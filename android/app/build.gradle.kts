import org.jetbrains.kotlin.gradle.dsl.JvmTarget
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

fun envOrProperty(envKey: String, vararg propertyKeys: String): String? {
    val envValue = System.getenv(envKey)?.takeIf { it.isNotBlank() }
    if (envValue != null) {
        return envValue
    }
    for (propertyKey in propertyKeys) {
        val propertyValue = localProperties.getProperty(propertyKey)?.takeIf { it.isNotBlank() }
        if (propertyValue != null) {
            return propertyValue
        }
    }
    return null
}

val mStoreFile: File = file("keystore.jks")
val mStorePassword: String? = envOrProperty(
    "STORE_PASSWORD",
    "storePassword",
    "STORE_PASSWORD",
)
val mKeyAlias: String? = envOrProperty(
    "KEY_ALIAS",
    "keyAlias",
    "KEY_ALIAS",
)
val mKeyPassword: String? = envOrProperty(
    "KEY_PASSWORD",
    "keyPassword",
    "KEY_PASSWORD",
)
val isRelease =
    mStoreFile.exists() && mStorePassword != null && mKeyAlias != null && mKeyPassword != null

// Read app name from local.properties (set by Flutter dart-define)
val appName = localProperties.getProperty("flutter.appName", "Orange")

android {
    namespace = "com.follow.clash"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()



    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.follow.clash"
        minSdk = flutter.minSdkVersion
        targetSdk = libs.versions.targetSdk.get().toInt()
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

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            applicationIdSuffix = ".dev"
        }

        release {
            isMinifyEnabled = true
            isShrinkResources = true
            if (isRelease) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
                applicationIdSuffix = ".dev"
            }

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}


dependencies {
    implementation(project(":service"))
    implementation(project(":common"))
    implementation(libs.core.splashscreen)
    implementation(libs.gson)
    implementation(libs.smali.dexlib2) {
        exclude(group = "com.google.guava", module = "guava")
    }
}
