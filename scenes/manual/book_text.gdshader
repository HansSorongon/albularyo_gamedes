shader_type canvas_item;

uniform float curve_amount : hint_range(0.0, 100.0) = 20.0;

void vertex() {
	// UV.x goes from 0.0 (left) to 1.0 (right)
	// Create smooth curve from center outward
	
	if (UV.x > 0.5) {
		VERTEX.y += 1.0; 
	}
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}