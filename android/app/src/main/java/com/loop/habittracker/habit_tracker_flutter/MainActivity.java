package com.loop.habittracker.habit_tracker_flutter;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.loop.habit_tracker/widget_config";
    private int pendingAppWidgetId = -1;
    private boolean pendingWidgetConfig = false;
    private MethodChannel methodChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        checkWidgetIntent(getIntent());
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        checkWidgetIntent(intent);
        if (pendingWidgetConfig && methodChannel != null) {
            Map<String, Object> args = new HashMap<>();
            if (pendingAppWidgetId != -1) {
                args.put("appWidgetId", pendingAppWidgetId);
            }
            methodChannel.invokeMethod("openWidgetConfig", args);
            pendingWidgetConfig = false;
            pendingAppWidgetId = -1;
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("finishConfig")) {
                // Ignore setResult in MainActivity since it's not the initial configuration flow
                result.success(null);
            } else if (call.method.equals("checkPendingWidgetConfig")) {
                if (pendingWidgetConfig) {
                    Map<String, Object> args = new HashMap<>();
                    if (pendingAppWidgetId != -1) {
                        args.put("appWidgetId", pendingAppWidgetId);
                    }
                    result.success(args);
                } else {
                    result.success(null);
                }
                pendingWidgetConfig = false;
                pendingAppWidgetId = -1;
            } else {
                result.notImplemented();
            }
        });
    }

    private void checkWidgetIntent(Intent intent) {
        if (intent == null) return;
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
