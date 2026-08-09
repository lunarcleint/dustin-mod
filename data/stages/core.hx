//
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

public var impact:CustomShader;
var tape_noise:CustomShader;
var warp:CustomShader;
var heathud:CustomShader;

var shakeTimer:Float = 0;
var foreverShake:Bool = false;

var floatOriginX:Float = 0;
var floatOriginY:Float = 0;
var floatAngle:Float = 0;
var isFloating:Bool = false;
var isFloating2:Bool = false;


function create() {
    warp = new CustomShader("warp");
    warp.distortion = 0.5;

    heathud = new CustomShader("heatwave");
    heathud.time = 0; heathud.speed = 0.7; 
    heathud.even = true;

    impact = new CustomShader("impact_frames");
    impact.threshold = .3;

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 0;

    // adding shaders
    if (Options.gameplayShaders) {
        if (FlxG.save.data.warp) FlxG.camera.addShader(warp);
        if (FlxG.save.data.fire) {
            camHUD.addShader(heathud);
            FlxG.camera.addShader(heathud);
        }
        if (FlxG.save.data.impact)
            FlxG.camera.addShader(impact);

        if (FlxG.save.data.static)
            FlxG.camera.addShader(tape_noise);
    }

    stage.getSprite("fondo").visible = false;
    stage.getSprite("pilares").visible = false;
    stage.getSprite("platform").visible = false;
    stage.getSprite("light").visible = false;
}

function postCreate() {
    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    stage.getSprite("rotate").camera = camHUD;
    stage.getSprite("rotate").playAnim("idle");
    stage.getSprite("rotate").scale.set(0.7, 0.7);
    stage.getSprite("rotate").updateHitbox();
    stage.getSprite("rotate").screenCenter();

    if (!camHUD.downscroll)
        stage.getSprite("rotate").y = stage.getSprite("rotate").y + 70;
    else
        stage.getSprite("rotate").y = stage.getSprite("rotate").y - 70;

    stage.getSprite("rotate").visible = false;

    dustinHealthBar.flipX = true;
    dustinHealthBG.flipX = true;

    dustiniconP1.flipX = true;
    dustiniconP2.flipX = true;
    reverseIcons = true;

    autoTitleCard = false;

    strumLines.members[3].characters[0].visible = false;
    impacting.visible = false;

    

}


