//Thank you for giving me this opportinty lunarcleint & the dustin' team 🧡 - HIGGAMEON
//btw, the color pallete idea was so gas 🔥 - also HIGGAMEON

// cool beans higg this is so peak -lunar >:D 
import funkin.game.HudCamera;
import funkin.backend.utils.FlxInterpolateColor;
import flixel.effects.FlxFlicker;
import openfl.display.BlendMode;

importScript("data/scripts/snowing-shader");

public var camCharacters:FlxCamera;
public var camHUD3:FlxCamera;
//camHUD4 is for the cinematic bar not being affected by shaders
public var camHUD4:FlxCamera;

var flickerSprite:FlxSprite;
public var blurIntensity:Float = 0;
public var water:CustomShader;
public var water2:CustomShader;

function create() {
	camCharacters = new FlxCamera(0, 0);

	camHUD3 = new FlxCamera(0, 0);
	camHUD4 = new FlxCamera(0, 0);
	
	for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
	for (cam in [camGame, camCharacters, camHUD3, camHUD4, camHUD, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

	stage.getSprite("final_rocks").camera = camGame;
	stage.getSprite("final_rocks").visible = false;

	stage.getSprite("ASGOREOT").cameras = [camCharacters];
	stage.getSprite("ASGOREOT").color = FlxColor.fromRGB(104,104,104);
	stage.getSprite("madnessbar_assetsOVERTHRONE").color = FlxColor.fromRGB(112,112,112);

	stage.getSprite("shade_overthrone_tutorial").visible = false;
	stage.getSprite("warning_OVERTHRONE").visible = false;

	var spirits = strumLines.members[3].characters[0];
	if (spirits.curCharacter == "spirits") {  // mettaton's arm on asgore's face due to the shader sob  - Nex
		//spirits.x -= 50;
		if(FlxG.save.data.impact)
			spirits.color = FlxColor.fromRGB(112,112,112);
		spirits.y -= 200;
	}

	dustinPauseScript = "red-demon-o";
}

function onPostNoteCreation(e) {
	if(FlxG.save.data.impact)
		e.note.color = FlxColor.fromRGB(200,200,200);
}

function onPostStrumCreation(e) {
	if(FlxG.save.data.impact)
		e.strum.color = FlxColor.fromRGB(100,100,100);
}

var radial:CustomShader;
var radial2:CustomShader;

var warp:CustomShader;
public var fillShader = new CustomShader("impact_frames_col");
public var fillShaderBG = new CustomShader("impact_frames_col");

var timing:Float = 0.005;
var fillColorBGLerp:FlxInterpolateColor = new FlxInterpolateColor(0xff000000);
var fillColorBG:Int =  fillColorBGLerp.color;

var fillColorLerp:FlxInterpolateColor = new FlxInterpolateColor(0xff5d1d1d);
var fillColor:Int =  fillColorLerp.color;

function postCreate() {

	if(FlxG.save.data.impact)
		gf.color = FlxColor.fromRGB(160,160,160);
	for (script in PlayState.instance.scripts.scripts) {
		if(script.fileName == "Camera Flash.hx") {
			PlayState.instance.scripts.scripts.remove(script);
			script.destroy();
			script = null;
		}
	}

	camCharacters.alpha = 0;
	autoTitleCard = false;

	camZooming = true;
	useCamZoomMult = true;

	doWashColor(camGame, fillColorBGLerp.color, .22, 7);
	doWashColor(camCharacters, fillColorLerp.color, .15, 4);
	doWashColor(camHUD, fillColorLerp.color, .08, 7);
	doWashColor(camHUD2, fillColorLerp.color, .08, 7);

	radial = new CustomShader("radial");
	radial.center = [0.5, 0.5];
    radial.blur = 0;

	radial2 = new CustomShader("radial");
	radial2.center = [0.5, 0.5];
    radial2.blur = 0;

	warp = new CustomShader("warp");
	warp.distortion = 0;

	for(snow in [snowShader, snowShader2]) {
		snow.snowMeltRect = [-700, 800, 1500, 100]; 
		snow.LAYERS = 0;
	}
    snowSpeed = .2;
	snowShader.BRIGHT = .2;
	snowShader2.BRIGHT = 2;

	water = new CustomShader("waterDistortion");
    water.strength = 0;
	water.time = 0;
	water2 = new CustomShader("waterDistortion");
    water2.strength = 0;
	water2.time = 0;

	if (Options.gameplayShaders) {
		camGame.addShader(radial);
		camHUD.addShader(radial2);
		camCharacters.addShader(radial2);

		if (FlxG.save.data.warp) {
			camGame.addShader(warp);
			camCharacters.addShader(warp);
		}

		if (FlxG.save.data.particles) {
			camGame.addShader(snowShader);
    		camCharacters.addShader(snowShader2);	
		}

		if (FlxG.save.data.water) {
			camGame.addShader(water);
    		camCharacters.addShader(water2);	
		}
	}

	flickerSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
    flickerSprite.scrollFactor.set(0, 0);
    flickerSprite.zoomFactor = 0;
    flickerSprite.cameras = [camHUD2];
    flickerSprite.alpha = 0.025;
    add(flickerSprite);

	if(!FlxG.save.data.antiFlash)
    	FlxFlicker.flicker(flickerSprite, 9999999, 0.04);
}

function onSongStart() {
	for(snow in [snowShader, snowShader2])
		snow.LAYERS = 7;
	timing = 0.05;
	fillColorBG = 0xff210014;
	fillColor = 0xff882a2a;
}

function stepHit(step:Int) {
	switch(step) {
		case 16:
			fillColor = 0xffb04747;
			FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {camCharacters.alpha = val;});
		case 32:
			timing = 0.0035;
			fillColorBG = 0xff310000;
			fillColor = 0xffe27575;
    		FlxTween.num(blurIntensity, 0.04, (Conductor.stepCrochet / 1000) * 23.5, {ease: FlxEase.quadOut}, (val:Float) -> {blurIntensity = val;});
    		FlxTween.num(water.strength, 0.2, (Conductor.stepCrochet / 1000) * 23.5, {ease: FlxEase.quadOut}, (val:Float) -> {water.strength = val;});
		case 48:
			fillColorBG = 0xff430000;
		case 54:
    		FlxTween.num(water.strength, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {water.strength = val;});
		case 56:
			timing = 0.005;
			fillColorBG = 0xff000000;
			fillColor = 0xffff0000;
			blurIntensity = 0;
		case 64:
			showTitleCard();
    		FlxTween.num(snowSpeed, .6, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {snowSpeed = val;});
			timing = 0.0035;
			fillColorBG = 0xffff0000;
			fillColor = 0xffffffff;
		case 452 | 1024:
			timing = 0.005;
    		FlxTween.num(snowSpeed, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut}, (val:Float) -> {snowSpeed = val;});
    		FlxTween.num(water.strength, .2, (Conductor.stepCrochet / 1000) * 28, {ease: FlxEase.sineInOut}, (val:Float) -> {water.strength = val;});
			FlxTween.num(0, 0.02, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.quadOut}, (val:Float) -> {blurIntensity = val;});
			fillColor = 0xffffb1dc;
			fillColorBG = 0xff9c0058;
		case 560 | 1136:
			timing = 0.02;
			fillColor = 0xffff3e3e;
			fillColorBG = 0xffff0000;
    		FlxTween.num(snowSpeed, .15, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {snowSpeed = val;});
    		FlxTween.num(water.strength, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineInOut}, (val:Float) -> {water.strength = val;});
			blurIntensity = 0;
		case 570 | 1146:
			timing = 0.015;
			fillColor = 0xffff0000;
			fillColorBG = 0xff000000;
		case 1148:
    		FlxTween.num(blurIntensity, 0.08, (Conductor.stepCrochet / 1000) * 3.5, {ease: FlxEase.quadOut}, (val:Float) -> {blurIntensity = val;});
		case 576 | 1152:
			timing = 0.02;
			water.strength = .3;
			water2.strength = .2;
			snowSpeed = .15;
			fillColorBGLerp.color = 0xffff4a4a;
			fillColorBG = 0xffb82438;
			fillColorLerp.color = FlxColor.WHITE;
			fillColor = 0xffffb0c5;
			setIntensity(0.05);
			blurIntensity = 0.03;
			if(step == 1152) {
				for (cam in [camCharacters, camHUD, camHUD2, camHUD3, camHUD4]) FlxG.cameras.remove(cam, false);
				for (cam in [camHUD3, camCharacters, camHUD4, camHUD, camHUD2]) {FlxG.cameras.add(cam, cam == camGame);}
			}
		case 704 | 1344:
			timing = 0.015;
			fillColor = 0xffffaeae;
			fillColorBG = 0xffff3131;
		case 768 | 1360:
			fillColor = 0xffff9e9e;
			fillColorBG = 0xfff22626;
		case 784 | 1376:
			fillColor = 0xffff8787;
			fillColorBG = 0xfff22637;
		case 800:
			fillColor = 0xffff7d7d;
			fillColorBG = 0xffe21b32;
		case 814:
			timing = 0.0035;
			fillColor = 0xffff9c9c;
			fillColorBG = 0xffe8101b;
		case 832 | 1408:
			timing = 0.001;
    		FlxTween.num(water.strength, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {water.strength = val;});
    		FlxTween.num(water2.strength, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {water2.strength = val;});
    		FlxTween.num(snowSpeed, .6, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {snowSpeed = val;});
			fillColor = (step == 832) ? 0xffffffff : 0xffff0000;
			fillColorBG = 0xffff0000;
			blurIntensity = 0;
		case 1335:
			fillColor = 0xffffffff;
			fillColorBG = 0xff300002;
		case 1390:
			fillColor = 0xffff9c9c;
			fillColorBG = 0xff8d0a11;
		case 1392:
			fillColor = 0xffffffff;
			fillColorBG = 0xffb82438;
		case 1423:
    		FlxTween.num(water.strength, .05, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut}, (val:Float) -> {water.strength = val;});
    		FlxTween.num(water2.strength, .15, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut}, (val:Float) -> {water2.strength = val;});
			timing = 0.0015;
			fillColor = 0xffffe2e7;
			fillColorBG = 0xffff0088;
			blurIntensity = 0.04;
		case 1680:
    		FlxTween.num(snowSpeed, .6, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut}, (val:Float) -> {snowSpeed = val;});
			FlxTween.num(water.strength, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineInOut}, (val:Float) -> {water.strength = val;});
    		FlxTween.num(water2.strength, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineInOut}, (val:Float) -> {water2.strength = val;});
			blurIntensity = 0;
		case 1736:
			timing = 0.05;
			fillColorBG = 0xff000000;
			fillColor = 0xffe27575;
		case 1744:
			for (cam in [camCharacters, camHUD, camHUD2, camHUD3, camHUD4]) FlxG.cameras.remove(cam, false);
			for (cam in [camCharacters, camHUD3, camHUD4, camHUD, camHUD2]) {FlxG.cameras.add(cam, cam == camGame);}
			fillColorBG = 0xffff0000;
			fillColor = 0xffffffff;
		case 1792:
			timing = 0.015;
			fillColorBG = 0xff6b002b;
		case 1872:
			fillColorBG = 0xffff0000;
		case 2000:
			timing = 0.005;
			fillColorBG = 0xff760000;
	}
}

