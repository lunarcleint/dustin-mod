//
import openfl.Lib;

public var dadClone:Character = null;
public var bfClone:Character = null;

public var dadPos:Float = 670;
public var bfPos:Float = /*400*/ null;
public var bfPos2:Float = 620;
public var bfPos3:Float = 540;

public var bloom_new:CustomShader;
public var lightShader:CustomShader;
public var vig:CustomShader;

public var chromWarp:CustomShader;
public var dust:CustomShader;

public var colorShader:CustomShader;

var alteredColors:Bool = false;
// inline function from flxcolor
function boundChannel(Value:Int):Int
{
    return Value > 0xff ? 0xff : Value < 0 ? 0 : Value;
}

public function resetColors() {
    alteredColors = false;
    ogHealthColors = archivedHealthColors.copy();
    healthBarColors = archivedHealthColors.copy();
    colorShader.forceColors = false;
    colorShader.colors = [-1,-1,-1,-1];

    // shaders clash with the colors variable, so we have to remove it entirely for these sprites
    stage.stageSprites["ground"].shader = null;
    stage.stageSprites["fg"].shader = null;
    if (Options.gameplayShaders && FlxG.save.data.godrays)
        lightShader.lightcol = [255., 241., 255.];
}

// -1 will ignore the color
public function changeColors(r:Float = -1, g:Float = -1, b:Float = -1, a:Float = -1) {
    if (!alteredColors) {
        archivedHealthColors = ogHealthColors.copy();
        trace(archivedHealthColors[1] == FlxColor.RED);
        alteredColors = true;
    }

    for (i => healthColor in archivedHealthColors) {
        if (r != -1) {
            // removing red
            healthColor &= 0xff00ffff;
            healthColor |= boundChannel(r) << 16;
        }
        if (g != -1) {
            // removing green
            healthColor &= 0xffff00ff;
            healthColor |= boundChannel(g) << 8;
        }
        if (b != -1) {
            //removing blue
            healthColor &= 0xffffff00;
            healthColor |= boundChannel(b);
        }

        ogHealthColors[i] = healthBarColors[i] = healthColor;
    }

    colorShader.forceColors = true;
    colorShader.colors = [r,g,b,a];

    stage.stageSprites["ground"].shader = colorShader;
    stage.stageSprites["fg"].shader = colorShader;

    if (Options.gameplayShaders && FlxG.save.data.godrays) {
        if (r == -1) r = 1;
        if (g == -1) g = 1;
        if (b == -1) b = 1;
        lightShader.lightcol = [r * 255., g * 255., b * 255];
    }
}

public var archivedHealthColors:Array<Int> = [0,0];



// updating icons

using StringTools;

function create() {
    colorShader = new CustomShader("forceColor"); // Papyrus by default
    colorShader.forceColors = false;
    colorShader.colors = [-1,-1,-1,-1];
}

function postCreate() {
    archivedplayerColor = ogHealthColors[1];

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 20; bloom_new.brightness = 1.78;
    bloom_new.directions = 16; bloom_new.quality = 5;
    bloom_new.threshold = .75;

    // autoTitleCard = false;

    var vig = new CustomShader("vig");
    vig.amount = 0.45; vig.radius = 0.8; vig.softness = 0.4;

    dustinHealthBar.flipX = true;
    dustinHealthBG.flipX = true;

    dustiniconP1.flipX = true;
    dustiniconP2.flipX = true;
    reverseIcons = true;

    camZoomMult = .965;
    FlxG.camera.followLerp = .03;

    stage.stageSprites["back"].shader = colorShader;
    stage.stageSprites["ground"].color = 0xffb7ace4;
    stage.stageSprites["fg"].color = 0xffb7ace4;

    lightShader = new CustomShader("light_preprocess");
    lightShader.threshold = .5;
    lightShader.time = 0; lightShader.bright = 1;
    lightShader.lightcol = [255., 241., 255.];
    if (Options.gameplayShaders && FlxG.save.data.godrays) stage.stageSprites["light"].shader = lightShader;
    else remove(stage.stageSprites["light"]);

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = 0.0;

    dust = new CustomShader("dust");
    dust.cameraZoom = FlxG.camera.zoom; dust.flipY = true;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    dust.time = 0; dust.res = [FlxG.width, FlxG.height];
    dust.OPACITY = 1;
    dust.LAYERS = 10; dust.DEPTH = .9;
    dust.WIDTH = .01; dust.SPEED = .3;
    dust.STARTING_LAYERS = 4;
    dust.pixely = false;
    dust.BRIGHT = 10;
    dust.Wzoom = 1;

    // camGame.addShader(chromWarp);
    if (Options.gameplayShaders && FlxG.save.data.bloom) FlxG.camera.addShader(bloom_new);
    if (Options.gameplayShaders) FlxG.camera.addShader(vig);
    if (Options.gameplayShaders && FlxG.save.data.particles) FlxG.camera.addShader(dust);
    if (Options.gameplayShaders) camHUD.addShader(vig);

    createDadClone(dadPos, 1.15);
    createBFClone(bfPos2, 1.25);

    //stage.getSprite("paps_bg").visible = false;
    //stage.getSprite("paps_fg").visible = false;

    remove(strumLines.members[3].characters[0]);
    insert(members.indexOf(dad)-1, strumLines.members[3].characters[0]);

    strumLines.members[3].characters[0].alpha = 0;
}

