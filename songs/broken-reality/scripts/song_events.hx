//
// I promise to polish up this code, or someelse if they wanna - higg


import flixel.addons.effects.FlxTrail;
import flixel.util.FlxGradient;
import funkin.backend.utils.FlxInterpolateColor;
import flixel.text.FlxText.FlxTextBorderStyle;

var papsBODY:Character;

var dadBody:Dynamic = {
    circularMotion: false,
    orbit: {
        time: 0,
        radius: 150
    },
    start: {
        x: 5000,
        y: 5000
    },
    endX: 1000,
    baseY: 300
}

var ogTimeCol = [];
var ogCol1;

var gradient;

var ratio:Float;
var holdCircle:FlxSprite;
var skipText:FunkinText;
var skipColor:FlxInterpolateColor = new FlxInterpolateColor(0xffffffff);
var alphaTween:FlxTween;
var alphaTimer:Float = 0.0;
var holdTime:Float = 0.0;

function onCountdown(countdown) countdown.cancel();

function create() {
    introLength = 2;
    doHealthbarFade = false;
    papsBODY = new Character(0, 0, 'phantom_paps_br_body');
    papsBODY.scrollFactor.set(1, 1);
    papsBODY.x = dad.x - 50;
    papsBODY.y = dad.y + 0;
    papsBODY.scale.set(1.3, 1.3);

    insert(members.indexOf(dad), papsBODY);
    papsBODY.visible = false;

    camMoveOffset = 22;
    autoTitleCard = false;

    gradient = FlxGradient.createGradientFlxSprite(1, 520, [0x00000000,0xA0510F0F, 0xA0510F0F, 0xC4650E0E,0xA9FF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000],1,-90,true);
    gradient.scale.x = FlxG.width; gradient.updateHitbox();
    gradient.scale.x = 9000;
    gradient.scale.y = 8;
    gradient.angle = 0;
    gradient.flipY = true;
    gradient.updateHitbox();
    gradient.x = dad.x-4900; gradient.y = dad.y-1000;
    gradient.blend = 0; gradient.color = 0xFF7A0B0B;
    gradient.alpha = 0;

    insert(members.indexOf(stage.stageSprites["light"]), gradient);
    add(gradient);
}

function postCreate() {
    ogTimeCol = timeBarColors;
    ogCol1 = healthBarColors[0];

    add(skipText = textCrispy(new FunkinText(-28, FlxG.height - 50 - 6, FlxG.width, "Hold SPACE/LEFT CLICK to skip...").setFormat(Paths.font('8bit-jve.ttf'), 32, 0xffffffff, "right", FlxTextBorderStyle.OUTLINE, 0xff000000)));
    skipText.scrollFactor.set();
    skipText.borderSize = 3;
    skipText.cameras = [videoCam];
    skipText.visible = false;

    add(holdCircle = new FlxSprite());
    holdCircle.frames = Paths.getFrames(Paths.image("menus/holdCircle"), true);
    holdCircle.animation.addByPrefix("idle", "hold", ratio = ((holdCircle.frames.frames.length - 1) / 2), false);
    holdCircle.animation.frameIndex = 0;
    holdCircle.setGraphicSize(33 * (FlxG.width / 1280), 33 * (FlxG.width / 1280));
    holdCircle.updateHitbox();
    holdCircle.setPosition(FlxG.width - holdCircle.width - skipText.textField.textWidth - 40 - 8, FlxG.height - holdCircle.height - 10 - 10);
    holdCircle.cameras = [videoCam];
    holdCircle.visible = false;

    ratio /= 360;  // before i forger  - Nex
}

function doAlphaTween() {
    alphaTween?.cancel();
    alphaTween = FlxTween.tween(skipText, {alpha: 0}, 0.5);
}

var lock24FPS:Array<{sprite:FlxSprite, x:Float, y:Float, anim:String}> = [];
var dad24FPS:{x:Float, y:Float, anim:String} = null;
var head24FPS:{x:Float, y:Float, anim:String} = null;
public var __coolTimer:Float = 0;

