//
import Date;
import funkin.backend.MusicBeatState;

import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxTextFormat;
import flixel.text.FlxText.FlxTextAlign;

import flixel.text.FlxText.FlxTextBorderStyle;

using StringTools;

FULL_VOLUME = true;

var script = importScript("data/scripts/skippableVideoUndertale");
PlayState.isStoryMode = false;

var videoStarted:Bool = false;

var lyrics:Array<Dynamic>;
var prevLyric = [];
var markup:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.WHITE), "\\");

var caption:FlxText;
var captionEcho:FlxText;
var clearText:Array<FlxText> = [];

var captionsFade:Bool = false;
//var debugMode:Bool = true;
//var debugString = "HIGGAMEON";
//var debugTxt;
//var yPose:Float = 0;

// okay so basically, I don't think they have the files to these videos anymore
// so im gonna force it myself >:) - hig
// I couldn't fit anyone new from special credits, I am sorry :(
// hopefully this'll be fixed in another update
var fakeCam:FlxCamera;
var moveVel:Float = 0;
var size:Float = 56;

function create() {

    menuType = data;

    var jsonPath:String = Paths.json("endings/" + data);
    if(Assets.exists(jsonPath)) {
        var raw = Assets.getText(jsonPath);
        try {
            lyrics = Json.parse(raw).lyrics;
        } catch (e:Dynamic) {trace('INVALID JSON PARSING : ' + e);}
    }

    caption = new FlxText(0, 625);
    caption.setFormat(Paths.font("8bit-jve.ttf"), 32, FlxColor.GRAY, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    caption.borderSize = 2;
    caption.alpha = 0;
    
    script.call("startVideo", [data + "_ending", () -> {
        MusicBeatState.skipTransOut = true;
        FlxG.switchState(new MainMenuState());
    }, "mp4", false]);
    script.set("onStart", () -> {
        videoStarted = true;
        startDate = Date.now().getTime();
        caption.camera = script.get("cutsceneCamera");
        add(caption);

        fakeCam = new FlxCamera(0,137, FlxG.width, 446);
        fakeCam.bgColor = 0x00FF0000;
        FlxG.cameras.add(fakeCam, false);
        video = script.get("vid");

        trace('start');
        //var higgTxt = createText("HIGGAMEON", 350, 5);
        if (menuType == "genocide") {
            moveVel = -105;
            createText("HIGGAMEON", 833, 2600);
            createText("NexusVGM", 845, 3537);
            createText("HIGGAMEON", 833, 9100);
            createText("Ralty", 880, 9145);
            createText("HeroEyad", 840, 9190);
        } else if (menuType == "secret") {
            fakeCam.y += 40;
            fakeCam.height -= 14;
            moveVel = -137;
            createText("HIGGAMEON", 850, 2660);
            createText("NexusVGM", 860, 3500);
            size = 45;
            createText("HIGGAMEON", 880 - 15, 9030);
            createText("Ralty", 920 - 15, 9050 + 20);
            createText("HeroEyad", 890 -  15, 9080 + 30);
            /*debugTxt = createText("Ralty", 895, 150);
            debugTxt.moves = false;
            yPose = debugTxt.y;*/
        } else if (menuType == "pacifist") {
            fakeCam.y += 28;
            fakeCam.height -= 57;
            createText("HIGGAMEON", 905, 8476).velocity.y = -168;
            createText("HIGGAMEON", 180, 4269).velocity.y = -65;
            createText("NexusVGM", 190, 5085).velocity.y = -65;
            createText("HIGGAMEON", 905, 22561 + 50).velocity.y = -220;
            createText("Ralty", 955, 22601 + 50).velocity.y = -220;
            createText("HeryEyad", 955, 22641 + 50).velocity.y = -220;
            moveVel = -220;
            //debugTxt = createText("HIGGAMEON", 905, 200);
            //debugTxt = createText("Ralty", 955, 200);
            //debugTxt.moves = false;
            //yPose = debugTxt.y;
        }

        fakeTextTimer = 0;
        timerStart = true;

        //debugTxt = createText("Ralty", 880, 9155);
        //debugTxt.moves = false;
    });

}

function createText(string, x, y) {
    var txt = new FunkinText(x, y, 0, string, 24, false);
    txt.antialiasing = true;
    txt.moves = true;
    txt.velocity.y = moveVel;
    txt.setFormat(Paths.font("8bit-jve.ttf"), size, 0xFFFFFFFF, 'center', FlxTextBorderStyle.NONE, FlxColor.BLACK);
    txt.camera = fakeCam;
    txt.angle = y;
    txt.onDraw = (spr) -> {
        if (updatePos)
            spr.angle = spr.y;
        var _y = spr.y;
        var _angle = spr.angle;
        spr.angle = 0;
        spr.y = _angle;
        spr.draw();
        spr.angle = _angle;
        spr.y = _y;

    }
    return add(txt);
    
}

var updatePos:Bool = false;
var fakeTextTimer:Float = -1;
var timerStart:Bool = false;

function update(elapsed:Float) {
    if(videoStarted) {
        /*if (debugTxt != null && !debugTxt.moves)
            yPose -= (moveVel * elapsed);
        if (FlxG.keys.justPressed.SPACE) {
            debugTxt.moves = true;
            trace(yPose);
        }*/
        if (timerStart)
            if (fakeTextTimer != -1) {
                fakeTextTimer += elapsed;
                if (fakeTextTimer >= 1/24) {
                    updatePos = true;
                    fakeTextTimer = 0;
                }
            }
        else timerStart = false;
        if (lyrics != null) {
            timer = (Date.now().getTime() - startDate - lateTimer) / 1000;
            var lyric = lyrics[0];
            if(lyric != null) {
                if(timer >= lyric[0] && caption.text != "\\*\\ " + lyric[1]) {
                    updateCaptions(lyric);
                    prevLyric = lyric;
                    lyrics.remove(lyric);
                }
            }
            var mult:Float = captionsFade ? -0.8 : 0.85;
            caption.alpha += (elapsed * mult);
        }
    }
}

function postDraw() {
    updatePos = false;
}

function updateCaptions(lyric:Array<Dynamic>) {
    if(lyric[1] == "")
        captionsFade = true;
    else {
        if(prevLyric[1] != null && (prevLyric[1].length != lyrics[0][1].length || lyrics[0][1] == "")) {
            for(i in clearText) {
                i.visible = false;
                clearText.remove(i);
            }
        }
        if(prevLyric[2]?.contains("fade") || prevLyric[2]?.contains("quickFade")) {
            var captionEcco = captureText(prevLyric[1], caption);
            add(captionEcco);

            FlxTween.num(caption.alpha, 0, prevLyric[2]?.fade ? 1.5 : 1, {ease: FlxEase.quadOut, onComplete: (_) -> captionEcco.destroy()}, (val:Float) -> {captionEcco.alpha = val;});
            clearText.push(captionEcco);
        }

        if(prevLyric[2]?.contains("longFade")) {
            var captionEcco = captureText(prevLyric[1], caption);
            add(captionEcco);

            clearText.push(captionEcco);
            FlxTween.num(caption.alpha, 0, 2, {ease: FlxEase.quadOut, onComplete: (_) -> captionEcco.destroy()}, (val:Float) -> {captionEcco.alpha = val;});
        }

        caption.text = "\\*\\ " + lyric[1];
        caption.applyMarkup(caption.text, [markup]);
        caption.updateHitbox();
        caption.screenCenter(FlxAxes.X);

        if(lyric[2]?.contains("fadeIn") || lyric[2]?.contains("quickFadeIn")) {
            var captionFade = captureText(lyric[1], caption);
            captionFade.color = FlxColor.GRAY;
            add(captionFade);

            clearText.push(captionFade);
            FlxTween.num(caption.alpha, 0, lyric[2].contains("fadeIn") ? 1.5 : 0.8, {ease: FlxEase.quartOut, onComplete: (_) -> captionFade.destroy()}, (val:Float) -> {captionFade.alpha = val;});
        }

        if(lyric[2]?.contains("fadeInLong")) {
            var captionFade = captureText(lyric[1], caption);
            captionFade.color = FlxColor.GRAY;
            add(captionFade);

            clearText.push(captionFade);
            FlxTween.num(caption.alpha, 0, 2, {ease: FlxEase.quartOut, onComplete: (_) -> captionFade.destroy()}, (val:Float) -> {captionFade.alpha = val;});
        }

        if(lyric[2]?.contains("ecco")) {
            var captionEcco = captureText(lyric[1], caption);
            captionEcco.blend = 0;
            add(captionEcco);

            clearText.push(captionEcco);
            FlxTween.num(1, 1.3, 1.25, {ease: FlxEase.circOut}, (val:Float) -> {captionEcco.scale.set(val, val);});
            FlxTween.num(1, 0, 1.25, {ease: FlxEase.circOut, onComplete: (_) -> captionEcco.destroy()}, (val:Float) -> {captionEcco.alpha = val;});
        }
        
        captionsFade = false;
    }
}

function captureText(lyricData:String, lyric:FlxText) {
    var capText:FlxText = new FlxText(lyric.x, 625);
    capText.setFormat(Paths.font("8bit-jve.ttf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.NONE, FlxColor.BLACK);
    capText.alpha = lyric.alpha;
    capText.camera = lyric.camera;

    var capturedText:String = "";
    for(i in 0...lyric.text.length) {
        var str:String = "* " + lyricData;
        var char:String = str.charAt(i + 1);
        if(char != "\\")
            capturedText += char;
        else
            break;
    }
    capText.text = "*" + capturedText;
    capText.x += capText.width;

    capturedText = "";
    var eccoIndex:Int = lyricData.indexOf("\\");
    for(i in 0...lyric.text.length - eccoIndex) {
        var char:String = lyricData.charAt(eccoIndex + i + 1);
        if(char != "\\")
            capturedText += char;
        else
            break;
    }
    capText.text = capText.text.charAt(capText.text.length);
    capText.x -= capText.width;
    capText.text = capturedText;

    return capText;
}

var timer:Float = 0;
var startDate:Date;
var lateDate:Date;
var lateTimer:Float = 0;

function onFocus()
    if (FlxG.autoPause) lateTimer += Date.now().getTime() - lateDate.getTime();

function onFocusLost()
    if (FlxG.autoPause) lateDate = Date.now();