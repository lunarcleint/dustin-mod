//
import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.system.Logs;
import funkin.backend.utils.FlxInterpolateColor;
import hxvlc.flixel.FlxVideoSprite;

public static var FULL_VOLUME:Bool = false;

var onStart:Void->Void = null;
var callback:Void->Void = null;
var vid:FlxVideoSprite;
var holdCircle:FlxSprite;
var skipText:FunkinText;
var skipColor:FlxInterpolateColor = new FlxInterpolateColor(0xffffffff);
var alphaTween:FlxTween;
var alphaTimer:Float = 0.0;
var holdTime:Float = 0.0;
var cutsceneCamera:FlxCamera = null;

var oldVisible = [];
var vidName:String;
function startVideo(name:String, ?leCallback:Void->Void, ?ext:String, ?usePath:Bool) {
    vidName = name;

    callback = leCallback;
    ext ??= "mp4";

    cutsceneCamera = new FlxCamera();
    cutsceneCamera.bgColor = 0xFF000000;
    FlxG.cameras.add(cutsceneCamera, false);

    add(vid = new FlxVideoSprite());
    vid.cameras = [cutsceneCamera];
    vid.antialiasing = CoolUtil.coolTextFile(Paths.video("nonPixelyCutscenes", "txt")).contains(new Path(name).file);
    vid.bitmap.onFormatSetup.add(function() if (vid.bitmap?.bitmapData != null) {
        final width = vid.bitmap.bitmapData.width;
        final height = vid.bitmap.bitmapData.height;
        final scale:Float = Math.min(FlxG.width / width, FlxG.height / height);
        vid.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
        vid.updateHitbox();
        vid.screenCenter();
    });

    try {
        if (FULL_VOLUME) {
            vid.autoVolumeHandle = false;
            vid.bitmap.volume = 1;

            FULL_VOLUME = false;
        }
    }
    catch (e:Any) {
        // hxvlc 1.5.0/CNE <=v1.0.1 backward comaptibility
        // Does nothing if fails
    }

    add(skipText = textCrispy(new FunkinText(-28, FlxG.height - 50 - 6, FlxG.width, "Hold ENTER/LEFT CLICK to skip...").setFormat(Paths.font('8bit-jve.ttf'), 32, 0xffffffff, "right", FlxTextBorderStyle.OUTLINE, 0xff000000)));
    skipText.scrollFactor.set();
    skipText.borderSize = 3;
    skipText.cameras = [cutsceneCamera];

    add(holdCircle = new FlxSprite());
    holdCircle.frames = Paths.getFrames(Paths.image("menus/holdCircle"), true);
    holdCircle.animation.addByPrefix("idle", "hold", ratio = ((holdCircle.frames.frames.length - 1) / 2), false);
    holdCircle.animation.frameIndex = 0;
    holdCircle.setGraphicSize(33 * (FlxG.width / 1280), 33 * (FlxG.width / 1280));
    holdCircle.updateHitbox();
    holdCircle.setPosition(FlxG.width - holdCircle.width - skipText.textField.textWidth - 40 - 8, FlxG.height - holdCircle.height - 10 - 10);
    holdCircle.cameras = [cutsceneCamera];

    ratio /= 360;  // before i forger  - Nex

    if (vid.load(usePath == false ? Paths.video(name, ext) : name)) {
        //making sure the game doesn't freeze before the video plays - HIGG
        vid.play();
        vid.pause();
        new FlxTimer().start(0.0001, () -> {
            for (cam in FlxG.cameras.list) {
                if (cam == cutsceneCamera)
                    continue;
                if (cam.visible) {
                    oldVisible.push(cam);
                    cam.visible = false;
                }
            }
            vid.bitmap.position = 0;
            vid.play();
            vid.bitmap.onEndReached.add(onFinish);
            if(onStart != null)
                onStart();
        });
    } else {
        Logs.trace("Failed to load the cutscene, finishing directly!!", 2);
        onFinish();
    }
}

var ratio:Float;
function update(elapsed:Float) if (vid != null) {
    if (!FlxG.mouse.pressed && !FlxG.keys.pressed.ENTER) {  // i cant use accept cuz we dont have acept_hold, only in dev still sob  - Nex
        holdTime = 0;
        holdCircle.animation.stop();
        holdCircle.animation.frameIndex = 0;

        skipColor.color = 0xffffffff;

        if (alphaTimer > 1) doAlphaTween();
        else alphaTimer += elapsed;
    } else if (vid.alpha == 1) {
        alphaTween?.cancel();
        skipText.alpha = 1;
        alphaTimer = 0;
        holdCircle.animation.play("idle", false, false, 1);

        skipText.color = skipColor.fpsLerpTo(0xffff0000, ratio);

        if ((holdTime += elapsed) > 2)
            onFinish();
    }

    holdCircle.color = skipText.color = skipColor.color;
    holdCircle.alpha = skipText.alpha;

    //vid.x = Main.scaleMode.offset.x;
    //vid.y = Main.scaleMode.offset.y;

    if (vid != null && !vid.autoVolumeHandle) {
        var volume:Float = Math.floor(Math.pow(vid.getCalculatedVolume(), 0.333) * 100.0);
        if (vid.bitmap.volume != volume)
            vid.bitmap.volume = volume;
    }
}

function getCalculatedVolume() {
    return (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;
}

function doAlphaTween() {
    alphaTween?.cancel();
    alphaTween = FlxTween.tween(skipText, {alpha: 0}, 0.5);
}

import StringTools;

function onFinish() {
    vid.bitmap?.dispose();
    vid.destroy();
    vid = null; // cuz it doesnt happen instantly and i need it for update  - Nex
    FlxG.cameras.remove(cutsceneCamera, true);

    if (!StringTools.contains(vidName, "end-cutscene")) {
        for (cam in oldVisible)
            cam.visible = true;
    }
    
    if (callback != null) callback();
}