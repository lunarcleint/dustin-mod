
//
import flixel.util.FlxSort;
import funkin.editors.charter.Charter;
import openfl.Lib;

public var directionStrums:Array<Strumline> = [playerStrums];
public function applyDirectionStrum(strumline:Strumline) {
    if(!directionStrums.contains(strumline)) {
        for(s in strumline.members)
            s.onDraw = strumDraw;
        directionStrums.push(strumline);
        negMultY -= 1;
        negMultY += 1;
    }
}
public function removeDirectionStrum(strumline:Strumline) {
    if(directionStrums.contains(strumline)) {
        for(s in strumline.members)
            s.onDraw = null;
        directionStrums.remove(strumline);
        if(strumline.onNoteUpdate.has(onNoteDirectionUpdate))
            strumline.onNoteUpdate.remove(onNoteDirectionUpdate);
    }
}

public var onDirectionChangePost:Array<(direc:Bool)-> Void> = [];
public var onDirectionChange:Array<(direc:Bool)-> Void> = [];

public var updateNotes(default, set):Bool = true;
public var changeNoteColors:Bool = true;
function set_updateNotes(value:Bool) {
    updateNotes = value;
    if(!value && negMultY != 1)
        negMultY = negMultY;
    return value;
}


public var strumOffset:FlxPoint = FlxPoint.get();
public var strumOffsetLerp:FlxPoint = FlxPoint.get();
public var strumDraw:FlxSprite->Void = (spr) -> {
    if(spr.camera.alpha > 0 || spr.alpha > 0) {
        spr.y += strumOffsetLerp.y + downscrollOffsetLerp + forcedScrollOffset + shakeValuesPos.y;
        spr.x += strumOffsetLerp.x + shakeValuesPos.x;
        spr.draw();
        spr.y -= strumOffsetLerp.y + downscrollOffsetLerp + forcedScrollOffset + shakeValuesPos.y;
        spr.x -= strumOffsetLerp.x + shakeValuesPos.x;
    }
};

function postCreate() {
    for(strumline in directionStrums) {
        for(s in strumline.members)
            s.onDraw = strumDraw;
    }
}

public var directionalPluey:Float = 0;
public var hudOffY:Float = 0;

var hudX:Float = 283.5;
var desiredHudX:Float = 283.5;
var hudY:Float = 564;
var hudTween:FlxTween;
var monitorTween:FlxTween;
var windowTweenRunning:Bool;

var strumXTween:FlxTween;
var strumYTween:FlxTween;
var negMultTween:FlxTween;
var shakeTween:FlxTween;
var tweeningNotes:Bool = false;
var shakeValues:FlxPoint = FlxPoint.weak(0,0);
var shakeValuesPos:FlxPoint = FlxPoint.weak(0,0);
var shakeValuesTimer:Float = 0;

public var ignoreHUDScroll:Bool = false;

function update(elapsed:Float) {
    shakeValuesTimer += elapsed;
    if (shakeValuesTimer > (1/30)) {
        shakeValuesTimer = 0;
        shakeValuesPos.set(shakeValues.x, shakeValues.y);
    }
    downscrollOffsetLerp = Math.min(0, downscrollOffset * negMultY);

    if(!ignoreHUDScroll) {
        hudX = lerp(hudX, desiredHudX, FlxEase.sineInOut(.2));
        moveHUD(hudX, hudY + hudOffY);
    }
    
    if (directionalPluey != -1 && changeNoteColors) {
        var strumColor:FlxColor = FlxColor.interpolate(0xFFFFFFFF, 0xFF83A2FF, directionalPluey);
        for (i=>strum in strumLines.members[1].members)
            strum.color = strumColor;
        strumLines.members[1].notes.forEach(function (note) {
            note.color = strumColor;
        });
    }

    for(spr in ratingsGroup.members) {
        spr.onDraw = strumDraw;
    }

    if (windowTweenRunning) monitorTween.active = true;
}

var _negMultY:Float;
var _strumOffsetLerpX:Float;
var _strumOffsetLerpY:Float;

