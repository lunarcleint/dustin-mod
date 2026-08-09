// NEW
import flixel.effects.FlxFlicker;

var flickerSprite:FunkinSprite;

var blackwhite:CustomShader;
var oldstatic:CustomShader;
var pixel:CustomShader;

var blackOverlayHUD:FlxSprite;

var normalStrumPoses:Array<Array<Array<Int>>> = [];
var arrowSine:Bool = false;
function postCreate() {
    if (Options.gameplayShaders) {
        blackwhite = new CustomShader("blackwhite");
        blackwhite.grayness = 1;
        for (cam in [FlxG.camera, camHUD, camCharacters, camForeground]) cam.addShader(blackwhite);

        oldstatic = new CustomShader("static");
        oldstatic.time = 0; oldstatic.strength = 1.2;
        if (FlxG.save.data.static) 
            for (cam in [FlxG.camera, camHUD, camCharacters, camForeground]) cam.addShader(oldstatic);

        pixel = new CustomShader("pixel");
        pixel.blockSize = 5.0;
        pixel.res = [FlxG.width, FlxG.height];
    }

    flickerSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
    flickerSprite.scrollFactor.set(0, 0);
    flickerSprite.zoomFactor = 0;
    flickerSprite.cameras = [camHUD];
    flickerSprite.alpha = 0.05;

    if(!FlxG.save.data.antiFlash) {
        add(flickerSprite);
        FlxFlicker.flicker(flickerSprite, 9999999, 0.05);
    }

    for (element in hudElements) element.alpha = 0;
    camMoveOffset = 15;

    camZoomingStrength = 0;
    FlxG.camera.followLerp = 0.007;

    if (Options.gameplayShaders) {
        for (strum in strumLines)
            for (char in strum.characters) {
                char.shader = new CustomShader("iconshader");
                char.shader.minBrightness = .01;
                char.shader.color = [.01, .01, .01];
                char.shader.ratio = 1;
            }
    }

    
    blackOverlayHUD = new FlxSprite();
    blackOverlayHUD.makeGraphic(1280, 720, FlxColor.BLACK);
    blackOverlayHUD.scrollFactor.set(0, 0);
    blackOverlayHUD.alpha = 1;
    blackOverlayHUD.cameras = [camHUD];
    add(blackOverlayHUD); 

    for (i=>strum in strumLines.members) {
        normalStrumPoses[i] = [for (s in strum.members) [s.x, s.y]];
    }
}

function onSongStart() {
    FlxTween.tween(blackOverlayHUD, {alpha: 0}, 7, {
        onComplete: function(twn:FlxTween) {
            remove(blackOverlayHUD);
            blackOverlayHUD.destroy();
        }
    });
}

