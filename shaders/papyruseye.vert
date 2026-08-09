#pragma header

uniform vec2 uRadius;
varying vec2 vBlurCoords[7];
uniform vec2 uTextureSize;

void main(void) {

    gl_Position = openfl_Matrix * openfl_Position;

    /*vec2 r = uRadius / uTextureSize;
    vBlurCoords[0] = openfl_TextureCoordv - r;
    vBlurCoords[1] = openfl_TextureCoordv - r * 0.75;
    vBlurCoords[2] = openfl_TextureCoordv - r * 0.5;
    vBlurCoords[3] = openfl_TextureCoordv;
    vBlurCoords[4] = openfl_TextureCoordv + r * 0.5;
    vBlurCoords[5] = openfl_TextureCoordv + r * 0.75;
    vBlurCoords[6] = openfl_TextureCoordv + r;*/

}