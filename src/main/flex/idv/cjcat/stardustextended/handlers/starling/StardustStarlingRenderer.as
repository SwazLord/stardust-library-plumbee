package idv.cjcat.stardustextended.handlers.starling
{

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import idv.cjcat.stardustextended.particles.Particle;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.filters.FragmentFilter;
	import starling.rendering.Painter;
	import starling.textures.Texture;
	
	public class StardustStarlingRenderer extends DisplayObject
	{
	    /** The offset of position data (x, y) within a vertex. */
	    private static const POSITION_OFFSET:int = 0;
	    /** The offset of color data (r, g, b, a) within a vertex. */
	    private static const COLOR_OFFSET:int = 2;
	    /** The offset of texture coordinates (u, v) within a vertex. */
	    private static const TEXCOORD_OFFSET:int = 6;
	
	    public static const MAX_POSSIBLE_PARTICLES:int = 16383;
	    private static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
	    private static const sCosLUT : Vector.<Number> = new Vector.<Number>(0x800, true);
	    private static const sSinLUT : Vector.<Number> = new Vector.<Number>(0x800, true);
	    private static const renderAlpha : Vector.<Number> = new Vector.<Number>(4);

	    private static var numberOfVertexBuffers : int;
	    private static var maxParticles : int;
	    private static var initCalled : Boolean = false;
	    
	    private var boundsRect : Rectangle;
	    private var mFilter : FragmentFilter;
	    private var mTexture : Texture;
	    private var mBatched : Boolean;
	    private var vertexes : Vector.<Number>;
	    private var frames : Vector.<Frame>;
	
	    public var mNumParticles : int = 0;
	    public var texSmoothing : String;
	    public var premultiplyAlpha : Boolean = true;
	
		private var _id:Number;
	
	    public function StardustStarlingRenderer()
	    {
	        if(initCalled == false)
			{
	            init();
	        }
			
	        vertexes = new <Number>[];
	    }
	
	    /** numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering.
	     *  Multi buffering can avoid stalling of the GPU but will also increases it's memory consumption.
	     *  If you want to avoid stalling create the same amount of buffers as your maximum rendered emitters at the
	     *  same time.
	     *  Allocating one buffer with the maximum amount of particles (16383) takes up 2048KB(2MB) GPU memory.
	     *  This call requires that there is a Starling context
	     **/
	    public static function init(numberOfBuffers : uint = 2, maxParticlesPerBuffer : uint = MAX_POSSIBLE_PARTICLES) : void
	    {
	        numberOfVertexBuffers = numberOfBuffers;
			
	        if(maxParticlesPerBuffer > MAX_POSSIBLE_PARTICLES)
			{
	            maxParticlesPerBuffer = MAX_POSSIBLE_PARTICLES;
	            trace("StardustStarlingRenderer WARNING: Tried to render than 16383 particles, setting value to 16383");
	        }
	
	        maxParticles = maxParticlesPerBuffer;
	        StarlingParticleBuffers.createBuffers(maxParticlesPerBuffer, numberOfBuffers);
	
	        if (!initCalled)
			{
	            for (var i : int = 0; i < 0x800; ++i)
				{
	                sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
	                sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
	            }
	
	            // handle a lost device context
	            Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
	            initCalled = true;
	        }
	    }
	
	    private static function onContextCreated(event : Event) : void
	    {
	        StarlingParticleBuffers.createBuffers(maxParticles, numberOfVertexBuffers);
	    }
	
	    public function setTextures(texture : Texture, _frames : Vector.<Frame>) : void
	    {
	        mTexture = texture;
	        frames = _frames;
	    }
		
		private var particle : Particle;
		private var vertexID : int = 0;
		
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		private var particleAlpha:Number;
		
		private var _rotation:Number;
		private var xPos:Number, yPos:Number;
		private var xOffset:Number, yOffset:Number;
		
		private var angle:uint;
		private var cos:Number;
		private var sin:Number;
		private var cosX:Number;
		private var cosY:Number;
		private var sinX:Number;
		private var sinY:Number;
		private var position:uint;
		private var frame:Frame;
		private var bottomRightX:Number;
		private var bottomRightY:Number;
		private var topLeftX:Number;
		private var topLeftY:Number;
	
		private var _i:int;
		
		[Inline]
	    final public function advanceTime(mParticles : Vector.<Particle>):void
	    {
	        mNumParticles = mParticles.length;
	        vertexes.fixed = false;
	        vertexes.length = mNumParticles * 32;
	        vertexes.fixed = true;
	
	        for(_i = 0; _i < mNumParticles; ++_i)
			{
	            vertexID = _i << 2;
	            particle = mParticles[_i];

	            // color & alpha
	            particleAlpha = particle.alpha;
				
	            if(premultiplyAlpha)
				{
	                red = particle.colorR * particleAlpha;
	                green = particle.colorG * particleAlpha;
	                blue = particle.colorB * particleAlpha;
	            }
	            else
				{
	                red = particle.colorR;
	                green = particle.colorG;
	                blue = particle.colorB;
	            }

	            // position & rotation
				_rotation = particle.rotation * DEGREES_TO_RADIANS;
	            xPos = particle.x;
	            yPos = particle.y;
	            // texture
	            frame = frames[particle.currentAnimationFrame];
	            bottomRightX = frame.bottomRightX;
	            bottomRightY = frame.bottomRightY;
	            topLeftX = frame.topLeftX;
	            topLeftY = frame.topLeftY;
	            xOffset = frame.particleHalfWidth * particle.scale;
	            yOffset = frame.particleHalfHeight * particle.scale;
	
	            position = vertexID << 3; // * 8
				
	            if (_rotation)
				{
	                angle = (_rotation * 325.94932345220164765467394738691) & 2047;
	                cos = sCosLUT[angle];
	                sin = sSinLUT[angle];
	                cosX = cos * xOffset;
	                cosY = cos * yOffset;
	                sinX = sin * xOffset;
	                sinY = sin * yOffset;
	
	                vertexes[position] = xPos - cosX + sinY;  // 0,1: position (in pixels)
	                vertexes[++position] = yPos - sinX - cosY;
	                vertexes[++position] = red;// 2,3,4,5: Color and Alpha [0-1]
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = topLeftX; // 6,7: Texture coords [0-1]
	                vertexes[++position] = topLeftY;
	
	                vertexes[++position] = xPos + cosX + sinY;
	                vertexes[++position] = yPos + sinX - cosY;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = bottomRightX;
	                vertexes[++position] = topLeftY;
	
	                vertexes[++position] = xPos - cosX - sinY;
	                vertexes[++position] = yPos - sinX + cosY;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = topLeftX;
	                vertexes[++position] = bottomRightY;
	
	                vertexes[++position] = xPos + cosX - sinY;
	                vertexes[++position] = yPos + sinX + cosY;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = bottomRightX;
	                vertexes[++position] = bottomRightY;
	            }
	            else
				{
	                vertexes[position] = xPos - xOffset;
	                vertexes[++position] = yPos - yOffset;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = topLeftX;
	                vertexes[++position] = topLeftY;
	
	                vertexes[++position] = xPos + xOffset;
	                vertexes[++position] = yPos - yOffset;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = bottomRightX;
	                vertexes[++position] = topLeftY;
	
	                vertexes[++position] = xPos - xOffset;
	                vertexes[++position] = yPos + yOffset;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = topLeftX;
	                vertexes[++position] = bottomRightY;
	
	                vertexes[++position] = xPos + xOffset;
	                vertexes[++position] = yPos + yOffset;
	                vertexes[++position] = red;
	                vertexes[++position] = green;
	                vertexes[++position] = blue;
	                vertexes[++position] = particleAlpha;
	                vertexes[++position] = bottomRightX;
	                vertexes[++position] = bottomRightY;
	            }
	        }
	    }
	
		[Inline]
	    final protected function isStateChange(texture:TextureBase,
	                                     	   smoothing:String,
											   blendMode:String,
											   filter:FragmentFilter,
	                                     	   premultiplyAlpha:Boolean,
											   numParticles:uint):Boolean
	    {
	        if (mNumParticles == 0)
			{
	            return false;
	        }
	        else if(mNumParticles + numParticles > MAX_POSSIBLE_PARTICLES)
			{
	            return true;
	        }
	        else if(mTexture != null && texture != null)
			{
	            return mTexture.base != texture || texSmoothing != smoothing || this.blendMode != blendMode ||
	                   mFilter != filter || this.premultiplyAlpha != premultiplyAlpha;
	        }

	        return true;
	    }
	
	    public override function render(painter : Painter):void
	    {
	        painter.excludeFromCache(this); // for some reason it doesnt work if inside the if. Starling bug?
			
	        if (mNumParticles > 0 && !mBatched)
			{
	            var mNumBatchedParticles : int = batchNeighbours();
	            var parentAlpha : Number = parent ? parent.alpha : 1;
	            renderCustom(painter, mNumBatchedParticles, parentAlpha);
	        }

	        //reset filter
	        super.filter = mFilter;
	        mBatched = false;
	    }
	
		[Inline]
	    final protected function batchNeighbours():int
	    {
	        var mNumBatchedParticles : int = 0;
	        var last : int = parent.getChildIndex(this);
			var isStateChange:Boolean;
			
			var targetIndex:int, sourceIndex:int, sourceEnd:int;
			
	        while (++last < parent.numChildren)
			{
	            var nextPS:StardustStarlingRenderer = parent.getChildAt(last) as StardustStarlingRenderer;
				
				isStateChange = nextPS.isStateChange(mTexture.base, texSmoothing, blendMode, mFilter, premultiplyAlpha, mNumParticles);
				
	            if (nextPS && !isStateChange)
				{
	                if (nextPS.mNumParticles > 0)
					{
	                    vertexes.fixed = false;

	                    targetIndex = (mNumParticles + mNumBatchedParticles) * 32; // 4 * 8
	                    sourceIndex = 0;
	                    sourceEnd = nextPS.mNumParticles * 32; // 4 * 8
						
	                    while (sourceIndex < sourceEnd)
						{
	                        vertexes[int(targetIndex++)] = nextPS.vertexes[int(sourceIndex++)];
	                    }

	                    vertexes.fixed = true;
	
	                    mNumBatchedParticles += nextPS.mNumParticles;
	
	                    nextPS.mBatched = true;
	
	                    //disable filter of batched system temporarily
	                    nextPS.filter = null;
	                }
	            }
	            else
				{
	                break;
	            }
	        }

	        return mNumBatchedParticles;
	    }
	
	    private function renderCustom(painter:Painter, mNumBatchedParticles:int, parentAlpha:Number):void
	    {
	        if (mNumParticles === 0 || StarlingParticleBuffers.buffersCreated === false)
			{
	            return;
	        }
			
	        if(mNumBatchedParticles > maxParticles)
			{
	            trace("Over " + maxParticles + " particles! Aborting rendering");
	            return
	        }

	        StarlingParticleBuffers.switchVertexBuffer();
	
	        var context : Context3D = Starling.context;
			
	        if(context === null)
			{
	            throw new MissingContextError();
	        }
			
			painter.finishMeshBatch();
			painter.drawCount += 1;
			painter.prepareToDraw();
			
	        BlendMode.get(blendMode).activate();
	
	        renderAlpha[0] = renderAlpha[1] = renderAlpha[2] = premultiplyAlpha ? parentAlpha : 1;
	        renderAlpha[3] = parentAlpha;
	
	        ParticleProgram.getProgram(mTexture.mipMapping, mTexture.format, texSmoothing).activate(); // calls context.setProgram(_program3D);
	        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, renderAlpha, 1);
	        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, painter.state.mvpMatrix3D, true);
	
	        context.setTextureAt(0, mTexture.base);
	        StarlingParticleBuffers.vertexBuffer.uploadFromVector(vertexes, 0, Math.min(maxParticles * 4, vertexes.length / 8));
	        context.setVertexBufferAt(0, StarlingParticleBuffers.vertexBuffer, POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
	        context.setVertexBufferAt(1, StarlingParticleBuffers.vertexBuffer, COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
	        context.setVertexBufferAt(2, StarlingParticleBuffers.vertexBuffer, TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
	
	        context.drawTriangles(StarlingParticleBuffers.indexBuffer, 0, (Math.min(maxParticles, mNumParticles + mNumBatchedParticles)) * 2);
	
	        context.setVertexBufferAt(0, null);
	        context.setVertexBufferAt(1, null);
	        context.setVertexBufferAt(2, null);
	        context.setTextureAt(0, null);
	    }
	
	    public override function set filter(value : FragmentFilter) : void
	    {
	        if(!mBatched)
			{
	            mFilter = value;
	        }
			
	        super.filter = value;
	    }
	
	    /**
	     * Stardust does not calculate the bounds of the simulation. In the future this would be possible, but
	     * will be a performance heavy operation.
	     */
	    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
	    {
	        if(boundsRect == null)
			{
	            boundsRect = new Rectangle();
	        }

	        return boundsRect;
	    }
	}
}
