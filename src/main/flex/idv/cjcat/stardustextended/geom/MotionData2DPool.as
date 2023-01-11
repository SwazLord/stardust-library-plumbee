package idv.cjcat.stardustextended.geom
{
	public class MotionData2DPool
	{
	
	    protected static const _recycled : Vector.<MotionData2D> = new <MotionData2D>[];
	
	    [Inline]
	    public static function get(x:Number = 0, y:Number = 0):MotionData2D
	    {
	        var obj:MotionData2D;
			
	        if (_recycled.length > 0)
			{
	            obj = _recycled.pop();
	            obj.setTo(x, y);
	        }
	        else
			{
	            obj = new MotionData2D(x, y);
	        }
	
	        return obj;
	    }
	
	    [Inline]
	    public static function recycle(obj:MotionData2D):void
	    {
	        _recycled.push(obj);
	    }
	}
}