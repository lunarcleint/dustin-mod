//
function onPostCountdown(event) event.sprite?.color = ratingColor;

var fellShakeAmount:Float = 0;

var healthDrainAmount:Float = 0;
var camShakeAmount:Float = 0;

public var angryMode = 0;

var shadeSprite:FlxSprite;
var madnessSprite:FlxSprite;

var spiritsChar;


function postCreate() {
    timeBarBG.color = 0xFFA3A5AC;

    stage.getSprite("madnessbar_assetsOVERTHRONE").camera = camHUD;
    stage.getSprite("warning_OVERTHRONE").camera = camHUD;
    stage.getSprite("shade_overthrone_tutorial").camera = camHUD;

    stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("idle");

    stage.getSprite("icon_fell").camera = camHUD;
    stage.getSprite("icon_fell").playAnim("icon_idle");

    dustiniconP2.visible = false;

    iconFellOriginalX = stage.getSprite("icon_fell").x;
    iconFellOriginalY = stage.getSprite("icon_fell").y;


    shadeSprite    = stage.getSprite("shade_overthrone_tutorial");
    madnessSprite  = stage.getSprite("warning_OVERTHRONE");

    shadeSprite.alpha = 0;
    madnessSprite.alpha = 0;

    if (camHUD.downscroll)
    {
        madnessbar_assetsOVERTHRONE.flipY = true;
        dustinHealthBar.flipY = true;
        dustinHealthBG.flipY = true;
        dustinHealthBar.y += 6;
    }

    spiritsChar = strumLines.members[3].characters[0];
    spiritsChar.alpha = 0;

    remove(spiritsChar);
    insert(members.indexOf(ASGOREOT), spiritsChar);
    stage.getSprite("ASGOREOT").playAnim("ASGOREIDLE");
}

function onDadHit(note:Note) {
    if (health > 0.02) health -= healthDrainAmount;
}


function stepHit(step:Int) {
    if (FlxG.save.data.mechanics && step == 45) {
        FlxTween.tween(shadeSprite, { alpha: 0 }, 0.5, { ease: FlxEase.quintOut });
        FlxTween.tween(madnessSprite, { alpha: 0 }, 0.5, { ease: FlxEase.quintOut });
    }

    switch (step) {
        case (SONG.meta.name.toLowerCase() == "overthrone" ? 1060 : 1424):
            FlxTween.tween(spiritsChar, {alpha: 0.7}, 2, {ease: FlxEase.quadInOut});
            FlxTween.tween(ASGOREOT, {alpha: 0.7}, 2, {ease: FlxEase.quadInOut});

        case (SONG.meta.name.toLowerCase() == "overthrone" ? 1316 : 1680):
            FlxTween.tween(spiritsChar, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

        case 1308, 1324, 1340, 1356, 1372, 1388, 1404, 1420, 1436, 1452, 1468, 1484, 1500, 1516, 1532, 1548:
            if (SONG.meta.name.toLowerCase() == "overthrone") stage.getSprite("ASGOREOT").playAnim("ASGORESTOMP");

        case (SONG.meta.name.toLowerCase() == "overthrone" ? 1572 : 1681):
            FlxTween.tween(ASGOREOT, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

        case (SONG.meta.name.toLowerCase() == "overthrone" ? 1828 : 1776):
            FlxTween.tween(gf, {alpha: SONG.meta.name.toLowerCase() == "overthrone" ? 0.8 : 0.4}, 3, {ease: FlxEase.quadInOut});

        case 2084:
            FlxTween.tween(icon_fell, { alpha: 0 }, 0.5, { ease: FlxEase.quintOut });
            FlxTween.tween(madnessbar_assetsOVERTHRONE, { alpha: 0 }, 0.5, { ease: FlxEase.quintOut });

        case 2000:
            if (SONG.meta.name.toLowerCase() == "red-demon-o")
                camGame.fade(FlxColor.BLACK, 10); 
    }
}
function onSongStart():Void {
    if (FlxG.save.data.mechanics) {
        FlxTween.tween(shadeSprite, { alpha: 1 }, 0.5, { ease: FlxEase.quintOut });
        FlxTween.tween(madnessSprite, { alpha: 1 }, 0.5, { ease: FlxEase.quintOut });
    }

}

function update(elapsed:Float) {
    dustiniconP1.x = 570;

    var shakeX = (Math.random() * 2 - 1) * fellShakeAmount;
    var shakeY = (Math.random() * 2 - 1) * fellShakeAmount;

    var iconFell = stage.getSprite("icon_fell");
    iconFell.x = iconFellOriginalX + shakeX;
    iconFell.y = iconFellOriginalY + shakeY;

    switch(angryMode){
        case 0:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("idle");
            stage.getSprite("icon_fell").playAnim("icon_idle");

            healthDrainAmount = 0;
            camShakeAmount = 0;
        case 1:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("1");
            fellShakeAmount = 1;

            healthDrainAmount = 0.003;
            camShakeAmount = 0.002;
        case 2:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("2");
            fellShakeAmount = 3;

            healthDrainAmount = 0.005;
            camShakeAmount = 0.004;
        case 3:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("3");
            fellShakeAmount = 5;

            healthDrainAmount = 0.008;
            camShakeAmount = 0.006;
        case 4:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("4");
            fellShakeAmount = 7;
            stage.getSprite("icon_fell").playAnim("icon_angry");

            healthDrainAmount = 0.01;
            camShakeAmount = 0.008;
        case 5:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("5");
            fellShakeAmount = 9;

            healthDrainAmount = 0.012;
            camShakeAmount = 0.01;
        case 6:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("6");
            fellShakeAmount = 11;

            healthDrainAmount = 0.014;
            camShakeAmount = 0.012;
        case 7:
            stage.getSprite("madnessbar_assetsOVERTHRONE").playAnim("7");
            fellShakeAmount = 13;

            healthDrainAmount = 0.016;
            camShakeAmount = 0.015;
        case 8:
            health -= 2;
    }
}

function onPlayerMiss(e) e.cancelMissSound();