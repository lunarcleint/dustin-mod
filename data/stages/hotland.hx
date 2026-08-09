//
import flixel.util.FlxGradient;
import openfl.Lib;

public var heat:CustomShader;
public var embers:CustomShader;
public var embers2:CustomShader;
public var fogShader:CustomShader;

public var chromWarp:CustomShader;
public var water:CustomShader;
public var glitching:CustomShader;

public var oldstatic:CustomShader;
public var flames:CustomShader;

public var camCharacters:FlxCamera;
public var mtt:Character;

function create() {
    camCharacters = new FlxCamera(0, 0);

    for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
    for (cam in [camGame, camCharacters, camHUD, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    heat = new CustomShader("heatwave");
    heat.time = 0; heat.speed = 4; 
    heat.even = false;
    heat.strength = 0.12; 

    oldstatic = new CustomShader("static");
    oldstatic.time = 0; oldstatic.strength = 1.3;

    embers = new CustomShader("coresparks");
    embers.time = 0; embers.speed = 1;
    embers.strength = 1; embers.zoom = 1;
    stage.getSprite("embershit").flipY = true;

    embers2 = new CustomShader("firething");
    embers2.LAYERS_COUNT = 7; embers2.ALPHA_MOD = .2;
    embers2.SIZE_MOD = 1.4;
    embers2.iTime = 0; embers2.res = [FlxG.width, FlxG.height];

    fogShader = new CustomShader("fog");
    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    fogShader.res = [FlxG.width, FlxG.height]; fogShader.time = 0;

    fogShader.FOG_COLOR = [41./255., 21./255., 7./255.]; fogShader.BG = [.1, 0.0, 0.0];
    fogShader.ZOOM = 3.0; fogShader.OCTAVES = 8; fogShader.FEATHER = 200;
    fogShader.INTENSITY = 2.5;

    fogShader.applyY = boyfriend.y+770;
    fogShader.applyRange = 1500;

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = 0;

    water = new CustomShader("waterDistortion");
    water.strength = .0;

    glitching = new CustomShader("glitching2");
    glitching.time = 0; glitching.glitchAmount = 0;

    flames = new CustomShader("roaring_flame"); // flame on!!!! -lunar
    flames.time = 0; flames.intensitiy = 0; flames.zoom = 1;

    if (Options.gameplayShaders) {
        if (FlxG.save.data.particles) {
            stage.getSprite("embershit").shader = embers;
            stage.getSprite("embershit2").shader = embers2;
        }

        if (FlxG.save.data.fire) {
            stage.getSprite("lavaPT2").shader = heat;
            FlxG.camera.addShader(heat);
            camCharacters.addShader(heat);
        }

        if (FlxG.save.data.chromwarp) camGame.addShader(chromWarp);

        if (FlxG.save.data.water) camGame.addShader(water);

        if (FlxG.save.data.static) {
            FlxG.camera.addShader(oldstatic);
            camCharacters.addShader(oldstatic);
        }

        if (FlxG.save.data.fog) camCharacters.addShader(fogShader);

        if (FlxG.save.data.glitch) stage.getSprite("rflames").shader = flames;
    }

    stage.getSprite("rflames").flipY = true;

    stage.stageSprites["CORE_IMPACT1"].cameras = [camCharacters];
    stage.stageSprites["CORE_IMPACT2"].cameras = [camCharacters];
    
    mtt = strumLines.members[2].characters[0];
}

var _lastSANSanim:String;
var _lastBFanim:String;

function postCreate() {
    sansShadow?.playAnim(_lastSANSanim = dad.getAnimName(), true, "DANCE");
    bfShadow?.playAnim(_lastBFanim = boyfriend.getAnimName(), true, "DANCE");

    if (Options.gameplayShaders) {
        if (FlxG.save.data.bloom) camCharacters.addShader(bloom);
        if (FlxG.save.data.saturation) camCharacters.addShader(contrast);
    }
}

function onDadHit(event) {
    if (event.character.curCharacter == "sans_heatwave")
        sansShadow?.playAnim(dad.singAnims[event.direction % dad.singAnims.length], true, "SING");
}

function onPlayerHit(event)
    bfShadow?.playAnim(boyfriend.singAnims[event.direction % boyfriend.singAnims.length], true, "SING");

function beatHit(beat) {
    if(beat % dad.beatInterval == 0 && dad.getAnimName() == "idle") sansShadow?.playAnim("idle", false, "DANCE");
    if(beat % boyfriend.beatInterval == 0 && boyfriend.getAnimName() == "idle") bfShadow?.playAnim("idle", false, "DANCE");
}

var tottalTimer:Float = FlxG.random.float(100, 1000);  // Stole this from the snow shader script cuz I liked the idea lmfao  - Nex
var mttAnimationFrameName:String = "";
public var mttXOffset:Float = 0;
public var mttYOffset:Float = 0;
public var mttIdle:Bool = true;
function update(elapsed:Float) {
    heat?.time = (tottalTimer += elapsed);
    embers?.time = tottalTimer;
    embers2?.iTime = tottalTimer;
    fogShader.time = tottalTimer;
    oldstatic.time = tottalTimer;
    water.time = tottalTimer;
    glitching.time = tottalTimer;
    flames.time = tottalTimer;

    embers2.SIZE_MOD = 1.4 / (Lib.application.window.width/FlxG.width);
    flames.zoom = 1 / (Lib.application.window.width/FlxG.width);
    embers.zoom = Math.max(.96, 1 / (Lib.application.window.width/FlxG.width));

    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];

    var anim = dad.getAnimName();
    if(_lastSANSanim != anim && (_lastSANSanim = anim) == "idle") sansShadow?.playAnim("idle", true, "DANCE");
    if(_lastBFanim != (anim = boyfriend.getAnimName()) && (_lastBFanim = anim) == "idle") bfShadow?.playAnim("idle", true, "DANCE");

    for (strum in strumLines)
        for (char in strum.characters) {
            if (char.curCharacter != "mtt") char.cameras = [camCharacters];
        }

    // make him move with animation so it doesnt have the fnf look
    if (mttIdle && mttAnimationFrameName != mtt.animation.frameName) {
        mtt.x = (100 + Math.sin(__coolTimer)*204)+mttXOffset;
        mtt.y = (-380 + (Math.sin(__coolTimer*2)/2)*(102))+mttYOffset;
    } else if (!mttIdle) {
        mtt.x = 100+mttXOffset;
        mtt.y = -380+mttYOffset;
    }

    mttAnimationFrameName = mtt.animation.frameName;
}

function postUpdate(elapsed) DustinUtil.copyCamera(FlxG.camera, camCharacters);

public var mttCameraNormalizer:Float = 0;
function onCameraMove(_) {
    // normalize mtt movement a bit
    if (_.strumLine.characters[0].curCharacter == "mtt") {
        _.position.x -= (mtt.x - 100)*FlxMath.lerp(.8, 1, mttCameraNormalizer);
        _.position.y -= (mtt.y - (-380))*FlxMath.lerp(.7, 1, mttCameraNormalizer);
    }
}