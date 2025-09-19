import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

 //   id("com.chaquo.python") 
}

val keystoreProps = Properties().apply {
    FileInputStream(file("../key.properties")).use { load(it) }
}

android {
    namespace = "ai.nextvine.scoliosis"
    compileSdk = 36
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ai.nextvine.scoliosis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "x86_64"))
        }
    }

    signingConfigs {
        create("scolioscan-release") {
            val storeFilePath = keystoreProps.getProperty("storeFile") ?: ""
            storeFile = if (storeFilePath.isNotEmpty()) file(storeFilePath) else null
            storePassword = keystoreProps.getProperty("storePassword")
            keyAlias = keystoreProps.getProperty("keyAlias")
            keyPassword = keystoreProps.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("scolioscan-release") // signing key is in the root directory
        }
    }
}

//chaquopy {
//    defaultConfig {
//        buildPython("C:/Users/GPU_6/Desktop/Repository/nextvine/mobile/android/app/src/main/python/.venv/Scripts/python.exe")
//        pip {
//            install("pillow")
//            install("numpy<2.0.0")
//            install("jsonschema==2.6")
//        }
//    }
//}

flutter {
    source = "../.."
}

repositories {
    maven { url = uri("https://jitpack.io")}
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.0")


    implementation("com.microsoft.onnxruntime:onnxruntime-android:1.22.0")
    implementation("com.github.erenalpaslan:removebg:1.0.4")
    implementation("org.tensorflow:tensorflow-lite-gpu-delegate-plugin:0.4.4")
    implementation("com.google.android.material:material:1.13.0")

}
