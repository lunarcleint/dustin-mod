//
var blaster:FlxSprite;
var space:FlxSprite;

public var canDodge:Bool = false;
var dodging:Bool = false;
var dodgeTimer:Float = 0;
var dodgeCooldown:Float = 0;

function create() {
    blaster = stage.stageSprites["BLASTER"];
    blaster.y -= 600;
    blaster.x -= 900;

    blaster.cameras = [camCharacters];
    blaster.visible = false;

    stage.stageSprites["BLASTER_IMPACT1"].cameras = [camCharacters];
    stage.stageSprites["BLASTER_IMPACT2"].cameras = [camCharacters];

    space = stage.stageSprites["PRESS_SPACE"];
    space.alpha = 0;
}

function stepHit(step:Int) {
    switch (step) {
        case 2236:
            /*
            for (i => strumLine in strumLines.members) 
                for (k=>s in strumLine.members)
                    FlxTween.tween(s, {alpha: 0}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});

            for (s in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2])
                FlxTween.tween(s, {alpha: 0}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            */
        case 2192: canDodge = true;
        case 2256:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 0}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut});
            if (FlxG.save.data.mechanics) FlxTween.tween(space, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});

            blaster.visible = true;
            FlxTween.tween(blaster, {y: 920}, (Conductor.stepCrochet / 1000) * 10, {ease: FlxEase.sineInOut});
            // .then(FlxTween.tween(blaster, {y: 900}, ((Conductor.getTimeForStep(2280)-Conductor.getTimeForStep(2266))/2)/1000, {type: 4 /*PINGPONG*/}));
            FlxTween.tween(blaster, {x: 1080}, (Conductor.stepCrochet / 1000) * 13, {ease: FlxEase.cubeOut});
        case 2278:
            if (!FlxG.save.data.mechanics)
                boyfriend.playAnim("dodge", true);
        case 2280: 
            // FlxTween.cancelTweensOf(blaster); blaster.y = 920;

            space.visible = false;
            blaster.playAnim("blast");
            for (cam in FlxG.cameras.list) cam.visible = false;
            new FlxTimer().start(0.06, () -> {
                shaketime = .57; cancelCamMove = true; lerpCamZoom = false;

                for (cam in FlxG.cameras.list) cam.visible = true;
                camForeground.removeShader(screenVignette);
                camForeground.visible = false;

                stage.stageSprites["BLASTER_IMPACT1"].alpha = 1;
                new FlxTimer().start(0.08, () -> {
                    stage.stageSprites["BLASTER_IMPACT1"].alpha = 0;
                    stage.stageSprites["BLASTER_IMPACT2"].alpha = 1;

                    new FlxTimer().start(0.09, () -> {
                        cancelCamMove = false; lerpCamZoom = true;

                        if (Options.gameplayShaders) camForeground.addShader(screenVignette);
                        camForeground.visible = true;
                        
                        stage.stageSprites["BLASTER_IMPACT2"].alpha = 0;

                        executeEvent({name: "Bloom Effect", time: 0, params: [false, 2, 4, "linear", "In"]});
                        executeEvent({name: "Bloom Effect", time: 0, params: [true, 1, 2, "quad", "Out"]});

                        FlxTween.num(7, 1.4, ((Conductor.stepCrochet / 1000) * 6)-0.24, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.brightness = val;});
                        FlxTween.num(60, 10, ((Conductor.stepCrochet / 1000) * 6)-0.24, {ease: FlxEase.quadOut}, (val:Float) -> {bloom_new.size = val;});

                        snowShader2.LAYERS = 36; snowShader.LAYERS = 37; 
                        camCharacters.removeShader(snowShader2);
                        if (Options.gameplayShaders && FlxG.save.data.particles) camForeground.addShader(snowShader2);

                        snowShader2.snowMelts = false;

                        camForeground.removeShader(screenVignette);
                        if (Options.gameplayShaders) camHUD2.addShader(screenVignette);

                        // camHUD.addShader(chromWarp);
                    });
                });
            });
        case 2281: // makes it where you can actually press space on beat now
            if (!dodging) health = 0.05;
            canDodge = false;
        case 2284:
            for (element in hudElements)
                FlxTween.tween(element, {alpha: 1}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut});
            /*
            for (i => strumLine in strumLines.members) 
                for (k=>s in strumLine.members)
                    FlxTween.tween(s, {alpha: 1}, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.quadOut});

            for (s in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2])
                FlxTween.tween(s, {alpha: 1}, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.quadOut});
            */
    }
}

public var shaketime:Float = 0;
function update(elapsed:Float) {
    if (shaketime > 0) {
        var xMod:Float = FlxG.random.float(-1, 1);
        var yMod:Float = FlxG.random.float(-1, 1);

        for (cam in [camGame, camCharacters, camHUD,camHUD2]) {
            cam.scroll.x += xMod; cam.scroll.y += yMod;
        }
        shaketime -= elapsed;
    }

    if (!FlxG.save.data.mechanics) return;

    if (!dodging && dodgeCooldown <= 0 && canDodge && FlxG.keys.justPressed.SPACE) {
        dodging = true; dodgeTimer = .8; 
        boyfriend.playAnim("dodge", true);
    }

    if (dodging && dodgeTimer <= 0) {
        dodging = false; dodgeCooldown = 0.2;
        if (boyfriend.animation.name == "dodge")
            boyfriend.dance();
    }

    dodgeTimer -= elapsed;
    dodgeCooldown -= elapsed;
}