package idv.cjcat.stardustextended.initializers
{
	import idv.cjcat.stardustextended.events.StardustInitializerEvent;
	
	/**
	 * This class is used internally by classes that implements the <code>InitializerCollector</code> interface.
	 */
	public class InitializerCollection implements InitializerCollector
	{
	
	    private var _initializers : Vector.<Initializer>;
	
	    public function InitializerCollection()
	    {
	        _initializers = new Vector.<Initializer>();
	    }
	
	    public final function addInitializer(initializer : Initializer) : void
	    {
	        if (_initializers.indexOf(initializer) >= 0) return;
	        _initializers.push(initializer);
	        initializer.addEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
	        sortInitializers();
	    }
	
	    public final function removeInitializer(initializer : Initializer) : void
	    {
	        var index:int;
			
	        if((index = _initializers.indexOf(initializer)) >= 0)
			{
	            _initializers.removeAt(index);
	            initializer.removeEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
	        }
	    }
	
	    public final function sortInitializers(event:StardustInitializerEvent = null):void
	    {
	        _initializers.sort(prioritySort);
	    }
	
	    public final function clearInitializers() : void
	    {
	        for each (var initializer : Initializer in _initializers) removeInitializer(initializer);
	    }
	
	    public function get initializers() : Vector.<Initializer>
	    {
	        return _initializers;
	    }
	
	    // descending priority sort
	    private static function prioritySort(el1:Initializer, el2:Initializer):Number
	    {
	        if (el1.priority > el2.priority)
	        {
	            return -1;
	        }
	        else if (el1.priority < el2.priority)
	        {
	            return 1;
	        }
	        return 0;
	    }
	}
}