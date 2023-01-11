package idv.cjcat.stardustextended.actions
{
	import idv.cjcat.stardustextended.events.StardustActionEvent;
	
	/**
	 * This class is used internally by classes that implements the <code>ActionCollector</code> interface.
	 */
	public class ActionCollection implements ActionCollector
	{
	
	    protected var _actions : Vector.<Action>;
	
	    public function ActionCollection()
	    {
	        _actions = new Vector.<Action>();
	    }
	
		[Inline]
	    final public function get actions() : Vector.<Action>
	    {
	        return _actions;
	    }
	
	    public final function addAction(action : Action) : void
	    {
	        if (_actions.indexOf(action) >= 0) return;
	        _actions.push(action);
	        action.addEventListener(StardustActionEvent.PRIORITY_CHANGE, sortActions);
	        sortActions();
	    }
	
	    public final function removeAction(action:Action):void
	    {
	        var index:int;
			
	        if((index = _actions.indexOf(action)) >= 0)
			{
	            _actions.removeAt(index);
	            action.removeEventListener(StardustActionEvent.PRIORITY_CHANGE, sortActions);
	        }
	    }
	
	    public final function clearActions():void
	    {
	        for each (var action : Action in _actions) removeAction(action);
	    }
	
	    public final function sortActions(event : StardustActionEvent = null) : void
	    {
	        _actions.sort(prioritySort);
	    }
	
	    // descending priority sort
	    private static function prioritySort(el1 : Action, el2 : Action):Number
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