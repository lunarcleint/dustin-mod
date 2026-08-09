//
importScript("data/scripts/DialogueBoxBG");
importScript("data/scripts/galleryBG");
import openfl.geom.Rectangle;
import sys.FileSystem;
import haxe.io.Path;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTweenType;
import flixel.text.FlxTextAlign;
import Paths;
import openfl.geom.Point;
import hxvlc.flixel.FlxVideoSprite;

var videoPlaying:Bool = false;

var cameraY = 0;
var maxCameraY = 0;
var gallerySprites:Array<FlxSprite> = [];
var baseScales:Array<Float> = [];

var imagePathsNoExt:Array<String> = [];
var imagePathsWithExt:Array<String> = [];

var previewFrame:FlxSprite;
var previewImage:FlxSprite;
var previewVideo:FlxVideoSprite;
var previewText:FlxText;
var groupLabel:FlxText;
var canSelect:Bool = true;

var leftArrow:FlxSprite;
var rightArrow:FlxSprite;

var galleryGroups:Array<String> = [
    "shitpost",
    "concepts",
    "cutscenes",
    "winner_contest"
];
var currentGroupIndex = 0;

var inspectBox:FunkinSprite;
var inspectLabel:FlxText;

function create() {
    createGalleryBG();

    previewFrame = new FlxSprite(FlxG.width - 500, 0);
    previewFrame.makeGraphic(400, FlxG.height, 0x00000000);
    previewFrame.scrollFactor.set(0, 0);
    add(previewFrame);

    previewImage = new FlxSprite(previewFrame.x + 10, 10);
    previewImage.scrollFactor.set(0, 0);
    previewImage.visible = true;
    add(previewImage);

    previewVideo = new FlxVideoSprite(previewFrame.x + 10, 10);
    previewVideo.antialiasing = Options.antialiasing;
    previewVideo.scrollFactor.set(0, 0);
    previewVideo.visible = false;
    add(previewVideo);

    previewText = textCrispy(new FlxText(previewFrame.x, 30, 400, ""));
    previewText.setFormat(null, 16, 0xFFFFFFFF, "center");
    previewText.scrollFactor.set(0, 0);
    previewText.alpha = 0;
    add(previewText);

    var gradientSprite:FlxSprite = FlxGradient.createGradientFlxSprite(300, 500, [0xFF000000, 0x00000000], 1, true);
    gradientSprite.angle = 90;
    gradientSprite.scrollFactor.set(0, 0);
    gradientSprite.x = 160;
    gradientSprite.y = -100;
    add(gradientSprite);

    var gradientSprite:FlxSprite = FlxGradient.createGradientFlxSprite(300, 500, [0x00000000, 0xFF000000], 1, true);
    gradientSprite.angle = 90;
    gradientSprite.scrollFactor.set(0, 0);
    gradientSprite.x = 160;
    gradientSprite.y = 320;
    add(gradientSprite);

    // maybe another day.. - hig
    
    /*inspectBox = newDialogueBoxBG(FlxG.width - 465,FlxG.height - 80,null,300,60,5);
    inspectBox.pixels.fillRect(new Rectangle(5,5,130,40),0xFF000000);
    inspectBox.visible = true; add(inspectBox);
    inspectBox.scrollFactor.set(0, 0);

    inspectLabel = new FlxText(0, 0, 300, "INSPECT");

    inspectLabel.textField.antiAliasType = 0/*ADVANCED;
	inspectLabel.textField.sharpness = 400/*MAX ON OPENFL;

    inspectLabel.setFormat(null, 18, 0xFFFFFF, "center");
    inspectLabel.scrollFactor.set(0, 0);
    inspectLabel.x = inspectBox.x;
    inspectLabel.y = inspectBox.y + (inspectBox.height - inspectLabel.height) / 2;
    add(inspectLabel);*/

    var b = newDialogueBoxBG(175,20,null,300,60,5);
    b.pixels.fillRect(new Rectangle(5,5,130,40),0xFF000000);
    b.visible = true; add(b);
    b.scrollFactor.set(0, 0);

    groupLabel = textCrispy(new FlxText(0, 0, 300, ""));
    groupLabel.setFormat(null, 18, 0xFFFFFF, "center");
    groupLabel.scrollFactor.set(0, 0);
    groupLabel.x = b.x;
    groupLabel.y = b.y + (b.height - groupLabel.height) / 2;
    add(groupLabel);

    leftArrow = textCrispy(new FlxText(0, 0, 40, "<"));

    leftArrow.setFormat(Paths.font("8bit-jve.ttf"), 40, FlxColor.WHITE, FlxTextAlign.CENTER);
    leftArrow.scrollFactor.set(0, 0);
    leftArrow.x = b.x + 10;
    leftArrow.y = b.y + (b.height - leftArrow.height) / 2;
    add(leftArrow);

    rightArrow = textCrispy(new FlxText(0, 0, 40, ">"));
    rightArrow.setFormat(Paths.font("8bit-jve.ttf"), 40, FlxColor.WHITE, FlxTextAlign.CENTER);
    rightArrow.scrollFactor.set(0, 0);

    rightArrow.x = b.x + b.width - 10 - rightArrow.fieldWidth;
    rightArrow.y = b.y + (b.height - leftArrow.height) / 2;
    add(rightArrow);

    var divLine = new FlxSprite(FlxG.width / 2 - 50, (FlxG.height - 500) / 2);
    divLine.makeGraphic(4, 500, FlxColor.WHITE);
    divLine.scrollFactor.set(0, 0);
    add(divLine);

    loadGalleryGroup(galleryGroups[currentGroupIndex]);

    insert(members.indexOf(previewFrame) + 1, gradientSprite);
    insert(members.indexOf(previewFrame) + 2, b);
    insert(members.indexOf(previewFrame) + 3, groupLabel);
}

