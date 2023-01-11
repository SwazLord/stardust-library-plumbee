package idv.cjcat.stardustextended.events
{

	import flash.events.Event;
	
	import idv.cjcat.stardustextended.initializers.Initializer;
	
	public class StardustInitializerEvent extends Event
	{
	
	    public static const PRIORITY_CHANGE : String = "PRIORITY_CHANGE";
	    public static const ADD : String = "ADD";
	    public static const REMOVE : String = "REMOVE";
	
	    private var _initializer : Initializer;
	
	    public function StardustInitializerEvent(_type:String)
	    {
	        super(_type);
	    }
	
		public function set initializer(action:Initializer):void
		{
			_initializer = action;
		}
	
	    public function get initializer():Initializer
	    {
	        return _initializer;
	    }
	
	    override public function clone() : Event
	    {
	        var copy:StardustInitializerEvent = new StardustInitializerEvent(type);
				copy.initializer = _initializer;
				
			return copy;
	    }
	}
}
