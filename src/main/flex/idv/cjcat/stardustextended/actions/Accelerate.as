package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Accelerates particles along their velocity directions.
 */
public class Accelerate extends Action
{

    /**
     * The amount of acceleration in each second.
     */
    public var acceleration : Number;
    protected var _timeDeltaOneSec : Number;

    public function Accelerate(acceleration : Number = 60)
    {
        this.acceleration = acceleration;
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        _timeDeltaOneSec = time * 60;
    }

	private var _finalLength:Number;
	private var _updateVec:Vec2D = new Vec2D(0, 0);

	[Inline]
    final override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void
    {
		_updateVec.x = particle.vx;
		_updateVec.y = particle.vy;
		
        if(_updateVec.length > 0)
		{
			_finalLength = _updateVec.length + acceleration * _timeDeltaOneSec;
			
            if(_finalLength < 0)
			{
				_finalLength = 0;
            }
			
			_updateVec.length = _finalLength;

            particle.vx = _updateVec.x;
            particle.vy = _updateVec.y;
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Accelerate";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@acceleration = acceleration;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@acceleration.length()) acceleration = parseFloat(xml.@acceleration);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}