function loadGalleryGroup(groupPath:String) {
    for (spr in gallerySprites) remove(spr);
    gallerySprites = [];
    baseScales = [];
    imagePathsNoExt = [];
    imagePathsWithExt = [];

    var colCount = 3;
    var margin = 30;
    var frameSize = 128;
    var offsetX = margin;
    var offsetY = margin;
    var colIndex = 0;

    groupPath = "gallery/" + groupPath;
    var fullPath = Paths.getAssetsRoot() + "/images/" + groupPath;
    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) return;
    var files = FileSystem.readDirectory(fullPath);

    for (file in files) {
        var ext = Path.extension(file).toLowerCase();
        if (ext == "png" || ext == "jpg") {
            var name = file.substr(0, file.lastIndexOf("."));
            var pathNoExt = groupPath + "/" + name;
            var pathWithExt = file;

            var spr = new FlxSprite();
            spr.loadGraphic(Paths.image(pathNoExt, null, false, ext));

            var origW = spr.frameWidth, origH = spr.frameHeight;
            var scale = Math.min(frameSize/origW, frameSize/origH,1);
            spr.scale.set(scale, scale);
            spr.centerOrigin();
            spr.updateHitbox();

            baseScales.push(scale);
            imagePathsNoExt.push(pathNoExt);
            imagePathsWithExt.push(pathWithExt);

            spr.x = offsetX + frameSize/2;
            spr.y = offsetY + frameSize/2;

            insert(members.indexOf(previewFrame), spr);
            gallerySprites.push(spr);

            if (++colIndex >= colCount) {
                colIndex = 0;
                offsetX = margin;
                offsetY += frameSize + margin;
            } else {
                offsetX += frameSize + margin;
            }
        }
    }

    var label:String = Path.withoutDirectory(groupPath).toUpperCase();

    if (gallerySprites.length > 0) showPreview(0);
    maxCameraY = Math.max(0, offsetY - FlxG.height + margin + (label == "CUTSCENES" ? 0 : 200));
    cameraY = 0;

    trace(groupPath);

    groupLabel.text = label;
}

