//
import flixel.addons.effects.FlxTrail;
import openfl.Lib;
import flixel.text.FlxText;

var bgCam;
var water;
var tape_noise:CustomShader;
var warp:CustomShader;
var warp2:CustomShader;

var heartParticles:Array<FlxSprite> = [];
var heartParticleTimer:Float = 0;

var dadFloatTime:Float = 0;
var currentFloatSpeed:Float = 3; 
var currentFloatRadius:Float = 200; 

var dadBaseX:Float = 0;
var dadBaseY:Float = 0;
var dadFloatPhase:Float = 0;
var dadFloating:Bool = false;

var particlesActive:Bool = false;

var theEndText:FlxText;
var customUI:Array<FlxSprite>;

var dadClone:Character = null;
var bfClone:Character = null;
var glitch:CustomShader = null;
var glitchTimer:Float = 0;
var glitchValues:Array<Float> = [0.05, 0.15, 0.2, 0.3];
var dadPos:Float = 670;


function create() {
    bgCam = new FlxCamera(0, 0, 1280, 720);
    bgCam.bgColor = 0x00000000;
    camGame.bgColor = 0x00FFFFFF;


    FlxG.cameras.remove(camGame, false);
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(bgCam, false);
    FlxG.cameras.add(camGame, true);
    FlxG.cameras.add(camHUD, false);

    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 50; bloom_new.brightness = 1.7;
    bloom_new.directions = 16; bloom_new.quality = 5;
    bloom_new.threshold = .85;

    water = new CustomShader("waterDistortion");
    water.strength = 0.5;

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 0;

    warp = new CustomShader("warp");
    warp.distortion = 1;

    warp2 = new CustomShader("warp");
    warp2.distortion = 0;

    if (Options.gameplayShaders) {
        if (FlxG.save.bloom) camHUD.addShader(bloom_new);
        if (FlxG.save.data.water) bgCam.addShader(water);
        if (FlxG.save.data.static) bgCam.addShader(tape_noise);

        if (FlxG.save.data.warp) {
            bgCam.addShader(warp);
            camGame.addShader(warp2);
        }
    }

    autoTitleCard = false;
    bg_player.camera = bgCam;

    glitch = new CustomShader("glitching");
    
}

function onCountdown(countdown) countdown.cancel();

function postCreate() {
    //
    camGame.alpha = 0.0001;
    boyfriend.alpha = 0;

    customUI = [
            dustinHealthBG, dustinHealthBar,
            dustiniconP1, dustiniconP2,
            timeBarBG, timeTxt, timeBar
    ];

    for (element in customUI) {
        element.visible = false;
    }



    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    theEndText = new FlxText(0, 0, FlxG.width, "THE END");
    theEndText.setFormat(null, 100, 0xFFFF0000, "center");
    theEndText.screenCenter();
    theEndText.x = -1100;
    theEndText.y = 550;
    theEndText.cameras = [camGame]; 
    add(theEndText);
    theEndText.visible = false;
    //door.camera = bgCam;


}

