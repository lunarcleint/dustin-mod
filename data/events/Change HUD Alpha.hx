//
import funkin.editors.charter.Charter;

var hudTween:FlxTween;
var hudAlpha:Float = 1;

function onEvent(eventEvent) {
    var params:Array = eventEvent.event.params;
    if (eventEvent.event.name == "Change HUD Alpha") {
        if (params[0] == false || (PlayState.chartingMode && Charter.startHere && eventEvent.event.time < Charter.startTime)) {
            for (element in hudElements) {
                FlxTween.cancelTweensOf(element);
                element.alpha = params[1];
            }
            hudAlpha = params[1];
        } else {
            if (hudTween != null) hudTween.cancel();

            for (element in hudElements) 
                element.health = element.alpha;

            var flxease:String = params[3] + (params[3] == "linear" ? "" : params[4]);
            hudTween = FlxTween.num(0, 1, ((Conductor.crochet / 4) / 1000) * params[2], {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {
                for (element in hudElements) {
                    FlxTween.cancelTweensOf(element);
                    element.alpha = FlxMath.lerp(element.health, params[1], val);
                }
                hudAlpha = FlxMath.lerp(hudAlpha, params[1], val);
            });
        }
    }
}