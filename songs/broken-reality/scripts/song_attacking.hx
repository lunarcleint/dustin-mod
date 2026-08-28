//
import funkin.editors.charter.Charter;
import funkin.backend.system.framerate.Framerate;

import flixel.text.FlxTextBorderStyle;
import flixel.effects.FlxFlicker;

var target_flip:Int = -1;
var target:FlxSprite;
var target_choice:FlxSprite;
var target_text:FlxText;
var assFramerate:Bool;

public var flickerSprite:FlxSprite;
public var warp:CustomShader;
public var chromWarp:CustomShader;
public var impact:CustomShader;

function postCreate() {
    hurtColor = 0xFFFF0000;
    if (Options.gameplayShaders) dustiniconP1.shader.color = [1., 0., 0.];

    target = new FunkinSprite().loadGraphic(Paths.image("game/undertale/spr_target"));
    target.cameras = [camHUD];
    target.scale.x = 0;
    target.alpha = 0;
	target.updateHitbox();
	target.antialiasing = false;
    insert(9999, target);

    target_choice = new FlxSprite();
    target_choice.frames = Paths.getSparrowAtlas("game/undertale/spr_targetchoice");
    target_choice.animation.addByPrefix("spr_targetchoice", "spr_targetchoice", 8, true);
    // target_choice.animation.play("spr_targetchoice");
    target_choice.cameras = [camHUD];
    target_choice.scale.set(.9, .9);
    target_choice.animation.frameIndex = 0;
	target_choice.updateHitbox();
	target_choice.antialiasing = false;
    target_choice.visible = false;
    insert(9999, target_choice);

    target_text = textCrispy(new FlxText(0, 0, 0, "PRESS SPACE!"));
    target_text.setFormat(Paths.font("DTM-Mono.ttf"), 16, fullColor);

    target_text.borderStyle = FlxTextBorderStyle.OUTLINE;
    target_text.borderSize = 2;
    target_text.borderColor = 0xFF000000;

    target_text.alpha = 0;
    target_text.cameras = [camHUD];
    insert(9999, target_text);

    flickerSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
    flickerSprite.scrollFactor.set(0, 0);
    flickerSprite.zoomFactor = 0;
    flickerSprite.cameras = [camHUD2];
    flickerSprite.alpha = 0;
    if(!FlxG.save.data.antiFlash)
        add(flickerSprite);

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = 0;

    warp = new CustomShader("warp");
    warp.distortion = 0;

    impact = new CustomShader("impact_frames");
    impact.threshold = -1;

    if (Options.gameplayShaders) {
        if (FlxG.save.data.impact) camGame.addShader(impact);
        if (FlxG.save.data.warp) camGame.addShader(warp);
        if (FlxG.save.data.chromwarp) camGame.addShader(chromWarp);
        if (FlxG.save.data.bloom) {
            camGame.removeShader(bloom_new);
            camGame.addShader(bloom_new);
        }
    }

    FlxFlicker.flicker(flickerSprite, 9999999, 0.01);

    if (!FlxG.save.data.scrollSpeedChange) {
        PlayState.instance.scrollSpeed = 3.2;
    }
}

public var didDamage:Bool = false;

var desiredScale:Float = 0;
var tY:Float = 15;
var desiredY:Float = 15;
var targetDesiredX:Float = 0;
var inAttack:Bool = false;
function doAttack() {
    if (inAttack || (PlayState.chartingMode && Charter.startHere && FlxG.sound.music.time < Charter.startTime)) return;
    inAttack = true;
    attackerSpeed = FlxG.random.float(0.98, 1.25);
    target_flip *= -1;
    targetDesiredX = -.5;
    judgeRating = JUDGE_MISS;

    target_choice.visible = false;
    target_choice.animation.stop();
    target_choice.animation.frameIndex = 0;
    target_choice.ID = -1;
    target_choice.alpha = 1;

    target_text.text = "PRESS SPACE!";
    target_text.color = 0xFFFFFFFF;

    desiredScale = 1; desiredY = 0;

    FlxG.sound.play(Paths.sound("undertale/snd_b"), .3, false, null, true);

    (new FlxTimer()).start(0.4, function (_) {
        target_choice.visible = true;
    });
    boyfriend.playAnim("attack_prep", true);

    stealCamera = true;

    FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (v:Float) -> {
        for (obj in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2]) obj.alpha = v;
    });

    camGame.followLerp = .06;

    FlxG.camera.shake(0.0012, 999999);
    boyfriend.health = -1;
}

function endAttack() {
    inAttack = false;

    desiredScale = 0; desiredY = 15;
    target_choice.ID = -1;
    target_choice.visible = false;

    stealCamera = false;
    camGame.followLerp = .04;

    FlxTween.num(0, 1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut}, (v:Float) -> {
        for (obj in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2]) obj.alpha = v;
    });
    FlxG.camera.stopFX();

    flickerSprite.alpha = 0; 
    chromWarp.distortion = 0; warp.distortion = 0;
    lightShader.bright = 1; dust.BRIGHT = 10; impact.threshold = -1;

    for (cam in FlxG.cameras.list) cam.visible = true;
    boyfriend.x = 1400; boyfriend.y = 2630;
    camOffX = -90; camOffY = 213;

    boyfriend.health = 1; // free him
}

