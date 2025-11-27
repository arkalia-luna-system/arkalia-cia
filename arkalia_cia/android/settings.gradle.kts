// Configurer flutter.source AVANT pluginManagement pour que le plugin puisse le lire
// Le plugin Flutter Gradle lit cette propriété depuis gradle.properties ou -P
// On s'assure que gradle.properties contient le bon chemin (absolu en CI, relatif en local)
val gradlePropsFile = file("gradle.properties")
var flutterSourcePath: String? = null

// Lire depuis -P (priorité maximale)
flutterSourcePath = gradle.startParameter.projectProperties["flutter.source"] as? String

// Si pas dans -P, lire depuis gradle.properties
if (flutterSourcePath == null && gradlePropsFile.exists()) {
    val gradleProps = java.util.Properties()
    gradlePropsFile.inputStream().use { gradleProps.load(it) }
    val flutterSourceFromProps = gradleProps.getProperty("flutter.source")
    
    if (flutterSourceFromProps != null) {
        val sourceFile = file(flutterSourceFromProps)
        // Toujours convertir en absolu pour être sûr
        flutterSourcePath = if (sourceFile.isAbsolute) {
            sourceFile.absolutePath
        } else {
            sourceFile.absoluteFile.absolutePath
        }
        
        // Mettre à jour gradle.properties avec le chemin absolu
        gradleProps.setProperty("flutter.source", flutterSourcePath)
        gradlePropsFile.outputStream().use { gradleProps.store(it, null) }
    }
}

// Si toujours pas défini, utiliser le fallback
if (flutterSourcePath == null) {
    flutterSourcePath = file("..").absoluteFile.absolutePath
    // Ajouter à gradle.properties
    if (gradlePropsFile.exists()) {
        val gradleProps = java.util.Properties()
        gradlePropsFile.inputStream().use { gradleProps.load(it) }
        gradleProps.setProperty("flutter.source", flutterSourcePath)
        gradlePropsFile.outputStream().use { gradleProps.store(it, null) }
    }
}

// S'assurer que la propriété est disponible via les propriétés système ET local.properties
// Le plugin Flutter Gradle lit depuis local.properties en priorité
if (flutterSourcePath != null) {
    // FORCER la propriété dans gradle.startParameter.projectProperties
    // Le plugin Flutter Gradle lit cette propriété au moment de son application
    gradle.startParameter.projectProperties["flutter.source"] = flutterSourcePath
    
    // Aussi dans local.properties qui est lu très tôt par Gradle
    val localPropsFile = file("local.properties")
    if (localPropsFile.exists()) {
        val localProps = java.util.Properties()
        localPropsFile.inputStream().use { localProps.load(it) }
        localProps.setProperty("flutter.source", flutterSourcePath)
        localPropsFile.outputStream().use { localProps.store(it, null) }
    }
    
    println("✅ Flutter source directory configuré: $flutterSourcePath")
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