function beatHit(beat:Int) {
	if(stage.getSprite("ASGOREOT").alpha == 0.7 && curBeat % 4 == 0 && curStep != 1468) {
		fillColorBG = (curBeat % 8 == 0) ? 0xffff0088 : 0xffff0000;
		fillColor = (curBeat % 8 == 0) ? 0xffff98f0 : 0xffffffff;
	}
}


function onCountdown(event) event.sprite?.cameras = [camCharacters];

var timer:Float = 0;
function update(elapsed:Float) {
	timer += elapsed;
	water.time = timer;
	water2.time = timer;

	for(bar in [cinematicBar1, cinematicBar2]) {
		if(bar.camera != camHUD3) {
			bar.camera = camHUD3;
		}
	}

    for (strum in strumLines)
        for (char in strum.characters)
			char.cameras = [camCharacters];

	radial.blur = FlxMath.lerp(radial.blur, blurIntensity, (Math.PI * elapsed) * 0.45);
	radial2.blur = FlxMath.lerp(radial2.blur, blurIntensity * 0.3, (Math.PI * elapsed) * 0.45);

	warp.distortion = FlxMath.lerp(warp.distortion, blurIntensity * 50, (Math.PI * elapsed) * 0.45);
	fillColorLerp.lerpTo(fillColor, timing);
	fillColorBGLerp.lerpTo(fillColorBG, timing);

	fillShader.impactCol = [((fillColorLerp.color >> 16) & 0xff)/255, ((fillColorLerp.color >> 8) & 0xff)/255, (fillColorLerp.color & 0xff)/255];
	fillShaderBG.impactCol = [((fillColorBGLerp.color >> 16) & 0xff)/255, ((fillColorBGLerp.color >> 8) & 0xff)/255, (fillColorBGLerp.color & 0xff)/255];
}