function tweenNotes() {
    FlxG.sound.play(Paths.sound('undertale/snd_spearrise'), .3);

    if (negMultY == desiredMultY && strumOffsetLerp.y == strumOffset.y)
        return;
    // canceling tweens are iffy sometimes
    _negMultY = negMultY;
    _strumOffsetLerpX = strumOffsetLerp.x;
    _strumOffsetLerpY = strumOffsetLerp.y;

    for (twn in [strumXTween, strumYTween, negMultTween, shakeTween]) {
        if (twn != null)
            twn.cancel();
    }

    shakeValues.set();

    negMultTween = FlxTween.num(_negMultY, desiredMultY * 0.35, (Conductor.stepCrochet / 1000) * 2.25, {ease: FlxEase.sineIn},
        (val:Float) -> {
            negMultY = val;
        }
    ).then(negMultTween = FlxTween.num(negMultY, desiredMultY, (Conductor.stepCrochet / 1000) * 1.75, {ease: FlxEase.circOut},
        (val:Float) -> {
            negMultY = val;
            if (negMultY == desiredMultY)
                trace('yey');
    }));

    strumXTween = FlxTween.num(_strumOffsetLerpX, strumOffset.x * 0.35, (Conductor.stepCrochet / 1000) * 2.25, {ease: FlxEase.sineIn},
        (val:Float) -> {
            strumOffsetLerp.x = val;
        }
    ).then(strumXTween = FlxTween.num(strumOffsetLerp.x, strumOffset.x, (Conductor.stepCrochet / 1000) * 1.75, {ease: FlxEase.circOut},
        (val:Float) -> {
            strumOffsetLerp.x = val;
    }));

    strumYTween = FlxTween.num(_strumOffsetLerpY, strumOffset.y * 0.35, (Conductor.stepCrochet / 1000) * 2.25, {ease: FlxEase.sineIn},
        (val:Float) -> {
            strumOffsetLerp.y = val;
        }
    ).then(strumYTween = FlxTween.num(strumOffsetLerp.y, strumOffset.y, (Conductor.stepCrochet / 1000) * 1.75, {ease: FlxEase.circOut, onComplete: (_) -> {shakeNotes();}},
        (val:Float) -> {
            strumOffsetLerp.y = val;
    }));
}

function shakeNotes() {
    pluSFX();
    shakeTween = FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.linear},
        (val:Float) -> {
            shakeValues.set(FlxG.random.float(-15,15) * val, FlxG.random.float(-15,15) * val);
        }
    );
}

function onGamePause(e) {
    if (windowTweenRunning) {
        monitorTween.active = false;
        FlxG.stage.window.__backend.move(
            (FlxG.stage.window.displayMode.width - FlxG.stage.window.width) * 0.5,
            (FlxG.stage.window.displayMode.height - FlxG.stage.window.height) * 0.5
        );
    }
}

// i rather have my strums flashed when this mechanic enabled, thanks. -ralty
function flashCamera(camera:FlxCamera) {
    var colorTransform = FlxG.renderBlit ? camera._flashBitmap.transform.__colorTransform : camera.canvas.transform.__colorTransform;
    colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = 255;
    FlxTween.tween(colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 0.5, {ease: FlxEase.auintInOut});
}

public var downscrollOffset:Float = 120;
public var downscrollOffsetLerp:Float = 0;
public var forcedScrollOffset:Float = 0;
public function goDownScroll() {
    if (!FlxG.save.data.mechanics || (PlayState.chartingMode && Charter.startHere && FlxG.sound.music.time < Charter.startTime)) return;
    pluOUT();

    for(fun in onDirectionChange) fun(true);

    desiredHudX = 283.5;
    desiredMultY = -1;

    if (hudTween != null) hudTween.cancelChain();
    if (monitorTween != null) monitorTween.cancelChain();
    strumOffset.set(0,camHUD.height - (strumLines.members[0].members[0].y) - (strumLines.members[0].members[0].height / 2));

    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4.5, ()->{ for(fun in onDirectionChangePost) fun(true); });

    flashCamera(camHUD);

    hudTween = FlxTween.num(hudY, 564+300, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(FlxTween.num(-400, 50, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }));

    tweenNotes();
}

function pluSFX() {
    if (!FlxG.save.data.mechanics) return;
    // camHUD.shake(0.002, 0.3);
    FlxG.sound.play(Paths.sound('undertale/snd_break2'), 1);
    //FlxG.sound.play(Paths.sound('undertale/snd_impact'), .6);
}

