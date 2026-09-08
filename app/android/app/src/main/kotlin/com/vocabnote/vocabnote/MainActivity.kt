package com.vocabnote.vocabnote

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Material You accent, read straight from the framework resources that
        // Android 12 (API 31) added. No dependency needed for one integer.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_DYNAMIC_COLOR,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAccentColor" -> result.success(accentColor())
                else -> result.notImplemented()
            }
        }
    }

    /** The device accent as an ARGB int, or null below Android 12. */
    private fun accentColor(): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return null
        return try {
            getColor(android.R.color.system_accent1_500)
        } catch (e: android.content.res.Resources.NotFoundException) {
            // Some OEM builds ship API 31 without the dynamic palette.
            null
        }
    }

    private companion object {
        const val CHANNEL_DYNAMIC_COLOR = "com.vocabnote/dynamic_color"
    }
}
