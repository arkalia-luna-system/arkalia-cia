import java.util.Properties

// ========================================================================
// CONFIGURATION FLUTTER.SOURCE - CRITIQUE AVANT APPLICATION DU PLUGIN
// ========================================================================
// Le plugin Flutter Gradle lit flutter.source au moment où il est appliqué
// dans le bloc plugins {}. On doit le configurer AVANT avec beforeEvaluate
// ou directement dans les propriétés que le plugin lit.

// Fonction pour déterminer le répertoire source Flutter
fun determineFlutterSourceDir(): java.io.File {
    // Lire depuis -P (priorité maximale)
    val flutterSourceFromGradleProps = gradle.startParameter.projectProperties["flutter.source"] as? String
    val flutterSourceFromSystem = project.findProperty("flutter.source") as? String
    
    // Lire aussi depuis gradle.properties
    val gradleProps = Properties()
    val gradlePropsFile = rootProject.file("gradle.properties")
    if (gradlePropsFile.exists()) {
        gradlePropsFile.inputStream().use { gradleProps.load(it) }
    }
    val flutterSourceFromProps = gradleProps.getProperty("flutter.source")
    
    // Lire aussi depuis local.properties (priorité pour le plugin)
    val localProps = Properties()
    val localPropsFile = rootProject.file("local.properties")
    if (localPropsFile.exists()) {
        localPropsFile.inputStream().use { localProps.load(it) }
    }
    val flutterSourceFromLocal = localProps.getProperty("flutter.source")
    
    // Déterminer le répertoire source Flutter (priorité: -P > local.properties > gradle.properties > fallback)
    return when {
        flutterSourceFromGradleProps != null -> file(flutterSourceFromGradleProps)
        flutterSourceFromLocal != null -> {
            val sourceFile = file(flutterSourceFromLocal)
            if (sourceFile.isAbsolute) sourceFile else rootProject.file(flutterSourceFromLocal)
        }
        flutterSourceFromSystem != null -> file(flutterSourceFromSystem)
        flutterSourceFromProps != null -> {
            val sourceFile = file(flutterSourceFromProps)
            if (sourceFile.isAbsolute) sourceFile else rootProject.file(flutterSourceFromProps)
        }
        else -> projectDir.parentFile.parentFile // Fallback
    }
}

// Configurer flutter.source AVANT que le plugin ne soit appliqué
val flutterSourceDir = determineFlutterSourceDir()
val flutterSourceAbsolutePath = flutterSourceDir.absolutePath

// Stocker dans project.ext pour que le plugin puisse y accéder
project.ext.set("flutter.source", flutterSourceAbsolutePath)

// Aussi définir comme propriété du projet (le plugin lit depuis project.findProperty)
project.setProperty("flutter.source", flutterSourceAbsolutePath)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Configuration Flutter - Le plugin devrait avoir lu flutter.source depuis -P, gradle.properties, local.properties, ou project.ext
// On le confirme ici aussi pour être sûr
flutter {
    source = flutterSourceAbsolutePath
}

// Charger les propriétés de signature depuis key.properties (si existe)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

// Fonction pour extraire le version code depuis pubspec.yaml (définie AVANT android {})
// Retourne un Long pour gérer les grands nombres, puis converti en Int avec modulo si nécessaire
fun extractVersionCodeFromPubspec(): Long {
        return try {
            // Lire directement depuis pubspec.yaml (plus fiable que flutter.versionCode)
            // Utiliser flutterSourceDir qui pointe vers le répertoire racine Flutter
            val pubspecFile = file("${flutterSourceDir}/pubspec.yaml")
            println("🔍 Recherche pubspec.yaml dans: ${pubspecFile.absolutePath}")
            if (pubspecFile.exists()) {
                val pubspecContent = pubspecFile.readText()
                println("📄 Contenu pubspec.yaml lu (${pubspecContent.length} caractères)")
                // Extraire le version code depuis "version: X.Y.Z+CODE" ou "version: X.Y.Z+CODE"
                // Regex améliorée pour gérer différents formats
                val versionLine = pubspecContent.lines().find { it.trim().startsWith("version:") }
                println("📝 Ligne version trouvée: $versionLine")
                if (versionLine != null) {
                    // Extraire le nombre après le + (utiliser split qui est plus fiable)
                    // Format: "version: 1.3.1+2512070141" ou "version:1.3.1+2512070141"
                    val parts = versionLine.split("+")
                    println("🔍 [DEBUG] parts.size: ${parts.size}, parts: $parts")
                    if (parts.size > 1) {
                        val codeStr = parts[1].trim()
                        println("🔍 [DEBUG] codeStr: '$codeStr', length: ${codeStr.length}, toIntOrNull(): ${codeStr.toIntOrNull()}")
                        // Utiliser toLongOrNull directement pour gérer les grands nombres
                        val codeLong = codeStr.toLongOrNull()
                        if (codeLong == null) {
                            println("❌ [DEBUG] Impossible de convertir '$codeStr' en Long")
                            return@extractVersionCodeFromPubspec 1L
                        }
                        println("🔢 Version Code extrait depuis pubspec.yaml: $codeLong (depuis: $versionLine, split: '$codeStr')")
                        codeLong
                    } else {
                        println("⚠️ Aucun '+' trouvé dans: $versionLine")
                        // Essayer avec regex en dernier recours
                        val regexMatch = Regex("\\+(\\d+)").findAll(versionLine).lastOrNull()
                        if (regexMatch != null) {
                            val versionCodeStr = regexMatch.groupValues[1]
                            val codeInt = versionCodeStr.toIntOrNull() ?: 1
                            println("🔢 Version Code extrait (regex fallback): $codeInt (groupe: '$versionCodeStr')")
                            codeInt
                        } else {
                            println("⚠️ Aucun version code trouvé dans pubspec.yaml, utilisation de 1")
                            1
                        }
                    }
                } else {
                    println("⚠️ Ligne 'version:' introuvable dans pubspec.yaml, utilisation de 1")
                    1
                }
            } else {
                println("⚠️ pubspec.yaml introuvable à ${pubspecFile.absolutePath}")
                // Fallback: essayer avec un chemin relatif depuis projectDir
                val fallbackPubspec = file("${project.projectDir}/../../pubspec.yaml")
                println("🔍 Essai fallback: ${fallbackPubspec.absolutePath}")
                if (fallbackPubspec.exists()) {
                    val pubspecContent = fallbackPubspec.readText()
                    val versionLine = pubspecContent.lines().find { it.trim().startsWith("version:") }
                    if (versionLine != null) {
                        // Utiliser split comme méthode principale (cohérent avec le code principal)
                        val parts = versionLine.split("+")
                        if (parts.size > 1) {
                            val codeStr = parts[1].trim()
                            val codeLong = codeStr.toLongOrNull() ?: 1L
                            println("🔢 Version Code extrait depuis pubspec.yaml (fallback): $codeLong (split: '$codeStr')")
                            codeLong
                        } else {
                            println("⚠️ Aucun version code trouvé dans pubspec.yaml (fallback), utilisation de 1")
                            1L
                        }
                    } else {
                        println("⚠️ Ligne 'version:' introuvable (fallback), utilisation de 1")
                        1L
                    }
                } else {
                    println("⚠️ pubspec.yaml introuvable (fallback aussi), utilisation de 1")
                    1L
                }
            }
        } catch (e: Exception) {
            println("⚠️ Erreur lors de l'extraction du versionCode: ${e.message}")
            e.printStackTrace()
            1L
        }
    }

