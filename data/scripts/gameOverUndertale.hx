//
PlayState.instance.scripts.importScript("data/scripts/FunkinTypeText");

import sys.FileSystem;
import Reflect;

var game_over:FunkinText;
var heart:FlxSprite;
var heartbroken:FlxSprite;
var quoteTextObj:FunkinTypeText;
var quoteText:FunkinTypeText;
var quoteString:String = PlayState.SONG.meta?.customValues?.gameover?.quote;
var songName:String = PlayState.SONG.meta?.customValues?.gameover?.song;
var soundName:String = PlayState.SONG.meta?.customValues?.gameover?.sound;

var gameOverEnd:Bool = false;

var heartbrokenBaseX;
var heartbrokenBaseY;

var glitch:CustomShader;
var bloom:CustomShader;

var pauseInfo = PlayState.instance.scripts.publicVariables.get("pauseInfo");

using StringTools;

function create(e) {
    for (cam in FlxG.cameras.list) {
        cam.visible = false;
    }

    bloom = new CustomShader("bloom");
    bloom.size = 40;
    bloom.brightness = 5;
    bloom.directions = 8;
    bloom.quality = 10;

    glitch = new CustomShader("glitching");
    glitch.SPEED = 1;
    glitch.AMT = 0.7;

    var soulType:Null<Bool> = pauseInfo.isMonster;

    if(soulType != null) FlxG.sound.play(Paths.sound('startBreak'), 1);
    e.cancel();
    FlxG.cameras.add(gameOverCam = new FlxCamera(), false);

    var textSpeach;
    var textSound = soundName == null ? "default" : soundName + "_talk";
    
    switch(soundName) {
        case "gf": textSpeach = "8bit-jve.ttf";
        case "paps": textSpeach = "papyrus.ttf";
        case "sans": textSpeach = "pixel-comic.ttf";
        case "swapsans": textSpeach = "pixel-comic.ttf";
        case "swappaps": textSpeach = "papyrus.ttf";
        case "fellsans": textSpeach = "pixel-comic.ttf";
        case "alphys": textSpeach = "8bit-jve.ttf";
        default: textSpeach = "8bit-jve.ttf";
    }

    game_over = new FunkinSprite().loadGraphic(Paths.image("game/gameover/gay_over"));
    game_over.scale.set(0.7, 0.7);
    game_over.updateHitbox();
    game_over.antialiasing = false;
    game_over.alpha = 0;
    game_over.cameras = [gameOverCam];
    add(game_over);
    game_over.screenCenter();
    if (songName == "genocides")
        game_over.y += 30;

    {
        var path =  Paths.getAssetsRoot().replace("./mods/dustin", "assets/") + "songs/" + PlayState.SONG.meta.name + "/quotes.txt";
        trace(Assets.exists(path));
        if(Assets.exists(path)) {
            var quoteType:String = "LOOP";
            var quotes:Array<String> = CoolUtil.coolTextFile(path);
            if(quotes[0].startsWith("type:")) {
                quoteType = quotes[0].replace("type:", "").toUpperCase();
                quotes.remove(quotes[0]);
            }
            if(quoteType == "RANDOM")
                quoteString = quotes[FlxG.random.int(0, quotes.length - 1)].replace("\\n", "\n");
            trace(quoteType);
            trace(quoteString);
        }
    }

    quoteTextObj = newFunkinTypeText(0, 500, FlxG.width, quoteString != null ? quoteString : "Don't lose hope!");
    quoteText = quoteTextObj.flxtext;
    quoteText.setFormat(Paths.font(textSpeach), 34, FlxColor.WHITE);
    quoteText.x = 0;
    quoteText.fieldWidth = FlxG.width;
    quoteText.cameras = [gameOverCam];
    quoteText.alignment = "center";
    quoteText.letterSpacing = 8;
    add(quoteText);
    quoteText.y = songName == "genocides" ? 370 : 530;
    quoteTextObj.defaultSound = FlxG.sound.load(Paths.sound('talk/' + textSound));

    if (soundName == "fellsans") {
        var fellColor:Int = FlxColor.fromString("#B93B3E");

        quoteText.color = fellColor;
        game_over.color = fellColor;
    }
    else if (soundName == "swapsans" || soundName == "swappaps") {
        var fellColor:Int = FlxColor.fromString("#FFADD5");

        quoteText.color = fellColor;
        game_over.color = fellColor;
    }
    
    var useBraveHeart:Bool =
        PlayState.SONG.meta.name.toLowerCase() == "lorem-ipsum";

    var heartPath:String = useBraveHeart
        ? "game/gameover/brave_heart"
        : (soulType
            ? "game/gameover/monster_heart"
            : "game/gameover/heart");
    heart = new FunkinSprite();
    if(soulType != null) heart.loadGraphic(Paths.image(heartPath));
    else heart.alpha = 0;
    heart.scale.set(3.2, 3.2);
    heart.updateHitbox();
    heart.antialiasing = false;
    heart.cameras = [gameOverCam];
    add(heart);
    heart.screenCenter();

    var positionToTween = heart.y + 80;
    heart.y = heart.y + (songName == "genocides" ? 500 : 400);

    var heartPath2:String = useBraveHeart
        ? "game/gameover/brave_heart_broken"
        : (soulType
            ? "game/gameover/monster_heart_broken"
            : "game/gameover/heart_broken");
    heartbroken = new FunkinSprite();
    if(soulType != null) heartbroken.loadGraphic(Paths.image(heartPath2));
    else heartbroken.alpha = 0;
    heartbroken.scale.set(3.2, 3.2);
    heartbroken.updateHitbox();
    heartbroken.antialiasing = false;
    heartbroken.cameras = [gameOverCam];
    heartbroken.visible = false;
    add(heartbroken);
    heartbroken.screenCenter();
    heartbroken.y = heartbroken.y + 80;

    heartbrokenBaseX = heartbroken.x;
    heartbrokenBaseY = heartbroken.y;

    whiteFlash = new FunkinSprite(0, 0).makeSolid(FlxG.width, FlxG.height, 0xFFFFFFFF);
    whiteFlash.alpha = 0;
    whiteFlash.scrollFactor.set();
    whiteFlash.scale.set(1920, 1080);
    whiteFlash.cameras = [gameOverCam];
    add(whiteFlash);

    if(soulType != null) {
        FlxTween.tween(heart, {y: positionToTween}, 2, {
            ease: FlxEase.quartInOut,
        });

        new FlxTimer().start(1.5, function() {
            gameOverCam.shake(0.005, 0.5);
        });
    }

    new FlxTimer().start(soulType != null ? 2 : .5, function() {
        FlxG.sound.playMusic(Paths.music('gameovers/' + songName), 0.8);
        if(soulType != null) {
            FlxG.sound.play(Paths.sound('endBreak'), 0.8);

            if (songName == "kinemorto" && FlxG.random.float() < 0.1)
                FlxG.sound.play(Paths.sound('umano'), 0.8);
        }

        if (Options.gameplayShaders) {
            if(FlxG.save.data.bloom) gameOverCam.addShader(bloom);
            if(FlxG.save.data.glitch) gameOverCam.addShader(glitch);
        }

        if(soulType != null) {
            FlxTween.num(2, 0, 2, {ease: FlxEase.quintOut}, function(num) {
                bloom.size = 20 * num;
                bloom.brightness = 1 + (20 * num);
                glitch.AMT = 0.1 * num;
                glitch.SPEED = 2 * num;
            });

            gameOverCam.shake(0.04, 0.2);
        } else {
            glitch.AMT = 0;
            bloom.size = 0;
            bloom.brightness = 0;
        }
        
        heartbroken.visible = true;
        heart.visible = false;

        FlxTween.tween(game_over, {alpha: 1}, soulType != null ? 2 : 1, {
            ease: soulType != null ? FlxEase.linear : FlxEase.quadOut,
            onComplete: function(_) {
                quoteTextObj.start(null, quoteTextObj);
                gameOverEnd = true;
            }
        });
    });
}

