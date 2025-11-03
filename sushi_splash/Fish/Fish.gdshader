shader_type canvas_item;

uniform float time;
uniform float intensity = 5.0;
uniform float frequency = 10.0;

void vertex() {
    // Apply vertical sine wave based on x-position
    VERTEX.y += sin(VERTEX.x * frequency + time) * intensity;
}
