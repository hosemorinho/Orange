import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localPropertiesFile = rootProject.file("local.properties")
val localProperties = Properties().apply {
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

val mStoreFile: File = file("keystore.jks")
val mStorePassword: String? = localProperties.getProperty("storePassword")
val mKeyAlias: String? = localProperties.getProperty("keyAlias")
val mKeyPassword: String? = localProperties.getProperty("keyPassword")
val isRelease = mStoreFile.exists()
        && mStorePassword != null
        && mKeyAlias != null
        && mKeyPassword != null

// 从 --dart-define 读取包名（Flutter 以 base64 编码传入）
val dartDefines = (project.findProperty("dart-defines") as? String)
    ?.split(",")
    ?.mapNotNull { encoded ->
        try {
            val decoded = String(java.util.Base64.getDecoder().decode(encoded))
            val parts = decoded.split("=", limit = 2)
            if (parts.size == 2) parts[0] to parts[1] else null
        } catch (_: Exception) { null }
    }?.toMap() ?: emptyMap()

val appPackageName = dartDefines["APP_PACKAGE_NAME"]?.takeIf { it.isNotEmpty() } ?: "com.follow.clash"

android {
    namespace = appPackageName
    compileSdk = 35
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = appPackageName
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (isRelease) {
            create("release") {
                storeFile = mStoreFile
                storePassword = mStorePassword
                keyAlias = mKeyAlias
                keyPassword = mKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            applicationIdSuffix = ".debug"
        }

        release {
            isMinifyEnabled = true
            isDebuggable = false

            // 强制使用 debug 签名，不使用 release 签名
            signingConfig = signingConfigs.getByName("debug")

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(project(":core"))
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.android.tools.smali:smali-dexlib2:3.0.9") {
        exclude(group = "com.google.guava", module = "guava")
    }
}