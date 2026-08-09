//
importScript("data/scripts/snowing-shader");
import openfl.Lib;
import openfl.filters.ShaderFilter;

public var blackOverlay:FlxSprite;

public var fogShader:CustomShader;
public var gradientShader:CustomShader;
public var camCharacters:FlxCamera;
public var camForeground:FlxCamera;

public var chromWarp:CustomShader;
public var water:CustomShader;
public var glitching:CustomShader;

public var impact:CustomShader;

public var bloom_new:CustomShader;
public var screenVignette2:CustomShader;

function create() {
    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 10; bloom_new.brightness = 1.4;
    bloom_new.directions = 16; bloom_new.quality = 3;
    bloom_new.threshold = .5;

    fogShader = new CustomShader("fog");
    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    fogShader.res = [FlxG.width, FlxG.height]; fogShader.time = 0;

    fogShader.FOG_COLOR = [166./255., 185./255., 189./255.]; fogShader.BG = [0.0, 0.0, 0.0];
    fogShader.ZOOM = 3.0; fogShader.OCTAVES = 4; fogShader.FEATHER = 100;
    fogShader.INTENSITY = 1;

    fogShader.applyY = 1520;
    fogShader.applyRange = 900;

    gradientShader = new CustomShader("gradient");
    gradientShader.cameraZoom = FlxG.camera.zoom;
    gradientShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    gradientShader.res = [FlxG.width, FlxG.height];

    gradientShader.applyY = 1520;
    gradientShader.applyRange = 1000;

    camCharacters = new FlxCamera(0, 0);
    camForeground = new FlxCamera(0, 0);

    for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
    for (cam in [camGame, camCharacters, camForeground, camHUD, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    screenVignette2 = new CustomShader("coloredVignette");
    screenVignette2.strength = 1.0; screenVignette2.transperency = true;
    screenVignette2.amount = 1;
    screenVignette2.color = [0.0, 0.0, 0.0];

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = .3;

    water = new CustomShader("waterDistortion");
    water.strength = .0;

    impact = new CustomShader("impact_frames");
    impact.threshold = -1;
    // impact.threshold = .4;

    glitching = new CustomShader("glitching2");
    glitching.time = 0; glitching.glitchAmount = 0;


    if (Options.gameplayShaders) {

        if (FlxG.save.data.impact) camCharacters.addShader(impact);
        if (FlxG.save.data.glitch) camCharacters.addShader(glitching);

        camCharacters.addShader(screenVignette2);

        if (FlxG.save.data.bloom)
            camCharacters.addShader(bloom_new);

        camCharacters.addShader(gradientShader);

        if (FlxG.save.data.saturation) {
            camCharacters.addShader(saturation);
            camForeground.addShader(saturation);
        }

        if (FlxG.save.data.fog) camCharacters.addShader(fogShader);

        if (FlxG.save.data.bloom)
            camForeground.addShader(bloom);

        if (FlxG.save.data.water) camGame.addShader(water);
        if (FlxG.save.data.chromwarp) camGame.addShader(chromWarp);
    }

    stage.stageSprites["BG4"].cameras = [camForeground];
    stage.stageSprites["BG4"].color = 0xFF1B1B1B;

    blackOverlay = new FlxSprite(-2000, -500);
    blackOverlay.makeSolid(4000, 1500, 0xFF1B1B1B);
    blackOverlay.scrollFactor.set(0, 0);
    blackOverlay.alpha = 1;
    blackOverlay.cameras = [camGame];
    add(blackOverlay); 

    snowSpeed = 7;
}

function onCountdown(event) event.sprite?.cameras = [camCharacters];

function postCreate() {
    if (Options.gameplayShaders) {
        if (FlxG.save.data.particles) {
            camGame.addShader(snowShader);
            camCharacters.addShader(snowShader2);
        }

        if (FlxG.save.data.water) camHUD.addShader(water);
    }
}

var __timer:Float = 0; 
public var gfAlpha:Float = 0;
public var monitorY:Float = 0;
var prev_monitorY:Float = 0;
var prev_monitorX:Float = 0;

public var monitorX:Float = 0;
function update(elapsed:Float) {
    __timer += elapsed;
    if (!cancelCamMove) {
        fogShader.time = __timer;
        water.time = __timer;
        glitching.time = __timer;
    }

    if (shaketime > 0) {
        var xMod:Float = FlxG.random.float(-1, 1);
        var yMod:Float = FlxG.random.float(-1, 1);

        for (cam in [camGame, camCharacters, camHUD,camHUD2]) {
            cam.scroll.x += xMod; cam.scroll.y += yMod;
        }

        shaketime -= elapsed;
    }

    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];

    gradientShader.cameraZoom = FlxG.camera.zoom;
    gradientShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];

    gf.x = 1397 + Math.sin(__timer)*24;
    gf.y = 850 + (Math.sin(__timer*2)/2)*(12);

    gf.alpha = (0.7 + Math.sin(__timer)*.04)*gfAlpha;

    for (strum in strumLines)
        for (char in strum.characters)
            char.cameras = [camCharacters];
}

function postUpdate(elapsed)
    DustinUtil.copyCameras(FlxG.camera, [camCharacters, camForeground]);

public var cancelCamMove:Bool = false;
function onCameraMove(camMoveEvent) {
    if (cancelCamMove) camMoveEvent.cancel();
}

var shakeWindow:Bool = false;
public var shaketime:Float = 0;
public function epicimpact() {
    if (!Options.gameplayShaders) return;
    for (cam in FlxG.cameras.list) cam.visible = false;
    new FlxTimer().start(0.06, () -> {
        shaketime = .26; cancelCamMove = true; lerpCamZoom = false; gfAlpha = 0; 

        for (cam in FlxG.cameras.list) cam.visible = true;
        camGame.visible = false;

        chromWarp.distortion = 0; impact.threshold = .1; glitching.glitchAmount = 3;
        executeEvent({name: "ScreenCoverer", time: 0, params: [false, 0xFF000000, 0.1, 4, "quad", "Out", "camHUD", "back"]});

        new FlxTimer().start(0.08, () -> {
            cancelCamMove = false; lerpCamZoom = true; gfAlpha = .7;
            camGame.visible = true;

            impact.threshold = -1; chromWarp.distortion = .13;

            executeEvent({name: "Bloom Effect", time: 0, params: [false, 1.3, 4, "linear", "In"]});
            executeEvent({name: "Bloom Effect", time: 0, params: [true, 1, 2, "quad", "Out"]});

            FlxTween.num(1, 0, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.cubeIn}, (val:Float) -> {glitching.glitchAmount = val;});

            FlxTween.num(1.8, .6, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
            FlxTween.num(10, 50, ((Conductor.stepCrochet / 1000) * 6), {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});
        });
    });
}

function onSongEnd() {
    monitorX = monitorY = 0;
}