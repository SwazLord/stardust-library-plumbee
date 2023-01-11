package idv.cjcat.stardustextended.clocks
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This clock can be used to create randomized impulses and has more parameters than ImpulseClock
 */
public class ImpulseClock extends Clock
{
    protected var _impulseInterval : Random;

    /**
     * How many particles to create when an impulse is happening.
     */
    public var ticksPerCall : Number;

    protected var _initialDelay : Random;
    protected var currentImpulseInterval : Number;
    protected var currentImpulseLength : Number;
    protected var currentInitialDelay : Number;
    protected var _impulseLength : Random;
    private var currentTime : Number;

    /**
     * The delay in seconds until the first impulse happens
     */
    public function set initialDelay(value : Random) : void
    {
        _initialDelay = value;
        setCurrentInitialDelay();
    }

    public function get initialDelay() : Random
    {
        return _initialDelay;
    }

    /**
     * The length of a impulses in seconds.
     */
    public function set impulseLength(value : Random) : void
    {
        _impulseLength = value;
        setCurrentImpulseLength();
    }

    public function get impulseLength() : Random
    {
        return _impulseLength;
    }

    /**
     * The time between a impulses in seconds.
     */
    public function set impulseInterval(value : Random) : void
    {
        _impulseInterval = value;
        setCurrentImpulseInterval();
    }

    public function get impulseInterval() : Random
    {
        return _impulseInterval;
    }

    public function ImpulseClock(_impulseInterval : Random = null,
                                 _impulseLength : Random = null,
                                 _initialDelay : Random = null,
                                 _ticksPerCall : Number = 1)
    {
        impulseInterval = _impulseInterval ? _impulseInterval : new UniformRandom(20, 10);
        impulseLength = _impulseLength ? _impulseLength : new UniformRandom(5, 0);
        initialDelay = _initialDelay ? _initialDelay : new UniformRandom(0, 0);
        ticksPerCall = _ticksPerCall;
        currentTime = 0;
    }

	[Inline]
    override public final function getTicks(time:Number):int
    {
        var ticks : int = 0;
        currentInitialDelay = currentInitialDelay - time;
		
        if(currentInitialDelay < 0)
		{
            currentTime = currentTime + time;
			
            if (currentTime <= currentImpulseLength)
			{
                ticks = StardustMath.randomFloor(ticksPerCall * time);
            }
            else if (currentTime - time <= currentImpulseLength)
			{
                // timestep was too big and it overstepped this impulse. Calculate the ticks for the fraction time
                ticks = StardustMath.randomFloor(ticksPerCall * (currentImpulseLength - currentTime + time));
            }
			
            if (currentTime >= currentImpulseInterval)
			{
                setCurrentImpulseLength();
                setCurrentImpulseInterval();
                currentTime = 0;
            }
        }

        return ticks;
    }

    /**
     * The emitter step after the <code>impulse()</code> call creates a burst of particles.
     */
    public function impulse():void
    {
        currentInitialDelay = -1;
        currentTime = 0;
    }

    [Inline]
    private final function setCurrentImpulseLength() : void
    {
        var len : Number = _impulseLength.random();
        currentImpulseLength = len > 0 ? len : 0;
    }

    [Inline]
    private final function setCurrentImpulseInterval() : void
    {
        var val : Number = _impulseInterval.random();
        currentImpulseInterval = val > 0 ? val : 0;
    }

    [Inline]
    private final function setCurrentInitialDelay() : void
    {
        var val : Number = _initialDelay.random();
        currentInitialDelay = val > 0 ? val : 0;
    }

    /**
     * Resets the clock and randomizes all values
     */
    override public function reset() : void
    {
        setCurrentInitialDelay();
        setCurrentImpulseLength();
        setCurrentImpulseInterval();
        currentTime = 0;
    }

    //XML
    //------------------------------------------------------------------------------------------------
    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return new <StardustElement>[_impulseInterval, _impulseLength, _initialDelay];
    }

    override public function getXMLTagName() : String
    {
        return "ImpulseClock";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@ticksPerCall = ticksPerCall;
        xml.@impulseInterval = _impulseInterval.name;
        xml.@impulseLength = _impulseLength.name;
        xml.@initialDelay = _initialDelay.name;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        // The randoms its using might not be initialized yet
        if (xml.@ticksPerCall.length()) ticksPerCall = parseFloat(xml.@ticksPerCall);
        if (xml.@impulseLength.length()) _impulseLength = builder.getElementByName(xml.@impulseLength) as Random;
        if (xml.@impulseInterval.length()) impulseInterval = builder.getElementByName(xml.@impulseInterval) as Random;

        if (xml.@initialDelay.length()) _initialDelay = builder.getElementByName(xml.@initialDelay) as Random;

        // Legacy names, for simulations created with old versions
        if (xml.@impulseCount.length()) ticksPerCall = parseFloat(xml.@impulseCount);
        if (xml.@repeatCount.length()) impulseLength = new UniformRandom(parseInt(xml.@repeatCount), 0);
        if (xml.@burstInterval.length()) impulseInterval = new UniformRandom(parseInt(xml.@burstInterval), 0);
    }

    override public function onXMLInitComplete() : void
    {
        reset();
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}