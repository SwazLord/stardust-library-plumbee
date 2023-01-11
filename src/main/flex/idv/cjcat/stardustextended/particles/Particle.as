package idv.cjcat.stardustextended.particles
{
	import flash.utils.Dictionary;
	
	/**
	 * This class represents a particle and its properties.
	 */
	public class Particle
	{
	    /**
	     * The initial life upon birth.
	     */
	    public var initLife : Number;
	    /**
	     * The normal scale upon birth.
	     */
	    public var initScale : Number;
	    /**
	     * The normal alpha value upon birth.
	     */
	    //[Deprecated(message="initAlpha property will be soon removed, use ColorGradient")]
	    public var initAlpha : Number;
	
	    /**
	     * The remaining life of the particle.
	     */
	    public var life : Number;
	    /**
	     * The scale of the particle.
	     */
	    public var scale : Number;
	    /**
	     * The alpha value of the particle.
	     */
	    public var alpha : Number;
	    /**
	     * The mass of the particle.
	     */
	    public var mass : Number;
	
	    /**
	     * Whether the particle is marked as dead.
	     *
	     * <p>
	     * Dead particles would be removed from simulation by an emitter.
	     * </p>
	     */
	    public var isDead : Boolean;
	    /**
	     * The collision radius of the particle.
	     */
	    public var collisionRadius : Number;
	    /**
	     * Custom user data of the particle.
	     *
	     * <p>
	     * Normally, this property contains information for renderers.
	     * For instance this property should refer to a display object for a <code>DisplayObjectRenderer</code>.
	     * </p>
	     */
	    public var target : *;
	
	    /**
	     * current Red color component; in the [0,1] range.
	     */
	    public var colorR : Number;
	    /**
	     * current Green color component; in the [0,1] range.
	     */
	    public var colorG : Number;
	    /**
	     * current Blue color component; in the [0,1] range.
	     */
	    public var colorB : Number;
	
	    /**
	     * Dictionary for storing additional information.
	     */
	    public var dictionary : Dictionary;
	
	    /**
	     * Particle handlers use this property to determine which frame to display if the particle is animated
	     */
	    public var currentAnimationFrame : int = 0;
	
	    public var x : Number;
	    public var y : Number;
	    public var vx : Number;
	    public var vy : Number;
	    public var rotation : Number;
	    public var omega : Number;
	
	    public function Particle()
	    {
	        dictionary = new Dictionary();
	    }
	
	    /**
	     * Initializes properties to default values.
	     */
		[Inline]
	    final public function init():void
	    {
	        initLife = life = currentAnimationFrame = 0;
	        initScale = scale = 1;
	        initAlpha = alpha = 1;
	        mass = 1;
	        isDead = false;
	        collisionRadius = 0;
	
	        colorR = 1;
	        colorB = 1;
	        colorG = 1;
	
	        x = 0;
	        y = 0;
	        vx = 0;
	        vy = 0;
	        rotation = 0;
	        omega = 0;
	    }
	
	    public function destroy():void
	    {
	        target = null;
	        var key : *;
			
	        for(key in dictionary)
			{
				dictionary[key] = null;
				delete dictionary[key];
			}
	    }
	
		[Inline]
	    public static function compareFunction(p1:Particle, p2:Particle):Number
	    {
	        if (p1.x < p2.x)
	        {
	            return -1;
	        }
	
	        return 1;
	    }
	}
}