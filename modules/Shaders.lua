local Shaders = {}

-- https://love2d.org/forums/viewtopic.php?f=4&t=3733&start=20#p38666

Shaders = {
    verticalblur = love.graphics.newShader([[
        extern number canvas_h = 256.0;

        const number offset_1 = 1.3846153846;
        const number offset_2 = 3.2307692308;

        const number weight_0 = 0.2270270270;
        const number weight_1 = 0.3162162162;
        const number weight_2 = 0.0702702703;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 texcolor = Texel(texture, texture_coords);
            vec3 tc = texcolor.rgb * weight_0;
            
            tc += Texel(texture, texture_coords + vec2(0.0, offset_1)/canvas_h).rgb * weight_1;
            tc += Texel(texture, texture_coords - vec2(0.0, offset_1)/canvas_h).rgb * weight_1;
            
            tc += Texel(texture, texture_coords + vec2(0.0, offset_2)/canvas_h).rgb * weight_2;
            tc += Texel(texture, texture_coords - vec2(0.0, offset_2)/canvas_h).rgb * weight_2;
            
            return color * vec4(tc, 1.0);
        }
    ]]),
    horizontalblur = love.graphics.newShader([[
        extern number canvas_w = 256.0;

        const number offset_1 = 1.3846153846;
        const number offset_2 = 3.2307692308;

        const number weight_0 = 0.2270270270;
        const number weight_1 = 0.3162162162;
        const number weight_2 = 0.0702702703;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 texcolor = Texel(texture, texture_coords);
            vec3 tc = texcolor.rgb * weight_0;
            
            tc += Texel(texture, texture_coords + vec2(offset_1, 0.0)/canvas_w).rgb * weight_1;
            tc += Texel(texture, texture_coords - vec2(offset_1, 0.0)/canvas_w).rgb * weight_1;
            
            tc += Texel(texture, texture_coords + vec2(offset_2, 0.0)/canvas_w).rgb * weight_2;
            tc += Texel(texture, texture_coords - vec2(offset_2, 0.0)/canvas_w).rgb * weight_2;
            
            return color * vec4(tc, 1.0);
        }
    ]]),
    bloom = love.graphics.newShader([[
        extern number threshold = 0.10;
        
        float luminance(vec3 color)
        {
            // numbers make 'true grey' on most monitors, apparently
            return (0.212671 * color.r) + (0.715160 * color.g) + (0.072169 * color.b);
        }
        
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 texcolor = Texel(texture, texture_coords);
            
            vec3 extract = smoothstep(threshold * 0.7, threshold, luminance(texcolor.rgb)) * texcolor.rgb;
            return vec4(extract, 1.0);
        }
    ]]),
    combine = love.graphics.newShader([[
        extern Image bloomtex;
        
        extern number basesaturation = 1.0;
        extern number bloomsaturation = 1.0;
        
        extern number baseintensity = 1.0;
        extern number bloomintensity = 1.0;
        
        vec3 AdjustSaturation(vec3 color, number saturation)
        {
            vec3 grey = vec3(dot(color, vec3(0.212671, 0.715160, 0.072169)));
            return mix(grey, color, saturation);
        }
    
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 basecolor = Texel(texture, texture_coords);
            vec4 bloomcolor = Texel(bloomtex, texture_coords);
            
            bloomcolor.rgb = AdjustSaturation(bloomcolor.rgb, bloomsaturation) * bloomintensity;
            basecolor.rgb = AdjustSaturation(basecolor.rgb, basesaturation) * baseintensity;
            
            basecolor.rgb *= (1.0 - clamp(bloomcolor.rgb, 0.0, 1.0));
            
            bloomcolor.a = 0.0;
            
            return clamp(basecolor + bloomcolor, 0.0, 1.0);
        }
    ]])

}

return Shaders