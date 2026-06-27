package com.loop.habittracker.habit_tracker_flutter;

public class HabitWidgetMediumProvider extends BaseHabitWidgetProvider {
    @Override
    protected int getLayoutId() { return R.layout.habit_widget_medium; }

    @Override
    protected String getTag() { return "HabitWidgetMediumProvider"; }

    @Override
    protected String getImagePathKey() { return "heatmap_image_medium"; }

    @Override
    protected boolean hasHeatmap() { return true; }
}
