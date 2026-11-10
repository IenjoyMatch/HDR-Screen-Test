#version 320 es

// Direct Flutter port of compose-miuix SquircleBackground.kt's current
// baked-SDF mask. Static fills and clipped surfaces use this path upstream.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform vec4 u_corner_sizes;
uniform vec4 u_half_ranges_px;
uniform vec4 u_blend_weights;
uniform float u_bitmap_size;
uniform float u_pixel_ratio;
uniform sampler2D u_corner_sdf;

out vec4 frag_color;

void main() {
  vec2 coord = FlutterFragCoord().xy;
  // Flutter's Impeller OpenGL backend exposes an inverted fragment y-axis.
  // The source coordinates are top-down, so normalize that backend here.
#ifdef IMPELLER_TARGET_OPENGLES
  coord.y = u_size.y - coord.y;
#endif
  float dx_l = coord.x;
  float dx_r = u_size.x - coord.x;
  float dy_t = coord.y;
  float dy_b = u_size.y - coord.y;
  bool left = dx_l < dx_r;
  bool top = dy_t < dy_b;
  float dx = left ? dx_l : dx_r;
  float dy = top ? dy_t : dy_b;

  float corner_size = top
      ? (left ? u_corner_sizes.x : u_corner_sizes.y)
      : (left ? u_corner_sizes.w : u_corner_sizes.z);
  float half_range_px = top
      ? (left ? u_half_ranges_px.x : u_half_ranges_px.y)
      : (left ? u_half_ranges_px.w : u_half_ranges_px.z);
  float blend_weight = top
      ? (left ? u_blend_weights.x : u_blend_weights.y)
      : (left ? u_blend_weights.w : u_blend_weights.z);

  if (corner_size <= 0.0 || dx >= corner_size || dy >= corner_size) {
    frag_color = vec4(1.0);
    return;
  }

  vec2 uv = vec2(dx, dy) / corner_size;
  // The normalized LINEAR sampler is equivalent to the source child shader
  // evaluated at uv * bitmapSize. Keep the size in the compiled contract.
  vec2 normalized_uv = (uv * u_bitmap_size) / u_bitmap_size;
  float sdf_sample = texture(u_corner_sdf, normalized_uv).a;
  float squircle_sdf = (1.0 - 2.0 * sdf_sample) * half_range_px;
  float qx = corner_size - dx;
  float qy = corner_size - dy;
  float circle_sdf = sqrt(qx * qx + qy * qy) - corner_size;
  // Compose draw scopes express this distance in physical pixels. Flutter's
  // Canvas coordinates are logical, so restore the physical unit before the
  // source one-pixel smoothstep or high-density edges become too soft.
  float distance_to_edge =
      mix(squircle_sdf, circle_sdf, blend_weight) * u_pixel_ratio;
  float alpha = smoothstep(0.5, -0.5, distance_to_edge);
  frag_color = vec4(alpha);
}
