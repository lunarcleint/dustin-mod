//
import flixel.text.FlxTextBorderStyle;

function onStartSong() {
    inst.onComplete = bazinga;
}

function onGamePause(e) if (bigRichsIncoming) e.cancel(true);

var bigRichsIncoming:Bool = false;
public function bazinga() if (!bigRichsIncoming) {
    for(strum in strumLines) strum.ghostTapping = true;
    bigRichsIncoming = true;

    var gainAmount:Int = Std.int(switch (curRating.rating) {
        case "S++" | "=)": 700;
        case "S": 650;
        case "A": 600;
        case "B": 550;
        case "[N/A]": 0;
        default: 500;
    });
    if (!FlxG.save.data.mechanics) gainAmount = Math.round(gainAmount/2);
    if (FlxG.save.data.nh) gainAmount = Math.round(gainAmount*2);
    FlxG.save.data.dustinCash += gainAmount;

    for (camera in FlxG.cameras.list) {
        camera.alpha = 0;
        camera.visible = false;
    }

    var cutsceneCamera = new FlxCamera();
    cutsceneCamera.bgColor = 0xFF000000;
    FlxG.cameras.add(cutsceneCamera, false);

    var target_text = textCrispy(new FlxText(0, 0, 0, "+ 0 EXP"));
    target_text.setFormat(Paths.font("DTM-Mono.ttf"), 48, 0xFFFFFFFF);

    target_text.borderStyle = FlxTextBorderStyle.OUTLINE;
    target_text.borderSize = 2;
    target_text.borderColor = 0xFF000000;

    target_text.alpha = 0;
    target_text.cameras = [cutsceneCamera];
    add(target_text);

    target_text.screenCenter(0x11);
    FlxTween.tween(target_text, {alpha: 1}, .2);

    FlxTween.num(0, gainAmount, .7, {ease: FlxEase.sineOut}, (val:Float) -> {
        target_text.text = "+ " + Std.string(Math.floor(val)) + " EXP";
        target_text.screenCenter(0x11);
    });

    FlxG.sound.play(Paths.sound("levelup"), 1, false, null, true);

    new FlxTimer().start(2.6, (_) -> {
        FlxG.cameras.remove(cutsceneCamera);
        endSong();
    });

    inst.volume = 0; vocals.volume = 0;
    for (strumLine in strumLines.members) strumLine.vocals.volume = 0;
}

function onSongEnd() {
    if (!FlxG.save.data.dustinBoughtStuff.contains(SONG.meta.name.toLowerCase()))
        FlxG.save.data.dustinBoughtStuff.push(SONG.meta.name.toLowerCase());
}