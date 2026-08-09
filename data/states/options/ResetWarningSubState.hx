// this is coded last minute, don't question it - higg
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.savedata.FunkinSave;
import funkin.backend.assets.ModsFolder;

var cam:FlxCamera;

var choices:Array<FunkinText> = [];
var selected:Int = 0;
var frame1:Bool = true;

function create() {
    cam = new FlxCamera();
    cam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(cam, false);
    cam.alpha = 0;

    var bg:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0.75;
    bg.camera = cam;
    add(bg);

    var header = textCrispy(new FunkinText(0, 130, FlxG.width, "are yOu sure yOu want to\nreset?", 50, false));
    header.setFormat(Paths.font("fallen-down.ttf"), 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    header.borderSize = 6;
    header.camera = cam;
    add(header);

    var text = textCrispy(new FunkinText(0, 330, FlxG.width * 0.8, "", 50, false));
    text.text = "Once you reset, there will be no data transfering between older versions. Your EXP, story progress, and scores WILL be gone.\nDo you want to proceed?";
    text.setFormat(Paths.font("8bit-jve.ttf"), 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    text.screenCenter(FlxAxes.X);
    text.borderSize = 3;
    text.camera = cam;
    add(text);

    var no = textCrispy(new FunkinText(0, 580, FlxG.width, "", 50, false));
    no.ID = 0;
    no.x -= FlxG.width * 0.15;
    no.text = "No";
    no.setFormat(Paths.font("8bit-jve.ttf"), 40, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    no.borderSize = 3;
    no.camera = cam;
    choices.push(no);
    add(no);

    var yes = textCrispy(new FunkinText(0, 580, FlxG.width, "", 50, false));
    yes.ID = 1;
    yes.x += FlxG.width * 0.15;
    yes.text = "Yes";
    yes.setFormat(Paths.font("8bit-jve.ttf"), 40, FlxColor.GRAY, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    yes.borderSize = 3;
    yes.camera = cam;
    choices.push(yes);
    add(yes);

    FlxTween.tween(cam, {alpha: 1}, 1);
}

function update(elapsed:Float) {
    if (frame1)
        return frame1 = false;
    if (controls.BACK) {
        persistentUpdate = true;
        close();
    } else if (controls.LEFT_P || controls.RIGHT_P) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
        selected = FlxMath.wrap(selected + 1, 0, 1);
        for (choice in choices)
            choice.color = (choice.ID == selected) ? FlxColor.WHITE : FlxColor.GRAY;

    } else if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound("menu/confirm"));
        if (selected == 0) {
            persistentUpdate = true;
            close();
        } else reset();
    }
}

function reset() {
    FunkinSave.save.erase();
    FunkinSave.highscores.clear();
    FunkinSave.flush();

    FlxG.save.erase();
    FlxG.save.data.dustinMigratedV2 = true;
    FlxG.save.data.dustinMigrated = true;
    FlxG.save.flush();

    Options.freeplayLastSong = "perseverance";

    ModsFolder.switchMod(ModsFolder.currentModFolder);
}

function destroy() {
    FlxTween.cancelTweensOf(cam);
    cam.destroy();
}