shader_type canvas_item;

// Number of colors to shift between (maximum 10 for practical purposes)
uniform int num_colors : hint_range(2, 10) = 3;
// Array of colors to shift between
uniform vec4 shift_colors[10] : source_color;
uniform float color_speed = 1.0;
uniform float color_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float color_offset : hint_range(0.0, 1.0) = 0.0;

// Function to interpolate between multiple colors
vec3 shift_between_colors(float time) {
    float cycle = mod(time * color_speed + color_offset, float(num_colors));
    int current_index = int(cycle);
    int next_index = (current_index + 1) % num_colors;
    float t = fract(cycle);

    // Smooth interpolation between colors
    float smooth_t = smoothstep(0.0, 1.0, t);
    return mix(shift_colors[current_index].rgb, shift_colors[next_index].rgb, smooth_t);
}

void fragment() {
    // Get the sprite's texture color
    vec4 texture_color = texture(TEXTURE, UV);

    // Skip transparent pixels
    if (texture_color.a < 0.01) {
        discard;
    }

    // Get the current shifted color
    vec3 shifted_base = shift_between_colors(TIME);

    // Mix with the texture color based on intensity
    vec3 final_color = mix(texture_color.rgb, shifted_base, color_intensity);

    // Set the final color while preserving original alpha
    COLOR = vec4(final_color, texture_color.a);
}