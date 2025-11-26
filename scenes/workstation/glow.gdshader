shader_type canvas_item;

uniform float time : hint_range(0, 1000);
uniform vec4 glow_color = vec4(1.0, 0.6, 0.3, 1.0);
uniform float radius = 50.0;

void fragment() {
    vec2 uv = FRAGCOORD.xy - vec2(0.0, 0.0); // center at your node position
    float dist = length(uv);
    
    // pulse using sine
    float alpha = glow_color.a * smoothstep(radius, 0.0, dist) * (0.8 + 0.2 * sin(time * 5.0));
    
    COLOR = vec4(glow_color.rgb, alpha);
}
