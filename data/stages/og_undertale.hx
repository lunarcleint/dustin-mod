//
import flixel.text.FlxTextBorderStyle;
import flixel.addons.effects.FlxTrail;
import openfl.Lib;

var dadFloatTime:Float = 0;


var dadBaseX:Float = 0;
var dadBaseY:Float = 0;
var dadFloatPhase:Float = 0;
var dadFloating:Bool = false;

var currentFloatSpeed:Float = 3; 
var currentFloatRadius:Float = 200; 

var fakeMaxHealthMode:Bool = false;
var realMaxHealth:Int = 10;
var originalTextBGWidth:Float;


public var flames:CustomShader;
importScript("data/scripts/DialogueBoxBG");

function create() {
    ratingScale = 0.3;
    __undertaleResize();

    for (thing in [timeBar, timeBarBG]) if(thing != null) {
        remove(thing); thing.destroy();
    }
    scripts.getByName("ui_timebar.hx")?.active = false;

    flames = new CustomShader("roaring_flame_cut"); // flame on!!!! -lunar
    flames.time = 0; flames.intensitiy = 0; flames.zoom = 1;
    if (Options.gameplayShaders && FlxG.save.data.glitch) stage.getSprite("rflames").shader = flames;
    stage.getSprite("rflames").flipY = false;
}

var hpTxt:FunkinText;
var lifeTxt:FunkinText;
var textBG:FunkinSprite;
var erText:FunkinText;

var dialogueCam:FlxCamera;

function postCreate() {
    FlxG.camera.followLerp = 0;
    camFollowChars = false;

    dialogueCam = new FlxCamera();
    dialogueCam.bgColor = FlxColor.TRANSPARENT;
    dialogueCam._filters = camGame._filters;
    FlxG.cameras.add(dialogueCam, false);

    dustinHealthBG?.visible = false;
    lerpedHealth = health = maxHealth;
    dustinHealthBar.flipX = true;
    dustinHealthBar.width = FlxG.width / 8;
    dustinHealthBar.x -= camHUD.downscroll ? FlxG.width / 1.47 : 130;
    dustinHealthBar.y += camHUD.downscroll ? -FlxG.height / 1.35 : 30;
    dustinHealthBar.offset.y += camHUD.downscroll ? -5 : 9;
    dustinHealthBar.antialiasing = false;
    noMissIconAnim = true;

    for (text in [hpTxt = textCrispy(new FunkinText(FlxG.width - (FlxG.width / 2.67) - 10, dustinHealthBar.y - 9, 0, "hp")), lifeTxt = textCrispy(new FunkinText(FlxG.width - (FlxG.width / 5) - 9, dustinHealthBar.y - 9, 0, health * 10 + "/" + maxHealth * 10))]) {
        insert(members.indexOf(dustinHealthBar), text); hudElements.insert(hudElements.indexOf(dustinHealthBar), text);
        text.cameras = [camHUD]; text.scrollFactor.set();
        text.setFormat(Paths.font("DTM-Mono.ttf"), 20, 0xFFFFFFFF);
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        text.borderSize = 2;
        text.borderColor = 0xFF000000;

        if (camHUD.downscroll) {
            text.y -= 2;
            text.x -= FlxG.width / 2.1;
        }
    }
    for(text in [scoreTxt, missesTxt, accuracyTxt]) text?.visible = false;

    if(iconText == null) return;
    iconText.cameras = [dialogueCam]; hudElements.push(iconText);
    genocides.cameras = [dialogueCam];
    iconText.animation.play(_lastAnim = dad.getAnimName());

    insert(members.indexOf(iconText), textBG = newDialogueBoxBG(20, 20, null, (iconText.width + FlxG.width * 2) * iconText.scale.x, (iconText.height + FlxG.height / 1.6) * iconText.scale.y, 5));
    textBG.cameras = [dialogueCam];
    hudElements.push(textBG);

    insert(members.indexOf(textBG) + 1, erText = textCrispy(new FunkinText(iconText.x + (iconText.width * iconText.scale.x) + 50, textBG.y + textBG.extra["border"] + 10, textBG.width)));
    erText.setFormat(Paths.font("pixel-comic.ttf"), Math.floor(textBG.height / 5), 0xFFFFFFFF);
    erText.cameras = [dialogueCam]; hudElements.push(erText);

    iconText.setPosition(textBG.x - 200, textBG.y - 175);

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    pasta.y += 1200;

    originalTextBGWidth = textBG.width;

    textBG.extra["bWidth"] = textBG.width *= 2;
    erText.fieldWidth = textBG.width;

    for (thing in [textBG, erText, iconText, hpTxt, lifeTxt, dustinHealthBar, dustiniconP1, dustiniconP2]) {
        if (thing != null) thing.alpha = 0;
    }
        

}

