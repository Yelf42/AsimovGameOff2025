shader_type canvas_item;

uniform vec4 bg_colour: source_color = vec4(0.6, 0.66, 0.66, 1.0);
uniform vec4 grid_colour: source_color = vec4(0.6, 0.66, 0.66, 1.0);

uniform sampler2D GRID;
uniform vec2 grid_resize = vec2(1.0);

void fragment() {
	vec3 col = bg_colour.rgb;
	vec2 uv = (UV - vec2(0.5)) * grid_resize + vec2(0.5);
	vec4 gridCol = texture(GRID, uv);
	if (gridCol.a > 0.5) {
		col = grid_colour.rgb;
	}
	COLOR = vec4(col, 1.0);
}

