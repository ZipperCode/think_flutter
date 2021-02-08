package com.zipper.think_flutter

import android.os.Parcel
import android.os.Parcelable
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodChannelPlugin(private val messenger: BinaryMessenger, private val name: String)
    : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        const val TAG = "MethodChannel2"
        const val CHANNEL_KEY = ""
    }

    private lateinit var mMethodChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel = MethodChannel(messenger, name)
        mMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "callNative" -> {
                Log.d(TAG, "callNative")
            }
            else -> {
                Log.d(TAG, "other call")
            }
        }
    }

    fun callMethod(methodName: String, params: Map<String, Any>, callback: MethodChannel.Result) {
        mMethodChannel.invokeMethod(methodName, params, callback)
    }

}