package idv.cjcat.stardustextended.geom
{
	public class Vec2DPool
	{
	    protected static const _recycled:Vector.<Vec2D> = new <Vec2D>[];
	
	    [Inline]
	    public static function get(x : Number = 0, y : Number = 0) : Vec2D
	    {
	        var obj : Vec2D;
			
	        if (_recycled.length > 0)
			{
	            obj = _recycled.pop();
	            obj.setTo(x, y);
	        }
	        else
			{
	            obj = new Vec2D(x, y);
	        }

	        return obj;
	    }
	
	    [Inline]
	    public static function recycle(obj : Vec2D) : void
	    {
	        _recycled.push(obj);
	    }
	}
}