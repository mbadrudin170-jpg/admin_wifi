package com.example.adminwifi

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wifi_rssi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getRssi") {
                try {
                    val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                    val info = wifiManager.connectionInfo
                    result.success(info.rssi)
                } catch (e: Exception) {
                    result.error("RSSI_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