var JUDGE_MISS:Int = -1;
var JUDGE_RED:Int = 0;
var JUDGE_YELLOW:Int = 1;
var JUDGE_GREEN:Int = 2;

var judgeRating = JUDGE_MISS;
var GREEN_FRAC:Float = 0.0547;
var YELLOW_FRAC:Float = 0.1898;
var RED_FRAC:Float = 0.3942;

/*
after calculations.. running commands, testing...
this fuckass immutable bug should die now
ive been on this shit for like A WHILE now this SHOULD WORK
AND IF IT DOESNT IM CRASHING THE FUCK OUT
- HeroEyad
*/
function judgeInput():Int {
    var d = Math.abs((target_choice.x + target_choice.width/2) - (target.x + target.width/2));
    var w = target.frameWidth * target.scale.x;

    if (d <= w * GREEN_FRAC) return JUDGE_GREEN;
    if (d <= w * YELLOW_FRAC) return JUDGE_YELLOW;
    if (d <= w * RED_FRAC) return JUDGE_RED;
    return JUDGE_MISS;
}

function judgeHealth():Float {
    if (!FlxG.save.data.mechanics) return;
    return switch (judgeRating) {
        case JUDGE_GREEN: health += .63 * Math.max(1, drainAmount*.47);
        case JUDGE_YELLOW: health += .45 * Math.max(1, drainAmount*.47);
        case JUDGE_RED: health += .24 * Math.max(1, drainAmount*.47);
        default: 
    }
}

var DISAPPEAR_FRAMES = 26;
var zoomTimes:Float = 1;
var zoomSpeeds:Float = 1;

public var controlDad:Bool = true;
var desiredDadX:Float = 5170;
var desiredDadY:Float = 2700;
function undertale_update(elapsed:Float) {
    if (target_choice.visible && target_choice.ID == -1) {
        var judgement:Int = judgeInput();
        target_text.color = switch (judgement) {
            case JUDGE_GREEN: 0xFFA8FFA8;
            case JUDGE_YELLOW: 0xFFFFFFAE;
            case JUDGE_RED: 0xFFFFC7C7;
            case JUDGE_MISS: 0xFFFFE6E6;
        };

        targetDesiredX += attackerSpeed * elapsed;
        if (justPressedZ && judgement != JUDGE_MISS) {
            didDamage = true;
            DISAPPEAR_FRAMES = 50;

            target_choice.animation.play("spr_targetchoice", true);
            target_choice.ID++;

            FlxG.sound.play(Paths.sound("undertale/snd_laz"), 1, false, null, true);
            judgeRating = judgement;
            judgeHealth();

            target_text.text = switch (judgement) {
                case JUDGE_GREEN: "PERFECT!";
                case JUDGE_YELLOW: "GOOD!";
                case JUDGE_RED: "BAD...";
                case JUDGE_MISS: "MISS...";
            };

            (new FlxTimer()).start(.2, (_) -> {
                boyfriend.playAnim("attack", true);
            });
            FlxG.camera.shake(0.0024, 999999);
        } else if (targetDesiredX >= .5) {
            DISAPPEAR_FRAMES = 16;
            target_choice.ID++;

            boyfriend.playAnim("attack_back", true);
            target_text.text = "MISS...";
            target_text.color = 0xFFFF0000;

            target_choice.alpha = 0.00001;
            FlxG.camera.stopFX();
        }
    } else if (target_choice.visible) {
        target_choice.ID++;
        if (target_choice.ID > DISAPPEAR_FRAMES)
            endAttack();
    }

    if (controlDad) {
        dad.x = FlxMath.lerp(dad.x, desiredDadX, FlxEase.sineIn(.46));
        dad.y = FlxMath.lerp(dad.y, desiredDadY, FlxEase.sineIn(.46));
    }
    
    target.scale.x = FlxMath.lerp(target.scale.x, desiredScale, FlxEase.sineIn(.42));
    target.alpha = FlxMath.lerp(target.alpha, desiredScale, FlxEase.sineIn(.42));
    target_text.alpha = target.alpha;

    target.x = FlxG.width/2 - target.width/2;
    target.y = dustinHealthBar.y - 89.5 + (tY = FlxMath.lerp(tY, desiredY, FlxEase.sineIn(.42)));

    target_choice.x = target.x + (target.frameWidth*(targetDesiredX * target_flip)) - target_choice.width/2;
    target_choice.y = target.y;

    target_text.x = target.x - target_text.fieldWidth/2;
    target_text.y = target.y - 20;

    forceDefaultCamZoom = stealCamera;
    camZoomLerpMult = stealCamera ? .3 * zoomSpeeds : 1;

    defaultCamZoom = stealCamera ? .575 * zoomTimes : .525;

    hudOffY = 30 * Math.abs(Math.min(0, negMultY)) * target.alpha;
}

