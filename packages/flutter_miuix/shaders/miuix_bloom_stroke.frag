#version 320 es

// Direct Flutter port of miuix-blur/internal/Shaders.kt's current
// BLOOM_STROKE_SHADER_SINGLE specialization. The source paints this output
// with BlendMode.Plus after ordinary blurred content.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform vec4 u_corner_radii;
uniform float u_stroke_width;
uniform float u_inner_blur_radius;
uniform float u_inner_blur_radius_sq;
uniform float u_highlight_alpha;
uniform vec4 u_stroke_color;
uniform float u_stroke_alpha_mul;
uniform vec3 u_light_dir_1;
uniform vec4 u_light_color_1;
uniform float u_light_intensity_1;
uniform vec3 u_light_dir_2;
uniform vec4 u_light_color_2;
uniform float u_light_intensity_2;
uniform vec2 u_axis_1;
uniform vec2 u_axis_2;

out vec4 frag_color;

float pick_radius(vec2 coordinate, vec2 half_view, vec4 radii) {
  vec2 vertical = coordinate.y < half_view.y ? radii.xy : radii.zw;
  return coordinate.x < half_view.x ? vertical.x : vertical.y;
}

float rounded_box_sdf(vec2 position, vec2 half_size, float radius) {
  radius = min(radius, min(half_size.x, half_size.y));
  vec2 distance = position - half_size + radius;
  return length(max(distance, 0.0)) +
      min(max(distance.x, distance.y), 0.0) - radius;
}

vec3 source_normal(
  vec2 coordinate,
  vec2 half_view,
  vec2 half_view_floor,
  float sdf,
  float radius
) {
  vec2 xy = coordinate - half_view_floor;
  vec2 folded = abs(xy);
  float transition = smoothstep(-u_inner_blur_radius, 0.0, sdf);
  float z = sqrt(max(u_inner_blur_radius_sq - transition * transition, 0.0));
  vec3 point = vec3(folded, -z);

  vec2 corner = half_view - radius;
  corner.x = min(corner.x, folded.x);
  corner.y = min(corner.y, folded.y);
  vec2 delta = point.xy - corner;
  float delta_length = length(delta);
  vec2 direction = delta_length > 0.000001 ? delta / delta_length : vec2(0.0);
  corner += direction * (radius - u_inner_blur_radius);

  if (any(lessThan(folded, corner))) {
    return vec3(0.0, 0.0, -1.0);
  }

  vec2 signal = sign(xy);
  vec3 normal = normalize(point - vec3(corner, 0.0));
  normal.xy *= signal;
  return normal;
}

void main() {
  vec2 coordinate = FlutterFragCoord().xy;
  vec2 half_view = u_size * 0.5;
  vec2 folded = abs(coordinate - half_view);
  float original_radius = pick_radius(coordinate, half_view, u_corner_radii);
  float radius = max(original_radius, u_inner_blur_radius);

  if (all(lessThan(folded, half_view - radius))) {
    frag_color = vec4(0.0);
    return;
  }

  float sdf = rounded_box_sdf(folded, half_view, original_radius);
  float outer_mask = smoothstep(0.0, -1.0, sdf);
  float stroke_alpha = smoothstep(
    -u_stroke_width,
    -u_stroke_width + 1.0,
    sdf
  );
  vec3 rgb = u_stroke_color.rgb *
      (u_stroke_alpha_mul * stroke_alpha * stroke_alpha);
  vec3 normal = source_normal(
    coordinate,
    half_view,
    floor(half_view),
    sdf,
    radius
  );

  float falloff_1 = max(dot(vec3(u_axis_1, 0.0), normal), 0.0);
  float light_1 = clamp(dot(normal, u_light_dir_1) * falloff_1, 0.0, 1.0);
  rgb += light_1 * light_1 * u_light_intensity_1 * u_light_color_1.rgb;

  float falloff_2 = max(dot(vec3(u_axis_2, 0.0), normal), 0.0);
  float light_2 = clamp(dot(normal, u_light_dir_2) * falloff_2, 0.0, 1.0);
  rgb += light_2 * light_2 * u_light_intensity_2 * u_light_color_2.rgb;

  frag_color = vec4(rgb * u_highlight_alpha, 1.0) * outer_mask;
}