var time:Float = 0;
function update(elapsed:Float) {

    time += elapsed;
    oldstatic?.time = time;

    for (i => strumLine in strumLines.members) {
        for (k=>s in strumLine.members) {
            s.x = lerp(s.x, arrowSine ? normalStrumPoses[i][k][0] + (10*FlxMath.fastCos((time*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) + 20 : normalStrumPoses[i][k][0], .6);
            s.y = lerp(s.y, arrowSine ? normalStrumPoses[i][k][1] + (8*FlxMath.fastSin((time*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) : normalStrumPoses[i][k][1], .6);
        }
    }

}

function onSongEnd() {
    arrowSine = false;
}

function stepHit(step:Int) {
    switch (step) {
        case 0: time = 0;
        case 96:
            FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 32, {ease: FlxEase.quadInOut}, (val:Float) -> {blackOverlay.colorTransform.color = CoolUtil.lerpColor(0xFF1B1B1B, 0xFF5F5F5F, val);});
        case 128:
            FlxTween.tween(blackOverlay, {alpha: 0}, 3.6, {
                onComplete: function(twn:FlxTween) {
                    remove(blackOverlay);
                    blackOverlay.destroy();
                }
            });

            if (Options.gameplayShaders) {
                for (strum in strumLines)
                    for (char in strum.characters) 
                        FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadInOut}, (val:Float) -> {char.shader.ratio = val;});
            }


            FlxTween.num(7, 1.3, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {snowSpeed = val;});
            FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {stage.stageSprites["BG4"].color = CoolUtil.lerpColor(0xFF1B1B1B, 0xFFFFFFFF, val);});
            FlxG.camera.followLerp = 0.02;
        case 240:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 1}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.quadOut});
        case 254:
            strumLines.members[0].notes.forEach((note:Note) -> {note.visible = false;});
        case 255:
            strumLines.members[0].notes.forEach((note:Note) -> {note.visible = true;});
        case 512:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 0}, (Conductor.stepCrochet / 1000) * 32, {ease: FlxEase.quadOut});
        case 544:
            FlxG.camera.shake(0.000001, 999999);
			FlxTween.tween(FlxG.camera, {_fxShakeIntensity: 0.0009}, (Conductor.stepCrochet / 1000) * 100);
        case 564:
            FlxTween.num(0, 0.1, (Conductor.stepCrochet / 1000) * 50, {ease: FlxEase.sineIn}, (val:Float) -> {water.strength = val;});
        case 645:
            FlxTween.num(0.1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            if(oldstatic != null) FlxTween.num(1.3, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {oldstatic.strength = val;});
            if(blackwhite != null) FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {blackwhite.grayness = val;});
            if(blackwhite != null) FlxTween.num(1.3, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {blackwhite.grayness = val;});

            FlxTween.num(1.4, 1, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 25, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});

            FlxTween.num(5, .7, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {chromWarp.distortion = val;});
            flickerSprite.alpha = 0; FlxG.camera.stopFX();

            camGame.flash(0x7619A2F2, (Conductor.stepCrochet / 1000) * 4);
        case 656:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 1}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadIn});

            screenVignette.transperency = true;

            camGame.removeShader(screenVignette);
            camCharacters.removeShader(screenVignette2);

            if (Options.gameplayShaders) {
                camForeground.addShader(screenVignette);
                if (FlxG.save.data.bloom) camCharacters.addShader(bloom);
            }

            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(.7, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {chromWarp.distortion = val;});

            FlxG.camera.followLerp = 0.035;

        case 752 | 760 | 768 | 880 | 888 | 896 /*| 1696 | 1728 | 1760*/:
            FlxTween.num(.3, 0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {water.strength = val;});
            FlxTween.num(.4, 0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            FlxTween.num(1.3, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(35, 10, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
        case 976 | 1104:
            FlxTween.num(.4, 0, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(.5, 0, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});

        case 1000: camMoveOffset = 0; camAngleOffset = 0;
        case 1040 | 1167: camMoveOffset = 15; camAngleOffset = .3;
        case 1136:
            camMoveOffset = 0; camAngleOffset = 0;

            FlxTween.num(0, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(0, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});

            camHUD.removeShader(water);

            for (strum in strumLines) {
                for (char in strum.characters) {
                    char.shader.color = [.2, .2, .2];
                    char.shader.minBrightness = .01;
                    FlxTween.num(0, .1, (Conductor.stepCrochet / 1000) * 20, {ease: FlxEase.quintIn}, (val:Float) -> {char.shader.ratio = val;});
                }
            }
        
        case 1168:
            strumLines.members[0].notes.forEach((note:Note) -> {note.visible = false;});
            if (Options.gameplayShaders && pixel != null && FlxG.save.data.pixel) {
                if (Options.gameplayShaders) 
                    for (cam in [FlxG.camera, camCharacters, camForeground]) cam.addShader(pixel);

                FlxTween.num(1, 16, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.circOut}, (val:Float) -> {pixel.blockSize = val;});
            }

            camAngleChars = false;
            FlxTween.tween(camGame, {angle: -120}, (Conductor.stepCrochet / 1000) * 15, {ease: FlxEase.circIn});
        case 1180: FlxG.camera.visible = camCharacters.visible = camForeground.visible = camHUD.visible = false;
        case 1182: FlxG.camera.visible = camCharacters.visible = camForeground.visible = camHUD.visible = true;
        case 1184:
            water.strength = 0; chromWarp.distortion = 0;
            if (Options.gameplayShaders) {
                for (strum in strumLines) 
                    for (char in strum.characters)
                        char.shader.ratio = 0;
            }


            strumLines.members[0].notes.forEach((note:Note) -> {note.visible = true;});
            FlxTween.num(32, 1, (Conductor.stepCrochet / 1000) * 24, {ease: FlxEase.circOut, onComplete: (_) -> {
                if (Options.gameplayShaders && FlxG.save.data.pixel) camHUD.addShader(pixel);
                for (cam in [camCharacters, camForeground]) cam.removeShader(pixel);
            }}, (val:Float) -> {pixel.blockSize = val;});

            FlxTween.cancelTweensOf(camGame);
            camGame.angle = 0; 

            camForeground.removeShader(screenVignette);

            camGame.removeShader(snowShader);
            if (Options.gameplayShaders) {
                camHUD2.addShader(screenVignette);
                if (FlxG.save.data.bloom) {
                    camGame.addShader(bloom_new);
                    camHUD.addShader(bloom_new);
                }
            }
            gradientShader.applyY = 9999999;
            fogShader.applyY = 9999999;
            snowShader2.pixely = true; snowShader2.LAYERS = 7;
            snowShader2.snowMeltRect = [1000, 1430, 1700, 70];

            snowSpeed = 1.3;

            for (name => sprite in stage.stageSprites)    
                sprite.visible = name == "PILLARS";
            
            for (element in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2, timeBarBG, timeBar])
                element.visible = false;

            for (element in [scoreTxt, missesTxt, accuracyTxt]) element.y -= 10;

            boyfriend.alpha = 0.00000000001;
        case 1432 | 1568: snowShader2.LAYERS = 0;
        case 1440 | 1572: snowShader2.LAYERS = 7;
        case 1664:
            FlxTween.num(0, .5, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(0, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});

        case 1688:
            if (pixel != null && FlxG.save.data.pixel) {
                if (Options.gameplayShaders) 
                    for (cam in [FlxG.camera, camCharacters, camForeground]) cam.addShader(pixel);
                FlxTween.num(1, 16, (Conductor.stepCrochet / 1000) * 7.7, {ease: FlxEase.circOut}, (val:Float) -> {pixel.blockSize = val;});
            }

            camAngleChars = false;
            FlxTween.num(0, -60, (Conductor.stepCrochet / 1000) * 7.7, {ease: FlxEase.circIn}, (val:Float) -> {camGame.angle = val;});
        case 1696:
            snowSpeed = 3;

            if (pixel != null) {
                FlxTween.num(16, 1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.circOut, onComplete: (_) -> {
                    for (cam in [camGame, camCharacters, camForeground, camHUD]) cam.removeShader(pixel);
                }}, (val:Float) -> {pixel.blockSize = val;});
            }

            camAngleChars = false;
            FlxTween.num(-10, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.circOut, onComplete: (_) -> {
                camAngleChars = true;
            }}, (val:Float) -> {camGame.angle = val;});

            for (name => sprite in stage.stageSprites)    
                sprite.visible = name != "PILLARS";

            if (Options.gameplayShaders) {
                camForeground.addShader(screenVignette);
                camHUD2.removeShader(screenVignette);

                if (FlxG.save.data.particles) camGame.addShader(snowShader);
            }
            camGame.removeShader(bloom_new);
            camHUD.removeShader(bloom_new);
            gradientShader.applyY = 1520;
            snowShader2.pixely = false; snowShader2.LAYERS = 13;
            snowShader2.snowMeltRect = [1000, 1220, 1500, 100];
            boyfriend.alpha = 1;            
            fogShader.applyY = 1520;
            water.strength = 0;

            for (element in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2, timeBarBG, timeBar])
                element.visible = true;

            for (element in [scoreTxt, missesTxt, accuracyTxt]) element.y += 10;

            for (strumLine in strumLines.members) {
                for (strum in strumLine.members) {
                    strum.scale.set(1, 1); strum.updateHitbox();
                    strum.setGraphicSize(Std.int((strum.width * finalNotesScale)));
                    strum.updateHitbox();
                }
            }

            if (Options.gameplayShaders && FlxG.save.data.water) camHUD.addShader(water);

        case 1840:
            FlxTween.num(.6, .4, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(15, 30, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
            FlxTween.num(.4, .05, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            camGame.removeShader(pixel);
            water.strength = 0;
            snowShader2.LAYERS = 30; snowShader.LAYERS = 31; 

            FlxTween.num(3, 2.7, (Conductor.stepCrochet / 1000) * 32, {ease: FlxEase.quadOut}, (val:Float) -> {snowSpeed = val;});
            FlxTween.num(1, 2.8, (Conductor.stepCrochet / 1000) * 34, {ease: FlxEase.quadOut}, (val:Float) -> {snowShader2.BRIGHT = val;});
            FlxTween.num(1, 2.4, (Conductor.stepCrochet / 1000) * 34, {ease: FlxEase.quadOut}, (val:Float) -> {snowShader.BRIGHT = val;});
            FlxTween.num(1, 1.8, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {fogShader.INTENSITY = val;});
            snowShader2.snowMelts = false;

            camForeground.removeShader(screenVignette);
            camCharacters.removeShader(snowShader2);
            if (Options.gameplayShaders) {
                camHUD2.addShader(screenVignette);
                if (FlxG.save.data.particles) camHUD.addShader(snowShader2);
            }
        case 1935:

        case 1936 | 1952 | 1968 | 2064 | 2080 | 2096 :
            FlxTween.num(.35, 0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {water.strength = val;});
            FlxTween.num(.3, .05, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            FlxTween.num(1.3, .4, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(32, 15, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
        case 2128:
            camHUD2.removeShader(screenVignette);
            camHUD.removeShader(snowShader2);

            if (Options.gameplayShaders) {
                camForeground.addShader(screenVignette);
                camCharacters.addShader(snowShader2);
            }

            snowShader2.snowMelts = true;

            bloom_new.size = 10; bloom_new.brightness = 1.4;
            snowSpeed = .7;
            snowShader2.BRIGHT = 1; snowShader.BRIGHT = 1;
            blackwhite?.grayness = 1;
            oldstatic?.strength = 4;
            flickerSprite.alpha = 0.1;

            FlxG.camera.zoom = 0.6;
        case 2236:
            if(blackwhite != null) FlxTween.num(1, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {blackwhite.grayness = val;});
        case 2279:
            flickerSprite.alpha = 0;
        case 2280:
            FlxTween.num(0, .7, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {gfAlpha = val;});

        case 2288: 
            snowShader2.BRIGHT = 3.5; snowShader.BRIGHT = 2.8; snowSpeed = 4;
            FlxTween.num(1.8, 1.85, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {fogShader.INTENSITY = val;});
            FlxTween.num(0, .13, (Conductor.stepCrochet / 1000) * 9, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            FlxTween.num(0, .1, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {water.strength = val;});

            FlxTween.num(1.4, .6, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 50, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});

            if(oldstatic != null) FlxTween.num(3, 1.9, (Conductor.stepCrochet / 1000) * 1, {ease: FlxEase.quadOut}, (val:Float) -> {oldstatic.strength = val;});
            if(blackwhite != null) FlxTween.num(.3, .5, (Conductor.stepCrochet / 1000) * 1,  {ease: FlxEase.quadOut}, (val:Float) -> {blackwhite.grayness = val;});
        case 2528:
            camGame.flash(0xEFFA0000, (Conductor.stepCrochet / 1000) * 4);

            FlxG.camera.followLerp = 2;
            FlxG.camera.zoom = 0.8;

            FlxTween.num(1, 0, ((Conductor.stepCrochet / 1000) * 7), {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
            
            FlxTween.num(1.8, .6, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 50, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
            FlxTween.num(1, .13, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
        case 2536:
            camZoomMult = 0.9; arrowSine = true;
            FlxG.camera.followLerp = 0.04; snowSpeed = 7;
            snowShader2.BRIGHT = 4; snowShader.BRIGHT = 2.9; 

            if(oldstatic != null) FlxTween.num(1.9, 3, (Conductor.stepCrochet / 1000) * 1, {ease: FlxEase.quadOut}, (val:Float) -> {oldstatic.strength = val;});
            if(blackwhite != null) FlxTween.num(.5, .8, (Conductor.stepCrochet / 1000) * 1,  {ease: FlxEase.quadOut}, (val:Float) -> {blackwhite.grayness = val;});

            FlxTween.num(1.8, .6, ((Conductor.stepCrochet / 1000) * 26), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 50, ((Conductor.stepCrochet / 1000) * 26), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
        case 2808:
            FlxG.camera.visible = camCharacters.visible = camForeground.visible = false;
            camHUD.removeShader(water);
        case 2836:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 0}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.quadOut});
        case 2860:
            arrowSine = false;
    }
}

function pixelbump() {
    if (!Options.gameplayShaders) return;
    FlxTween.num(4, 1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {pixel.blockSize = val;});
    FlxTween.num(.4, .0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {water.strength = val;});
    FlxTween.num(1.6, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
    FlxTween.num(20, 10, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
    FlxTween.num(.05, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {chromWarp.distortion = val;});
}

function epicbump() {
    if (!Options.gameplayShaders) return;
    FlxTween.num(.5, .2, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.cubeIn}, (val:Float) -> {water.strength = val;});
    FlxTween.num(.6, .4, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
    FlxTween.num(1.3, .6, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
    FlxTween.num(20, 15, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
}

function epicimpact() {
    if (!Options.gameplayShaders) return;
    for (cam in FlxG.cameras.list) cam.visible = false;
    new FlxTimer().start(0.06, () -> {
        safetyCam.alpha = 0.5;
        shaketime = .26; cancelCamMove = true; lerpCamZoom = false; gfAlpha = 0; 

        for (cam in FlxG.cameras.list) cam.visible = true;
        camGame.visible = false;

        chromWarp.distortion = 0; impact.threshold = .1; glitching.glitchAmount = 3;
        executeEvent({name: "ScreenCoverer", time: 0, params: [false, 0xFF000000, 0.1, 4, "quad", "Out", "camHUD", "back"]});

        new FlxTimer().start(0.08, () -> {
            cancelCamMove = false; lerpCamZoom = true; gfAlpha = .7;
            camGame.visible = true;

            impact.threshold = -1; chromWarp.distortion = .13;

            executeEvent({name: "Bloom Effect", time: 0, params: [false, 1.3, 4, "linear", "In"]});
            executeEvent({name: "Bloom Effect", time: 0, params: [true, 1, 2, "quad", "Out"]});

            safetyCam.alpha = 0;

            FlxG.camera.fade(FlxColor.BLACK, (Conductor.stepCrochet / 1000) * 4, true, () -> {}, true);

            FlxTween.num(1, 0, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});

            FlxTween.num(1.8, .6, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 50, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
        });
    });
}

function swagbump() {
    FlxTween.num(.3, .1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
}

function onStrumCreation(_) _.__doAnimation = false;