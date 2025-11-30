shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(1.0,1.0))) * 1.0);
}

vec3 chromatic_abberation(float offset, vec2 uv) {
	float r = texture(screen_texture, uv + offset * vec2(0.001,0.001)).r;
	float g = texture(screen_texture, uv + offset * vec2(0.0,-0.001)).g;
	float b = texture(screen_texture, uv + offset * vec2(-0.001,0.0)).b;
	return vec3(r,g,b);
}

void fragment() {
	vec2 local_uv = UV;
	vec2 screen_uv = SCREEN_UV;
	
	float r = mod(TIME * 0.5, 1.0);
	
	// Calculate distortion based on local UV
	vec2 distorted_uv = screen_uv;
	if (abs(local_uv.y - r) < 0.05) {
		float distortion = 0.05 * pow(0.05 - abs(local_uv.y - r), 1.2);
		distorted_uv.x += distortion;
	}
	
	// Clamp sampling to this ColorRect's screen space bounds
	vec2 rect_min = SCREEN_UV - UV;  // Top-left corner in screen space
	vec2 rect_max = rect_min + vec2(1.0, 1.0);  // Bottom-right corner
	distorted_uv = clamp(distorted_uv, rect_min, rect_max);
	
	float s = sin(800.0 * local_uv.x) / 50.0;
	COLOR = vec4(chromatic_abberation(2.0, distorted_uv) - s, 1.0);
}
