package com.zipper.think_flutter

import android.content.Context
import android.content.IntentFilter
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec


class MessageChannelPlugin(private val context: Context) : FlutterPlugin, BasicMessageChannel.MessageHandler<Any> {

    companion object {
        const val TAG = "MessageChannel"
        const val CHANNEL_KEY = ""
    }

    private lateinit var mMessageChannel: BasicMessageChannel<Any>;

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMessageChannel = BasicMessageChannel<Any>(binding.binaryMessenger, CHANNEL_KEY,
                StandardMessageCodec.INSTANCE as MessageCodec<Any>)
        mMessageChannel.setMessageHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMessageChannel.setMessageHandler(null)
    }

    /**
     * 收到消息回调 flutter -> 原生
     */
    override fun onMessage(message: Any?, reply: BasicMessageChannel.Reply<Any>) {
        val args: Map<*, *>? = message as Map<*, *>?

    }

    /**
     * 发送消息 原生 -> flutter
     * @param message ["method"]["test"], ["message"]["string"], ["code"][100], ["args"][]
     */
    fun sendMessage(message: Map<Any, Any>?){
        mMessageChannel.send(message) {
            Log.d(TAG, "sendMessage 回调信息为 ：$it")
        }
    }

}