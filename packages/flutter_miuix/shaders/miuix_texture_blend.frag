#version 320 es

// Flutter image-filter port of miuix-blur/internal/Shaders.kt. The first vec2
// and sampler are populated by ImageFilter.shader; layer uniforms are supplied
// by MiuixLayerBackdrop in the same order as the original Compose pipeline.
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

float color_burn(float base, float blend) {
  return blend == 0.0 ? blend : max(1.0 - (1.0 - base) / blend, 0.0);
}

vec3 color_burn(vec3 base, vec3 blend) {
  return vec3(
    color_burn(base.r, blend.r),
    color_burn(base.g, blend.g),
    color_burn(base.b, blend.b)
  );
}

float color_dodge(float base, float blend) {
  return blend == 1.0 ? blend : min(base / (1.0 - blend), 1.0);
}

vec3 color_dodge(vec3 base, vec3 blend) {
  return vec3(
    color_dodge(base.r, blend.r),
    color_dodge(base.g, blend.g),
    color_dodge(base.b, blend.b)
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

vec3 rgb2xyz(vec3 c) {
  c.r = c.r > 0.04045 ? pow((c.r + 0.055) / 1.055, 2.4) : c.r / 12.92;
  c.g = c.g > 0.04045 ? pow((c.g + 0.055) / 1.055, 2.4) : c.g / 12.92;
  c.b = c.b > 0.04045 ? pow((c.b + 0.055) / 1.055, 2.4) : c.b / 12.92;
  c *= 100.0;
  return vec3(
    c.r * 0.4124 + c.g * 0.3576 + c.b * 0.1805,
    c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722,
    c.r * 0.0193 + c.g * 0.1192 + c.b * 0.9505
  );
}

vec3 xyz2lab(vec3 c) {
  c /= vec3(95.047, 100.0, 108.883);
  c.x = c.x > 0.008856 ? pow(c.x, 1.0 / 3.0) : 7.787 * c.x + 16.0 / 116.0;
  c.y = c.y > 0.008856 ? pow(c.y, 1.0 / 3.0) : 7.787 * c.y + 16.0 / 116.0;
  c.z = c.z > 0.008856 ? pow(c.z, 1.0 / 3.0) : 7.787 * c.z + 16.0 / 116.0;
  return vec3(116.0 * c.y - 16.0, 500.0 * (c.x - c.y), 200.0 * (c.y - c.z));
}

vec3 rgb2lab(vec3 c) {
  return xyz2lab(rgb2xyz(c));
}

vec3 lab2xyz(vec3 lab) {
  float y = (lab.x + 16.0) / 116.0;
  float x = lab.y / 500.0 + y;
  float z = y - lab.z / 200.0;
  y = pow(y, 3.0) > 0.008856 ? pow(y, 3.0) : (y - 16.0 / 116.0) / 7.787;
  x = pow(x, 3.0) > 0.008856 ? pow(x, 3.0) : (x - 16.0 / 116.0) / 7.787;
  z = pow(z, 3.0) > 0.008856 ? pow(z, 3.0) : (z - 16.0 / 116.0) / 7.787;
  return vec3(x * 95.047, y * 100.0, z * 108.883);
}

vec3 xyz2rgb(vec3 xyz) {
  xyz /= 100.0;
  float r = xyz.x * 3.2406 + xyz.y * -1.5372 + xyz.z * -0.4986;
  float g = xyz.x * -0.9689 + xyz.y * 1.8758 + xyz.z * 0.0415;
  float b = xyz.x * 0.0557 + xyz.y * -0.2040 + xyz.z * 1.0570;
  r = r > 0.0031308 ? 1.055 * pow(r, 1.0 / 2.4) - 0.055 : 12.92 * r;
  g = g > 0.0031308 ? 1.055 * pow(g, 1.0 / 2.4) - 0.055 : 12.92 * g;
  b = b > 0.0031308 ? 1.055 * pow(b, 1.0 / 2.4) - 0.055 : 12.92 * b;
  return clamp(vec3(r, g, b), 0.0, 1.0);
}

vec3 lab2rgb(vec3 lab) {
  return xyz2rgb(lab2xyz(lab));
}

vec3 lab_lighten(vec3 color, float amount) {
  vec3 lab = rgb2lab(color);
  lab.r = (100.0 - amount) / 55.0 * lab.r + (100.0 * amount - 4500.0) / 55.0;
  return lab2rgb(lab);
}

vec3 lab_darken(vec3 color, float amount) {
  vec3 lab = rgb2lab(color);
  lab.r = amount / 45.0 * lab.r;
  return lab2rgb(lab);
}

vec3 lab_color(vec3 color, float m, float n) {
  vec3 lab = rgb2lab(color);
  lab.r = (n - m) * lab.r + m * 100.0;
  return lab2rgb(lab);
}

vec3 lab_normalized(vec3 lab) {
  return vec3(lab.r / 100.0, (lab.g + 128.0) / 255.0, (lab.b + 128.0) / 255.0);
}

vec3 lab_denormalized(vec3 lab) {
  return vec3(lab.r * 100.0, lab.g * 255.0 - 128.0, lab.b * 255.0 - 128.0);
}

vec3 linear_light_lab(vec3 source, vec3 destination) {
  vec3 source_lab = lab_normalized(rgb2lab(source));
  vec3 destination_lab = lab_normalized(rgb2lab(destination));
  return lab2rgb(lab_denormalized(linear_light(destination_lab, source_lab)));
}

vec3 rgb2hsl(vec3 c) {
  float minimum = min(c.r, min(c.g, c.b));
  float maximum = max(c.r, max(c.g, c.b));
  float lightness = (maximum + minimum) * 0.5;
  float saturation = 0.0;
  float hue = 0.0;
  if (maximum > minimum) {
    float delta = maximum - minimum;
    saturation = lightness < 0.5
        ? delta / (maximum + minimum)
        : delta / (2.0 - maximum - minimum);
    if (maximum == c.r) hue = (c.g - c.b) / delta;
    else if (maximum == c.g) hue = 2.0 + (c.b - c.r) / delta;
    else hue = 4.0 + (c.r - c.g) / delta;
    hue = mod(hue / 6.0, 1.0);
  }
  return vec3(hue, saturation, lightness);
}

vec3 hsl2rgb(vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
}

float soft_light_channel(float base, float blend) {
  if (blend <= 0.5) return base - (1.0 - 2.0 * blend) * base * (1.0 - base);
  float d = base <= 0.25
      ? ((16.0 * base - 12.0) * base + 4.0) * base
      : sqrt(base);
  return base + (2.0 * blend - 1.0) * (d - base);
}

vec3 standard_blend(int mode, vec3 base, vec3 blend) {
  if (mode == 14) return 1.0 - (1.0 - base) * (1.0 - blend);
  if (mode == 24) return base * blend;
  if (mode == 15) return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), step(0.5, base));
  if (mode == 20) return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), step(0.5, blend));
  if (mode == 21) return vec3(
    soft_light_channel(base.r, blend.r),
    soft_light_channel(base.g, blend.g),
    soft_light_channel(base.b, blend.b)
  );
  if (mode == 18) return color_dodge(base, blend);
  if (mode == 19) return color_burn(base, blend);
  if (mode == 28) {
    vec3 hsl = rgb2hsl(base);
    hsl.z = rgb2hsl(blend).z;
    return hsl2rgb(hsl);
  }
  return blend;
}

