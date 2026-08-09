#pragma header

uniform bool flip;

// The add blend mode adds the source and destination colors.

varying vec2 vBlurCoords[7];

void main() {
	// Get the texture to apply to.
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

/*
	color += flixel_texture2D(bitmap, vBlurCoords[0]) * 0.00443;
	color += flixel_texture2D(bitmap, vBlurCoords[1]) * 0.05399;
	color += flixel_texture2D(bitmap, vBlurCoords[2]) * 0.24197;
	color += flixel_texture2D(bitmap, vBlurCoords[3]) * 0.39894;
	color += flixel_texture2D(bitmap, vBlurCoords[4]) * 0.24197;
	color += flixel_texture2D(bitmap, vBlurCoords[5]) * 0.05399;
	color += flixel_texture2D(bitmap, vBlurCoords[6]) * 0.00443;*/

	/*if (!flip && (color.r <= 0.01 && color.g <= 0.001 && color.b <= 0.01)) {
		gl_FragColor = color;
	} else if (flip && (color.r >= 0.0 && color.g >= 0.0 && color.b >= 0.0)) {
		gl_FragColor = color;
	}*/

	/*if (color.a >= 0.0 && color.b != 0.0) {
		if (color.r >= 0.9) // RED EYES
			color.a = 2.0;
		else if (color.b <= 0.2 && color.r <= 0.05) // shaded skull
			color.a = 2.0;
		else if (color.b <= 0.35 && color.g >= 0.18 && color.r <= 0.35) // skull
			color.a = 2.0;
		else {
			color.a *= 0.85;
			color.r *= 0.75;
			color.g *= 0.75;
			color.b *= 0.75;
		}
		//if (color.r <= 0.35 && color.g >= 0.3)
		//if (color.r <= 0.05)
			//color.a *= 10.0;
		gl_FragColor = color;
	} //else gl_FragColor = color*/
	/*else if (color.r >= 0.01) {
		color.a *= 0.5;
	}*/
	gl_FragColor = color;
}