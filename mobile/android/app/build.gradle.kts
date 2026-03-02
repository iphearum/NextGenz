plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.nextgenz.keyboard"
    compileSdk = 30

    signingConfigs {
        create("release") {
            storeFile = file("../nextgenz-release.jks")
            storePassword = "nextgenz123"
            keyAlias = "nextgenz"
            keyPassword = "nextgenz123"
        }
    }

    defaultConfig {
        applicationId = "com.nextgenz.keyboard"
        minSdk = 21
        targetSdk = 30
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
}
