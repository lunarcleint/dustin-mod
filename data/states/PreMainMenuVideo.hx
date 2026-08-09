//
import funkin.backend.MusicBeatState;
import funkin.savedata.FunkinSave;

var script = importScript("data/scripts/skippableVideoUndertale");

function create() script.call("startVideo", ["intro", () -> {
        MusicBeatState.skipTransOut = true;
        MusicBeatState.skipTransIn = true;
        FlxG.switchState(new ModState("NewMainMenu"));
    }, "mp4", false]);

function update() {
    var vid = script.get("vid");
    if (!vid?.antialiasing && vid.bitmap.time > 70000)
        vid.antialiasing = Options.antialiasing;  // making the antialiasing activate after the pixel part ended :)  - Nex
}