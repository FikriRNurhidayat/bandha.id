package id.bandha.app.plugins

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream

class FilePicker : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
  private var binding: ActivityPluginBinding? = null
  private lateinit var channel: MethodChannel

  companion object {
    private const val REQUEST_CODE_PICK_FILE = 1001
    private const val REQUEST_CODE_SAVE_FILE = 1002
  }

  // --- FlutterPlugin Lifecycle ---
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "id.bandha.app/plugins/file_picker")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // --- ActivityAware Setup ---
  override fun onAttachedToActivity(activityBinding: ActivityPluginBinding) {
    binding = activityBinding
  }

  override fun onReattachedToActivityForConfigChanges(activityBinding: ActivityPluginBinding) {
    binding = activityBinding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    binding = null
  }

  override fun onDetachedFromActivity() {
    binding = null
  }

  // --- MethodCallHandler ---
  override fun onMethodCall(
      call: MethodCall,
      result: MethodChannel.Result,
  ) {
    when (call.method) {
      "pickFile" -> {
        pickFile(call, result)
      }

      "saveFile" -> {
        saveFile(call, result)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun pickFile(
      call: MethodCall,
      result: MethodChannel.Result,
  ) {
    val mimeTypes = call.argument<List<String>>("mimeTypes")?.toTypedArray()
    val intent =
        Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
          addCategory(Intent.CATEGORY_OPENABLE)
          type = if (!mimeTypes.isNullOrEmpty() && mimeTypes.size == 1) mimeTypes[0] else "*/*"
          if (!mimeTypes.isNullOrEmpty() && mimeTypes.size > 1) {
            putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
          }
        }

    launchFilePicker(intent, REQUEST_CODE_PICK_FILE, result) { activity, uri ->
      try {
        val fileName = getFileName(activity, uri);
        val destinationFile = File(activity.cacheDir, fileName)
        destinationFile.parentFile?.mkdirs()
        activity.contentResolver.openInputStream(uri)?.use { inputStream ->
          FileOutputStream(destinationFile).use { outputStream -> inputStream.copyTo(outputStream) }
        }

        result.success(destinationFile.absolutePath)
      } catch (e: Exception) {
        result.error("COPY_FAILED", "Failed to process picked file: ${e.message}", null)
      }
    }
  }

  private fun saveFile(
      call: MethodCall,
      result: MethodChannel.Result,
  ) {
    val filePath = call.argument<String>("filePath")
    val fileName = call.argument<String>("fileName")
    val mimeType = call.argument<String>("mimeType") ?: "*/*"

    if (filePath.isNullOrEmpty()) {
      result.error("INVALID_FILE", "Source file is empty", null)
      return
    }

    if (!File(filePath).exists()) {
      result.error("INVALID_FILE", "Source file does not exist", null)
      return
    }

    val intent =
        Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
          addCategory(Intent.CATEGORY_OPENABLE)
          type = mimeType
          putExtra(Intent.EXTRA_TITLE, fileName)
        }

    launchFilePicker(intent, REQUEST_CODE_SAVE_FILE, result) { activity, uri ->
      try {
        val source = File(filePath)
        source.inputStream().use { inputStream ->
          activity.contentResolver.openOutputStream(uri)?.use { outputStream ->
            inputStream.copyTo(outputStream)
          }
        }
        result.success(uri.toString())
      } catch (e: Exception) {
        result.error("EXPORT_FAILED", "Failed to save file: ${e.message}", null)
      }
    }
  }

  private fun launchFilePicker(
      intent: Intent,
      requestCode: Int,
      result: MethodChannel.Result,
      onSuccess: (Activity, Uri) -> Unit,
  ) {
    val currentBinding =
        binding
            ?: run {
              result.error("NO_ACTIVITY", "Activity context unavailable", null)
              return
            }

    val listener =
        object : PluginRegistry.ActivityResultListener {

          override fun onActivityResult(reqCode: Int, resultCode: Int, data: Intent?): Boolean {
            if (reqCode != requestCode) return false

            currentBinding.removeActivityResultListener(this)

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
              onSuccess(currentBinding.activity, data.data!!)
            } else {
              result.success(null)
            }

            return true
          }
        }

    currentBinding.addActivityResultListener(listener)
    currentBinding.activity.startActivityForResult(intent, requestCode)
  }

  fun getFileName(context: Context, uri: Uri): String? {
    var name: String? = null
    val cursor: Cursor? = context.contentResolver.query(uri, null, null, null, null)
    cursor?.use {
      if (it.moveToFirst()) {
        val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
        if (nameIndex != -1) {
          name = it.getString(nameIndex)
        }
      }
    }
    return name
  }
}