function update(elapsed:Float) {
    if (FlxG.mouse.wheel != 0) {
        cameraY -= FlxG.mouse.wheel * 20;
    }
    cameraY = Math.min(Math.max(0, cameraY), maxCameraY);
    FlxG.camera.scroll.set(0, lerp(FlxG.camera.scroll.y , cameraY, Math.abs(FlxG.mouse.wheel) > 1 ? (Math.abs(FlxG.mouse.wheel) > 1.5 ? 0.95 : 0.85) : 0.25));

    var mouse = FlxG.mouse.getWorldPosition();

    var overlapRight:Bool = FlxG.mouse.overlaps(rightArrow);
    if(rightArrow.scale.x == 1)
        rightArrow.color = overlapRight ? FlxColor.YELLOW : FlxColor.WHITE;
    if (FlxG.keys.justPressed.RIGHT || FlxG.mouse.justPressed && overlapRight) {
        animateArrow(rightArrow);
        currentGroupIndex = (currentGroupIndex + 1) % galleryGroups.length;
        loadGalleryGroup(galleryGroups[currentGroupIndex]);
    }

    var overlapLeft:Bool = FlxG.mouse.overlaps(leftArrow);
    if(leftArrow.scale.x == 1)
        leftArrow.color = overlapLeft ? FlxColor.YELLOW : FlxColor.WHITE;
    if (FlxG.keys.justPressed.LEFT || FlxG.mouse.justPressed && overlapLeft) {
        animateArrow(leftArrow);
        currentGroupIndex = (currentGroupIndex - 1 + galleryGroups.length) % galleryGroups.length;
        loadGalleryGroup(galleryGroups[currentGroupIndex]);
    }

    if(!overlapRight && !overlapLeft) {
        for (i in 0...gallerySprites.length) {
            var spr = gallerySprites[i];
            var base = baseScales[i];
            var targetScale = base;

            if (spr.overlapsPoint(mouse, true, FlxG.camera)) {
                targetScale = base * ((spr.frameWidth * base + 20) / (spr.frameWidth * base));
                if (FlxG.mouse.justPressed) {
                    showPreview(i);
                }
            }

            FlxTween.tween(spr.scale, { x: targetScale, y: targetScale }, 0.1,
                { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        }
    }

    if (controls.BACK) {
        if (!FlxG.sound.music.playing) {
            FlxG.sound.music.resume();
        }
        FlxG.switchState(new ModState("gallery/GalleryState"));
    }
}

function showPreview(index:Int):Void {
    if (!canSelect) return;
    canSelect = false;

    if (previewVideo != null) {
        remove(previewVideo);
        previewVideo.destroy();
        previewVideo = null;
        videoPlaying = false;
    }

    var pathWithExt = imagePathsWithExt[index];
    var pathNoExt = imagePathsNoExt[index];

    if (pathNoExt.indexOf("cutscenes/") != -1) {
        var videoName = Paths.video(Path.withoutExtension(StringTools.replace(pathWithExt, "_thumb", "")));
        trace(pathWithExt, videoName);

        if (FlxG.sound.music != null && FlxG.sound.music.playing)
            FlxG.sound.music.pause();

        previewVideo = new FlxVideoSprite(previewFrame.x + 10, 10);
        previewVideo.antialiasing = Options.antialiasing;
        previewVideo.scrollFactor.set(0, 0);
        previewVideo.visible = false;
        add(previewVideo);

        previewVideo.load(videoName);

        previewVideo.bitmap.onFormatSetup.add(function():Void {
            var w = previewVideo.bitmap.bitmapData.width;
            var h = previewVideo.bitmap.bitmapData.height;
            var maxW = 500;
            var maxH = FlxG.height - 100;
            var scale = Math.min(maxW / w, maxH / h, 1);
            if (w * scale < 150 || h * scale < 150) scale *= 2;
            scale = Math.min(scale, 4);

            previewVideo.setGraphicSize(Std.int(w * scale), Std.int(h * scale));
            previewVideo.updateHitbox();

            previewVideo.x = previewFrame.x + (previewFrame.width - previewVideo.width) / 2;
            previewVideo.y = (FlxG.height - previewVideo.height) / 2;

            videoPlaying = true;
            previewVideo.visible = true;
        });


        previewVideo.bitmap.onEndReached.add(function() {
            previewVideo.stop();
            previewVideo.visible = false;
            videoPlaying = false;
            if (FlxG.sound.music != null) {
                FlxG.sound.music.resume();
            }
        });

        previewImage.visible = false;
        var path = pathWithExt;
        var p = new Path(path);
        var fname = p.file;

        var suff = "_thumb";
        if (fname.lastIndexOf(suff) == fname.length - suff.length) {
            fname = fname.substr(0, fname.length - suff.length);
        }

        previewText.text = fname + ".mp4";
        previewText.alpha = 0;

        FlxTween.tween(previewText, { alpha: 1 }, 0.6, { ease: FlxEase.quadOut });
        new FlxTimer().start(0.001, function(_){ previewVideo.play(); });

    } else {
        if (FlxG.sound.music != null) {
            FlxG.sound.music.resume();
        }
        previewImage.visible = true;
        previewImage.loadGraphic(Paths.image(pathNoExt, null, false, "jpg"));
        var scale = previewImage.width > previewImage.height ? previewImage.width : previewImage.height;
        scale = (previewImage.width > previewImage.height ? 500 : 480) / scale;
        previewImage.antialiasing = Options.antialiasing;
        trace(scale);
        previewImage.scale.set(scale, scale);
        previewImage.updateHitbox();
        var targetX = FlxG.width * .75 - previewImage.width / 2;
        var targetY = FlxG.height * .5 - (previewImage.height / 2);
        previewImage.x = previewFrame.x + 150 + 20;
        previewImage.y = targetY;
        FlxTween.tween(previewImage, { x: targetX }, 0.6,
            { ease: FlxEase.backOut, type: FlxTween.ONESHOT });

        previewText.text = pathWithExt;
        previewText.alpha = 0;
        FlxTween.tween(previewText, { alpha: 1 }, 0.6,
            { ease: FlxEase.quadOut, type: FlxTween.ONESHOT });
    }

    new FlxTimer().start(0.6, function(_:FlxTimer) {
        canSelect = true;
    });
}

function animateArrow(sprite:FlxText):Void {
    FlxTween.cancelTweensOf(sprite);
    sprite.scale.set(1, 1);
    FlxG.sound.play(Paths.sound("menu/scroll"), 1);

    FlxTween.tween(sprite.scale, { x:1.2, y:1.2 }, 0.1, {
        type: FlxTweenType.PINGPONG,
        ease: FlxEase.quadOut,
        onComplete: function(tween:FlxTween):Void {
            if (tween.executions >= 2) tween.cancel(); sprite.scale.set(1, 1);
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