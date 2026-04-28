package com.improvs.waily

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Install the SplashScreen compat surface BEFORE super.onCreate
        // so the system-managed splash is held until Flutter draws its
        // first frame. Combined with FlutterNativeSplash.preserve() in
        // main.dart, this removes the white flash between the OS splash
        // and the Flutter view on every Android version.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
