import openfl.display.BlendMode;
import openfl.display.ShaderPrecision;
import openfl.geom.ColorTransform;
import flixel.FlxStrip;

public var heat:CustomShader;

var bloomShader:CustomShader;
var bloomHUDShader:CustomShader;
var darkenShader:CustomShader;

var tankmanGhostChar;
var steveGhostChar;
var drummerGhostChar;
var picoChar;
var playerChar;

var backgroundCamera:FlxCamera;
var backgroundSpriteBuffer:FunkinSprite;

var ghostCamera:FlxCamera;
var ghostSpriteBuffer:FunkinSprite;

var time:Float = 0;
var iTime:Array<Float> = [];
var floatPhase:Float = 0;

var baseTankmanGhostX:Float;
var baseTankmanGhostY:Float;
var baseSteveGhostX:Float;
var baseSteveGhostY:Float;

var currentFloatRadius:Float = 20;
var currentFloatSpeed:Float = 2;

var targetFloatRadius:Float = 20;
var targetFloatSpeed:Float = 2;

var drummerFloatPhase:Float = 0;
var drummerBaseX:Float = 0;
var drummerBaseY:Float = 0;
var drummerMotionActive:Bool = false;

var steveChar;
var canFloat:Bool = true;
var isResetting:Bool = false;

var titleCardUprising:FunkinSprite;
var picoIsHereLabel:FunkinSprite;

function createSpriteBuffer(key:String):Array<Dynamic> {
	var spriteBuffer = new FunkinSprite(0, 0, createGraphic(1, 1, key));
	spriteBuffer.graphic.persist = false;
	spriteBuffer.scrollFactor.set(0, 0);
	spriteBuffer.zoomFactor = 0;
	spriteBuffer.antialiasing = true;

	var camera = new FlxCamera();
	FlxG.cameras.insert(camera, FlxG.cameras.list.indexOf(camGame), false);

	return [spriteBuffer, camera];
}

function preDrawSpriteBuffer(camera:FlxCamera) {
	camera.visible = true;
	camera.clearDrawStack();
	camera.canvas.graphics.clear();
	#if FLX_DEBUG
	camera.debugLayer.graphics.clear();
	#end
}

function postDrawSpriteBuffer(spriteBuffer:FlxSprite, camera:FlxCamera, resolution:Float) {
	camera.zoom = camGame.getActualZoom();
	camera.scroll.copyFrom(camGame.scroll);
	camera.angle = camGame.angle;

	camera.update();
	camera.render();

	final display = camera._scrollRect;
	final rect = display.__scrollRect;
	camera._helperMatrix.identity();
	camera._helperMatrix.a = camera._helperMatrix.d = resolution;
	resizeGraphic(spriteBuffer.graphic, rect.width * resolution + 2, rect.height * resolution + 2);
	clearBitmapData(spriteBuffer.pixels);
	drawToBitmapData(spriteBuffer.pixels, display, camera._helperMatrix, resolution != 1.0);
	spriteBuffer.frames = spriteBuffer.graphic.imageFrame;
	spriteBuffer.angle = -camGame.angle;
	final marginX = 1.0 / FlxG.scaleMode.scale.x, marginY = 1.0 / FlxG.scaleMode.scale.y;
	spriteBuffer.setPosition(-1, -marginY);
	spriteBuffer.setGraphicSize(FlxG.width + marginX * 2, FlxG.height + marginY * 2);
	spriteBuffer.updateHitbox();

	camera.visible = false;
}

