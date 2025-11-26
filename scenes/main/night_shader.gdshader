shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

uniform vec4 day_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec4 night_tint : source_color = vec4(0.3, 0.4, 0.7, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 tint = mix(day_tint, night_tint, progress);
    COLOR = vec4(tex_color.rgb * tint.rgb, tex_color.a);
}