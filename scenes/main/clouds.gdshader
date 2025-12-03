shader_type canvas_item;

uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform vec4 sky_color : source_color = vec4(0.4, 0.6, 0.9, 1.0);
uniform float speed : hint_range(0.0, 0.2) = 0.02;
uniform float scale : hint_range(1.0, 20.0) = 4.0;
uniform float pixel_size : hint_range(0.005, 0.1) = 0.025;
uniform float edge_border : hint_range(0.0, 0.3) = 0.12;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.15; // Controls fade smoothness
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.8; // How much to fade edges

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
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 uv) {
    float value = 0.0;
    float amplitude = 0.5;
    value += amplitude * noise(uv); uv *= 2.0; amplitude *= 0.5;
    value += amplitude * noise(uv);
    return value;
}

void fragment() {
    // Extend UV beyond 0-1 to spill clouds over Rect edges
    vec2 extended_uv = UV * (1.0 + edge_border * 2.0) - edge_border;
    
    // Pixelate to grid
    vec2 pixelated_uv = round(extended_uv / pixel_size) * pixel_size;
    
    // Scroll & scale for clouds
    vec2 uv = pixelated_uv * scale;
    uv.x += TIME * speed;
    
    // Generate puffy cloud pattern
    float density = fbm(uv * 0.8) * 0.6 + fbm(uv * 0.4) * 0.4;
    float cloud_pattern = pow(density, 1.2);
    
    // Sharp threshold for pixel art hard edges
    float cloud_mask = step(0.35, cloud_pattern);
    
    // Mix with subtle gradient in clouds for depth
    vec4 cloud_layer = mix(cloud_color * 0.85, cloud_color, cloud_mask);
    vec4 cloud_result = mix(sky_color, cloud_layer, cloud_mask);
    
    // Create circular/radial fade at edges
    vec2 center = UV - vec2(0.5);
    float dist = length(center);
    float vignette = smoothstep(0.5, 0.5 - edge_softness, dist);
    vignette = mix(1.0, vignette, vignette_strength);
    
    COLOR = cloud_result;
    COLOR.a *= vignette; // Apply radial fade to alpha
}