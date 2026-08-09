import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import haxe.Json;
import flixel.text.FlxText;
import flixel.text.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTweenType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

importScript("data/scripts/galleryBG");

var images:Array<String>;
var curSelected:Int = 0;
static var galleryMusicStarted:Bool = false;

var frame:FlxSprite;
var background:FlxSprite;
var imageDisplay:FlxSprite;
var leftArrow:FlxSprite;
var rightArrow:FlxSprite;
var sprites:Array<FlxSprite> = [];
var transition:Bool = false;
var cooldownTimer:Float = 0;
var songs:Array<Category>;
var infoFrame:FlxSprite;
var infoBackground:FlxSprite;
var titleText:FlxText;
var storyText:FlxText;
var titleUnderline:FlxSprite;
var infoVisible:Bool = false;
var overlay:FlxSprite;
var infoTween:Dynamic;
var infW = 900, infH = 400;
var offY:Float;
var infX:Float, infY:Float;


function create():Void {

    createGalleryBG();
    
    var raw = Assets.getText(Paths.json("config/songstuff"));
    var data = Json.parse(raw);
    var imageNames = [];
    songs = [];

    for (entry in data) {
        imageNames.push("gallery/songs/" + entry.name);
        songs.push(entry);
    }

    images = imageNames;

    for (path in images) {
        var sp = new FlxSprite().loadGraphic(Paths.image(path, null, false, "jpg"), false);
        sprites.push(sp);
    }

    if (!galleryMusicStarted) {
        FlxG.sound.playMusic(Paths.music("gallery_placeholder"), 1, true);
        galleryMusicStarted = true;
    }

    var boxX = 155;
    var boxY = 85;
    var boxW = 971;
    var boxH = 551;
    var infW = 600, infH = 680;
    infX = (FlxG.width - infW) / 2;
    infY = (FlxG.height - infH) / 2;
    offY = FlxG.height + 50;

    frame = new FlxSprite(boxX, boxY);
    frame.makeGraphic(boxW, boxH, FlxColor.WHITE);
    add(frame);

    background = new FlxSprite(boxX + 5, boxY + 5);
    background.makeGraphic(boxW - 10, boxH - 10, FlxColor.BLACK);
    add(background);

    imageDisplay = new FlxSprite();
    imageDisplay.antialiasing = Options.antialiasing;
    updateImage();
    imageDisplay.updateHitbox();
    add(imageDisplay);

    leftArrow = textCrispy(new FlxText(0, 0, 50, "<", 80, true));
    leftArrow.setFormat(Paths.font("8bit-jve.ttf"), 80, FlxColor.WHITE, FlxTextAlign.CENTER);
    leftArrow.x = 50;
    leftArrow.y = FlxG.height / 2 - leftArrow.height / 2;
    add(leftArrow);

    rightArrow = textCrispy(new FlxText(0, 0, 50, ">", 80, true));
    rightArrow.setFormat(Paths.font("8bit-jve.ttf"), 80, FlxColor.WHITE, FlxTextAlign.CENTER);
    rightArrow.x = FlxG.width - 50 - rightArrow.width;
    rightArrow.y = FlxG.height / 2 - rightArrow.height / 2;
    add(rightArrow);

    sText = textCrispy(new FlxText(0, 500, 500, "PRESS ENTER TO SHOW STORY", 40, true));
    sText.setFormat(Paths.font("8bit-jve.ttf"), 40, FlxColor.WHITE, FlxTextAlign.CENTER);
    sText.x = FlxG.width / 2 - sText.width / 2;
    sText.y = FlxG.height - 30 - sText.height;
    add(sText);

    //Press Enter text animation
    FlxTween.tween(
        sText,
        { alpha: 0.1 },
        1.5,
        {
            type: FlxTweenType.PINGPONG,
            ease: FlxEase.sineInOut
        }
    );

    overlay = new FlxSprite(0, 0);
    overlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    overlay.set_alpha(0);
    add(overlay);

    infoFrame = new FlxSprite(infX, offY);
    infoFrame.makeGraphic(infW, infH, FlxColor.WHITE);
    infoFrame.set_alpha(0);
    add(infoFrame);

    infoBackground = new FlxSprite(infX + 5, offY + 5);
    infoBackground.makeGraphic(infW - 10, infH - 10, FlxColor.BLACK);
    infoBackground.set_alpha(0);
    add(infoBackground);

    titleText = textCrispy(new FlxText(infX + 20, offY + 20, infW - 40, "", 60));
    titleText.setFormat(Paths.font("8bit-jve.ttf"), 60, FlxColor.WHITE, FlxTextAlign.CENTER);
    titleText.set_alpha(0);
    add(titleText);

    titleUnderline = new FlxSprite(infX + 100, offY + 90);
    titleUnderline.makeGraphic(infW - 200, 3, FlxColor.WHITE);
    titleUnderline.set_alpha(0);
    add(titleUnderline);
    titleUnderline.x = titleText.x + (titleText.width - titleUnderline.width) / 2;

    storyText = textCrispy(new FlxText(infX + 40, offY + 100, infW - 80, "", 25, true));
    storyText.setFormat(Paths.font("8bit-jve.ttf"), 25, FlxColor.WHITE, FlxTextAlign.CENTER);
    storyText.wordWrap = true;
    storyText.set_alpha(0);
    add(storyText);
}

