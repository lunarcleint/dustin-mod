//
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.FlxEase;

public var desiredCamAngle:Float = 4;
public var isAngle:Bool = true;
public var isGlitch:Bool = true;
public var isGlitch2:Bool = false;
public var starthittingthegriddy:Bool = false;
public var glitch:CustomShader = null;
public var glitch2:CustomShader = null;
var distortionTween:NumTween;

var alphaTimer:Float = 0;
var fadeInterval:Float = 2.5;
var fadeAmount:Float = 0.1;

var glitchTimer:Float = 0;
var glitchValues:Array<Float> = [0.1, 0.2, 0.3, 0.4];
var glitchValues2:Array<Float> = [0.4, 0.6, 0.8, 1];

public var itslikeprettywarpedtoo:CustomShader = null;

var up:Bool = true;


function create() {
    glitch = new CustomShader("glitching");
    glitch2 = new CustomShader("glitching");
    if (Options.gameplayShaders && FlxG.save.data.glitch) {
        camGame.addShader(glitch);
        camHUD.addShader(glitch2);
    }

    glitch.AMT = 0;
    glitch2.AMT = 0;

    cinematic_bars_vin.camera = camHUD;
}



function postCreate() {
    desiredCamAngle = 4;

    dad.playAnim("talk", true);

    bg_legacy.visible = false;
    il_legacy.visible = false;

    sanses_bg.visible = false;
    sanses_front.visible = false;
    thero_appear.visible = false;

    autoTitleCard = false;

    gf.alpha = 0;

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    var vignetteCam = new FlxCamera();
    FlxG.cameras.add(vignetteCam, false);
    vignetteCam.bgColor = 0x00000000;

    gasterBlaster.camera = vignetteCam;
    hate_vignette.camera = vignetteCam;
    hate_vignette.alpha = 0;
    gasterBlaster.visible = false;


    itslikeprettywarpedtoo = new CustomShader("chromaticWarp");
    if (Options.gameplayShaders && FlxG.save.data.chromwarp) camGame.addShader(itslikeprettywarpedtoo);
    itslikeprettywarpedtoo.distortion = 1;

    if (camHUD.downscroll) {
        gasterBlaster.y -= 480;
    }
}

function update(elapsed:Float) {
    baseAngle = isAngle ? desiredCamAngle : 0;

    if (isGlitch)
    {
        glitchTimer += elapsed;
        if (glitchTimer >= 0.15) {
            glitchTimer = 0;

            var randIndex = FlxG.random.int(0, glitchValues.length - 1);
            glitch.AMT = glitchValues[randIndex];
        } 
    }

    if (isGlitch2)
    {
        glitchTimer += elapsed;
        if (glitchTimer >= 0.15) {
            glitchTimer = 0;

            var randIndex2 = FlxG.random.int(0, glitchValues2.length - 1);
            glitch2.AMT = glitchValues2[randIndex2];
        } 
    }

    if (hate_vignette.alpha > 0) {
        alphaTimer += elapsed;
        if (alphaTimer >= fadeInterval) {
            alphaTimer = 0;
            hate_vignette.alpha -= fadeAmount;
        }
    }
}

function beatHit() {
    if (Options.gameplayShaders && itslikeprettywarpedtoo != null && starthittingthegriddy) {
        itslikeprettywarpedtoo.distortion = 1.6;

        FlxTween.num(1.6, 1, 0.5, {
            ease: FlxEase.quadOut}, 
            function(val:Float) {
                itslikeprettywarpedtoo.distortion = val;}

        );
    }
}


public function turnCam() {
    if (!FlxG.save.data.mechanics) return;
    camGame.shake(0.01, 0.2);
    camHUD.shake(0.01, 0.2);
    if (up == true) {
        // should be from 4 to 0, a quadOut, then from 0 to 184 a quadIn
        desiredCamAngle = 0;
        desiredCamAngle = 184;
        up = false;
    }
    else {
        // should be from 184 to 180, a quadOut, then from 180 to 4 a quadIn
        desiredCamAngle = 180;
        desiredCamAngle = 4;
        up = true;
    }
}

public function shootBlast() {
    if (!FlxG.save.data.mechanics) return;
    gasterBlaster.visible = true;
    gasterBlaster.playAnim("shoot");
    

    new FlxTimer().start(0.2, function(tmr:FlxTimer) {
        FlxG.sound.play(Paths.sound("blaster_shoot"), 1);
    });

    

    new FlxTimer().start(0.4, function(tmr:FlxTimer) {
        if (player != null) {

            if (health <= 0.3 && !player.cpu) {
                health = 0;
            } else
            {
                health = 0.1;
            }
            
        }
    });


}