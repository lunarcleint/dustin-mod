// IM GOING MENTALLY INSANE I DIDNT KNOW THIS WOULD BE SO FUCKING EASY TO CODE BYE  - NEX
import lime.ui.Window;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.system.Capabilities;
import funkin.backend.system.Main;

#if (linux || macos)  // Alt + Enter is broken on these bruh THANK YOU LIME!!  - Nex
FlxG.fullscreen = false;
#end

var actualFullscreen = FlxG.fullscreen;
var fullscreen = #if desktop !FlxG.save.data.gSwag || actualFullscreen #else true #end;
var canGo:Bool = false;
var app:Window = null;
var tottalTimer:Float = FlxG.random.float(100, 1000);
var NYEHEHE = new Bitmap(BitmapData.fromBytes(Assets.getBytes(Paths.image("game/cutscenes/genocides/SWAG"))));

function postCreate() {
    if (fullscreen) {
        NYEHEHE.width = Lib.application.window.width;
        NYEHEHE.height = Lib.application.window.height;
        NYEHEHE.alpha = 0;
        Main.instance.addChild(NYEHEHE);
    } else new FlxTimer().start(0.1, () -> {
        app = Lib.application.createWindow({
            title: "DAME TU HUESITO",
            alwaysOnTop: true,
            width: Capabilities.screenResolutionX,  // Capabilities.screenResolutionX/Y can crash on ceratin devices I HATE YOU OPENFL  - Nex
            height: Capabilities.screenResolutionY,
            frameRate: Options.framerate,
            borderless: true,
            //hidden: true
        });

        FlxG.autoPause = false;
        app.onFocusOut.add(() -> /*Lib.application.window?.focus()*/ if (canPause && !paused) pauseGame());
        app.onKeyDown.add((e) -> Lib.application.window?.onKeyDown.dispatch(e));
        app.onKeyUp.add((e) -> Lib.application.window?.onKeyUp.dispatch(e));
        app.onMouseDown.add((e) -> Lib.application.window?.onMouseDown.dispatch(e));
        app.onMouseUp.add((e) -> Lib.application.window?.onMouseUp.dispatch(e));
        app.onMouseMove.add((e) -> Lib.application.window?.onMouseMove.dispatch(e));
        app.onMouseWheel.add((e) -> Lib.application.window?.onMouseWheel.dispatch(e));

        Lib.application.window.onClose.add(shouldClose);
        app.onClose.add(() -> if (!canGo) app.onClose.cancel());

        NYEHEHE.width = app.width;
        NYEHEHE.height = app.height;
        app.stage.addChild(new Sprite().addChild(NYEHEHE));

        app.opacity = 0;
        app.stage.color = FlxColor.BLACK;
    });

    autoTitleCard = false;
    dad.x -= 1000;
}

function update() if (FlxG.fullscreen != actualFullscreen)
    FlxG.fullscreen = actualFullscreen;  // not gonna let you change mid song bitch  - Nex

function onSongStart() {
    dad.playAnim("walk", true);
    FlxTween.tween(dad, {x: dad.x + 1000}, 3.8, {onComplete: () -> dad.dance()});
}

var tween:FlxTween = null;
function onEvent(_) if (_.event.name == "Play Animation" && _.event.params[1] == "swag") {
    if (fullscreen) NYEHEHE.alpha = 1;
    else app?.opacity = 1;

    tween?.cancel();
    tween = !fullscreen && app != null ? FlxTween.tween(app, {opacity: 0}, 0.7) : FlxTween.tween(NYEHEHE, {alpha: 0}, 0.7);
}

function destroy() {
    if (fullscreen) Main.instance.removeChild(NYEHEHE);
    else shouldClose();
    FlxG.autoPause = Options.autoPause;
    NYEHEHE.bitmapData.dispose();
    Lib.application.window.onClose.remove(shouldClose);
}

function shouldClose() {
    canGo = true;
    app?.close();
    Lib.application.window?.focus();
}

function beatHit(beat:Int) {
    if(beat == 304) {
        pauseInfo.isMonster = true;
    }
}