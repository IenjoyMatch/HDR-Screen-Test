#version 320 es

// Flutter ImageFilter adaptation of AndroidLiquidGlass's rounded-rectangle
// refraction and vibrancy pipeline at commit 65ab177e90e5c1d8c62e70cf7755841982da65f6.
// Copyright 2025 Kyant; source licensed under Apache-2.0.
// The input sampler is supplied by Flutter's ImageFilter.shader pipeline; all
// coordinates are in the physical destination-texture domain.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform vec2 u_shape_size;
uniform vec2 u_shape_offset;
uniform vec4 u_corner_radii;
uniform float u_refraction_height;
uniform float u_refraction_amount;
uniform float u_depth_effect;
uniform float u_chromatic_aberration;
uniform float u_vibrancy;
uniform sampler2D u_texture_input;

out vec4 frag_color;

float radius_at(vec2 coordinate) {
  if (coordinate.x >= 0.0) {
    return coordinate.y <= 0.0 ? u_corner_radii.y : u_corner_radii.z;
  }
  return coordinate.y <= 0.0 ? u_corner_radii.x : u_corner_radii.w;
}

float rounded_rect_sdf(vec2 coordinate, vec2 half_size, float radius) {
  vec2 corner = abs(coordinate) - (half_size - vec2(radius));
  float outside = length(max(corner, 0.0)) - radius;
  float inside = min(max(corner.x, corner.y), 0.0);
  return outside + inside;
}

vec2 rounded_rect_gradient(vec2 coordinate, vec2 half_size, float radius) {
  vec2 corner = abs(coordinate) - (half_size - vec2(radius));
  if (corner.x >= 0.0 || corner.y >= 0.0) {
    vec2 positive = max(corner, 0.0);
    float magnitude = length(positive);
    vec2 direction = magnitude > 0.000001 ? positive / magnitude : vec2(0.0);
    return sign(coordinate) * direction;
  }
  float gradient_x = step(corner.y, corner.x);
  return sign(coordinate) * vec2(gradient_x, 1.0 - gradient_x);
}

vec4 sample_input(vec2 coordinate) {
  vec2 uv = clamp(coordinate, vec2(0.5), u_size - vec2(0.5)) / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  vec4 sampled_color = texture(u_texture_input, uv);
  // AndroidLiquidGlass applies a 1.5x saturation ColorMatrix before blur and
  // refraction. Saturation is a linear transform, so applying the same matrix
  // to each sampled result is equivalent while keeping Flutter's filter chain
  // to one runtime lens. Clamp to alpha to preserve premultiplied output.
  float luminance = dot(sampled_color.rgb, vec3(0.213, 0.715, 0.072));
  sampled_color.rgb = clamp(
    mix(vec3(luminance), sampled_color.rgb, u_vibrancy),
    vec3(0.0),
    vec3(sampled_color.a)
  );
  return sampled_color;
}

float circle_map(float value) {
  float safe_value = clamp(value, 0.0, 1.0);
  return 1.0 - sqrt(max(0.0, 1.0 - safe_value * safe_value));
}

void main() {
  vec2 coordinate = FlutterFragCoord().xy;
  vec2 half_size = u_shape_size * 0.5;
  vec2 centered = (coordinate + u_shape_offset) - half_size;
  float radius = radius_at(centered);
  float distance = rounded_rect_sdf(centered, half_size, radius);

  if (-distance >= u_refraction_height || u_refraction_height <= 0.0) {
    frag_color = sample_input(coordinate);
    return;
  }
  distance = min(distance, 0.0);
  float displacement = circle_map(1.0 - (-distance / u_refraction_height)) *
      u_refraction_amount;
  float gradient_radius = min(radius * 1.5, min(half_size.x, half_size.y));
  vec2 gradient = rounded_rect_gradient(centered, half_size, gradient_radius);
  if (u_depth_effect > 0.0) {
    float center_length = length(centered);
    if (center_length > 0.000001) gradient += centered / center_length;
  }
  float gradient_length = length(gradient);
  gradient = gradient_length > 0.000001 ? gradient / gradient_length : vec2(0.0);
  vec2 refracted = coordinate + displacement * gradient;

  if (u_chromatic_aberration <= 0.0) {
    frag_color = sample_input(refracted);
    return;
  }

  float denominator = max(half_size.x * half_size.y, 0.000001);
  float dispersion_intensity = u_chromatic_aberration *
      ((centered.x * centered.y) / denominator);
  vec2 dispersed = displacement * gradient * dispersion_intensity;
  vec4 color = vec4(0.0);
  vec4 red = sample_input(refracted + dispersed);
  color.r += red.r / 3.5;
  color.a += red.a / 7.0;
  vec4 orange = sample_input(refracted + dispersed * (2.0 / 3.0));
  color.r += orange.r / 3.5;
  color.g += orange.g / 7.0;
  color.a += orange.a / 7.0;
  vec4 yellow = sample_input(refracted + dispersed * (1.0 / 3.0));
  color.r += yellow.r / 3.5;
  color.g += yellow.g / 3.5;
  color.a += yellow.a / 7.0;
  vec4 green = sample_input(refracted);
  color.g += green.g / 3.5;
  color.a += green.a / 7.0;
  vec4 cyan = sample_input(refracted - dispersed * (1.0 / 3.0));
  color.g += cyan.g / 3.5;
  color.b += cyan.b / 3.0;
  color.a += cyan.a / 7.0;
  vec4 blue = sample_input(refracted - dispersed * (2.0 / 3.0));
  color.b += blue.b / 3.0;
  color.a += blue.a / 7.0;
  vec4 purple = sample_input(refracted - dispersed);
  color.r += purple.r / 7.0;
  color.b += purple.b / 3.0;
  color.a += purple.a / 7.0;
  frag_color = color;
}
