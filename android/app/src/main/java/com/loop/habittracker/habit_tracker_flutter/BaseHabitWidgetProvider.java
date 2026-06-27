package com.loop.habittracker.habit_tracker_flutter;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.view.View;
import android.widget.RemoteViews;

import java.io.File;
import es.antonborri.home_widget.HomeWidgetPlugin;

public abstract class BaseHabitWidgetProvider extends AppWidgetProvider {

    protected abstract int getLayoutId();
    protected abstract String getTag();
    protected abstract String getImagePathKey();
    protected abstract boolean hasHeatmap();

    @Override
    public void onReceive(Context context, Intent intent) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            android.os.UserManager userManager = (android.os.UserManager) context.getSystemService(Context.USER_SERVICE);
            if (userManager != null && !userManager.isUserUnlocked()) {
                // Ignore broadcasts in Direct Boot mode to prevent AppWidgetManager crash
                return;
            }
        }
        super.onReceive(context, intent);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        try {
            SharedPreferences prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE);
            String habitIdStr = prefs.getString("widget_habit_" + appWidgetId, null);
            String prefix = habitIdStr != null ? "habit_" + habitIdStr + "_" : "habit_";
            String heatmapSuffix = habitIdStr != null ? "_" + habitIdStr : "";

            String name = prefs.getString(prefix + "name", "Select Habit");
            String streak = prefs.getString(prefix + "streak", "0 Day Streak");
            String icon = prefs.getString(prefix + "icon", "💧");
            String colorStr = prefs.getString(prefix + "color", "#2196F3");
            String desc = prefs.getString(prefix + "description", "");
            String imagePath = prefs.getString(getImagePathKey() + heatmapSuffix, null);
            String appTheme = prefs.getString("app_theme", "system");

            // Legacy dots
            boolean[] recentCompletions = new boolean[7];
            String[] dayLabels = new String[7];
            int[] counts = new int[7];
            for (int i = 0; i < 7; i++) {
                recentCompletions[i] = prefs.getBoolean(prefix + "completed_" + i, false);
                dayLabels[i] = prefs.getString(prefix + "day_" + i, "");
                counts[i] = prefs.getInt(prefix + "count_" + i, 0);
            }

            RemoteViews views = new RemoteViews(context.getPackageName(), getLayoutId());
            
            boolean isDark = false;
            if ("dark".equals(appTheme)) {
                isDark = true;
            } else if ("light".equals(appTheme)) {
                isDark = false;
            } else {
                int currentNightMode = context.getResources().getConfiguration().uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK;
                isDark = (currentNightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES);
            }
            
            views.setInt(R.id.widget_root, "setBackgroundResource", isDark ? R.drawable.widget_dark_bg : R.drawable.widget_bg);
            views.setTextColor(R.id.habit_name, isDark ? Color.WHITE : Color.BLACK);
            views.setInt(R.id.habit_icon, "setBackgroundResource", isDark ? R.drawable.widget_icon_bg_dark : R.drawable.widget_icon_bg);

            views.setTextViewText(R.id.habit_name, name);
            views.setTextViewText(R.id.habit_icon, icon);

            // Handle Description
            int descId = context.getResources().getIdentifier("habit_description", "id", context.getPackageName());
            if (descId != 0) {
                if (desc == null || desc.isEmpty()) {
                    views.setViewVisibility(descId, View.GONE);
                } else {
                    views.setTextViewText(descId, desc);
                    views.setViewVisibility(descId, View.VISIBLE);
                }
            }

            int color = Color.parseColor(colorStr);

            // Handle Streak
            if (getLayoutId() == R.layout.habit_widget_compact) {
                views.setViewVisibility(R.id.habit_streak, View.GONE);
            } else {
                views.setTextColor(R.id.habit_streak, isDark ? Color.parseColor("#AAAAAA") : Color.parseColor("#666666"));
                views.setTextViewText(R.id.habit_streak, streak);
                views.setViewVisibility(R.id.habit_streak, View.VISIBLE);
            }

            views.setTextColor(R.id.habit_icon, color);
            
            // To keep it simple, we use color for dots if legacy_dots is visible
            int activeColor = color;
            int inactiveColor = isDark ? Color.parseColor("#3C3A4D") : Color.parseColor("#E0E0E0");

            for (int i = 0; i < 7; i++) {
                int viewIdBg = context.getResources().getIdentifier("circle_bg_" + i, "id", context.getPackageName());
                int viewIdText = context.getResources().getIdentifier("dot_" + i, "id", context.getPackageName());
                int viewIdDay = context.getResources().getIdentifier("day_" + i, "id", context.getPackageName());

                if (viewIdDay != 0) {
                    views.setTextViewText(viewIdDay, dayLabels[i]);
                }
                
                if (viewIdBg != 0 && viewIdText != 0) {
                    // No tick marks — just colored boxes for a clean heatmap look
                    views.setTextViewText(viewIdText, "");
                    
                    if (recentCompletions[i]) {
                        views.setImageViewResource(viewIdBg, R.drawable.widget_circle_filled);
                        views.setInt(viewIdBg, "setColorFilter", activeColor);
                    } else if (counts[i] > 0) {
                        views.setImageViewResource(viewIdBg, R.drawable.widget_circle_filled);
                        int r = android.graphics.Color.red(activeColor);
                        int g = android.graphics.Color.green(activeColor);
                        int b = android.graphics.Color.blue(activeColor);
                        views.setInt(viewIdBg, "setColorFilter", android.graphics.Color.argb(128, r, g, b));
                    } else if (i == 0) {
                        // Today and not completed: Outline
                        views.setImageViewResource(viewIdBg, R.drawable.widget_circle_outline);
                        views.setInt(viewIdBg, "setColorFilter", activeColor);
                    } else {
                        // Past and not completed: Dark filled
                        views.setImageViewResource(viewIdBg, R.drawable.widget_circle_filled);
                        views.setInt(viewIdBg, "setColorFilter", inactiveColor);
                    }
                } else {
                    // Fallback for old layouts that still use plain text dots (if they haven't been updated)
                    int fallbackId = context.getResources().getIdentifier("dot_" + i, "id", context.getPackageName());
                    if (fallbackId != 0) {
                        views.setTextColor(fallbackId, recentCompletions[i] ? activeColor : inactiveColor);
                    }
                }
            }

            if (hasHeatmap()) {
                if (imagePath != null) {
                    File imgFile = new File(imagePath);
                    if (imgFile.exists()) {
                        Bitmap myBitmap = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
                        views.setImageViewBitmap(R.id.heatmap_image, myBitmap);
                        views.setViewVisibility(R.id.heatmap_image, View.VISIBLE);
                        views.setViewVisibility(R.id.legacy_dots, View.GONE);
                    } else {
                        views.setViewVisibility(R.id.heatmap_image, View.GONE);
                        views.setViewVisibility(R.id.legacy_dots, View.VISIBLE);
                    }
                } else {
                    views.setViewVisibility(R.id.heatmap_image, View.GONE);
                    views.setViewVisibility(R.id.legacy_dots, View.VISIBLE);
                }
            } else {
                views.setViewVisibility(R.id.legacy_dots, View.VISIBLE);
            }

            // Setting click intent to open widget config
            Intent intent = new Intent(context, MainActivity.class);
            intent.setAction(Intent.ACTION_VIEW);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.setData(Uri.parse("habitloop://widget_config?appWidgetId=" + appWidgetId));
            
            int flags = PendingIntent.FLAG_UPDATE_CURRENT;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                flags |= PendingIntent.FLAG_IMMUTABLE;
            }
            
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, flags);
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent);

            appWidgetManager.updateAppWidget(appWidgetId, views);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
