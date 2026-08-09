//
import flixel.effects.FlxFlicker;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxMatrix;
import funkin.backend.FlxAnimate;

public var static2:CustomShader;
public var chromWarp:CustomShader;
public var warp:CustomShader;
var redOverlayHUD:FlxSprite;
var flickerSprite:FunkinSprite;

var normalStrumPoses:Array<Array<Array<Int>>> = [];
var arrowSine:Bool = false;

var camPaps:FlxCamera;
public var screenVignette2:CustomShader;

function postCreate() {

    stage.getSprite("bg_start").alpha = 1;
    stage.getSprite("floorLights").alpha = 0;
    stage.getSprite("room").alpha = 0;
    stage.getSprite("bg_monitor").alpha = 0;

    dust.BRIGHT = 0;

    camPaps = new FlxCamera(0, 0);

    for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
    for (cam in [camGame, camHUD, camPaps, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    static2 = new CustomShader("static2");
    static2.iTime = 0; static2.strengthMulti = 1;
    if (Options.gameplayShaders && FlxG.save.data.static) FlxG.camera.addShader(static2);

    redOverlayHUD = new FunkinSprite();
    redOverlayHUD.makeSolid(1280, 720, 0xFFFF0000);
    redOverlayHUD.scrollFactor.set(0, 0);
    redOverlayHUD.zoomFactor = 0;
    redOverlayHUD.alpha = 0;
    redOverlayHUD.cameras = [camGame];

    insert(members.indexOf(dad), redOverlayHUD); 

    flickerSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
    flickerSprite.scrollFactor.set(0, 0);
    flickerSprite.zoomFactor = 0;
    flickerSprite.cameras = [camHUD];
    flickerSprite.alpha = 0.04;
    add(flickerSprite);

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = 0;

    warp = new CustomShader("warp");
    warp.distortion = 0;

    if(FlxG.save.data.antiFlash)
        FlxFlicker.flicker(flickerSprite, 9999999, 0.05);

    for (i=>strum in strumLines.members) {
        normalStrumPoses[i] = [for (s in strum.members) [s.x, s.y]];
    }

    gf.cameras = [camPaps];
    camPaps.visible = false;

    screenVignette2 = new CustomShader("coloredVignette_clip");
    screenVignette2.strength = 1.2;
    screenVignette2.amount = 1.2;
    screenVignette2.color = [0.0, 0.0, 0.0];
    
    if (Options.gameplayShaders) {
        if (FlxG.save.data.warp) camGame.addShader(warp);
        if (FlxG.save.data.chromwarp) camGame.addShader(chromWarp);

        if (FlxG.save.data.bloom) {
            FlxG.camera.removeShader(bloom);
            FlxG.camera.addShader(bloom);
        }

        if (FlxG.save.data.bloom) camPaps.addShader(bloom);

        if (FlxG.save.data.static) {
            camPaps.addShader(oldstatic);
            camPaps.addShader(static2);
        }

        camPaps.addShader(screenVignette2);
    }
    spawnPapsTrail(gf);
}

var drainAmount:Float = .3;
var gainAmount:Float = .053;
var drainHealth:Bool = false;

function stepHit(step:Int) {
    switch (step) {
        case 48: FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut}, (val:Float) -> {dust.BRIGHT = val;});
        case 64:
            showTitleCard();
            stage.getSprite("bg_start").alpha = 0;

            stage.getSprite("floorLights").alpha = 1;
            stage.getSprite("room").alpha = 1;
            stage.getSprite("bg_monitor").alpha = 1;
            stage.getSprite("bg_light2").alpha = 1;
            stage.getSprite("bg_light3").alpha = 1;
            dad.alpha = 1;
            boyfriend.alpha = 1;

            if (!Options.gameplayShaders) {
                dad.color = FlxColor.WHITE;
                boyfriend.color = FlxColor.WHITE;
            }

            if (!FlxG.save.data.bloom || !Options.gameplayShaders)
                for (spr in ["floorLights", "room", "bg_monitor", "bg_light2", "bg_light3"]) {
                    stage.getSprite(spr).alpha = 0.1;
                    FlxTween.tween(stage.getSprite(spr), {alpha: 1}, .6, {ease: FlxEase.quadOut});
                }

            FlxG.camera.shake(0.01, 0.55);

            FlxTween.num(1, .13, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (val:Float) -> {static2.strengthMulti = val;});
        case 208:
            stage.getSprite("drakOVER").alpha = 0.5;
        case 848: 
            static2.strengthMulti *= 0.75;
            oldstatic.strength *= 0.75;
            flickerSprite.alpha *= 0.75;
        case 848: 
            static2.strengthMulti *= 1.25;
            oldstatic.strength *= 1.25;
            flickerSprite.alpha *= 1.25;

            static2.strengthMulti *= 1.25;
            oldstatic.strength *= 1.25;
            flickerSprite.alpha *= 1.5;
        case 984:
            updateDTLights = false;
            stage.getSprite("dtLights").alpha = 0.35;
            stage.getSprite("dtEyes").alpha = 0.45;
            stage.getSprite("g_OVER").alpha = 0.5;
        case 1000:
            arrowSine = true;
            camZoomMult = 0.9;
        case 1547:
            FlxTween.num(0, 1, 3, {ease: FlxEase.quadIn}, (val:Float) -> {
                stage.getSprite("dtLights").alpha = 0.35 + (0.25 * val);
                stage.getSprite("dtEyes").alpha = 0.45 + (0.25 * val);
                stage.getSprite("g_OVER").alpha = 0.5 - (0.45 * val);
                eyeItensity = 0.1 * val;
            });
        case 1803: // EVERY SOUL HAD TO DIE
            dad.visible = false;
            boyfriend.visible = false;
            camGame.visible = false;
            /*stage.getSprite("bg_main").visible = false;
            stage.getSprite("bg_end").visible = false;
            stage.getSprite("bg_start").visible = false;
            stage.getSprite("bg_monitor").visible = false;
            stage.getSprite("bg_light2").visible = false;
            stage.getSprite("bg_light3").visible = false;*/

            dust.BRIGHT = 0;
            //papsTrails[0].visible = false;
            gf.script.set("enabledTrails", false);
            for (trail in gf.script.get("papsTrails")) {
                gf.script.get("papsTrails").remove(trail);
                trail = null;
            }

        case 1812:
            gf.color = 0xFF9E7E7E;
            camGame.visible = true;
            camPaps.removeShader(bloom);

            dad.visible = true;
            boyfriend.visible = true;

            stage.getSprite("dtLights").alpha = 1;
            stage.getSprite("dtEyes").alpha = 1;

            stage.getSprite("dtOVER").alpha = 0.45;

            eyeItensity = 0.6;
            /*stage.getSprite("bg_main").visible = true;
            stage.getSprite("bg_end").visible = true;
            stage.getSprite("bg_start").visible = true;
            stage.getSprite("bg_monitor").visible = true;
            stage.getSprite("bg_light2").visible = true;
            stage.getSprite("bg_light3").visible = true;*/
            dust.BRIGHT = 1;

            //papsTrails[0].visible = true;
            gf.script.set("enabledTrails", true);

        case 2084: 
            FlxG.camera.shake(0.01, 0.2);
            FlxTween.tween(gf, {alpha: 0}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut});
            FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {
                stage.getSprite("dtOVER").alpha = 0.5 + (0.5 * val);
                stage.getSprite("g_OVER").alpha = 0.05 - (0.95 * val);
                eyeItensity = 0.6 + (0.4 * val);
            });
            clearTrails();
        case 2109: 
            hurtColor = 0xFFFF0000;
            if (Options.gameplayShaders) dustiniconP1.shader.color = [1., 0., 0.];

            health = 2; // DISABLE ON HELL IF IT EVER COMES OUT -lunar
            drainHealth = true;
            FlxG.camera.shake(0.01, 0.4);
            dustiniconP1.onDraw = (spr) -> {
                spr.x -= spr.width / 2;
                spr.draw();
                spr.x += spr.width / 2;
            }
            dustinHealthBG.y -= 32;
            dustinHealthBar.y -= 32;
            healthBarColors[0] = 0x00000000;
            FlxTween.tween(dustinHealthBG, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP1, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            
        case 2110:
            cinematicBar1.cameras = [camHUD2];
            cinematicBar2.cameras = [camHUD2];
            remove(cinematicBar1);
            remove(cinematicBar2);
            insert(9999, cinematicBar1);
            insert(9999, cinematicBar2);
        case 2160:
            FlxTween.tween(dad, {alpha: 0}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.quadOut});
        case 2116: 
            FlxTween.num(.46, .66, 10, {ease: FlxEase.quadIn}, (val:Float) -> {drainAmount = val;});

            FlxG.camera.shake(0.004, 11); 
            camHUD.shake(0.004, 11); 
            FlxTween.tween(redOverlayHUD, {alpha:1}, 10, {ease: FlxEase.quadIn});
            FlxTween.num(0, 1, 10, {ease: FlxEase.quadIn}, (val:Float) -> {chromWarp.distortion = val;});
            FlxTween.num(0, 2.4, 10, {ease: FlxEase.circOut}, (val:Float) -> {warp.distortion = val;});
        case 2235:
            FlxTween.tween(dustinHealthBG, {alpha: 0}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 0}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP1, {alpha: 0}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut});
        case 2238:
            dad.alpha = 1;
            drainHealth = false;
            redOverlayHUD.alpha = 0;
            chromWarp.distortion = 0;
            warp.distortion = 0;
            if (Options.gameplayShaders) {
                shadows.boyfriend.distance = 0;
                shadows.dad.distance = 0;
            }
            FlxG.camera.shake(0.02, 0.5);
            stage.getSprite("dtLights").alpha = 0;
            stage.getSprite("dtEyes").alpha = 0;
            stage.getSprite("dtOVER").alpha = 0;
            stage.getSprite("g_OVER").alpha = 0;
            eyeItensity = 0;
    }
}

