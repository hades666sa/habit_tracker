package com.loop.habittracker.habit_tracker_flutter;

public class HabitWidgetCompactProvider extends BaseHabitWidgetProvider {
    @Override
    protected int getLayoutId() { return R.layout.habit_widget_compact; }

    @Override
    protected String getTag() { return "HabitWidgetCompactProvider"; }

    @Override
    protected String getImagePathKey() { return "heatmap_image_compact"; }

    @Override
    protected boolean hasHeatmap() { return false; }
}
