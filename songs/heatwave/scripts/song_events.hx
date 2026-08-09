//
import flixel.effects.FlxFlicker;
import flixel.addons.effects.FlxTrail;

var flickerSprite:FlxSprite;
var warp:CustomShader;
var radial:CustomShader;
var heathud:CustomShader;
var wi:CustomShader;
var tape_noise:CustomShader;
public var lightShader:CustomShader;
var disableTrail:Bool = false;
var mttTrail:FlxTrail;

var normalStrumPoses:Array<Array<Array<Int>>> = [];
var arrowSine:Bool = false;
function create() {
    warp = new CustomShader("warp");
    warp.distortion = 0;

    radial = new CustomShader("radial");
    radial.blur = 0;
    radial.center = [0.5, 0.5];

    heathud = new CustomShader("heatwave");
    heathud.time = 0; heathud.speed = 6; 
    heathud.even = true;
    heathud.strength = 0.08; 

    wi = new CustomShader("wi");
    wi.iTime = 0; wi.timeMulti = 1.;
    wi.glitchModifier = .2; wi.fullglitch = .6; wi.effectMulti = .3;
    wi.moveScreenFullX = true; wi.moveScreenX = true; wi.moveScreenFullY = true;

    wi.working = false;

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 0;

    lightShader = new CustomShader("heatlight");
    lightShader.threshold = .14;

    if (Options.gameplayShaders) {
        if (FlxG.save.data.warp) {
            FlxG.camera.addShader(warp);
            camCharacters.addShader(warp);
        }

        if (FlxG.save.data.static) FlxG.camera.addShader(tape_noise);

        if (FlxG.save.data.glitch) {
            FlxG.camera.addShader(wi);
            camCharacters.addShader(wi);
            camHUD.addShader(wi);
        }
    }

    flickerSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
    flickerSprite.scrollFactor.set(0, 0);
    flickerSprite.zoomFactor = 0;
    flickerSprite.cameras = [camHUD2];
    flickerSprite.alpha = 0.0;
    add(flickerSprite);

    if(!FlxG.save.data.antiFlash)
        FlxFlicker.flicker(flickerSprite, 9999999, 0.04);

    mtt.alpha = 0.00000001;

    mttTrail = new FlxTrail(gf, null, 32, 11, 0.35, 0.045);
    mttTrail.visible = false;
    mttTrail.color = 0xFFFBB8FF;
    insert(members.indexOf(mtt), mttTrail);
}

function postCreate() {
    for (i=>strum in strumLines.members) {
        normalStrumPoses[i] = [for (s in strum.members) [s.x, s.y]];
    }
}

public var cancelCamMove:Bool = false;
function onCameraMove(camMoveEvent) {
    if (cancelCamMove) camMoveEvent.cancel();
}

