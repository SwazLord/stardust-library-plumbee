package idv.cjcat.stardustextended.actions
{

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import idv.cjcat.stardustextended.StardustElement;
	import idv.cjcat.stardustextended.emitters.Emitter;
	import idv.cjcat.stardustextended.events.StardustActionEvent;
	import idv.cjcat.stardustextended.particles.Particle;
	import idv.cjcat.stardustextended.xml.XMLBuilder;
	
	/**
	 * An action is used to continuously update a particle's property.
	 *
	 * <p>
	 * An action is associated with an emitter. On each <code>Emitter.step()</code> method call,
	 * the action's <code>update()</code> method is called with each particles in the emitter passed in as parameter.
	 * This method updates a particles property, such as changing the particle's position according to its velocity,
	 * or modifying the particle's velocity based on gravity fields.
	 * </p>
	 *
	 * <p>
	 * Default priority = 0;
	 * </p>
	 */
	[Event(name="PRIORITY_CHANGE", type="idv.cjcat.stardustextended.events.StardustActionEvent")]
	[Event(name="ADD", type="idv.cjcat.stardustextended.events.StardustActionEvent")]
	[Event(name="REMOVE", type="idv.cjcat.stardustextended.events.StardustActionEvent")]
	
	public class Action extends StardustElement
	{
	
	    private const eventDispatcher : EventDispatcher = new EventDispatcher();
		
		private static var addEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.ADD);
		private static var removeEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.REMOVE);
		private static var priorityChangeEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.PRIORITY_CHANGE);
		
	    public function addEventListener(_type : String,
	                                     listener : Function,
	                                     useCapture : Boolean = false,
	                                     priority : int = 0,
	                                     useWeakReference : Boolean = false) : void
	    {
	        eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
	    }
	
	    public function removeEventListener(_type:String, listener:Function, useCapture:Boolean = false):void
	    {
	        eventDispatcher.removeEventListener(_type, listener, useCapture);
	    }
	
		[Inline]
	    final public function dispatchAddEvent():void
	    {
			addEvent.action = this;
	        eventDispatcher.dispatchEvent(addEvent);
	    }
	
		[Inline]
		final public function dispatchRemoveEvent():void
	    {
			removeEvent.action = this;
	        eventDispatcher.dispatchEvent(removeEvent);
	    }
	
	    /**
	     * Denotes if the action is active, true by default.
	     */
	    public var active : Boolean;
	
	    protected var _priority : int;
	
	    public function Action()
	    {
	        super();
	        priority = 0;
	        active = true;
	    }
	
	    /**
	     * [Template Method] This method is called once upon each <code>Emitter.step()</code> method call,
	     * before the <code>update()</code> calls with each particles in the emitter.
	     *
	     * <p>
	     * All setup operations before the <code>update()</code> calls should be done here.
	     * </p>
	     * @param    emitter        The associated emitter.
	     * @param    time        The timespan of each emitter's step.
	     */
	    public function preUpdate(emitter : Emitter, time : Number) : void
	    {
	        //abstract method
	    }
	
	    /**
	     * [Template Method] Acts on all particles upon each <code>Emitter.step()</code> method call.
	     *
	     * <p>
	     * Override this method to create custom actions.
	     * </p>
	     * @param    emitter        The associated emitter.
	     * @param    particle    The associated particle.
	     * @param    timeDelta   The timespan of each emitter's step.
	     * @param    currentTime The total time from the first emitter.step() call.
	     */
	    public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
	    {
	        //abstract method
	    }
	
	    /**
	     * [Template Method] This method is called once after each <code>Emitter.step()</code> method call,
	     * after the <code>update()</code> calls with each particles in the emitter.
	     *
	     * <p>
	     * All setup operations after the <code>update()</code> calls should be done here.
	     * </p>
	     * @param    emitter        The associated emitter.
	     * @param    time        The timespan of each emitter's step.
	     */
	    public function postUpdate(emitter : Emitter, time : Number) : void
	    {
	        //abstract method
	    }
	
	    /**
	     * Actions will be sorted by the associated emitter according to their priorities.
	     *
	     * <p>
	     * This is important,
	     * since it doesn't make sense to first update a particle's position according to its speed,
	     * and then update the velocity according to gravity fields afterwards.
	     * You can alter the priority of an action, but it is recommended that you use the default values.
	     * </p>
	     */
		[Inline]
	    final public function get priority():int
	    {
	        return _priority;
	    }
	
	    public function set priority(value:int):void
	    {
	        _priority = value;

			priorityChangeEvent.action = this;
	        eventDispatcher.dispatchEvent(priorityChangeEvent);
	    }
	
	    /**
	     * Tells the emitter whether this action requires that particles must be sorted before the <code>update()</code> calls.
	     *
	     * <p>
	     * For instance, the <code>Collide</code> action needs all particles to be sorted in X positions.
	     * </p>
	     */
	    public function get needsSortedParticles() : Boolean
	    {
	        return false;
	    }
	
	    //XML
	    //------------------------------------------------------------------------------------------------
	
	    override public function getXMLTagName() : String
	    {
	        return getQualifiedClassName(this);
	    }
	
	    override public function getElementTypeXMLTag() : XML
	    {
	        return <actions/>;
	    }
	
	    override public function toXML() : XML
	    {
	        var xml : XML = super.toXML();
	        xml.@active = active;
	        return xml;
	    }
	
	    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
	    {
	        super.parseXML(xml, builder);
	        if (xml.@active.length()) active = (xml.@active == "true");
	    }
	
	    //------------------------------------------------------------------------------------------------
	    //end of XML
	}
}