package idv.cjcat.stardustextended.initializers
{

	import flash.events.EventDispatcher;
	
	import idv.cjcat.stardustextended.events.StardustInitializerEvent;
	import idv.cjcat.stardustextended.particles.Particle;
	import idv.cjcat.stardustextended.StardustElement;
	import idv.cjcat.stardustextended.xml.XMLBuilder;
	
	/**
	 * An initializer is used to alter just once (i.e. initialize) a particle's properties upon the particle's birth.
	 *
	 * <p>
	 * An initializer can be associated with an emitter or a particle factory.
	 * </p>
	 *
	 * <p>
	 * Default priority = 0;
	 * </p>
	 */
	[Event(name="PRIORITY_CHANGE", type="idv.cjcat.stardustextended.events.StardustInitializerEvent")]
	[Event(name="ADD", type="idv.cjcat.stardustextended.events.StardustInitializerEvent")]
	[Event(name="REMOVE", type="idv.cjcat.stardustextended.events.StardustInitializerEvent")]
	public class Initializer extends StardustElement
	{
	
	
	    private const eventDispatcher : EventDispatcher = new EventDispatcher();
		
		private static var addEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.ADD);
		private static var removeEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.REMOVE);
		private static var priorityChangeEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.PRIORITY_CHANGE);
		
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
	
	    public function dispatchAddEvent():void
	    {
	        eventDispatcher.dispatchEvent(addEvent);
	    }
	
	    public function dispatchRemoveEvent():void
	    {
	        eventDispatcher.dispatchEvent(removeEvent);
	    }
	
	    /**
	     * Denotes if the initializer is active, true by default.
	     */
	    public var active : Boolean;
	
	    private var _priority : int;
	
	    public function Initializer()
	    {
	        priority = 0;
	        active = true;
			
			addEvent.initializer = this;
			removeEvent.initializer = this;
			priorityChangeEvent.initializer = this;
	    }
	
	    /** @private */
	    public function doInitialize(particles : Vector.<Particle>, currentTime : Number) : void
	    {
	        if (active) {
	            var particle : Particle;
	            for (var m : int = 0; m < particles.length; ++m) {
	                particle = particles[m];
	                initialize(particle);
	            }
	        }
	    }
	
	    /**
	     * [Template Method] This is the method that alters a particle's properties.
	     *
	     * <p>
	     * Override this property to create custom initializers.
	     * </p>
	     * @param    particle
	     */
	    public function initialize(particle : Particle) : void
	    {
	        //abstract method
	    }
	
	    /**
	     * Initializers will be sorted according to their priorities.
	     *
	     * <p>
	     * This is important,
	     * since some initializers may rely on other initializers to perform initialization beforehand.
	     * You can alter the priority of an initializer, but it is recommended that you use the default values.
	     * </p>
	     */
	    public function get priority():int
	    {
	        return _priority;
	    }
	
	    public function set priority(value:int):void
	    {
	        _priority = value;
	        eventDispatcher.dispatchEvent(priorityChangeEvent);
	    }
	
	    //XML
	    //------------------------------------------------------------------------------------------------
	
	    override public function getXMLTagName():String
	    {
	        return "Initializer";
	    }
	
	    override public function getElementTypeXMLTag():XML
	    {
	        return <initializers/>;
	    }
	
	    override public function toXML():XML
	    {
	        var xml:XML = super.toXML();
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