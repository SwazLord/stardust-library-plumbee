package idv.cjcat.stardustextended.actions
{
	import idv.cjcat.stardustextended.emitters.Emitter;
	import idv.cjcat.stardustextended.particles.Particle;
	
	/**
	 * Mark a particle as dead if its life reaches zero.
	 * <p>
	 * Remember to add this action to the emitter if you wish particles to be removed from simulation when their lives reach zero.
	 * Otherwise, the particles will not be removed.
	 * </p>
	 */
	public class DeathLife extends Action
	{
	
		[Inline]
	    override public final function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void
	    {
	        if(particle.life <= 0)
			{
	            particle.isDead = true;
	        }
	    }
	
	
	    //XML
	    //------------------------------------------------------------------------------------------------
	
	    override public function getXMLTagName() : String
	    {
	        return "DeathLife";
	    }
	
	    //------------------------------------------------------------------------------------------------
	    //end of XML
	}
}