import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Configuration Flutter - doit être définie AVANT le bloc android
// pour que flutter.minSdkVersion, etc. soient disponibles
flutter {
    source = file("../..")
}

// Charger les propriétés de signature depuis key.properties (si existe)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
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
        // Application ID unique pour Arkalia CIA
        applicationId = "com.arkalia.cia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Configuration de signature release (si key.properties existe)
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                val keystorePath = keystoreProperties["storeFile"] as String
                storeFile = if (keystorePath.startsWith("/")) {
                    file(keystorePath)
                } else {
                    file("${rootProject.projectDir}/${keystorePath}")
                }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Utiliser la signature release si configurée, sinon debug (pour développement)
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Signing with the debug keys for now, so `flutter run --release` works.
                signingConfig = signingConfigs.getByName("debug")
            }
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
    
    // Nettoyer les fichiers macOS AVANT processReleaseResources
    afterEvaluate {
        tasks.named("processReleaseResources").configure {
            doFirst {
                val intermediatesDir = file("${project.buildDir}/intermediates/merged_res/release/mergeReleaseResources")
                if (intermediatesDir.exists()) {
                    intermediatesDir.walkTopDown()
                        .filter { it.isFile && (it.name.startsWith("._") || it.name.contains("._")) }
                        .forEach { 
                            try {
                                it.delete()
                            } catch (e: Exception) {
                                // Ignorer les erreurs
                            }
                        }
                }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
