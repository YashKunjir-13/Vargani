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

// Several third-party plugins pin an older compileSdk in their own
// android/build.gradle than the AndroidX libraries they transitively pull in
// require (e.g. connectivity_plus, printing). Force every Android subproject
// (including plugins from the pub cache) to compile against a modern SDK
// instead of bumping each plugin version individually as this surfaces.
// Must run in afterEvaluate (each plugin's own build.gradle sets its lower
// compileSdkVersion during evaluation, so overriding earlier gets clobbered),
// but skip :app -- Flutter's own build.gradle.kts already forces :app to
// evaluate early via evaluationDependsOn(":app") above, so calling
// afterEvaluate on it again here throws "already evaluated".
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
