#pragma header

const float PI = 3.141592653589793;

uniform vec4 frameUV;
uniform vec2 frameSize;
uniform int frameAngle;

uniform float skewWidth;
uniform float cutOffY;

uniform float time;
uniform vec2 waveStrength;
uniform float waveSpeed;
uniform float waveCount;

uniform bool boldSkewWidth;

float rand(vec2 n) { return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);}
float noise(vec2 n) {
const vec2 d = vec2(0.0, 1.0);
vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

vec4 frameTexture2D(vec2 uv) {
	if (abs(uv.x - 0.5) > 0.5 || abs(uv.y - 0.5) > 0.5) return vec4(0.0);

	vec2 projectedUV;
	if (frameAngle == 90) projectedUV = mix(frameUV.xy, frameUV.zw, vec2(uv.y, 1.0 - uv.x));
	if (frameAngle == -90) projectedUV = mix(frameUV.xy, frameUV.zw, vec2(1.0 - uv.y, uv.x));
	else if (frameAngle == 180) projectedUV = mix(frameUV.xy, frameUV.zw, 1.0 - uv);
	else projectedUV = mix(frameUV.xy, frameUV.zw, uv);

	return texture2D(bitmap, projectedUV);
}

void main() {
	vec2 mainUV = (openfl_TextureCoordv - 0.5) * (waveStrength * 0.5 + 1.0) + 0.5;

	float cutY = 1.0 - cutOffY;
	if (mainUV.y > cutY) discard;
	/*if (mainUV.y > cutY) {
		gl_FragColor = vec4(vec3(1.0, 0.0, 0.0), 1.0);
		return;
	}
	else {
		vec2 uv = mainUV - 0.5;
		float minw = 1.0 - (skewWidth / frameSize.x);
		uv.x /= minw + ((cutY - mainUV.y) / cutY) * (1.0 - minw);
		if (abs(uv.x) > 0.5 || abs(uv.y) > 0.5) {
			gl_FragColor = vec4(vec3(0.25, 0.0, 0.0), 0.25);
			return;
		}
		uv += 0.5;

		gl_FragColor = vec4(vec3(0.0, 0.0, 0.0), 1.0);
		return;
	}*/

	float widthStuff = skewWidth / frameSize.x;
	float shadow = 0.0;

	vec2 uv = mainUV - 0.5;
	uv.x /= 1.0 - widthStuff + ((cutY - mainUV.y) / cutY) * widthStuff;
	if (abs(uv.x) > 0.5) discard;

	float wave = time * waveSpeed;
	vec2 waveUV = vec2(
		noise(vec2(openfl_TextureCoordv.x + time * waveSpeed, openfl_TextureCoordv.y) * waveCount),
		noise(vec2(-openfl_TextureCoordv.y, openfl_TextureCoordv.x - time * waveSpeed) * waveCount)
	) * waveStrength;

	// bolden the width stuff
	if (boldSkewWidth) {
		float num = floor((skewWidth / 8.0) + 0.5);
		float yShit = cutY - mainUV.y;
		for (int pass = 0; pass < num; pass++) {
			float v = pass / num;

			uv = mainUV - vec2(0.5, 1.0);
			uv.x *= 1.0 + widthStuff;
			uv.x += widthStuff * (-0.5 + v) * yShit;
			uv.y /= sin((0.375 + v * 0.3125) * PI) * 0.5 + 0.5;
			uv += waveUV * yShit + vec2(0.5, 1.0);

			shadow += frameTexture2D(uv).a;
		}
		shadow = min(shadow * pow(yShit, 0.5), 1.0);
	}
	else {
		shadow = frameTexture2D(uv + waveUV * (cutY - mainUV.y) + 0.5).a;
	}

	if (shadow == 0.0) discard;
	//gl_FragColor = vec4(vec3(0.0), shadow);
	gl_FragColor = applyFlixelEffects(vec4(vec3(1.0), shadow));
}