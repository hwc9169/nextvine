allprojects {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }

    // Global dependency resolution strategy
    configurations.all {
        resolutionStrategy {
            // Force androidx.activity:activity-ktx to a stable version
            force("androidx.activity:activity-ktx:1.8.2")
            // Force androidx.preference:preference to the version that works with activity-ktx 1.8.2
            force("androidx.preference:preference:1.2.1")
            // Force androidx.fragment:fragment-ktx to a compatible version
            force("androidx.fragment:fragment-ktx:1.6.2")
        }
    }
}

buildscript {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io")}
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.5.0")
        //classpath("com.chaquo.python:gradle:16.1.0")
    }
}

plugins {
 //   id("com.chaquo.python") version "15.0.1" apply false
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
