package com.example.financial_planner

import android.os.Build
import android.window.OnBackInvokedCallback
import android.window.OnBackInvokedDispatcher
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.financial_planner/back_handler"
    private var methodChannel: MethodChannel? = null
    
    private val onBackInvokedCallback = object : OnBackInvokedCallback {
        override fun onBackInvoked() {
            // Send back press event to Flutter
            methodChannel?.invokeMethod("onBackPressed", null)
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "exitApp") {
                finishAffinity()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
    
    override fun onStart() {
        super.onStart()
        // Register back callback for Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                onBackInvokedCallback
            )
        }
    }
    
    override fun onStop() {
        super.onStop()
        // Unregister back callback
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.unregisterOnBackInvokedCallback(onBackInvokedCallback)
        }
    }
    
    // Fallback for older Android versions (< API 33)
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        methodChannel?.invokeMethod("onBackPressed", null)
    }
}
