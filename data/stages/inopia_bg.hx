//
var screenVignette:FlxSprite;
var boyfriendOGx:Float;

var isTweeningStrums:Bool = false;
var strumsShifted:Bool = false;
var strumShiftAmount:Float = 640;

function create() {
    FlxG.camera.bgColor = 0xFF000000;
}

function postCreate() {
    stage.getSprite("marco").camera = camHUD;
    stage.getSprite("marco").playAnim("marco");
    stage.getSprite("marco").alpha = 1;

    stage.getSprite("vignette").camera = camHUD;
    stage.getSprite("vignette").playAnim("vignette");
    stage.getSprite("vignette").alpha = 0.5;

    stage.getSprite("red").camera = camHUD;
    stage.getSprite("red").playAnim("red");
    stage.getSprite("red").alpha = 0;

    stage.getSprite("avignette").camera = camHUD;
    stage.getSprite("avignette").alpha = 0.5;

    boyfriendOGx = boyfriend.x;

    for (strum in strumLines.members[2].members)
        strum.x += -320;


    deer.visible = false;
    mouse.visible = false;
    bunny.visible = false;
    bear.visible = false;
    monster.visible = false;
    bunny2.visible = false;
    cat.visible = false;
    gf.visible = false; 


    redBG(false);

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    dustinHealthBar.flipX = true;
    dustinHealthBG.flipX = true;

    dustiniconP1.flipX = true;
    dustiniconP2.flipX = true;
    reverseIcons = true;

}

function flipBF() {
    if (isTweeningStrums) return;

    if (boyfriend.flipX == true) {
        boyfriend.flipX = false;
        boyfriend.x = boyfriendOGx;
        dustiniconP2.loadGraphicFromSprite(createHealthIcon("inopia-sans", false));
        dustiniconP2.updateHitbox();

        if (Options.colorHealthBar && healthBarColors != null && dad.iconColor != null) {
            ogHealthColors[0] = healthBarColors[0] = dad.iconColor;
        }
    }
    else {
        boyfriend.flipX = true;
        if (boyfriend.extra["flipOffset"] != null)
        boyfriend.x = boyfriendOGx + boyfriend.extra["flipOffset"];
        dustiniconP2.loadGraphicFromSprite(createHealthIcon("inopia-paps", false));
        dustiniconP2.updateHitbox();

        if (Options.colorHealthBar && healthBarColors != null && gf.iconColor != null) {
            ogHealthColors[0] = healthBarColors[0] = gf.iconColor;
        }
    }
}

function shiftStrums():Void {
    if (isTweeningStrums) return;

    isTweeningStrums = true;

    var shift = strumsShifted ? -strumShiftAmount : strumShiftAmount;
    var tweenTime = 0.5;
    var tweensLeft = 0;

    function onTweenComplete(_) {
        tweensLeft--;
        if (tweensLeft <= 0) {
            isTweeningStrums = false;
        }
    }

    for (strumLine in strumLines) {
        for (sprite in strumLine.members) {
            if (sprite != null) {
                tweensLeft++;
                FlxTween.tween(sprite, {x: sprite.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                    onComplete: onTweenComplete
                });
            }
        }

        for (note in strumLine.notes) {
            if (note != null) {
                tweensLeft++;
                FlxTween.tween(note, {x: note.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                    onComplete: onTweenComplete
                });
            }
        }
    }

    strumsShifted = !strumsShifted;
}


function update(elapsed:Float) {
    var currentHealth:Float = PlayState.instance.health;
    var redAlpha:Float = 1 - currentHealth;
    redAlpha = FlxMath.bound(redAlpha, 0, 1);
    stage.getSprite("red").alpha = redAlpha;


    /*if (FlxG.mouse.justPressed) {
        flipBF();
        shiftStrums();
    }*/
}

function stepHit(step:Int) {
    switch (step) {
        case 782:
            monsterAppear("deer");
        case 832:
            monsterAppear("mouse");
        case 806:
            monsterAppear("bunny");
            monsterAppear("monster");
        case 904:
            monsterAppear("bear");
        case 782:
            monster.visible = true;
        case 928:
            monsterAppear("bunny2");
        case 960:
            monsterAppear("cat");

        case 1008:
            gf.visible = true; 

        case 1024, 1408, 1536, 1568, 1824, 1888:
            flipBF();
            shiftStrums();

        case 1672:
            timeBarColors = [0xFF7A282A, 0xFF000000];
            redBG(true);

        
    }
}


function redBG(isVisible:Bool) {
    BG1.visible = !isVisible;
    BG2.visible = !isVisible;
    BG3.visible = !isVisible;
    BG4.visible = !isVisible;
    BG5.visible = !isVisible;
    BG6.visible = !isVisible;
    BG7.visible = !isVisible;

    red_BG1.visible = isVisible;
    red_BG2.visible = isVisible;
    red_BG3.visible = isVisible;
    red_BG4.visible = isVisible;
    red_BG5.visible = isVisible;
    red_BG6.visible = isVisible;
    red_BG7.visible = isVisible;
}

function monsterAppear(name:String) {
    stage.getSprite(name).visible = true;
    stage.getSprite(name).playAnim("enter", true);

    stage.getSprite(name).animation.finishCallback = function(animName:String) {
        if (animName == "enter") {
            stage.getSprite(name).playAnim("idle", true);
        }
    };
}