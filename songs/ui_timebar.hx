//
import flixel.ui.FlxBarFillDirection;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormat;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.math.FlxRect;

public var precentWidth:Float;
public var customLengthOverride:Float = -1;

static var timeBarBG:FlxSprite;
static var timeBar:FlxSprite;

static var timeBarColors:Array<Int> = [0xFFFFFFFF, 0xFFFF0000];
var cahceRect:FlxRect = new FlxRect();

static var timeTxt:FunkinText;

function create() {
    var timeBarSkin:String = "snowdin";
    if (stage != null && stage.stageXML != null && stage.stageXML.exists("timeBarSkin"))
		timeBarSkin = stage.stageXML.get("timeBarSkin");
    
    timeBarBG = createTimeBG(timeBarSkin);

    var bfColor:Int = boyfriend != null && boyfriend.iconColor != null && Options.colorHealthBar ? boyfriend.iconColor : (PlayState.opponentMode ? 0xFFFF0000 : 0xFF66FF33);

    timeBarColors = [bfColor, 0xFF000000];

    timeBar = new FlxSprite(timeBarBG.x, timeBarBG.y).loadGraphic(Paths.image("game/ui/timebar_fill_" + timeBarSkin));
    timeBar.cameras = [camHUD]; timeBar.scrollFactor.set();
    timeBar.antialiasing = Options.antialiasing; timeBar.flipY = camHUD.downscroll;

    add(timeBar); hudElements.push(timeBar);
    add(timeBarBG); hudElements.push(timeBarBG);

    timeTxt = textCrispy(new FunkinText(timeBar.x, timeBarBG.y+2, 0, "0:00 / 0:00", 16));
    add(timeTxt); hudElements.push(timeTxt);

    timeTxt.cameras = [camHUD]; timeTxt.scrollFactor.set();

    timeTxt.setFormat(Paths.font("DTM-Mono.ttf"), 16, 0xFFFFFFFF);

    timeTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
    timeTxt.borderSize = 2;
    timeTxt.borderColor = 0xFF000000;

    timeBar.onDraw = () -> {
        for (i => color in timeBarColors) {
            var length = (customLengthOverride > 0) ? customLengthOverride : inst.length;
            precentWidth = timeBar.width * (lerpedTime / length);

            switch (i) {
                case 0: cahceRect.set(0, 2, precentWidth, timeBar.height-2);
                case 1: cahceRect.set(precentWidth, 2, timeBar.width-precentWidth, timeBar.height - 2);
            }

            timeBar.colorTransform.color = color;
            timeBar.clipRect = cahceRect;
            timeBar.draw();
        }
    };
}

static function createTimeBG(image:String) {
    var newTimeBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9 - 10).loadGraphic(Paths.image("game/ui/timebar_" + image));
    newTimeBG.cameras = [camHUD]; newTimeBG.scrollFactor.set(); newTimeBG.antialiasing = Options.antialiasing; newTimeBG.flipY = camHUD.downscroll;
    newTimeBG.screenCenter(FlxAxes.X);
    return newTimeBG;
}

var lerpedTime:Float = 0;
function update(elapsed:Float) {
    if (inst.volume == 0) return;
    lerpedTime = CoolUtil.fpsLerp(lerpedTime, inst.time, 1/20);

    var timeTextText:String = getTimeText();
    if (timeTextText != timeTxt.text)
        timeTxt.text = timeTextText;

    timeTxt.x = timeBarBG.x + timeBarBG.width/2 - timeTxt.width/2;
    timeTxt.y = timeBarBG.y + 2;
}


function getTimeText():String {
    var length = (customLengthOverride > 0) ? customLengthOverride : inst.length;
    return FlxStringUtil.formatTime(inst.time / 1000) + " / " + FlxStringUtil.formatTime(length / 1000);
}