package com.example.hdrscreentest;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.res.ColorStateList;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorSpace;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.TextView;
import java.util.Locale;

/** HDR test patterns with a collapsible, HyperOS-inspired control sheet. */
public class HdrPatternActivity extends Activity {
    private static final int BLUE = 0xff3482ff, TEXT = 0xff151922, SUB = 0xff747d8e;
    private final Handler timer = new Handler();
    private TestView test;
    private LinearLayout sheet, areaGroup;
    private TextView status, areaValue, levelValue;
    private TextView[] modeButtons;
    private int pattern = 0, area = 10, level = 1000;
    private final String[] labels = {"PQ 亮度阶梯", "HLG 渐变", "PQ 面积探针"};
    private final Runnable update = new Runnable() {
        @Override public void run() { refreshStatus(); timer.postDelayed(this, 1000); }
    };
    private int dp(float value) { return Math.round(getResources().getDisplayMetrics().density * value); }
    private GradientDrawable shape(int color, float radius) {
        GradientDrawable d = new GradientDrawable(); d.setColor(color); d.setCornerRadius(dp(radius)); return d;
    }
    private TextView text(String value, int size, int color, boolean bold) {
        TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color);
        if (bold) t.setTypeface(Typeface.DEFAULT, Typeface.BOLD); return t;
    }
    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        if (Build.VERSION.SDK_INT < 34) { finish(); return; }
        if (state != null) { pattern = state.getInt("pattern", 0); area = state.getInt("area", 10); level = state.getInt("level", 1000); }
        getWindow().setColorMode(ActivityInfo.COLOR_MODE_HDR);
        if (Build.VERSION.SDK_INT >= 35) getWindow().setDesiredHdrHeadroom(0f);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        FrameLayout root = new FrameLayout(this);
        test = new TestView(); root.addView(test, new FrameLayout.LayoutParams(-1, -1));
        sheet = new LinearLayout(this); sheet.setOrientation(LinearLayout.VERTICAL); sheet.setPadding(dp(20), dp(8), dp(20), dp(20));
        sheet.setBackground(shape(0xf5f2f3f6, 28)); sheet.setElevation(dp(12));
        View handle = new View(this); handle.setBackground(shape(0xffc7cad0, 5));
        FrameLayout handleArea = new FrameLayout(this);
        handleArea.addView(handle, new FrameLayout.LayoutParams(dp(42), dp(4), Gravity.CENTER));
        sheet.addView(handleArea, new LinearLayout.LayoutParams(-1, dp(24)));
        handleArea.setContentDescription("收起测试设置");
        handleArea.setOnClickListener(v -> hideSheet());
        handleArea.setOnTouchListener(new View.OnTouchListener() {
            private float startY;
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getActionMasked() == MotionEvent.ACTION_DOWN) { startY = event.getRawY(); return true; }
                if (event.getActionMasked() == MotionEvent.ACTION_UP) {
                    if (event.getRawY() - startY > dp(20)) hideSheet();
                    else v.performClick();
                    return true;
                }
                return true;
            }
        });
        LinearLayout header = new LinearLayout(this); header.setGravity(Gravity.CENTER_VERTICAL);
        TextView title = text("HDR 测试", 21, TEXT, true); header.addView(title, new LinearLayout.LayoutParams(0, -2, 1));
        TextView close = text("收起", 14, BLUE, true); close.setPadding(dp(12), dp(10), dp(12), dp(10)); close.setOnClickListener(v -> hideSheet()); header.addView(close); sheet.addView(header);
        status = text("", 12, SUB, false); status.setPadding(0, dp(4), 0, dp(10)); sheet.addView(status);
        ScrollView scroll = new ScrollView(this); scroll.setFillViewport(false); scroll.setVerticalScrollBarEnabled(false);
        LinearLayout body = new LinearLayout(this); body.setOrientation(LinearLayout.VERTICAL); scroll.addView(body);
        body.addView(text("测试图案", 14, SUB, true));
        LinearLayout modes = new LinearLayout(this); modes.setPadding(0, dp(8), 0, dp(12)); modeButtons = new TextView[labels.length];
        for (int i = 0; i < labels.length; i++) { final int index = i; TextView b = text(labels[i], 12, TEXT, true); b.setGravity(Gravity.CENTER); b.setPadding(dp(4),dp(10),dp(4),dp(10));
            LinearLayout.LayoutParams bp = new LinearLayout.LayoutParams(0, -2, 1); if (i > 0) bp.leftMargin=dp(6); modes.addView(b,bp); b.setOnClickListener(v -> selectPattern(index)); modeButtons[i]=b; }
        body.addView(modes);
        areaGroup = new LinearLayout(this); areaGroup.setOrientation(LinearLayout.VERTICAL);
        areaValue = addSlider(areaGroup, "白色色块面积", 99, area - 1, progress -> { area = progress + 1; selectPattern(2); });
        levelValue = addSlider(areaGroup, "亮度信号", 39, Math.max(0, level / 100 - 1), progress -> { level = (progress + 1) * 100; selectPattern(2); });
        TextView note = text("面积和亮度用于 PQ 面积探针；亮度为信号值，实际亮度需测量。", 12, SUB, false); note.setPadding(0, dp(6), 0, dp(12)); areaGroup.addView(note); body.addView(areaGroup);
        TextView exit = text("退出测试", 15, TEXT, true); exit.setGravity(Gravity.CENTER); exit.setPadding(0, dp(13), 0, dp(13)); exit.setBackground(shape(Color.WHITE, 18)); exit.setOnClickListener(v -> finish()); body.addView(exit);
        sheet.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1));
        FrameLayout.LayoutParams sp = new FrameLayout.LayoutParams(-1, Math.min(dp(470), (int)(getResources().getDisplayMetrics().heightPixels * .72f)), Gravity.BOTTOM); root.addView(sheet, sp);
        test.setOnClickListener(v -> sheet.setVisibility(sheet.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE));
        setContentView(root); selectPattern(pattern);
    }
    private interface Progress { void changed(int value); }
    private TextView addSlider(LinearLayout parent, String label, int max, int value, Progress callback) {
        LinearLayout row = new LinearLayout(this); row.setGravity(Gravity.CENTER_VERTICAL);
        TextView name = text(label, 14, TEXT, true); row.addView(name, new LinearLayout.LayoutParams(0,-2,1));
        TextView current = text("", 14, BLUE, true); row.addView(current); parent.addView(row);
        SeekBar slider = new SeekBar(this); slider.setMax(max); slider.setProgress(value); slider.setProgressTintList(ColorStateList.valueOf(BLUE)); slider.setThumbTintList(ColorStateList.valueOf(BLUE));
        slider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            public void onProgressChanged(SeekBar s, int progress, boolean fromUser) { if (fromUser) callback.changed(progress); }
            public void onStartTrackingTouch(SeekBar s) {} public void onStopTrackingTouch(SeekBar s) {}
        }); parent.addView(slider); return current;
    }
    private void selectPattern(int selected) {
        pattern = selected; test.invalidate();
        for (int i=0;i<modeButtons.length;i++) { modeButtons[i].setBackground(shape(i==pattern ? 0xffd6e5ff : Color.WHITE, 18)); modeButtons[i].setTextColor(i==pattern ? 0xff165ac7 : TEXT); }
        areaValue.setText(area + "%"); levelValue.setText(level + " cd/m²"); refreshStatus();
    }
    private void hideSheet() { sheet.setVisibility(View.GONE); }
    private void refreshStatus() {
        if (status == null) return;
        Display d = Build.VERSION.SDK_INT >= 30 ? getDisplay() : getWindowManager().getDefaultDisplay();
        String ratio = "HDR/SDR 比率未上报";
        if (d != null && d.isHdrSdrRatioAvailable()) ratio = String.format(Locale.US, "HDR/SDR %.2f×", d.getHdrSdrRatio());
        status.setText(labels[pattern] + " · " + ratio + "\n收起后轻触画面重新打开设置");
    }
    @Override protected void onSaveInstanceState(Bundle out) { out.putInt("pattern",pattern); out.putInt("area",area); out.putInt("level",level); super.onSaveInstanceState(out); }
    @Override protected void onResume() { super.onResume(); timer.post(update); }
    @Override protected void onPause() { timer.removeCallbacks(update); super.onPause(); }
    private static float pq(double nits) {
        double l = Math.pow(Math.max(0, Math.min(10000, nits)) / 10000.0, 2610.0 / 16384.0);
        return (float)Math.pow((3424.0 / 4096.0 + (2413.0 / 128.0) * l) / (1.0 + (2392.0 / 128.0) * l), 2523.0 / 32.0);
    }
    private class TestView extends View {
        final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        final double[] steps = {0.01, 0.1, 1, 10, 50, 100, 203, 400, 600, 1000, 2000, 4000};
        TestView() { super(HdrPatternActivity.this); }
        private void setPq(double nits) { float c = pq(nits); paint.setColor(Color.pack(c,c,c,1f,ColorSpace.get(ColorSpace.Named.BT2020_PQ))); }
        @Override protected void onDraw(Canvas canvas) {
            super.onDraw(canvas); float w=getWidth(), h=getHeight(); canvas.drawColor(Color.BLACK);
            if (pattern == 0) {
                float height = h / steps.length;
                for (int i=0; i<steps.length; i++) { setPq(steps[i]); canvas.drawRect(0,i*height,w,(i+1)*height+1,paint); }
                paint.setColor(Color.WHITE); paint.setTextSize(Math.max(20, dp(12))); paint.setShadowLayer(3,1,1,Color.BLACK);
                for (int i=0; i<steps.length; i++) canvas.drawText(steps[i] + " cd/m² 信号", dp(8), (i+0.65f)*height,paint);
                paint.clearShadowLayer();
            } else if (pattern == 1) {
                for(int i=0;i<256;i++) { float c=i/255f; paint.setColor(Color.pack(c,c,c,1f,ColorSpace.get(ColorSpace.Named.BT2020_HLG))); canvas.drawRect(i*w/256f,0,(i+1)*w/256f+1,h,paint); }
            } else {
                float[] rect=HdrPatchGeometry.bounds(w,h,area); setPq(level); canvas.drawRect(rect[0],rect[1],rect[2],rect[3],paint);
            }
        }
    }
}

