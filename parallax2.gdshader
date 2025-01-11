shader_type canvas_item;

// Input parameters for customization
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float color_speed = 1.0;
uniform float color_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float color_offset : hint_range(0.0, 1.0) = 0.0;

// Color shift function using sine waves
vec3 shift_color(vec3 input_color, float time) {
    // Create offset sine waves for each color channel
    float r_shift = sin(time * color_speed + color_offset) * color_intensity;
    float g_shift = sin(time * color_speed + color_offset + 2.094) * color_intensity; // 2.094 = 2π/3
    float b_shift = sin(time * color_speed + color_offset + 4.189) * color_intensity; // 4.189 = 4π/3
    
    // Mix the input color with the shifted colors
    vec3 shifted_color = vec3(
        input_color.r + r_shift,
        input_color.g + g_shift,
        input_color.b + b_shift
    );
    
    // Ensure colors stay in valid range
    return clamp(shifted_color, 0.0, 1.0);
}

void fragment() {
    // Get the sprite's texture color
    vec4 texture_color = texture(TEXTURE, UV);
    
    // Skip transparent pixels
    if (texture_color.a < 0.01) {
        discard;
    }
    
    // Get base color influence
    vec3 influenced_color = mix(texture_color.rgb, base_color.rgb, 0.5);
    
    // Apply color shifting
    vec3 final_color = shift_color(influenced_color, TIME);
    
    // Set the final color while preserving original alpha
    COLOR = vec4(final_color, texture_color.a);
}