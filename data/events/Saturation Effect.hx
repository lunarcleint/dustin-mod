import funkin.editors.charter.Charter;

public var saturation:CustomShader;

function create() {
    if(!Options.gameplayShaders || !FlxG.save.data.saturation) {
        disableScript();
        return;
    }

    saturation = new CustomShader("saturation");
    saturation.sat = 1;
    saturation.contrast = 1;
    FlxG.camera.addShader(saturation);
    camHUD.addShader(saturation);
}

var saturationTween:FlxTween = null;
var curSaturation:Float = 1;

function onEvent(eventEvent) {
    var params:Array = eventEvent.event.params;
    if (eventEvent.event.name == "Saturation Effect") {
        if (params[0] == false || (PlayState.chartingMode && Charter.startHere && eventEvent.event.time < Charter.startTime))
            saturation.sat = curSaturation = params[1];
        else {
            if (saturationTween != null) saturationTween.cancel();
            var flxease:String = params[3] + (params[3] == "linear" ? "" : params[4]);
            var sat = params[1];
            if (FlxG.save.data.antiFlash && sat != 1)
                sat *= 0.5;

            saturationTween = FlxTween.num(curSaturation, params[1], ((Conductor.crochet / 4) / 1000) * params[2], 
            {ease: Reflect.field(FlxEase, flxease)}, (val:Float) -> {saturation.sat = curSaturation = val;});
        }
    }
}