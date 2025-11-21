shader_type canvas_item;

uniform vec4 outline_color: source_color = vec4(0.6, 0.66, 0.66, 1.0);

uniform vec4 inside_color1: source_color = vec4(0.6, 0.66, 0.66, 1.0);
uniform vec4 inside_color2: source_color = vec4(0.6, 0.66, 0.66, 1.0);

uniform vec2 resolution = vec2(1152, 648);
uniform int numBlockers;
uniform vec3[5] blockerData;

vec3 hash3( vec2 p ){
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453 + + TIME*0.01);
}

float iqnoise( in vec2 x, float u, float v ){
    vec2 p = floor(x);
    vec2 f = fract(x);
		
	float k = 1.0+63.0*pow(1.0-v,4.0);
	
	float va = 0.0;
	float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
		vec3 o = hash3( p + g )*vec3(u,u,1.0);
		vec2 r = g - f + o.xy;
		float d = dot(r,r);
		float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
		va += o.z*ww;
		wt += ww;
    }
	
    return va/wt;
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
	
	vec3 col = outline_color.rgb;
	
	if (is_outside > 0.0) {
		// Outline
		COLOR = vec4(outline_color.rgb, in_band);
	} else {
		// Inside
		// Vector noise, rounded to closest third
		float shade = floor(iqnoise(UV * 20.0 * (resolution.x / resolution.y), 1.0, 0.0) * 4.0) / 4.0;
		vec3 inside_col = outline_color.rgb;
		if (shade < 0.3) {
			inside_col = inside_color1.rgb;
		} else if (shade < 0.6) {
			inside_col = inside_color2.rgb;
		}
		COLOR = vec4(inside_col, in_band);
	}
}
