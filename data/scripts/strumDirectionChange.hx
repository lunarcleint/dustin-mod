//


continue;

import flixel.math.FlxPoint;

public var onDirectionChangePost:Array<(direc:Bool)-> Void> = [];
public var onDirectionChange:Array<(direc:Bool)-> Void> = [];

public var updateNotes(default, set):Bool = true;
function set_updateNotes(value:Bool) {
    return updateNotes = value;
}

var arrowSine:Bool = false;

public var soundMultiplier:Float = 1;

var strumOffset:FlxPoint = FlxPoint.get();
public var strumOffsetLerp:FlxPoint = FlxPoint.get();

function postCreate() {
    for (i=>strum in strumLines.members) {
        for(s in strum.members) {
            s.onDraw = (spr) -> {
                spr.y += strumOffsetLerp.y;
                spr.x += strumOffsetLerp.x;
                spr.draw();
                spr.y -= strumOffsetLerp.y;
                spr.x -= strumOffsetLerp.x;
            }
        }
    }
}

public var hudOffY:Float = 0;
function update(elapsed:Float) {
    strumOffsetLerp.x = lerp(strumOffsetLerp.x, strumOffset.x, FlxEase.circInOut(.27));
    strumOffsetLerp.y = lerp(strumOffsetLerp.y, strumOffset.y, FlxEase.circInOut(.27));

    negMultY = lerp(negMultY, desiredMultY, FlxEase.circInOut(.27));

    hudX = lerp(hudX, desiredHudX, FlxEase.sineInOut(.2));
    moveHUD(hudX, hudY + hudOffY);
}

var hudX:Float = 283.5;
var desiredHudX:Float = 283.5;
public var hudY:Float = 564;
var hudTween:FlxTween;
public function changeDownScroll() {
    //if (!FlxG.save.data.mechanics) return;
    pluSFX();

    for(fun in onDirectionChange) fun(true);

    desiredHudX = 283.5;
    desiredMultY = -1;

    if (hudTween != null) hudTween.cancelChain();
    for (i in 0...4) {
        (new FlxTimer()).start(i*.06, (_) -> {
            strumOffset.set(0,506);
            FlxTween.cancelTweensOf(strumLines.members[1].members[i]);
            FlxTween.tween(strumLines.members[1].members[i], {angle: -360}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut, onComplete: (_) -> {
                strumLines.members[1].members[i].angle = 0;
            }});
        });
    }

    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4.5, ()->{ for(fun in onDirectionChangePost) fun(true); });
    hudTween = FlxTween.num(hudY, 564+300, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(
        hudTween = FlxTween.num(-400, 50, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
            hudY = val;
        })
    );
}

function pluSFX() {
    //if (!FlxG.save.data.mechanics) return;
    // camHUD.shake(0.002, 0.3);
    FlxG.sound.play(Paths.sound('undertale/snd_break2'), .67 * soundMultiplier);
    FlxG.sound.play(Paths.sound('undertale/snd_noise'), .8 * soundMultiplier);
    FlxG.sound.play(Paths.sound('undertale/snd_impact'), .2 * soundMultiplier);
}

public function changeUpScroll() {
    //if (!FlxG.save.data.mechanics) return;
    pluSFX()();

    for(fun in onDirectionChange) fun(false);

    desiredHudX = 283.5;
    desiredMultY = 1;
    if (hudTween != null) hudTween.cancelChain();
    for (i in 0...4) {
        (new FlxTimer()).start(i*.06, (_) -> {
            strumOffset.set(0, 0);
            FlxTween.cancelTweensOf(strumLines.members[1].members[i]);
            FlxTween.tween(strumLines.members[1].members[i], {angle: 360}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut, onComplete: (_) -> {
                strumLines.members[1].members[i].angle = 0;
            }});
        });
    }

    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4.5, ()->{ for(fun in onDirectionChangePost) fun(false); });
    hudTween = FlxTween.num(hudY, -400, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(
        hudTween = FlxTween.num(564+300, 564, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
            hudY = val;
        })
    );
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

//function create()
    //strumLines.members[1].onNoteUpdate.add(onNoteUpdate);

public var desiredMultY:Float = 1;
public var negMultY(default, set):Float = 1;
function set_negMultY(value:Float) {
    if(negMultY == value)
        return;
    if(updateNotes) {
        if(value != 1) {
            if(!strumLines.members[1].onNoteUpdate.has(updateNoteScroll))
                strumLines.members[1].onNoteUpdate.add(updateNoteScroll);
        } else if(strumLines.members[1].onNoteUpdate.has(updateNoteScroll))
            strumLines.members[1].onNoteUpdate.remove(updateNoteScroll);
    }
    return negMultY = value;
}
/*function onNoteUpdate(e:NoteUpdateEvent) {
    if(!updateNotes)
        return;
    e.__reposNote = false;
    var note:Note = e.note;

    var baseScrollFactor:Float = 0.45 * CoolUtil.quantize(scrollSpeed, 100);
    var timeUntilNote:Float = note.strumTime - Conductor.songPosition;
    var posy:Float = timeUntilNote * baseScrollFactor;
    if (note.isSustainNote) posy += Strum.N_WIDTHDIV2;

    note.y = e.strum.y + posy * negMultY;
    note.x = e.strum.x + (((e.strum.width - note.width) / 2) * Math.abs(negMultY)) + (posy * desiredMultX);

    if (note.isSustainNote) {
        note.health = negMultX < 0 ? -1 : 1;
        note.angle = 90 * negMultX; 
        if (note.animation.name == "holdend") {
            note.scale.y = negMultY;
            note.y -= Math.min(0, negMultY)*110;
        }
        note.y -= e.strum.height/2 * baseScrollFactor * Math.abs(Math.min(0, negMultY));
    }
}*/

public function updateNoteScroll(e:NoteUpdateEvent) {
    e.__reposNote = false;

    var note:Note = e.note;
    var strum:Strum = e.strum;
    var speed:Float = strum.getScrollSpeed(note);

    strum.y += strumOffsetLerp.y;
    strum.x += strumOffsetLerp.x;
    strum.updateNotePosition(note);
    strum.y -= strumOffsetLerp.y;
    strum.x -= strumOffsetLerp.x;
    note.y = (note.strumTime - Conductor.songPosition) * (0.45 * (CoolUtil.quantize(speed * negMultY, 100))) + strumOffsetLerp.y;
    
    if (note.isSustainNote) {
		if (note.nextSustain != null) {
            note.scale.y = (note.sustainLength * 0.45 * speed) / note.frameHeight;
            note.scale.y *= negMultY;
            note.updateHitbox();
            note.scale.y += (note.gapFix / note.frameHeight) * negMultY;
        }
        if (note.animation.name == "holdend") {
            note.scale.y = negMultY;
            note.y -= Math.min(0, negMultY)*110;
        }
        note.y += ((note.frameHeight/2) * negMultY);
    }
}