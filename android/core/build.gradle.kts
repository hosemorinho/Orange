import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.follow.clash.core"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }


    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}


dependencies {
    implementation(libs.annotation.jvm)
}

val copyNativeLibs by tasks.register<Copy>("copyNativeLibs") {
    doFirst {
        delete("src/main/jniLibs")
        delete("src/main/cpp/includes")
    }
    from("../../libclash/android")
    into("src/main/jniLibs")

    doLast {
        // Move .h files from each ABI directory to cpp/includes/{ABI}/
        val jniLibsDir = file("src/main/jniLibs")
        val targetDir = file("src/main/cpp/includes")
        jniLibsDir.listFiles()?.filter { it.isDirectory }?.forEach { abiDir ->
            abiDir.listFiles()?.filter { it.extension == "h" }?.forEach { headerFile ->
                val destDir = File(targetDir, abiDir.name)
                destDir.mkdirs()
                headerFile.copyTo(File(destDir, headerFile.name), overwrite = true)
                headerFile.delete()
            }
        }
        // Copy bride.h from core/ to each ABI include directory
        val brideHeader = file("../../core/bride.h")
        if (brideHeader.exists()) {
            jniLibsDir.listFiles()?.filter { it.isDirectory }?.forEach { abiDir ->
                val destDir = File(targetDir, abiDir.name)
                destDir.mkdirs()
                brideHeader.copyTo(File(destDir, brideHeader.name), overwrite = true)
            }
        }
        // Also handle legacy includes/ subdirectory layout
        val includesDir = file("src/main/jniLibs/includes")
        if (includesDir.exists()) {
            copy {
                from(includesDir)
                into(targetDir)
            }
            delete(includesDir)
        }
    }
}

afterEvaluate {
    tasks.named("preBuild") {
        dependsOn(copyNativeLibs)
    }
}