function stepHit(step:Int) {
    switch (step) {
        case 128: showTitleCard();
        case 376:
            FlxTween.num(1.3, 6, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {oldstatic.strength = val;});
            FlxTween.num(0, .7, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(0, .3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
        case 384:

            heat.strength = .25;
            heat.speed = 6;
            if (Options.gameplayShaders) {
                camCharacters.addShader(radial);   
                FlxG.camera.addShader(radial);

                if (FlxG.save.data.glitch) camCharacters.addShader(glitching);

                if (FlxG.save.data.fire) camHUD.addShader(heathud);
            }

            FlxTween.num(8, 2.3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {oldstatic.strength = val;});
            FlxTween.num(.8, .0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});

            executeEvent({name: "Bloom Effect", time: 0, params: [false, 1.6, 4, "linear", "In"]});
            executeEvent({name: "Bloom Effect", time: 0, params: [true, 1.1, 12, "quad", "Out"]});
            executeEvent({name: "Screen Coverer", time: 0, params: [false, 0xFF000000, 0, 4, "quad", "Out", "camHUD", "back"]});

            FlxTween.num(.4, 0, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
            FlxTween.num(.07, .002, ((Conductor.stepCrochet / 1000) * 8), {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(.3, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            FlxTween.num(2.5, 3.5, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {fogShader.INTENSITY = val;});

        case 452 | 640:
            FlxTween.num(.055, .002, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});

        case 516: 
            camMoveOffset = 0; camAngleOffset = 0;

            FlxTween.num(.055, .002, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
        case 576: 
            camMoveOffset = 15; camAngleOffset = .3;

            FlxTween.num(.055, .002, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
        case 639:
            FlxG.camera.followLerp = 0.08;
        case 672 | 912 | 928 | 960 | 976 | 992:
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {glitching.glitchAmount = val;});
        case 708:
            FlxTween.num(.025, .002, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
        case 761:
            for (name => sprite in stage.stageSprites)
                sprite.alpha = 0.2;

            FlxG.camera.zoom = 0.7; /* camZoomLerpMult = 100/0.5; */ camZoomMult = 0.875; camHUD.zoom = 0.875;
            camCharacters.removeShader(radial);
            FlxG.camera.followLerp = 0.17; wi.time = 0.4; wi.working = true;
            FlxTween.num(30, 10, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (val:Float) -> {oldstatic.strength = val;});
            FlxTween.num(.002, .016, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(3, 2.5, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {tape_noise.strength = val;});
            warp.distortion = 1.8;
            glitching.glitchAmount = 1.2;

            flickerSprite.alpha = 0.3;
        case 764: cancelCamMove = true; FlxG.camera.followLerp = 0.03; 
        case 768: 
            if (Options.gameplayShaders && FlxG.save.data.water) camHUD.addShader(water);
            for (name => sprite in stage.stageSprites)
                FlxTween.num(0.1, 1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {sprite.alpha = val;});
            cancelCamMove = false; flickerSprite.alpha = 0.08; camZoomLerpMult = 1; camZoomMult = 1; wi.working = false;
            FlxTween.num(.016, .008, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1.3, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {glitching.glitchAmount = val;});
            FlxTween.num(1.8, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (val:Float) -> {warp.distortion = val;});
            FlxTween.num(0, .15, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(0, .6, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
        case 832: FlxG.camera.followLerp = 0.1;
        case 836: FlxG.camera.followLerp = 0.04;
        case 896:
            if (Options.gameplayShaders) camCharacters.addShader(radial);
            flickerSprite.alpha = 0.02;
            FlxTween.num(.008, .002, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(.15, .1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (val:Float) -> {water.strength = val;});
            FlxTween.num(.6, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});

            FlxTween.num(10, 2, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (val:Float) -> {oldstatic.strength = val;});
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.cubeIn}, (val:Float) -> {tape_noise.strength = val;});

            FlxTween.num(.055, .002, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(1.4, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
        case 1012:
            FlxG.camera.followLerp = 0.02;
        case 1024:
            FlxG.camera.followLerp = 0.04;

            stage.stageSprites["core"].visible = false;
            stage.stageSprites["core_broken"].visible = true;
            
            for (camera in FlxG.cameras.list) camera.visible = false;
            (new FlxTimer()).start(0.06, function (_) {
                camCharacters.shake(0.01, 0.3);
                camCharacters.visible = true;
                camCharacters.removeShader(fogShader);

                stage.stageSprites["CORE_IMPACT1"].visible = true;
                (new FlxTimer()).start(0.07, function (_) {
                    stage.stageSprites["CORE_IMPACT1"].visible = false;
                    stage.stageSprites["CORE_IMPACT2"].visible = true;
                    (new FlxTimer()).start(0.05, function (_) {
                        stage.stageSprites["CORE_IMPACT2"].visible = false;
                        executeEvent({name: "Screen Coverer", time: 0, params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]});
                        executeEvent({name: "Bloom Effect", time: 0, params: [false, 1, 12, "quad", "Out"]});

                        for (camera in FlxG.cameras.list) camera.visible = true;
                        if (Options.gameplayShaders && FlxG.save.data.fog) camCharacters.addShader(fogShader);
                    });
                });
            });
        case 1088:
            FlxG.camera.zoom = 0.65; camZoomMult = 0.85; camHUD.zoom = 0.85;

            tape_noise.strength = 3; oldstatic.strength = 10; flickerSprite.alpha = 0.1;
            wi.working = true; wi.moveScreenFullY = false; FlxG.camera.zoom = 0.6;
            FlxTween.num(30, 0, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.cubeOut}, (val:Float) -> {oldstatic.strength = val;});
            FlxTween.num(.002, 0.001, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(3, 0, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.cubeIn}, (val:Float) -> {tape_noise.strength = val;});
            warp.distortion = 1.8;
            glitching.glitchAmount = 2;

            for (name => sprite in stage.stageSprites) 
                if (name != "bgForw") sprite.alpha = 0.2;

            mtt.cameras = [camCharacters];
            stage.stageSprites["bgForw"].cameras = [camCharacters];
            stage.stageSprites["bgForw"].alpha = 1;
            stage.stageSprites["bgForw"].colorTransform.color = 0xFF000000;

            mtt.alpha = 1; mttCameraNormalizer = 1; 
            mttYOffset += 1000; mttIdle = false;

            if (Options.gameplayShaders && FlxG.save.data.godrays) camCharacters.addShader(lightShader);
            fogShader.INTENSITY = 0;

            FlxG.camera.visible = false;

            FlxTween.num(1000, 0, (Conductor.stepCrochet / 1000) * (16 * 7.25), {}, (val:Float) -> {mttYOffset = val;});
        case 1092:
            flickerSprite.alpha = 0; camZoomMult = 0.85;
            FlxTween.num(.4, .2, (Conductor.stepCrochet / 1000) * 48, {ease: FlxEase.cubeOut}, (val:Float) -> {glitching.glitchAmount = val;});
            FlxTween.num(3, 0, (Conductor.stepCrochet / 1000) * 48, {ease: FlxEase.cubeOut}, (val:Float) -> {tape_noise.strength = val;});
            FlxTween.num(1.8, 0, (Conductor.stepCrochet / 1000) * 48, {ease: FlxEase.cubeOut}, (val:Float) -> {warp.distortion = val;});
            FlxTween.num(.055, .0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(2, 1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {chromWarp.distortion = val;});
            wi.working = false; wi.moveScreenFullY = true; wi.time = 0.4; 

            for (name => sprite in stage.stageSprites)
                if (name != "bgForw") FlxTween.num(0.1, 1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {sprite.alpha = val;});
        case 1200: countdown(0);
        case 1204: countdown(1);
        case 1208: countdown(2);
        case 1212: countdown(3);
        case 1216:
            FlxG.camera.visible = true;
            fogShader.INTENSITY = 2;
            camCharacters.removeShader(lightShader);
            mtt.cameras = [FlxG.camera];
            stage.stageSprites["bgForw"].cameras = [FlxG.camera];
            stage.stageSprites["bgForw"].colorTransform = null;
            // add(spr_grad);
            camZoomMult = .95;
            mttIdle = true; __coolTimer = 0; mttCameraNormalizer = 0; disableTrail = true;

            flames.intensitiy = .05;
            embers.strength = 2; embers.speed = 1.4;
            fogShader.FEATHER = 400;
            stage.getSprite("embershit").y -= 50;
            stage.getSprite("embershit").height += 50;

            stage.getSprite("embershit2").y -= 300;
            stage.getSprite("embershit2").height += 300;

            embers2.SIZE_MOD = 1.1;
            embers2.ALPHA_MOD = .8;
            embers2.LAYERS_COUNT = 10;

            heathud.strength = 0.06;
            FlxG.camera.removeShader(radial);
            if (Options.gameplayShaders) {
                if (FlxG.save.data.glitch) FlxG.camera.addShader(glitching);
                FlxG.camera.addShader(radial);
            }

            glitching.glitchAmount = 0; chromWarp.distortion = 0;
            wi.time = 0.4; FlxG.camera.removeShader(wi);
        case 1348:
            FlxG.camera.followLerp = 0.06;
        case 1248 | 1256 | 1264 | 1296 | 1312 | 1328 | 1520 | 1528 | 1616 | 1648:
            FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
            FlxTween.num(.9, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {chromWarp.distortion = val;});
        case 1344 | 1360 | 1376 | 1384 | 1392 | 1412 | 1440 | 1448 | 1472 | 1584 | 1720:
            FlxTween.num(.01, .00, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (val:Float) -> {radial.blur = val;});
            FlxTween.num(.9, 0, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});
            FlxTween.num(.9, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {chromWarp.distortion = val;});
        case 1600:
            mttTrail.visible = true;
            heat.strength = .5;
            heat.speed = 10;
            heathud.strength = 0.04;
            FlxTween.num(0, .35, (Conductor.stepCrochet / 1000) * 24, {ease: FlxEase.quadOut}, (val:Float) -> {flames.intensitiy = val;});

            camCharacters.flash(0xFFFF0000, (Conductor.stepCrochet / 1000) * 12);
        case 1728:
            camZoomMult = 0.9; arrowSine = true;
            camHUD.removeShader(heathud);
            // warp.distortion = 1;

            camCharacters.flash(0xFFF100FF, (Conductor.stepCrochet / 1000) * 8);
        case 1984:
            for (strumLine in strumLines)
                for (strum in strumLine.members) 
                    FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadInOut}, (val:Float) -> {strum.alpha = val;});

            // start_test_fight();
        case 2224:
            for (strumLine in strumLines)
                for (strum in strumLine.members) 
                    strum.alpha = 1;
            FlxG.camera.followLerp = 0.02; fogShader.INTENSITY = 0;
            mtt.alpha = 0; camMoveOffset = 0;
            camAngleOffset = 0; mttTrail.visible = false;
            tape_noise.strength = 2; radial.blur = .0;
            oldstatic.strength = 4; flickerSprite.alpha = 0.07;
        case 2607:
            for (camera in FlxG.cameras.list) camera.visible = false;
    }

    if ((step >= 1096 && step <= 1176) && step % 4 == 0) {
        FlxTween.num(.01, .00, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {radial.blur = val;});
        FlxTween.num(.5, .0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {warp.distortion = val;});
    } 

    if ((step >= 1096 && step <= 1172) && step % 4 == 0) {
        FlxTween.num(.45, .4, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeOut}, (val:Float) -> {chromWarp.distortion = val;});
    } 
}

public var shaketime:Float = 0;
public var __coolTimer:Float = 0;
function update(elapsed:Float) {
    __coolTimer += elapsed;
    heathud.time = __coolTimer;
    tape_noise.time = __coolTimer;
    wi.iTime = Math.floor(__coolTimer*40)/40;
    
    for (i=>trail in mttTrail.members) {
        var scale = FlxMath.bound(1 + (.11 * FlxMath.fastSin(__coolTimer + (i * FlxG.random.float((Conductor.stepCrochet / 1000) * 0.5, (Conductor.stepCrochet / 1000) * 1.2)))), 0.9, 999);
        trail.scale.set(scale, scale);
    }

    if (shaketime > 0) {
        var xMod:Float = FlxG.random.float(-1, 1)*1.5;
        var yMod:Float = FlxG.random.float(-1, 1)*1.5;

        for (cam in [camGame, camCharacters, camHUD,camHUD2]) {
            cam.scroll.x += xMod; cam.scroll.y += yMod;
        }
        shaketime -= elapsed;
    }

    if (!arrowSine) return;
    for (i => strumLine in strumLines.members) {
        for (k=>s in strumLine.members) {
            s.x = lerp(s.x, arrowSine ? normalStrumPoses[i][k][0] + (3*FlxMath.fastCos((__coolTimer*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) + 20 : normalStrumPoses[i][k][0], .6);
            s.y = lerp(s.y, arrowSine ? normalStrumPoses[i][k][1] + (13*FlxMath.fastSin((__coolTimer*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) : normalStrumPoses[i][k][1], .6);
        }
    }
}