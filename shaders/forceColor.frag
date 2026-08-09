#pragma header

uniform bool forceColors;
uniform vec4 colors;

void main() {
	// Get the texture to apply to.
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

	if (forceColors) {
		if (colors[0] != -1.0)
			color.r = colors[0];
		if (colors[1] != -1.0)
			color.g = colors[1];
		if (colors[2] != -1.0)
			color.b = colors[2];
		if (colors[3] != -1.0)
			color.a = colors[3];
	}
	
	// Cap the color values.
	color = min(color, vec4(1.0, 1.0, 1.0, 1.0));

  	// Return the value.
	gl_FragColor = color;
}