package com.example.hdrscreentest;

import android.app.Activity;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

public class VideoActivity extends Activity implements SurfaceHolder.Callback {
    private MediaPlayer player;
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        FrameLayout root = new FrameLayout(this); root.setBackgroundColor(0xff000000);
        SurfaceView surface = new SurfaceView(this); surface.getHolder().addCallback(this);
        root.addView(surface, new FrameLayout.LayoutParams(-1,-1));
        TextView close = new TextView(this); close.setText("✕  Close"); close.setTextSize(16); close.setTextColor(-1); close.setBackgroundColor(0x99000000); close.setPadding(30,20,30,20); close.setOnClickListener(v -> finish());
        FrameLayout.LayoutParams p = new FrameLayout.LayoutParams(-2,-2,Gravity.TOP | Gravity.END); p.setMargins(20,40,20,20); root.addView(close,p);
        setContentView(root);
    }
    @Override public void surfaceCreated(SurfaceHolder holder) {
        try {
            player = new MediaPlayer(); player.setDataSource(this, getIntent().getData()); player.setDisplay(holder);
            player.setLooping(true); player.setOnPreparedListener(MediaPlayer::start);
            player.setOnErrorListener((mp, what, extra) -> { Toast.makeText(this,"This video could not be played on this device",Toast.LENGTH_LONG).show(); finish(); return true; });
            player.prepareAsync();
        } catch (Exception e) { Toast.makeText(this,"Unable to open video: " + e.getMessage(),Toast.LENGTH_LONG).show(); finish(); }
    }
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int width,int height) {}
    @Override public void surfaceDestroyed(SurfaceHolder holder) { release(); }
    @Override protected void onPause() { super.onPause(); if (player != null && player.isPlaying()) player.pause(); }
    @Override protected void onResume() { super.onResume(); if (player != null) { try { player.start(); } catch (IllegalStateException ignored) {} } }
    private void release() { if (player != null) { player.release(); player = null; } }
    @Override protected void onDestroy() { release(); super.onDestroy(); }
}
