shader_type canvas_item;

uniform vec2 resolution = vec2(1152, 648);
uniform int numBlockers;
uniform vec3[5] blockerData;

float ball(vec2 p, float r) {
    return (r*r) / max(dot(p,p), 0.00001);
}

void fragment() {
	vec2 puv = UV * resolution;
	float result = 0.0;

	float minDist = 1e20;
	for (int i = 0; i < numBlockers; i++) {
		vec2 pos = blockerData[i].xy;
		minDist = min(length(puv - pos) - blockerData[i].z, minDist);
	}

	minDist += 15.0;
	float is_outside = step(0.0, minDist);
    float in_band = step(minDist, 15.0);
    float alpha = is_outside * in_band;
    COLOR = vec4(vec3(1.0), alpha);
}
