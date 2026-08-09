//

import dustin.DustinUtil;
import hscript.TemplateClass;
import Reflect;

static var DustinUtil = DustinUtil;

public static var forceUpdate:Array<(elapsed:Float)-> Void> = [];

static function scriptObject(script:Script):TemplateClass {
    var scriptClass:TemplateClass = new TemplateClass();
    Reflect.setField(scriptClass, "__interp", script.interp);

    return scriptClass;
}

static function textCrispy(target_text) {
    target_text.textField.antiAliasType = 0/*ADVANCED*/;
    target_text.textField.sharpness = 400/*MAX ON OPENFL*/;
    target_text.antialiasing = false;
    return target_text;
}

static function validHurtNoteHit(note:Note) {
    return note.extra["hurtNote"] != null && Math.abs(Conductor.songPosition - note.strumTime) < 90;
}

static var curMusicID = "";
static function playMusic(?song:String, ?volume:Float, ?fadeIn:Bool) {
    if (song == null) song = curMusicID;
    if (volume == null) volume = 1;
    if (fadeIn == null) fadeIn = false;

    if (curMusicID != (curMusicID = song) || (FlxG.sound.music == null || !FlxG.sound.music.playing || FlxG.sound.music.length < 100)) {
        CoolUtil.playMusic(Paths.music(curMusicID), true, fadeIn ? 0 : volume, true, 124);
        if (fadeIn) FlxG.sound.music.fadeIn(4, 0, volume);
        else FlxG.sound.music.volume = volume; // this is just needed for some reason music blasts my ears without it
    }
}

function postUpdate(elapsed) {
    for(func in forceUpdate) {
        func(elapsed);
    }
}