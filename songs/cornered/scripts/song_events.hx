//
var gfShaderSprite;
var blackOverlay;
var beam;

var maxTimeTween:FlxTween;

public var finalHours:Bool = PlayState.variation == "final hours";

function postCreate() {
    blackOverlay = new FlxSprite();
    blackOverlay.makeGraphic(3000, 3000, FlxColor.BLACK);
    blackOverlay.scrollFactor.set(1, 1);
    blackOverlay.screenCenter();
    blackOverlay.alpha = 0;
    add(blackOverlay);

    beam = new Character(gf.x, gf.y, "LightBeameye", stage.isCharFlipped("LightBeameye", false));
    beam.visible = false;
    beam.x = gf.x;
    beam.y = gf.y;
    add(beam);

    beam.x += 600;
    beam.y += -225;

    gfShaderSprite = new Character(gf.x, gf.y, "undyne_hurt_white", stage.isCharFlipped("undyne_hurt_white", false));
    gfShaderSprite.alpha = 0;
    gfShaderSprite.x = gf.x;
    gfShaderSprite.y = gf.y;
    add(gfShaderSprite);

    customLengthOverride = finalHours ? 220000 : 199000;

    onEventCreation();

    frontEmitter.speed = backEmitter.speed = finalHours ? 0.5 : 0.7;
}

function update(elapsed:Float) {
    if (beam.visible) {
        switch (gf.animation.curAnim.name) {
            case "idle":
                beam.x = gf.x;
                beam.y = gf.y;

                beam.x += 600;
                beam.y += -225;
            case "singUP":
                beam.x = gf.x;
                beam.y = gf.y;
                
                beam.x += 600;
                beam.y += -370;
            case "singDOWN":
                beam.x = gf.x;
                beam.y = gf.y;
                
                beam.x += 710;
                beam.y += -140;
            case "singLEFT":
                beam.x = gf.x;
                beam.y = gf.y;
                
                beam.x += 450;
                beam.y += -235;
            case "singRIGHT":
                beam.x = gf.x;
                beam.y = gf.y;
                
                beam.x += 730;
                beam.y += -210;
            default:
                beam.x = gf.x;
                beam.y = gf.y;

                beam.x += 600;
                beam.y += -225;
        }
    }
}