var canSkip:Bool = false;
function skipCutscene() {
    if(inst.time < 32901) {
        vocals.pause(); inst.pause();
        curVideo?.bitmap?.time = inst.time = vocals.time = 32901;
        vocals.resume(); inst.resume();
    }
    canSkip = false;
}

function onSongStart() {
    canSkip = true;
}
function onEvent(_) {
    var params:Array = _.event.params;
    if (_.event.name == "Video Cutscene") {
        if (_.event.time == 0) {
            for (spr in [skipText, holdCircle]) {
                spr.visible = true;
            }
        }
    }
}

function update(elapsed:Float) {
    canSkip = inst.time < 32901;
    if(canSkip && holdCircle.visible) {
        remove(holdCircle, true);
        insert(9999, holdCircle);
        remove(skipText, true);
        insert(9999, skipText);
        if (!FlxG.mouse.pressed && !FlxG.keys.pressed.SPACE) {  // i cant use accept cuz we dont have acept_hold, only in dev still sob  - Nex
            holdTime = 0;
            holdCircle.animation.stop();
            holdCircle.animation.frameIndex = 0;

            skipColor.color = 0xffffffff;

            if (alphaTimer > 1) doAlphaTween();
            else alphaTimer += elapsed;
        } else if (curVideo != null) {
            alphaTween?.cancel();
            skipText.alpha = 1;
            alphaTimer = 0;
            holdCircle.animation.play("idle", false, false, 1);

            skipText.color = skipColor.fpsLerpTo(0xffff0000, ratio);

            if ((holdTime += elapsed) > 2)
                skipCutscene();
        }
        holdCircle.color = skipText.color = skipColor.color;
        holdCircle.alpha = skipText.alpha;
    } else if (!canSkip && holdCircle != null && holdCircle.visible) {
        titleCard.visible = false;

        holdCircle.destroy();
        skipText.destroy();

        holdCircle = null;
        skipText = null;
    }

    __coolTimer += elapsed;

    updateBody(elapsed);

    if ((curStep >= 1664 && curStep <= 3308) && curCameraTarget == 0) {
        camAngleOffset = .6;
    } else {
        camAngleOffset = .3;
    }
}

function updateBody(elapsed:Float) {
    for (info in lock24FPS) {
        var sprite = info.sprite;
        if (sprite.animation.frameName != info.anim) {
            sprite.x = info.x; sprite.y = info.y;
            if (info.angle != null) sprite.angle = info.angle;
            info.anim = sprite.animation.frameName;
        }
    }

    if (dad24FPS != null) {
        var waveSpeed = __coolTimer * 3;
        var bobX = Math.sin(waveSpeed) * 50;
        var bobY = Math.cos(waveSpeed * 0.8) * 40 + Math.sin(waveSpeed * 1.5) * 10;

        dad24FPS.x = dadBody.start.x + bobX - (dadBody.circularMotion ? 50 : 0);
        dad24FPS.y = dadBody.start.y + bobY;
    }

    if (head24FPS != null) {
        dadBody.orbit.time += elapsed * 1.5;

        var orbitSpeed = dadBody.orbit.time * 1.7;
        var t = (Math.sin(orbitSpeed*.8) * 0.5) + .5;
        t += Math.sin(orbitSpeed * 0.5) * 0.15;
        t += Math.cos(orbitSpeed * 1.7) * 0.1;

        var easedT = Math.sin(t * Math.PI * 0.5);

        var mainArc = Math.sin(t * Math.PI) * -dadBody.orbit.radius * 1.6;
        var tilt = Math.cos(orbitSpeed * 1.2) * 25;
        var sway = Math.sin(orbitSpeed * 3.5) * 15;
        var pulse = Math.sin(orbitSpeed * 0.5) * 10;

        head24FPS.x = FlxMath.lerp(dadBody.start.x, dadBody.endX, easedT) + tilt + pulse;
        head24FPS.y = dadBody.baseY + mainArc + sway + pulse + tilt;

        // var papSpin = Math.sin(orbitSpeed/4) * 360;
        // papSpin += Math.sin(orbitSpeed * 0.3) * 90;
        // papSpin += Math.sin(orbitSpeed * .3) * 30;
        // papSpin += Math.cos(dadBody.orbit.time) * 45;

        // head24FPS.angle = papSpin;
    }

    //gradient.angle = -80 + -Math.abs(10 * Math.sin(__coolTimer*.5));
    for (paptrail in papsTrails) {
        for (i => trail in paptrail.members) {
            var scale = FlxMath.bound(1.3 + .2 + (.2 * FlxMath.fastSin(__coolTimer + (i * FlxG.random.float((Conductor.stepCrochet / 1000) * 0.5, (Conductor.stepCrochet / 1000) * 1.2)))), 0.9, 999);
            trail.scale.set(scale, scale);

            if (dadBody.circularMotion) 
                trail.centerOrigin();
        }
    }

    if (dadBody.circularMotion) {
        dad.centerOrigin();
    }
}

