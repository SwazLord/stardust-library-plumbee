package idv.cjcat.stardustextended.actions
{

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.geom.Matrix;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's color during its lifetime based on a gradient.
 */
public class ColorGradient extends Action
{
    /**
     * Number of gradient steps. Higher values result in smoother transition, but more memory usage.
     */
    public var numSteps : uint = 500;

    protected var _colors : Array;
    protected var _ratios : Array;
    protected var _alphas : Array;
    protected var colorRs : Vector.<Number>;
    protected var colorBs : Vector.<Number>;
    protected var colorGs : Vector.<Number>;
    protected var colorAlphas : Vector.<Number>;

    public function get colors() : Array
    {
        return _colors;
    }

    public function get ratios() : Array
    {
        return _ratios;
    }

    public function get alphas() : Array
    {
        return _alphas;
    }

    /**
     *
     * @param setDefaultValues Set some default values to start with. Leave it false if you set value manually to
     *        prevent parsing twice
     */
    public function ColorGradient(setDefaultValues : Boolean = false) : void
    {
        super();
        if (setDefaultValues) {
            setGradient([0x00FF00, 0xFF0000], [0, 255], [1, 1]);
        }
    }

    /**
     * Sets the gradient values. Both vectors must be the same length, and must have less than 16 values.
     * @param colors Array of uint colors HEX RGB colors
     * @param ratios Array of uint ratios ordered, in increasing order. First value should be 0, last 255.
     * @param alphas Array of Number alphas in the 0-1 range.
     */
    public final function setGradient(colors : Array, ratios : Array, alphas : Array):void
    {
        _colors = colors;
        _ratios = ratios;
        _alphas = alphas;
        colorRs = new Vector.<Number>();
        colorBs = new Vector.<Number>();
        colorGs = new Vector.<Number>();
        colorAlphas = new Vector.<Number>();

        var mat : Matrix = new Matrix();
        mat.createGradientBox(numSteps, 1);
        var sprite : Sprite = new Sprite();
        sprite.graphics.lineStyle();
        sprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
        sprite.graphics.drawRect(0, 0, numSteps, 1);
        sprite.graphics.endFill();
        var bd : BitmapData = new BitmapData(numSteps, 1, true, 0x00000000);
        bd.draw(sprite);
        for (var i : int = numSteps - 1; i > -1; i--) {
            var color : uint = bd.getPixel32(i, 0);
            colorRs.push(ColorUtil.extractRed(color));
            colorBs.push(ColorUtil.extractBlue(color));
            colorGs.push(ColorUtil.extractGreen(color));
            colorAlphas.push(ColorUtil.extractAlpha32(color));
        }
        colorRs.fixed = true;
        colorBs.fixed = true;
        colorGs.fixed = true;
        colorAlphas.fixed = true;
        bd.dispose();
    }

	[Inline]
    override public final function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void
    {
        var ratio:uint = (numSteps - 1) * particle.life / particle.initLife;

        particle.colorR = colorRs[ratio];
        particle.colorB = colorBs[ratio];
        particle.colorG = colorGs[ratio];
        particle.alpha = colorAlphas[ratio];
    }

    //XML
    //------------------------------------------------------------------------------------------------
    override public function getXMLTagName() : String
    {
        return "ColorGradient";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        var colorsStr : String = "";
        var ratiosStr : String = "";
        var alphasStr : String = "";
        for (var i : int = 0; i < _colors.length; i++) {
            colorsStr = colorsStr + _colors[i] + ",";
            ratiosStr = ratiosStr + _ratios[i] + ",";
            alphasStr = alphasStr + _alphas[i] + ",";
        }
        xml.@colors = colorsStr.substr(0, colorsStr.length - 1);
        xml.@ratios = ratiosStr.substr(0, ratiosStr.length - 1);
        xml.@alphas = alphasStr.substr(0, alphasStr.length - 1);

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        setGradient((xml.@colors).split(","), (xml.@ratios).split(","), (xml.@alphas).split(","));
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}