android {
    namespace = "com.arkalia.cia"
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
        // Utiliser la fonction extractVersionCodeFromPubspec() qui lit directement depuis pubspec.yaml
        // Plus fiable que flutter.versionCode qui peut causer des erreurs de conversion
        versionCode = try {
            val code = extractVersionCodeFromPubspec()
            // S'assurer que le code est dans les limites d'Android (Int.MAX_VALUE)
            if (code > Int.MAX_VALUE) {
                // Si le versionCode dépasse Int.MAX_VALUE, utiliser un modulo
                (code % Int.MAX_VALUE).toInt().coerceAtLeast(1)
            } else {
                code.coerceIn(1, Int.MAX_VALUE)
            }
        } catch (e: Exception) {
            println("⚠️ Erreur extraction versionCode: ${e.message}, utilisation de 1")
            1
        }
        versionName = flutter.versionName
        println("✅ versionCode: $versionCode, versionName: $versionName")
    }
    
    // Plus besoin de afterEvaluate - on utilise directement flutter.versionCode

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
    
    // Nettoyer les fichiers macOS AVANT toutes les tâches de build
    afterEvaluate {
        // Fonction de nettoyage réutilisable et agressive
        fun cleanMacOSFiles() {
            // Nettoyer dans le répertoire build de l'app
            val appBuildDir = project.buildDir
            if (appBuildDir.exists()) {
                appBuildDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs
                        }
                    }
            }
            
            // Nettoyer dans le répertoire build racine (contient les builds des plugins)
            val rootBuildDir = rootProject.layout.buildDirectory.asFile.get()
            if (rootBuildDir.exists()) {
                rootBuildDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs
                        }
                    }
            }
            
            // Nettoyer spécifiquement dans le répertoire javac (où se trouve le problème)
            val javacDir = project.file("${project.buildDir}/intermediates/javac")
            if (javacDir.exists()) {
                javacDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs
                        }
                    }
            }
        }
        
        // Nettoyer AVANT la tâche expandReleaseArtProfileWildcards (qui échoue)
        // Cette tâche lit les fichiers .class et échoue si elle trouve une référence à un fichier ._*
        tasks.matching { 
            it.name.contains("expand") && it.name.contains("ArtProfile")
        }.configureEach {
            doFirst {
                // Nettoyer les fichiers macOS
                cleanMacOSFiles()
                
                // Nettoyer aussi les références dans les répertoires de classes
                val classesDir = project.file("${project.buildDir}/intermediates/javac/release/compileReleaseJavaWithJavac/classes")
                if (classesDir.exists()) {
                    classesDir.walkTopDown()
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
        
        // Nettoyer AVANT les tâches de compilation Java (le plus tôt possible)
        tasks.matching { 
            it.name.contains("compile") && it.name.contains("Java")
        }.configureEach {
            doFirst {
                cleanMacOSFiles()
            }
        }
        
        // Nettoyer AVANT la génération des classes (avant même la compilation)
        tasks.matching { 
            it.name.contains("generate") || it.name.contains("transform")
        }.configureEach {
            doFirst {
                cleanMacOSFiles()
            }
        }
        
        // Nettoyer dans tous les répertoires de build (app + plugins)
        // Utiliser tasks.matching pour trouver les tâches qui existent
        tasks.matching { 
            it.name.contains("process") && it.name.contains("Resources") ||
            it.name.contains("verify") && it.name.contains("Resources")
        }.configureEach {
            doFirst {
                cleanMacOSFiles()
            }
        }
        
        // Nettoyer AVANT toutes les tâches de build/release
        tasks.matching { 
            it.name.contains("bundle") || it.name.contains("assemble") || it.name.contains("build")
        }.configureEach {
            doFirst {
                cleanMacOSFiles()
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
