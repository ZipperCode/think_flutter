package com.zipper.think_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class EventChannelPlugin(private val messenger: BinaryMessenger) : BroadcastReceiver(), FlutterPlugin, EventChannel.StreamHandler {

    companion object{
        const val CHANNEL_KEY = ""
        const val TAG = ""


    }

    private lateinit var mEventChannel :EventChannel

    private var events: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mEventChannel = EventChannel(messenger, CHANNEL_KEY)
        mEventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mEventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events;
    }

    override fun onCancel(arguments: Any?) {
        this.events = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        // 收到广播
        // 将消息发送给flutter
        // this.events.success("")
    }
}