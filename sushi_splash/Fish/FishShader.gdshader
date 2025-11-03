shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 20.0) = 5.0;
uniform float frequency : hint_range(0.0, 20.0) = 10.0;
uniform float speed : hint_range(0.0, 10.0) = 4.0;
uniform float flop_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Sample the original color first (before distortion)
    vec4 original_color = texture(TEXTURE, UV);

    // Skip fully transparent pixels so they don’t distort
    if (original_color.a < 0.01) {
        discard;
    }

    // Apply flop distortion
    vec2 offset_uv = UV;
    float wave = sin(offset_uv.y * frequency + TIME * speed) * amplitude * flop_strength;

    offset_uv.x += wave / TEXTURE_PIXEL_SIZE.x;

    // Sample again using the distorted UV — but only apply distortion to the visible parts
    vec4 distorted_color = texture(TEXTURE, offset_uv);

    // Keep the alpha from the original sample to avoid distorting transparency edges
    COLOR = vec4(distorted_color.rgb, original_color.a);
}
