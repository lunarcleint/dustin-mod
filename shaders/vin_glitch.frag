#pragma header
#pragma stage frag

uniform float time;
uniform vec2 resolution;

float sat(float t) {
	return clamp(t, 0.0, 1.0);
}

vec2 sat(vec2 t) {
	return clamp(t, 0.0, 1.0);
}

float remap(float t, float a, float b) {
	return sat((t - a) / (b - a));
}

float linterp(float t) {
	return sat(1.0 - abs(2.0 * t - 1.0));
}

vec3 spectrum_offset(float t) {
	vec3 ret;
	float lo = step(t, 0.5);
	float hi = 1.0 - lo;
	float w = linterp(remap(t, 1.0 / 6.0, 5.0 / 6.0));
	float neg_w = 1.0 - w;
	ret = vec3(lo, 1.0, hi) * vec3(neg_w, w, neg_w);
	return ret; // no gamma correction
}

float rand(vec2 n) {
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float srand(vec2 n) {
	return rand(n) * 2.0 - 1.0;
}

float mytrunc(float x, float num_levels) {
	return floor(x * num_levels) / num_levels;
}

vec2 mytrunc(vec2 x, float num_levels) {
	return floor(x * num_levels) / num_levels;
}

void main() {
	vec2 fragCoord = openfl_TextureCoordv * resolution;
	vec2 uv = fragCoord / resolution;

	float t = mod(time * 100.0, 32.0) / 110.0;
	float GLITCH = 0.1 + resolution.x;

	float gnm = sat(GLITCH);
	float rnd0 = rand(mytrunc(vec2(t, t), 6.0));
	float r0 = sat((1.0 - gnm) * 0.7 + rnd0);
	float rnd1 = rand(vec2(mytrunc(uv.x, 10.0 * r0), t));
	float r1 = 1.0 - max(0.0, ((0.5 - 0.5 * gnm + rnd1) < 1.0 ? (0.5 - 0.5 * gnm + rnd1) : 0.9999999));
	float rnd2 = rand(vec2(mytrunc(uv.y, 40.0 * r1), t));
	float r2 = sat(rnd2);
	float rnd3 = rand(vec2(mytrunc(uv.y, 10.0 * r0), t));
	float r3 = (1.0 - sat(rnd3 + 0.8)) - 0.1;
	float pxrnd = rand(uv + t);

	float ofs = 0.01 * r2 * GLITCH * (rnd0 > 0.5 ? 1.0 : -1.0);
	ofs += 0.2 * pxrnd * ofs;

	uv.y += 0.02 * r3 * GLITCH;

	const int NUM_SAMPLES = 20;
	const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);

	vec4 sum = vec4(0.0);
	vec3 wsum = vec3(0.0);
	vec2 uv0 = uv; // original uv

	for (int i = 0; i < NUM_SAMPLES; ++i) {
		float it = float(i) * RCP_NUM_SAMPLES_F;
		vec2 sampleUV = uv0;
		sampleUV.x = sat(sampleUV.x + ofs * it);
		
		vec4 samplecol = flixel_texture2D(bitmap, sampleUV);
		vec3 s = spectrum_offset(it);
		samplecol.rgb *= s;
		sum.rgb += samplecol.rgb;
		wsum += s;
	}

	sum.rgb /= wsum;
	sum.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;

	gl_FragColor = vec4(sum.rgb, sum.a);
}
