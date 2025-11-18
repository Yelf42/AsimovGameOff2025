shader_type canvas_item;

uniform vec4 bg_color: source_color = vec4(0.6, 0.66, 0.66, 1.0);

uniform sampler2D GRID;
uniform float grid_intesnsity = 0.1;
uniform vec2 grid_resize = vec2(1.0);

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

float vignette(vec2 uv){
    uv *= 1.0 - uv.xy;
    float vignette = uv.x * uv.y * 15.0;
    return pow(vignette, vignette_intensity * vignette_opacity);
}

void fragment() {
	vec3 col = bg_color.rgb;
	vec2 uv = (UV - vec2(0.5)) * grid_resize + vec2(0.5);
	vec4 gridCol = texture(GRID, uv);
	if (gridCol.a > 0.5) {
		col -= vec3(grid_intesnsity);
	}
	COLOR = vec4(col - (1.0 - vignette(UV)), 1.0);
}