function onEventCreation() {
    if(!finalHours) {
        addStepEvent(124, () -> {
            FlxTween.num(0.8, 0.5, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });

        addStepEvent(128, () -> {
            FlxTween.num(0.5, 1, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });
    }
    else if(finalHours) {
        addStepEvent(528, () -> {
            backEmitter.maxLimit = 80;
            frontEmitter.speed = 1.35;
            backEmitter.speed = 1.35;
        });

        addStepEvent(650, () -> {
            FlxTween.num(1.35, 0.7, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });

        addStepEvent(656, () -> {
            FlxTween.num(0.7, 1.35, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });

        addStepEvent(766, () -> {
            FlxTween.num(1.35, 1.25, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });

        addStepEvent(774, () -> {
            FlxTween.num(1.25, 1.15, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
        });

        addStepEvent(784, () -> {
            FlxTween.num(1.15, 1, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.quadOut}, (val:Float) -> {
                frontEmitter.speed = backEmitter.speed = val;
            });
            backEmitter.maxLimit = 40;
        });
    };

    addStepEvent(finalHours ? 1328 : 787, () -> {
        // Tween paps sturms to 0.3 alpha
        for (strum in cpuStrums.members)
            if (strum != null)
                FlxTween.tween(strum, {alpha: 0.3}, 0.75, {ease: FlxEase.sineInOut});
    });

    addStepEvent(finalHours ? 1712 : 1095, () -> {
        FlxTween.tween(dad, {alpha: 0}, 1.5, {ease: FlxEase.quadOut});
        FlxTween.tween(dustiniconP2, {alpha: 0}, 1.5, {ease: FlxEase.quadOut});
    });

    addStepEvent(finalHours ? 1984 : 1295, () -> { // first attack
        FlxG.camera.shake(0.015, 0.4);

        stage.stageSprites["BLASTER_IMPACT1"].alpha = 1;
        new FlxTimer().start(0.2, () -> {
            stage.stageSprites["BLASTER_IMPACT1"].alpha = 0;
            stage.stageSprites["BLASTER_IMPACT2"].alpha = 1;

            new FlxTimer().start(0.1, () -> {
                stage.stageSprites["BLASTER_IMPACT2"].alpha = 0;
                stage.stageSprites["BLASTER_IMPACT3"].alpha = 1;

                    new FlxTimer().start(0.1, () -> {
                stage.stageSprites["BLASTER_IMPACT3"].alpha = 0;
            });
            });
        });

        frontEmitter.alpha = 0.6;
        backEmitter.alpha = 0.4;
        backEmitter.maxLimit = 20;
        frontEmitter.maxLimit = 8;
    });

    addStepEvent(finalHours ? [1980, 3054] : [1292, 2154], () -> {
        stage.stageSprites["ATTACK"].alpha = 1;
        stage.stageSprites["ATTACK"].playAnim("appear");
    });

    addStepEvent(finalHours ? [1996, 3062] : [1304, 2162], () -> {
        stage.stageSprites["ATTACK"].playAnim("press",true);
    });

    addStepEvent(finalHours ? 2270 : 1526, () -> {
        FlxTween.tween(gfShaderSprite, { alpha: 1 }, 1.5);
        FlxTween.tween(blackOverlay, { alpha: 1 }, 1.5);
        FlxG.camera.shake(0.002, 0.3);
    });

    addStepEvent(finalHours ? 2272 : 1530, () -> {
        FlxG.camera.shake(0.004, finalHours ? 0.5 : 0.3);
    });

    if (finalHours) {
        addStepEvent(finalHours ? 2276 : 1530, () -> {
            FlxG.camera.shake(0.0045, 0.5);
        });

        addStepEvent(finalHours ? 2277 : 1530, () -> {
            FlxG.camera.shake(0.005, 0.5);
        });

        addStepEvent(finalHours ? 2278 : 1530, () -> {
            FlxG.camera.shake(0.00055, 0.5);
        });
    }

    addStepEvent(finalHours ? 2280 : 1533, () -> {
        FlxG.camera.shake(0.006, finalHours ? 0.6 : 0.4);
    });

    addStepEvent(finalHours ? 2282 : 1536, () -> {
        FlxG.camera.shake(0.008, finalHours ? 0.6 : 0.4);
    });

    addStepEvent(finalHours ? 2284 : 1539, () -> {
        FlxG.camera.shake(0.01, finalHours ? 0.5 :  0.3);
    });

    addStepEvent(finalHours ? 2286 : 1541, () -> {
        FlxG.camera.shake(0.015, 0.3);
    });

    addStepEvent(finalHours ? 2288 : 1543, () -> {
        FlxG.camera.shake(0.02, 0.5);
        beam.visible = true;
        gfShaderSprite.visible = false;
        blackOverlay.visible = false;

        stage.stageSprites["cracks"].alpha = 0;
        stage.stageSprites["bones"].alpha = 0;

        snow.call("enableSnow");
        snow.set("isOn", true);

        stage.stageSprites["bg_end"].alpha = 1;
        stage.stageSprites["ilumination_end"].alpha = 1;

        // Tween the max song length from 3:40 to 5:35 over 3 seconds
        if (maxTimeTween != null) maxTimeTween.cancel();

        var duration:Float = 3.0;
        var startLength:Float = customLengthOverride;
        var endLength:Float = 335000;

        iconGroup.group.remove(iconGroup.icons[1]);
        iconGroup.icons[1].destroy();
        iconGroup.group.add(iconGroup.icons[1] = createHealthIcon('undying', false)).ID = 1;

        maxTimeTween = FlxTween.num(startLength, endLength, duration, {ease: FlxEase.quadOut}, function(val:Float) {
            customLengthOverride = val;
        }, function() {
            customLengthOverride = endLength;
        });

        frontEmitter.maxLimit = 15;
        frontEmitter.duration = 2.25;

        frontEmitter.alpha = 0.8;
        frontEmitter.colors = [0xFF79FFD2, 0xFF409688];

        backEmitter.alpha = 1;
        backEmitter.duration = 0.35;
        
        backEmitter.colors = [0xFFA5ECFC, 0xFF408696];
        backEmitter.maxLimit = 40;
    });

    addStepEvent(finalHours ? 3088 : 2183, () -> {
        beam.visible = false;
    });

    addStepEvent(finalHours ? 3056 : 2157, () -> {
        backEmitter.maxLimit = 3;
        frontEmitter.maxLimit = 5;
        frontEmitter.speed = backEmitter.speed = 0.45;
        if(!finalHours) {
            //trace('crash out');
            snow.set("isOn", false);
            particleSprite.destroy();
            FlxG.camera.removeShader(snowShader2);
            //FlxG.camera.removeShader(snowShader);
        }
        FlxG.camera.shake(0.02, 0.6);

        stage.stageSprites["BLASTER_IMPACT4"].alpha = 1;
        new FlxTimer().start(0.2, () -> {
            stage.stageSprites["BLASTER_IMPACT4"].alpha = 0;
            stage.stageSprites["BLASTER_IMPACT5"].alpha = 1;

            new FlxTimer().start(0.1, () -> {
                stage.stageSprites["BLASTER_IMPACT5"].alpha = 0;
                stage.stageSprites["BLASTER_IMPACT6"].alpha = 1;

                    new FlxTimer().start(0.1, () -> {
                stage.stageSprites["BLASTER_IMPACT6"].alpha = 0;
            });
            });
        });
    });
}

function backgroundFade()
{
    trace('background fade');
    for(i => tag in ["bg", "bg_front", "wall_left", "wall_right", "bridge", "shards", "cracks", "bones"])
        FlxTween.tween(stage.stageSprites[tag], {alpha: 0}, i > 3 ? 3 : 2, {ease: FlxEase.quadOut});
    FlxTween.tween(frontEmitter, {alpha: 0}, 3, {ease: FlxEase.quadOut});
    FlxTween.tween(backEmitter, {alpha: 0}, 3, {ease: FlxEase.quadOut});

    FlxTween.tween(gf, {alpha: 0}, 2.5, {ease: FlxEase.quadOut});
    FlxTween.tween(dad, {alpha: 0}, 2.5, {ease: FlxEase.quadOut});
}

function phantomIn()
{
    trace('phantom in');
    heat.strength = 0.2;
    heat2.strength = 0.3;
    gf.alpha = 1;
    gf.visible = false;

    dad.alpha = 0;

    for (strum in cpuStrums.members)
        if (strum != null) strum.alpha = 0;

    for(i => tag in ["bg", "bg_front", "wall_left", "wall_right", "bridge", "shards", "cracks", "bones"])
        FlxTween.tween(stage.stageSprites[tag], {alpha: 1}, i > 3 ? 3.5 : 4.5, {ease: FlxEase.quadOut});

    FlxTween.tween(frontEmitter, {alpha: 0.6}, 3.5, {ease: FlxEase.quadOut});
    FlxTween.tween(backEmitter, {alpha: 0.6}, 3.5, {ease: FlxEase.quadOut});
    frontEmitter.colors = backEmitter.colors = [0xFFBEBEBE, 0xFF525252];
    frontEmitter.speed = 0.6;
    backEmitter.speed = 0.6;

    backEmitter.maxLimit = 20;
    frontEmitter.maxLimit = 8;

    new FlxTimer().start(Conductor.stepCrochet / 1000, () -> {
        dad.alpha = 0;
        iconGroup.group.visible = false;
        dustiniconP2.visible = true;
        FlxTween.tween(dad, {alpha: 1}, 3, {ease: FlxEase.quadOut});
    });
}

function phantomOut() {
    trace('phantom out');
    iconGroup.group.visible = true;
    dustiniconP2.visible = false;
    FlxTween.cancelTweensOf(dustiniconP2);
    FlxTween.cancelTweensOf(dad);
    dustiniconP2.alpha = iconGroup.group.members[0].alpha = iconGroup.group.members[1].alpha = iconGroup.group.alpha = 1; //idk why I have to do this but okay flxspritegroup
    
    dad.alpha = 1;
    dad.visible = true;
    dad.dance();
    gf.alpha = 1;
    heat.strength = 0;
    heat2.strength = 0;
    for (strum in cpuStrums.members)
        if (strum != null) strum.alpha = 1;
    gf.visible = true;

    frontEmitter.colors = [0xFF79FFD2, 0xFF409688];
    backEmitter.colors = [0xFFA5ECFC, 0xFF408696];

    frontEmitter.maxLimit = 15;
    frontEmitter.alpha = 0.8;

    backEmitter.alpha = 1;
    backEmitter.maxLimit = 40;

    frontEmitter.speed = 1;
    backEmitter.speed = 1;
}

//I'm reverting this later btw
// Event Handler, easier to setup for variants
var stepEventMap:Map<Int, Dynamic> = [];
function addStepEvent(step:Dynamic, func:Dynamic) {
    var isArray:Bool = step?.length != null;
    if(isArray) {
        for(sep in step) {
            stepEventMap.set(sep, func);
        }
    } else stepEventMap.set(step, func);
}

function stepHit(step:Int) {
    for(count in stepEventMap.keys()) {
        if(step >= count) {
            stepEventMap[count]();
            trace('new event at ' + count);
            stepEventMap.remove(count);
            break;
        }
    }
}