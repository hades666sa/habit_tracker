package com.loop.habittracker.habit_tracker_flutter;

public class HabitWidgetSmallProvider extends BaseHabitWidgetProvider {
    @Override
    protected int getLayoutId() { return R.layout.habit_widget_small; }

    @Override
    protected String getTag() { return "HabitWidgetSmallProvider"; }

    @Override
    protected String getImagePathKey() { return "heatmap_image_small"; }

    @Override
    protected boolean hasHeatmap() { return true; }
}
