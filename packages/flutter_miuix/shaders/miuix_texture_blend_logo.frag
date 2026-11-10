#version 320 es

// Lean specialization for the source Foreground Blur "Logo Blend" sequence.
// The light token starts with ColorBurn while the dark token starts with
// ColorDodge; both then apply LinearLight and Lab color mapping. Keeping
// unrelated extended modes out avoids Skia register exhaustion.
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

vec4 premultiplied_color_burn(vec4 source, vec4 destination) {
  return vec4(
    burn_component(source.ra, destination.ra),
    burn_component(source.ga, destination.ga),
    burn_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
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

vec4 premultiplied_color_dodge(vec4 source, vec4 destination) {
  return vec4(
    dodge_component(source.ra, destination.ra),
    dodge_component(source.ga, destination.ga),
    dodge_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
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

vec3 rgb_to_xyz(vec3 color) {
  color.r = color.r > 0.04045
      ? pow((color.r + 0.055) / 1.055, 2.4)
      : color.r / 12.92;
  color.g = color.g > 0.04045
      ? pow((color.g + 0.055) / 1.055, 2.4)
      : color.g / 12.92;
  color.b = color.b > 0.04045
      ? pow((color.b + 0.055) / 1.055, 2.4)
      : color.b / 12.92;
  color *= 100.0;
  return vec3(
    color.r * 0.4124 + color.g * 0.3576 + color.b * 0.1805,
    color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722,
    color.r * 0.0193 + color.g * 0.1192 + color.b * 0.9505
  );
}

vec3 xyz_to_lab(vec3 color) {
  color /= vec3(95.047, 100.0, 108.883);
  color.x = color.x > 0.008856
      ? pow(color.x, 1.0 / 3.0)
      : 7.787 * color.x + 16.0 / 116.0;
  color.y = color.y > 0.008856
      ? pow(color.y, 1.0 / 3.0)
      : 7.787 * color.y + 16.0 / 116.0;
  color.z = color.z > 0.008856
      ? pow(color.z, 1.0 / 3.0)
      : 7.787 * color.z + 16.0 / 116.0;
  return vec3(
    116.0 * color.y - 16.0,
    500.0 * (color.x - color.y),
    200.0 * (color.y - color.z)
  );
}

vec3 lab_to_xyz(vec3 lab) {
  float y = (lab.x + 16.0) / 116.0;
  float x = lab.y / 500.0 + y;
  float z = y - lab.z / 200.0;
  float y3 = pow(y, 3.0);
  float x3 = pow(x, 3.0);
  float z3 = pow(z, 3.0);
  y = y3 > 0.008856 ? y3 : (y - 16.0 / 116.0) / 7.787;
  x = x3 > 0.008856 ? x3 : (x - 16.0 / 116.0) / 7.787;
  z = z3 > 0.008856 ? z3 : (z - 16.0 / 116.0) / 7.787;
  return vec3(x * 95.047, y * 100.0, z * 108.883);
}

vec3 xyz_to_rgb(vec3 xyz) {
  xyz /= 100.0;
  vec3 rgb = vec3(
    xyz.x * 3.2406 + xyz.y * -1.5372 + xyz.z * -0.4986,
    xyz.x * -0.9689 + xyz.y * 1.8758 + xyz.z * 0.0415,
    xyz.x * 0.0557 + xyz.y * -0.2040 + xyz.z * 1.0570
  );
  rgb.r = rgb.r > 0.0031308
      ? 1.055 * pow(rgb.r, 1.0 / 2.4) - 0.055
      : 12.92 * rgb.r;
  rgb.g = rgb.g > 0.0031308
      ? 1.055 * pow(rgb.g, 1.0 / 2.4) - 0.055
      : 12.92 * rgb.g;
  rgb.b = rgb.b > 0.0031308
      ? 1.055 * pow(rgb.b, 1.0 / 2.4) - 0.055
      : 12.92 * rgb.b;
  return clamp(rgb, 0.0, 1.0);
}

vec3 lab_color(vec3 color, float minimum, float maximum) {
  vec3 lab = xyz_to_lab(rgb_to_xyz(color));
  lab.r = (maximum - minimum) * lab.r + minimum * 100.0;
  return xyz_to_rgb(lab_to_xyz(lab));
}

vec4 apply_logo_mode(vec4 background, vec4 layer, int mode) {
  if (mode == 18) return premultiplied_color_dodge(layer, background);
  if (mode == 19) return premultiplied_color_burn(layer, background);
  float background_alpha = max(background.a, 0.0001);
  float layer_alpha = layer.a;
  vec3 base = background.rgb / background_alpha;
  vec3 blend = layer_alpha > 0.0 ? layer.rgb / layer_alpha : vec3(0.0);
  vec3 result = base;
  if (mode == 100) {
    result = mix(base, linear_light(base, blend), layer_alpha);
  } else if (mode == 106) {
    result = mix(base, lab_color(base, blend.r, blend.g), layer_alpha);
  }
  return vec4(result * background_alpha, background_alpha);
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
    current = apply_logo_mode(
      current,
      u_layer_colors[index],
      int(u_modes[index] + 0.5)
    );
  }
  frag_color = current;
}