function stepHit(step:Int) {
	if (step == 160 || step == 704 || step == 736 || step == 704 || step == 768 || step == 832 || step == 864 || step == 896) {
		impact.threshold = -1;
		FlxG.camera.shake(0.01, 0.2);

          healthBar.scale.x = -1;    
    healthBar.x += healthBar.width;
    healthBar.updateHitbox();

    healthBarBG.scale.x = -1;
    healthBarBG.x += healthBarBG.width;
    healthBarBG.updateHitbox();
	}

    if (step == 2416) {
        impacting.visible = true;
        FlxG.camera.shake(0.04, 0.3);
    }

    if (step == 688 || step == 720 || step == 752 || step == 816 || step == 848 || step == 880) {
        impact.threshold = .4;
    }

    if (step == 175) {
        showTitleCard();
    }

    if (step == 950) {
        tape_noise.strength = 1;
        heathud.strength = 0.2;
        dad.alpha = 0;
        dad.flipX = false;

        dustiniconP2.visible = false;

        stage.getSprite("back").visible = false;
        stage.getSprite("core").visible = false;
        stage.getSprite("lights").visible = false;
        stage.getSprite("tube").visible = false;
        stage.getSprite("floor").visible = false;

        stage.getSprite("bg").alpha = 1;
        stage.getSprite("bg_spark").alpha = 1;

        dad.x = 1130;
        dad.y = 830;
        dad.cameraOffset.y = -50;
        dad.cameraOffset.x = 100;

        boyfriend.x = 350;
        boyfriend.y = 700;
        boyfriend.cameraOffset.x = 450;
        boyfriend.cameraOffset.y = -100;
    }

    if (step == 1196) {
        dad.alpha = 0.7;

        insert(members.indexOf(strumLines.members[3].characters[0]), boyfriend);

    }

    if (step == 1224) {
        stage.getSprite("rotate").visible = true;
    }

    if (step == 1244) {
        stage.getSprite("rotate").visible = false;
    }

    if (step == 1245) {
        stage.getSprite("rotate").visible = true;
        stage.getSprite("rotate").playAnim("scary");
    }

    if (step == 1247) {
        stage.getSprite("rotate").visible = false;
    }

    if (step == 1224) {
        strumLines.members[3].characters[0].visible = true;
        
        tape_noise.strength = 0;
        heathud.strength = 0;
        dad.alpha = 1;

        dustiniconP2.visible = true;

        stage.getSprite("back").visible = true;
        stage.getSprite("core").visible = true;
        stage.getSprite("lights").visible = true;
        stage.getSprite("tube").visible = true;
        stage.getSprite("floor").visible = true;

        stage.getSprite("bg").alpha = 0;
        stage.getSprite("bg_spark").alpha = 0;

        dad.x = 3000;
        dad.y = 1070;
        dad.cameraOffset.y = 0;
        dad.cameraOffset.x = 0;

        boyfriend.x = 1400;
        boyfriend.y = 500;
        boyfriend.cameraOffset.x = 0;
        boyfriend.cameraOffset.y = 0;
    }

    if (step == 1248) {
        FlxG.camera.shake(0.01, 0.2);

        boyfriend.alpha = 0;
        
        floatOriginX = boyfriend.x;
        floatOriginY = boyfriend.y;
        floatAngle = 0;
        isFloating = true;

        FlxTween.tween(boyfriend, {alpha: 0.7}, 1, {
            ease: FlxEase.quadOut
        });

        
    }

    if (step == 1718) {
        isFloating = false;
        boyfriend.x = floatOriginX;
        boyfriend.y = floatOriginY;
        boyfriend.alpha = 1;


        strumLines.members[3].characters[0].alpha = 0;

        stage.getSprite("fondo").visible = true;
        stage.getSprite("pilares").visible = true;
        stage.getSprite("platform").visible = true;
        stage.getSprite("light").visible = true;

        platform.y = platform.y + 1600;
        dad.y = dad.y + 1600;
        boyfriend.y = boyfriend.y + 1600;
    }

    if (step == 2400) {
        FlxTween.tween(strumLines.members[3].characters[0], {alpha: 0.5}, 0.5, {
            ease: FlxEase.quadOut
        });
    }

    if (step == 1792) {
        FlxTween.tween(dad, {y: dad.y - 1600}, 7, {ease: FlxEase.cubeInOut});
        FlxTween.tween(boyfriend, {y: boyfriend.y - 1600}, 7, {ease: FlxEase.cubeInOut});
        FlxTween.tween(platform, {y: platform.y - 1600}, 7, {ease: FlxEase.cubeInOut});


        shakeTimer = 6;
        foreverShake = false;
    }

    if (step == 1856) {
        floatOriginX = strumLines.members[3].characters[0].x;
        floatOriginY = strumLines.members[3].characters[0].y;
        floatAngle = 0;
        isFloating2 = true;

        FlxTween.tween(strumLines.members[3].characters[0], {alpha: 0.2}, 1, {
            ease: FlxEase.quadOut
        });
    }

    if (step == 2400) {
        FlxTween.tween(dad, {y: dad.y + 300}, 0.7, {ease: FlxEase.cubeInOut});
        FlxTween.tween(boyfriend, {y: boyfriend.y + 300}, 0.7, {ease: FlxEase.cubeInOut});
        FlxTween.tween(platform, {y: platform.y + 300}, 0.7, {ease: FlxEase.cubeInOut});
        isFloating2 = false;
        FlxTween.tween(strumLines.members[3].characters[0], {y: strumLines.members[3].characters[0].y + 300}, 0.7, {ease: FlxEase.cubeInOut});
    }

    if (step == 2408) {
        FlxTween.tween(dad, {y: dad.y - 1200}, 1, {ease: FlxEase.quartIn});
        FlxTween.tween(boyfriend, {y: boyfriend.y - 1200}, 1, {ease: FlxEase.quartIn});
        FlxTween.tween(platform, {y: platform.y - 1200}, 1, {ease: FlxEase.quartIn});

        FlxTween.tween(strumLines.members[3].characters[0], {y: strumLines.members[3].characters[0].y - 1200}, 1, {ease: FlxEase.quartIn});
    }
}

var tottalTimer:Float = 0;
var shakeTimer:Float = 0;

function update(elapsed:Float) {
    tottalTimer += elapsed;
    heathud.time = tottalTimer;
    tape_noise.time = tottalTimer;

    if (shakeTimer > 0) {
        shakeTimer -= elapsed;
        FlxG.camera.shake(0.02, 0.05);

        if (shakeTimer <= 0) {
            foreverShake = true;
        }
    }

    if (foreverShake) {
        FlxG.camera.shake(0.01, 0.05);
    }

    if (isFloating) {
        floatAngle += elapsed * 2;

        var radiusX = 80;
        var radiusY = 20;

        boyfriend.x = floatOriginX + Math.cos(floatAngle) * radiusX;
        boyfriend.y = floatOriginY + Math.sin(floatAngle) * radiusY;
    }

    if (isFloating2) {
        floatAngle += elapsed * 2;

        var radiusX = 80;
        var radiusY = 20;

        strumLines.members[3].characters[0].x = floatOriginX + Math.cos(floatAngle) * radiusX;
        strumLines.members[3].characters[0].y = floatOriginY + Math.sin(floatAngle) * radiusY;
    }

}
