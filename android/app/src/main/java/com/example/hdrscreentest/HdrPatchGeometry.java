package com.example.hdrscreentest;

/** Computes a centred patch covering the requested percentage of the screen. */
final class HdrPatchGeometry {
    private HdrPatchGeometry() {}
    static float[] bounds(float width, float height, int percent) {
        if (width <= 0 || height <= 0) return new float[]{0, 0, 0, 0};
        double fraction = Math.max(1, Math.min(100, percent)) / 100.0;
        double area = width * (double) height * fraction;
        float patchWidth = (float) Math.min(width, Math.sqrt(area));
        float patchHeight = (float) (area / patchWidth);
        if (patchHeight > height) { patchHeight = height; patchWidth = (float) (area / height); }
        return new float[]{(width - patchWidth) / 2, (height - patchHeight) / 2,
                (width + patchWidth) / 2, (height + patchHeight) / 2};
    }
}

