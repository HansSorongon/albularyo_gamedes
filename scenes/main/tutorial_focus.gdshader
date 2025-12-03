shader_type canvas_item;

// Vignette parameters
uniform float radius:    hint_range(0.0, 1.0) = 0.22;
uniform float softness:  hint_range(0.0, 1.0) = 0.38;
uniform float intensity: hint_range(0.0, 3.0) = 2.00;
uniform float contrast:  hint_range(0.5, 4.0) = 2.20;
uniform vec4 vignette_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Center offset and size controls
uniform vec2 center_offset = vec2(0.0, 0.0);  // XY offset from center
uniform vec2 clear_area_size = vec2(1.0, 1.0);  // Width and height scale of clear area

// Pixel art edge controls
uniform float pixel_size: hint_range(0.001, 0.02) = 0.004;
uniform float blend_steps: hint_range(2.0, 16.0) = 8.5;

// Optional noise texture for organic edges
uniform sampler2D noiseTexture;
uniform float noise_strength: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Snap UV coordinates to pixel grid
    vec2 snapped_uv = floor(SCREEN_UV / pixel_size) * pixel_size;
    
    // Calculate shape from snapped coordinates with offset center
    vec2 centered = snapped_uv - (vec2(0.5) + center_offset);
    
    // Apply independent scaling to width and height
    vec2 scaled_centered = centered / clear_area_size;
    
    float edge_box = max(abs(scaled_centered.x) * 2.0, abs(scaled_centered.y) * 2.0);
    float edge_radial = length(scaled_centered) * 2.0;
    float shape = mix(edge_box, edge_radial, 0.25);
    
    // Optional noise for organic/burned edges
    float noise = 0.0;
    if (noise_strength > 0.0) {
        noise = texture(noiseTexture, snapped_uv).r * noise_strength * 0.2;
    }
    shape += noise;
    
    // Calculate base vignette
    float v = smoothstep(radius, radius + softness, shape);
    v = pow(v, contrast);
    
    // Posterize to discrete steps (pixel art banding)
    float mask = floor(v * blend_steps) / blend_steps;
    
    // Apply intensity
    vec4 overlay = vignette_color;
    overlay.a = clamp(mask * intensity, 0.0, 1.0);
    
    COLOR = overlay;
}