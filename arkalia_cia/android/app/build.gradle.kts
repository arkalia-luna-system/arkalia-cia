plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.example.arkalia_cia"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    
    // Supprimer les warnings Java obsolètes
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:-options")
    }

    kotlinOptions {
        jvmTarget = "17" // Aligné avec la version Kotlin du plugin
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.arkalia_cia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // ========================================================================
    // CONFIGURATION ULTRA-COMPLÈTE : Ignorer les fichiers macOS cachés
    // ========================================================================
    // Cette configuration s'ajoute à celle du build.gradle.kts racine
    // pour garantir une exclusion totale dans l'app Android
    
    sourceSets {
        getByName("main") {
            resources {
                // Exclure tous les patterns macOS
                // Note: Les exclusions sont gérées par le build.gradle.kts racine
                // Ici on configure seulement le packaging Android
            }
        }
    }
    
    // Configuration du packaging Android pour exclure ces fichiers
    // Cette configuration empêche les fichiers macOS d'être inclus dans l'APK/AAB
    packaging {
        resources {
            excludes += setOf(
                "**/._*",
                "**/._*/**",
                "**/.DS_Store",
                "**/.DS_Store?",
                "**/.AppleDouble/**",
                "**/.Spotlight-V100/**",
                "**/.Trashes/**",
                "META-INF/._*",
                "META-INF/._*/**"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
