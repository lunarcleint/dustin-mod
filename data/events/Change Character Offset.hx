//
import funkin.editors.charter.Charter;

var characterTweens:Map<Int, Array<FlxTween>> = [];
var nullCheck:Array<Event> = [];

function create() {
    for (event in PlayState.SONG.events) {
		if (event.name != "Change Character Offset" || event.time > 0) continue;
            if (event.params[1] == null)
                continue;
            var params:Array = event.params;
            var flxease:String = params[5] + (params[5] == "linear" ? "" : params[6]);

            var character:Character = strumLines.members[params[1]].characters[0];
            if (params[0] && !(PlayState.chartingMode && Charter.startHere && event.time < Charter.startTime)) {
                if (characterTweens[params[1]] != null)
                    for (tween in characterTweens[params[1]])
                        if (tween != null) tween.cancel();

                characterTweens[params[1]] = [
                    FlxTween.num(character.cameraOffset.x, character.cameraOffset.x + params[2], ((Conductor.crochet / 4) / 1000) * params[4], 
                        {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {character.cameraOffset.x = val;}),
                    FlxTween.num(character.cameraOffset.y, character.cameraOffset.y + params[3], ((Conductor.crochet / 4) / 1000) * params[4], 
                    {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {character.cameraOffset.y = val;})
                ];
            } else {
                character.cameraOffset.x += params[2]; character.cameraOffset.y += params[3];
            }
    }
}

function onEvent(eventEvent) {
    if (eventEvent.event.name == "Change Character Offset") {
        trace(nullCheck.contains(eventEvent.event.params[1]));
        if (eventEvent.event.time <= 0 && !nullCheck.contains(eventEvent.event.params[1]))
            return;
        var params:Array = eventEvent.event.params;
        var flxease:String = params[5] + (params[5] == "linear" ? "" : params[6]);

        var character:Character = strumLines.members[params[1]].characters[0];
        if (params[0] && !(PlayState.chartingMode && Charter.startHere && eventEvent.event.time < Charter.startTime)) {
            if (characterTweens[params[1]] != null)
                for (tween in characterTweens[params[1]])
                    if (tween != null) tween.cancel();

            characterTweens[params[1]] = [
                FlxTween.num(character.cameraOffset.x, character.cameraOffset.x + params[2], ((Conductor.crochet / 4) / 1000) * params[4], 
                    {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {character.cameraOffset.x = val;}),
                FlxTween.num(character.cameraOffset.y, character.cameraOffset.y + params[3], ((Conductor.crochet / 4) / 1000) * params[4], 
                {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {character.cameraOffset.y = val;})
            ];
        } else {
            character.cameraOffset.x += params[2]; character.cameraOffset.y += params[3];
        }
    }
}