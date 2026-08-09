//
public var tvScreen:FlxCamera;
var itslikeprettywarpedtoo:CustomShader = null;
var itslikeprettywarpedtoo2:CustomShader = null;
var strumShiftAmount:Float = -320;
var strumsShifted:Bool = false;
var glitch:CustomShader = null;
var glitchTimer:Float = 0;
var glitchValues:Array<Float> = [0.01, 0.02, 0.04, 0.05];
var isGlitch:Bool = false;
var starthittingthegriddy:Bool = false;

var iTime:Float = 0;
var floatRadius:Float = 20; // circle height
var floatSpeed:Float = 2;  // speed

var baseDadX:Float;
var baseDadY:Float;
var baseBFX:Float;
var baseBFY:Float;
var distorsion_ammount:Float = 0.7;

function create() {
    tvScreen = new FlxCamera(0, 0, 1280, 720);

    FlxG.cameras.remove(camGame, false);
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(tvScreen, false);
    FlxG.cameras.add(camGame, true);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.add(camHUD2, false);

    glitch = new CustomShader("glitching");
    if (Options.gameplayShaders && FlxG.save.data.glitch) dad.shader = glitch;
    

    glitch.AMT = 0;

    isGlitch = true;

    baseDadX = dad.x;
    baseDadY = dad.y;

    baseBFX = boyfriend.x;
    baseBFY = boyfriend.y;

    camGame.bgColor = 0x00FFFFFF;
    tvScreen.bgColor = 0xFFFFFFFF;

    
}

function postCreate() {
    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    autoTitleCard = false;

    for (strum in cpuStrums.members) {
        if (strum != null)
            strum.cameras = [tvScreen];
            strum.alpha = 0.8;
            strum.scrollFactor.set(0.8, 0.8);
    }

    itslikeprettywarpedtoo = new CustomShader("chromaticWarp");
    itslikeprettywarpedtoo2 = new CustomShader("chromaticWarp");

    if (Options.gameplayShaders && FlxG.save.data.chromwarp) {
        camGame.addShader(itslikeprettywarpedtoo);
        tvScreen.addShader(itslikeprettywarpedtoo2);
    }
    itslikeprettywarpedtoo.distortion = 0;
    itslikeprettywarpedtoo2.distortion = 4;
}

var iTime:Float = 0;
function update(elapsed:Float) {
    tvScreen.zoom = camGame.zoom;
    tvScreen.angle = camGame.angle;
    tvScreen.target = camGame.target;
    tvScreen.followLerp = camGame.followLerp;
    tvScreen.deadzone = camGame.deadzone;

    if (Options.gameplayShaders && FlxG.save.data.glitch && isGlitch)
    {
        glitchTimer += elapsed;
        if (glitchTimer >= 0.15) {
            glitchTimer = 0;

            var randIndex = FlxG.random.int(0, glitchValues.length - 1);
            glitch.AMT = glitchValues[randIndex];
        } 

        for (note in cpuStrums.members) {
            if (note != null && !note.mustPress && note.shader == null) {
                note.shader = glitch;
            }
        }
    }

    iTime += elapsed;

    var floatX = Math.cos(iTime * floatSpeed) * floatRadius;
    var floatY = Math.sin(iTime * floatSpeed) * floatRadius;

    dad.x = baseDadX + floatX;     
    dad.y = baseDadY + floatY;

    boyfriend.x = baseBFX - floatX;
    boyfriend.y = baseBFY + floatY;

}

function onGameOver() {
    tvScreen.bgColor = 0x00FFFFFF;
}

function stepHit(step:Int) {
    switch (step) {
        case 8:
            //glitchValues = [0.2, 0.5, 0.7, 1];
            for (strum in cpuStrums.members) {
                if (strum != null)
                    strum.y = FlxG.height + 800;
                    strum.x -= 400;

                    strum.angle = -195;

                    if (camHUD.downscroll) {
                        strum.y = FlxG.height + 800;
                    }

            }

            tvScreen.bgColor = 0xFF000000;

            stage.getSprite("parte-trasera").visible = false;
            stage.getSprite("parte-delantera").visible = false;

            dad.visible = false;

        case 128:
            tvScreen.bgColor = 0xFFFFFFFF;

            stage.getSprite("parte-trasera").visible = true;
            stage.getSprite("parte-delantera").visible = true;

            dad.visible = true;

        case 416:
            starthittingthegriddy = true;

        case 664:
            starthittingthegriddy = false;
            itslikeprettywarpedtoo.distortion = 0;

        case 672:
            starthittingthegriddy = false;
            itslikeprettywarpedtoo.distortion = 30;
            itslikeprettywarpedtoo2.distortion = 10;

        case 928:
            itslikeprettywarpedtoo.distortion = 0;
            itslikeprettywarpedtoo2.distortion = 5;
            starthittingthegriddy = true;

        case 1048:
            starthittingthegriddy = false;
            itslikeprettywarpedtoo.distortion = 0;

        case 1072:
            starthittingthegriddy = false;
            itslikeprettywarpedtoo.distortion = 0;
            
        case 1088:
            glitchValues = [0.2, 0.5, 0.7, 1];
            itslikeprettywarpedtoo2.distortion = 20;
            starthittingthegriddy = true;

        case 1464:
            itslikeprettywarpedtoo2.distortion = 0;
            starthittingthegriddy = false;

            

        case 1472:
            tvScreen.bgColor = 0xFF000000;

            stage.getSprite("parte-trasera").visible = false;
            stage.getSprite("parte-delantera").visible = false;

            dad.visible = false;

            shiftStrums();

            for (strum in cpuStrums.members) {
                if (strum != null)
                    strum.alpha = 0;
                    
            }

        case 1728:
            tvScreen.bgColor = 0xFFFFFFFF;

            glitchValues = [0.5, 1, 1.5, 2];
            stage.getSprite("parte-trasera").visible = true;
            stage.getSprite("parte-delantera").visible = true;

            dad.visible = true;

            itslikeprettywarpedtoo2.distortion = 20;

            starthittingthegriddy = true;
            distorsion_ammount = 1;

            shiftStrums();

            for (strum in cpuStrums.members) {
                if (strum != null)
                    strum.alpha = 1;

            }

        case 2256:
            starthittingthegriddy = false;
            

        case 912:
            FlxTween.num(30, 1, 50, {
            ease: FlxEase.quadOut}, 
            function(val:Float) {
                itslikeprettywarpedtoo.distortion = val;}

        );
    }
}

function shiftStrums():Void {
    var shift = strumsShifted ? -strumShiftAmount : strumShiftAmount;
    var tweenTime = 1;
    var tweensLeft = 0;


    for (strumLine in strumLines) {
        for (sprite in strumLine.members) {
            if (sprite != null) {
                tweensLeft++;
                FlxTween.tween(sprite, {x: sprite.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }

        for (note in strumLine.notes) {
            if (note != null) {
                tweensLeft++;
                FlxTween.tween(note, {x: note.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }
    }


    strumsShifted = !strumsShifted;
}


function beatHit() {
    if (Options.gameplayShaders && itslikeprettywarpedtoo != null && starthittingthegriddy) {
        itslikeprettywarpedtoo.distortion = distorsion_ammount;

        FlxTween.num(distorsion_ammount, 0, 0.5, {
            ease: FlxEase.quadOut}, 
            function(val:Float) {
                itslikeprettywarpedtoo.distortion = val;}

        );
    }
}
