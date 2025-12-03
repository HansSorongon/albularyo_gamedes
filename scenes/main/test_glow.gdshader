shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float glow_radius : hint_range(1.0, 20.0) = 8.0;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int samples : hint_range(4, 32) = 16;
uniform float fade : hint_range(0.0, 1.0) = 1.0;  // Add this for tweening!

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate glow by sampling nearby pixels
    float glow = 0.0;
    float total_weight = 0.0;
    
    // Sample in a circular pattern around the current pixel
    for(int i = 0; i < samples; i++) {
        float angle = float(i) * 6.28318 / float(samples);
        
        for(float r = 1.0; r <= glow_radius; r += 1.0) {
            vec2 offset = vec2(cos(angle), sin(angle)) * r * TEXTURE_PIXEL_SIZE;
            vec4 sample_color = texture(TEXTURE, UV + offset);
            
            // Weight falls off with distance
            float weight = (1.0 - r / glow_radius) * sample_color.a;
            glow += weight;
            total_weight += 1.0;
        }
    }
    
    glow = (glow / total_weight) * glow_intensity;
    
    // Apply glow effect
    if(tex_color.a > 0.01) {
        // Original pixel exists - enhance it with glow
        COLOR.rgb = mix(tex_color.rgb, glow_color.rgb, glow * 0.3);
        COLOR.a = tex_color.a * fade;  // Apply fade to alpha
    } else if(glow > 0.01) {
        // Transparent pixel near opaque areas - add glow
        COLOR.rgb = glow_color.rgb;
        COLOR.a = glow * fade;  // Apply fade to glow alpha
    } else {
        // Fully transparent
        COLOR = vec4(0.0);
    }
}