var _erCounter:Int = -1;
function onNoteHit(event) event.healthGain = 0;
function onDadHit(event) {
    if(event.note.isSustainNote) return;

    if(erText.text == "" || _erCounter+1 > 8) {  // manually resetted  - Nex
        erText.text = "*";
        _erCounter = -1;
    }

    if ((_erCounter+1)%3 < (_erCounter)%3)
        erText.text += "\n*";

    _erCounter++;
    erText.text += dad.curCharacter == "papyrus_genocides" ? (FlxG.random.bool(75) ? " HEH!" : " NYEH!") : (" e" + (FlxG.random.bool() ? "rr" : "r"));
}
function onPlayerMiss(event) {
    if (fakeMaxHealthMode) {
        health -= 0.1;
        if (health <= 0) health -= 9999;

        lifeTxt.text = FlxMath.roundDecimal(health, 1) + "";
    } else {
        var normMax:Int = maxHealth * 10;
        event.healthGain = - maxHealth / normMax;
        lifeTxt.text = normMax - misses - event.misses + "/" + normMax;
    }
}


var tottalTimer:Float = FlxG.random.float(1000, 5000); 
function update(elapsed) {

    if (dadFloating) {
        dadFloatPhase += elapsed * currentFloatSpeed;

        var dadFloatX = Math.sin(dadFloatPhase) * currentFloatRadius;
        var dadFloatY = Math.sin(dadFloatPhase * 2) * (currentFloatRadius / 2);

        dad.x = dadBaseX + dadFloatX;
        dad.y = dadBaseY + dadFloatY;
    }

    if (fakeMaxHealthMode) {
        lifeTxt.text = FlxMath.roundDecimal(health, 1) + "";
    }



    tottalTimer += elapsed;
    flames.time = tottalTimer;
    flames.zoom = 1 / (Lib.application.window.width/FlxG.width);
    dustiniconP2.x = 10;
    dustiniconP1.x = camHUD.downscroll ? lifeTxt.x + lifeTxt.width + 10 : FlxG.width - dustiniconP1.width - 10;
    if (dad.curCharacter == "papyrus_genocides") {
        dustiniconP2.flipX = dustiniconP1.flipX = true;
        dustiniconP2.x = dustiniconP1.x;
        dustiniconP1.x = camHUD.downscroll ? hpTxt.x - dustiniconP1.width - 10 : 10;
    }

    for (icon in [dustiniconP1, dustiniconP2]) {
        icon.antialiasing = false;
        icon.scale.set(.4, .4); icon.updateHitbox();
    }

    healthBarColors = [0xFF0000, 0xFFFF00];
    hpTxt.alpha = lifeTxt.alpha = dustinHealthBar.alpha;
}

var _lastAnim:String;
var _iconMovingTimer:FLoat = 0;
function postUpdate(elapsed:Float) if (iconText != null) {
    var curAnim = dad.getAnimName();
    var isAlt:Bool = false;
    var isIdle:Bool = curAnim == "idle";
    dialogueCam.alpha = camHUD.alpha;
    if (dad.curCharacter == "papyrus_genocides") {
        isAlt = true;
        curAnim += "-alt";
    }

    if (curAnim != _lastAnim) {
        _lastAnim = curAnim;
        iconText.playAnim(curAnim);
        if (isIdle) erText.text = "";
        else if (isAlt) _iconMovingTimer = 0.2;
    }

    if((_iconMovingTimer -= elapsed) > 0) {
        iconText.setPosition((isAlt ? (textBG.x + textBG.extra["bWidth"] - iconText.width * iconText.scale.x - 30) : textBG.x) - 200, textBG.y - 175);
        iconShake(iconText, _iconMovingTimer/0.2);
    }

    if (_oldBf != null) {
        insert(members.indexOf(boyfriend) + 1, _oldBf);
        _oldBf = null;
    }

    vignette?.angle = camGame.angle;
}

