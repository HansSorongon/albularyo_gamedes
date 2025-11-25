shader_type canvas_item;

uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 current_color = COLOR;
	COLOR.rgb = current_color.rgb * fade;
	COLOR.a = current_color.a;
}