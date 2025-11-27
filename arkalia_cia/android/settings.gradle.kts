// Configurer flutter.source AVANT pluginManagement pour que le plugin puisse le lire
// Le plugin Flutter Gradle lit cette propriété depuis gradle.properties
// On s'assure que gradle.properties contient le bon chemin (absolu en CI, relatif en local)
val gradlePropsFile = file("gradle.properties")
if (gradlePropsFile.exists()) {
    val gradleProps = java.util.Properties()
    gradlePropsFile.inputStream().use { gradleProps.load(it) }
    val flutterSourceFromProps = gradleProps.getProperty("flutter.source")
    
    // Si flutter.source est défini mais est relatif, on le convertit en absolu
    if (flutterSourceFromProps != null) {
        val sourceFile = file(flutterSourceFromProps)
        if (!sourceFile.isAbsolute) {
            // Convertir le chemin relatif en absolu et mettre à jour gradle.properties
            val absolutePath = sourceFile.absoluteFile.absolutePath
            gradleProps.setProperty("flutter.source", absolutePath)
            gradlePropsFile.outputStream().use { gradleProps.store(it, null) }
        }
    } else {
        // Si flutter.source n'est pas défini, utiliser le fallback et l'ajouter à gradle.properties
        val fallbackPath = file("..").absoluteFile.absolutePath
        gradleProps.setProperty("flutter.source", fallbackPath)
        gradlePropsFile.outputStream().use { gradleProps.store(it, null) }
    }
}

pluginManagement {
    val flutterSdkPath =
        run {
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
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
