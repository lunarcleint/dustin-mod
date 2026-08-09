//

//TODO: organize this code if I feel like it - hig

import funkin.menus.FreeplayState.FreeplaySonglist;
import flixel.math.FlxRect;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.addons.effects.FlxTrail;
import funkin.savedata.FunkinSave;
import funkin.backend.MusicBeatState;

using StringTools;

import Date;
var t = Date.now();

var boxes:Array<Dynamic> = [];
var portraits:Array<FunkinSprite> = [];
var outlineSize:Float = 10;

var bloom = new CustomShader("bloom");
bloom.size = 1;
bloom.brightness = 1;
bloom.directions = 8;
bloom.quality = 10;

var glitch = new CustomShader("glitching");
glitch.SPEED = 1;
glitch.AMT = 0;

var curSelected:Int = 0;

var allowInput:Bool = true;
public var tvScreen:FlxCamera;
var cds:Array<FunkinSprite> = [];

var cdSpinSpeed:Float = 0;
var spinningCD:FunkinSprite = null;
var bg;
var bgtv;
var fg;

var ink:FunkinSprite = null;
var genocidesText:FunkinText = null;
var nullObjectText:FunkinText = null;

var seedeeznuts:FunkinSprite = new FunkinSprite(0, 0, Paths.image("menus/shop/cds_images/perseverance"));

function loadCD(name:String) {
    seedeeznuts.loadGraphic(Paths.image("menus/shop/cds_images/" + name));
    seedeeznuts.updateHitbox();
}

var scoreBg:FlxSpriteGroup;

var variant(get, never):Null<String>;
function get_variant() return curVariant == "Vanilla" ? null : curVariant;
static var curVariant:String = "Vanilla";
var variants:Array<String> = ["Vanilla"];

var warningHue:Float = 0;
var variantBg:FlxSpriteGroup;
var variantText:FlxText;
var warningText:FlxText;
var warningTextTrail:FlxTrail;

var scoreText:FlxText;
var scoreText2:FlxText;
var score:Dynamic = {value: 0, lerpValue: 0};
var misses:Dynamic = {value: 0, lerpValue: 0};
var accuracy:Dynamic = {value: 0, lerpValue: 0};

//yolo
var frontCam:FlxCamera;
var frontPortrait:FunkinSprite;

//if shaders are off
var whiteCover:FunkinSprite;

var varientQNA:FlxSpriteGroup;
var waitingVariantResponse:Bool = false;

using StringTools;

function hasSong(song) {
    var songName:String = song.name.toLowerCase();
    return (songName == "perseverance" || dustinShop["keys"][songName] || dustinShop["cds"][songName] || FunkinSave.getSongHighscore(song.name, "hard").score > 0);
}

function hasPortrait(song):Bool {
    var portraitName:String = song.displayName.toLowerCase().replace(' ', '-');
    return Assets.exists(Paths.image('menus/freeplay/portraits/' + portraitName));
}

function loadPortrait(portrait:FlxSprite, name:String) {
    var portraitPath:String = 'menus/freeplay/portraits/' + name;
    if (Assets.exists(Paths.image(portraitPath))) {
        portrait.frames = Paths.getFrames(portraitPath);
        portrait.addAnim('idle', 'idle0', 24, true);
        portrait.addAnim('start', 'start0', 24, false);
        portrait.playAnim('idle');
        portrait.scale.set(0.61, 0.61);
    } else {
        portrait.visible = false;
        portrait.alpha = 0.0001;
        return;
    }
    portrait.updateHitbox();
    portrait.screenCenter();
    portrait.x = FlxG.width * 0.75 - portrait.width / 2;
    portrait.scrollFactor.set();
    portrait.antialiasing = Options.antialiasing;
    portrait.y = portrait.y + 3;

    portrait.alpha = (portrait.ID == curSelected ? 1 : 0.0001);

    if (name == "yolo") {
        portrait.x -= 14;
        portrait.y -= 27;
    }

    #if desktop
    if (name == "genocides" && genocidesText == null) {
        genocidesText = textCrispy(new FunkinText(portrait.x - 100, portrait.y - 100, portrait.width + 200, "If the song is bugged for you, uncheck Options > Miscellaneous > Genocides Swag."));
        genocidesText.setFormat(Paths.font("fallen-down.ttf"), 14, 0xFFFFFFFF);
        genocidesText.scrollFactor.set();
    }
    #end

    if (name == "uncreate" && ink == null) {
        ink = new FunkinSprite(0, 0, Paths.image('menus/freeplay/Inks_artWork'));
        ink.addAnim('paint', 'Inks_handWork0', 24, true);
        ink.visible = false;
        ink.scrollFactor.set();
        ink.scale.set(0.61, 0.61);
        ink.updateHitbox();
        ink.screenCenter();
        ink.x += 767;
        ink.y -= 225;
    }
}