var lock24FPS:Array<{sprite:FlxSprite, x:Float, y:Float, anim:String}> = [];
var dad24FPS:{x:Float, y:Float, anim:String} = null;
var __coolTimer:Float = 0;

var tottalTimer:Float = FlxG.random.float(100, 1000);  // Stole this from the snow shader script cuz I liked the idea lmfao  - Nex
function update(elapsed:Float) {
    //gf.alpha = 0;
    //gf.visible = 1;
    //camPaps.visible = 1;
    //camPaps.alpha = 1;
    tottalTimer += elapsed;
    __coolTimer += elapsed;
    oldstatic.time = tottalTimer;
    dust.time = tottalTimer*.7;
    static2.iTime = tottalTimer;

    dust.cameraZoom = FlxG.camera.zoom;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];

    for (info in lock24FPS) {
        var sprite = info.sprite;
        if (sprite.animation.name != info.anim) {
            sprite.x = info.x; sprite.y = info.y;
            if (info.angle != null) sprite.angle = info.angle;
            info.anim = sprite.animation.name;
        }
    }

    if (dad24FPS != null) {
        var waveSpeed = __coolTimer * 2;
        var bobX = Math.sin(waveSpeed) * 50;
        var bobY = Math.cos(waveSpeed * 0.8) * 40 + Math.sin(waveSpeed * 1.5) * 10;

        dad24FPS.x = (1780 + bobX*.4);
        dad24FPS.y = (1100 + bobY*.4);
    }

    for (paptrail in papsTrails) {
        for (i => trail in paptrail.members) {
            var scale = FlxMath.bound(2.2 + .1 + (.1 * FlxMath.fastSin(__coolTimer + (i * FlxG.random.float((Conductor.stepCrochet / 1000) * 0.5, (Conductor.stepCrochet / 1000) * 1.2)))), 0.9, 999);
            trail.scale.set(scale, scale);
        }
    }

    camPaps.scroll = FlxG.camera.scroll;
    camPaps.zoom = FlxG.camera.zoom;
    // camPaps.angle = FlxG.camera.angle;

    if (!arrowSine) return;
    for (i => strumLine in strumLines.members) {
        for (k=>s in strumLine.members) {
            s.x = lerp(s.x, arrowSine ? normalStrumPoses[i][k][0] + (3*FlxMath.fastCos((__coolTimer*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) + 20 : normalStrumPoses[i][k][0], .6);
            s.y = lerp(s.y, arrowSine ? normalStrumPoses[i][k][1] + (13*FlxMath.fastSin((__coolTimer*3) + ((Conductor.stepCrochet / 1000) * (k*2) * 4))) : normalStrumPoses[i][k][1], .6);
        }
    }

    if (drainHealth && FlxG.save.data.mechanics) {
        health -= (drainAmount*.96) * elapsed;
        if (FlxG.keys.justPressed.SPACE) health += gainAmount;
    }
}

function lyrics() {
    spawnPapsTrail(gf);
    FlxTween.tween(gf, {alpha: 1}, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.quadOut});
    lock24FPS = [];
    dad24FPS = {sprite: gf, x: 1780, y: 1100, anim: gf.animation.name}
    lock24FPS.push(dad24FPS);
    __coolTimer = 0;

    trace('play the goddamn animation already');
    gf.playAnim("lyrics", true);

    camPaps.visible = true;
    camPaps.angle = 0;
    // cinematicBar1.cameras = [camPaps];
    // cinematicBar2.cameras = [camPaps];
    
    // remove(cinematicBar1);
    // remove(cinematicBar2);
    // insert(9999, cinematicBar1);
    // insert(9999, cinematicBar2);
}

