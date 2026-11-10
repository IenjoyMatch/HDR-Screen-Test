package com.example.hdrscreentest;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorSpace;
import android.graphics.Paint;
import android.os.Build;
import android.os.Bundle;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Visual HDR test signals. Display pipeline and luminance require device verification. */
public class HdrPatternActivity extends Activity {
    private TestView test;
    private TextView status;
    private LinearLayout controls;
    private int pattern = 0, areaIndex = 2, levelIndex = 2;
    private final int[] areas = {1, 5, 10, 25, 50, 100};
    private final int[] levels = {203, 400, 1000, 2000};
    private final String[] labels = {"PQ luminance steps", "HLG gradient", "PQ area patch"};
    private final android.os.Handler timer = new android.os.Handler();
    private final Runnable update = new Runnable() {
        @Override public void run() { updateStatus(); timer.postDelayed(this, 1000); }
    };
    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        if (Build.VERSION.SDK_INT < 34) { finish(); return; }
        getWindow().setColorMode(ActivityInfo.COLOR_MODE_HDR);
        if (Build.VERSION.SDK_INT >= 35) getWindow().setDesiredHdrHeadroom(0f);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        FrameLayout root = new FrameLayout(this);
        test = new TestView(); root.addView(test, new FrameLayout.LayoutParams(-1,-1));
        controls = new LinearLayout(this); controls.setOrientation(LinearLayout.VERTICAL); controls.setPadding(16,16,16,24); controls.setBackgroundColor(0xd9000000);
        status = new TextView(this); status.setTextColor(Color.WHITE); status.setTextSize(13); controls.addView(status);
        LinearLayout buttons = new LinearLayout(this);
        addButton(buttons,"Next", () -> { pattern = (pattern + 1) % labels.length; test.invalidate(); updateStatus(); });
        addButton(buttons,"Area", () -> { areaIndex = (areaIndex + 1) % areas.length; test.invalidate(); updateStatus(); });
        addButton(buttons,"Level", () -> { levelIndex = (levelIndex + 1) % levels.length; test.invalidate(); updateStatus(); });
        addButton(buttons,"Close", this::finish); controls.addView(buttons);
        FrameLayout.LayoutParams p = new FrameLayout.LayoutParams(-1,-2,Gravity.BOTTOM); root.addView(controls,p);
        test.setOnClickListener(v -> controls.setVisibility(controls.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE));
        setContentView(root); updateStatus();
    }
    private void addButton(LinearLayout row, String label, Runnable action) {
        Button b = new Button(this); b.setText(label); b.setAllCaps(false); b.setOnClickListener(v -> action.run());
        row.addView(b, new LinearLayout.LayoutParams(0,-2,1));
    }
    private void updateStatus() {
        Display d = Build.VERSION.SDK_INT >= 30 ? getDisplay() : getWindowManager().getDefaultDisplay();
        String ratio = "HDR/SDR ratio unavailable";
        if (d != null && Build.VERSION.SDK_INT >= 34 && d.isHdrSdrRatioAvailable()) ratio = String.format(java.util.Locale.US, "HDR/SDR %.2f×", d.getHdrSdrRatio());
        String details = pattern == 2 ? " · " + areas[areaIndex] + "% · " + levels[levelIndex] + " cd/m² signal" : "";
        status.setText(labels[pattern] + details + "\n" + ratio + " · Tap pattern to hide/show controls\nSignal values are not measured brightness.");
    }
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
                paint.setColor(Color.WHITE); paint.setTextSize(Math.max(20, getResources().getDisplayMetrics().density*12));
                for (int i=0; i<steps.length; i++) { paint.setShadowLayer(3,1,1,Color.BLACK); canvas.drawText(steps[i] + " cd/m² signal", 12, (i+0.65f)*height,paint); }
                paint.clearShadowLayer();
            } else if (pattern == 1) {
                for(int i=0;i<256;i++) { float c=i/255f; paint.setColor(Color.pack(c,c,c,1f,ColorSpace.get(ColorSpace.Named.BT2020_HLG))); canvas.drawRect(i*w/256f,0,(i+1)*w/256f+1,h,paint); }
            } else {
                double fraction=areas[areaIndex]/100.0; float pw=(float)(w*Math.sqrt(fraction)); float ph=(float)(h*Math.sqrt(fraction));
                setPq(levels[levelIndex]); canvas.drawRect((w-pw)/2,(h-ph)/2,(w+pw)/2,(h+ph)/2,paint);
            }
        }
    }
}