function create() {
	var backgroundColorSprite = new FlxSprite(-1800, -600).makeSolid(6000, 1400, 0xFFDE861A);
	insert(0, backgroundColorSprite);

	darkenShader = new CustomShader('darkenbutlights');
	darkenShader.tint = [0.042, 0.032, 0.15, 0.9];
	darkenShader.threshold = 0.105;
	darkenShader.gradientY = 0.32;
	darkenShader.gradientHeight = 0.125;

	camGame.addShader(darkenShader);

	sun.blend = BlendMode.ADD;
	sun.alpha = 0.55;

	heat = new CustomShader("heatwave");
	heat.data.time.value = iTime;
	heat.speed = 0.2; 
	heat.even = false;
	heat.strength = 0.4;

	titleCardUprising = new FunkinSprite(247, 300, Paths.image("stages/surface/text_appear2"));
	titleCardUprising.scale.set(0.55, 0.55);
	titleCardUprising.updateHitbox();
	titleCardUprising.scrollFactor.set(0.8, 0.8);
	titleCardUprising.zoomFactor = 0.5;
	titleCardUprising.antialiasing = true;

	picoIsHereLabel = new FunkinSprite(-90, 230, Paths.image("stages/surface/text_appear"));
	picoIsHereLabel.scrollFactor.set(0.65, 0.65);
	picoIsHereLabel.zoomFactor = 0.75;
	picoIsHereLabel.scale.set(1.5, 1.5);
	picoIsHereLabel.updateHitbox();
	picoIsHereLabel.color = 0xFFAAAAAA;
	picoIsHereLabel.antialiasing = true;

	if (Options.gameplayShaders) {
		var temp = createSpriteBuffer("backgroundBuffer");
		backgroundSpriteBuffer = temp[0];
		backgroundCamera = temp[1];
		insert(members.indexOf(ground), backgroundSpriteBuffer);

		temp = createSpriteBuffer("ghostBuffer");
		ghostSpriteBuffer = temp[0];
		ghostCamera = temp[1];

		for (sprite in [sunUnderlay, sun, mountain, city, grass, titleCardUprising, picoIsHereLabel])
			sprite.camera = backgroundCamera;

		var wave = new CustomShader("waterDistortion");
		wave.data.time.value = iTime;
		wave.strength = 0.125;

		ghostSpriteBuffer.shader = wave;

		if (FlxG.save.data.bloom) {
			bloomShader = new CustomShader("bloom_new");
			bloomShader.size = 60;
			bloomShader.brightness = 2.0;
			bloomShader.directions = 16;
			bloomShader.quality = 3;
			bloomShader.threshold = .7;

			camGame.addShader(bloomShader);

			bloomHUDShader = new CustomShader("bloom_new");
			bloomHUDShader.size = 20;
			bloomHUDShader.brightness = 1.78;
			bloomHUDShader.directions = 16;
			bloomHUDShader.quality = 3;
			bloomHUDShader.threshold = .75;

			camHUD.addShader(bloomHUDShader);
		}

		if (FlxG.save.data.fire) {
			var heatSun = new CustomShader("heatwave");
			heatSun.data.time.value = iTime;
			heatSun.speed = 0.1;
			heatSun.even = false;
			heatSun.strength = 1.2;

			sunUnderlay.shader = heatSun;
			sun.shader = heatSun;

			backgroundSpriteBuffer.shader = heat;
		}
	}

	autoTitleCard = false;
}

var shadowStrip:FlxStrip = new FlxStrip();
shadowStrip.indices.push(0);
shadowStrip.indices.push(1);
shadowStrip.indices.push(2);
shadowStrip.indices.push(2);
shadowStrip.indices.push(3);
shadowStrip.indices.push(0);
shadowStrip.uvtData.push(0); shadowStrip.uvtData.push(0);
shadowStrip.uvtData.push(1); shadowStrip.uvtData.push(0);
shadowStrip.uvtData.push(1); shadowStrip.uvtData.push(1);
shadowStrip.uvtData.push(0); shadowStrip.uvtData.push(1);
shadowStrip.blend = BlendMode.MULTIPLY;
shadowStrip.color = 0x000000;
shadowStrip.updateColorTransform();
shadowStrip.colorTransform.redOffset = 0.662 * 255;
shadowStrip.colorTransform.greenOffset = 0.474 * 255;
shadowStrip.colorTransform.blueOffset = 0.48 * 255;
//var debugSprite:FlxSprite = new FunkinSprite().makeSolid(1, 1, 0x8000FF00);
//debugSprite.forceIsOnScreen = true;

