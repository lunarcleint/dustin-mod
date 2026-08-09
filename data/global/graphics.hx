import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.IBitmapDrawable;
import openfl.display.OpenGLRenderer;
import openfl.display.Sprite;
import openfl.display.Shader;
import openfl.display3D.textures.TextureBase;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3DTriangleFace;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;

var gfxBitmap:Bitmap, gfxSprite:Sprite, gfxRenderer:OpenGLRenderer;

function prepareGfxSprite() {
	gfxSprite.__cacheBitmapMatrix.identity();
	gfxSprite.__cacheBitmapColorTransform.__identity();
}

function prepareGfxRenderer() {
	gfxRenderer.__worldTransform.identity();
	gfxRenderer.__worldColorTransform.__identity();
	gfxRenderer.__worldAlpha = 1;

	gfxRenderer.__setBlendMode(BlendMode.NORMAL);
	gfxRenderer.__clearShader();
	//gfxRenderer.__copyShader(cast FlxG.stage.__gfxRenderer);
}

static function captureScreenToBitmapData(?width:Int, height:Int, ?bitmap:BitmapData):BItmapData {
	if ((width == null || width <= 0)) width = FlxG.width * FlxG.scaleMode.scale.x;
	if ((height == null || height <= 0)) height = FlxG.height * FlxG.scaleMode.scale.y;

	prepareGfxSprite();

	if (bitmap == null) bitmap = createBitmapData(width, height);
	else {
		resizeBitmapData(bitmap, width, height);
		clearBitmapData(bitmap);
	}

	final sw = width / FlxG.width, sh = height / FlxG.height;
	final sx = 1 / FlxG.scaleMode.scale.x * sw, sy = 1 / FlxG.scaleMode.scale.y * sh;
	for (camera in FlxG.cameras.list) {
		if (!camera.visible) continue;

		if (camera._helperMatrix == null) camera._helperMatrix = new FlxMatrix();
		camera._helperMatrix.setTo(sx, 0, 0, sy, camera.x * sw, camera.y * sh);

		if (camera.filters == null || camera.filters.length == 0) bitmap.draw(camera._scrollRect, camera._helperMatrix, true);
		else {
			if (gfxSprite.__cacheBitmapData3 == null) gfxSprite.__cacheBitmapData3 = createBitmapData(width, height);
			else {
				resizeBitmapData(gfxSprite.__cacheBitmapData3, width, height);
				clearBitmapData(gfxSprite.__cacheBitmapData3);
			}

			gfxSprite.__cacheBitmapData3.draw(camera._scrollRect, camera._helperMatrix, true);
			applyFiltersToBitmapData(gfxSprite.__cacheBitmapData3, camera.filters);

			camera._helperMatrix.identity();
			bitmap.draw(gfxSprite.__cacheBitmapData3, camera._helperMatrix, false);
		}
	}

	applyFiltersToBitmapData(bitmap, FlxG.game.filters);
	return bitmap;
}

static function createGraphic(width:Int, height:Int, key:String, ?noGpu:Bool):FlxGraphic {
	var graph = (noGpu == true || FlxG.stage.context3D == null) ? FlxG.bitmap.create(width, height, 0, false, key) : FlxG.bitmap.get(key);
	if (graph != null) {
		clearBitmapData(graph.bitmap);
		return resizeGraphic(graph, width, height);
	}

	(graph = FlxGraphic.fromBitmapData(createBitmapData(width, height), false, key, true)).destroyOnNoUse = false;
	return graph;
}

static function createBitmapData(width:Int, height:Int):BitmapData {
	final bitmap = new BitmapData(0, 0, true, 0);
	bitmap.__texture = FlxG.stage.context3D.createTexture(width, height, 1, true);
	bitmap.__textureContext = FlxG.stage.context3D.__context;
	bitmap.__resize(width, height);
	bitmap.__isValid = true;

	return bitmap;
}

static function resizeGraphic(graph:FlxGraphic, width:Int, height:Int):FlxGraphic {
	if (graph.width == width && graph.height == height) return graph;

	resizeBitmapData(graph.bitmap, width, height);

	graph.bitmap = graph.bitmap;

	var frame = graph.imageFrame.frame;
	frame.sourceSize.set(width, height);

	frame.frame.width = width;
	frame.frame.height = height;
	frame.frame = frame.frame;

	return graph;
}

