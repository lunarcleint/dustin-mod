//
import funkin.game.cutscenes.VideoCutscene;

menuType = "default";
var name:String = null;
var script;

function onOpenSubState(e) if (e.substate is VideoCutscene) {
    e.cancelled = true;
    subState = null;

    FULL_VOLUME = true;

    script = importScript("data/scripts/skippableVideoUndertale");
    dustCall = e.substate.__callback;
    name = e.substate.path;
    script.call("startVideo", [name, finishDustin]);
    // preload pause music
    var snd = FlxG.sound.play(Paths.music(Flags.DEFAULT_PAUSE_MENU_MUSIC));
    snd.volume = 0; snd.destroy(); snd = null;
}

function finishDustin() {
    script.destroy();

    if (dustCall != null) {
        dustCall();
        // Camera is normally frozen during storymode cutscenes and usually lets you see outside the background when finishing.
        // This fixes that.
        moveCamera();
        camera.snapToTarget();
        // meant to not look so stiff, plus fnf usually starts off like this lol - higg
        camera.scroll.x -= 100;
        camera.scroll.y -= 150;
    }

    if (name == "assets/videos/the-uprising-end-cutscene.mp4")
        FlxG.switchState(new ModState("EndingCredits", "genocide"));

    else if (name == "assets/videos/you-are-end-cutscene.mp4")
        FlxG.switchState(new ModState("EndingCredits", "pacifist"));
}