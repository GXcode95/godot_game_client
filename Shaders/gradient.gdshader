shader_type canvas_item;

uniform vec4 orange : source_color = vec4(1.0, 0.6, 0.0, 1.0); // orange
uniform vec4 green : source_color = vec4(0.2, 0.8, 0.4, 1.0); // green
uniform vec4 cyan : source_color = vec4(0.2, 0.8, 0.85, 1.0); // cyan
uniform vec4 purple : source_color = vec4(0.8, 0.2, 0.8, 1.0); // pruple

void fragment() {
    // UV coords from 0 to 1
    float t = (UV.x + UV.y) * 0.5; // Diagonal interpolation

    vec4 col;
    if (t < 0.45) {
        // A -> B
        float f = smoothstep(0.0, 0.45, t);
        col = mix(orange, green, f);
    } else if (t < 0.55) {
        // B -> C
        float f = smoothstep(0.45, 0.55, t);
        col = mix(green, cyan, f);
    } else {
        // C -> D
        float f = smoothstep(0.55, 1.0, t);
        col = mix(cyan, purple, f);
    }

    COLOR = col;
}