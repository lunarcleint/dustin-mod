//
public var tvScreen:FlxCamera;
var pixel:CustomShader;
var pixel2:CustomShader;
var strumShiftAmount:Float = -320;
var strumsShifted:Bool = false;
var asriel;
var itslikeprettywarpedtoo:CustomShader = null;
var starthittingthegriddy:Bool = false;
var distorsion_ammount:Float = 0.3;
var isGlitch:Bool = false;
var isGlitch2:Bool = false;

var glitch:CustomShader = null;
var glitch2:CustomShader = null;

var glitchTimer:Float = 0;
var glitchValues:Array<Float> = [0.03, 0.05, 0.07, 0.1];
var glitchValues2:Array<Float> = [0.4, 0.6, 0.8, 1];

var asrielBaseX:Float = 0;
var asrielBaseY:Float = 0;
var asrielOrbitTime:Float = 0;
var asrielOrbitRadius:Float = 60;
var asrielOrbitSpeed:Float = 2; 

function create() {
    tvScreen = new FlxCamera(0, 0, 1280, 720);
    tvScreen.bgColor = 0xFFFF0000;

    FlxG.cameras.remove(camGame, false);
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.remove(camHUD2, false);
    FlxG.cameras.add(tvScreen, false);
    FlxG.cameras.add(camGame, true);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.add(camHUD2, false);
}

function postCreate() {
    red.camera = tvScreen;
    school.camera = tvScreen;
    school.visible = false;

    oldstatic = new CustomShader("static");
    oldstatic.time = 0; oldstatic.strength = 20;
    if (Options.gameplayShaders && FlxG.save.data.static) tvScreen.addShader(oldstatic);

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 3;
    if (Options.gameplayShaders && FlxG.save.data.static) tvScreen.addShader(tape_noise);

    camGame.bgColor = 0x00000000;

    // autoTitleCard = false;

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    pixel = new CustomShader("pixel");
    pixel.blockSize = 1.0;
    pixel.res = [FlxG.width, FlxG.height];

    pixel2 = new CustomShader("pixel");
    pixel2.blockSize = 1.0;
    pixel2.res = [FlxG.width, FlxG.height];


    asriel = new Character(0, 0, 'asriel_dustshift');
    asriel.scrollFactor.set(1, 1);
    asrielBaseX = dad.x - 400;
    asrielBaseY = dad.y - 200;
    asriel.x = asrielBaseX;
    asriel.y = asrielBaseY;

    asriel.alpha = 0;
    insert(members.indexOf(dad), asriel);

    itslikeprettywarpedtoo = new CustomShader("chromaticWarp");

    if (FlxG.save.data.distortion && FlxG.save.data.chromwarp) camGame.addShader(itslikeprettywarpedtoo);
    if (FlxG.save.data.distortion && FlxG.save.data.chromwarp) tvScreen.addShader(itslikeprettywarpedtoo);
    itslikeprettywarpedtoo.distortion = 0;


    glitch = new CustomShader("glitching");
    glitch2 = new CustomShader("glitching");
    if (Options.gameplayShaders && FlxG.save.data.glitch) camGame.addShader(glitch);
    if (Options.gameplayShaders && FlxG.save.data.glitch) tvScreen.addShader(glitch2);

    glitch.AMT = 0;
    glitch2.AMT = 0;
}

function onSongStart() {
    if (pixel != null) {
        if (Options.gameplayShaders && FlxG.save.data.pixel) camGame.addShader(pixel);
        if (Options.gameplayShaders && FlxG.save.data.pixel) camHUD2.addShader(pixel);
        if (Options.gameplayShaders) tvScreen.addShader(pixel2);

        FlxTween.num(16, 0.001, (Conductor.stepCrochet / 1000) * 26, {ease: FlxEase.circOut}, (val:Float) -> {pixel.blockSize = val;});
        FlxTween.num(16, 0.001, (Conductor.stepCrochet / 1000) * 26, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});
    }
}

var iTime:Float = 0;
function update(elapsed:Float) {
    oldstatic.time += elapsed;
    tape_noise.time += elapsed;
    iTime += elapsed;

    tvScreen.zoom = camGame.zoom;
    tvScreen.angle = camGame.angle;
    tvScreen.target = camGame.target;
    tvScreen.followLerp = camGame.followLerp;
    tvScreen.deadzone = camGame.deadzone;

    if (asriel != null && asriel.alpha > 0) {
        asrielOrbitTime += elapsed * asrielOrbitSpeed;

        var offsetX = Math.cos(asrielOrbitTime) * asrielOrbitRadius;
        var offsetY = Math.sin(asrielOrbitTime) * asrielOrbitRadius * 0.5;

        asriel.x = asrielBaseX + offsetX;
        asriel.y = asrielBaseY + offsetY;
    }


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

}

