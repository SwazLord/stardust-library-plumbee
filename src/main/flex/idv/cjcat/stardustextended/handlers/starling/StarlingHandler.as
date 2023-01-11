package idv.cjcat.stardustextended.handlers.starling
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ISpriteSheetHandler;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

import starling.display.BlendMode;
import starling.display.DisplayObjectContainer;
import starling.textures.SubTexture;
import starling.textures.TextureSmoothing;

public class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler
{
    private var _blendMode : String = BlendMode.NORMAL;
    private var _spriteSheetAnimationSpeed : uint = 1;
    private var _smoothing : String = TextureSmoothing.NONE;
    private var _isSpriteSheet : Boolean;
    private var _premultiplyAlpha : Boolean = true;
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _totalFrames : uint;
    private var _textures : Vector.<SubTexture>;
    private var _renderer : StardustStarlingRenderer;
    private var timeSinceLastStep : Number;

    public function StarlingHandler() : void
    {
        timeSinceLastStep = 0;
    }

    override public function reset() : void
    {
        timeSinceLastStep = 0;
        _renderer.advanceTime(new Vector.<Particle>);
    }

    public function set container(container:DisplayObjectContainer):void
    {
        createRendererIfNeeded();
        container.addChild(_renderer);
    }

    public function createRendererIfNeeded():void
    {
        if(_renderer == null)
		{
            _renderer = new StardustStarlingRenderer();
            _renderer.blendMode = _blendMode;
            _renderer.texSmoothing = _smoothing;
            _renderer.premultiplyAlpha = _premultiplyAlpha;
        }
    }

	private var _stepSize:uint;
	private var _mNumParticles:uint;
	
	private var _particle:Particle;
	private var _currentFrame:int;

	private var _i:int;
	
	[Inline]
    override public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {
        if (_isSpriteSheet && _spriteSheetAnimationSpeed > 0)
		{
            timeSinceLastStep = timeSinceLastStep + time;

            if(timeSinceLastStep > 1/_spriteSheetAnimationSpeed)
            {
				_stepSize = Math.floor(timeSinceLastStep * _spriteSheetAnimationSpeed);
				_mNumParticles = particles.length;
				
                for(_i = 0; _i < _mNumParticles; ++_i)
				{
					_particle = particles[_i];
					_currentFrame = _particle.currentAnimationFrame;
					
					_currentFrame = _currentFrame + _stepSize;
					
                    if(_currentFrame >= _totalFrames)
					{
						_currentFrame = 0;
                    }
					
					_particle.currentAnimationFrame = _currentFrame;
                }

                timeSinceLastStep = 0;
            }
        }

        _renderer.advanceTime(particles);
    }

	[Inline]
    final override public function particleAdded(particle : Particle) : void
    {
        if (_isSpriteSheet)
		{
            var currFrame : uint = 0;

            if(_spriteSheetStartAtRandomFrame)
			{
                currFrame = Math.random() * _totalFrames;
            }

            particle.currentAnimationFrame = currFrame;
        }
        else
		{
            particle.currentAnimationFrame = 0;
        }
    }

    public function get renderer():StardustStarlingRenderer
    {
        return _renderer;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed : uint) : void
    {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;

        if (_textures)
		{
            setTextures(_textures);
        }
    }

    public function get spriteSheetAnimationSpeed() : uint
    {
        return _spriteSheetAnimationSpeed;
    }

    public function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame : Boolean) : void
    {
        _spriteSheetStartAtRandomFrame = spriteSheetStartAtRandomFrame;
    }

    public function get spriteSheetStartAtRandomFrame() : Boolean
    {
        return _spriteSheetStartAtRandomFrame;
    }

    public function get isSpriteSheet() : Boolean
    {
        return _isSpriteSheet;
    }

    public function get smoothing() : Boolean
    {
        return _smoothing != TextureSmoothing.NONE;
    }

    public function set smoothing(value : Boolean) : void
    {
        if (value == true) {
            _smoothing = TextureSmoothing.BILINEAR;
        }
        else {
            _smoothing = TextureSmoothing.NONE;
        }
        createRendererIfNeeded();
        _renderer.texSmoothing = _smoothing;
    }

    public function get premultiplyAlpha() : Boolean
    {
        return _premultiplyAlpha;
    }

    public function set premultiplyAlpha(value : Boolean) : void
    {
        _premultiplyAlpha = value;
        createRendererIfNeeded();
        _renderer.premultiplyAlpha = value;
    }

    public function set blendMode(blendMode : String) : void
    {
        _blendMode = blendMode;
        createRendererIfNeeded();
        _renderer.blendMode = blendMode;
    }

    public function get blendMode() : String
    {
        return _blendMode;
    }

    /** Sets the textures directly. Stardust can batch the simulations resulting multiple simulations using
     *  just one draw call. To have this working the following must be met:
     *  - The textures must come from the same sprite sheet. (= they must have the same base texture)
     *  - The simulations must have the same render target, smoothing, blendMode, same filter
     *    and the same premultiplyAlpha values.
     **/

    final public function setTextures(textures:Vector.<SubTexture>):void
    {
        if (textures == null || textures.length == 0)
		{
            throw new ArgumentError("the textures parameter cannot be null and needs to hold at least 1 element");
        }
		
        createRendererIfNeeded();
		
        _isSpriteSheet = textures.length > 1;
        _textures = textures;
		
        var frames : Vector.<Frame> = new <Frame>[];
		
        for each (var texture : SubTexture in textures) {
            if (texture.root != textures[0].root) {
                throw new Error("The texture " + texture + " does not share the same base root with others");
            }
            // TODO use the transformationMatrix
            var frame : Frame = new Frame(
                    texture.region.x / texture.root.width,
                    texture.region.y / texture.root.height,
                    (texture.region.x + texture.region.width) / texture.root.width,
                    (texture.region.y + texture.region.height) / texture.root.height,
                    texture.width * 0.5,
                    texture.height * 0.5);
            frames.push(frame);
        }
        _totalFrames = frames.length;
        _renderer.setTextures(textures[0].root, frames);
    }

    public function get textures() : Vector.<SubTexture>
    {
        return _textures;
    }

    //////////////////////////////////////////////////////// XML
    override public function getXMLTagName() : String
    {
        return "StarlingHandler";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@spriteSheetAnimationSpeed = _spriteSheetAnimationSpeed;
        xml.@spriteSheetStartAtRandomFrame = _spriteSheetStartAtRandomFrame;
        xml.@smoothing = smoothing;
        xml.@blendMode = _blendMode;
        xml.@premultiplyAlpha = _premultiplyAlpha;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        _spriteSheetAnimationSpeed = parseFloat(xml.@spriteSheetAnimationSpeed);
        _spriteSheetStartAtRandomFrame = (xml.@spriteSheetStartAtRandomFrame == "true");
        smoothing = (xml.@smoothing == "true");
        blendMode = (xml.@blendMode);
        premultiplyAlpha = (xml.@premultiplyAlpha == "true");
    }

}
}