function stepHit(step:Int) {
    switch (step) {
        case 256:
            FlxG.camera.shake(0.03, 0.4);

        case 258:
            camGame.alpha = 1;
            stage.getSprite("YOUAREtitlecard").playAnim("introtitle", false);

        // PAPS PART
        case 768:
            bg_player.visible = false;
            tv_player.visible = false;
            ground_player.visible = false;
            kinemorto.alpha = 1;
            kinemorto.camera = bgCam;
            light_player.alpha = 1;
            tape_noise.strength = 1;
            water.strength = 0.3;

            for (strumLine in strumLines) {
                for (sprite in strumLine.members) {
                    if (sprite != null) {
                        FlxTween.tween(sprite, {x: sprite.x + 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }

                for (note in strumLine.notes) {
                    if (note != null) {
                        FlxTween.tween(note, {x: note.x + 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }
            }

        case 1024:
            tape_noise.strength = 0;
            kinemorto.alpha = 0;
            water.strength = 0.5;
            light_player.alpha = 0.4;
            for (strumLine in strumLines) {
                for (sprite in strumLine.members) {
                    if (sprite != null) {
                        FlxTween.tween(sprite, {x: sprite.x - 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }

                for (note in strumLine.notes) {
                    if (note != null) {
                        FlxTween.tween(note, {x: note.x - 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }
            }

        case 1033:
            door.alpha = 1;
            clearTrails();
            spawnPapsTrail(dad);
            warp2.distortion = 2.5;

            dadBaseX = dad.x;
            dadBaseY = dad.y;
            dadFloating = true;
            dadFloatTime = 0; 
            currentFloatSpeed = 2; 
            currentFloatRadius = 300; 
            dad.alpha = 0.8;

        case 1311:
            door.alpha = 0;
            boyfriend.alpha = 0;
            clearTrails();
            warp2.distortion = 0;
            dadFloating = false;
            dad.x = dadBaseX;
            dad.y = dadBaseY;

            light_player.alpha = 1;

            bg_player.visible = true;
            tv_player.visible = true;
            ground_player.visible = true;
            tape_noise.strength = 0;
            particlesActive = true;

        case 1313, 1314, 1315:
            boyfriend.alpha = 0;

        // STYLE CHANGES

        case 1600:
            particlesActive = false;
            flowers.alpha = 1;
            bg_player.visible = false;
            tv_player.visible = false;
            ground_player.visible = false;
            light_player.alpha = 0;

        case 1828:
            flowers.alpha = 0;
            waterfall.alpha = 1;

        case 1952:
            waterfall.alpha = 0;
            HOTLANDFINALE.alpha = 1;

        case 2016:
            HOTLANDFINALE.alpha = 0;
            lab.alpha = 1;

        case 2096:
            lab.alpha = 0;
            pixel_bg.alpha = 1;
            theEndText.visible = true;

        // SANS PART

        case 2764:
            heart.alpha = 1;
            spawnPapsTrail(heart);
            heartBaseY = heart.y;
            boyfriend.alpha = 1;
            pixel_bg.alpha = 0;
            theEndText.visible = false;
            sans_bg.alpha = 1;
            sans_fg.alpha = 1;

            for (element in customUI) {
                element.visible = true;
            }

            for (strumLine in strumLines) {
                for (sprite in strumLine.members) {
                    if (sprite != null) {
                        FlxTween.tween(sprite, {x: sprite.x + 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }

                for (note in strumLine.notes) {
                    if (note != null) {
                        FlxTween.tween(note, {x: note.x + 250}, 1, {
                            ease: FlxEase.quadOut,
                        });
                    }
                }
            }

            createDadClone(dadPos, 0.75);

        case 3328:
            boyfriend.shader = glitch;

        case 3456:
            sans_bg.alpha = 0;
            sans_fg.alpha = 0;
    }
}

var iTime:Float = 0;
var tottalTimer:Float = FlxG.random.float(100, 1000);
var heartBaseY:Float = 0;
var heartFloatTime:Float = 0;
function update(elapsed:Float) {
    glitchTimer += elapsed;
        if (glitchTimer >= 0.15) {
            glitchTimer = 0;

            var randIndex = FlxG.random.int(0, glitchValues.length - 1);
            glitch.AMT = glitchValues[randIndex];
        } 

    water?.time = (tottalTimer += elapsed);

    tape_noise.time = tottalTimer;

    bgCam.zoom = camGame.zoom;
    bgCam.angle = camGame.angle;
    bgCam.target = camGame.target;
    bgCam.followLerp = camGame.followLerp;
    bgCam.deadzone = camGame.deadzone;


    if (dadFloating) {
        dadFloatPhase += elapsed * currentFloatSpeed;

        var dadFloatX = Math.sin(dadFloatPhase) * currentFloatRadius;
        var dadFloatY = Math.sin(dadFloatPhase * 2) * (currentFloatRadius / 2);

        dad.x = dadBaseX + dadFloatX;
        dad.y = dadBaseY + dadFloatY;
    }

    if (particlesActive && FlxG.save.data.particles) {
        heartParticleTimer += elapsed;
        if (heartParticleTimer > 0.3) { // rate
            heartParticleTimer = 0;

            var particle = new FlxSprite();
            particle.loadGraphic(Paths.image("game/monster_heart"));

            // POS
            var spawnRangeX = 2000;
            particle.x = ground_player.x + ground_player.width / 2 + FlxG.random.float(-spawnRangeX, spawnRangeX);
            particle.y = (ground_player.y + 1200) + FlxG.random.float(-5, 5);

            // SIZE
            var scale = FlxG.random.float(0.04, 0.08);
            particle.setGraphicSize(Std.int(particle.width * scale));
            particle.updateHitbox();

            particle.alpha = 0;
            particle.velocity.y = -FlxG.random.float(100, 120);

            particle.camera = camGame;
            insert(members.indexOf(tv_player), particle); 

            heartParticles.push(particle);
        }

        for (particle in heartParticles) {
            particle.y += particle.velocity.y * elapsed;

            if (particle.alpha < 0.5 && particle.y > ground_player.y - 100) {
                particle.alpha += elapsed * 5;
            } else {
                particle.alpha -= elapsed * 0.5;
            }

            if (particle.alpha <= 0) {
                remove(particle);
                heartParticles.remove(particle);
                particle.destroy();
            }
        }
    }

    // Sync Dad reflection
    if (dadClone != null) {
        if (dadClone.animation.name != dad.animation.name)
            dadClone.animation.play(dad.animation.name, true);

        dadClone.animation.stop();
        dadClone.animation.frameIndex = dad.animation.frameIndex;

        dadClone.frameOffset.set(dad.frameOffset.x, dad.frameOffset.y);
        dadClone.offset.set(
            dadClone.globalOffset.x * (dadClone.isPlayer != dadClone.playerOffsets ? 1 : -1),
            -dadClone.globalOffset.y
        );
        dadClone.setPosition(dad.x, dad.y + dadPos - 195);
    }

    // Sync BF reflection
    if (bfClone != null) {
        if (bfClone.animation.name != boyfriend.animation.name)
            bfClone.animation.play(boyfriend.animation.name, true);

        bfClone.animation.stop();
        bfClone.animation.frameIndex = boyfriend.animation.frameIndex;

        bfClone.frameOffset.set(boyfriend.frameOffset.x, -boyfriend.frameOffset.y * .3);
        bfClone.offset.set(
            bfClone.globalOffset.x * (bfClone.isPlayer != bfClone.playerOffsets ? 1 : -1),
            -bfClone.globalOffset.y
        );
        bfClone.setPosition(
            boyfriend.x,
            boyfriend.y + (bfPos != null ? bfPos : bfPos2) + (2630 - boyfriend.y)
        );
    }


    if (heart != null && heart.alpha != 0) {
        heartFloatTime += elapsed * 1.3; 
        heart.y = heartBaseY + Math.sin(heartFloatTime) * 50;
    }



}

var papsTrails:Array<FlxTrail> = [];

function spawnPapsTrail(sprite:FlxSprite) {
    var trail = new FlxTrail(sprite, null, 32, 11, 0.3, 0.045);
    trail.color = 0xFFC49F9F;
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

function clearHeartParticles() {
    for (p in heartParticles) {
        remove(p);
        p.destroy();
    }
    heartParticles = [];
}

function createDadClone(offset:Float, sizeChar:Float) {
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

    insert(members.indexOf(dad), dadClone);
}