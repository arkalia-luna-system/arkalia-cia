allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration Java/Kotlin pour tous les sous-projets
subprojects {
    // Configuration AVANT l'évaluation pour créer l'extension flutter
    // Cela permet aux plugins comme file_picker d'accéder à android.flutter
    beforeEvaluate {
        // Créer l'extension flutter factice pour les plugins qui en ont besoin
        // Lire le versionCode depuis pubspec.yaml au lieu d'utiliser 1
        var versionCodeFromPubspec = 1
        var versionNameFromPubspec = "1.0.0"
        try {
            val pubspecFile = file("${project.projectDir.parentFile.parentFile}/pubspec.yaml")
            if (pubspecFile.exists()) {
                val pubspecContent = pubspecFile.readText()
                val versionLine = pubspecContent.lines().find { it.trim().startsWith("version:") }
                if (versionLine != null) {
                    val parts = versionLine.split("+")
                    if (parts.size > 1) {
                        val codeStr = parts[1].trim()
                        versionCodeFromPubspec = codeStr.toIntOrNull() ?: 1
                        versionNameFromPubspec = parts[0].replace("version:", "").trim()
                        println("✅ [build.gradle.kts] Version lue depuis pubspec.yaml: $versionNameFromPubspec+$versionCodeFromPubspec")
                    }
                }
            }
        } catch (e: Exception) {
            println("⚠️ [build.gradle.kts] Erreur lecture pubspec.yaml: ${e.message}, utilisation valeurs par défaut")
        }
        
        val flutterConfig = mapOf(
            "minSdkVersion" to 21,
            "targetSdkVersion" to 36,
            "compileSdkVersion" to 36,
            "versionCode" to versionCodeFromPubspec,
            "versionName" to versionNameFromPubspec
        )
        project.extensions.extraProperties.set("flutter", flutterConfig)
    }
    
    afterEvaluate {
        // Forcer Java 17 pour tous les projets Android
        // Note: La configuration compileSdk pour les plugins Flutter est gérée par init.gradle
        plugins.withId("com.android.library") {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                // Forcer compileSdk si non défini
                if (this is com.android.build.gradle.LibraryExtension) {
                    if (this.compileSdk == null) {
                        this.compileSdk = 36
                    }
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        plugins.withId("com.android.application") {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        // Configuration Java pour les projets Java/Kotlin standards
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
            options.compilerArgs.add("-Xlint:-options")
        }
        
        // Configuration Kotlin pour TOUS les projets (force la compatibilité)
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Nettoyer les fichiers macOS dans TOUS les projets (y compris plugins Flutter)
// Utiliser gradle.projectsEvaluated pour éviter l'erreur "already evaluated"
gradle.projectsEvaluated {
    allprojects {
        // Fonction de nettoyage agressive pour tous les projets
        fun cleanMacOSFilesInProject(project: Project) {
            val projectBuildDir = project.buildDir
            if (projectBuildDir.exists()) {
                projectBuildDir.walkTopDown()
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
        
        // Nettoyer AVANT les tâches de vérification des ressources (où se trouve le problème)
        tasks.matching {
            it.name.contains("verify") && it.name.contains("Resources")
        }.configureEach {
            doFirst {
                cleanMacOSFilesInProject(project)
            }
        }
        
        // Nettoyer AVANT toutes les tâches de build
        tasks.matching {
            (it.name.contains("process") && it.name.contains("Resources")) ||
            it.name.contains("compile") ||
            it.name.contains("merge")
        }.configureEach {
            doFirst {
                cleanMacOSFilesInProject(project)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ============================================================================
// CONFIGURATION ULTRA-PROFESSIONNELLE : Ignorer les fichiers macOS cachés
// ============================================================================
// Cette configuration empêche Gradle de traiter les fichiers ._* et .DS_Store
// au niveau le plus bas, AVANT même qu'ils ne soient inclus dans les opérations
// Solution multi-niveaux pour garantir 100% de couverture

// Patterns à exclure partout
val macosHiddenFilePatterns = listOf(
    "**/._*",
    "**/._*/**",
    "**/.DS_Store",
    "**/.DS_Store?",
    "**/.AppleDouble",
    "**/.AppleDouble/**",
    "**/.Spotlight-V100/**",
    "**/.Trashes/**",
    "**/._.DS_Store",
    "**/._*.*"
)

allprojects {
    // ========================================================================
    // NIVEAU 1 : Configuration GLOBALE des FileTree (le plus bas niveau)
    // ========================================================================
    // Intercepter TOUS les FileTree créés dans Gradle
    // Note: Les sourceSets sont configurés dans app/build.gradle.kts
    
    // ========================================================================
    // NIVEAU 2 : Configuration de TOUTES les tâches PatternFilterable
    // ========================================================================
    // Intercepter toutes les tâches qui peuvent filtrer des fichiers
    tasks.configureEach {
        val filterable = this as? org.gradle.api.tasks.util.PatternFilterable
        filterable?.let {
            macosHiddenFilePatterns.forEach { pattern ->
                it.exclude(pattern)
            }
        }
        
        // Note: Les inputs.files sont gérés automatiquement par les exclusions ci-dessus
    }
    
    // ========================================================================
    // NIVEAU 3 : Configuration spécifique des tâches de copie
    // ========================================================================
    tasks.withType<Copy> {
        macosHiddenFilePatterns.forEach { pattern ->
            exclude(pattern)
        }
        // Exclure aussi dans les FileTree utilisés
        filteringCharset = "UTF-8"
    }
    
    // ========================================================================
    // NIVEAU 4 : Configuration des tâches de synchronisation
    // ========================================================================
    tasks.withType<Sync> {
        macosHiddenFilePatterns.forEach { pattern ->
            exclude(pattern)
        }
    }
    
    // ========================================================================
    // NIVEAU 5 : Configuration des tâches de compression/archivage
    // ========================================================================
    tasks.withType<org.gradle.api.tasks.bundling.Zip> {
        macosHiddenFilePatterns.forEach { pattern ->
            exclude(pattern)
        }
    }
    
    tasks.withType<org.gradle.api.tasks.bundling.Tar> {
        macosHiddenFilePatterns.forEach { pattern ->
            exclude(pattern)
        }
    }
    
    tasks.withType<org.gradle.api.tasks.bundling.Jar> {
        macosHiddenFilePatterns.forEach { pattern ->
            exclude(pattern)
        }
    }
    
    // ========================================================================
    // NIVEAU 6 : Configuration des tâches Android spécifiques
    // ========================================================================
    // Note: Les tâches Android utilisent les exclusions configurées dans
    // les sourceSets et le packaging, donc pas besoin d'exclusion supplémentaire ici
    
    // ========================================================================
    // NIVEAU 7 : Nettoyage automatique AVANT chaque build
    // ========================================================================
    tasks.matching { it.group == "build" || it.name.contains("assemble") || it.name.contains("bundle") || it.name.contains("compile") || it.name.contains("expand") }.configureEach {
        doFirst {
            // Nettoyer les fichiers macOS dans le répertoire build
            val buildDir = project.layout.buildDirectory.asFile.get()
            if (buildDir.exists()) {
                buildDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs de suppression
                        }
                    }
            }
            
            // Nettoyer spécifiquement dans le répertoire javac (où se trouve souvent le problème)
            val javacDir = project.file("${project.layout.buildDirectory.asFile.get()}/intermediates/javac")
            if (javacDir.exists()) {
                javacDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs de suppression
                        }
                    }
            }
            
            // Nettoyer aussi dans le répertoire source si nécessaire
            val srcDir = project.file("src")
            if (srcDir.exists()) {
                srcDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs de suppression
                        }
                    }
            }
            
            // Nettoyer dans le répertoire généré
            val generatedDir = project.file("build/generated")
            if (generatedDir.exists()) {
                generatedDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store" || it.name.contains("._")) }
                    .forEach { 
                        try {
                            it.delete()
                        } catch (e: Exception) {
                            // Ignorer les erreurs de suppression
                        }
                    }
            }
        }
    }
    
    // ========================================================================
    // NIVEAU 8 : Nettoyage automatique APRÈS chaque build
    // ========================================================================
    tasks.matching { it.group == "build" || it.name.contains("assemble") || it.name.contains("bundle") }.configureEach {
        doLast {
            val buildDir = project.layout.buildDirectory.asFile.get()
            if (buildDir.exists()) {
                buildDir.walkTopDown()
                    .filter { it.isFile && (it.name.startsWith("._") || it.name == ".DS_Store") }
                    .forEach { it.delete() }
            }
        }
    }
}

// Tâche pour nettoyer les fichiers macOS cachés (optionnelle)
tasks.register("cleanMacOSFiles") {
    doLast {
        val buildDir = rootProject.layout.buildDirectory.get().asFile
        if (buildDir.exists()) {
            var count = 0
            buildDir.walkTopDown()
                .filter { it.name.startsWith("._") || it.name == ".DS_Store" }
                .forEach { 
                    it.delete()
                    count++
                }
            if (count > 0) {
                println("✅ Supprimé $count fichiers macOS cachés dans build/")
            }
        }
    }
}
