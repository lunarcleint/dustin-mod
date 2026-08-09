#pragma header

uniform float amount;

void main()
{
    vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec3 overlayWhite = mix(
        source.rgb * 2.0,
        vec3(1.0),
        step(vec3(0.5), source.rgb)
    );

    source.rgb = mix(
        source.rgb,
        clamp(overlayWhite, 0.0, 1.0),
        clamp(amount, 0.0, 1.0)
    );

    gl_FragColor = source;
}
