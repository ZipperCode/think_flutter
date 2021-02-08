package com.zipper.think_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap

class FlutterReceiver : BroadcastReceiver(), FlutterPlugin {

    companion object {
        const val MESSAGE_RECEIVER = "com.zipper.think_flutter/flutter_receiver"
        const val INTENT_FILTER_ACTION = "com.zipper.think_flutter/flutter_receiver/action";
    }

    private lateinit var mMethodChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel = MethodChannel(binding.binaryMessenger, MESSAGE_RECEIVER)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel.setMethodCallHandler(null);
    }

    override fun onReceive(context: Context, intent: Intent) {
        val code = intent.getIntExtra("code", 0);
        val message = intent.getStringExtra("message") ?: ""
        val map = HashMap<String, Any>()
        map["code"] = code
        map["message"] = message;
        mMethodChannel.invokeMethod("onReceiverMessage", map)
    }
}