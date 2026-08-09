import flixel.system.ui.FlxSoundTray;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import funkin.backend.system.framerate.Framerate;

var post:Bool = false;

var barBg:Bitmap;
var bar:Bitmap;

var bgX:Int;
var bgY:Int = 36;

var width:Int = 124.5;
var height:Int = 5;

function postCreate() {

    barBg = new Bitmap(new BitmapData(width, height, false, FlxColor.WHITE));
    bar = new Bitmap(new BitmapData(width, height, false, FlxColor.WHITE));

    _defaultScale = 1;
    barsAmount = 0;
    barBg.alpha = 0.5;
    addChild(barBg);
    addChild(bar);
    background.width = width * 1.25;
    background.height = 50;
    FlxSoundTray.volumeChangeSFX = Paths.sound('menu/scroll');
    text.setTextFormat(new TextFormat(Paths.getFontName(Paths.font("DTM-Mono.ttf"))));

    background.x = 0;
    for(i => spr in [barBg, bar, text]) {
        spr.x = (background.width - width) / 2;
        if(i < 2)
            spr.y = bgY;
    }
    text.x += text.width * .25;
}

function regenerateBars(_) {
    _.cancel();
    regenerateBarsArray();
}

function postReloadText(_) {
    text.height = _height;
    text.multiline = true;
    text.wordWrap = true;
    text.selectable = false;

	text.defaultTextFormat = new TextFormat(Framerate.fontName, 16, -1);
	text.defaultTextFormat.align = TextFormatAlign.CENTER;
	text.antiAliasType = 0;
	text.sharpness = 400/*MAX ON OPENFL*/;
}

function postShow(_) {
    y = -10;
    bar.width = width * (FlxG.sound.muted ? 0 : FlxG.sound.volume);
    text.textColor = FlxG.sound.muted ? FlxColor.GRAY : FlxColor.WHITE;
}