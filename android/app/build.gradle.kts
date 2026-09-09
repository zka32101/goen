plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yourwish.goen"
    compileSdk = 36  // Updated to 36 to satisfy in_app_purchase_android and androidx dependency requirements
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Unique Application ID for GoEn (碁縁)
        applicationId = "com.yourwish.goen"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Release signing config - loads from environment or gradle.properties
        create("release") {
            storeFile = file(
                System.getenv("ANDROID_KEYSTORE_PATH")
                    ?: project.findProperty("ANDROID_KEYSTORE_PATH") as String?
                    ?: "app/goen-release.keystore"
            )
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                ?: project.findProperty("ANDROID_KEYSTORE_PASSWORD") as String?
                ?: "changeme"
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                ?: project.findProperty("ANDROID_KEY_ALIAS") as String?
                ?: "goen-key"
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                ?: project.findProperty("ANDROID_KEY_PASSWORD") as String?
                ?: "changeme"
        }
    }

    buildTypes {
        release {
            // Sign with release keystore (from env vars or gradle.properties)
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