function stepHit(step:Int) {

    switch(step) {
        case 176:
            showTitleCard();
        case 436:
            camZoomLerpMult = .65;
        case 849:
            createDadClone(dadPos, 1.15);
        case 1664:
            lightShader.bright = .2;
            dust.BRIGHT = 0;

            dadClone.visible = false;

            remove(dad);
            insert(members.indexOf(stage.stageSprites["fg"]), dad);

            dustiniconP1.loadGraphicFromSprite(createHealthIcon(boyfriend.getIcon() + "-red", true));
            dustiniconP1.updateHitbox();
            updateIconXml(dustiniconP1, boyfriend.getIcon() + "-red");

            changeColors(-1,0,0,-1);
            ogHealthColors[0] = healthBarColors[0] = archivedHealthColors[0];

            dadBody.start.x = dad.x;
            dadBody.start.y = dad.y;

            dad24FPS = {sprite: dad, x: dadBody.start.x, y: dadBody.start.y, anim: dad.animation.frameName};
            lock24FPS.push(dad24FPS);
            spawnPapsTrail(dad);

            controlDad = false;
            timeBarColors = [0xFFFF0000, 0xFF000000];
        case 2669:
            papsBODY.visible = true;

            dadBody.circularMotion = true;
            dad.x = dadBody.start.x;
            dad.y = dadBody.baseY;
            dadBody.orbit.time = 0;

            lock24FPS = [];

            dad24FPS = {sprite: papsBODY, x: dadBody.start.x, y: dadBody.start.y, anim: papsBODY.animation.frameName};
            lock24FPS.push(dad24FPS);
            dad24FPS = lock24FPS[papsBODY];

            head24FPS = {sprite: dad, x: dadBody.start.x, y: dadBody.start.y, angle: 0, anim: dad.animation.frameName};
            lock24FPS.push(head24FPS);

            clearTrails();

            spawnPapsTrail(dad);
            spawnPapsTrail(papsBODY);
        case 3005:
            papsBODY.visible = false;
            dadBody.circularMotion = false;

            lock24FPS = [];
            
            clearTrails();
            spawnPapsTrail(dad);

            dad24FPS = {sprite: dad, x: dadBody.start.x, y: dadBody.start.y, anim: dad.animation.frameName};
            lock24FPS.push(dad24FPS);
            FlxTween.tween(dad, {x: dadBody.start.x, y: dadBody.start.y}, 1, {ease: FlxEase.quadInOut});

        case 3311:
            lock24FPS = [];
            clearTrails();

            controlDad = true;

            lightShader.lightcol = [255., 241., 255.];
            lightShader.bright = 1;
            dust.BRIGHT = 10;

            remove(dad);
            insert(members.indexOf(stage.stageSprites["fg"]), dad);

            resetColors();

            healthBarColors[1] = ogHealthColors[1];
            dustiniconP1.loadGraphicFromSprite(createHealthIcon(boyfriend.getIcon(), true));
            dustiniconP1.updateHitbox();
            updateIconXml(dustiniconP1, boyfriend.getIcon());

            bfPos = null;
            createBFClone(bfPos2, 1.25);
            dadClone.visible = true;

            timeBarColors = ogTimeCol;
        case 3330:
            createDadClone(dadPos, 1.15);
        case 4064:
            bfClone.visible = false;
            healthBarColors[0] = 0x00000000;
            dustiniconP1.onDraw = (spr) -> {
                spr.x += spr.width / 2;
                spr.draw();
                spr.x -= spr.width / 2;
            }
            dustiniconP2.alpha = 0;
            dust.BRIGHT = 0;
            for (name => sprite in stage.stageSprites) 
                sprite.visible = false;

            camMoveOffset = 0;
            camAngleOffset = 0;
        case 4672:
            bfClone.visible = true;
            dustiniconP1.onDraw = null;
            healthBarColors[0] = ogCol1;
            dustiniconP2.alpha = 1;
            dustiniconP2.visible = true;
            dust.BRIGHT = 10;
            for (name => sprite in stage.stageSprites) 
                sprite.visible = true;

            camMoveOffset = 5;
            camAngleOffset = .3;
        case 4052:
            strumLines.members[0].characters[0].alpha = 0;
        case 4320:
            FlxTween.tween(strumLines.members[0].characters[0], {alpha: 1}, 5, {ease: FlxEase.quadInOut});
        case 976 | 1320 | 4834 | 5186:
            spawnPapsTrail(strumLines.members[3].characters[0], .2);
            FlxTween.tween(strumLines.members[3].characters[0], {alpha: .56}, 2, {ease: FlxEase.quadInOut});

            FlxTween.tween(gradient, {alpha: .27}, 2,  {ease: FlxEase.quadOut});
        case 1104 | 1360 | 4928:
            clearTrails();
            FlxTween.tween(strumLines.members[3].characters[0], {alpha: 0}, .5, {ease: FlxEase.quadInOut});

            FlxTween.tween(gradient, {alpha: 0}, 1.3,  {ease: FlxEase.quadIn});

    }
}