var iTime:Float = 0;
function update(elapsed:Float){
    iTime += elapsed;
    glitch.iTime = iTime;

    updateFunkinTypeText(elapsed*1.2, quoteTextObj);

    if (controls.ACCEPT || FlxG.mouse.justPressed && gameOverEnd){
        endGameOver();
    }
    if (controls.BACK && gameOverEnd){
        if (FlxG.sound.music != null) FlxG.sound.music.stop();
		FlxG.sound.music = null;
        
        FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
        PlayState.isStoryMode = false;
    }

    if (heartbroken.visible) {
        heartbroken.x = heartbrokenBaseX + FlxG.random.float(-1.5, 1.5);
        heartbroken.y = heartbrokenBaseY + FlxG.random.float(-1.5, 1.5);
    }
}

function endGameOver() {
    if (!gameOverEnd) return;

    gameOverEnd = false;

    FlxG.sound.music.stop();
    var sound:FlxSound = FlxG.sound.play(Paths.sound('gameovers/' + songName), 0.8);

    FlxTween.num(2, 0, 2, {ease: FlxEase.quintOut}, function(num) {
        bloom.size = 20 * num;
        bloom.brightness = 1 + (20 * num);
        glitch.AMT = 0.1 * num;
        glitch.SPEED = 2 * num;
    });

    gameOverCam.shake(0.04, 0.2);
    heartbroken.visible = false;
    heart.visible = true;

    new FlxTimer().start(2, function() {
        FlxTween.tween(gameOverCam, {zoom: 1.8}, 3, {ease: FlxEase.quadIn});
        FlxTween.tween(whiteFlash, { alpha: 1 }, 3, { ease: FlxEase.sineOut });

        new FlxTimer().start(4, function() {
            FlxG.switchState(new PlayState());
        });
    });
}

function destroy() {
}
