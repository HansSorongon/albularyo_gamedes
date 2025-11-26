shader_type canvas_item;
// Debug mode to see the raw flame shape
uniform bool debug = false;
// Number of color bands in the flame (3-4 recommended for pixel art)
uniform int pallet_size = 4;
// Flame shape controls
uniform float flame_height = 1.0; // How tall the flame is
uniform float flame_width = 0.7; // How wide the flame is (increased for more body)
uniform float flame_taper = 1.2; // How much it tapers at top (lower = more body)
uniform float flame_flicker = 0.2; // How much the flame flickers
uniform float step_frequency = 8.0; // How "choppy" the animation is (higher = more steps)
uniform float scroll_speed = 0.1; // How fast it actually moves
// Noise texture for flame animation (use low-res noise for pixel art)
uniform sampler2D noise_tex: filter_nearest, repeat_enable;
// Flame colors (from hottest/center to coolest/outer) - pixel art palette
uniform vec4 flame_0: source_color = vec4(1.0, 1.0, 0.8, 1.0); // Bright yellow core
uniform vec4 flame_1: source_color = vec4(1.0, 0.7, 0.2, 1.0); // Orange
uniform vec4 flame_2: source_color = vec4(0.9, 0.3, 0.1, 1.0); // Red-orange
uniform vec4 flame_3: source_color = vec4(0.6, 0.2, 0.1, 0.8); // Dark red edge
uniform vec4 flame_4: source_color = vec4(0.4, 0.1, 0.0, 0.3); // Very dark edge
// Brightness thresholds for each color band (tuned for 16x16)
uniform float thresh_f0 = 0.05;
uniform float thresh_f1 = 0.15;
uniform float thresh_f2 = 0.3;
uniform float thresh_f3 = 0.5;
uniform float thresh_f4 = 0.7;
void fragment() {
	// Snap to pixel grid for crisp pixel art
	vec2 pixel_uv = floor(UV / TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE;
	// Center the UV coordinates
	vec2 uv = pixel_uv;
	uv.x = (uv.x - 0.5) * 2.0; // Range from -1 to 1
	uv.y = 1.0 - uv.y; // Flip Y so flame goes upward
	// Create small candle flame shape (optimized for 16x16)
	// Classic candle flame: rounded bottom, pointed top
	// Vertical gradient: strong at bottom (y=0), weak at top (y=1)
	float vertical_strength = 1.0 - uv.y; // Bottom (0) = 1.0, Top (1) = 0.0
	vertical_strength = pow(vertical_strength, 1.0 / flame_height); // Control height
	// Taper the width as we go up (uv.y increases going up)
	float width_at_height = mix(flame_width, flame_width * 0.15, pow(uv.y, flame_taper));
	float horizontal_falloff = 1.0 - (abs(uv.x) / width_at_height);
	horizontal_falloff = max(0.0, horizontal_falloff);
	// Combine for final shape
	float base_flame = vertical_strength * horizontal_falloff * 1.5;
	// Add pixel-stepped animation for flickering
	float time_step = floor(TIME * step_frequency) / step_frequency;
	vec2 noise_uv = vec2(pixel_uv.x * 0.5, pixel_uv.y * 0.8 + time_step * scroll_speed);
	vec4 noise_color = texture(noise_tex, noise_uv);
	float noise_val = (noise_color.r + noise_color.g + noise_color.b) / 3.0;
	// Apply noise to create flickering effect
	float flicker = (noise_val - 0.5) * flame_flicker;
	base_flame += flicker;
	// Add secondary noise for detail
	vec2 detail_uv = vec2(pixel_uv.x * 2.0, pixel_uv.y * 1.5 + time_step * scroll_speed * 1.5);
	vec4 detail_noise = texture(noise_tex, detail_uv);
	float detail_val = (detail_noise.r + detail_noise.g + detail_noise.b) / 3.0;
	base_flame += (detail_val - 0.5) * 0.08;
	// Clamp the result
	float map_lum = clamp(base_flame, 0.0, 1.0);
	// Apply color bands based on luminance thresholds (inverted logic - higher values = hotter)
	if (map_lum > thresh_f4 && pallet_size >= 1) {
		COLOR = flame_0;
	} else if (map_lum > thresh_f3 && pallet_size >= 2) {
		COLOR = flame_1;
	} else if (map_lum > thresh_f2 && pallet_size >= 3) {
		COLOR = flame_2;
	} else if (map_lum > thresh_f1 && pallet_size >= 4) {
		COLOR = flame_3;
	} else if (map_lum > thresh_f0 && pallet_size >= 5) {
		COLOR = flame_4;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent background
	}
	// Debug mode shows the raw luminance map
	if (debug) {
		COLOR = vec4(vec3(map_lum), 1.0);
	}
}