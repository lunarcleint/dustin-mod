//
public var backCam:FlxCamera;
public var blooming:CustomShader = null;
public var water:CustomShader = null;
var redShader:CustomShader = null;
var pixel:CustomShader;

var bloomingTween:FlxTween = null;
var curblooming:Float = 1;
var bgBeat:Bool = false;

var bloomToBeat = 4;

function create() {
    blooming = new CustomShader("bloom");
    blooming.size = 0;
    blooming.brightness = 1;
    blooming.directions = 8;
    blooming.quality = 4;

    water = new CustomShader("waterDistortion");
    water.strength = 0;

    pixel = new CustomShader("pixel");
    pixel.blockSize = 0.001;
    pixel.res = [FlxG.width, FlxG.height];

    tape_noise = new CustomShader("static");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 0;
    

    backCam = new FlxCamera(0, 0, 1280, 720);
    backCam.bgColor = 0x00000000;

    redShader = new CustomShader("rederShader");

    if (Options.gameplayShaders) {
        if (FlxG.save.data.bloom) backCam.addShader(blooming);
        if (FlxG.save.data.water) backCam.addShader(water);
        if (FlxG.save.data.pixel) backCam.addShader(pixel);
        if (FlxG.save.data.static) backCam.addShader(tape_noise);

        boyfriend.shader = redShader;
    }


    FlxG.cameras.remove(camGame, false);
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(backCam, false);
    FlxG.cameras.add(camGame, true);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.add(camHUD2, false);

    BG.camera = backCam;
    boyfriend.colorTransform.color = FlxColor.RED;
}

function postCreate() {
    camGame.bgColor = 0x00000000;

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    autoTitleCard = false;

    BG.visible = false;
    FG.visible = false;
    dad.visible = false;
    dustiniconP2.visible = false;

    bg_psycho.camera = backCam;

    bg_psycho.visible = false;
    road_5.visible = false;
    road_4.visible = false;
    road_3.visible = false;
    road_2.visible = false;
    road_1.visible = false;
}

function stepHit(step:Int) {
    switch (step) {
        case 142:
            FlxG.camera.shake(0.01, 0.2);
            if (Options.gameplayShaders) boyfriend.shader = null;
            boyfriend.colorTransform.redOffset = 0;
            boyfriend.colorTransform.blueOffset = 0;
            boyfriend.colorTransform.greenOffset = 0;
            boyfriend.color = FlxColor.BLACK;
            backCam.bgColor = 0xFFFF0000;

        case 392:
            if (Options.gameplayShaders) boyfriend.color = 0xFFFFFFFF;
            else boyfriend.color = FlxColor.WHITE;
            BG.visible = true;
            FG.visible = true;
            dad.visible = true;
            dustiniconP2.visible = true;
            showTitleCard();

        case 520:
            bgBeat = true;

        case 646:
            BG.visible = false;

        case 898:
            BG.visible = true;

        case 1024:
            bgBeat = false;
            BG.visible = false;
            FG.visible = false;
            if (Options.gameplayShaders) {
                boyfriend.shader = redShader;
                dad.shader = redShader;
            } else {
                boyfriend.colorTransform.color = FlxColor.RED;
                dad.colorTransform.color = FlxColor.RED;
            }
            backCam.bgColor = 0xFF000000;
            blooming.size = 0;
            blooming.brightness = 1;

        case 1119:

            dad.colorTransform.redOffset = 0;
            dad.colorTransform.blueOffset = 0;
            dad.colorTransform.greenOffset = 0;
            dad.color = FlxColor.WHITE;

            boyfriend.colorTransform.redOffset = 0;
            boyfriend.colorTransform.blueOffset = 0;
            boyfriend.colorTransform.greenOffset = 0;
            boyfriend.color = FlxColor.WHITE;

            bg_psycho.visible = true;
            bg_psycho.alpha = 0.5;
            road_5.visible = true;
            road_4.visible = true;
            road_3.visible = true;
            road_2.visible = true;
            road_1.visible = true;

            BG.visible = false;
            FG.visible = false;

            water.strength = 8;

        case 1263:
            bg_psycho.alpha = 1;

            water.strength = 8;
            bgBeat = true;
            bloomToBeat = 20;
            bg_psycho.color = 0xFFFF0000;

        case 1519:
            bgBeat = false;
            blooming.size = 0;
            blooming.brightness = 1;
            bg_psycho.color = 0xFFFFFFFF;

        case 1647:
            bgBeat = true;
            bloomToBeat = 4;
            bg_psycho.color = 0xFFFF0000;
            // each 2 beats the bg beat

        case 1711:
            bloomToBeat = 20;

        case 1716:
            bgBeat = false;

        case 1775:
            bgBeat = true;
            bloomToBeat = 10;
            pixel.blockSize = 10;
            tape_noise.strength = 3;

        case 2175:
            bgBeat = false;

            pixel.blockSize = 0;
            tape_noise.strength = 0;
            backCam.bgColor = 0xFF000000;

            BG.visible = false;
            FG.visible = false;
            boyfriend.visible = false;


            bg_psycho.visible = false;
            road_5.visible = false;
            road_4.visible = false;
            road_3.visible = false;
            road_2.visible = false;
            road_1.visible = false;
            dustiniconP2.visible = false;

        case 2431:
            bg_psycho.visible = true;
            bg_psycho.color = 0xFFFF0000;
            bgBeat = true;
            bloomToBeat = 30;
            pixel.blockSize = 10;
            tape_noise.strength = 10;
            boyfriend.visible = true;

            
            backCam.bgColor = 0xFFFF0000;

            bg_psycho.scale.set(6, 6);
            bg_psycho.x = -900;
            bg_psycho.updateHitbox();
            dustiniconP2.visible = true;

        case 2432:
            boyfriend.color = 0xFF000000;
            dad.color = 0xFF000000;


        }

       
}

var tottalTimer:Float = FlxG.random.float(100, 1000);
var iTime:Float = 0;
function update(elapsed:Float) {
    tape_noise.time += elapsed;
    water?.time = (tottalTimer += elapsed);

    backCam.zoom = camGame.zoom;
    backCam.angle = camGame.angle;
    backCam.target = camGame.target;
    backCam.followLerp = camGame.followLerp;
    backCam.deadzone = camGame.deadzone;
}

function beatHit(curBeat:Int) {
    if (bgBeat) {
        var beatInterval:Int = 1;

        if (curBeat >= 1647 && curBeat < 1716) 
            beatInterval = 2;

        if (curBeat % beatInterval == 0) {
            if (bloomingTween != null) bloomingTween.cancel();

            setblooming(bloomToBeat);

            bloomingTween = FlxTween.num(bloomToBeat, 1, 0.5, {ease: FlxEase.quadOut}, function(val:Float) {
                setblooming(val);
            });
        }
    }
}




function setblooming(blooming_effect:Float) {
    blooming.size = Math.max(blooming_effect - 1, 0) * 4.5;
    blooming.brightness = Math.max(blooming_effect, 1);
    curblooming = blooming_effect;
}