var undertaleFrameTime:Float = 1/30;
var undertaleFrameCounter:Float = 0;

var tottalTimer:Float = FlxG.random.float(100, 1000);  // Stole this from the snow shader script cuz I liked the idea lmfao  - Nex
function update(elapsed:Float) {
    tottalTimer += elapsed;
    lightShader.time = tottalTimer;

    undertaleFrameCounter += elapsed;
    if (undertaleFrameCounter > undertaleFrameTime) {
        undertaleFrameCounter = 0;
        dust.time = tottalTimer*.7;

    }
    dust.cameraZoom = FlxG.camera.zoom;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    dust.Wzoom = Math.max(0.9, 1 / (Lib.application.window.width/FlxG.width));

    // Sync Dad cool reflection
    if (dadClone != null) {
        if (dadClone.animation.name != dadClone.animation.name) 
            dadClone.animation.play(dad.animation.name, true);

        dadClone.animation.stop();
        dadClone.animation.frameIndex = dad.animation.frameIndex;

        if(dadClone.curCharacter.contains("player"))
		    dadClone.frameOffset.set(dad.frameOffset.x, -dad.frameOffset.y + (dad.frameHeight - dad.height));
        else
		    dadClone.frameOffset.set(dad.frameOffset.x, dad.frameOffset.y);

        dadClone.offset.set(dadClone.globalOffset.x * (dadClone.isPlayer != dadClone.playerOffsets ? 1 : -1), -dadClone.globalOffset.y);
        dadClone.setPosition(dad.x, dad.y + dadPos);
    }

    // Sync BF cool reflection
    if (bfClone != null) {
        if (bfClone.animation.name != bfClone.animation.name) 
            bfClone.animation.play(boyfriend.animation.name, true);

        bfClone.animation.stop();
        bfClone.animation.frameIndex = boyfriend.animation.frameIndex;

		bfClone.frameOffset.set(boyfriend.frameOffset.x, -boyfriend.frameOffset.y*.3);

        bfClone.offset.set(bfClone.globalOffset.x * (bfClone.isPlayer != bfClone.playerOffsets ? 1 : -1), -bfClone.globalOffset.y);
        bfClone.setPosition(boyfriend.x, boyfriend.y + (bfPos != null ? bfPos : bfPos2) + (2630 - boyfriend.y));
    }
}

function postUpdate(elapsed:Float) {
    var waveSpeed = tottalTimer * 2.1;
    var bobX = Math.sin(waveSpeed) * 50;
    var bobY = Math.cos(waveSpeed * 0.8) * 40 + Math.sin(waveSpeed * 1.5) * 10;

    strumLines.members[3].characters[0].x = dad.x + 500 + bobX;
    strumLines.members[3].characters[0].y = dad.y - 60 + bobY;
}

public function createDadClone(offset:Float, sizeChar:Float) {
    if (dadClone != null) {
        remove(dadClone);
        dadClone.destroy();
        dadClone = null;
    }

    dadClone = new Character(0, 0, dad.curCharacter);
    dadClone.scrollFactor.set(1, 1);
    dadClone.scale.set(sizeChar, sizeChar);
    dadClone.flipY = true;
    dadClone.alpha = 0.3;
    dadClone.setPosition(dad.x, dad.y + offset);
    dadClone.shader = dad.shader = colorShader;

    insert(members.indexOf(dad), dadClone);
}

public function createBFClone(offset:Float, sizeChar:Float) {
    if (bfClone != null) {
        remove(bfClone);
        bfClone.destroy();
        bfClone = null;
    }

    bfClone = new Character(0, 0, boyfriend.curCharacter);
    bfClone.scrollFactor.set(1, 1);
    bfClone.scale.set(sizeChar, sizeChar);
    bfClone.flipY = true;
    bfClone.alpha = 0.3;
    bfClone.setPosition(boyfriend.x, boyfriend.y + offset);
    bfClone.shader = boyfriend.shader = colorShader;

    insert(members.indexOf(boyfriend), bfClone);
}