package idv.cjcat.stardustextended.fields
{
import flash.geom.Point;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * 2D vector field.
 */
public class Field extends StardustElement implements IPosition
{

    public var active : Boolean;
    public var massless : Boolean;

    protected const position : Point = new Point();

    public function Field()
    {
        active = true;
        massless = true;
    }

    private var md2D : MotionData2D;
    private var mass_inv : Number;

    public final function getMotionData2D(particle : Particle) : MotionData2D
    {
        if (!active) return MotionData2DPool.get(0, 0);

        md2D = calculateMotionData2D(particle);

        if(!massless)
		{
            mass_inv = 1 / particle.mass;
            md2D.x *= mass_inv;
            md2D.y *= mass_inv;
        }

        return md2D;
    }

    protected function calculateMotionData2D(particle : Particle) : MotionData2D
    {
        return null;
    }

    /**
     * [Abstract Method] Sets the position of this Field.
     */
    public function setPosition(xc : Number, yc : Number) : void
    {
        throw new Error("This method must be overridden by subclasses");
    }

    /**
     * [Abstract Method] Gets the position of this Field.
     */
    public function getPosition() : Point
    {
        throw new Error("This method must be overridden by subclasses");
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Field";
    }

    override public function getElementTypeXMLTag() : XML
    {
        return <fields/>;
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@active = active;
        xml.@massless = massless;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        if (xml.@active.length()) active = (xml.@active == "true");
        if (xml.@massless.length()) massless = (xml.@massless == "true");
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}