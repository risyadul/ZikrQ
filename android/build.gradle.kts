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

    // Fix for legacy Flutter plugins (e.g. isar_flutter_libs 3.x) that predate
    // the AGP 8.x requirement for an explicit `namespace` in build.gradle.
    // Must be registered here (before evaluationDependsOn) so afterEvaluate
    // runs before the project is forced-evaluated.
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val lib = project.extensions
                .findByType<com.android.build.gradle.LibraryExtension>()
            if (lib?.namespace == null) {
                val manifest = project.file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = Regex("""package="([^"]+)"""")
                        .find(manifest.readText())?.groupValues?.get(1)
                    if (!pkg.isNullOrEmpty()) {
                        lib?.namespace = pkg
                    }
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