function onDadHit(note:Note):Void {
    if (asriel != null && asriel.alpha != 0) {
        var dirNames = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
        var animName = 'sing' + dirNames[note.direction];
        asriel.playAnim(animName, true);
    }
}

function stepHit(step:Int) {
    switch (step) {
        case 16:
            itslikeprettywarpedtoo.distortion = 1;

            FlxTween.num(1, 0, 0.5, {
                ease: FlxEase.quadOut}, 
                function(val:Float) {
                    itslikeprettywarpedtoo.distortion = val;}

            );
        case 1728:
            shiftStrums();
            asriel.alpha = 0;

        case 1744:
            boyfriend.camera = tvScreen;

        case 1072:
            asriel.alpha = 0;
            FlxTween.tween(asriel, {alpha: 0.4}, 8, {ease: FlxEase.quadInOut});

        case 1202:
            FlxTween.tween(asriel, {alpha: 0.85}, 2, {ease: FlxEase.quadInOut});

        case 144 | 150 | 160 | 166 | 176 | 182 | 192 | 198 | 208 | 214 | 224 | 230 | 240 | 246 | 256 | 262:
            itslikeprettywarpedtoo.distortion = 0.7;

            FlxTween.num(0.7, 0, 0.5, {
                ease: FlxEase.quadOut}, 
                function(val:Float) {
                    itslikeprettywarpedtoo.distortion = val;}

            );

        case 304:
            starthittingthegriddy = true;

        case 272:
            FlxTween.num(0.001, 20, (Conductor.stepCrochet / 1000) * 26, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 305:
            FlxTween.num(20, 0.001, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 560:
            starthittingthegriddy = false;

        case 816:
            FlxTween.num(0.001, 20, (Conductor.stepCrochet / 1000) * 120, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 944:
            starthittingthegriddy = true; 
            distorsion_ammount = 0.5;
            isGlitch2 = true;
            isGlitch = true;
            school.visible = true;
            FlxTween.num(20, 5, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 1473:
            starthittingthegriddy = true; 
            distorsion_ammount = 0.8;
            isGlitch2 = true;
            isGlitch = true;
            school.visible = true;
            FlxTween.num(20, 5, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});


        case 1204 | 1728:
            starthittingthegriddy = false; 
            isGlitch2 = false;
            isGlitch = true;
            school.visible = false;
            FlxTween.num(20, 0.001, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});


        case 1745:
            starthittingthegriddy = false; 
            isGlitch2 = false;
            isGlitch = false;
            glitch.AMT = 0;
            glitch2.AMT = 0;
            FlxTween.num(20, 0.001, (Conductor.stepCrochet / 1000) * 12, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 2000:
            isGlitch2 = true;
            isGlitch = true;
            starthittingthegriddy = true; 
            distorsion_ammount = 0.5;
            glitchValues2 = [0.1, 0.2, 0.3, 0.4];

        case 2207:
            starthittingthegriddy = false; 

        case 2564:
            starthittingthegriddy = true; 
            distorsion_ammount = 0.2;
            isGlitch2 = true;
            isGlitch = true;
            FlxTween.num(20, 3, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.circOut}, (val:Float) -> {pixel2.blockSize = val;});

        case 2692:
            FlxTween.num(0.001, 5, (Conductor.stepCrochet / 1000) * 64, {ease: FlxEase.circOut}, (val:Float) -> {pixel.blockSize = val;});

        case 2772:
            FlxTween.num(3, 8, (Conductor.stepCrochet / 1000) * 64, {ease: FlxEase.circOut}, (val:Float) -> {pixel.blockSize = val;});

        case 2757:
            starthittingthegriddy = false; 

        case 2309:
            glitchValues2 = [0.4, 0.6, 0.8, 1];

    }
}

function shiftStrums():Void {
    var shift = strumsShifted ? -strumShiftAmount : strumShiftAmount;
    var tweenTime = 2;
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

            FlxTween.tween(scoreTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(accuracyTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(missesTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBG, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP1, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP2, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeBarBG, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeBar, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});

            for (strum in playerStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: 0.8}, 3, {ease: FlxEase.quadOut});

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    FlxTween.tween(note, {alpha: 0.8}, 3, {ease: FlxEase.quadOut});

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