function createClones() {
    createDadClone(dadPos, 1);
    createBFClone(bfPos2, 1.25);
}

function onDadHit(note:Note):Void {
    if (papsBODY != null && papsBODY.visible == true) {
        var dirNames = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
        var animName = 'sing' + dirNames[note.direction];
        papsBODY.playAnim(animName, true);
    }
}

public var papCameraNormalizer:Float = .1;
function onCameraMove(_) {
    // normalize mtt movement a bit
    if (_.strumLine.characters[0].curCharacter == "phantom_paps_br") {
        _.position.x -= (dad.x - dadBody.start.x)*FlxMath.lerp(.8, 1, papCameraNormalizer);
        _.position.y -= (dad.y - dadBody.start.y)*FlxMath.lerp(.7, 1, papCameraNormalizer);
    }
}

var papsTrails:Array<FlxTrail> = [];
function spawnPapsTrail(sprite:FlxSprite, alpha:Float = 0.3) {
    trail = new FlxTrail(sprite, null, 32, 11, 0.3, 0.045);
    trail.color = 0xFFFFFFFF;
    insert(members.indexOf(sprite), trail);
    papsTrails.push(trail);
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

function bloom_flash() {
    bloom_new.brightness = 2; bloom_new.size = 30;

    FlxTween.num(2, 1.78, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
    FlxTween.num(22, 20, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});

    executeEvent({name: "Bloom Effect", time: 0, params: [false, 1.25, 4, "linear", "In"]});
    executeEvent({name: "Bloom Effect", time: 0, params: [true, 1, 8, "quad", "Out"]});
}

var imageCine:Int = 0;
function cineHit() {
    imageCine++;
    stage.stageSprites['cine' + Std.string(imageCine)].alpha = 1;
    stage.stageSprites['cine' + Std.string(imageCine)].y += 17;
    FlxG.camera.zoom += 0.12;
    camHUD.zoom += 0.06;
    FlxTween.tween(stage.stageSprites['cine' + Std.string(imageCine)], {alpha: 0, "scale.x": .9, "scale.y": .9, y: stage.stageSprites['cine' + Std.string(imageCine)].y-17}, (Conductor.stepCrochet / 1000) * 10, {ease: FlxEase.quadOut});
}