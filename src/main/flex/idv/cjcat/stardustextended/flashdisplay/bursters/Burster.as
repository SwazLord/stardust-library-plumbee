﻿package idv.cjcat.stardustextended.flashdisplay.bursters
{
	import idv.cjcat.stardustextended.emitters.Emitter;
	import idv.cjcat.stardustextended.initializers.Initializer;
	import idv.cjcat.stardustextended.initializers.InitializerCollector;
	import idv.cjcat.stardustextended.particles.Particle;
	import idv.cjcat.stardustextended.particles.PooledParticleFactory;
	
	/**
	 * Allows users to create particles and fully customize their properties.
	 *
	 * <p>
	 * If you don't want to create random particles as Stardust does,
	 * you can use bursters to create particles with properties of exact given values.
	 * </p>
	 */
	public class Burster implements InitializerCollector
	{
	
		public function Burster():void
		{
			
		}
	
	    /**
	     * The internal factory for the burster.
	     * Use its <code>createParticles()</code> method to create particles,
	     * initialized by initializers added to the burster.
	     */
	    protected var factory : PooledParticleFactory;
	
	    /**
	     * Adds particles created by the <code>createParticles()</code> method to an emitter.
	     * @param    emitter
	     * @param    currentTime
	     */
	    public final function burst(emitter : Emitter, currentTime : Number) : void
	    {
	        emitter.addParticles(createParticles(currentTime));
	    }
	
	    /**
	     * [Abstract Method] Creates an array of particles.
	     * Override this method to alter the particles' properties as you see fit.
	     * @return
	     */
	    public function createParticles(currentTime : Number) : Vector.<Particle>
	    {
	        //abstract method
	        return null;
	    }
	
	    /**
	     * Adds an initializer to the burster.
	     * @param    initializer
	     */
	    public final function addInitializer(initializer : Initializer) : void
	    {
	        factory.addInitializer(initializer);
	    }
	
	    /**
	     * Removes an initializer to the burster.
	     * @param    initializer
	     */
	    public final function removeInitializer(initializer : Initializer) : void
	    {
	        factory.removeInitializer(initializer);
	    }
	
	    /**
	     * Removes all initializers from the burster.
	     */
	    public final function clearInitializers() : void
	    {
	        factory.clearInitializers();
	    }
	}
}