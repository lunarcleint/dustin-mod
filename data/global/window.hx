//

import funkin.backend.system.Main;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.FlxObject;
import openfl.filters.ShaderFilter;
import openfl.Lib;

static var FNF_RESOLUTION:{width:Float, height:Float} = {width: 1280, height: 720};
static var UT_RESOLUTION:{width:Float, height:Float} = {width: 640, height: 480};
static var OW_RESOLUTION:{width:Float, height:Float} = {width: 1280/2, height: 720/2};

static var __resizedTo:Int = 0;  // 0 fnf, 1 undertale, 2 overworld  - Nex
static var __utScaleMode:RatioScaleMode = new RatioScaleMode();

static var __oldFNFFramerate:Float = FlxG.updateFramerate;
static var UT_FRAMERATE:Int = 30;

static function __undertaleFrameRate() {
    if (FlxG.updateFramerate == UT_FRAMERATE) return;

    __oldFNFFramerate = FlxG.updateFramerate;
    FlxG.updateFramerate = FlxG.drawFramerate = UT_FRAMERATE;
    FlxG.fixedTimestep = true;
}

static function __fnfFrameRate() {
    if (FlxG.updateFramerate != UT_FRAMERATE) return;
    FlxG.updateFramerate = FlxG.drawFramerate = __oldFNFFramerate;
    FlxG.fixedTimestep = false;
}

static function __fnfResize() {
    if (__resizedTo == 0) return;
    __resizedTo = 0;

    __resizeGame(FNF_RESOLUTION.width, FNF_RESOLUTION.height, 1);
    FlxG.scaleMode = Main.scaleMode;
    Lib.application.window.resizable = true;

    __pixelPerfect(false);
}

static function __undertaleResize() {
    if (__resizedTo == 1) return;
    __resizedTo = 1;

    __resizeGame(UT_RESOLUTION.width, UT_RESOLUTION.height, 2);
    FlxG.scaleMode = __utScaleMode;
    Lib.application.window.resizable = false;

    __pixelPerfect(true);
}

static function __overworldResize() {
    if (__resizedTo == 2) return;
    __resizedTo = 2;

    __resizeGame(OW_RESOLUTION.width, OW_RESOLUTION.height);
    FlxG.scaleMode = __utScaleMode;
    Lib.application.window.resizable = false;

    __pixelPerfect(true);
}

static function __resizeGame(width:Float, height:Float, ?windowScale:Float) {
    Lib.application.window.maximized = false;

    if (windowScale != null) {
        var centerPoint:FlxPoint = __getCenterWindowPoint();
        FlxG.fullscreen = false;
        FlxG.resizeWindow(width * windowScale, height * windowScale);
        __centerWindowOnPoint(centerPoint);
        centerPoint.put();
    }

    FlxG.resizeGame(width, height);
    FlxG.width = width; FlxG.height = height;
    FlxG.initialWidth = width; FlxG.initialHeight = height;

    for (camera in FlxG.cameras.list) {
        camera.width = width;
        camera.height = height;
    }
}

static function __resizeGameNEW(width:Float, height:Float) {
    Main.scaleMode.width = width;
    Main.scaleMode.height = height;

    for (camera in FlxG.cameras.list) {
        camera.width = width;
        camera.height = height;
    }

    FlxG.width = width; FlxG.height = height;
}

static function __pixelPerfect(pixelPerfect:Bool) {
    FlxG.game.stage.quality = pixelPerfect ? 2 /*LOW*/ : 0 /*BEST*/;
    FlxG.forceNoAntialiasing = pixelPerfect ? true : null;

    // Makes every pixel render properly
    FlxG.game.setFilters(pixelPerfect ? [new ShaderFilter(new FlxGraphicsShader())] : []);

    if (pixelPerfect)
        FlxG.cameras.cameraAdded.add(__onCameraAdd);
    else
        FlxG.cameras.cameraAdded.remove(__onCameraAdd);

    for (camera in FlxG.cameras.list) __onCameraAdd(camera);
    FlxObject.defaultPixelPerfectPosition = pixelPerfect;
}

static function __onCameraAdd(camera:FlxCamera)
    if (camera != null) camera.pixelPerfectRender = __resizedTo != 0;

// RECENTER WINDOW
static function __centerWindowOnPoint(?point:FlxPoint) {
    Lib.application.window.x = Std.int(point.x - (Lib.application.window.width / 2));
    Lib.application.window.y = Std.int(point.y - (Lib.application.window.height / 2));
}

static function __getCenterWindowPoint():FlxPoint
    return FlxPoint.get(
        Lib.application.window.x + (Lib.application.window.width / 2),
        Lib.application.window.y + (Lib.application.window.height / 2)
    );