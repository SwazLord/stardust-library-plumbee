package idv.cjcat.stardustextended.clocks
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes the emitter to create particles at a steady rate.
 */
public class SteadyClock extends Clock
{

    /**
     * How many particles to create in each second.
     *
     * If less than one, it's the probability of an emitter to create a single particle in each second.
     */
    public var ticksPerCall : Number;

    /**
     * The delay in seconds until the the clock starts
     */
    public function set initialDelay(value : Random) : void
    {
        _initialDelay = value;
        setCurrentInitialDelay()
    }

    public function get initialDelay() : Random
    {
        return _initialDelay;
    }

    protected var _initialDelay : Random;
    protected var currentInitialDelay : Number;
    protected var currentTime : Number;

    public function SteadyClock(ticksPerCall : Number = 1, _initialDelay : Random = null)
    {
        this.ticksPerCall = ticksPerCall;
        initialDelay = _initialDelay ? _initialDelay : new UniformRandom(0, 0);
        currentTime = 0;
    }

	[Inline]
    override public final function getTicks(time:Number):int
    {
        currentTime = currentTime + time;

        if(currentTime > currentInitialDelay)
		{
            return StardustMath.randomFloor(ticksPerCall * time);
        }

        return 0;
    }

    /**
     * Resets the clock and randomizes all values
     */
    override public function reset() : void
    {
        currentTime = 0;
        setCurrentInitialDelay();
    }

    [Inline]
    private final function setCurrentInitialDelay() : void
    {
        var val : Number = _initialDelay.random();
        currentInitialDelay = val > 0 ? val : 0;
    }

    //XML
    //------------------------------------------------------------------------------------------------
    override public function getXMLTagName() : String
    {
        return "SteadyClock";
    }

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return new <StardustElement>[_initialDelay];
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@ticksPerCall = ticksPerCall;
        xml.@initialDelay = _initialDelay.name;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        ticksPerCall = parseFloat(xml.@ticksPerCall);
        if (xml.@initialDelay.length()) _initialDelay = builder.getElementByName(xml.@initialDelay) as Random;
    }

    override public function onXMLInitComplete() : void
    {
        setCurrentInitialDelay();
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}