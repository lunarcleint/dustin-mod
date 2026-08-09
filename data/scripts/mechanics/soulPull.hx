//
import flixel.tweens.FlxTweenManager;

var ogBFColor:FlxColor = 0xFFFFFFFF;
var heart:FlxSprite;
function postCreate() {

    strumLines.members[1].onNoteUpdate.add(onNoteUpdate);

    heart = new FunkinSprite().loadGraphic(Paths.image("game/heart"));
    heart.colorTransform.color = 0xFFFF0000;
	heart.scale.set(48/1024, 48/1024);
	heart.updateHitbox(); heart.visible = false;
	heart.antialiasing = false;
    heart.cameras = [camGame];
	add(heart);

    ogBFColor = ogHealthColors[1];
    FlxG.sound.play(Paths.sound('soul_transformation'), 0); // preload
}

var soulActive:Bool = false;
var time:Float = 0;
public function toggleSoul() {
    time = 0;

    soulActive = !soulActive;
    heart.colorTransform.color = soulActive ? 0xFF003CFF : 0xFFFF0000;
    heart.visible = true;
    heart.alpha = 1;

    if(FlxG.save.data.mechanics)
        doSansMechanicNormal = doSansMechanicSustains = soulActive;

    FlxTween.num(0, (soulActive ? 1.3 : 0), (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {sineAmount = val;});
    FlxTween.num(0, (soulActive ? .7 : 0), (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {pluey = val;});
    if(!soulActive)
        FlxTween.num(1, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {heart.alpha = val;});

    if(soulActive)
        FlxG.sound.play(Paths.sound('soul_transformation'), .75);
}

var sineAmount:Float = 0;
var pluey:Float = 0; // bluey pluey same thing... - lunar

var time:Float = 0;
function update(elapsed:Float) {
    time += elapsed;

    heart.x = boyfriend.x+160+(3*FlxMath.fastCos((time*1.3) + ((Conductor.stepCrochet / 1000))));
    heart.y = boyfriend.y+525+(4*FlxMath.fastSin((time*2) + ((Conductor.stepCrochet / 1000))));

    switch (boyfriend.animation.name) {
        case "singLEFT" | "singLEFTmiss": heart.x -= 110; heart.y -= 15;
        case "singDOWN" | "singDOWNmiss": heart.x -= 65; heart.y += 85;
        case "singUP" | "singUPmiss": heart.x += 30; heart.y -= 65;
        case "singRIGHT" | "singRIGHTmiss": heart.x += 110; heart.y += 5;
    }

    if (pluey != -1) {
        var strumColor:FlxColor = FlxColor.interpolate(0xFFFFFFFF, 0xFF2C61FF, pluey);
        for (i=>strum in strumLines.members[1].members)
            strum.color = strumColor;
        strumLines.members[1].notes.forEach(function (note) {
            if(!(note.extra.exists("isUndyne") || note.noteType == "NOTE_undyne"))
            note.color = strumColor;
        });
        dustiniconP1.color = boyfriend.color = strumColor;
        ogHealthColors[1] = FlxColor.interpolate(ogBFColor, 0xFF062792, pluey*1.3);
    }

}

var slowTime:Float = (hitWindow * 0.5 * 2.25);
var slowSustainTime:Float = slowTime*1.2;

var doSansMechanicNormal:Bool = false;
var doSansMechanicSustains:Bool = false;

function onNoteUpdate(e:NoteUpdateEvent) {
    var note:Note = e.note;
    if(soulActive || (note.noteTypeID != 0 && (note.noteType != "No Animation" || note.noteType == "No Anim Note"))) continue;

    var nextNoteIsSustain:Bool = note.nextNote != null ? note.nextNote.isSustainNote : false;
    var timeToUse:Float = nextNoteIsSustain ? slowSustainTime : slowTime;

    var allowedSustains:Bool = (doSansMechanicSustains && nextNoteIsSustain);
    var allowedNormal:Bool = (doSansMechanicNormal && !nextNoteIsSustain);

    if ((note.strumTime > (Conductor.songPosition + timeToUse)) && (allowedSustains || allowedNormal)) {
        e.__reposNote = false;

        var strum:Strum = strumLines.members[1].members[note.noteData];
        var posx = strum.x+((strum.width-note.width)/2);
        note.x = posx;

        var posy:Float = (note.strumTime - Conductor.songPosition) * (0.45 * CoolUtil.quantize(scrollSpeed, 100));
        // if (note.isSustainNote) pos += Strum.N_WIDTHDIV2;
        posy += strum.y;

        var progress:Float = 1-((note.strumTime - (Conductor.songPosition+timeToUse))/2000);
        note.y = FlxMath.lerp(nextNoteIsSustain ? 3200 : 5300, posy, FlxEase.quadIn(progress));
        
        // var progress2:Float = FlxEase.circOut(1-(note.strumTime - ((Conductor.songPosition+(timeToUse*1.3))))/1000);
        // note.x = FlxMath.lerp((note.noteData > 1) ? 120 : -120, posx, FlxEase.quadIn(progress));
    }
}