package ai.nextvine.scoliosis

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.PyException

class MainActivity : FlutterActivity() {
  private val CHANNEL = "ai.nextvine.scoliosis/angle"
  
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    if (!Python.is){
      Python.start(AndroidPlatform(this))
    }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "estimate_angle" -> {
          val image = call.argument<Image>("image")

          val py = Python.getInstance()
          val module = py.getModule("main")
          val method = module.getFunction("estimate_angle")
          val angle = method.invoke(image)
          result.success(angle)
        }
      }
    }
  }
}
    val python = Python.getInstance()
    val module = python.getModule("scoliosis")
    val method = module.getFunction("estimate_angle")
  }
}
