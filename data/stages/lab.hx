//
public var dust:CustomShader;
public var oldstatic:CustomShader;

public var shadows:Dynamic = {
    boyfriend: null,
    dad: null,
    dt: null
};

public var eyeItensity:Float = 0;
public var updateDTLights:Bool = true;

var lightBloom:CustomShader;

function postCreate() {
    bg_start.alpha = 0;
    gf.alpha = 0;

    dad.alpha = 0;
    boyfriend.alpha = 0;

    dtEyes.onDraw = (spr) -> {
        spr.draw();
        if (eyeItensity == 0)
            return;
        var a:Float = spr.alpha;
        spr.color = FlxColor.RED;
        spr.blend = 0;
        spr.alpha = a * eyeItensity;
        spr.draw();
        spr.alpha *= 0.5;
        spr.draw();
        spr.color = FlxColor.WHITE;
        spr.blend = 10;
        spr.alpha = a;

    }

    dust = new CustomShader("lab_dust");
    dust.cameraZoom = FlxG.camera.zoom; dust.flipY = true;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    dust.time = 0; dust.res = [FlxG.width, FlxG.height];
    dust.LAYERS = 10; dust.DEPTH = 2;
    dust.WIDTH = .08; dust.SPEED = .5;
    dust.STARTING_LAYERS = 4;
    dust.pixely = false;
    dust.BRIGHT = 1;

    dust.dustFade = boyfriend.y;
    dust.dustRange = 1800;

    oldstatic = new CustomShader("static");
    oldstatic.time = 0; oldstatic.strength = 1.3;
    if (Options.gameplayShaders) {
        if (FlxG.save.data.particles) FlxG.camera.addShader(dust);
        if (FlxG.save.data.static) FlxG.camera.addShader(oldstatic);
    }

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    autoTitleCard = false;

    importScript('data/scripts/dropshadow-effect');

    shadows.dt = setupShader(dt);
    shadows.dt.curZoom = 0;

    shadows.dad = setupShader(dad);
    shadows.boyfriend = setupShader(boyfriend);
    shadows.boyfriend.angle = 123;
	shadows.boyfriend.threshold = 0.05; // the brightness for your drop shadow
    if (!Options.gameplayShaders) {
        boyfriend.shader = null;
        dad.shader = null;
        dad.color = FlxColor.BLACK;
        boyfriend.color = FlxColor.BLACK;
    }

    if(Options.gameplayShaders && FlxG.save.data.bloom) {
        lightBloom = new CustomShader("bloom");
        lightBloom.size = 0;
        lightBloom.brightness = 5;
        lightBloom.directions = 8;
        lightBloom.quality = 10;
    }

    floorLights.shader = lightBloom;

    // would've hit harder if we had more blend modes to work with

    lowerGLOW.blend = 9;
    g_OVER.blend = 14;
    
    g_OVER2.blend = 14;
    dtOVER.blend = 9;

    drakOVER.blend = 9;
}

function setupShader(char) {
    // put the sprite you want to assign the shader to in this param
	// it will automatically handle the shader assigning.
	// also, by calling `getDropShadow`, it will already assign the variables to its default values.
	var dropShadow = getDropShadow(char);

	dropShadow.setAdjustColor(0, 0, 0, 0); // brightness, hue, contrast, saturation
	dropShadow.color = FlxColor.RED; // the color for your drop shadow
	dropShadow.angle = 65; // the angle for your drop shadow
	dropShadow.distance = 14; // the distance for your drop shadow
	dropShadow.curZoom = 0.75; // the current zoom for your drop shadow
	dropShadow.threshold = 0.15; // the brightness for your drop shadow
	dropShadow.antialiasAmt = 2; // the amount of antialias for your drop shadow
	dropShadow.pixelPerfect = false; // whether the pixels are aligned perfectly
	dropShadow.flipX = false; // whether your drop shadow is flipped horizontally
	dropShadow.flipY = false; // whether your drop shadow is flipped vertically

    return dropShadow;

	//dropShadow.loadAltMask(Paths.image('my_mask')); // loads an alternate mask
	//dropShadow.maskThreshold = 0; // an alternate brightness threshold for your drop shadow
	//dropShadow.useAltMask = true; // whether the alternate mask is being used or not
}

    //FlxTween.tween(boyfriend, {x: boyfriend.x - 700}, 3.7, {ease: FlxEase.quintInOut});
    //FlxTween.tween(boyfriend, {y: boyfriend.y - 500}, 3.7, {ease: FlxEase.quintInOut});


var lightTimer:Float = 0;

function update(elapsed:Float) {
    lightTimer += elapsed * 2.5;

    if (updateDTLights)
        dtLights.alpha = lerp(dtLights.alpha, 0.85 + Math.sin(lightTimer) * 0.15, 0.05);
    shadows.dad.curZoom = 0.75 * dtLights.alpha;
    shadows.boyfriend.curZoom = 0.25 + 0.5 * dtLights.alpha;
    if(Options.gameplayShaders && FlxG.save.data.bloom) {
        floorLights.shader.size = 0.5 * (3 + Math.sin(lightTimer * 0.25));
        floorLights.shader.brightness = 1 + (0.5 * (1 + Math.sin(lightTimer * 0.25)));
    }

    lowerGLOW.alpha = dtLights.alpha * 0.5 * (1 + eyeItensity);

    g_OVER2.alpha = g_OVER2.alpha * 0.5;
    lowerGLOW.alpha = g_OVER2.alpha = 0;

    shadows.boyfriend.shader.charColor = [0, -0.2 * dtOVER.alpha, -0.2 * dtOVER.alpha, -1(1- boyfriend.alpha)];
    shadows.dad.shader.charColor = [0, -0.2 * dtOVER.alpha, -0.2 * dtOVER.alpha, -(1 - dad.alpha)];
    shadows.dt.shader.charColor = [0.05 * dtOVER.alpha, -0.2 * dtOVER.alpha, -0.2 * dtOVER.alpha, -1(1 - dt.alpha)];

    //floorLights.shader.contrast = 1 + 2 * (1 + Math.sin(lightTimer));
    //trace(DT_lights.alpha);
}