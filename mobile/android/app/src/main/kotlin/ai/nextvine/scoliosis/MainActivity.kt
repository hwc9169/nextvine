package ai.nextvine.scoliosis

import android.graphics.*
import android.util.Log
import dev.eren.removebg.RemoveBg
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.max
import kotlin.math.min
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

object ImagePreprocessor {

  // --- RemoveBg instance (requires Context) ---
  private var remover: RemoveBg? = null
  fun init(context: android.content.Context) {
    remover = RemoveBg(context.applicationContext)
  }

  @JvmStatic
  fun preprocessTo4DList(
          source: Bitmap,
          width: Int = 1024,
          height: Int = 1024
  ): List<ArrayList<ArrayList<List<Double>>>> {
    val src = ensureArgb8888(source)
    val bmp =
            if (src.width == width && src.height == height) src
            else Bitmap.createScaledBitmap(src, width, height, true)

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
    if (bmp !== src) bmp.recycle()
    src.recycle()
    return listOf(img)
  }

  private fun ensureArgb8888(bmp: Bitmap): Bitmap =
          if (bmp.config == Bitmap.Config.ARGB_8888) bmp
          else bmp.copy(Bitmap.Config.ARGB_8888, false)

  // ---- IMPLEMENTED: remove background with the library ----
  @JvmStatic
  fun removeBackgroundAndWhiteCrop(source: Bitmap): Bitmap {
    val r =
            remover
                    ?: error(
                            "ImagePreprocessor not initialized. Call ImagePreprocessor.init(context) first."
                    )
    val src = ensureArgb8888(source)
    val cut: Bitmap =
            runBlocking(Dispatchers.Default) {
              r.clearBackground(src).first() ?: error("Failed to remove background")
            }
    val whiteBg = Bitmap.createBitmap(cut.width, cut.height, Bitmap.Config.ARGB_8888)
    Canvas(whiteBg).apply {
      drawColor(Color.WHITE)
      drawBitmap(cut, 0f, 0f, null)
    }

    val cropped = return cropNonWhite(whiteBg)
  }
  // The lib returns a Flow<Bitmap>; take the first (and only) emission.

  @JvmStatic
  fun cropNonWhite(source: Bitmap): Bitmap {
    val tol = 5
    val src = ensureArgb8888(source)
    val w = src.width
    val h = src.height
    val pixels = IntArray(w * h)
    src.getPixels(pixels, 0, w, 0, 0, w, h)

    var minX = w
    var minY = h
    var maxX = -1
    var maxY = -1
    fun isWhite(c: Int): Boolean {
      val r = (c shr 16) and 0xFF
      val g = (c shr 8) and 0xFF
      val b = c and 0xFF
      return r >= 255 - tol && g >= 255 - tol && b >= 255 - tol
    }
    for (y in 0 until h) {
      for (x in 0 until w) {
        val c = pixels[y * w + x]
        if (!isWhite(c)) {
          if (x < minX) minX = x
          if (y < minY) minY = y
          if (x > maxX) maxX = x
          if (y > maxY) maxY = y
        }
      }
    }

    if (maxX < 0 || maxY < 0) return src

    val left = max(0, minX)
    val top = max(0, minY)
    val right = min(w - 1, maxX)
    val bottom = min(h - 1, maxY)
    val cw = right - left + 1
    val ch = bottom - top + 1

    return Bitmap.createBitmap(src, left, top, cw, ch)
  }
}

class MainActivity : FlutterActivity() {
  private val CHANNEL = "ai.nextvine.scoliosis/angle"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Initialize once for the RemoveBg library
    ImagePreprocessor.init(applicationContext)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      when (call.method) {
        "preprocess" -> {
          val imagePath = call.argument<String>("imagePath")
          CoroutineScope(Dispatchers.Default).launch {
            try {
              val bmp =
                      BitmapFactory.decodeFile(imagePath ?: "")
                              ?: error("Cannot decode image: $imagePath")
              val cut = ImagePreprocessor.removeBackgroundAndWhiteCrop(bmp)
              // Save the preprocessed image to the gallery
              // val resolver = applicationContext.contentResolver
              // val values =
              //         ContentValues().apply {
              //           put(MediaStore.Images.Media.DISPLAY_NAME, "cut.png")
              //           put(MediaStore.Images.Media.MIME_TYPE, "image/png")
              //           put(
              //                   MediaStore.Images.Media.RELATIVE_PATH,
              //                   Environment.DIRECTORY_PICTURES + "/NextVine"
              //           )
              //           put(MediaStore.Images.Media.IS_PENDING, 1)
              //         }
              // val uri: Uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
              // values)!!
              // resolver.openOutputStream(uri)?.use { outputStream ->
              //   cut.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
              // }
              // values.clear()
              // values.put(MediaStore.Images.Media.IS_PENDING, 0)
              // resolver.update(uri, values, null, null)

              val preprocessed = ImagePreprocessor.preprocessTo4DList(cut)
              result.success(preprocessed) // nested lists are OK over MethodChannel
            } catch (e: Exception) {
              Log.e("MainActivity", "Preprocess error", e)
              result.error("PreprocessingError", e.message, null)
            }
          }
        }
        else -> result.notImplemented()
      }
    }
  }
}
