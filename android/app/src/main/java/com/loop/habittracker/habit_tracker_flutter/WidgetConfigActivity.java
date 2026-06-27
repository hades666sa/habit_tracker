package com.loop.habittracker.habit_tracker_flutter;

import android.app.Activity;
import android.appwidget.AppWidgetManager;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class WidgetConfigActivity extends FlutterActivity {
    private static final String CHANNEL = "com.loop.habit_tracker/widget_config";
    private int pendingAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
    private boolean pendingWidgetConfig = false;

    @Override
    public TransparencyMode getTransparencyMode() {
        return TransparencyMode.transparent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Intercept intent before Flutter engine starts
        checkWidgetIntent(getIntent());
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannel methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("finishConfig")) {
                int widgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
                if (call.argument("appWidgetId") != null) {
                    widgetId = call.argument("appWidgetId");
                }
                
                Intent resultValue = new Intent();
                if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                    resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId);
                }
                setResult(Activity.RESULT_OK, resultValue);
                finish();
                result.success(null);
            } else if (call.method.equals("checkPendingWidgetConfig")) {
                if (pendingWidgetConfig) {
                    Map<String, Object> args = new HashMap<>();
                    if (pendingAppWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                        args.put("appWidgetId", pendingAppWidgetId);
                    }
                    result.success(args);
                } else {
                    result.success(null);
                }
                pendingWidgetConfig = false;
                pendingAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
            } else {
                result.notImplemented();
            }
        });
    }

    private void checkWidgetIntent(Intent intent) {
        if (intent == null) return;

        if (AppWidgetManager.ACTION_APPWIDGET_CONFIGURE.equals(intent.getAction())) {
            pendingWidgetConfig = true;
            Bundle extras = intent.getExtras();
            if (extras != null) {
                pendingAppWidgetId = extras.getInt(
                        AppWidgetManager.EXTRA_APPWIDGET_ID, 
                        AppWidgetManager.INVALID_APPWIDGET_ID);
            }
            setResult(Activity.RESULT_CANCELED);
            return;
        }

        Uri data = intent.getData();
        if (data != null && "habitloop".equals(data.getScheme()) && "widget_config".equals(data.getHost())) {
            pendingWidgetConfig = true;
            String idStr = data.getQueryParameter("appWidgetId");
            if (idStr != null) {
                try {
                    pendingAppWidgetId = Integer.parseInt(idStr);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
        }
    }
}
