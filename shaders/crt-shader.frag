// Final CRT shader with all effects including curvature

uniform float scanlineIntensity; // Adjust intensity (0-1)
uniform float scanlineCount; // Number of scanlines
uniform float time; // For flicker effect
uniform float yOffset; // Vertical drift to combat moiré pattern
uniform float brightness; // Overall brightness
uniform float contrast; // Contrast adjustment 
uniform float saturation; // Color saturation
uniform float bloomIntensity; // Bloom effect intensity
uniform float bloomThreshold; // Brightness threshold for bloom
uniform float rgbShift; // RGB color separation amount
uniform float adaptiveIntensity; // Adapt scanlines to reduce moiré (0-1)
uniform float vignetteStrength; // Vignette darkness (0-1)
uniform float curvature; // Screen curvature amount
uniform float flickerStrength; // Flicker intensity

// Safer curvature function
vec2 curveRemapUV(vec2 uv, float curvature) {
    // Convert from 0-1 to -1 to 1
    vec2 coords = uv * 2.0 - 1.0;
    
    // Calculate curvature effect - limiting the maximum distortion
    float curveAmount = curvature * 0.5; // Scale down to avoid extreme distortion
    
    // Compute distortion with squared distance from center
    float dist = coords.x * coords.x + coords.y * coords.y;
    coords = coords * (1.0 + dist * curveAmount);
    
    // Convert back to 0-1 range
    return coords * 0.5 + 0.5;
}

// Bloom sampling (unchanged from 3x3 Gaussian)
vec4 sampleBloom(Image tex, vec2 uv, float radius) {
    vec4 bloom = vec4(0.0);
    float weight = 1.0 / 16.0;
    
    bloom += Texel(tex, uv + vec2(-radius, -radius)) * (1.0 * weight);
    bloom += Texel(tex, uv + vec2(0.0, -radius)) * (2.0 * weight);
    bloom += Texel(tex, uv + vec2(radius, -radius)) * (1.0 * weight);
    bloom += Texel(tex, uv + vec2(-radius, 0.0)) * (2.0 * weight);
    bloom += Texel(tex, uv + vec2(0.0, 0.0)) * (4.0 * weight);
    bloom += Texel(tex, uv + vec2(radius, 0.0)) * (2.0 * weight);
    bloom += Texel(tex, uv + vec2(-radius, radius)) * (1.0 * weight);
    bloom += Texel(tex, uv + vec2(0.0, radius)) * (2.0 * weight);
    bloom += Texel(tex, uv + vec2(radius, radius)) * (1.0 * weight);
    
    return bloom;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    
    // Apply screen curvature if enabled
    if (curvature > 0.0) {
        uv = curveRemapUV(uv, curvature);
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            return vec4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    // Get the original pixel color with curved coordinates
    vec4 pixel = Texel(tex, uv);
    
    // Apply bloom effect early
    if (bloomIntensity > 0.0) {
        vec4 bloomSample = sampleBloom(tex, uv, 0.005);
        // Apply brightness to bloom sample to match pixel processing
        bloomSample.rgb *= brightness;
        float lum = dot(bloomSample.rgb, vec3(0.299, 0.587, 0.114));
        // Add bloom with a subtle base bleed, amplified above threshold
        float bloomFactor = bloomIntensity * max(0.1, min(1.0, (lum - bloomThreshold) * 2.0));
        pixel.rgb += bloomSample.rgb * bloomFactor;
    }
    
    // Apply RGB shift (chromatic aberration)
    if (rgbShift > 0.0) {
        float shift = rgbShift * 0.01;
        pixel.r += Texel(tex, vec2(uv.x + shift, uv.y)).r * 0.1;
        pixel.b += Texel(tex, vec2(uv.x - shift, uv.y)).b * 0.1;
    }
    
    // Apply brightness
    pixel.rgb *= brightness;
    
    // Apply contrast
    pixel.rgb = (pixel.rgb - 0.5) * contrast + 0.5;
    
    // Apply saturation adjustment
    float luminance = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
    pixel.rgb = mix(vec3(luminance), pixel.rgb, saturation);
    
    // Calculate scanlines with anti-moiré adjustments
    float scanline = 1.0;
    if (scanlineIntensity > 0.0) {
        float scanlineY = (uv.y + yOffset) * scanlineCount;
        float scanlinePattern = abs(sin(scanlineY * 3.14159));
        float adaptiveFactor = 1.0;
        if (adaptiveIntensity > 0.0) {
            float yPattern = sin(uv.y * 30.0) * 0.5 + 0.5;
            adaptiveFactor = 1.0 - yPattern * adaptiveIntensity * 0.2;
        }
        scanline = 1.0 - scanlinePattern * scanlineIntensity * adaptiveFactor;
    }
    
    // Apply flicker effect
    float flicker = 1.0 + sin(time * 110.0) * flickerStrength;
    
    // Apply vignette
    float vignette = 1.0;
    if (vignetteStrength > 0.0) {
        vec2 vignetteCoord = uv * 2.0 - 1.0;
        float vignetteDistance = max(abs(vignetteCoord.x), abs(vignetteCoord.y));
        vignette = 1.0 - pow(vignetteDistance, 3.0) * vignetteStrength;
    }
    
    // Apply combined lighting effects
    pixel.rgb *= scanline * flicker * vignette;
    
    return pixel * color;
}