shader_type canvas_item;

uniform sampler2D screen_texture;
uniform float blur_radius = 4.0;
uniform vec2 screen_size = vec2(1920.0, 1080.0); // Set this to match your viewport

void fragment() {
    vec2 uv = UV;
    vec4 color = vec4(0.0);
    float total = 0.0;

    // Simple Gaussian blur
    for (float x = -blur_radius; x <= blur_radius; x++) {
        for (float y = -blur_radius; y <= blur_radius; y++) {
            float weight = exp(-(x*x + y*y) / (2.0 * blur_radius * blur_radius));
            vec2 offset = vec2(x, y) / screen_size;
            color += texture(screen_texture, uv + offset) * weight;
            total += weight;
        }
    }

    color /= total;
    COLOR = color;
}
