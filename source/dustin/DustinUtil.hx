//
import openfl.Lib;
import Reflect;

 class DustinWindowUtil {

    public static function init():DustinWindowUtil {
        FlxG.signals.postUpdate.add(update);
        FlxG.signals.postStateSwitch.add(reset);
        return DustinWindowUtil;
    }

    public static var x:Float = 0;
    public static var prevX:Float = 0;

    public static var y:Float = 0;
    public static var prevY:Float = 0;

    public static var boundsX:Float = 0.5;
    public static var prevBoundsX:Float = 0.5;

    public static var boundsY:Float = 0.5;
    public static var prevBoundsY:Float = 0.5;

    public static function set(_x:Float, _y:Float) {
        x = _x;
        y = _y;
    }

    public static function setBounds(_x:Float, _y:Float) {
        boundsX = _x;
        boundsY = _y;
    }

    public static function reset() {
        x = y = 0;
        boundsX = boundsY = 0.5;
    }

    public static function windowBounds(mult, winPos, winDimension, winScreen) {
        var pos:Float = mult;

        if (pos == 0.5)
            pos = winPos < 0 ? -winPos : 0;
        else if (pos > 0.5) {

            var exceededWidth:Bool = winPos + winDimension > winScreen;

            pos = exceededWidth ? Math.abs(winDimension - winPos) * 0.1 : (winScreen - winPos - winDimension);
            pos *= Math.min((mult - 0.5) * 2, 1);

            if(mult > 1)
                pos += winDimension * (mult - 1);

        } else if (pos < 0.5) {

            var exceededWidth:Bool = winPos < 0;

            pos = exceededWidth ? Math.abs(winPos * 0.15) : winPos;
            pos *= 1 - Math.max(mult * 2, 0);

            if(mult < 0)
                pos += winDimension * (Math.abs(mult));

            pos *= -1;

        }

        return pos;
    }

    public static function updateWindowPosition() {
        if (window.fullscreen)
            return;
        Lib.application.window.__backend.move(
            Lib.application.window.x + x + DustinWindowUtil.windowBounds(boundsX, Lib.application.window.x, Lib.application.window.width, Lib.current.stage.fullScreenWidth),
            Lib.application.window.y + y + DustinWindowUtil.windowBounds(boundsY, Lib.application.window.y, Lib.application.window.height, Lib.current.stage.fullScreenHeight)
        );
    }

    public static function update() {
        var updateWindow:Bool = false;
        if(prevX != (prevX = FlxMath.roundDecimal(x, 3))) updateWindow = true;
        if(prevY != (prevY = FlxMath.roundDecimal(y, 3))) updateWindow = true;

        if(prevBoundsX != (prevBoundsX = FlxMath.roundDecimal(boundsX, 3))) updateWindow = true;
        if(prevBoundsY != (prevBoundsY = FlxMath.roundDecimal(boundsY, 3))) updateWindow = true;

        if (updateWindow) updateWindowPosition();
    }
 }

class DustinUtil {

    //probably gonna delete this tbh, we'll so it goes as I develop it

    // Camera functions
    public static function copyCamera(origin:FlxCamera, copy:FlxCamera, ?copyShaders:Bool = false, ?excludeShaders:Array<CustomShader> = []) {
        copy.scroll.x = origin.scroll.x;
        copy.scroll.y = origin.scroll.y;
        copy.angle = origin.angle;
        copy.zoom = origin.zoom;
        if(copyShaders) {
            var _filters = origin._filters;
            if(excludeShaders.length == 0) {
                if(copy._filters != origin._filters) origin._filters = copy._filters;
            } else {
                var _filters = origin._filters.filter(item -> !excludeShaders.contains(item));
                if(copy._filters != _filters) copy._filters = _filters;
            }
        }
    }

    public static function copyCameras(origin:FlxCamera, copies:Array<FlxCamera> = [], ?copyShaders:Bool = false, ?excludeShaders:Array<CustomShader> = []) {
        for(cam in copies)
            copyCamera(origin, cam, copyShaders, excludeShaders);
    }

    // Window functions

    public static var window = DustinWindowUtil.init();

}