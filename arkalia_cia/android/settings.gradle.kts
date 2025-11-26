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

// Configurer flutter.source AVANT que les projets ne soient évalués
// Le plugin Flutter Gradle cherche cette propriété au moment de son application
// Note: Le plugin lit depuis gradle.properties directement, pas besoin de stocker ici
val gradleProps = java.util.Properties()
val gradlePropsFile = file("gradle.properties")
if (gradlePropsFile.exists()) {
    gradlePropsFile.inputStream().use { gradleProps.load(it) }
}
val flutterSourceFromProps = gradleProps.getProperty("flutter.source")
if (flutterSourceFromProps != null) {
    println("✅ Flutter source directory configuré depuis gradle.properties: $flutterSourceFromProps")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
