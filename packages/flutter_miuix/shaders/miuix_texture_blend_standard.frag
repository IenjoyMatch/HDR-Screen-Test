#version 320 es

// Lean current-source specialization for blend modes <= 28. MIUIX itself
// compiles this smaller variant when no Lab/custom mode is present so mobile
// Skia drivers do not reserve registers for the unrelated extended paths.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform float u_layer_count;
uniform vec4 u_layer_colors[8];
uniform float u_modes[8];
uniform float u_brightness;
uniform float u_contrast;
uniform float u_saturation;
uniform sampler2D u_texture_input;

out vec4 frag_color;

const float k_min_normal = 0.00006103515625;
const float k_divide_epsilon = 0.00000001;

float guarded_divide(float numerator, float denominator) {
  return numerator / (denominator + k_divide_epsilon);
}

vec3 guarded_divide(vec3 numerator, float denominator) {
  return numerator / (denominator + k_divide_epsilon);
}

vec4 src_over(vec4 source, vec4 destination) {
  return source + (1.0 - source.a) * destination;
}

vec4 screen_mode(vec4 source, vec4 destination) {
  return source + (1.0 - source) * destination;
}

float overlay_component(vec2 source, vec2 destination) {
  return 2.0 * destination.x <= destination.y
      ? 2.0 * source.x * destination.x
      : source.y * destination.y -
          2.0 * (destination.y - destination.x) *
              (source.y - source.x);
}

vec4 overlay_mode(vec4 source, vec4 destination) {
  vec4 result = vec4(
    overlay_component(source.ra, destination.ra),
    overlay_component(source.ga, destination.ga),
    overlay_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
  result.rgb += destination.rgb * (1.0 - source.a) +
      source.rgb * (1.0 - destination.a);
  return result;
}

float dodge_component(vec2 source, vec2 destination) {
  float delta = min(
    destination.y,
    abs(source.y - source.x) >= k_min_normal
        ? guarded_divide(
            destination.x * source.y,
            source.y - source.x
          )
        : destination.y
  );
  return delta * source.y + source.x * (1.0 - destination.y) +
      destination.x * (1.0 - source.y);
}

vec4 dodge_mode(vec4 source, vec4 destination) {
  return vec4(
    dodge_component(source.ra, destination.ra),
    dodge_component(source.ga, destination.ga),
    dodge_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

float burn_component(vec2 source, vec2 destination) {
  float delta = abs(source.x) >= k_min_normal
      ? destination.y - min(
          destination.y,
          guarded_divide(
            (destination.y - destination.x) * source.y,
            source.x
          )
        )
      : 0.0;
  return delta * source.y + source.x * (1.0 - destination.y) +
      destination.x * (1.0 - source.y);
}

vec4 burn_mode(vec4 source, vec4 destination) {
  return vec4(
    burn_component(source.ra, destination.ra),
    burn_component(source.ga, destination.ga),
    burn_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

float soft_light_component(vec2 source, vec2 destination) {
  if (2.0 * source.x <= source.y) {
    return guarded_divide(
          destination.x * destination.x *
              (source.y - 2.0 * source.x),
          destination.y
        ) +
        (1.0 - destination.y) * source.x +
        destination.x * (-source.y + 2.0 * source.x + 1.0);
  }
  if (4.0 * destination.x <= destination.y) {
    float destination_sq = destination.x * destination.x;
    float destination_cube = destination_sq * destination.x;
    float alpha_sq = destination.y * destination.y;
    float alpha_cube = alpha_sq * destination.y;
    return guarded_divide(
      alpha_sq *
              (source.x -
                  destination.x *
                      (3.0 * source.y - 6.0 * source.x - 1.0)) +
          12.0 * destination.y * destination_sq *
              (source.y - 2.0 * source.x) -
          16.0 * destination_cube * (source.y - 2.0 * source.x) -
          alpha_cube * source.x,
      alpha_sq
    );
  }
  return destination.x * (source.y - 2.0 * source.x + 1.0) +
      source.x -
      sqrt(destination.y * destination.x) *
          (source.y - 2.0 * source.x) -
      destination.y * source.x;
}

vec4 soft_light_mode(vec4 source, vec4 destination) {
  if (destination.a == 0.0) return source;
  return vec4(
    soft_light_component(source.ra, destination.ra),
    soft_light_component(source.ga, destination.ga),
    soft_light_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

vec4 multiply_mode(vec4 source, vec4 destination) {
  return vec4(
    (1.0 - source.a) * destination.rgb +
        (1.0 - destination.a) * source.rgb +
        source.rgb * destination.rgb,
    source.a + (1.0 - source.a) * destination.a
  );
}

float luminance(vec3 color) {
  return dot(vec3(0.3, 0.59, 0.11), color);
}

vec3 set_luminance(vec3 hue_color, float alpha, vec3 luminance_color) {
  float value = luminance(luminance_color);
  vec3 result = value - luminance(hue_color) + hue_color;
  float minimum = min(min(result.r, result.g), result.b);
  float maximum = max(max(result.r, result.g), result.b);
  if (minimum < 0.0 && value != minimum) {
    result = value +
        (result - value) *
            guarded_divide(value, value - minimum + k_min_normal);
  }
  if (maximum > alpha && maximum != value) {
    result = value +
        guarded_divide(
          (result - value) * (alpha - value),
          maximum - value + k_min_normal
        );
  }
  return result;
}

vec4 luminosity_mode(vec4 source, vec4 destination) {
  float alpha = destination.a * source.a;
  vec3 source_destination_alpha = source.rgb * destination.a;
  vec3 destination_source_alpha = destination.rgb * source.a;
  return vec4(
    set_luminance(
          destination_source_alpha,
          alpha,
          source_destination_alpha
        ) +
        destination.rgb - destination_source_alpha +
        source.rgb - source_destination_alpha,
    source.a + destination.a - alpha
  );
}

vec4 apply_mode(vec4 background, vec4 source, int mode) {
  if (mode == 3) return src_over(source, background);
  if (mode == 14) return screen_mode(source, background);
  if (mode == 15) return overlay_mode(source, background);
  if (mode == 18) return dodge_mode(source, background);
  if (mode == 19) return burn_mode(source, background);
  if (mode == 20) return overlay_mode(background, source);
  if (mode == 21) return soft_light_mode(source, background);
  if (mode == 24) return multiply_mode(source, background);
  if (mode == 28) return luminosity_mode(source, background);
  return src_over(source, background);
}

vec4 apply_color_controls(vec4 color) {
  float alpha = color.a;
  if (alpha < 0.001) return color;
  vec3 source = color.rgb / alpha;
  if (u_brightness != 0.0) {
    source = pow(source, vec3(2.2));
    source = u_brightness > 0.0
        ? mix(source, vec3(1.0), u_brightness)
        : source * (1.0 + u_brightness);
    source = pow(source, vec3(0.45454545));
  }
  if (u_contrast != 1.0) {
    source = (source - 0.5) * u_contrast + 0.5;
  }
  if (u_saturation != 1.0) {
    float light = dot(source, vec3(0.2126, 0.7152, 0.0722));
    source = mix(vec3(light), source, u_saturation);
  }
  source = clamp(source, 0.0, 1.0);
  return vec4(source * alpha, alpha);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  vec4 current = apply_color_controls(texture(u_texture_input, uv));
  int count = int(u_layer_count + 0.5);
  for (int index = 0; index < 8; index++) {
    if (index >= count) break;
    current = apply_mode(
      current,
      u_layer_colors[index],
      int(u_modes[index] + 0.5)
    );
  }
  frag_color = current;
}
