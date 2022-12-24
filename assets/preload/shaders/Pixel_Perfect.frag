float c_textureSize = 180.0;

#define c_onePixel  (1.0 / c_textureSize)
#define c_twoPixels  (2.0 / c_textureSize)

float c_x0 = -1.0;
float c_x1 =  0.0;
float c_x2 =  1.0;
float c_x3 =  2.0;
    
//=======================================================================================
vec3 NearestTextureSample (vec2 P)
{
    vec2 pixel = P * c_textureSize;
    
    vec2 frac = fract(pixel);
    pixel = (floor(pixel) / c_textureSize);
    return texture(bitmap, pixel + vec2(c_onePixel/2.0)).rgb;
}

//=======================================================================================
void AnimateUV (inout vec2 uv)
{
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // set up our coordinate system
    float aspectRatio = iResolution.y / iResolution.x;
    vec2 uv = (fragCoord.xy / iResolution.xy);
    
    // do our sampling
    vec3 color;

     AnimateUV(uv);
     color = NearestTextureSample(uv); //estees
   
    // set the final color
	fragColor = vec4(color,1.0);    
}