function update(elapsed:Float):Void {
    if (infoVisible && controls.BACK) {
        cooldownTimer = 0.5;
        _hideInfo();
        return;
    }

    if (!infoVisible && (controls.BACK || controls.BACK)) {
        FlxG.switchState(new ModState("gallery/GalleryState"));
        return;
    }

    if (cooldownTimer > 0) {
        cooldownTimer -= elapsed;
        return;
    }

    if (!infoVisible && (FlxG.keys.justPressed.LEFT || FlxG.mouse.justPressed && FlxG.mouse.overlaps(leftArrow))) {
        animateArrow(leftArrow);
        changeSelection(-1);
    }

    if (!infoVisible && (FlxG.keys.justPressed.RIGHT || FlxG.mouse.justPressed && FlxG.mouse.overlaps(rightArrow))) {
        changeSelection(1);
        animateArrow(rightArrow);
    }

    if (FlxG.keys.justPressed.ENTER) {
        cooldownTimer = 0.5;
        if (!infoVisible) _showInfo();
        else _hideInfo();
    }
}

function _showInfo():Void {
    var current = songs[curSelected];
    titleText.set_text(current.title);
    storyText.set_text(current.story);

    overlay.set_alpha(0); 
    FlxTween.tween(overlay, { alpha: 0.9 }, 0.4, { ease: FlxEase.quadInOut });

    infoFrame.set_alpha(1); infoBackground.set_alpha(1);
    titleText.set_alpha(1); storyText.set_alpha(1);
    titleUnderline.set_alpha(1);
    FlxTween.tween(infoFrame,      { y: infY },     0.4, { ease: FlxEase.circOut });
    FlxTween.tween(infoBackground,{ y: infY + 5 }, 0.4, { ease: FlxEase.circOut });
    FlxTween.tween(titleText,      { y: infY + 20 },0.4, { ease: FlxEase.circOut });
    FlxTween.tween(titleUnderline, { y: infY + 90 }, 0.4, { ease: FlxEase.circOut });
    FlxTween.tween(storyText,      { y: infY + 120 },0.4, { ease: FlxEase.circOut });

    infoVisible = true;
}

function _hideInfo():Void {
    FlxTween.tween(overlay, { alpha: 0 }, 0.4, { ease: FlxEase.quadInOut });

    FlxTween.tween(infoFrame,      { y: offY },     0.4, { ease: FlxEase.circIn });
    FlxTween.tween(infoBackground,{ y: offY + 5 }, 0.4, { ease: FlxEase.circIn });
    FlxTween.tween(titleText,      { y: offY + 20 },0.4, { ease: FlxEase.circIn });
    FlxTween.tween(titleUnderline, { y: offY + 90 }, 0.4, {
    ease: FlxEase.circIn,
        onComplete: function(_) {
            titleUnderline.set_alpha(0);
        }
    });
    FlxTween.tween(storyText,      { y: offY + 100 },0.4, { ease: FlxEase.circIn, onComplete: function(t) {
        infoFrame.set_alpha(0);
        infoBackground.set_alpha(0);
        titleText.set_alpha(0);
        storyText.set_alpha(0);
        infoVisible = false;
    }});
}

function changeSelection(amt:Int):Void {
    if (transition) return;
    transition = true;
    cooldownTimer = 0.7;
    var padding = 50;
    var offset = background.width + padding;
    var screenOffset = (amt > 0) ? -offset : offset;
    var originalX = frame.x;
    var fadeDuration = 0.15;
    var moveDuration = 0.3;

    FlxTween.tween(frame,      { alpha: 0, x: frame.x + screenOffset }, fadeDuration, { ease: FlxEase.quadOut });
    FlxTween.tween(background, { alpha: 0, x: background.x + screenOffset }, fadeDuration, { ease: FlxEase.quadOut });
    FlxTween.tween(imageDisplay,{ alpha: 0, x: imageDisplay.x + screenOffset }, fadeDuration, { ease: FlxEase.quadOut, onComplete: () -> {
            curSelected = FlxMath.wrap(curSelected + amt, 0, images.length - 1);
            updateImage();

            frame.x = originalX - screenOffset;
            background.x = frame.x + 5;
            imageDisplay.x = background.x + (background.width - imageDisplay.width) / 2;

            frame.alpha = background.alpha = imageDisplay.alpha = 0;

            FlxTween.tween(frame,      { x: originalX, alpha: 1 }, moveDuration, { ease: FlxEase.quadOut });
            FlxTween.tween(background, { x: originalX + 5, alpha: 1 }, moveDuration, { ease: FlxEase.quadOut });
            FlxTween.tween(imageDisplay, {
                x: originalX + 5 + (background.width - imageDisplay.width) / 2,
                alpha: 1
            }, moveDuration, { ease: FlxEase.quadOut, onComplete: () -> transition = false });
    }});
}


function updateImage():Void {
    var path = images[curSelected];
    imageDisplay.loadGraphic(Paths.image(path, null, false, "jpg"));

    var innerW = background.width;
    var innerH = background.height;

    imageDisplay.setGraphicSize(innerW, innerH);
    imageDisplay.centerOffsets();
    imageDisplay.updateHitbox();

    imageDisplay.x = background.x + (innerW - imageDisplay.width) / 2;
    imageDisplay.y = background.y + (innerH - imageDisplay.height) / 2;
}

function animateArrow(sprite:FlxText):Void {
    FlxTween.cancelTweensOf(sprite);
    FlxG.sound.play(Paths.sound("menu/scroll"), 1);

    FlxTween.tween(sprite.scale, { x:1.2, y:1.2 }, 0.1, {
        type: FlxTweenType.PINGPONG,
        ease: FlxEase.quadOut,
        onComplete: function(tween:FlxTween):Void {
            if (tween.executions >= 2) tween.cancel();
        }
    });

    FlxTween.color(sprite, 0.1, FlxColor.WHITE, FlxColor.YELLOW, {
        type: FlxTweenType.PINGPONG,
        ease: FlxEase.quadOut,
        onComplete: function(tween:FlxTween):Void {
            if (tween.executions >= 2) tween.cancel();
        }
    });
}