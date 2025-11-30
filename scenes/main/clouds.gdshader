shader_type canvas_item;

uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform vec4 sky_color : source_color = vec4(0.4, 0.6, 0.9, 1.0);
uniform float speed : hint_range(0.0, 0.2) = 0.02;
uniform float scale : hint_range(1.0, 20.0) = 4.0; // Lower = bigger clouds
uniform float pixel_size : hint_range(0.005, 0.1) = 0.025; // Bigger pixels = less grainy pixel art
uniform float edge_border : hint_range(0.0, 0.3) = 0.12; // Extends sampling to avoid cut-off edges

// Improved value noise (same as original but cleaner)
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f); // Smooth hermite interpolation
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fewer octaves = less grain, blockier pixel art clouds
float fbm(vec2 uv) {
    float value = 0.0;
    float amplitude = 0.5;
    value += amplitude * noise(uv); uv *= 2.0; amplitude *= 0.5;
    value += amplitude * noise(uv); uv *= 2.0; amplitude *= 0.5; // Only 2 octaves
    // value += amplitude * noise(uv); // Uncomment for subtle detail
    return value;
}

void fragment() {
    // Extend UV beyond 0-1 to spill clouds over Rect edges (no straight cut-offs!)
    vec2 extended_uv = UV * (1.0 + edge_border * 2.0) - edge_border;
    
    // Pixelate to grid (use round() for perfectly centered pixels)
    vec2 pixelated_uv = round(extended_uv / pixel_size) * pixel_size;
    
    // Scroll & scale for clouds
    vec2 uv = pixelated_uv * scale;
    uv.x += TIME * speed;
    
    // Generate puffy cloud pattern (pow for sharper bottoms, classic cloud shape)
    float density = fbm(uv * 0.8) * 0.6 + fbm(uv * 0.4) * 0.4; // Multi-layer for puffiness
    float cloud_pattern = pow(density, 1.2); // Sharper, more defined clouds
    
    // Sharp threshold for pixel art hard edges (adjust 0.35 for more/less clouds)
    float cloud_mask = step(0.35, cloud_pattern);
    
    // Mix with subtle gradient in clouds for depth
    vec4 cloud_layer = mix(cloud_color * 0.85, cloud_color, cloud_mask);
    COLOR = mix(sky_color, cloud_layer, cloud_mask);
}