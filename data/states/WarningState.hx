//

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.MusicBeatState;

var newWarningFont:FlxText = null;
function postCreate() {

    FlxG.camera.flash(0xFF000000, .3);
    MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
    disclaimer.text = "This mod uses alot of shaders and may lag on low end devices.\n\nYou can turn them off with the options menu:\nAppearance  >  Advanced  >  #Gameplay Shaders#\n\nHeavy *flashing lights* lights are also used, please proceed with caution!!!\n\n_Press ENTER/LEFT CLICK to continue._";
    disclaimer.applyMarkup(disclaimer.text, [
        new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF5D5D), "*"),
        new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF55DAFF), "#"),
        new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFF00), "_")
    ]);
    disclaimer.font = Paths.font("8bit-jve.ttf");
    textCrispy(disclaimer);
    disclaimer.y += 15;

    newWarningFont = textCrispy(new FlxText(0, 170, FlxG.width, "WaRNING"));
    newWarningFont.setFormat(Paths.font("fallen-down.ttf"), 60, 0xFFFFFFFF);
    newWarningFont.borderStyle = FlxTextBorderStyle.OUTLINE;
    newWarningFont.borderSize = 2;
    newWarningFont.borderColor = 0xFF000000;
    newWarningFont.alignment = "center";
    add(newWarningFont);

    titleAlphabet.visible = false;

    var freakingLunarBro = new FunkinSprite().loadGraphic(Paths.image('menus/credits/sprites/Lunarcleint'));
    add(freakingLunarBro);
    freakingLunarBro.scale.set(12, 12);
    freakingLunarBro.updateHitbox();
    freakingLunarBro.screenCenter();
    freakingLunarBro.x -= 675;
    freakingLunarBro.alpha = 0;

    new FlxTimer().start(20, function() {
        FlxTween.tween(freakingLunarBro, {alpha: 0.075, x: freakingLunarBro.x + 25}, 10);
    });
}

var __timer:Float = 0;
function update(elapsed:Float) {
    __timer += elapsed;
    if (controls.ACCEPT || FlxG.mouse.justPressed) {
        FlxG.camera.visible = false;
        goToTitle();
    }

    if (FlxG.keys.justPressed.F)
        FlxG.fullscreen = !FlxG.fullscreen;
}

function destroy() {
    if (!Options.devMode) Framerate.debugMode = 0;
}