var undertaleFrameTime:Float = 1/30;
var undertaleFrameCounter:Float = 0;

var justPressedZ:Bool = false; // store outside of 30 fps update for obv reasons

var frameNum:Int = 0;
function update(elapsed:Float) {
    if (!justPressedZ && FlxG.keys.justPressed.SPACE) justPressedZ = true;

    if (assFramerate != (assFramerate = Framerate.fpsCounter.lastFPS < 30))
        flickerSprite.cameras = [assFramerate ? camGame : camHUD2];

    undertaleFrameCounter += elapsed;
    if (assFramerate || (undertaleFrameCounter > undertaleFrameTime)) {
        undertale_update(undertaleFrameCounter);
        undertaleFrameCounter = 0;

        justPressedZ = false;
    }

    if (boyfriend.animation.name == "attack" && frameNum != boyfriend.animation.frameIndex && inAttack) {
        frameNum = boyfriend.animation.frameIndex;
        if (boyfriend.animation.frameIndex == 94 || boyfriend.animation.frameIndex == 98 || boyfriend.animation.frameIndex == 127) {
            for (cam in FlxG.cameras.list) cam.visible = false;
        }
        if (boyfriend.animation.frameIndex == 95 || boyfriend.animation.frameIndex == 99 || boyfriend.animation.frameIndex == 128) {
            for (cam in FlxG.cameras.list) cam.visible = true;
            chromWarp.distortion = .1;
            lightShader.bright = 0; dust.BRIGHT = 0; impact.threshold = .4;
        }
        if (boyfriend.animation.frameIndex == 96 || boyfriend.animation.frameIndex == 101 || boyfriend.animation.frameIndex == 129) {
            chromWarp.distortion = 0; warp.distortion = 0;
            lightShader.bright = 1; dust.BRIGHT = 10; impact.threshold = -1;
        }

        if (boyfriend.animation.frameIndex == 95 || boyfriend.animation.frameIndex == 96) {
            flickerSprite.alpha = 0.3;
            FlxG.sound.play(Paths.sound("undertale/snd_noise"), .3, false, null, true, 1.3);
        }
        if (boyfriend.animation.frameIndex == 97) {
            flickerSprite.alpha = 0;
            camOffX = 3260; camOffY = -140;
            camGame.followLerp = 1;
            zoomTimes = .7; zoomSpeeds = 6;
            FlxG.sound.play(Paths.sound("undertale/snd_laz_c"), .9, false, null, true);
        }
        if (boyfriend.animation.frameIndex == 99) { // teleport to sans
            FlxG.sound.play(Paths.sound("undertale/snd_noise"), .5, false, null, true);
            boyfriend.x = 4060; boyfriend.y = 2300;
        }

        if (boyfriend.animation.frameIndex == 103) {
            desiredDadX = 5170 + 200; desiredDadY = 2700 + 70; 
        }
        if (boyfriend.animation.frameIndex == 107) {
            warp.distortion = 4;
            camGame.zoom += 0.35;
            chromWarp.distortion = .3;
            warp.distortion = .2;
            FlxG.sound.play(Paths.sound("undertale/snd_damage_c"), .5, false, null, true);
            FlxG.sound.play(Paths.sound("undertale/snd_break2"), .8, false, null, true);
            FlxG.camera.shake(0.08, .3);
        }
        if (boyfriend.animation.frameIndex == 110) {
            chromWarp.distortion = .1;
            warp.distortion = .1;
        }
        if (boyfriend.animation.frameIndex == 125) {
            flickerSprite.alpha = 0.3;
            camOffX = 3000;
        }
        if (boyfriend.animation.frameIndex == 127) {
            FlxG.sound.play(Paths.sound("undertale/snd_noise"), .3, false, null, true, 1.3);
        }
        if (boyfriend.animation.frameIndex == 128) { // teleport back
            desiredDadX = 5170; desiredDadY = 2700; 

            flickerSprite.alpha = 0;
            FlxG.sound.play(Paths.sound("undertale/snd_noise"), .3, false, null, true, 1.3);
            boyfriend.x = 1400; boyfriend.y = 2630;
            stealCamera = false;
            camOffX = -90; camOffY = 213;
            camGame.followLerp = .17;
            zoomTimes = 1;
            chromWarp.distortion = 0;
            warp.distortion = 0;
        }
        if (boyfriend.animation.frameIndex == 140)
            camGame.followLerp = .04;
    }
}

var stealCamera:Bool = false;
var camX:Float = 1828;
var camY:Float = 3061;
var camOffX:Float = -90;
var camOffY:Float = 213;
function onCameraMove(e) {
    if (stealCamera) {
        e.position.x = camX + camOffX;
        e.position.y = camY + camOffY;
    }
}

var attackerSpeed:Float = 1;
function changeAttackerSpeed(salpha:String) {
    var falpha = Std.parseFloat(salpha);
    attackerSpeed = falpha;
}

function onSongEnd() {
    if (PlayState.isStoryMode) {
        if (didDamage) PlayState.storyPlaylist.remove("you-are");
        else PlayState.storyPlaylist.remove("the-uprising");
    }
}
