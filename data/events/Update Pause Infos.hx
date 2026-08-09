//
import funkin.backend.utils.FlxInterpolateColor;

if (PlayState.SONG.meta.customValues == null) {
    disableScript();
    return;
}

function onEvent(eventEvent) {
    var params:Array = eventEvent.event.params;
    if (eventEvent.event.name == "Update Pause Infos") {
        pauseInfo.character.sprite = params[1];
        pauseInfo.stats = StringTools.replace(params[2], "\\n", "\n");

        // basically FlxColor.toWebString but its abstract so i cant use that func directly  - Nex
        var interp = new FlxInterpolateColor(params[0]);
        pauseInfo.mainColor = "#" + StringTools.hex(interp.red * 255, 2) + StringTools.hex(interp.green * 255, 2) + StringTools.hex(interp.blue * 255, 2);

        pauseInfo.character.x = params[3];
        pauseInfo.character.y = params[4];
    }
}