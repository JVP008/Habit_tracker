plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Configure JVM Toolchain for all projects that apply the Kotlin Android plugin
    afterEvaluate {
        if (project.plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            project.extensions.getByType<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidExtension>().apply {
                jvmToolchain(17)
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

    // Explicitly set Java compatibility for JavaCompile tasks
    project.tasks.withType<JavaCompile> {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
