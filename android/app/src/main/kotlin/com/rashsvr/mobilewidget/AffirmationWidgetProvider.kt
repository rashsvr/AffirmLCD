package com.rashsvr.mobilewidget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.random.Random
import org.json.JSONArray

class AffirmationWidgetProvider : HomeWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (
            intent.action == Intent.ACTION_SCREEN_ON ||
            intent.action == Intent.ACTION_USER_PRESENT
        ) {
            refreshForWake(context)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val saved = widgetData.getString(AFFIRMATION_KEY, null)?.trim().orEmpty()
        val affirmation = saved.ifEmpty { chooseNextAffirmation(widgetData) }
        widgetData.edit().putString(AFFIRMATION_KEY, affirmation).apply()
        updateAll(context, appWidgetManager, appWidgetIds, widgetData, affirmation)
    }

    private fun updateAll(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
        affirmation: String,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.affirmation_widget).apply {
                setTextViewText(R.id.widget_label, currentTime())
                setTextViewText(R.id.affirmation_text, "$affirmation \u2600")
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("mobilewidget://affirmation"),
                    ),
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun chooseNextAffirmation(widgetData: SharedPreferences): String {
        val list = parseAffirmationList(widgetData.getString(AFFIRMATION_LIST_KEY, null))
        if (list.isEmpty()) return DEFAULT_AFFIRMATION

        val current = widgetData.getString(AFFIRMATION_KEY, null)
        if (list.size == 1) return list.first()

        var next = list[Random.nextInt(list.size)]
        var guard = 0
        while (next == current && guard < 8) {
            next = list[Random.nextInt(list.size)]
            guard++
        }
        return next
    }

    private fun parseAffirmationList(raw: String?): List<String> {
        if (raw.isNullOrBlank()) return emptyList()
        return try {
            val json = JSONArray(raw)
            buildList {
                for (index in 0 until json.length()) {
                    val text = json.optString(index, "").trim()
                    if (text.isNotEmpty()) add(text)
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun currentTime(): String {
        return SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
    }

    companion object {
        private const val WIDGET_PREFS = "HomeWidgetPreferences"
        private const val AFFIRMATION_KEY = "affirmation_text"
        private const val AFFIRMATION_LIST_KEY = "affirmation_list"
        private const val DEFAULT_AFFIRMATION = "\u2728 Add your first affirmation"

        fun refreshForWake(context: Context) {
            val provider = AffirmationWidgetProvider()
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, AffirmationWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return

            val widgetData = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
            val next = provider.chooseNextAffirmation(widgetData)
            widgetData.edit().putString(AFFIRMATION_KEY, next).apply()
            provider.updateAll(context, manager, ids, widgetData, next)
        }
    }
}
