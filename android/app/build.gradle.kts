import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Secrets de signature, lus dans android/key.properties — un fichier JAMAIS versionné.
//
// Android identifie une application par sa signature, pas par son nom : une fois l'APK
// distribué, changer de clé oblige CHAQUE utilisateur à désinstaller puis réinstaller,
// en perdant sa session. La clé de production doit donc être posée avant la première
// livraison, et conservée ensuite — sauvegardez le .jks ET le mot de passe hors du poste.
//
// Quand le fichier est absent (autre poste, intégration continue), on retombe sur la clé
// de debug : le projet reste compilable par tous, seul l'APK de livraison exige le secret.
val fichierSecrets = rootProject.file("key.properties")
val secretsSignature = Properties().apply {
    if (fichierSecrets.exists()) fichierSecrets.inputStream().use { load(it) }
}

// Firebase (FCM) — activé le jour où le client dépose son google-services.json dans
// android/app/. Tant que le fichier est absent, le plugin n'est PAS appliqué : le build
// reste vert et l'application démarre normalement, sans push (voir PushService).
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

android {
    namespace = "com.mediasoft.olympia_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mediasoft.olympia_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (fichierSecrets.exists()) {
            create("release") {
                storeFile = file(secretsSignature.getProperty("storeFile"))
                storePassword = secretsSignature.getProperty("storePassword")
                keyAlias = secretsSignature.getProperty("keyAlias")
                keyPassword = secretsSignature.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (fichierSecrets.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Repli assumé : permet à `flutter run --release` de fonctionner sur un
                // poste sans le secret. Un APK ainsi signé ne doit JAMAIS être livré.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
