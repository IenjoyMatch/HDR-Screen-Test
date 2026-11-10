#version 320 es

// Direct Flutter runtime-effect port of Shaders.kt's
// buildProgressiveBlurShader(PROGRESSIVE_BLUR_MAX_TAP). Two instances are
// composed by Dart for the horizontal and vertical Gaussian passes.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform vec2 u_step;
uniform float u_max_radius;
uniform vec2 u_axis;
uniform float u_start_fraction;
uniform float u_end_fraction;
uniform float u_curve;
uniform float u_noise;
uniform sampler2D u_texture_input;

out vec4 frag_color;

float progressive_random(vec2 coordinate) {
  return fract(sin(dot(coordinate, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 sample_input(vec2 coordinate) {
  vec2 uv = clamp(coordinate, vec2(0.5), u_size - vec2(0.5)) / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(u_texture_input, uv);
}

void main() {
  vec2 coordinate = FlutterFragCoord().xy;
  float projection_min =
      (u_axis.x > 0.0 ? 0.0 : u_axis.x * u_size.x) +
      (u_axis.y > 0.0 ? 0.0 : u_axis.y * u_size.y);
  float projection_max =
      (u_axis.x > 0.0 ? u_axis.x * u_size.x : 0.0) +
      (u_axis.y > 0.0 ? u_axis.y * u_size.y : 0.0);
  float span = projection_max - projection_min;
  float band_start = projection_min + u_start_fraction * span;
  float band_end = projection_min + u_end_fraction * span;
  if (abs(band_end - band_start) < 0.001) {
    band_end = band_start + 0.001;
  }

  float projection = dot(coordinate, u_axis);
  float raw = clamp(
    (projection - band_start) / (band_end - band_start),
    0.0,
    1.0
  );
  float smooth_raw = raw * raw * (3.0 - 2.0 * raw);
  float intensity = 1.0 - pow(smooth_raw, u_curve);
  float radius = u_max_radius * intensity;
  if (radius <= 0.0) {
    vec4 clear_color = sample_input(coordinate);
    frag_color = clear_color.a > 0.0039
        ? vec4(clear_color.rgb / clear_color.a, 1.0)
        : clear_color;
    return;
  }

  float sigma = radius * 0.5 + 0.5;
  float inverse_two_sigma_squared = -1.0 / (2.0 * sigma * sigma);
  vec2 jitter =
      ((progressive_random(coordinate) - 0.5) * u_noise) * u_step;
  vec4 color = sample_input(coordinate + jitter);
  float total = 1.0;
  for (int pair_index = 0; pair_index < 24; pair_index++) {
    float first_offset = float(2 * pair_index + 1);
    float first_reach = clamp(radius - first_offset + 1.0, 0.0, 1.0);
    if (first_reach <= 0.0) continue;
    float second_offset = first_offset + 1.0;
    float first_weight =
        exp(first_offset * first_offset * inverse_two_sigma_squared) *
        first_reach;
    float second_weight =
        exp(second_offset * second_offset * inverse_two_sigma_squared) *
        clamp(radius - second_offset + 1.0, 0.0, 1.0);
    float combined_weight = first_weight + second_weight;
    vec2 merged_offset =
        ((first_offset * first_weight + second_offset * second_weight) /
        combined_weight) * u_step;
    color +=
        (sample_input(coordinate + merged_offset + jitter) +
        sample_input(coordinate - merged_offset + jitter)) * combined_weight;
    total += 2.0 * combined_weight;
  }
  color /= max(total, 0.0001);
  frag_color = color.a > 0.0039
      ? vec4(color.rgb / color.a, 1.0)
      : color;
}
