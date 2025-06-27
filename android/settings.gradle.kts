pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    
    val localProperties = java.util.Properties().apply {
        file("../local.properties").reader().use(::load)
    }
    val flutterSdkPath = localProperties.getProperty("flutter.sdk")
        ?: throw GradleException("flutter.sdk not set in local.properties")
    
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") apply false
}

include(":app")