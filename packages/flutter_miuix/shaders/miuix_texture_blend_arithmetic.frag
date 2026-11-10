#version 320 es

// Lean specialization for current source presets that combine ordinary Skia
// modes with LinearLight, Difference, MI dodge/burn, or PlusDarker/Lighter.
// Lab conversion is deliberately absent so Android Skia does not reserve the
// large register set that made the former catch-all effect fail at runtime.
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
        ? guarded_divide(destination.x * source.y, source.y - source.x)
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

float luminance(vec3 color) {
  return dot(vec3(0.3, 0.59, 0.11), color);
}

vec3 set_luminance(vec3 hue_color, float alpha, vec3 luminance_color) {
  float value = luminance(luminance_color);
  vec3 result = value - luminance(hue_color) + hue_color;
  float minimum = min(min(result.r, result.g), result.b);
  float maximum = max(max(result.r, result.g), result.b);
  if (minimum < 0.0 && value != minimum) {
    result = value + (result - value) *
        guarded_divide(value, value - minimum + k_min_normal);
  }
  if (maximum > alpha && maximum != value) {
    result = value + guarded_divide(
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

float straight_burn(float base, float blend) {
  return blend == 0.0 ? blend : max(1.0 - (1.0 - base) / blend, 0.0);
}

vec3 straight_burn(vec3 base, vec3 blend) {
  return vec3(
    straight_burn(base.r, blend.r),
    straight_burn(base.g, blend.g),
    straight_burn(base.b, blend.b)
  );
}

float straight_dodge(float base, float blend) {
  return blend == 1.0 ? blend : min(base / (1.0 - blend), 1.0);
}

vec3 straight_dodge(vec3 base, vec3 blend) {
  return vec3(
    straight_dodge(base.r, blend.r),
    straight_dodge(base.g, blend.g),
    straight_dodge(base.b, blend.b)
  );
}

float linear_light(float base, float blend) {
  return blend < 0.5
      ? max(base + 2.0 * blend - 1.0, 0.0)
      : min(base + 2.0 * (blend - 0.5), 1.0);
}

vec3 linear_light(vec3 base, vec3 blend) {
  return vec3(
    linear_light(base.r, blend.r),
    linear_light(base.g, blend.g),
    linear_light(base.b, blend.b)
  );
}

float greyscale(vec3 color) {
  return 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
}

vec4 apply_mode(vec4 background, vec4 source, int mode) {
  if (mode == 3) return src_over(source, background);
  if (mode == 15) return overlay_mode(source, background);
  if (mode == 18) return dodge_mode(source, background);
  if (mode == 19) return burn_mode(source, background);
  if (mode == 28) return luminosity_mode(source, background);

  float background_alpha = max(background.a, 0.0001);
  float source_alpha = source.a;
  vec3 base = background.rgb / background_alpha;
  vec3 blend = source_alpha > 0.0 ? source.rgb / source_alpha : vec3(0.0);
  vec3 result = base;

  if (mode == 100) {
    result = mix(base, linear_light(base, blend), source_alpha);
  } else if (mode == 101) {
    result = mix(
      base,
      linear_light(base, blend),
      source_alpha * greyscale(base)
    );
  } else if (mode == 102) {
    result = mix(base, abs(base - blend), source_alpha);
  } else if (mode == 118) {
    result = mix(base, straight_dodge(base, blend), source_alpha);
  } else if (mode == 119) {
    result = mix(base, straight_burn(base, blend), source_alpha);
  } else if (mode == 120) {
    result = max(
      vec3(0.0),
      1.0 - ((1.0 - base) * background_alpha +
          (1.0 - blend) * source_alpha)
    );
  } else if (mode == 121) {
    result = min(
      base * background_alpha + blend * source_alpha,
      vec3(1.0)
    );
  } else if (mode == 200) {
    vec4 layer = vec4(blend, source_alpha);
    vec4 mixed_color = (1.0 - source_alpha) *
        vec4(base, background_alpha) + source_alpha * layer;
    float mask = (1.0 - source_alpha) * (1.0 - base.r) + base.r;
    return vec4(
      mixed_color.rgb * mask * background_alpha,
      background_alpha
    );
  } else if (mode == 201) {
    float luminance = dot(base, vec3(0.2126, 0.7152, 0.0722));
    vec3 adjusted = mix(vec3(luminance), base, u_saturation);
    result = mix(base, adjusted, source_alpha);
  } else if (mode == 202) {
    vec3 linear = pow(base, vec3(2.2));
    if (u_brightness > 0.0) {
      linear = mix(linear, vec3(1.0), u_brightness);
    } else {
      linear *= 1.0 + u_brightness;
    }
    vec3 adjusted = pow(max(linear, vec3(0.0)), vec3(0.45454545));
    result = mix(base, adjusted, source_alpha);
  } else if (mode == 203) {
    // The current source binds zero luminance curve uniforms, so this mode is
    // neutral until a public luminance-curve configuration is introduced.
    result = base;
  }

  float output_alpha = source_alpha +
      background_alpha * (1.0 - source_alpha);
  return vec4(result * output_alpha, output_alpha);
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
