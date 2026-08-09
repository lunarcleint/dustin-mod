#pragma header

uniform float strength;
uniform float threshold;
uniform vec4 tint;
uniform float gradientY;
uniform float gradientHeight;

void main() {
	vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (col.a == 0.0) discard;

	if (strength != 0.0)
	{
		float shadowBrightness = dot(tint.rgb, vec3(0.2126, 0.7152, 0.0722));
		float brightness = (dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * (1.0 + shadowBrightness)) + threshold - shadowBrightness;

		vec3 color = mix(mix(col.rgb, min(tint.rgb, col.rgb), tint.a), col.rgb, min(pow(brightness, 1.0 + strength) - threshold, 1.0));

		col.rgb = mix(col.rgb, color, min(mix(0.0, strength, min(max((openfl_TextureCoordv.y - gradientY) / gradientHeight, 0.0), 1.0)), 1.0));
	}

	gl_FragColor = col;
}