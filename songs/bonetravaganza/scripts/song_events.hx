//

import funkin.backend.utils.FlxInterpolateColor;
import flixel.text.FlxText.FlxTextBorderStyle;

var bouncingTween:FlxTween;
var heart:FlxSprite;
var strumShiftAmount:Float = -320;
var strumsShifted:Bool = false;

introLength = 1;

var ratio:Float;
var holdCircle:FlxSprite;
var skipText:FunkinText;
var skipColor:FlxInterpolateColor = new FlxInterpolateColor(0xffffffff);
var alphaTween:FlxTween;
var alphaTimer:Float = 0.0;
var holdTime:Float = 0.0;

function onCountdown(_) {
    if (startingSong) _.cancel();
}

function postCreate() {
    heart = new FunkinSprite().loadGraphic(Paths.image("game/monster_heart"));
    heart.scale.set(0.1, 0.1);
    heart.updateHitbox();
    heart.antialiasing = false;
    add(heart);

    heart.x = 2000; heart.y = 1200;
    heart.alpha = 0;

    autoTitleCard = false;

    stage.getSprite("guitar_background").visible = false;
    stage.getSprite("guitar_foreground").visible = false;
    stage.getSprite("ghosts").visible = false;

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    skipText = textCrispy(new FunkinText(-28, FlxG.height - 50 - 6, FlxG.width, "Hold SPACE/LEFT CLICK to skip...").setFormat(Paths.font('8bit-jve.ttf'), 32, 0xffffffff, "right", FlxTextBorderStyle.OUTLINE, 0xff000000));
    skipText.scrollFactor.set();
    skipText.scrollFactor.set();
    skipText.borderSize = 3;

    holdCircle = new FlxSprite();
    holdCircle.scrollFactor.set();
    holdCircle.frames = Paths.getFrames(Paths.image("menus/holdCircle"), true);
    holdCircle.animation.addByPrefix("idle", "hold", ratio = ((holdCircle.frames.frames.length - 1) / 2), false);
    holdCircle.animation.frameIndex = 0;
    holdCircle.setGraphicSize(33 * (FlxG.width / 1280), 33 * (FlxG.width / 1280));
    holdCircle.updateHitbox();
    holdCircle.setPosition(FlxG.width - holdCircle.width - skipText.textField.textWidth - 40 - 8, FlxG.height - holdCircle.height - 10 - 10);

    for (spr in [skipText, holdCircle]) {
        insert(9999, spr);
        spr.cameras = [camHUD2];
    }

    ratio /= 360;  // before i forger  - Nex


}
function doAlphaTween() {
    alphaTween?.cancel();
    alphaTween = FlxTween.tween(skipText, {alpha: 0}, 0.5);
}

var canSkip:Bool = true;
function skipCutscene() {
    if(inst.time < 25600) {
        vocals.pause(); inst.pause();
        inst.time = vocals.time = 25600;
        vocals.resume(); inst.resume();
    }
    canSkip = false;
}


function onEvent(_) {
    var params:Array = _.event.params;
    if (_.event.name == "Video Cutscene") {
        if (_.event.time == 0) {
            for (spr in [skipText, holdCircle]) {
                spr.cameras = [videoCam];
            }
        }
    }
}

function update(elapsed:Float) {
    canSkip = inst.time < 25601;
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
        } else if (inst.time < 25601) {
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
        holdCircle.destroy();
        skipText.destroy();

        holdCircle = null;
        skipText = null;
    } else if (!canSkip && inst.time > 25600 && curVideo != null && curVideo == preloadedVideos.get("intro_b") && curVideo.bitmap.time < 25600 - 8697) {
        curVideo.bitmap.time = 25600 - 8697;
    }
}


function stepHit(step:Int) {
    switch (step) {
        case 144: countdown(0);
        case 148: countdown(1);
        case 152: countdown(2);
        case 156: countdown(3);
        case 292:
            showTitleCard();
        case 1404:
            strumLines.members[2].characters[0].visible = true;
            bg_char.y =  bg_char.y + 600;
            dad.x = dad.x + 200;
            dad.y = dad.y - 50;
        case 1422:
            FlxTween.tween(bg_char, {y: bg_char.y - 600}, 0.7, {
                ease: FlxEase.quadOut,
                onComplete: function(twn:FlxTween) {
                    startBouncing();
                }
            });
        case 1472:
            if (bouncingTween != null) {
                bouncingTween.cancel();
                bouncingTween = null;
            }
        case 1896:
            FlxTween.tween(dad, {x: dad.x + 550}, 0.7, {ease: FlxEase.quintInOut});
            FlxTween.tween(dad, {y: dad.y + 30}, 0.7, {ease: FlxEase.quintInOut});
        case 1960:
            FlxTween.tween(dad, {x: dad.x - 550}, 0.7, {ease: FlxEase.quintInOut});
            FlxTween.tween(dad, {y: dad.y - 30}, 0.7, {ease: FlxEase.quintInOut});
        case 2408:
            strumLines.members[3].characters[0].visible = true;
        case 2416:
            FlxTween.tween(heart, { y: 700, alpha: 1 }, 3, { ease: FlxEase.quadOut });
        case 2436:
            heart.visible = false;
            FlxG.camera.shake(0.05, 0.3);


        case 2992:
            shiftStrums();

        case 3104:
            FlxTween.tween(scoreTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(accuracyTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(missesTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});

            for (strum in playerStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: 1}, 1, {ease: FlxEase.quadOut});

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    FlxTween.tween(note, {alpha: 1}, 1, {ease: FlxEase.quadOut});
        case 3112:
            if ((FlxG.save.data.strumOverlay / 100) < 0.25)
                strumOverlay.alpha = 0.25;
            stage.getSprite("guitar_background").visible = true;
            stage.getSprite("guitar_foreground").visible = true;

            stage.getSprite("room").visible = false;
            stage.getSprite("tenna").visible = false;
            stage.getSprite("lights").visible = false;
            stage.getSprite("bg_char").visible = false;
            dad.visible = false;
            strumLines.members[3].characters[0].visible = false;
            strumLines.members[2].characters[0].visible = false;
            strumLines.members[4].characters[0].visible = false;
        case 3124:
            FlxG.camera.shake(0.04, 0.3);
        case 3252:
            FlxG.camera.shake(0.02, 0.2);
            stage.getSprite("ghosts").visible = true;
        case 3412:
            if ((FlxG.save.data.strumOverlay / 100) != strumOverlay.alpha)
                FlxTween.tween(strumOverlay, {alpha: (FlxG.save.data.strumOverlay / 100)}, 0.6, {ease: FlxEase.quadOut});
    }
}

function startBouncing() {
    bouncingTween = FlxTween.tween(bg_char, {y: bg_char.y + 100}, 0.5, {
        type: FlxTween.PINGPONG,
        ease: FlxEase.sineInOut,
        looped: true
    });
}

function shiftStrums():Void {
    var shift = strumsShifted ? -strumShiftAmount : strumShiftAmount;
    var tweenTime = 0.5;
    var tweensLeft = 0;


    for (strumLine in strumLines) {
        for (sprite in strumLine.members) {
            if (sprite != null) {
                tweensLeft++;
                FlxTween.tween(sprite, {x: sprite.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }

        for (note in strumLine.notes) {
            if (note != null) {
                tweensLeft++;
                FlxTween.tween(note, {x: note.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }
    }

    strumsShifted = !strumsShifted;
}