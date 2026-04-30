plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rw.atik_mobil_uygulama"
    
    // ✅ BURAYI 34 YAPTIK (Kararlı Sürüm)
    compileSdk = 34 
    
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.rw.atik_mobil_uygulama"
        
        // Kamera için en az 21 gerekli
        minSdk = 21 
        
        // ✅ BURAYI DA 34 YAPTIK
        targetSdk = 34
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 👇 BU KODU EN ALTA YAPIŞTIR
// Bu kod, arka plandaki kütüphanelerin en son sürüm yerine
// Android 14 (SDK 34) ile uyumlu olan sürümü kullanmasını zorlar.
configurations.all {
    resolutionStrategy {
        force("androidx.activity:activity:1.9.3")
    }
}