shader_type canvas_item;

// Progress from 0.0 (no color) to 1.0 (fully colored)
uniform float progress : hint_range(0.0, 5.0) = 0.0;

// Fade from 0.0 (original color) to 1.0 (gold color)
uniform float fade : hint_range(0.0, 1.0) = 1.0;

// Golden yellow color
uniform vec4 gold_color : source_color = vec4(1.0, 0.843, 0.0, 1.0); // #FFD700

// Pixel art settings
uniform float pixel_size = 0.004; // Adjust for your sprite size
uniform float blend_steps = 8.0; // Lower = more pixelated/saturated

void fragment() {
	// Snap UV to pixel grid for pixel art look
	vec2 snapped_uv = floor(UV / pixel_size) * pixel_size;
	
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Calculate distance from center using snapped UVs
	vec2 center = vec2(0.49, 0.44);
	float dist = distance(snapped_uv, center);
	
	// Normalize distance (0.0 at center, 1.0 at edges)
	float normalized_dist = dist / 0.707;
	
	// Create mask based on progress
	float mask = clamp(1.0 - (normalized_dist / progress), 0.0, 1.0);
	
	// Quantize the mask for stepped pixel art effect
	mask = floor(mask * blend_steps) / blend_steps;
	
	// Apply fade to the mask (fade controls overall gold intensity)
	mask *= fade;
	
	// Mix original texture with gold color
	vec3 final_color = mix(tex_color.rgb, gold_color.rgb, mask);
	
	COLOR = vec4(final_color, tex_color.a);
}