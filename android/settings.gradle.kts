pluginManagement {
    plugins {
        id("com.android.application") version "8.1.0"
        id("org.jetbrains.kotlin.android") version "1.9.10"       // ✅ Kotlin Android plugin
        id("com.google.gms.google-services") version "4.4.0"
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal() // 🔐 Needed for Kotlin plugins
    }

    val localProperties = java.util.Properties().apply {
        val file = File(rootDir, "local.properties")
        if (file.exists()) {
            file.reader().use(::load)
        } else {
            throw GradleException("local.properties file not found at ${file.absolutePath}")
        }
    }

    val flutterSdkPath = localProperties.getProperty("flutter.sdk")
        ?: throw GradleException("flutter.sdk not set in local.properties")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

include(":app")
