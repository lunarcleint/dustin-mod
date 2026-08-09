#pragma header

uniform float time;
uniform vec2 res;
uniform float strength;

uniform vec2 handheldOffset;
uniform float handheldAngle;
uniform float handheldZoom;
uniform float focusBlur;

uniform float motionBlurAmount;
uniform float motionBlurDirection;
uniform float staticBurst;
uniform float shootBlurAmount;

float hash(float n)
{
    return fract(sin(n) * 43758.5453123);
}

float hash(vec2 p)
{
    return fract(
        sin(dot(p, vec2(127.1, 311.7))) *
        43758.5453123
    );
}

// Stable animated hash for full-screen static. Keeping both the pixel and
// frame seeds bounded avoids the all-zero result produced by some renderers
// when sin() receives the very large values used by the regular VHS hash.
float burstHash(vec2 pixel, float frame)
{
    vec2 boundedPixel = mod(pixel, vec2(1021.0));
    float boundedFrame = mod(frame, 251.0);
    vec2 seed = boundedPixel + vec2(
        boundedFrame * 17.0,
        boundedFrame * 37.0
    );

    return fract(
        52.9829189 *
        fract(dot(seed, vec2(0.06711056, 0.00583715)))
    );
}

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(
            hash(i),
            hash(i + vec2(1.0, 0.0)),
            f.x
        ),
        mix(
            hash(i + vec2(0.0, 1.0)),
            hash(i + vec2(1.0, 1.0)),
            f.x
        ),
        f.y
    );
}

mat2 rot(float angle)
{
    float s = sin(angle);
    float c = cos(angle);

    return mat2(
         c, -s,
         s,  c
    );
}

vec3 rgb2yiq(vec3 color)
{
    return mat3(
         0.299,  0.596,  0.211,
         0.587, -0.274, -0.523,
         0.114, -0.322,  0.312
    ) * color;
}

vec3 yiq2rgb(vec3 color)
{
    return mat3(
        1.000,  1.000,  1.000,
        0.956, -0.272, -1.106,
        0.621, -0.647,  1.703
    ) * color;
}

vec4 sampleScreen(vec2 uv)
{
    return flixel_texture2D(
        bitmap,
        clamp(
            uv,
            vec2(0.001),
            vec2(0.999)
        )
    );
}

