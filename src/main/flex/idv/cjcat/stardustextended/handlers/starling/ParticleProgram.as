package idv.cjcat.stardustextended.handlers.starling
{

import flash.display3D.Context3DTextureFormat;
import flash.utils.Dictionary;

import starling.core.Starling;
import starling.rendering.Program;
import starling.textures.TextureSmoothing;
import starling.utils.RenderUtil;

public class ParticleProgram
{

    private static const sProgramNameCache : Dictionary = new Dictionary();

    public static function getProgram(texMipmap : Boolean = true,
                                      texFormat : String = "bgra",
                                      texSmoothing : String = "bilinear") : Program
    {
        var target : Starling = Starling.current;
        var programName : String = getImageProgramName(texMipmap, texFormat, texSmoothing);

        var program : Program = target.painter.getProgram(programName);
        if (!program) {
            // this is the input data we'll pass to the shaders:
            //
            // va0 -> position
            // va1 -> color
            // va2 -> texCoords
            // vc0 -> alpha
            // vc1 -> mvpMatrix
            // fs0 -> texture
            var vertexShader : String = "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
                                        "mul v0, va1, vc0 \n" + // multiply alpha (vc0) with color (va1)
                                        "mov v1, va2      \n"; // pass texture coordinates to fragment program

            var fragmentShader : String = "tex ft1,  v1, fs0 <???> \n" + // sample texture 0
                                          "mul  oc, ft1,  v0       \n"; // multiply color with texel color

            fragmentShader = fragmentShader.replace("<???>", RenderUtil.getTextureLookupFlags(texFormat, texMipmap, false, texSmoothing));
            program = Program.fromSource(vertexShader, fragmentShader);
            target.painter.registerProgram(programName, program);
        }
        return program;
    }

    private static function getImageProgramName(mipMap : Boolean, format : String, smoothing : String) : String
    {
        var bitField : uint = 0;

        if (mipMap)
            bitField |= 1 << 1;

        if (smoothing == TextureSmoothing.NONE)
            bitField |= 1 << 3;
        else if (smoothing == TextureSmoothing.TRILINEAR)
            bitField |= 1 << 4;

        if (format == Context3DTextureFormat.COMPRESSED)
            bitField |= 1 << 5;
        else if (format == "compressedAlpha")
            bitField |= 1 << 6;

        var name : String = sProgramNameCache[bitField];

        if (name == null) {
            name = "__STARDUST_RENDERER." + bitField.toString(16);
            sProgramNameCache[bitField] = name;
        }
        return name;
    }
}
}
