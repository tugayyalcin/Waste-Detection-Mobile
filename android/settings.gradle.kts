pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
    // 7.3.0 -> 7.3.1 yapıyoruz
    id("com.android.application") version "7.3.1" apply false 
    
    // 1.7.10 -> 1.8.10 yapıyoruz
    id("org.jetbrains.kotlin.android") version "1.8.10" apply false
}

include(":app")