function flash_red() {
    FlxG.camera.shake(0.002, 0.16);
    baseAngle = FlxG.random(-3, 3);
}

public var papCameraNormalizer:Float = .6;
function onCameraMove(_) {
    // normalize mtt movement a bit
    if (_.strumLine.characters[0].curCharacter == "papyrus_lyrics") {
        _.position.x -= (gf.x - 1780)*FlxMath.lerp(.8, 1, papCameraNormalizer);
        _.position.y -= (gf.y - 1100)*FlxMath.lerp(.7, 1, papCameraNormalizer);
    }
}

var papsTrails:Array<AtlasTrail> = [];
function spawnPapsTrail(sprite:FlxSprite) {
    return;
    trail = new AtlasTrail(sprite, null, 12, 4, 0.25, 0.045);
    trail.color = 0xFFFFFFFF;
    insert(members.indexOf(sprite), trail);
    papsTrails.push(trail);
    trail.cameras = [camPaps];
    // trail.rotationsEnabled = false;
    return trail;
}

function clearTrails() {
    for (trail in papsTrails) {
        remove(trail);
        trail.destroy();
    }

    papsTrails = [];
}


var cannedGameOvers:Bool = false;
function onGameOver(_) {
    if (cannedGameOvers) {
        _.cancel();
        return;
    }

    if (!PlayState.isStoryMode || !drainHealth) return;

    _.cancel();
    cannedGameOvers = true;

    persistentUpdate = false;
    persistentDraw = false;
    paused = true;

    vocals.stop();
    if (FlxG.sound.music != null)
        FlxG.sound.music.stop();
    for (strumLine in strumLines.members) strumLine.vocals.stop();

    for (cam in FlxG.cameras.list) cam.visible = false;

    FlxG.sound.play(Paths.sound('startBreak'), 1);
    new FlxTimer().start(1, function() {
        FlxG.sound.play(Paths.sound('endBreak'), 1);
        FlxG.sound.play(Paths.sound('undertale/snd_damage_c'), 1);
        new FlxTimer().start(3, function() {
            FlxG.switchState(new ModState("EndingCredits", "secret"));
        });
    });
}

/*function draw() {
    for (trail in papsTrails) {
        for (limb in trail.limb_instance) {
            @:privateAccess {
            dad.atlasAnim.parseElement(limb, 0, new FlxMatrix(), dad.colorTransform, dad.blend, true);
            }
        }
    }
}*/

class AtlasTrail extends FlxTrail {

    private var _l:Int = -5;
    public var limb_instance:Array<FlxElement> = [];

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (_l != (_l = members.length)) {
            for(i in members) {
                trace('oh');
                if (i.animateAtlas == null && target.animateAtlas != null) {
                    limb_instance.push(target.animateAtlas.anim.cutInstance);
                }
            }
        }
    }

    override public function draw() {
        trace(',y');
        return super.draw();
    }
}