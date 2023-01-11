package idv.cjcat.stardustextended.fields
{
import flash.geom.Point;

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Radial field.
 */
public class RadialField extends Field
{

    /**
     * The X coordinate of the center of the field.
     */
    public var x : Number;
    /**
     * The Y coordinate of the center of the field.
     */
    public var y : Number;
    /**
     * The strength of the field.
     */
    public var strength : Number;
    /**
     * The attenuation power of the field, in powers per pixel.
     */
    public var attenuationPower : Number;
    /**
     * If a point is closer to the center than this value,
     * it's treated as if it's this far from the center.
     * This is to prevent simulation from blowing up for points too near to the center.
     */
    public var epsilon : Number;

    public function RadialField(x : Number = 0, y : Number = 0, strength : Number = 1, attenuationPower : Number = 0, epsilon : Number = 1)
    {
        this.x = x;
        this.y = y;
        this.strength = strength;
        this.attenuationPower = attenuationPower;
        this.epsilon = epsilon;
    }

	private var _rVec:Vec2D = new Vec2D(0, 0);
	private var _calLen:Number;
	
	[Inline]
    final override protected function calculateMotionData2D(particle : Particle) : MotionData2D
    {
		_rVec.x = particle.x - x;
		_rVec.y = particle.y - y;
		
        _calLen = _rVec.length;
		
        if(_calLen < epsilon) _calLen = epsilon;
		
		_rVec.length = strength * Math.pow(_calLen, -0.5 * attenuationPower);

        return MotionData2DPool.get(_rVec.x, _rVec.y);
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    override public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "RadialField";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@x = x;
        xml.@y = y;
        xml.@strength = strength;
        xml.@attenuationPower = attenuationPower;
        xml.@epsilon = epsilon;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@x.length()) x = parseFloat(xml.@x);
        if (xml.@y.length()) y = parseFloat(xml.@y);
        if (xml.@strength.length()) strength = parseFloat(xml.@strength);
        if (xml.@attenuationPower.length()) attenuationPower = parseFloat(xml.@attenuationPower);
        if (xml.@epsilon.length()) epsilon = parseFloat(xml.@epsilon);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}