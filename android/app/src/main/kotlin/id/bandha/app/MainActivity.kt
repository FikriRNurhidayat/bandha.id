package id.bandha.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import id.bandha.app.event_channel.stream_handlers.KeyboardVisibilityHandler

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, "id.bandha.app/keyboard")
      .setStreamHandler(KeyboardVisibilityHandler(this))
  }
}
