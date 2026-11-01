package com.akhiljr.workpulse

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "workpulse/geofences",
        ).setMethodCallHandler { call, result ->
            if (call.method != "sync") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            TaskGeofences.sync(this, call.arguments as String) { status ->
                result.success(status)
            }
        }
    }
}
