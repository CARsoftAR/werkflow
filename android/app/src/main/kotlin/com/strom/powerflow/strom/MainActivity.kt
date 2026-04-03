package com.strom.powerflow.strom

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.RingtoneManager
import android.media.Ringtone
import android.net.Uri
import java.io.File
import java.io.FileOutputStream
import android.os.Bundle
import android.view.WindowManager
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.werkflow.alarms/sounds"
    private var currentRingtone: Ringtone? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configuración para mostrar la app sobre el lockscreen y despertar la pantalla
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemAlarms" -> {
                    val alarms = getAlarms()
                    result.success(alarms)
                }
                "playPreview" -> {
                    val uriString = call.argument<String>("uri")
                    playPreview(uriString)
                    result.success(null)
                }
                "stopPreview" -> {
                    stopPreview()
                    result.success(null)
                }
                "prepareAlarmPath" -> {
                    val uriString = call.argument<String>("uri")
                    val path = prepareAlarmPath(uriString)
                    result.success(path)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAlarms(): List<Map<String, String>> {
        val manager = RingtoneManager(this)
        manager.setType(RingtoneManager.TYPE_ALARM)
        val cursor = manager.cursor
        val list = mutableListOf<Map<String, String>>()
        try {
            while (cursor.moveToNext()) {
                val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                val uri = manager.getRingtoneUri(cursor.position).toString()
                list.add(mapOf("nombre" to title, "path" to uri))
            }
        } catch (e: Exception) {
            // Log error or ignore
        }
        return list
    }

    private fun playPreview(uriString: String?) {
        stopPreview()
        if (uriString == null || uriString == "default") return
        try {
            val uri = Uri.parse(uriString)
            currentRingtone = RingtoneManager.getRingtone(applicationContext, uri)
            currentRingtone?.play()
        } catch (e: Exception) {
            // Error playing
        }
    }

    private fun stopPreview() {
        currentRingtone?.stop()
        currentRingtone = null
    }

    private fun prepareAlarmPath(uriString: String?): String? {
        if (uriString == null || uriString == "default" || uriString.startsWith("assets/")) {
            return uriString
        }
        try {
            val uri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(uri)
            val tempFile = File(cacheDir, "temp_alarm_sound.mp3")
            val outputStream = FileOutputStream(tempFile)
            inputStream?.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }
            return tempFile.absolutePath
        } catch (e: Exception) {
            return null
        }
    }

    override fun onDestroy() {
        stopPreview()
        super.onDestroy()
    }
}
