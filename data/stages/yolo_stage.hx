//
import StringTools;

var stageBloom:CustomShader = null;
var stageLerp:Float = 1;
var forcedLights:Int = 0;
public var stageModulo = 1;

function set_stageModulo(mod:String) stageModulo = Std.parseInt(mod);

function postCreate() if (Options.gameplayShaders && FlxG.save.data.bloom) {
    stageBloom = new CustomShader("bloom");
    //for (i in stage.stageSprites.keys()) if (StringTools.startsWith(i, "stage")) stage.getSprite(i).shader = stageBloom;
    stageBloom.size = 1.5;
    stageBloom.brightness = 1;
    stageBloom.directions = 8;
    stageBloom.quality = 6;
}

function update() {
    stageLerp = lerp(stageLerp, 1, FlxG.save.data.antiFlash ? 0.05 : 0.1);

    if (!Options.gameplayShaders && FlxG.save.data.bloom) return;
    stageBloom.brightness = stageLerp;
    stageBloom.size = (FlxG.save.data.antiFlash ? 20 : 40) * stageLerp;
}

function beatHit(curBeat:Int) {
    if (curBeat % stageModulo == 0)
        updateLights(curBeat + forcedLights);
}

function forceLights() {
    forcedLights++;
    updateLights(curBeat + forcedLights);
}

function updateLights(beat:Int) {
    if (FlxG.save.data.antiFlash)
        return;
    for (i in stage.stageSprites.keys()) if (StringTools.startsWith(i, "stage")) {
        stage.getSprite(i).visible = false;
        stage.getSprite(i).shader = null;
    }

    var sprite = stage.getSprite("stage" + (Math.abs(beat) % 4));
    sprite.visible = true;
    if (FlxG.save.data.bloom) sprite.shader = stageBloom;
    stageLerp = FlxG.save.data.antiFlash ? 1.35 : 2;
}