function onStrumCreation(event) if (camHUD.downscroll) event.strum.y -= 30;

var _oldBf:Character = null;
function onEvent(_) if (_.event.name == "Change Character" && _.event.params[1] == "papyrus_genocides" && iconText != null) {
    _oldBf = boyfriend;

    textBG.x = FlxG.width - (iconText.width + FlxG.width * 2) * iconText.scale.x - 20;
    erText.x = textBG.x + 20;
    for (strum in strumLines.members[1].members) strum.x -= (FlxG.width / 1.9) - 10;

    if (camHUD.downscroll) for (thing in [dustinHealthBar, hpTxt, lifeTxt]) thing.x += (FlxG.width / 2.1);
    else {
        dustinHealthBar.x = -440;
        hpTxt.x = (FlxG.width / 7.80) - 10;
        lifeTxt.x = (FlxG.width / 3.3) - 9;
    }

    shake(0.7, 0.85);
    _iconMovingTimer = 0.7;
    FlxTween.tween(FlxG.camera.scroll, {y: 0}, 0.3, {startDelay: 0.7, ease: FlxEase.sineInOut});

    FlxTween.tween(FlxG.camera.scroll, {x: FlxG.camera.scroll.x + 300}, 0.3);
    new FlxTimer().start(0.05, () -> FlxTween.tween(dad, {x: -200}, 0.08, {ease: FlxEase.linear}));  // cant use startDelay here since dad changes  - Nex
}

function genoText(text:String) {
    text = StringTools.replace(text, "\\n", "\n");
    _erCounter = 8;

    if (!StringTools.startsWith(text, "*")) text = erText.text + text;
    erText.text = text;
}

function stepHit(step:Int){

    if (step < 63) {
        for (strum in playerStrums.members) {
            strum.alpha = 0;
            strum.visible = false;
        }
    }
    switch(step) {
        case 26:
            textBG.alpha = 1;
            erText.alpha = 1;
            iconText.alpha = 1;


        case 51:
            genocides.alpha = 1;

        case 64:
            genocides.alpha = 0;
            erText.text = "";
            for (strum in playerStrums.members) {
                strum.visible = true;
            }

            FlxTween.num(textBG.extra["bWidth"], originalTextBGWidth, 1.5, {ease: FlxEase.quartOut}, (val:Float) -> {
                textBG.extra["bWidth"] = val;
                erText.fieldWidth = val;
            });

        case 860:
            FlxTween.num(textBG.extra["bWidth"], textBG.extra["bWidth"] * 1.2, 1.5, {ease: FlxEase.quartOut}, (val:Float) -> {
                textBG.extra["bWidth"] = val;
                erText.fieldWidth = val;
            });

        case 891, 1275:
            erText.text = "";
            FlxTween.num(textBG.extra["bWidth"], originalTextBGWidth, 1.5, {ease: FlxEase.quartOut}, (val:Float) -> {
                textBG.extra["bWidth"] = val;
                erText.fieldWidth = val;
            });
        case 1211:
            fakeMaxHealthMode = true;
            health = 1;
            maxHealth = 1;
            lifeTxt.text = "1.0";


        case 540, 950, 1000, 1300, 1520:
            gaster.x = -1570;
            FlxTween.tween(gaster, {x: pasta.x + 2200}, 1);

        case 1419:
            flames.intensitiy = 1.1;

        case 1659:
            dadBaseX = dad.x;
            dadBaseY = dad.y;
            clearTrails();
            spawnPapsTrail(dad);
            
            dadFloating = true;
            dadFloatTime = 0; 

        case 1948:
            trace("pasta");
            FlxTween.tween(pasta, {y: pasta.y - 1200}, 4, {ease: FlxEase.quartOut});

        case 1979:
            currentFloatSpeed = 5; 
            currentFloatRadius = 400; 
        case 2288:
            dialogueCam.visible = false;
    }
}
var papsTrails:Array<FlxTrail> = [];

function spawnPapsTrail(sprite:FlxSprite) {
    var trail = new FlxTrail(sprite, null, 32, 11, 0.3, 0.045);
    trail.color = 0xFFFFFFFF;
    insert(members.indexOf(sprite), trail);
    papsTrails.push(trail);
    return trail;
}

function clearTrails() {
    for (trail in papsTrails) {
        remove(trail);
        trail.destroy();
    }
    papsTrails = [];
}

function destroy() __fnfResize();