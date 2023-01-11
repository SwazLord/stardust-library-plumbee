package idv.cjcat.stardustextended.emitters
{

import flash.events.EventDispatcher;

import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.ActionCollection;
import idv.cjcat.stardustextended.actions.ActionCollector;
import idv.cjcat.stardustextended.clocks.Clock;
import idv.cjcat.stardustextended.clocks.SteadyClock;
import idv.cjcat.stardustextended.events.StardustEmitterStepEndEvent;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.InitializerCollector;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.particles.PooledParticleFactory;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This class takes charge of the actual particle simulation of the Stardust particle system.
 */
[Event(name="StardustEmitterStepEndEvent", type="idv.cjcat.stardustextended.events.StardustEmitterStepEndEvent")]
public class Emitter extends StardustElement implements ActionCollector, InitializerCollector
{


    private const eventDispatcher : EventDispatcher = new EventDispatcher();

    public function addEventListener(_type : String,
                                     listener : Function,
                                     useCapture : Boolean = false,
                                     priority : int = 0,
                                     useWeakReference : Boolean = false) : void
    {
        eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(_type : String, listener : Function, useCapture : Boolean = false) : void
    {
        eventDispatcher.removeEventListener(_type, listener, useCapture);
    }


    private const newParticles : Vector.<Particle> = new Vector.<Particle>();

    private var _particles : Vector.<Particle> = new Vector.<Particle>();
	
    /**
     * Returns every managed particle for custom parameter manipulation.
     * The returned Vector is not a copy.
     * @return
     */
	[Inline]
    final public function get particles() : Vector.<Particle>
    {
        return _particles;
    }

    /**
     * Particle handler is used to render particles
     */
    public var particleHandler : ParticleHandler;

    protected var _clock : Clock;
    /**
     * Whether the emitter is active, true by default.
     *
     * <p>
     * If the emitter is active, it creates particles in each step according to its clock.
     * Note that even if an emitter is not active, the simulation of existing particles still goes on in each step.
     * </p>
     */
    public var active : Boolean;
    /**
     * The time since the simulation is running
     */
    public var currentTime : Number = 0;

    /**
     * While the max. fps in Flash is 60, the actual value fluctuates a few ms.
     * Thus using the real value would cause lots of frame skips
     * To take this into account Stardust uses internally a slightly smaller value to compensate.
     */
    public static var timeStepCorrectionOffset : Number = 0.004;
    protected var factory : PooledParticleFactory = new PooledParticleFactory();
    protected const _actionCollection : ActionCollection = new ActionCollection();
    protected const activeActions : Vector.<Action> = new Vector.<Action>();
    protected var _invFps : Number = 1 / 60 - timeStepCorrectionOffset;
    protected var timeSinceLastStep : Number = 0;
    protected var _fps : Number;

    public function Emitter(clock : Clock = null, particleHandler : ParticleHandler = null)
    {
        this.clock = clock;
        this.active = true;
        this.particleHandler = particleHandler;
        fps = 60;
    }

    /**
     * The clock determines how many particles the emitter creates in each step.
     */
    public function get clock() : Clock
    {
        return _clock;
    }

    public function set clock(value : Clock) : void
    {
        if (!value) value = new SteadyClock(0);
        _clock = value;
    }

    /**
     * Sets the frame rate of the simulation. Lower framerates consume less CPU, but make your animations
     * look choppy. Note that the simulation behaves slightly differently at different FPS settings
     * (e.g. A clock produces the same amount of ticks on all FPSes, but it does it at a different times,
     * resulting in particles emitted in batches instead smoothly)
     */
    public function set fps(val : Number) : void
    {
        if (val > 60)
        {
            val = 60;
        }
        _fps = val;

        _invFps = 1 / val - timeStepCorrectionOffset;
    }

    public function get fps() : Number
    {
        return _fps;
    }

    //main loop
    //------------------------------------------------------------------------------------------------

    /**
     * This method is the main simulation loop of the emitter.
     *
     * <p>
     * In order to keep the simulation go on, this method should be called continuously.
     * It is recommended that you call this method through the <code>Event.ENTER_FRAME</code> event or the <code>TimerEvent.TIMER</code> event.
     * </p>
     * @param time The time elapsed since the last step in seconds
     */
	[Inline]
    public final function step(time:Number):void
    {
        if(time <= 0)
        {
            return;
        }

        timeSinceLastStep = timeSinceLastStep + time;
        currentTime = currentTime + time;

        if (timeSinceLastStep < _invFps)
        {
            return;
        }

		//this is not needed when using starling
        //particleHandler.stepBegin(this, _particles, timeSinceLastStep);

        var i : int;
        var len : int;

        if(active)
		{
            createParticles(_clock.getTicks(timeSinceLastStep));
        }

        //filter out active actions
        activeActions.length = 0;
        var action : Action;
        len = actions.length;
		
        for (i = 0; i < len; ++i)
		{
            action = actions[i];
			
            if(action.active)
			{
                activeActions.push(action);
            }
        }

        //sorting
        len = activeActions.length;

        for(i = 0; i < len; ++i)
		{
            action = activeActions[i];

            if(action.needsSortedParticles)
			{
                _particles.sort(Particle.compareFunction);
                break;
            }
        }

        //invoke action preupdates.
        for (i = 0; i < len; ++i)
		{
            activeActions[i].preUpdate(this, timeSinceLastStep);
        }

        //update the remaining particles
        var p : Particle;
		
        for(var m : int = 0; m < _particles.length; ++m)
		{
            p = _particles[m];
			
            for (i = 0; i < len; ++i)
			{
                action = activeActions[i];
                //update particle
                action.update(this, p, timeSinceLastStep, currentTime);
            }

            if (p.isDead)
			{
                particleHandler.particleRemoved(p);

                p.destroy();
                factory.recycle(p);

                _particles.removeAt(m);
                m--;
            }
        }

        //postUpdate
        for(i = 0; i < len; ++i)
		{
            activeActions[i].postUpdate(this, timeSinceLastStep);
        }

        if(eventDispatcher.hasEventListener(StardustEmitterStepEndEvent.TYPE))
		{
            eventDispatcher.dispatchEvent(new StardustEmitterStepEndEvent(this));
        }

        particleHandler.stepEnd(this, _particles, timeSinceLastStep);

        timeSinceLastStep = 0;
    }

    //------------------------------------------------------------------------------------------------
    //end of main loop


    //actions & initializers
    //------------------------------------------------------------------------------------------------
    /**
     * Returns every action for this emitter
     */
	[Inline]
    public final function get actions():Vector.<Action>
    {
        return _actionCollection.actions;
    }

    /**
     * Adds an action to the emitter.
     * @param    action
     */
    public function addAction(action:Action):void
    {
        _actionCollection.addAction(action);
        action.dispatchAddEvent();
    }

    /**
     * Removes an action from the emitter.
     * @param    action
     */
    public final function removeAction(action : Action) : void
    {
        _actionCollection.removeAction(action);
        action.dispatchRemoveEvent();
    }

    /**
     * Removes all actions from the emitter.
     */
    public final function clearActions() : void
    {
        var actions : Vector.<Action> = _actionCollection.actions;
        var len : int = actions.length;
        for (var i : int = 0; i < len; ++i) {
            var action : Action = actions[i];
            action.dispatchRemoveEvent();
        }
        _actionCollection.clearActions();
    }

    /**
     * Returns all initializers of this emitter.
     */
    public final function get initializers() : Vector.<Initializer>
    {
        return factory.initializerCollection.initializers;
    }

    /**
     * Adds an initializer to the emitter.
     * @param    initializer
     */
    public function addInitializer(initializer : Initializer) : void
    {
        factory.addInitializer(initializer);
        initializer.dispatchAddEvent();
    }

    /**
     * Removes an initializer form the emitter.
     * @param    initializer
     */
    public final function removeInitializer(initializer : Initializer) : void
    {
        factory.removeInitializer(initializer);
        initializer.dispatchRemoveEvent();
    }

    /**
     * Removes all initializers from the emitter.
     */
    public final function clearInitializers() : void
    {
        var initializers : Vector.<Initializer> = factory.initializerCollection.initializers;
        var len : int = initializers.length;
        for (var i : int = 0; i < len; ++i) {
            initializers[i].dispatchRemoveEvent();
        }
        factory.clearInitializers();
    }

    //------------------------------------------------------------------------------------------------
    //end of actions & initializers

    /**
     * Resets all properties to their default values and removes all particles.
     */
    public function reset() : void
    {
        currentTime = 0;
        clearParticles();
        _clock.reset();
        particleHandler.reset();
    }

    //particles
    //------------------------------------------------------------------------------------------------

    /**
     * The number of particles in the emitter.
     */
    public final function get numParticles() : int
    {
        return _particles.length;
    }

    /**
     * This method is called by the emitter to create new particles.
     */
	[Inline]
    public final function createParticles(pCount:uint):Vector.<Particle>
    {
        newParticles.length = 0;
        factory.createParticles(pCount, currentTime, newParticles);
        addParticles(newParticles);
        return newParticles;
    }

    /**
     * This method is used to manually add existing particles to the emitter's simulation.
     * Note: you have to initialize the particles manually! To call all initializers in this emitter for the
     * particle call <code>createParticles</code> instead.
     * @param    particles
     */
	[Inline]
    public final function addParticles(particles:Vector.<Particle>):void
    {
        var particle:Particle;

        const plen:uint = particles.length;

        for(var m : int = 0; m < plen; ++m)
		{
            particle = particles[m];
            _particles.push(particle);

            //handle adding
            particleHandler.particleAdded(particle);
        }
    }

    /**
     * Clears all particles from the emitter's simulation.
     */
    public final function clearParticles():void
    {
        var particle : Particle;

        for (var m : int = 0; m < _particles.length; ++m)
		{
            particle = _particles[m];
            //handle removal
            particleHandler.particleRemoved(particle);

            particle.destroy();
            factory.recycle(particle);
        }

        _particles = new Vector.<Particle>();
    }

    //------------------------------------------------------------------------------------------------
    //end of particles


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        var allElems : Vector.<StardustElement> = new Vector.<StardustElement>();
        allElems.push(_clock);
        allElems.push(particleHandler);
        allElems = allElems.concat(initializers);
        allElems = allElems.concat(Vector.<StardustElement>(actions));
        return allElems;
    }

    override public function getXMLTagName() : String
    {
        return "Emitter2D";
    }

    override public function getElementTypeXMLTag() : XML
    {
        return <emitters/>;
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@active = active.toString();
        xml.@clock = _clock.name;
        xml.@particleHandler = particleHandler.name;
        xml.@fps = fps.toString();

        if (actions.length > 0) {
            xml.appendChild(<actions/>);
            for each (var action : Action in actions) {
                xml.actions.appendChild(action.getXMLTag());
            }
        }

        if (initializers.length > 0) {
            xml.appendChild(<initializers/>);
            for each (var initializer : Initializer in initializers) {
                xml.initializers.appendChild(initializer.getXMLTag());
            }
        }

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        _actionCollection.clearActions();
        factory.clearInitializers();

        if (xml.@active.length()) active = (xml.@active == "true");
        if (xml.@clock.length()) clock = builder.getElementByName(xml.@clock) as Clock;
        if (xml.@particleHandler.length()) particleHandler = builder.getElementByName(xml.@particleHandler) as ParticleHandler;
        if (xml.@fps.length()) fps = parseFloat(xml.@fps);

        var node : XML;
        for each (node in xml.actions.*) {
            addAction(builder.getElementByName(node.@name) as Action);
        }
        for each (node in xml.initializers.*) {
            addInitializer(builder.getElementByName(node.@name) as Initializer);
        }
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}