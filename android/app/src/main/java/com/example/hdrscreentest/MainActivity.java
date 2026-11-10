package com.example.hdrscreentest;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final int PICK_VIDEO = 901;
    private MethodChannel.Result pending;
    @Override public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "hdr_screen_test/display")
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("info")) { try { result.success(info()); } catch (Exception e) { result.error("DISPLAY", e.toString(), null); } }
                else if (call.method.equals("patterns")) { if (Build.VERSION.SDK_INT >= 34) { startActivity(new Intent(this, HdrPatternActivity.class)); result.success(true); } else result.error("API", "HDR patterns require Android 14 or newer", null); }
                else if (call.method.equals("pickVideo")) {
                    if (pending != null) { result.error("BUSY", "Picker already open", null); return; }
                    try {
                        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE).setType("video/*");
                        pending = result; startActivityForResult(intent, PICK_VIDEO);
                    } catch (Exception e) { pending = null; result.error("PICKER", e.toString(), null); }
                } else result.notImplemented();
            });
    }
    @Override protected void onActivityResult(int request, int code, Intent data) {
        super.onActivityResult(request, code, data);
        if (request != PICK_VIDEO || pending == null) return;
        MethodChannel.Result reply = pending; pending = null;
        if (code == Activity.RESULT_OK && data != null && data.getData() != null) {
            try {
                Intent play = new Intent(this, VideoActivity.class).setData(data.getData()).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(play); reply.success(true);
            } catch (Exception e) { reply.error("PLAYBACK", e.toString(), null); }
        } else reply.success(false);
    }
    private Map<String, Object> info() {
        Display display = ((WindowManager) getSystemService(WINDOW_SERVICE)).getDefaultDisplay();
        DisplayMetrics m = new DisplayMetrics(); display.getRealMetrics(m);
        Map<String, Object> out = new HashMap<>();
        out.put("api", Build.VERSION.SDK_INT); out.put("device", Build.MANUFACTURER + " " + Build.MODEL);
        out.put("android", Build.VERSION.RELEASE + " (API " + Build.VERSION.SDK_INT + ")");
        out.put("widthDp", getResources().getConfiguration().screenWidthDp); out.put("heightDp", getResources().getConfiguration().screenHeightDp);
        out.put("width", m.widthPixels); out.put("height", m.heightPixels);
        out.put("density", m.densityDpi); out.put("xdpi", (double)m.xdpi); out.put("ydpi", (double)m.ydpi);
        if (m.xdpi > 0 && m.ydpi > 0) out.put("diagonal", Math.hypot(m.widthPixels / m.xdpi, m.heightPixels / m.ydpi));
        out.put("refresh", (double)display.getRefreshRate());
        ArrayList<Double> rates = new ArrayList<>();
        for (Display.Mode mode : display.getSupportedModes()) { double rate = mode.getRefreshRate(); if (!rates.contains(rate)) rates.add(rate); }
        out.put("rates", rates);
        if (Build.VERSION.SDK_INT >= 26) out.put("wide", display.isWideColorGamut());
        Display.HdrCapabilities hdr = display.getHdrCapabilities();
        int[] types = Build.VERSION.SDK_INT >= 34 ? display.getMode().getSupportedHdrTypes() : hdr.getSupportedHdrTypes();
        ArrayList<String> names = new ArrayList<>();
        for (int type : types) { switch(type) { case 1: names.add("Dolby Vision"); break; case 2: names.add("HDR10"); break; case 3: names.add("HLG"); break; case 4: names.add("HDR10+"); break; case 6: names.add("HLG+"); break; default: names.add("Type " + type); } }
        out.put("hdrTypes", names);
        putLuminance(out, "max", hdr.getDesiredMaxLuminance());
        putLuminance(out, "average", hdr.getDesiredMaxAverageLuminance());
        putLuminance(out, "min", hdr.getDesiredMinLuminance());
        if (Build.VERSION.SDK_INT >= 34 && display.isHdrSdrRatioAvailable()) out.put("ratio", (double)display.getHdrSdrRatio());
        return out;
    }
    private static void putLuminance(Map<String,Object> map, String key, float value) {
        if (value >= 0 && !Float.isNaN(value) && !Float.isInfinite(value)) map.put(key, (double)value);
    }
}


