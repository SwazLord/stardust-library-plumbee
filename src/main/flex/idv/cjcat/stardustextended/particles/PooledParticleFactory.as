package idv.cjcat.stardustextended.particles
{
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.InitializerCollection;

public class PooledParticleFactory
{

    private var _initializerCollection : InitializerCollection;

    public function PooledParticleFactory()
    {
        _initializerCollection = new InitializerCollection();
    }

    /**
     * Creates particles with associated initializers.
     * @param count
     * @param currentTime
     * @param toVector The vector the particles will be added to to prevent object allocation
     * @return the newly created particles
     */
	[Inline]
    public final function createParticles(count : int, currentTime : Number, toVector : Vector.<Particle> = null):Vector.<Particle>
    {
        var particles : Vector.<Particle> = toVector;
		
        if (particles === null)
		{
            particles = new Vector.<Particle>();
        }
		
        if (count > 0)
		{
            var i : int;

            for (i = 0; i < count; i++)
			{
                var particle : Particle = ParticlePool.get();
				
                particle.init();
                particles.push(particle);
            }

            var initializers : Vector.<Initializer> = _initializerCollection.initializers;
            var len : uint = initializers.length;
			
            for (i = 0; i < len; ++i)
			{
                initializers[i].doInitialize(particles, currentTime);
            }
        }

        return particles;
    }

    /**
     * Adds an initializer to the factory.
     * @param    initializer
     */
    public function addInitializer(initializer : Initializer) : void
    {
        _initializerCollection.addInitializer(initializer);
    }

    /**
     * Removes an initializer from the factory.
     * @param    initializer
     */
    public final function removeInitializer(initializer : Initializer) : void
    {
        _initializerCollection.removeInitializer(initializer);
    }

    /**
     * Removes all initializers from the factory.
     */
    public final function clearInitializers() : void
    {
        _initializerCollection.clearInitializers();
    }

    public function get initializerCollection() : InitializerCollection
    {
        return _initializerCollection;
    }

    [Inline]
    public final function recycle(particle : Particle) : void
    {
        ParticlePool.recycle(particle);
    }
}
}