function create() {
    playMusic('storyNfreeplay', 1, true);

    frontPortrait = new FunkinSprite(0, 0);

    frontPortrait.frames = Paths.getFrames('menus/freeplay/portraits/yolo_front');
    frontPortrait.addAnim('idle', 'idle0', 24, true);
    frontPortrait.addAnim('start', 'start0', 24, false);
    frontPortrait.playAnim('idle');
    frontPortrait.scale.set(0.61, 0.61);
    frontPortrait.updateHitbox();
    frontPortrait.screenCenter();
    frontPortrait.x = FlxG.width * 0.75 - frontPortrait.width / 2;
    frontPortrait.scrollFactor.set();
    frontPortrait.antialiasing = Options.antialiasing;
    frontPortrait.y = frontPortrait.y + 3;
    frontPortrait.x -= 14;
    frontPortrait.y -= 27;

    add(frontPortrait);
    
    FlxG.camera.bgColor = 0xFF050505;

    // RIGHT PORTRAITS
    var freeplaySongList = FreeplaySonglist.get();

    var firstPortrait:FunkinSprite;
    if (Options.freeplayLastSong == null)
        Options.freeplayLastSong = "perseverance";
    if (hasSong({name: Options.freeplayLastSong.toLowerCase().replace(' ', '-')})) {

        firstPortrait = new FunkinSprite(0, 0);
        loadPortrait(firstPortrait, Options.freeplayLastSong.toLowerCase());
    }
    
    for (i => song in freeplaySongList.songs) {
        if (firstPortrait != null && song.name == Options.freeplayLastSong.toLowerCase().replace(' ', '-')) {
            firstPortrait.ID = i;
            portraits.push(firstPortrait);
            add(firstPortrait);
            continue;
        }
        var name = song.displayName.toLowerCase();
        name = name.replace(' ', '-');

        var portrait:FunkinSprite;
        

        if(hasSong(song)) {
            portrait = new FunkinSprite(0, 0);
            add(portrait);
            portraits.push(portrait);

            portrait.ID = i;
            
            loadPortrait(portrait, name);
        } else portraits.push(new FunkinSprite());
    }

    bg = new FunkinSprite().loadGraphic(Paths.image('menus/freeplay/desk/bg_freeplay'));
    bg.antialiasing = false;
    bg.scale.set(0.67, 0.67);
    bg.updateHitbox();
    bg.screenCenter();
    bg.scrollFactor.set();
    add(bg);

    bgtv = new FunkinSprite().loadGraphic(Paths.image('menus/freeplay/desk/bg_freeplay_tv'));
    bgtv.antialiasing = false;
    bgtv.scale.set(0.67, 0.67);
    bgtv.updateHitbox();
    bgtv.screenCenter();
    bgtv.scrollFactor.set();
    add(bgtv);

    fg = new FunkinSprite().loadGraphic(Paths.image('menus/freeplay/desk/fg_freeplay'));
    fg.antialiasing = false;
    fg.scale.set(0.67, 0.67);
    fg.updateHitbox();
    fg.screenCenter();
    fg.scrollFactor.set();
    add(fg);

    for(folder in Paths.getFolderDirectories("images/menus/freeplay/desk/")) {
        trace(folder);
        for(graphic in ["bg_freeplay", "bg_freeplay", "fg_freeplay"])
            graphicCache.cache(Paths.image("menus/freeplay/desk/" + folder + '/' + graphic));
    }

    tvScreen = new FlxCamera(0, 0, 1280, 720);
    tvScreen.bgColor = 0xFF000000;

    frontCam = new FlxCamera(0, 0, 1280, 720);
    frontCam.bgColor = FlxColor.TRANSPARENT;

    oldstatic = new CustomShader("static");
    oldstatic.time = 0; oldstatic.strength = 5;

    FlxG.cameras.remove(FlxG.camera, false);
    FlxG.cameras.add(tvScreen, false);
    FlxG.cameras.add(FlxG.camera, true);
    FlxG.cameras.add(frontCam, false);

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 1;

    if (Options.gameplayShaders) {
        if (FlxG.save.data.static) {
            tvScreen.addShader(oldstatic);
            frontCam.addShader(oldstatic);

            if (FlxG.save.data.bloom) for(cam in [tvScreen, FlxG.camera, frontCam]) cam.addShader(bloom);
            if (FlxG.save.data.glitch) for(cam in [tvScreen, FlxG.camera, frontCam]) cam.addShader(glitch);

            tvScreen.addShader(tape_noise);
        }
    }

    nullObjectText = new FunkinText(0, 0, FlxG.width, "> NULL OBJECT EXCEPTION", 30, false);
    nullObjectText.setFormat(Paths.font("8bit-jve.ttf"), 30, FlxColor.RED, "center");
    nullObjectText.scrollFactor.set();
    nullObjectText.screenCenter();
    nullObjectText.camera = tvScreen;
    nullObjectText.visible = false;
    add(nullObjectText);
    nullObjectText.x += 280;
    nullObjectText.y += 150;

    FlxG.camera.bgColor = 0x00000000;

    seedeeznuts.scale.set(0.5, 0.5);
    seedeeznuts.updateHitbox();
    seedeeznuts.screenCenter();
    seedeeznuts.x = FlxG.width * 0.9 - seedeeznuts.width / 2;
    seedeeznuts.scrollFactor.set();
    seedeeznuts.y = seedeeznuts.y + 270;
    add(seedeeznuts).antialiasing = Options.antialiasing;

    seedeeznuts.origin.x += 25; seedeeznuts.origin.y += 5;

    // LEFT BOXES
    for (i => song in freeplaySongList.songs) {

        graphicCache.cache(Paths.image("menus/shop/cds_images/" + song.name.toLowerCase()));
        if (song.name == Options.freeplayLastSong) {
            curSelected = i;
            loadCD(song.name.toLowerCase());
        }


        var boxOutline = new FunkinSprite().makeSolid(600, 95, 0xFFFFFFFF);
        boxOutline.setPosition(10, 10 + 220 * i);
        add(boxOutline);

        var boxBG = new FunkinSprite().makeSolid(boxOutline.width - outlineSize / 2, boxOutline.height - outlineSize / 2, 0xFF000000);
        boxBG.setPosition(boxOutline.x + boxOutline.width / 2 - boxBG.width / 2, boxOutline.y + boxOutline.height / 2 - boxBG.height / 2);
        add(boxBG);

        var songDisplayName:String = song.customValues.customName != null ? song.customValues.customName : song.displayName;
        if(!hasSong(song))
            songDisplayName = hideStr(songDisplayName);
        var nameTxt = new FunkinText(0, 0, boxBG.width, songDisplayName , 36, false);
        nameTxt.setFormat(Paths.font("fallen-down.ttf"), 36, 0xFFFFFFFF);
        nameTxt.setPosition(boxBG.x + boxBG.width / 2 - nameTxt.width / 2, boxBG.y);
        nameTxt.alignment = "center";
        add(nameTxt);

        var divider = new FunkinSprite().makeSolid(boxBG.width - 40, 2, 0xFFFFFFFF);
        divider.setPosition(boxBG.x + 20, boxBG.y + nameTxt.height + 10);
        add(divider);

        // === CREDITS DISPLAY (split by category) ===
        var info = song;
        var creditData = info.customValues != null && hasSong(info) ? info.customValues.credits : null;

        var creditLabels = ["SONG", "SPRITES", "BACKGROUND", "CHART"];
        var creditColors = [0xFF1db2f0, 0xFFf50334, 0xFFbe2879, 0xFFa31be0];

        var labelTexts:Array<FunkinText> = [];
        var valueTexts:Array<FunkinText> = [];

        var currentY = divider.y + divider.height + 10;

        var creditMap:Map<String, Array<String>> = [];

        for(v in variants) {
            if (creditMap[v] != null)
                continue;
            var info = v == "Vanilla" ? song.customValues.credits : null;
            if(v != "Vanilla" && song.metas[v] != null && song.metas[v].customValues.credits != null) {
                info = song.metas[v].customValues.credits;
                if(!variants.contains(v.toLowerCase()))
                    variants.push(v.toLowerCase());
            }
            creditMap[v] = info;
        }

        // this was done last minute sorry
        for (file in Paths.getFolderContent("songs/" + song.name, false, -1, true)) {
            if (file.startsWith("meta-")) {
                var varientTable = file.split("meta-");
                var v:String = "";
                for (i => varient in varientTable) {
                    if (i != 0)
                        v += varient;
                }
                if (creditMap[v] != null)
                    continue;
                if (song.metas[v] == null) {
                    var creds = Json.parse(Assets.getText(Paths.getPath("songs/" + song.name + "/" + file + ".json")));
                    if (creds.customValues?.credits != null) {
                        song.metas[v] = creds;
                        creditMap[v] = creds.customValues.credits;
                    }
                    
                }
                if(!variants.contains(v.toLowerCase()))
                    variants.push(v.toLowerCase());
            }
        }

        if (creditData != null) {
            for (j in 0...creditLabels.length) {
                var label = creditLabels[j];
                var color = creditColors[j];

                if (Reflect.hasField(creditData, label)) {
                    var textLabel = label.toLowerCase().charAt(0).toUpperCase() + label.substr(1);
                    var creditValue = Reflect.field(creditData, label);

                    var labelMargin:Float = 30;
                    var valueMargin:Float = 40;  

                    // LABEL ITSELF
                    var labelTxt = new FunkinText(0, 0, boxBG.width, textLabel + ":", 35, false);
                    labelTxt.setFormat(Paths.font("8bit-jve.ttf"), 35, color);
                    labelTxt.setPosition(boxBG.x + labelMargin, currentY);
                    add(labelTxt);

                    // THE CREDITS THING
                    var valueTxtWidth = boxBG.width - valueMargin - 10;

                    var valueTxt = new FunkinText(0, 0, valueTxtWidth, creditValue, 29, true);
                    valueTxt.setFormat(Paths.font("8bit-jve.ttf"), 29, 0xFFFFFFFF);
                    valueTxt.wordWrap = true;
                    valueTxt.alignment = "left";
                    valueTxt.setPosition(boxBG.x + valueMargin, currentY);
                    add(valueTxt);

                    labelTexts.push(labelTxt);
                    valueTexts.push(valueTxt);

                    currentY += labelTxt.height + 4;
                    currentY += valueTxt.height + 6;
                }
            }
        } else {
            var noCreds = new FunkinText(0, 0, boxBG.width, "This vessel isn't ready yet.", 28, false);
            noCreds.setFormat(Paths.font("8bit-jve.ttf"), 28);
            noCreds.setPosition(boxBG.x + 30, currentY);
            labelTexts.push(noCreds);
            add(noCreds).alpha = 0.5;
            valueTexts.push(new FunkinText(0, 0, 0, "fungus tuah", 28, false));
            currentY += noCreds.height + 4;
        }

        boxes.push({
            song: song,
            outline: boxOutline,
            bg: boxBG,
            title: nameTxt,
            divider: divider,
            labelDescs: labelTexts,
            valueDescs: valueTexts,
            variantDescs: creditMap
        });

    }

    add(scoreBg = new FlxSpriteGroup(FlxG.width));
    scoreBg.scrollFactor.set();

    var spr = new FunkinSprite().makeGraphic(480, 65, FlxColor.BLACK);
    spr.setPosition(-spr.width + 35);
    scoreBg.add(spr);

    var spr = new FunkinSprite().makeGraphic(1, 65, FlxColor.BLACK);
    scoreBg.add(spr);

    scoreText = textCrispy(new FlxText(FlxG.width * 0.7, 5, 0, "", 32));
	scoreText.setFormat(Paths.font("DTM-Mono.ttf"), 20, FlxColor.WHITE, "right");
    scoreText.scrollFactor.set();
    add(scoreText);

    scoreText2 = textCrispy(new FlxText(FlxG.width * 0.7, scoreText.y + scoreText.height - 2.5, 0, "e\n", 32));
	scoreText2.setFormat(Paths.font("DTM-Mono.ttf"), 22, FlxColor.WHITE, "right");
    scoreText2.scrollFactor.set();
    add(scoreText2);

    add(variantBg = new FlxSpriteGroup(FlxG.width, scoreBg.height - 5));
    variantBg.scrollFactor.set();

    var spr = new FunkinSprite().makeGraphic(365, 30, FlxColor.BLACK);
    spr.setPosition(-spr.width + 35);
    variantBg.add(spr);

    var spr = new FunkinSprite().makeGraphic(20, 30, FlxColor.BLACK);
    spr.skew.x = 25;
    spr.x -= 342.25;
    variantBg.add(spr);

    variantText = textCrispy(new FlxText(FlxG.width - (variantBg.width * .5), scoreText2.y + 32,  0, "< FINAL HOURS >", 32));
	variantText.setFormat(Paths.font("DTM-Mono.ttf"), 22, FlxColor.WHITE, "center");
    variantText.scrollFactor.set();
    add(variantText);

    if((FlxG.save.data.freeplayWarning == null || FlxG.save.data.freeplayWarning) || FlxG.save.data.freeplayWarningLock) {
        FlxG.save.data.freeplayWarning = true;
        warningText = textCrispy(new FlxText(FlxG.width * .5, 100, FlxG.width, FlxG.save.data.freeplayWarningLock ? "PLEASE LOOK AT ME ->\nBEFORE PLAYING ANOTHER SONG!": "PSST! LOOK AT ME! ->"));
        warningText.setFormat(Paths.font("DTM-Mono.ttf"), 22, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        warningText.borderSize = 2;
        warningText.scrollFactor.set();
        if(FlxG.save.data.freeplayWarning)
            warningText.offset.x = 5;
        add(warningText);

        warningTextTrail = new FlxTrail(warningText, null, 32, 11, 0.3, 0.045);
        warningTextTrail.scrollFactor.set();
        warningTextTrail.color = 0xFF000000;
        insert(members.indexOf(warningText), warningTextTrail);
        FlxG.save.flush();
    }

    whiteFlash = new FunkinSprite(0, 0).makeSolid(FlxG.width, FlxG.height, 0xFFFFFFFF);
    whiteFlash.alpha = 0;
    whiteFlash.scrollFactor.set();
    whiteFlash.camera = frontCam;
    add(whiteFlash);

    var barHeight = FlxG.height / 2;

    barTop = new FunkinSprite(0, -barHeight).makeSolid(FlxG.width, barHeight, 0xFF000000);
    barTop.scrollFactor.set();
    barTop.camera = frontCam;
    add(barTop);

    barBottom = new FunkinSprite(0, FlxG.height).makeSolid(FlxG.width, barHeight, 0xFF000000);
    barBottom.scrollFactor.set();
    barBottom.camera = frontCam;
    add(barBottom);

    if (!Options.gameplayShaders || !FlxG.save.data.bloom) {
        whiteCover = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        whiteCover.scrollFactor.set();
        whiteCover.blend = 0;
        whiteCover.camera = frontCam;
        add(whiteCover).alpha = 0;
    }

    varientQNA = new FlxSpriteGroup();
    varientQNA.scrollFactor.set();
    varientQNA.camera = frontCam;

    var vbg:FunkinSprite = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, 0x9F000000);
    varientQNA.add(vbg).alpha = 0.5;
    
    var varientHeader = textCrispy(new FunkinText(0, 130, FlxG.width, "WHAT IS FINAL HOURS?", 50, false));
    varientHeader.setFormat(Paths.font("fallen-down.ttf"), 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    varientHeader.borderSize = 6;
    varientQNA.add(varientHeader);

    var varientTxt = textCrispy(new FunkinText(0, 260, FlxG.width * 0.8, "", 50, false));
    varientTxt.text = "Friday Night Dustin' FINAL HOURS was a Youtube stream where FND developers played the mod and explained the behind the scenes and fun facts. But during the stream, they added minor modifications to the songs to throw off people watching. These are the slightly modified version of those songs.\n\nPress any button to continue.";
    varientTxt.setFormat(Paths.font("8bit-jve.ttf"), 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    varientTxt.screenCenter(FlxAxes.X);
    varientTxt.borderSize = 3;
    varientQNA.add(varientTxt);

    add(varientQNA).alpha = 0;

    changeSelection(curSelected, true);
    var um:String = "" + curVariant;
    curVariant = "0";
    changeVariantSelection(variants.indexOf(um) + 1, true);
    frontCam.fade(FlxColor.BLACK, 1.25, true);

    if (ink != null) add(ink);
    if (genocidesText != null) add(genocidesText);

    for (portrait in portraits) {
    portrait.camera = tvScreen;
    }

    frontPortrait.camera = frontCam;
}

var prevVarient:String = curVariant;
var iTime:Float = 0;
function update(elapsed:Float) {
    oldstatic.time += elapsed;
    tape_noise.time += elapsed;
    iTime += elapsed;
    glitch.iTime = iTime;

    if (waitingVariantResponse && FlxG.keys.justPressed.ANY) {
        waitingVariantResponse = false;
        FlxG.sound.play(Paths.sound("menu/confirm"));
        FlxTween.cancelTweensOf(varientQNA);
        FlxTween.tween(varientQNA, {alpha: 0}, 0.75);
        return;
    }

    if(!waitingVariantResponse && allowInput) {
        var change = ((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
        if (change != 0) changeSelection(change);

        var change = ((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
        if (change != 0) changeVariantSelection(change);
    }

    if(warningText != null && warningTextTrail != null) {
        warningHue += (elapsed * 100);
        warningText.color = FlxColor.fromHSL(warningHue,1,0.55 + (Math.sin(iTime * 2.5) * .25),1);
        warningText.y = 70 + (Math.sin(iTime * 2.5) * 8);
        warningText.x = FlxG.width * .5 + (Math.sin(iTime * (2.5)/2) * 8);
    }

    seedeeznuts?.angle += cdSpinSpeed * elapsed;

    var yPos = 10;
    if (FlxMath.roundDecimal(boxes[curSelected].outline.scale.y, 3) != 475 || prevVarient != curVariant) {
        prevVarient = curVariant;
        for (i => box in boxes) {
            var selected = i == curSelected;
            var outline = box.outline;
            var title = box.title;

            outline.y = yPos;
            var visibility = box.variantDescs[curVariant] != null;
            if(box.outline.visible != visibility) {
                box.outline.visible = visibility;
                box.bg.visible = visibility;
                box.title.visible = visibility;
                box.divider.visible = visibility;

                for (label in box.labelDescs)
                    label.visible = visibility;

                for (value in box.valueDescs)
                    value.visible = visibility;
            }
            if(box.outline.visible)
                yPos += outline.height + 20;

            var wantedScale = selected ? [600, 475] : [600, title.height + 15];
            outline.scale.x = lerp(outline.scale.x, wantedScale[0], 0.3);
            outline.scale.y = lerp(outline.scale.y, wantedScale[1], 0.3);
            outline.updateHitbox();

            var bg = box.bg;
            bg.setPosition(outline.x + outline.width / 2 - bg.width / 2, outline.y + outline.height / 2 - bg.height / 2);
            bg.scale.x = outline.scale.x - outlineSize / 2;
            bg.scale.y = outline.scale.y - outlineSize / 2;
            bg.updateHitbox();

            title.setPosition(bg.x + bg.width / 2 - title.width / 2, bg.y);
            if(allowInput)
                title.alpha = lerp(title.alpha, selected ? 1 : 0.5, 0.4);

            var divider = box.divider;
            divider.setPosition(bg.x + 20, bg.y + title.height + 10);


            var descY = box.bg.y + box.title.height + 25;

            for (i in 0...box.labelDescs.length) {
                var label = box.labelDescs[i];
                var value = box.valueDescs[i];

                label.setPosition(box.bg.x + 20, descY);
                descY += label.height + 2;

                value.setPosition(box.bg.x + 40, descY);
                descY += value.height + 4;
            }


            if (box.labelDescs.length > 0 || box.valueDescs.length > 0) {
                var firstDesc = box.labelDescs.length > 0 ? box.labelDescs[0] : box.valueDescs[0];

                if (box.descClip == null) {
                    box.descClip = new FlxRect(0, 0, 0, 0);
                }

                var descClipRect = box.descClip;

                descClipRect.x = box.bg.x - firstDesc.x;
                descClipRect.y = box.bg.y - firstDesc.y;
                descClipRect.width = box.bg.width;
                descClipRect.height = box.bg.height;

                for (desc in box.labelDescs)
                    desc.clipRect = descClipRect;

                for (desc in box.valueDescs)
                    desc.clipRect = descClipRect;
            }

            if(!visibility && selected)
                changeSelection(-0.001);
        }
    }

    var curBox = boxes[curSelected];
    FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, curBox.outline.y + curBox.outline.height / 2 - FlxG.height / 2, 0.1);

    if (!waitingVariantResponse && allowInput && (controls.BACK || FlxG.keys.justPressed.ESCAPE)) {
        allowInput = false;
        CoolUtil.playMenuSFX(2, 0.7);
        FlxG.sound.music.fadeOut(0.75, 0);
        frontCam.fade(FlxColor.BLACK, 0.8, false, () -> {
            MusicBeatState.skipTransOut = true;
            FlxG.switchState(new MainMenuState());
        }, true);
    }

    if (!waitingVariantResponse && allowInput && (controls.ACCEPT || FlxG.mouse.justPressed)) {
        allowInput = false;
        selectSong();
    }

    var curPortrait = portraits[curSelected];
    /*if (!allowInput && curPortrait.animation.curAnim.name == 'start' && curPortrait.isAnimFinished()) {
        FlxG.switchState(new PlayState());
    }*/

    for(i in [score, misses, accuracy]) {
        if (i.lerpValue == i.value)
            continue;
        i.lerpValue = lerp(i.lerpValue, i.value, (i == score) ? 0.5 : (i == misses ? 0.1 : 0.5));

        if (Math.abs(i.lerpValue - i.value) <= 1)
            i.lerpValue = i.value;
    }
        
    if(allowInput) {
        scoreText.text = "Personal Best";
        scoreText2.text = "Score: " + Math.round(score.lerpValue) + " * Misses: " + Math.round(misses.lerpValue) + " * Accuracy: " + FlxMath.roundDecimal(accuracy.lerpValue, 2) + "%";
        scoreText.x = FlxG.width - scoreText.width - 15;
        scoreText2.x = FlxG.width - scoreText2.width - 15;

        if (bg.x != FlxG.width -290 - (bg.width * 1.2) - (bg.skew.x)) {
            var bg = scoreBg.members[1];
            bg.scale.x = scoreText2.width - 280 + 20;
            bg.skew.x = -(scoreText2.width - 280) * 0.15;
            bg.updateHitbox();
            bg.setPosition(FlxG.width -290 - (bg.width * 1.2) - (bg.skew.x));
        }
    }
}

function updateScore() {
    var saveData = FunkinSave.getSongHighscore(boxes[curSelected].song.name, "hard", variant, []);
    score.value = saveData.score == 1 ? 0 : saveData.score;
    misses.value = saveData.misses;
    accuracy.value = (saveData.accuracy == -1 ? 0 : saveData.accuracy) * 100;
}

function refreshVariantText() {
    if(!hasSong(boxes[curSelected].song))
        return variantText.text = "- LOCKED -";
    var displayText:String = "";
    if(variants.length > 1) {
        if(variants.indexOf(curVariant) != 0)
            displayText += "< ";
    }
    displayText += curVariant;
    if(variants.length > 1) {
        if(variants.indexOf(curVariant) != variants.length - 1)
            displayText += " >";
    }
    variantText.text = displayText;
    variantText.x = FlxG.width - (variantBg.width * .625);
    updateScore();
}

function postUpdate(elapsed) {
    DustinUtil.copyCamera(FlxG.camera, frontCam);
    // I originally had this in the copyCamera function, but it can be messed up if you pause and un/fullscreen at the same time
    // I will try to fix this later on if I have the time, sorry - HIGG
    // This is meant to sync the camera shaking
    frontCam.setPosition(
        FlxG.camera.x + (FlxG.camera.flashSprite.x - (FlxG.camera.x * FlxG.scaleMode.scale.x + FlxG.camera._flashOffset.x)),
        FlxG.camera.y + (FlxG.camera.flashSprite.y - (FlxG.camera.y * FlxG.scaleMode.scale.y + FlxG.camera._flashOffset.y))
    );
}

var variationTween:FlxTween;
function changeVariantSelection(amt:Int, ?force:Bool = false) {
    var prevSelected = curVariant;
    var variantIndex = variants.indexOf(prevSelected) + amt;
    if(variantIndex < 0 || variantIndex > variants.length - 1)
        return;
    if(curVariant != variants[variantIndex]) {
        curVariant = variants[variantIndex];

        if (curVariant == "final hours" && FlxG.save.data.finalHoursQNA == null) {
            FlxTween.tween(varientQNA, {alpha: 1}, 1);
            FlxG.save.data.finalHoursQNA = true;
            FlxG.save.flush();
            waitingVariantResponse = true;
        }

        refreshVariantText();
        var creditLabels = ["SONG", "SPRITES", "BACKGROUND", "CHART"];
        for(box in boxes) {
            if(box.variantDescs[curVariant] != null) {
                var credits = box.variantDescs[curVariant];
                for(i => value in box.valueDescs)
                    value.text = Reflect.hasField(credits, creditLabels[i]) ? Reflect.field(credits, creditLabels[i]) : "";
            }
        }
        var path = StringTools.replace(curVariant + '/', 'Vanilla/', '').replace(' ', '_').toLowerCase();
        bg.loadGraphic(Paths.image('menus/freeplay/desk/' + path + 'bg_freeplay'));
        bgtv.loadGraphic(Paths.image('menus/freeplay/desk/' + path + 'bg_freeplay_tv'));
        fg.loadGraphic(Paths.image('menus/freeplay/desk/' + path + 'fg_freeplay'));
        if(!force) {
            if(warningText != null && (FlxG.save.data.freeplayWarningLock || FlxG.save.data.freeplayWarning)) {

                warningTextTrail.destroy();
                
                warningText.text = "YOU'VE UNLOCKED\nNEW SONG VARIANTS!";
                if(FlxG.save.data.freeplayWarningLock)
                    warningText.text += "\nYAY....";

                FlxTween.num(1, 0, 3, {ease: FlxEase.linear, startDelay: 1.5}, function(num) {
                    warningText.alpha = num;
                });
                FlxG.save.data.freeplayWarningLock = false;
                FlxG.save.data.freeplayWarning = false;
            }
            if(variationTween != null) variationTween.cancel();
            variationTween = FlxTween.num(FlxG.save.data.antiFlash ? 0.35 : 1, 0, 1, {ease: FlxEase.quartOut}, function(num) {
                if (whiteCover != null) {
                     whiteCover.alpha = num * 0.15;
                } else {
                    bloom.size = 10 * num;
                    glitch.AMT = num * .01;
                    bloom.brightness = 1 + (5 * num);
                }
            });

            FlxG.sound.play(Paths.sound("menu/modeswitch"), 0.5);
        }
    }
}

var prevSelected = 0;
var staticTween:FlxTween;
var tapeNoiseTween:FlxTween;
function changeSelection(amt:Int, ?force:Bool = false) {
    prevSelected = curSelected;
    curSelected = force ? amt : FlxMath.wrap(curSelected + amt, 0, boxes.length - 1);

    while(boxes[curSelected].variantDescs[curVariant] == null) {
        curSelected = FlxMath.wrap(curSelected + (amt < 0 ? -1 : 1), 0, boxes.length - 1);
    }

    refreshVariantText();

    if (prevSelected != curSelected || force) {
        staticTween?.cancel();
        tapeNoiseTween?.cancel();
        oldstatic.strength = 260;
        tape_noise.strength = 4;

        if (hasSong(boxes[curSelected].song) && hasPortrait(boxes[curSelected].song)) {
            if(force) {
                oldstatic.strength = 5;
                tape_noise.strength = 1;
            } else {
                staticTween = FlxTween.num(60, 5, 0.5, {ease: FlxEase.quadOut}, function(val:Float) {
                    oldstatic.strength = val;
                });

                tapeNoiseTween = FlxTween.num(4, 1, 0.5, {ease: FlxEase.quadOut}, function(val:Float) {
                    tape_noise.strength = val;
                });
            }
        }

        if(prevSelected != curSelected)
            FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
    }

    // who never cached the song or the name bruh, now im too lazy to do it  - Nex
    genocidesText?.visible = boxes[curSelected].song.name.toLowerCase() == "genocides" && hasSong(boxes[curSelected].song);
    nullObjectText.visible = boxes[curSelected].song.name.toLowerCase() == "lorem-ipsum" && hasSong(boxes[curSelected].song);

    for (i => p in portraits)
        p.alpha = curSelected == p.ID && hasSong(boxes[curSelected].song) ? 1 : 0.0001;
    frontPortrait.alpha = boxes[curSelected].song.name.toLowerCase() == "yolo" && hasSong(boxes[curSelected].song);

    loadCD(boxes[curSelected].song.name.toLowerCase());
    seedeeznuts.visible = hasSong(boxes[curSelected].song);
    FlxTween.cancelTweensOf(seedeeznuts);
    seedeeznuts.x = FlxG.width * 0.9 - seedeeznuts.width / 2 + 35;
    FlxTween.tween(seedeeznuts, {x: FlxG.width * 0.9 - seedeeznuts.width / 2 }, 0.4, {
        ease: FlxEase.quadOut
    });


    updateScore();
}


var speedizer:Float = 0;
var xoffset:Float = 0;
var yoffset:Float = 0;
var angleoffset:Float = 0;

function startLoremSelectionGlitch() {
    FlxG.sound.music?.stop();
    FlxG.sound.play(Paths.sound("glitch"), 0.5);

    var glitchTargets:Array<Dynamic> = [bg, bgtv, fg, seedeeznuts, nullObjectText, scoreText, scoreText2, variantText];
    for(box in boxes) {
        glitchTargets.push(box.outline);
        glitchTargets.push(box.bg);
        glitchTargets.push(box.title);
        glitchTargets.push(box.divider);
        for(label in box.labelDescs) glitchTargets.push(label);
        for(value in box.valueDescs) glitchTargets.push(value);
    }

    var blackSquares:Array<FunkinSprite> = [];
    for(i in 0...14) {
        var square = new FunkinSprite().makeSolid(1, 1, FlxColor.BLACK);
        square.scrollFactor.set();
        square.antialiasing = false;
        square.camera = frontCam;
        square.visible = false;
        add(square);
        blackSquares.push(square);
    }

    new FlxTimer().start(0.05, function(_) {
        for(i in 0...FlxG.random.int(2, 6)) {
            var target = glitchTargets[FlxG.random.int(0, glitchTargets.length - 1)];
            if(target != null) {
                target.x += FlxG.random.float(-90, 90);
                target.y += FlxG.random.float(-55, 55);
                target.angle += FlxG.random.float(-18, 18);
                target.alpha = FlxG.random.bool(35) ? 0 : FlxG.random.float(0.2, 1);
                target.visible = !FlxG.random.bool(30);
            }
        }

        for(square in blackSquares) {
            square.visible = FlxG.random.bool(42);
            if(square.visible) {
                square.scale.set(FlxG.random.int(12, 280), FlxG.random.int(8, 170));
                square.updateHitbox();
                square.setPosition(FlxG.random.int(-40, FlxG.width), FlxG.random.int(-30, FlxG.height));
                square.alpha = FlxG.random.float(0.65, 1);
            }
        }

        glitch.AMT = FlxG.random.float(0.01, 0.12);
        glitch.SPEED = FlxG.random.float(1, 8);
    }, 75);
}

function selectSong() {
    if (!hasSong(boxes[curSelected].song)) return allowInput = true;
    if(FlxG.save.data.freeplayWarning) {
        FlxG.save.data.freeplayWarning = false;
        FlxG.save.data.freeplayWarningLock = true;
    }
    if(warningText != null) {
        warningTextTrail.destroy();
        warningText.destroy();
        warningText = null;
    }
    var curBox = boxes[curSelected];
    variantBg.visible = variantText.visible = false;

    Options.freeplayLastSong = curBox.song.name;
    PlayState.loadSong(curBox.song.name, curBox.song.difficulties[0], variant, false);
    PlayState.variation = variant;

    var curPortrait = portraits[curSelected];
    var hasPortraitAnim:Bool = curPortrait.animation != null && curPortrait.animation.name != null;
    if (hasPortraitAnim || boxes[curSelected].song.name.toLowerCase() == "lorem-ipsum") {
            if (boxes[curSelected].song.name.toLowerCase() == "you-are") {
                scoreText.visible = false;
                scoreText2.visible = false;
                scoreBg.visible = false;
                FlxG.sound.music.stop();
                FlxG.sound.play(Paths.sound("menu/youare-select"), 1);
                bg.visible = false;
                bgtv.visible = false;
                fg.visible = false;
                seedeeznuts.visible = false;

                for (b in boxes) {
                    b.outline.alpha = 0;
                    b.bg.alpha = 0;
                    b.title.alpha = 0;
                    b.divider.alpha = 0;

                    for (label in b.labelDescs)
                        label.alpha = 0;

                    for (value in b.valueDescs)
                        value.alpha = 0;
                }

                tvScreen.removeShader(oldstatic);
                tvScreen.removeShader(tape_noise);

                new FlxTimer().start(0.25, function(_) {
                    curPortrait.playAnim('start', true);

                curPortrait.offset.set(319, 308);
                

                new FlxTimer().start(2.5, function() {

                    FlxTween.tween(barTop, { y: 0 }, 3.5, { ease: FlxEase.quadInOut });
                    FlxTween.tween(barBottom, { y: FlxG.height / 2 }, 3, { ease: FlxEase.quadInOut });

                    FlxTween.tween(whiteFlash, { alpha: 1 }, 2, { ease: FlxEase.sineOut });

                    FlxTween.num(0, 1, 2, {ease: FlxEase.sineInOut}, function(n) {
                        glitch.AMT = 0.01 + 0.01 * n;
                        glitch.SPEED = 1 + 1 * n; 
                    });

                    new FlxTimer().start(1, function() {
                        FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
                    });

                    new FlxTimer().start(3.5, function() {
                        PlayState.variation = variant;
                        FlxG.switchState(new PlayState());
                    });
                });

                });
            } 

            else
            {
                cdSpinSpeed = 0;

                if(boxes[curSelected].song.name.toLowerCase() == "lorem-ipsum")
                    startLoremSelectionGlitch();

                FlxTween.num(0, 1300, 3, {ease: FlxEase.sineInOut}, function(val:Float) {
                    cdSpinSpeed = val;
                });

                FlxTween.num(0, 500, 3, { ease: FlxEase.quintOut }, function(val:Float) {
                    variantBg.offset.x = -val;
                    variantText.offset.x = -val;
                    scoreText.offset.x = -val;
                    scoreText2.offset.x = -val;
                    scoreBg.x = FlxG.width + val;
                });

                FlxTween.num(FlxG.save.data.antiFlash ? 0.15 : 2, 0, 2, {ease: FlxEase.quintOut}, function(num) {
                    if (whiteCover != null) {
                        whiteCover.alpha = num * .5;
                    } else {
                        bloom.size = 20 * num;
                        bloom.brightness = 1 + (20 * num);
                        glitch.AMT = 0.1 * num;
                        glitch.SPEED = 2 * num;
                    }
                });

                FlxG.camera.shake(0.02, 0.2);
                tvScreen.shake(0.02, 0.2);
                FlxG.sound.play(Paths.sound("menu/select_freeplay"), 1);

                if (boxes[curSelected].song.name.toLowerCase() == "uncreate") {
                    ink.visible = true;
                    ink.playAnim("paint", true);
                }

                new FlxTimer().start(0.25, function(_) {
                    if(hasPortraitAnim)
                        curPortrait.playAnim('start', true);
                    if(boxes[curSelected].song.name.toLowerCase() == "yolo") {
                        frontPortrait.playAnim('start', true);
                        frontPortrait.offset.y -= 15;
                        curPortrait.offset.y -= 15;
                    }

                new FlxTimer().start(1.5, function() {
                    FlxTween.tween(FlxG.camera, {zoom: 1.4}, 2, {ease: FlxEase.quadInOut});
                    FlxTween.tween(tvScreen, {zoom: 1.4}, 2, {ease: FlxEase.quadInOut});

                    FlxTween.tween(barTop, { y: 0 }, 2, { ease: FlxEase.quadInOut });
                    FlxTween.tween(barBottom, { y: FlxG.height / 2 }, 1.5, { ease: FlxEase.quadInOut });

                    FlxTween.tween(whiteFlash, { alpha: 1 }, 2, { ease: FlxEase.sineOut });

                    FlxTween.num(0, 1, 2, {ease: FlxEase.sineInOut}, function(n) {
                        glitch.AMT = 0.01 + 0.01 * n;
                        glitch.SPEED = 1 + 1 * n; 
                    });

                    new FlxTimer().start(1, function() {
                        if(boxes[curSelected].song.name.toLowerCase() != "lorem-ipsum")
                            FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
                    });

                    new FlxTimer().start(2, function() {
                        FlxG.switchState(new PlayState());
                    });
                });

                });
            }
    } else {
        FlxG.switchState(new PlayState());
    }
}

function destroy() {
    FlxG.camera.bgColor = 0xFF000000;
}

function hideStr(_:String):String {
    var temp:String = "";
    for (a in _.split(""))
        temp += a == " " ? " " : "?";
    return temp;
}
