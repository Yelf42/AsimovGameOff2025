shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(1.0,1.0))) * 1.0);
}

vec3 chromatic_abberation(float offset, vec2 uv) {
	float r = texture(screen_texture, uv + offset * vec2(0.001,0.001)).r;
	float g = texture(screen_texture, uv + offset * vec2(0.0,-0.001)).g;
	float b = texture(screen_texture, uv + offset * vec2(-0.001,0.0)).b;
	return vec3(r,g,b);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float r = (sin(TIME) + 1.0) / 2.0;
	r = mod(TIME * 0.5,1);
	if (abs(uv.y - r) < 0.05) {
		uv.x += 0.05 * pow(0.05 - abs(uv.y - r), 1.2);
	}
	float s = sin(800.0 * uv.x) / 50.0;
	COLOR = vec4(chromatic_abberation(2.0, uv) - s, 1.0);
}
