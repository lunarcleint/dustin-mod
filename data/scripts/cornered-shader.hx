//

public var snowShader:CustomShader;
public var particleSprite:FunkinSprite;
public var snowShader2:CustomShader;

public var snowScript:TemplateClass = scriptObject(__script__);

var initIndex:Int = null;
var snowRect:Array<Float> = [1000, 1220, 1500, 100];
var isOn:Bool = false; 

function postCreate() {
    if(!Options.gameplayShaders) {
        disableScript();
        return;
    }

    for (i in 0...2) {
        var newShader:CustomShader = new CustomShader("blue");
        newShader.cameraZoom = FlxG.camera.zoom; newShader.flipY = true;
        newShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
        newShader.time = 0; newShader.res = [FlxG.width, FlxG.height];
        newShader.LAYERS = i == 0 ? 5 : 4;
        newShader.DEPTH = 1;
        newShader.WIDTH = .1;
        newShader.SPEED = .6;
        newShader.STARTING_LAYERS = i == 0 ? 3 : 1;
        newShader.snowMeltRect = snowRect;
        newShader.snowMelts = true;

        if (i == 0) snowShader = newShader;
        else snowShader2 = newShader;
    }

    particleSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0x00FFFFFF);
    particleSprite.scrollFactor.set(0, 0);
    particleSprite.zoomFactor = 0;
    particleSprite.visible = false; // hide until activated
    particleSprite.alpha = 0; // safety

    if (initIndex != null) insert(initIndex, particleSprite);
    else add(particleSprite);

    // if (Options.gameplayShaders && FlxG.save.data.particles) particleSprite.shader = snowShader;
    // if (Options.gameplayShaders && FlxG.save.data.particles) FlxG.camera.addShader(snowShader2);

    isOn = false;
}


public var snowSpeed:Float = 1;
var tottalTimer:Float = FlxG.random.float(10, 100);


function update(elapsed:Float) {
   if (!isOn) return; // skip update if disabled

    tottalTimer += elapsed * snowSpeed;
    for (shader in [snowShader, snowShader2]) {
        shader.time = tottalTimer * 0.5;
        shader.cameraZoom = FlxG.camera.zoom;
        shader.cameraPosition = [FlxG.camera.scroll.x * 0.5, FlxG.camera.scroll.y * 0.5];
    }
}

function enableSnow() {
    if (isOn) return; // prevent double activation
    isOn = true;

    particleSprite.visible = true;
    particleSprite.alpha = 1;

    if (Options.gameplayShaders && FlxG.save.data.particles) {
        particleSprite.shader = snowShader;
        FlxG.camera.addShader(snowShader2);
    }
}


var last:Bool = true;
function onEvent(event) {
    if(event.event.name != "Screen Coverer" || event.event.params[6] != "camGame") return;

    if (event.event.params[2] != 0) {
        if(!last) return;
        last = false;
        FlxG.camera.removeShader(snowShader2);
    } else if(!last) {
        last = true;
        if (Options.gameplayShaders && FlxG.save.data.particles && isOn) FlxG.camera.addShader(snowShader2);
    }
}