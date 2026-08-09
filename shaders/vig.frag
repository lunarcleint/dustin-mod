#pragma header

uniform float amount;   // darkness, 0..1
uniform float radius;   // where it starts fading, ~0.5..0.9
uniform float softness; // edge blur, ~0.2..0.6

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
    vec2 uv = openfl_TextureCoordv.xy - 0.5;
    float d = length(uv);
    float v = smoothstep(radius, radius - softness, d);
    color.rgb *= mix(1.0 - amount, 1.0, v);
    gl_FragColor = color;
}