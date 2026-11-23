package com.example.adminwifi

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
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
                    val rssi = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                        val network = cm.activeNetwork
                        val caps = network?.let { cm.getNetworkCapabilities(it) }
                        val wifiInfo = if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) {
                            caps.transportInfo as? WifiInfo
                        } else {
                            null
                        }
                        wifiInfo?.rssi ?: -127
                    } else {
                        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                        wifiManager.connectionInfo.rssi
                    }
                    result.success(rssi)
                } catch (e: Exception) {
                    result.error("RSSI_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