function postUpdate(elapsed) {
	for(snow in [snowShader, snowShader2])
		snow.cameraPosition = [FlxG.camera.scroll.x * .4, FlxG.camera.scroll.y * .4];
	DustinUtil.copyCamera(FlxG.camera, camCharacters);
}

public function setIntensity(value:Float) {
	radial.blur = value;
	radial2.blur = value * 0.3;
    warp.distortion = value * 50;
	blurIntensity = value;
}

function onPlayerHit(event) {
    if (event.noteType == "Madness_NOTE_assets")
        camCharacters.shake(0.01, 0.2);
}

function doWashColor(cam:FlxCamera, col:Int, ther:Float, spread:Float) {
	if(!Options.gameplayShaders)
		return;
	var shaderFill = new CustomShader("impact_frames_col");
	if(col == fillColorLerp.color)
		shaderFill = fillShader;
	else if(col == fillColorBGLerp.color)
		shaderFill = fillShaderBG;
	shaderFill.threshold = ther;
	shaderFill.impactCol = [((col >> 16) & 0xff)/255, ((col >> 8) & 0xff)/255, (col & 0xff)/255];

	var bloom_new = new CustomShader("bloom_new");
    bloom_new.size = spread*.7; bloom_new.brightness = .6;
    bloom_new.directions = 6; bloom_new.quality = 5;
    bloom_new.threshold = .35;

	if (FlxG.save.data.impact) cam.addShader(shaderFill);
	if (FlxG.save.data.bloom) cam.addShader(bloom_new);
}

function onEvent(eventEvent) {
	var camera:FlxCamera = camHUD4;
	if (eventEvent.event.name == "Camera Flash") {
		if (eventEvent.event.params[0]) {
            camera.fade(eventEvent.event.params[1], 
                ((Conductor.crochet / 4) / 1000) * eventEvent.event.params[2],
                false, () -> {camera._fxFadeAlpha = 0;}, true
            );
        } else {
            camera.flash(
                eventEvent.event.params[1],
                ((Conductor.crochet / 4) / 1000) * eventEvent.event.params[2],
            null, true);
        }
		eventEvent.cancelled = true;
	}
}