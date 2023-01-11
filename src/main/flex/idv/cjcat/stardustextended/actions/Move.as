package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes a particle's position to change according to its velocity.
 *
 * <p>
 * Default priority = -4;
 * </p>
 */
public class Move extends Action
{

    /**
     * The multiplier of movement, 1 by default.
     *
     * <p>
     * For instance, a multiplier value of 2 causes a particle to move twice as fast as normal.
     * </p>
     */
    public var multiplier : Number;
    private var factor : Number;

    public function Move(multiplier : Number = 1)
    {
        priority = -4;

        this.multiplier = multiplier;
    }


    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        factor = time * multiplier;
    }

	[Inline]
    final override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        particle.x += particle.vx * factor;
        particle.y += particle.vy * factor;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Move";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@multiplier = multiplier;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@multiplier.length()) multiplier = parseFloat(xml.@multiplier);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}