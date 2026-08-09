#pragma header

uniform float amount;

void main()
{
    vec2 uv =
        openfl_TextureCoordv.xy;

    vec4 source =
        flixel_texture2D(
            bitmap,
            uv
        );

    float exposureAmount =
        clamp(
            amount,
            0.0,
            1.0
        );

    vec3 boosted =
        source.rgb *
        (
            1.0 +
            exposureAmount *
            6.5
        );

    boosted =
        pow(
            max(
                boosted,
                vec3(0.0)
            ),
            vec3(
                1.0 /
                (
                    1.0 +
                    exposureAmount *
                    1.65
                )
            )
        );

    vec3 flashTint =
        vec3(
            1.0,
            0.985,
            0.94
        );

    boosted =
        mix(
            boosted,
            flashTint,
            exposureAmount *
            0.32
        );

    vec3 finalColor =
        mix(
            source.rgb,
            clamp(
                boosted,
                0.0,
                1.0
            ),
            exposureAmount
        );

    gl_FragColor =
        vec4(
            finalColor,
            source.a
        );
}
