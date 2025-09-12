package ai.nextvine.scoliosis

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object ImagePreprocessor {
  @JvmStatic
  fun preprocessTo4DList(
          path: String,
          width: Int = 1024,
          height: Int = 1024
  ): List<ArrayList<ArrayList<List<Double>>>> {
    val bmp0 =
            BitmapFactory.decodeFile(path)
                    ?: throw IllegalArgumentException("Cannot decode image: $path")
    val bmp =
            if (bmp0.width == width && bmp0.height == height) bmp0
            else Bitmap.createScaledBitmap(bmp0, width, height, true)

    val pixels = IntArray(width * height)
    bmp.getPixels(pixels, 0, width, 0, 0, width, height)

    val img = ArrayList<ArrayList<List<Double>>>(height)
    var i = 0
    for (y in 0 until height) {
      val row = ArrayList<List<Double>>(width)
      for (x in 0 until width) {
        val p = pixels[i++]
        val r = ((p shr 16) and 0xFF).toDouble()
        val g = ((p shr 8) and 0xFF).toDouble()
        val b = (p and 0xFF).toDouble()
        row.add(listOf(r, g, b))
      }
      img.add(row)
    }
    if (bmp !== bmp0) bmp0.recycle()
    bmp.recycle()

    return listOf(img)
  }

  fun removeBackground(): String {
    return ""
  }
}

class MainActivity : FlutterActivity() {
  private val CHANNEL = "ai.nextvine.scoliosis/angle"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      when (call.method) {
        "preprocess" -> {
          val imagePath = call.argument<String>("imagePath")
          try {
            val preprocessedData = ImagePreprocessor.preprocessTo5DList(imagePath ?: "")
            result.success(preprocessedData.toList())
          } catch (e: Exception) {
            result.error("PreprocessingError", e.message, null)
          }
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }
}
