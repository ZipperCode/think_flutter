package com.zipper.think_flutter

import android.content.IntentFilter
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val receiver = FlutterReceiver()
        flutterEngine.plugins.add(receiver)
        registerReceiver(receiver, IntentFilter(FlutterReceiver.INTENT_FILTER_ACTION))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        flutterEngine.plugins.remove(FlutterReceiver::class.java)
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }
}