function initializeShadow(sprite:FlxSprite, cutOffY:Float, scaleHeight:Float, skewWidth:Float, skewX:Float,
	waveStrengthX:Float, waveStrengthY:Float, waveSpeed:Float, waveCount:Float,
	?drawFunc:FlxSprite->Void
) {
	final shadowShader = new CustomShader('shadowProcess');
	shadowShader.precisionHint = ShaderPrecision.FAST;
	shadowShader.boldSkewWidth = Options.gameplayShaders;
	shadowShader.waveStrength = [waveStrengthX, waveStrengthY];
	shadowShader.waveSpeed = waveSpeed;
	shadowShader.waveCount = waveCount;
	shadowShader.data.time.value = iTime;

	final halfWaveStrengthX = waveStrengthX * 0.5, halfWaveStrengthY = waveStrengthY * 0.5;

	final verts = shadowStrip.vertices;
	final frameUV = shadowShader.frameUV = [];
	final frameSize = shadowShader.frameSize = [];
	shadowShader.skewWidth = skewWidth;

	final isCharacter = sprite is Character;

	sprite.onDraw = (spr) -> {
		if (spr.alpha < 0.001) return;
		shadowStrip.colorTransform.alphaMultiplier = spr.alpha;

		final prevScaleY = spr.scale.y, prevFrameOffsetX = spr.frameOffset.x, prevFrameOffsetY = spr.frameOffset.y;

		final frame = spr._frame, point = spr._point, matrix = spr._matrix;
		shadowStrip.cameras = spr.cameras;

		shadowShader.frameAngle = frame.angle;
		frameUV[0] = frame.uv.x; frameUV[1] = frame.uv.y;
		frameUV[2] = frame.uv.width; frameUV[3] = frame.uv.height;

		switch (frame.angle) {
			case -90, 90:
				frameSize[0] = frame.frame.height;
				frameSize[1] = frame.frame.width;
			default:
				frameSize[0] = frame.frame.width;
				frameSize[1] = frame.frame.height;
		}

		if (isCharacter) spr.preDraw();

		spr.skew.x += skewX;
		spr.scale.y *= -scaleHeight;
		drawFunc(spr);

		var y = frame.offset.y;
		// workaround for hscript in 1.0.1
		final originY = spr.origin.y;
		final originX = spr.origin.x;
		if (spr.checkFlipY() != frame.flipY) {
			y = -y + frame.sourceSize.y - frameSize[1];
		}
		y -= spr.frameOffset.y + originY;
		if (spr.scale.y < 0) y += frameSize[1];
		y *= spr.scale.y;
		y += spr.y - spr.offset.y + originY;

		/*
		point.copyFrom(frame.offset);
		if (spr.checkFlipX() != frame.flipX) {
			point.x *= -1;
			point.x += frame.sourceSize.x - frameSize[0];
		}
		if (spr.checkFlipY() != frame.flipY) {
			point.y *= -1;
			point.y += frame.sourceSize.y - frameSize[1];
		}
		point.subtractPoint(spr.frameOffset);
		point.subtractPoint(spr.origin);
		point.scale(spr.scale.x, spr.scale.y);
		if (spr.scale.x < 0) point.x += frameSize[0] * spr.scale.x;
		if (spr.scale.y < 0) point.y += frameSize[1] * spr.scale.y;
		point.add(spr.x, spr.y);
		point.subtractPoint(spr.offset);
		point.addPoint(spr.origin);
		*/

		/*
		debugSprite.setPosition(
			spr.x,
			y
		);
		debugSprite.scale.set(frameSize[0] * Math.abs(spr.scale.x), frameSize[1] * Math.abs(spr.scale.y));
		//debugSprite.camera = camHUD;
		//debugSprite.zoomFactor = 0;
		debugSprite.updateHitbox();
		debugSprite.draw();
		*/

		shadowShader.cutOffY = Math.max((cutOffY - y) / frameSize[1] / Math.abs(spr.scale.y), 0.0);

		final widthMargin = skewWidth * 0.5 + (y - cutOffY);
		final left = -frameSize[0] * halfWaveStrengthX - widthMargin, right = frameSize[0] * (1.0 + halfWaveStrengthX) + widthMargin;
		final top = -frameSize[1] * halfWaveStrengthY, bottom = frameSize[1] * (1.0 + halfWaveStrengthY);

		for (camera in spr.cameras) {
			if (!camera.visible || !camera.exists) continue;

			matrix.identity();
			matrix.translate(frame.offset.x, frame.offset.y);
			if (spr.checkFlipX() != frame.flipX) {
				matrix.scale(-1, 1);
				matrix.tx += frame.sourceSize.x;
			}
			if (spr.checkFlipY() != frame.flipY) {
				matrix.scale(1, -1);
				matrix.ty += frame.sourceSize.y;
			}

			try {
				spr.prepareDrawMatrix(matrix, camera);
			}
			catch (e:Any) {
				matrix.translate(-originX, -originY);

				if (spr.frameOffsetAngle != null && spr.frameOffsetAngle != spr.angle) {
					var angleOff = (spr.frameOffsetAngle - spr.angle) * 3.141592653589793 / 180;
					var cos = Math.cos(angleOff), sin = Math.sin(angleOff);
					matrix.rotateWithTrig(cos, -sin);
					matrix.translate(-spr.frameOffset.x, -spr.frameOffset.y);
					matrix.rotateWithTrig(cos, sin);
				}
				else
					matrix.translate(-spr.frameOffset.x, -spr.frameOffset.y);

				matrix.scale(spr.scale.x, spr.scale.y);

				if (spr.matrixExposed) {
					matrix.concat(spr.transformMatrix);
				}
				else {
					if (spr.bakedRotationAngle <= 0) {
						spr.updateTrig();
						if (spr.angle != 0) matrix.rotateWithTrig(spr._cosAngle, spr._sinAngle);
					}

					spr.updateSkewMatrix();
					matrix.concat(spr._skewMatrix);
				}

				spr.getScreenPosition(point, camera).subtractPoint(spr.offset).add(originX, originY);
				matrix.translate(point.x, point.y);

				spr.doAdditionalMatrixStuff(matrix, camera);
			}

			if (!camera.rotateSprite && camera.angle != 0)
			{
				matrix.translate(-camera.width * 0.5, -camera.height * 0.5);
				matrix.rotateWithTrig(camera._cosAngle, camera._sinAngle);
				matrix.translate(camera.width * 0.5, camera.height * 0.5);
			}

			verts.length = 0;
			point.set(left, top).transform(matrix); verts.push(point.x); verts.push(point.y);
			point.set(right, top).transform(matrix); verts.push(point.x); verts.push(point.y);
			point.set(right, bottom).transform(matrix); verts.push(point.x); verts.push(point.y);
			point.set(left, bottom).transform(matrix); verts.push(point.x); verts.push(point.y);

			final drawItem = camera.startTrianglesBatch(spr.graphic, spr.antialiasing, true, shadowStrip.blend, true, shadowShader);
			drawItem.addTriangles(verts, shadowStrip.indices, shadowStrip.uvtData, shadowStrip.colors, null,
				spr._rect.set(-camera.width * 2, -camera.height * 2, camera.width * 4, camera.height * 4), shadowStrip.colorTransform);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		if (isCharacter) spr.postDraw();

		spr.skew.set(0, 0);
		spr.scale.y = prevScaleY;
		spr.frameOffset.set(prevFrameOffsetX, prevFrameOffsetY);
		spr.draw();
	}
}

function postCreate() {
	tankmanGhostChar = strumLines.members[3].characters[0];
	tankmanGhostChar.alpha = 0;

	steveGhostChar = strumLines.members[4].characters[0];
	steveGhostChar.alpha = 0;

	drummerGhostChar = strumLines.members[5].characters[0];
	drummerGhostChar.alpha = 0;

	picoChar = strumLines.members[2].characters[0];
	picoChar.alpha = 0;

	steveChar = strumLines.members[6].characters[0];
	steveChar.setPosition(dad.x - 400, dad.y - 100);
	steveChar.alpha = 0;
	remove(steveChar);
	insert(members.indexOf(dad), steveChar);

	playerChar = new Character(0, 0, 'player_uprising');
	playerChar.setPosition(boyfriend.x + 110, boyfriend.y - 70);
	playerChar.alpha = 0;
	insert(members.indexOf(boyfriend), playerChar);

	if (Options.gameplayShaders) {
		insert(members.indexOf(picoChar), ghostSpriteBuffer);
		for (character in [tankmanGhostChar, steveGhostChar, drummerGhostChar, steveChar])
			character.camera = ghostCamera;
	}

	initializeShadow(dad, 1274, 0.5, 90, -30, 0.08, 0.04, 0.1, 10, (spr) -> {spr.frameOffset.add(10, -23); spr.skew.y = 2;});
	initializeShadow(boyfriend, 1274, 0.5, 90, 30, 0.08, 0.04, 0.1, 10, (spr) -> spr.frameOffset.add(90, 552));
	initializeShadow(picoChar, 1080, 0.5, 110, 0, 0.08, 0.04, 0.1, 10, (spr) -> spr.frameOffset.add(0, 490));

	baseSteveGhostX = steveGhostChar.x;
	baseSteveGhostY = steveGhostChar.y;

	baseTankmanGhostX = tankmanGhostChar.x;
	baseTankmanGhostY = tankmanGhostChar.y;

	executeEvent({
		name: "Screen Coverer",
		time: Conductor.songPosition,
		params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
	});

	darkenShader.strength = 0.9;
	bloomShader.threshold = 0.65;
	bloomShader.size = 30;
	bloomShader.quality = 5;

	if (Options.gameplayShaders) camHUD.removeShader(bloomHUDShader);
}

function destroy() {
	shadowStrip.destroy();
	backgroundSpriteBuffer?.destroy();
	ghostSpriteBuffer?.destroy();
}

function update(elapsed:Float) {
	iTime[0] = time += elapsed;

	if (drummerMotionActive) {
		drummerFloatPhase += elapsed * 1.5;

		var radiusX = 80;
		var radiusY = 40;

		var dx = Math.sin(drummerFloatPhase) * radiusX;
		var dy = Math.sin(drummerFloatPhase * 1.5) * radiusY;

		drummerGhostChar.x = drummerBaseX + dx;
		drummerGhostChar.y = drummerBaseY + dy;
	}


	var lerpFactor = elapsed * 3; 
	currentFloatRadius = FlxMath.lerp(currentFloatRadius, targetFloatRadius, lerpFactor);
	currentFloatSpeed = FlxMath.lerp(currentFloatSpeed, targetFloatSpeed, lerpFactor);

	// awesome fucking realistic floating
	var speedMod = 1 + Math.sin(time * 0.5) * 0.3;
	floatPhase += currentFloatSpeed * elapsed * speedMod;

	if (canFloat) {
		var floatX = Math.sin(floatPhase) * currentFloatRadius;
		var floatY = Math.sin(floatPhase * 2) * (currentFloatRadius / 2);

		var floatX2 = Math.sin(time * 2) * 20;
		var floatY2 = Math.sin(time * 4) * 10;

		steveGhostChar.x = baseSteveGhostX + floatX;     
		steveGhostChar.y = baseSteveGhostY + floatY;

		tankmanGhostChar.x = baseTankmanGhostX - floatX2;
		tankmanGhostChar.y = baseTankmanGhostY + floatY2;
	}
}

function resetFloatPosition():Void {
	if (isResetting) return;
	isResetting = true;
	canFloat = false;

	FlxTween.tween(steveGhostChar, {x: baseSteveGhostX, y: baseSteveGhostY}, 2, {
		ease: FlxEase.quadInOut,
		onComplete: function(_) {
			isResetting = false;
			canFloat = true;
		}
	});

	FlxTween.tween(tankmanGhostChar, {x: baseTankmanGhostX, y: baseTankmanGhostY}, 2, {
		ease: FlxEase.quadInOut
	});
}

function onPlayerHit(note:Note):Void {
	if (playerChar != null && playerChar.alpha != 0) {
		var dirNames = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		var animName = 'sing' + dirNames[note.direction];
		playerChar.playAnim(animName, true);
	}
}

function draw() {
	if (Options.gameplayShaders) {
		preDrawSpriteBuffer(backgroundCamera);
		preDrawSpriteBuffer(ghostCamera);
	}
}

function postDraw() {
	if (Options.gameplayShaders) {
		postDrawSpriteBuffer(backgroundSpriteBuffer, backgroundCamera, 1);
		postDrawSpriteBuffer(ghostSpriteBuffer, ghostCamera, 1);
	}
}

function stepHit(step:Int) {
	switch (step) {
		case 40:
			titleCardUprising.y += 370;
			insert(members.indexOf(grass), titleCardUprising);

			FlxTween.tween(titleCardUprising, {y: titleCardUprising.y - 370}, 5, {ease: FlxEase.cubeOut});
			FlxTween.color(titleCardUprising, 3, 0xFF000000, 0xFFFFFFFF, {ease: FlxEase.quadOut});

		case 110:
			FlxTween.tween(titleCardUprising, {y: titleCardUprising.y - 40, alpha: 0}, 7, {ease: FlxEase.cubeIn});

		case 240:
			remove(titleCardUprising);
			if (Options.gameplayShaders) camHUD.addShader(bloomHUDShader);

		case 400:
			FlxTween.tween(tankmanGhostChar, {alpha: 0.9}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(steveGhostChar, {alpha: 0.9}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(drummerGhostChar, {alpha: 0.9}, 1, {ease: FlxEase.quadInOut});
			FlxTween.num(darkenShader.strength, 0, 1, {ease: FlxEase.quadInOut}, (f) -> darkenShader.strength = f);
			FlxTween.num(darkenShader.threshold, 0.7, 1, {ease: FlxEase.quadOut}, (f) -> bloomShader.threshold = f);
			FlxTween.num(bloomShader.size, 60, 1, {ease: FlxEase.quadOut}, (f) -> bloomShader.size = f);

		case 416:
			darkenShader.strength = 0.0;
			bloomShader.quality = 3;
			bloomShader.size = 60;
			bloomShader.brightness = 2.0;
			bloomShader.quality = 3;
			bloomShader.threshold = 0.7;

		case 1122:
			FlxTween.tween(steveChar, {alpha: 0.5}, 0.5, {ease: FlxEase.quadInOut});

		case 1152:
			FlxTween.tween(steveChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		case 1184:
			FlxTween.tween(playerChar, {alpha: 0.4}, 0.5, {ease: FlxEase.quadInOut});

		case 1260:
			FlxTween.tween(playerChar, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});

		case 696:
			FlxTween.tween(steveChar, {alpha: 0.9}, 3, {ease: FlxEase.quadInOut});

		case 824:
			FlxTween.tween(playerChar, {alpha: 0.4}, 1, {ease: FlxEase.quadInOut});

		case 960:
			FlxTween.tween(steveChar, {alpha: 0}, 5, {ease: FlxEase.quadInOut});
			FlxTween.tween(playerChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		case 1088:
			targetFloatRadius = 70;
			targetFloatSpeed = 3;

		// PICO APPEARS

		case 1322:
			FlxTween.tween(drummerGhostChar, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});

		case 1336:
			picoChar.alpha = 1;

		case 1344:
			targetFloatRadius = 20; 
			targetFloatSpeed = 2; 
			resetFloatPosition();

			picoIsHereLabel.y += 200;
			picoIsHereLabel.alpha = 0;
			insert(members.indexOf(grass), picoIsHereLabel);

			FlxTween.tween(picoIsHereLabel, {y: picoIsHereLabel.y - 200, alpha: 1}, 3, {ease: FlxEase.quintOut});

		case 1400:
			FlxTween.tween(picoIsHereLabel, {y: picoIsHereLabel.y - 40, alpha: 0}, 3, {ease: FlxEase.cubeIn});

		case 1500:
			remove(picoIsHereLabel);

		case 1600:
			remove(drummerGhostChar);
			insert(members.indexOf(ground), drummerGhostChar);
			//drummerGhostChar.camera = backgroundCamera;

			FlxTween.tween(drummerGhostChar, {alpha: 0.75}, 3, {ease: FlxEase.quadInOut});
			FlxTween.tween(drummerGhostChar, {y: drummerGhostChar.y - 300}, 3, {ease: FlxEase.quadInOut});

			var targetY = drummerGhostChar.y - 300;
			FlxTween.tween(drummerGhostChar, {y: targetY}, 3, {
				ease: FlxEase.quadInOut,
				onComplete: function(_) {
					drummerMotionActive = true;
				}
			});

			drummerBaseX = drummerGhostChar.x;
			drummerBaseY = targetY;

			FlxTween.tween(playerChar, {alpha: 0.6}, 1, {ease: FlxEase.quadInOut});

		case 1664:
			targetFloatRadius = 90; 
			targetFloatSpeed = 4;

		case 1728:
			targetFloatRadius = 20; 
			targetFloatSpeed = 2;

		case 1824:
			FlxTween.tween(playerChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		case 1920:
			FlxTween.tween(playerChar, {alpha: 0.6}, 0.5, {ease: FlxEase.quadInOut});

		case 1970:
			targetFloatRadius = 140; 
			targetFloatSpeed = 5; 

		case 2110:
			FlxTween.tween(playerChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		case 2106:
			FlxTween.tween(steveChar, {alpha: 0.9}, 2, {ease: FlxEase.quadInOut});

		case 2232:
			FlxTween.tween(steveChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});


		case 2356:
			FlxTween.tween(drummerGhostChar, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
			FlxTween.tween(steveGhostChar, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
			FlxTween.tween(tankmanGhostChar, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});

		case 2240:
			targetFloatRadius = 20; 
			targetFloatSpeed = 2;

		case 2368:
			darkenShader.strength = 0.9;
			bloomShader.threshold = 0.675;
			bloomShader.size = 30;
			bloomShader.quality = 5;

		case 2432:
			FlxTween.tween(steveGhostChar, {alpha: 0.9}, 0.7, {ease: FlxEase.quadInOut});

		case 2624:
			FlxTween.tween(drummerGhostChar, {alpha: 0.75}, 0.7, {ease: FlxEase.quadInOut});
			darkenShader.strength = 0.0;
			bloomShader.quality = 3;
			bloomShader.size = 60;
			bloomShader.brightness = 2.0;
			bloomShader.quality = 3;
			bloomShader.threshold = .7;

		case 2880:
			FlxTween.tween(tankmanGhostChar, {alpha: 0.9}, 0.7, {ease: FlxEase.quadInOut});

		case 3000:
			targetFloatRadius = 180; 
			targetFloatSpeed = 5; 

		case 3002:
			FlxTween.tween(playerChar, {alpha: 0.6}, 0.5, {ease: FlxEase.quadInOut});

		case 3247:
			FlxTween.tween(playerChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		case 3116:
			targetFloatRadius = 80; 
			targetFloatSpeed = 3; 

		case 3138:
			targetFloatRadius = 180; 
			targetFloatSpeed = 3; 

		case 3248:
			targetFloatRadius = 20; 
			targetFloatSpeed = 2;

			FlxTween.tween(drummerGhostChar, {alpha: 0}, 4, {ease: FlxEase.quadInOut});
			FlxTween.tween(steveGhostChar, {alpha: 0}, 4, {ease: FlxEase.quadInOut});
			FlxTween.tween(tankmanGhostChar, {alpha: 0}, 4, {ease: FlxEase.quadInOut});

		case 3264:
			darkenShader.strength = 0.95;
			bloomShader.threshold = 0.45;
			bloomShader.size = 30;
			bloomShader.quality = 5;

		case 3312:
			FlxTween.tween(steveChar, {alpha: 0.7}, 1, {ease: FlxEase.quadInOut});

		case 3392:
			FlxTween.tween(steveChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
	}
}