void main()
{
    vec2 screenUV = openfl_TextureCoordv.xy;
    vec2 uv = screenUV;

    float t = time;
    float amount = clamp(strength, 0.0, 2.0);

    vec2 safeResolution =
        max(res, vec2(1.0));

    vec2 pixelSize =
        1.0 / safeResolution;

    vec2 handheldUV =
        screenUV - 0.5;

    handheldUV /=
        max(handheldZoom, 1.0);

    handheldUV =
        rot(handheldAngle) *
        handheldUV;

    uv =
        handheldUV +
        0.5 +
        handheldOffset;

    float slowWave =
          sin(screenUV.y * 7.0 - t * 1.9) * 0.00105
        + sin(screenUV.y * 29.0 + t * 5.4) * 0.00042
        + sin(screenUV.y * 73.0 - t * 8.5) * 0.00012;

    float randomBend =
        (
            noise(vec2(
                screenUV.y * 9.0,
                t * 0.42
            )) - 0.5
        ) * 0.00125;

    uv.x +=
        (slowWave + randomBend) *
        amount;

    float riseTime =
        t * 0.31;

    float riseCycle =
        floor(riseTime);

    float risePhase =
        fract(riseTime);

    float risePosition =
        1.10 - risePhase * 1.24;

    float risePassStrength =
        mix(
            0.45,
            1.0,
            hash(riseCycle + 41.7)
        );

    float riseDistance =
        abs(screenUV.y - risePosition);

    float riseWide =
        (
            1.0 -
            smoothstep(
                0.010,
                0.070,
                riseDistance
            )
        ) *
        risePassStrength;

    float riseMiddle =
        (
            1.0 -
            smoothstep(
                0.003,
                0.030,
                riseDistance
            )
        ) *
        risePassStrength;

    float riseCore =
        (
            1.0 -
            smoothstep(
                0.0008,
                0.008,
                riseDistance
            )
        ) *
        risePassStrength;

    float riseDirection =
        mix(
            -1.0,
            1.0,
            step(
                0.5,
                hash(riseCycle + 8.3)
            )
        );

    float riseNoise =
        noise(vec2(
            screenUV.y * 130.0 - t * 3.7,
            t * 11.0 + riseCycle * 4.2
        )) - 0.5;

    float riseFineNoise =
        noise(vec2(
            screenUV.y * 310.0 + t * 8.0,
            screenUV.x * 4.0 - t * 2.0
        )) - 0.5;

    uv.x +=
        riseWide *
        riseDirection *
        (
            0.0060 +
            riseNoise * 0.0120
        ) *
        amount;

    uv.x +=
        riseMiddle *
        riseDirection *
        0.0135 *
        amount;

    uv.x +=
        riseCore *
        (
            riseNoise * 0.0170 +
            riseFineNoise * 0.0075
        ) *
        amount;

    uv.y +=
        riseCore *
        riseFineNoise *
        0.0018 *
        amount;

    float tearTick =
        floor(t * 7.0);

    float tearEnabled =
        smoothstep(
            0.972,
            0.995,
            hash(tearTick + 71.2)
        );

    float tearPosition =
        hash(tearTick + 13.7);

    float tearMask =
        1.0 -
        smoothstep(
            0.0015,
            0.012,
            abs(screenUV.y - tearPosition)
        );

    float tearDirection =
        hash(tearTick + 91.4) - 0.5;

    uv.x +=
        tearMask *
        tearEnabled *
        tearDirection *
        0.014 *
        amount;

    float bottomMask =
        smoothstep(
            0.925,
            1.000,
            screenUV.y
        );

    float bottomNoise =
        noise(vec2(
            screenUV.y * 280.0,
            t * 22.0
        )) - 0.5;

    uv.x +=
        bottomMask *
        bottomNoise *
        0.0065 *
        amount;

    uv.y +=
        bottomMask *
        bottomNoise *
        0.0015 *
        amount;

    float chromaOffset =
          0.00105
        + riseWide * 0.0009
        + riseMiddle * 0.0023
        + riseCore * 0.0010
        + tearMask * tearEnabled * 0.0022
        + bottomMask * 0.0010;

    chromaOffset *=
        amount;

    vec2 chromaVector =
        vec2(chromaOffset, 0.0);

    vec4 centerSample =
        sampleScreen(uv);

    vec4 redSample =
        sampleScreen(
            uv +
            chromaVector +
            vec2(pixelSize.x * 0.0, 0.0)
        );

    vec4 blueSample =
        sampleScreen(
            uv -
            chromaVector -
            vec2(pixelSize.x * 0.0, 0.0)
        );

    vec4 blurLeft =
        sampleScreen(
            uv -
            vec2(pixelSize.x * 2.5, 0.0)
        );

    vec4 blurRight =
        sampleScreen(
            uv +
            vec2(pixelSize.x * 2.5, 0.0)
        );

    vec3 color =
        vec3(
            redSample.r,
            centerSample.g,
            blueSample.b
        );

    float roomBlur =
        clamp(
            motionBlurAmount,
            0.0,
            1.0
        );

    if (roomBlur > 0.001)
    {

        float direction =
            motionBlurDirection == 0.0
                ? 1.0
                : sign(motionBlurDirection);

        vec2 blurVector =
            vec2(
                direction *
                (0.010 + roomBlur * 0.070),
                0.0
            );

        vec3 roomBlurColor =
            centerSample.rgb * 0.20;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.10
            ).rgb * 0.17;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.22
            ).rgb * 0.15;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.36
            ).rgb * 0.13;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.52
            ).rgb * 0.11;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.70
            ).rgb * 0.09;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector * 0.88
            ).rgb * 0.08;

        roomBlurColor +=
            sampleScreen(
                uv + blurVector
            ).rgb * 0.07;

        roomBlurColor.r +=
            sampleScreen(
                uv + blurVector * 1.08
            ).r * 0.045 * roomBlur;

        roomBlurColor.b +=
            sampleScreen(
                uv + blurVector * 0.82
            ).b * 0.035 * roomBlur;

        color =
            mix(
                color,
                roomBlurColor,
                0.96 * roomBlur
            );
    }

    vec3 horizontalBlur =
        (
            blurLeft.rgb +
            centerSample.rgb * 2.0 +
            blurRight.rgb
        ) / 4.0;

    color =
        mix(
            color,
            horizontalBlur,
            0.045 * amount
        );

    vec3 softLeft =
        sampleScreen(
            uv -
            vec2(pixelSize.x * 1.25, 0.0)
        ).rgb;

    vec3 softRight =
        sampleScreen(
            uv +
            vec2(pixelSize.x * 1.25, 0.0)
        ).rgb;

    vec3 softUp =
        sampleScreen(
            uv -
            vec2(0.0, pixelSize.y * 1.25)
        ).rgb;

    vec3 softDown =
        sampleScreen(
            uv +
            vec2(0.0, pixelSize.y * 1.25)
        ).rgb;

    vec3 softUpperLeft =
        sampleScreen(
            uv -
            pixelSize * 0.85
        ).rgb;

    vec3 softUpperRight =
        sampleScreen(
            uv +
            vec2(
                pixelSize.x * 0.85,
                -pixelSize.y * 0.85
            )
        ).rgb;

    vec3 softLowerLeft =
        sampleScreen(
            uv +
            vec2(
                -pixelSize.x * 0.85,
                pixelSize.y * 0.85
            )
        ).rgb;

    vec3 softLowerRight =
        sampleScreen(
            uv +
            pixelSize * 0.85
        ).rgb;

    vec3 cameraBlur =
        (
            centerSample.rgb * 4.0 +
            softLeft +
            softRight +
            softUp +
            softDown +
            softUpperLeft +
            softUpperRight +
            softLowerLeft +
            softLowerRight
        ) / 12.0;

    color =
        mix(
            color,
            cameraBlur,
            0.035 * amount
        );

    float focusAmount =
        clamp(
            focusBlur,
            0.0,
            1.0
        );

    if (focusAmount > 0.001)
    {
        vec2 nearFocusRadius =
            pixelSize *
            (
                2.0 +
                focusAmount *
                8.0
            );

        vec2 farFocusRadius =
            pixelSize *
            (
                5.0 +
                focusAmount *
                16.0
            );

        vec2 radialFocusOffset =
            (
                screenUV -
                0.5
            ) *
            0.028 *
            focusAmount;

        vec3 focusColor =
            centerSample.rgb *
            2.0;

        focusColor +=
            sampleScreen(
                uv -
                vec2(
                    nearFocusRadius.x,
                    0.0
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    nearFocusRadius.x,
                    0.0
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv -
                vec2(
                    0.0,
                    nearFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    0.0,
                    nearFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv -
                nearFocusRadius
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                nearFocusRadius
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    nearFocusRadius.x,
                    -nearFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    -nearFocusRadius.x,
                    nearFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv -
                vec2(
                    farFocusRadius.x,
                    0.0
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    farFocusRadius.x,
                    0.0
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv -
                vec2(
                    0.0,
                    farFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                vec2(
                    0.0,
                    farFocusRadius.y
                )
            ).rgb;

        focusColor +=
            sampleScreen(
                uv -
                radialFocusOffset
            ).rgb;

        focusColor +=
            sampleScreen(
                uv +
                radialFocusOffset
            ).rgb;

        focusColor /=
            16.0;

        color =
            mix(
                color,
                focusColor,
                focusAmount *
                0.90
            );
    }

    float shotBlur =
        clamp(
            shootBlurAmount,
            0.0,
            1.0
        );

    if (shotBlur > 0.001)
    {
        float horizontalRadius =
            12.0 +
            shotBlur *
            82.0;

        float verticalRadius =
            8.0 +
            shotBlur *
            48.0;

        vec2 shotX =
            vec2(
                pixelSize.x *
                horizontalRadius,
                0.0
            );

        vec2 shotY =
            vec2(
                0.0,
                pixelSize.y *
                verticalRadius
            );

        vec2 shotDiagonal =
            vec2(
                shotX.x * 0.72,
                shotY.y * 0.72
            );

        float shotDirection =
            motionBlurDirection == 0.0
                ? 1.0
                : sign(motionBlurDirection);

        vec2 recoilTrail =
            vec2(
                shotDirection *
                shotX.x *
                1.35,
                -shotY.y *
                0.35
            );

        vec3 shotBlurColor =
            centerSample.rgb *
            0.16;

        shotBlurColor +=
            sampleScreen(
                uv - shotX * 0.22
            ).rgb * 0.075;

        shotBlurColor +=
            sampleScreen(
                uv + shotX * 0.22
            ).rgb * 0.075;

        shotBlurColor +=
            sampleScreen(
                uv - shotX * 0.50
            ).rgb * 0.070;

        shotBlurColor +=
            sampleScreen(
                uv + shotX * 0.50
            ).rgb * 0.070;

        shotBlurColor +=
            sampleScreen(
                uv - shotX
            ).rgb * 0.060;

        shotBlurColor +=
            sampleScreen(
                uv + shotX
            ).rgb * 0.060;

        shotBlurColor +=
            sampleScreen(
                uv - shotY * 0.55
            ).rgb * 0.060;

        shotBlurColor +=
            sampleScreen(
                uv + shotY * 0.55
            ).rgb * 0.060;

        shotBlurColor +=
            sampleScreen(
                uv - shotDiagonal
            ).rgb * 0.055;

        shotBlurColor +=
            sampleScreen(
                uv + shotDiagonal
            ).rgb * 0.055;

        shotBlurColor +=
            sampleScreen(
                uv + vec2(
                    shotDiagonal.x,
                    -shotDiagonal.y
                )
            ).rgb * 0.055;

        shotBlurColor +=
            sampleScreen(
                uv + vec2(
                    -shotDiagonal.x,
                    shotDiagonal.y
                )
            ).rgb * 0.055;

        shotBlurColor +=
            sampleScreen(
                uv + recoilTrail * 0.45
            ).rgb * 0.045;

        shotBlurColor +=
            sampleScreen(
                uv + recoilTrail
            ).rgb * 0.045;

        color =
            mix(
                color,
                shotBlurColor,
                0.985 *
                shotBlur
            );
    }

    vec3 yiq =
        rgb2yiq(color);

    vec3 leftYIQ =
        rgb2yiq(blurLeft.rgb);

    vec3 rightYIQ =
        rgb2yiq(blurRight.rgb);

    yiq.yz =
        mix(
            yiq.yz,
            (
                leftYIQ.yz +
                rightYIQ.yz
            ) * 0.5,
            0.36 * amount
        );

    float chromaRotation =
        (
            sin(
                t * 2.2 +
                screenUV.y * 8.0
            ) * 0.030
            +
            riseMiddle *
            riseNoise *
            0.15
        ) *
        amount;

    yiq.yz *=
        rot(chromaRotation);

    color =
        yiq2rgb(yiq);

    float scanline =
        0.5 +
        0.5 *
        sin(
            screenUV.y *
            safeResolution.y *
            0.30
        );

    color *=
        1.0 -
        scanline *
        0.011 *
        amount;

    float noiseFrame =
        floor(t * 30.0);

    vec2 pixelCoord =
        floor(screenUV * safeResolution);

    float fineCameraNoise =
        hash(
            pixelCoord +
            vec2(
                noiseFrame * 37.0,
                noiseFrame * 17.0
            )
        );

    float fineCameraNoise2 =
        hash(
            pixelCoord *
            vec2(0.73, 1.31) +
            vec2(
                noiseFrame * 11.0,
                noiseFrame * 53.0
            )
        );

    vec2 coarseCoord =
        floor(
            screenUV *
            safeResolution *
            0.32
        );

    float coarseCameraNoise =
        hash(
            coarseCoord +
            vec2(
                noiseFrame * 23.0,
                noiseFrame * 41.0
            )
        );

    float horizontalCameraNoise =
        hash(vec2(
            floor(
                screenUV.y *
                safeResolution.y *
                0.75
            ),
            noiseFrame * 29.0
        ));

    float cameraNoise =
          (fineCameraNoise - 0.5) * 0.013
        + (fineCameraNoise2 - 0.5) * 0.0055
        + (coarseCameraNoise - 0.5) * 0.0065
        + (horizontalCameraNoise - 0.5) * 0.0035;

    color +=
        cameraNoise *
        amount;

    float streak =
        noise(vec2(
            screenUV.y * 190.0 - t * 2.0,
            t * 17.0
        ));

    color +=
        (streak - 0.5) *
        0.008 *
        amount;

    float relativePixelY =
        (
            screenUV.y -
            risePosition
        ) *
        safeResolution.y;

    float movingStripeA =
        abs(
            sin(
                relativePixelY * 0.58 -
                t * 19.0
            )
        );

    float movingStripeB =
        abs(
            sin(
                relativePixelY * 0.21 +
                t * 11.0
            )
        );

    float thinStripe =
        pow(
            1.0 - movingStripeA,
            10.0
        );

    float broadStripe =
        pow(
            1.0 - movingStripeB,
            7.0
        );

    float breakupNoise =
        noise(vec2(
            screenUV.x * 43.0 - t * 4.5,
            relativePixelY * 0.11 + t * 3.3
        ));

    float fineBreakup =
        noise(vec2(
            screenUV.x * 105.0 + t * 7.0,
            relativePixelY * 0.28 - t * 5.0
        ));

    float animatedBreakup =
        smoothstep(
            0.45,
            0.77,
            breakupNoise
        );

    animatedBreakup *=
        mix(
            0.40,
            1.0,
            smoothstep(
                0.35,
                0.75,
                fineBreakup
            )
        );

    float trackingLines =
        riseWide *
        (
            thinStripe * 0.65 +
            broadStripe * 0.22
        ) *
        animatedBreakup;

    float coreBreakup =
        smoothstep(
            0.37,
            0.73,
            noise(vec2(
                screenUV.x * 64.0 - t * 6.0,
                riseCycle * 9.0 +
                t * 2.5
            ))
        );

    float trackingCore =
        riseCore *
        coreBreakup;

    float trackingBrightness =
        clamp(
            trackingCore * 0.24 +
            trackingLines * 0.19,
            0.0,
            0.29
        ) *
        amount;

    vec3 trackingColor =
        vec3(
            0.84,
            0.86,
            0.88
        );

    color =
        mix(
            color,
            trackingColor,
            trackingBrightness
        );

    float trackingShadow =
        (
            1.0 -
            smoothstep(
                0.002,
                0.017,
                abs(
                    screenUV.y -
                    risePosition -
                    0.009
                )
            )
        ) *
        risePassStrength;

    color *=
        1.0 -
        trackingShadow *
        0.10 *
        amount;

    float snowTick =
        floor(t * 20.0);

    float snowLine =
        floor(
            screenUV.y *
            safeResolution.y *
            0.55
        );

    float snowChance =
        smoothstep(
            0.982,
            0.999,
            hash(vec2(
                snowLine,
                snowTick
            ))
        );

    float snowBreakup =
        smoothstep(
            0.55,
            0.82,
            noise(vec2(
                screenUV.x * 61.0 + t * 12.0,
                snowLine * 0.17 - t * 3.0
            ))
        );

    float snowIntensity =
        snowChance *
        snowBreakup *
        0.10 *
        amount;

    color =
        mix(
            color,
            vec3(0.78, 0.80, 0.82),
            snowIntensity
        );

    float randomLine =
        hash(vec2(
            floor(
                screenUV.y *
                safeResolution.y *
                0.50
            ),
            floor(t * 29.0)
        ));

    float lineNoise =
        smoothstep(
            0.94,
            1.0,
            randomLine
        );

    float linePolarity =
        hash(
            floor(
                screenUV.y *
                safeResolution.y
            ) +
            floor(t * 17.0)
        ) - 0.5;

    color +=
        lineNoise *
        linePolarity *
        0.032 *
        amount;

    color *=
        0.993 +
        0.007 *
        sin(t * 47.0);

    color *=
        1.0 +
        riseWide *
        0.018 *
        amount;

    float luma =
        dot(
            color,
            vec3(
                0.299,
                0.587,
                0.114
            )
        );

    color =
        mix(
            vec3(luma),
            color,
            0.94
        );

    vec2 centered =
        screenUV - 0.5;

    vec2 aspect =
        vec2(
            safeResolution.x /
            safeResolution.y,
            1.0
        );

    float edge =
        smoothstep(
            0.42,
            0.95,
            length(centered * aspect)
        );

    color *=
        1.0 -
        edge *
        0.045 *
        amount;

    float burstAmount =
        clamp(
            staticBurst,
            0.0,
            1.0
        );

    if (burstAmount > 0.001)
    {
        float burstFrame =
            floor(t * 60.0);

        vec2 burstPixel =
            floor(
                screenUV *
                safeResolution
            );

        float burstNoiseA =
            burstHash(
                burstPixel,
                burstFrame
            );

        float burstNoiseB =
            burstHash(
                burstPixel *
                vec2(
                    0.47,
                    1.39
                ) +
                vec2(17.0, 53.0),
                burstFrame + 83.0
            );

        float burstNoiseC =
            burstHash(
                burstPixel *
                vec2(
                    1.71,
                    0.63
                ) +
                vec2(71.0, 29.0),
                burstFrame + 167.0
            );

        float burstLine =
            burstHash(
                vec2(
                    floor(
                        screenUV.y *
                        safeResolution.y *
                        0.72
                    ),
                    0.0
                ),
                burstFrame + 41.0
            );

        float burstChecker =
            mod(
                floor(burstPixel.x * 0.5) +
                floor(burstPixel.y * 0.5) +
                burstFrame,
                2.0
            );

        float burstSnow =
            clamp(
                0.08 +
                burstNoiseA * 0.55 +
                burstNoiseB * 0.25 +
                burstLine * 0.12 +
                burstChecker * 0.18,
                0.0,
                1.0
            );

        vec3 burstColor =
            vec3(burstSnow);

        burstColor.r =
            clamp(
                burstColor.r +
                (burstNoiseB - 0.5) *
                0.24,
                0.0,
                1.0
            );

        burstColor.b =
            clamp(
                burstColor.b +
                (burstNoiseC - 0.5) *
                0.24,
                0.0,
                1.0
            );

        float burstMix =
            clamp(
                burstAmount *
                1.18,
                0.0,
                1.0
            );

        color =
            mix(
                color,
                burstColor,
                burstMix
            );

        color +=
            (burstNoiseA - 0.5) *
            0.18 *
            burstAmount;
    }

    color =
        clamp(
            color,
            0.0,
            1.0
        );

    gl_FragColor =
        vec4(
            color,
            centerSample.a
        );
}
