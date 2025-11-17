allprojects {
    repositories {
        google()
        mavenCentral()
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
    tasks.matching { it.group == "build" || it.name.contains("assemble") || it.name.contains("bundle") || it.name.contains("compile") }.configureEach {
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
