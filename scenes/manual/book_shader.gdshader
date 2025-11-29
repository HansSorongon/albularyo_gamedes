shader_type canvas_item;

// Dark brown color you can customize (default: #3d2817)
uniform vec4 brown_tint : source_color = vec4(0.239, 0.157, 0.090, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Convert to grayscale using luminosity method
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Apply brown tint to the grayscale
    vec3 tinted = vec3(gray) * brown_tint.rgb;
    
    // Keep original alpha
    COLOR = vec4(tinted, tex_color.a);
}