// Current Shaders.kt evaluates standard modes directly in premultiplied
// space. Unpremultiplying and merely interpolating by source alpha produces a
// visibly different Colored Thick preset, especially for Overlay/Dodge.
const float k_min_normal = 0.00006103515625;
const float k_divide_epsilon = 0.00000001;

float guarded_divide(float numerator, float denominator) {
  return numerator / (denominator + k_divide_epsilon);
}

vec3 guarded_divide(vec3 numerator, float denominator) {
  return numerator / (denominator + k_divide_epsilon);
}

vec4 mi_src_over(vec4 source, vec4 destination) {
  return source + (1.0 - source.a) * destination;
}

vec4 mi_screen(vec4 source, vec4 destination) {
  return source + (1.0 - source) * destination;
}

float mi_overlay_component(vec2 source, vec2 destination) {
  return 2.0 * destination.x <= destination.y
      ? 2.0 * source.x * destination.x
      : source.y * destination.y -
          2.0 * (destination.y - destination.x) *
              (source.y - source.x);
}

vec4 mi_overlay(vec4 source, vec4 destination) {
  vec4 result = vec4(
    mi_overlay_component(source.ra, destination.ra),
    mi_overlay_component(source.ga, destination.ga),
    mi_overlay_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
  result.rgb += destination.rgb * (1.0 - source.a) +
      source.rgb * (1.0 - destination.a);
  return result;
}

float mi_color_dodge_component(vec2 source, vec2 destination) {
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

vec4 mi_color_dodge(vec4 source, vec4 destination) {
  return vec4(
    mi_color_dodge_component(source.ra, destination.ra),
    mi_color_dodge_component(source.ga, destination.ga),
    mi_color_dodge_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

float mi_color_burn_component(vec2 source, vec2 destination) {
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

vec4 mi_color_burn(vec4 source, vec4 destination) {
  return vec4(
    mi_color_burn_component(source.ra, destination.ra),
    mi_color_burn_component(source.ga, destination.ga),
    mi_color_burn_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

float mi_soft_light_component(vec2 source, vec2 destination) {
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

vec4 mi_soft_light(vec4 source, vec4 destination) {
  if (destination.a == 0.0) return source;
  return vec4(
    mi_soft_light_component(source.ra, destination.ra),
    mi_soft_light_component(source.ga, destination.ga),
    mi_soft_light_component(source.ba, destination.ba),
    source.a + (1.0 - source.a) * destination.a
  );
}

vec4 mi_multiply(vec4 source, vec4 destination) {
  return vec4(
    (1.0 - source.a) * destination.rgb +
        (1.0 - destination.a) * source.rgb +
        source.rgb * destination.rgb,
    source.a + (1.0 - source.a) * destination.a
  );
}

float mi_luminance(vec3 color) {
  return dot(vec3(0.3, 0.59, 0.11), color);
}

vec3 mi_set_luminance(vec3 hue_color, float alpha, vec3 luminance_color) {
  float luminance = mi_luminance(luminance_color);
  vec3 result = luminance - mi_luminance(hue_color) + hue_color;
  float minimum = min(min(result.r, result.g), result.b);
  float maximum = max(max(result.r, result.g), result.b);
  if (minimum < 0.0 && luminance != minimum) {
    result = luminance +
        (result - luminance) *
            guarded_divide(luminance, luminance - minimum + k_min_normal);
  }
  if (maximum > alpha && maximum != luminance) {
    result = luminance +
        guarded_divide(
          (result - luminance) * (alpha - luminance),
          maximum - luminance + k_min_normal
        );
  }
  return result;
}

vec4 mi_luminosity(vec4 source, vec4 destination) {
  float alpha = destination.a * source.a;
  vec3 source_destination_alpha = source.rgb * destination.a;
  vec3 destination_source_alpha = destination.rgb * source.a;
  return vec4(
    mi_set_luminance(
          destination_source_alpha,
          alpha,
          source_destination_alpha
        ) +
        destination.rgb - destination_source_alpha +
        source.rgb - source_destination_alpha,
    source.a + destination.a - alpha
  );
}

vec4 apply_standard_mode(vec4 background, vec4 source, int mode) {
  if (mode == 3) return mi_src_over(source, background);
  if (mode == 14) return mi_screen(source, background);
  if (mode == 15) return mi_overlay(source, background);
  if (mode == 18) return mi_color_dodge(source, background);
  if (mode == 19) return mi_color_burn(source, background);
  if (mode == 20) return mi_overlay(background, source);
  if (mode == 21) return mi_soft_light(source, background);
  if (mode == 24) return mi_multiply(source, background);
  if (mode == 28) return mi_luminosity(source, background);
  return mi_src_over(source, background);
}

vec4 apply_mode(vec4 background, vec4 source, int mode) {
  if (mode <= 28) return apply_standard_mode(background, source, mode);
  float bg_alpha = max(background.a, 0.0001);
  float source_alpha = source.a;
  vec3 base = background.rgb / bg_alpha;
  vec3 blend = source_alpha > 0.0 ? source.rgb / source_alpha : vec3(0.0);
  vec3 result = base;

  if (mode == 100) {
    result = mix(base, linear_light(base, blend), source_alpha);
  } else if (mode == 101) {
    result = mix(base, linear_light(base, blend), source_alpha * greyscale(base));
  } else if (mode == 102) {
    result = mix(base, abs(base - blend), source_alpha);
  } else if (mode == 103) {
    float amount = 0.4 * greyscale(base) * 100.0 + 45.0;
    result = mix(base, lab_lighten(base, amount), source_alpha);
  } else if (mode == 105) {
    float amount = 45.0 - 0.15 * greyscale(base) * 100.0;
    result = mix(base, lab_darken(base, amount), source_alpha);
  } else if (mode == 106) {
    result = mix(base, lab_color(base, blend.r, blend.g), source_alpha);
  } else if (mode == 107) {
    result = mix(base, linear_light_lab(blend, base), source_alpha);
  } else if (mode == 118) {
    result = mix(base, color_dodge(base, blend), source_alpha);
  } else if (mode == 119) {
    result = mix(base, color_burn(base, blend), source_alpha);
  } else if (mode == 120) {
    result = max(vec3(0.0), 1.0 - ((1.0 - base) * bg_alpha + (1.0 - blend) * source_alpha));
  } else if (mode == 121) {
    result = min(base * bg_alpha + blend * source_alpha, vec3(1.0));
  }

  float out_alpha = source_alpha + bg_alpha * (1.0 - source_alpha);
  return vec4(result * out_alpha, out_alpha);
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
    float luminance = dot(source, vec3(0.2126, 0.7152, 0.0722));
    source = mix(vec3(luminance), source, u_saturation);
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
  for (int i = 0; i < 8; i++) {
    if (i >= count) break;
    current = apply_mode(current, u_layer_colors[i], int(u_modes[i] + 0.5));
  }
  frag_color = current;
}