var doingPLU:Bool = false;
function pluOUT() {
    if (doingPLU) return;
    doingPLU = true;

    FlxTween.num(0, .9, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {directionalPluey = val;});
    (new FlxTimer()).start((Conductor.stepCrochet / 1000) * 16, function (_) {
        FlxTween.num(.9, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {directionalPluey = val;});
        (new FlxTimer()).start((Conductor.stepCrochet / 1000) * 4, function (_) {
            doingPLU = false;
        });
    });
}

public function goUpScroll() {
    if (!FlxG.save.data.mechanics || (PlayState.chartingMode && Charter.startHere && FlxG.sound.music.time < Charter.startTime)) return;
    pluOUT();

    for(fun in onDirectionChange) fun(false);

    desiredHudX = 283.5;
    desiredMultY = 1;
    if (hudTween != null) hudTween.cancelChain();
    if (monitorTween != null) monitorTween.cancelChain();
    strumOffset.set(0,0);

    tweenNotes();
    
    for(fun in onDirectionChangePost) fun(false);

    flashCamera(camHUD);

    hudTween = FlxTween.num(hudY, -400, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(FlxTween.num(564+300, 564, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
         hudY = val;
    }));
}

function moveHUD(hudx:Float, hudy:Float) {
    dustinHealthBG.x = hudx; dustinHealthBG.y = hudy;
    dustinHealthBar.x = hudx + 46;  dustinHealthBar.y = hudy+(camHUD.downscroll ? 25 : 32);
    timeBarBG.x = hudx + 77; timeBarBG.y = hudy + 74;
    timeBar.x = timeBarBG.x; timeBar.y = timeBarBG.y;
    scoreTxt.x = dustinHealthBG.x + 56; scoreTxt.y = dustinHealthBG.y + 114;
    missesTxt.x = dustinHealthBG.x + 116; missesTxt.y = dustinHealthBG.y + 114;
    accuracyTxt.x = dustinHealthBG.x + 116; accuracyTxt.y = dustinHealthBG.y + 114;
}

public var desiredMultY:Float = 1;
public var negMultY(default, set):Float = 1;
function set_negMultY(value:Float) {
    if(!updateNotes)
        value = 1;
    if(negMultY == value)
        return;
    if(value != 1 && updateNotes) {
        for(strumline in directionStrums) {
            if(!strumline.onNoteUpdate.has(onNoteDirectionUpdate))
                strumline.onNoteUpdate.add(onNoteDirectionUpdate);
        }
    } else {
        for(strumline in directionStrums) {
            if(strumline.onNoteUpdate.has(onNoteDirectionUpdate))
                strumline.onNoteUpdate.remove(onNoteDirectionUpdate);
        }
    }
    return negMultY = value;
}

public function onNoteDirectionUpdate(e:NoteUpdateEvent) {
    e.__reposNote = camHUD.alpha != 0 && negMultY == 1;
    if(camHUD.alpha > 0) {
        if(e.__reposNote)
            return;

        var note:Note = e.note;
        note.strumRelativePos = true;
        var strum:Strum = e.strum;

        strum.updateNotePosition(note);
        updateNoteDirection(e);
    }
}

function fadeSansStrums(salpha:String) {
    if (!FlxG.save.data.mechanics) return;
    var falpha = Std.parseFloat(salpha);
    for (k=>s in strumLines.members[0].members) {
        FlxTween.tween(s, {alpha: falpha}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.circInOut});
    }
}

public function updateNoteDirection(e:NoteUpdateEvent) {
    var note:Note = e.note;
    var strum:Strum = e.strum;
    var speed:Float = strum.getScrollSpeed(note);

    note.x += shakeValuesPos.x;
    note.y += shakeValuesPos.y;
    note.y -= downscrollOffsetLerp;
    note.y = Math.max(0, note.camera.height * (negMultY * -1)) - (note.y * (negMultY * -1)) - Math.max(0, note.height * (negMultY * -1));
    note.y += forcedScrollOffset;
    if (note.isSustainNote) {
        if (note.nextSustain != null) {
            note.scale.y = ((note.sustainLength * 0.45 * speed) / note.frameHeight) * negMultY;
            note.updateHitbox();
            note.scale.y += (note.gapFix / note.frameHeight) * negMultY;
        } else {
            note.scale.y = finalNotesScale * negMultY;
        }
    }
}