package id.bandha.app.event_channel.stream_handlers

import android.app.Activity
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.plugin.common.EventChannel

class KeyboardVisibilityHandler(
    private val activity: Activity
) : EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null
    private var listenerAttached = false

    private val insetsListener: (View, WindowInsetsCompat) -> WindowInsetsCompat = { _, insets ->
        val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
        val visible = insets.isVisible(WindowInsetsCompat.Type.ime())
        sink?.success(
            hashMapOf(
                "visible" to visible,
                "height" to imeInsets.bottom.toFloat()
            )
        )
        insets
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (activity.isFinishing || activity.isDestroyed) return
        sink = events
        if (!listenerAttached) {
            ViewCompat.setOnApplyWindowInsetsListener(
                activity.window.decorView,
                insetsListener
            )
            listenerAttached = true
        }
    }

    override fun onCancel(arguments: Any?) {
        if (listenerAttached && !activity.isFinishing && !activity.isDestroyed) {
            ViewCompat.setOnApplyWindowInsetsListener(
                activity.window.decorView,
                null
            )
            listenerAttached = false
        }
        sink = null
    }
}
