package idv.cjcat.stardustextended.handlers
{

import flash.display.BitmapData;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;

/**
 * This handler draws pixels into a <code>BitmapData</code> object according to the <code>color</code> property of <code>Particle</code> objects.
 */
public class PixelHandler extends ParticleHandler
{

    /**
     * The target bitmap to draw display object into.
     */
    public var targetBitmapData : BitmapData;

    public function PixelHandler(targetBitmapData : BitmapData = null)
    {
        this.targetBitmapData = targetBitmapData;
    }

    private var x : int, y : int, finalColor : uint;

	[Inline]
    final override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void
    {
        for each (var particle : Particle in particles)
		{
            x = int(particle.x + 0.5);
			
            if ((x < 0) || (x >= targetBitmapData.width)) return;
			
            y = int(particle.y + 0.5);
			
            if ((y < 0) || (y >= targetBitmapData.height)) return;

            var rgbColor : uint = ColorUtil.rgbToHex(particle.colorR, particle.colorG, particle.colorB);
			
            finalColor = (rgbColor & 0xFFFFFF) | uint(uint(particle.alpha * 255) << 24);
			
            targetBitmapData.setPixel32(x, y, finalColor);
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "PixelHandler";
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}