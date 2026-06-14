package com.rashsvr.affirmlcd

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var screenReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerScreenReceiver()
    }

    override fun onResume() {
        super.onResume()
        AffirmationWidgetProvider.refreshForWake(this)
    }

    override fun onDestroy() {
        screenReceiver?.let { unregisterReceiver(it) }
        screenReceiver = null
        super.onDestroy()
    }

    private fun registerScreenReceiver() {
        if (screenReceiver != null) return

        screenReceiver =
            object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (
                        intent.action == Intent.ACTION_SCREEN_ON ||
                        intent.action == Intent.ACTION_USER_PRESENT
                    ) {
                        AffirmationWidgetProvider.refreshForWake(context)
                    }
                }
            }

        registerReceiver(
            screenReceiver,
            IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_USER_PRESENT)
            },
        )
    }
}