static function resizeBitmapData(bitmap:BitmapData, width:Int, height:Int) {
	bitmap.__resize(width, height);

	// just incase whoever want to resize a cpu image for whatever reason
	if (bitmap.image != null) {
		if (bmap.__surface != null) bmap.__surface.flush();
		bitmap.image.resize(width, height);
	}

	if (bitmap.__texture != null) resizeTexture(bitmap.__texture, width, height);
	else bitmap.getTexture(FlxG.stage.context3D);

	bitmap.__indexBufferContext = bitmap.__framebufferContext = bitmap.__textureContext;
	bitmap.__framebuffer = bitmap.__texture.__glFramebuffer;
	bitmap.__stencilBuffer = bitmap.__texture.__glStencilRenderbuffer;
	bitmap.__vertexBuffer = null;
	bitmap.getVertexBuffer(FlxG.stage.context3D);
}

static function resizeTexture(texture:TextureBase, width:Int, height:Int) {
	if (texture.__alphaTexture != null) resizeTexture(texture, width, height);
	if (width < 1 || height < 1 || (texture.__width == width && texture.__height == height)) return;

	final context = texture.__context;
	final gl = context == null ? null : context.gl;
	if (gl == null) return;

	texture.__width = width = Math.floor(width);
	texture.__height = height = Math.floor(height);

	gl.bindTexture(gl.TEXTURE_2D, texture.__textureID);
	gl.texImage2D(texture.__textureTarget, 0, texture.__internalFormat, width, height, 0, texture.__format, gl.UNSIGNED_BYTE, null);
	updateFramebuffer(texture);
	gl.bindTexture(context.__contextState.__currentGLTexture2D);
}

static function clearBitmapData(bitmap:BitmapData) {
	if (bitmap.__texture != null) {
		final texture = bitmap.__texture;
		if (texture.__glFramebuffer == null) return;

		final context = texture.__context;
		final gl = context == null ? null : context.gl;
		if (gl == null) return;

		context.__flushGLFramebuffer();

		gl.bindFramebuffer(gl.FRAMEBUFFER, texture.__glFramebuffer);

		gl.colorMask(
			context.__contextState.colorMaskRed = true,
			context.__contextState.colorMaskGreen = true,
			context.__contextState.colorMaskBlue = true,
			context.__contextState.colorMaskAlpha = true
		);
		gl.clearColor(0, 0, 0, 0);

		gl.disable(gl.SCISSOR_TEST);
		gl.clear(gl.COLOR_BUFFER_BIT);

		gl.bindFramebuffer(gl.FRAMEBUFFER, context.__contextState.__currentGLFramebuffer);
	}
	else bitmap.__fillRect(bitmap.rect, color, false);
}

static function updateFramebuffer(texture:TextureBase) {
	final context = texture.__context;
	final gl = context == null ? null : context.gl;
	if (gl == null) return;

	if (texture.__glFramebuffer == null) texture.__getGLFramebuffer(false, 0, 0);
	else {
		gl.bindFramebuffer(gl.FRAMEBUFFER, texture.__glFramebuffer);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture.__textureID, 0);

		final seperate = texture.__glDepthRenderbuffer != texture.__glStencilRenderbuffer;
		gl.bindRenderbuffer(gl.RENDERBUFFER, texture.__glDepthRenderbuffer);
		gl.renderbufferStorage(gl.RENDERBUFFER, seperate ? gl.DEPTH_COMPONENT16 : Context3D.__glDepthStencil, texture.__width, texture.__height);
		if (seperate) {
			gl.bindRenderbuffer(gl.RENDERBUFFER, texture.__glStencilRenderbuffer);
			gl.renderbufferStorage(gl.RENDERBUFFER, gl.STENCIL_INDEX8, texture.__width, texture.__height);
		}

		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
	}

	gl.bindFramebuffer(gl.FRAMEBUFFER, context.__contextState.__currentGLFramebuffer);
}

