import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load environment variables from .env file
val envFile = File(rootProject.projectDir.parentFile, ".env")
val envVars = mutableMapOf<String, String>()
if (envFile.exists()) {
    envFile.readLines().forEach { line ->
        val matcher = Regex("^\\s*([^#][^=]+)=(.*)$").find(line)
        if (matcher != null) {
            val (key, value) = matcher.destructured
            envVars[key.trim()] = value.trim()
        }
    }
}

android {
    namespace = "com.trusted.trusted"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.trusted.trusted"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Set environment variables for use in AndroidManifest.xml
        manifestPlaceholders["GOOGLE_CLIENT_ID_ANDROID"] = envVars["GOOGLE_CLIENT_ID_ANDROID"] ?: ""
        manifestPlaceholders["GOOGLE_CLIENT_ID_WEB"] = envVars["GOOGLE_CLIENT_ID_WEB"] ?: ""
        manifestPlaceholders["DEEP_LINK_SCHEME"] = envVars["DEEP_LINK_SCHEME"] ?: ""
        manifestPlaceholders["DEEP_LINK_HOST"] = envVars["DEEP_LINK_HOST"] ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