{
	(gfxSprite = new Sprite()).addChild(gfxBitmap = new Bitmap());
	gfxSprite.__cacheBitmapMatrix = new Matrix();
	gfxSprite.__cacheBitmapColorTransform = new ColorTransform();

	var gfxRenderer = null;
	if (FlxG.stage.__renderer != null && FlxG.stage.__renderer.__type == "opengl" && (
		(gfxRenderer = gfxSprite.__cacheBitmapRenderer) == null || gfxRenderer.__type != "opengl"))
	{
		gfxSprite.__cacheBitmapRenderer = gfxRenderer = new OpenGLRenderer(FlxG.stage.context3D);
		gfxRenderer.__worldTransform = new Matrix();
		gfxRenderer.__worldColorTransform = new ColorTransform();
	}
	gfxRenderer.__allowSmoothing = (gfxRenderer.__stage = FlxG.stage).__renderer.__allowSmoothing;

	static function copyBitmapDataFrom(dst:BitmapData, src:BitmapData, ?alpha:Float) {
		if (dst.image != null && src.image != null && alpha == null)
			dst.copyPixels(src, dst.rect, gfxSprite.__tempPoint = gfxSprite.__tempPoint ?? new Point());
		else {
			prepareGfxRenderer();

			if (gfxRenderer == null) {
				gfxBitmap.bitmapData = src;
				if (alpha != null) { // TODO: this doesnt work, need fix
					final colorTransform = new ColorTransform(1, 1, 1, alpha);
					dst.draw(gfxSprite, colorTransform);
				}
				else {
					clear(dst);
					dst.draw(gfxSprite);
				}
			}
			else {
				final context = gfxRenderer.__context3D;
				final cacheRTT = context.__state.renderToTexture,
					cacheRTTDepthStencil = context.__state.renderToTextureDepthStencil,
					cacheRTTAntiAlias = context.__state.renderToTextureAntiAlias,
					cacheRTTSurfaceSelector = context.__state.renderToTextureSurfaceSelector;

				gfxRenderer.__setRenderTarget(dst);
				if (alpha != null) gfxRenderer.__worldAlpha = alpha;
				gfxRenderer.__renderFilterPass(src, gfxRenderer.__defaultDisplayShader, false, false);
		
				if (cacheRTT != null) context.setRenderToTexture(cacheRTT, cacheRTTDepthStencil, cacheRTTAntiAlias, cacheRTTSurfaceSelector);
				else context.setRenderToBackBuffer();
			}
		}
	}

	function prepareCacheBitmapData(bitmap:BitmapData, width:Int, height:Int):BitmapData {
		if (bitmap == null) return createBitmapData(width, height);
		resizeBitmapData(bitmap, width, height);
		return bitmap;
	}

	static function applyShadersToBitmapData(bitmap:BitmapData, shaders:Array<Shader>) {
		prepareGfxRenderer();
		if (gfxRenderer == null) return;

		final width = bitmap.width, height = bitmap.height;
		final context = gfxRenderer.__context3D;
		final cacheRTT = context.__state.renderToTexture,
			cacheRTTDepthStencil = context.__state.renderToTextureDepthStencil,
			cacheRTTAntiAlias = context.__state.renderToTextureAntiAlias,
			cacheRTTSurfaceSelector = context.__state.renderToTextureSurfaceSelector;

		bitmap.getTexture(context);

		var bitmap2 = gfxSprite.__cacheBitmapData2 = prepareCacheBitmapData(gfxSprite.__cacheBitmapData2, width, height);
		var cacheBitmap:BitmapData;
		for (shader in shaders) {
			gfxRenderer.__setRenderTarget(bitmap2);

			clearBitmapData(bitmap2);
			gfxRenderer.__renderFilterPass(cacheBitmap = bitmap, shader, false, false);

			bitmap = bitmap2;
			bitmap2 = cacheBitmap;
		}

		if (bitmap == gfxSprite.__cacheBitmapData2) {
			gfxRenderer.__setRenderTarget(bitmap2);
			gfxRenderer.__renderFilterPass(bitmap, gfxRenderer.__defaultDisplayShader, false, false);
		}

		if (cacheRTT != null) context.setRenderToTexture(cacheRTT, cacheRTTDepthStencil, cacheRTTAntiAlias, cacheRTTSurfaceSelector);
		else context.setRenderToBackBuffer();
	}

	static function applyFiltersToBitmapData(bitmap:BitmapData, filters:Array<BitmapFilter>, ?resizeBitmap:Bool, ?rect:FlxRect) {
		if (filters == null || filters.length == 0) return;
		if (resizeBitmap == null) resizeBitmap = false;

		var width = bitmap.width, height = bitmap.height;
		if (resizeBitmap) {
			final flashRect = Rectangle.__pool.get(), cacheFilters = gfxSprite.__filters;
			gfxSprite.__filters = filters;
			gfxBitmap.bitmapData = bitmap;
			gfxSprite.__getFilterBounds(flashRect, gfxSprite.__cacheBitmapMatrix);
			gfxSprite.__filters = cacheFilters;

			if (rect != null) rect.copyFromFlash(flashRect);
			resizeBitmapData(bitmap, width = Math.floor(flashRect.width), height = Math.floor(flashRect.height));
			Rectangle.__pool.release(flashRect);
		}
		else if (rect != null)
			rect.set(0, 0, width, height);

		var bitmap2 = gfxSprite.__cacheBitmapData2 = prepareCacheBitmapData(gfxSprite.__cacheBitmapData2, width, height);
		var bitmap3 = gfxSprite.__cacheBitmapData3, cacheBitmap:BitmapData;

		prepareGfxRenderer();
		if (bitmap.__texture != null && gfxRenderer != null) {
			final context = gfxRenderer.__context3D;
			final cacheRTT = context.__state.renderToTexture,
				cacheRTTDepthStencil = context.__state.renderToTextureDepthStencil,
				cacheRTTAntiAlias = context.__state.renderToTextureAntiAlias,
				cacheRTTSurfaceSelector = context.__state.renderToTextureSurfaceSelector;

			for (filter in filters) {
				if (filter.__preserveObject) {
					gfxRenderer.__setRenderTarget(bitmap3 = prepareCacheBitmapData(bitmap3, width, height));
					gfxRenderer.__renderFilterPass(bitmap, gfxRenderer.__defaultDisplayShader, filter.__smooth, true);
				}

				for (i in 0...filter.__numShaderPasses) {
					final shader = filter.__initShader(gfxRenderer, i, filter.__preserveObject ? bitmap3 : null);
					gfxRenderer.__setBlendMode(filter.__shaderBlendMode);
					gfxRenderer.__setRenderTarget(bitmap2);

					gfxRenderer.__renderFilterPass(cacheBitmap = bitmap, shader, filter.__smooth, true);
					bitmap = bitmap2;
					bitmap2 = cacheBitmap;
				}

				gfxRenderer.__setBlendMode(BlendMode.NORMAL);
				filter.__renderDirty = false;
			}

			if (bitmap == gfxSprite.__cacheBitmapData2) {
				gfxRenderer.__setRenderTarget(bitmap2);
				gfxRenderer.__renderFilterPass(bitmap, gfxRenderer.__defaultDisplayShader, false, false);
			}

			if (cacheRTT != null) context.setRenderToTexture(cacheRTT, cacheRTTDepthStencil, cacheRTTAntiAlias, cacheRTTSurfaceSelector);
			else context.setRenderToBackBuffer();
		}
		else {
			final destPoint = gfxSprite.__tempPoint = gfxSprite.__tempPoint ?? new Point();
			for (filter in filters) {
				if (filter.__preserveObject)
					(bitmap3 = prepareCacheBitmapData(bitmap3, width, height)).copyPixels(bitmap, bitmap.rect, destPoint);

				cacheBitmap = filter.__applyFilter(bitmap2, bitmap, bitmap.rect, destPoint);

				if (filter.__preserveObject) cacheBitmap.draw(bitmap3);
				if (cacheBitmap == bitmap2) copyBitmapDataFrom(bitmap, bitmap2, false);
			}
		}

		gfxSprite.__cacheBitmapData3 = bitmap3;
	}

	static function drawToBitmapData(dst:BitmapData, src:DisplayObject, ?matrix:Matrix, smoothing = false) {
		prepareGfxRenderer();

		final context = gfxRenderer.__context3D;
		final cacheRTT = context.__state.renderToTexture,
			cacheRTTDepthStencil = context.__state.renderToTextureDepthStencil,
			cacheRTTAntiAlias = context.__state.renderToTextureAntiAlias,
			cacheRTTSurfaceSelector = context.__state.renderToTextureSurfaceSelector;

		gfxSprite.__visible = src.__visible;
		src.__visible = true;

		src.__update(false, true);
		if (src.__renderable) {
			dst.__textureContext = context.__context;

			context.setRenderToTexture(dst.getTexture(context), true);
			context.setColorMask(true, true, true, true);
			context.setCulling(Context3DTriangleFace.NONE);
			context.setStencilActions();
			context.setStencilReferenceValue(0, 0, 0);
			context.setScissorRectangle(null);

			gfxSprite.__cacheBitmapColorTransform.__copyFrom(src.__worldColorTransform);
			gfxSprite.__mask = src.__mask; gfxSprite.__scrollRect = src.__scrollRect;

			src.__worldColorTransform.__identity();
			src.__worldAlpha = 1; src.__mask = null; src.__scrollRect = null;

			gfxRenderer.__allowSmoothing = smoothing;
			gfxRenderer.__blendMode = null;
			gfxRenderer.__setBlendMode(BlendMode.NORMAL);
			gfxRenderer.__setRenderTarget(dst);
			gfxRenderer.__pixelRatio = #if openfl_disable_hdpi 1 #else FlxG.stage.window.scale #end;

			gfxRenderer.__worldTransform.copyFrom(src.__renderTransform);
			gfxRenderer.__worldTransform.invert();
			if (matrix != null) gfxRenderer.__worldTransform.concat(matrix);

			gfxRenderer.__renderDrawable(src);

			context.present();
			src.__worldColorTransform.__copyFrom(gfxSprite.__cacheBitmapColorTransform);
			src.__mask = gfxSprite.__mask; src.__scrollRect = gfxSprite.__scrollRect;
			gfxSprite.__mask = null; gfxSprite.__scrollRect = null;
		}

		src.__visible = gfxSprite.__visible;
		gfxSprite.__visible = true;
	}
}