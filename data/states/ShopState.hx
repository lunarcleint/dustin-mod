// imports
import Reflect;
import funkin.savedata.FunkinSave;

import openfl.geom.Rectangle;

import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextFormat;

import flixel.input.keyboard.FlxKey;

import funkin.backend.utils.FlxInterpolateColor;
import funkin.backend.utils.CoolUtil.CoolSfx;

import dustin.ShakingText;
import StringTools;

importScript("data/scripts/DialogueBoxBG");
importScript("data/scripts/FunkinTypeText");
var itemScript = importScript("data/scripts/PreloadSongItems");

static var shopMusicStarted:Bool = false;
static var lastReturnDialogue:String = "";

// backend functions (not gonna be used much)
function parseJson(path:String) { // better use this instead of creating a huge Map...... (you get the reference?)
    var jsonPath:String = Paths.json("gaster/" + path);
    if(Assets.exists(jsonPath)) {
        var raw = Assets.getText(jsonPath);
        try {
            raw = Json.parse(raw);
            return raw;
        } catch (e:Dynamic) {trace('INVALID JSON PARSING : ' + e);}
    }
    return null;
}

function endsWithArray(str, list) {
    var isTrue:Bool = false;
    for(word in list) {
        if(StringTools.endsWith(str, word)) {
            isTrue = true;
        }
    }
    return isTrue;
}

// bg stuff
var bg:FunkinSprite = new FunkinSprite(0, 0, Paths.image("menus/shop/background_gaster"));
var light:FunkinSprite = new FunkinSprite(485, -100, Paths.image("menus/shop/light"));
var gaster:FunkinSprite = new FunkinSprite(650, 85, Paths.image("menus/shop/gaster"));

// dialogue

var introDialogue:String;
var dialogue = {
    intro: true,
    start: null,
    resume: null,
    clear: null,
    lines: null,
    defaultSpeed: 0.08,
    speed: 0.08,
    box: newDialogueBoxBG(515, 470, null, 700, 210, 5),
    typeText: newFunkinTypeText(540, 490, 670, "hawk tuah", 40),
    txt: null,
}
dialogue.txt = textCrispy(dialogue.typeText.flxtext);

var money = {
    box: newDialogueBoxBG(1015, 420, null, 200, 55, 5),
    text: textCrispy(new FunkinText(0, 0, 0, "EXP: " + FlxG.save.data.dustinCash, 40, false)),
}

var stats = {
    box: newDialogueBoxBG(1040, 60, null, 175, 175, 5),
    item: new FunkinSprite(),
    itemY: 0,
    appear: false,
    cost: textCrispy(new FunkinText(0, 0, 175, "Cost: ???", 40, false)),
}

var shop = {
    data: {
        items: parseJson("shop/items"),
        dialogue: parseJson("shopDialogue")
    },
    box: newDialogueBoxBG(65, 40, null, 400, 640, 5),
    keys: null,
    cds: null,
    items: [],
    heart: new FunkinSprite(85, 0, Paths.image("game/heart")),
    curItem: 0,
    changeItem: null,
    yesno: [textCrispy(new FunkinText(595, 575 + (43 / 2), 0, "Yes", 40, false)), textCrispy(new FunkinText(1095, 575 + (43 / 2), 0, "No", 40, false))],
    curYesno: null,
}

var nullCostTimer:Float = 0;
var nullCostCharacters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#$%&?!";

function randomNullCost():String {
    var result:String = "";
    for(i in 0...6)
        result += nullCostCharacters.charAt(FlxG.random.int(0, nullCostCharacters.length - 1));
    return result;
}

function refreshCostText() {
    if(shop.items[shop.curItem] == null)
        return;

    var item = shop.items[shop.curItem];
    stats.cost.text = "Cost: " + (item.song == "lorem-ipsum" ? randomNullCost() : item.cost);
}

shop.changeItem = (change) -> {
    if(!shop.items[shop.curItem].sold)
        shop.items[shop.curItem]?.text?.color = FlxColor.WHITE;
    shop.curItem = FlxMath.wrap(shop.curItem + change, 0, shop.items.length-1);
    if(!shop.items[shop.curItem].sold) {
        if(shop.items[shop.curItem].song != null) {
            stats.item.loadGraphic(itemScript.call("image", ["cd", shop.items[shop.curItem].song]));
            stats.item.scale.set(0.5, 0.5);
            stats.item.updateHitbox();
            stats.item.setPosition(stats.box.x + 20, 60 + 25);
            stats.itemY = stats.box.y + 25;
        } else if(shop.items[shop.curItem].week != null) {
            stats.item.loadGraphic(itemScript.call("image", ["key", shop.items[shop.curItem].title.toLowerCase()]));
            stats.item.scale.set(0.8, 0.8);
            stats.item.updateHitbox();
            stats.item.setPosition(stats.box.x + stats.box.width / 2 - stats.item.width / 2, 60 + stats.box.height / 2 - stats.item.height / 2 + 10);
            stats.itemY = stats.box.y + stats.box.height / 2 - stats.item.height / 2 + 10;
        }
        shop.items[shop.curItem]?.text?.color = FlxColor.YELLOW;
        if(change != 0)
            CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.8);
        nullCostTimer = 0;
        refreshCostText();
    } else shop.changeItem(change != 0 ? change : 1);
}

dialogue.clear = () -> {
    colorTimer = 0;
    dialogue.lines = null;
    dialogue.typeText.resetText(" ", dialogue.typeText);
}

dialogue.resume = () -> {
    var curDialogue = dialogue.lines.shift();
    if(curDialogue.face != null)
        gaster.playAnim(curDialogue.face, true);
    dialogue.typeText.resetText(curDialogue.text, dialogue.typeText);
    dialogue.typeText.start(dialogue.speed, dialogue.typeText);
    if(dialogue.lines.length == 0 && shop.curYesno != null) {
        for(a in shop.yesno)
            a.visible = true;
        shop.heart.visible = true;
    }
}

dialogue.start = (obj, dialog) -> {
    stats.appear = false;
    colorTimer = 0;
    bgText.alpha = 0.2;
    CAM_SCROLL = CAM_SCROLL_GASTER;
    dialogue.lines = Reflect.getProperty(obj, dialog).copy();
    for(i => choice in obj.choices == null ? ["Yes", "No"] : obj.choices)
        shop.yesno[i].text = choice;
    for(a in shop.yesno)
        a.visible = false;
    dialogue.resume();
}

var gasterVanished:Bool = false;

var lerpColor:FlxInterpolateColor = new FlxInterpolateColor(0xFFFFFFFF);
var prevTxt;

var bgText;

var CAM_SCROLL:Float = 0;
var CAM_SCROLL_GASTER:Float = 220;

var glowDistance:Float = 2.5;
var glowDraw:FlxSprite -> Void = (spr) -> {
    var _xpos = spr.x;
    var _ypos = spr.y;
    var _alpha = spr.alpha;
    spr.alpha = ((FlxMath.fastSin(coolTimer) + 2) * 0.35) * (spr.alpha * 0.09) + 0.04;
    for(_x in 0...3) {
        var __x = _xpos - glowDistance + (glowDistance * _x);
        spr.x = __x;
        spr.draw();
        for(_y in 0...3) {
            var __y = _ypos - glowDistance + (glowDistance * _y);
            spr.y = __y;
            spr.draw();
        }
    }
    spr.alpha = _alpha;
    spr.x = _xpos;
    spr.y = _ypos;
    spr.draw();
}

function refreshShopCompletion() {
    var hasEverything:Bool = true;
    var purchasedCDs:Array<String> = FlxG.save.data.dustinPurchasedShopCDs;

    // One-time migration for saves made before shop purchases had their own list.
    // Null CD is new in this update, so an existing chart score must not buy it.
    if(purchasedCDs == null) {
        purchasedCDs = [];
        for(cd in shop.data.items.cds) {
            if(cd.song != "lorem-ipsum" && (FlxG.save.data.dustinBoughtStuff.contains(cd.song) || FunkinSave.getSongHighscore(cd.song, "hard").score > 0))
                purchasedCDs.push(cd.song);
        }
        FlxG.save.data.dustinPurchasedShopCDs = purchasedCDs;
        FlxG.save.flush();
    }

    trace(dustinShop);
    for(key in shop.data.items.keys) {
        trace(key.week);
        if(dustinShop["keys"][key.week] != true)
            hasEverything = false;
    }

    for(cd in shop.data.items.cds) {
        var bought:Bool = purchasedCDs.contains(cd.song);
        dustinShop["cds"][cd.song] = bought;
        if(!bought) {
            trace('UNBOUGHT SHOP CD: ' + cd.song);
            hasEverything = false;
        }
    }

    dustinShop["boughtAll"] = hasEverything;
    trace('SHOP CATALOGUE COMPLETE: ' + hasEverything);
}

function create() {
    // Check the freshly loaded shop JSON instead of relying on the global value,
    // which may come from an older catalogue cached earlier in the session.
    load_shop_data();

    if(FunkinSave.getSongHighscore("you-are", "hard").score > 1 && FunkinSave.getSongHighscore("the-uprising", "hard").score > 1)
        introDialogue = "bothEndings";
    else if(FunkinSave.getSongHighscore("cornered", "hard").score > 1 && FunkinSave.getSongHighscore("avulsion", "hard").score > 1 && FunkinSave.getSongHighscore("broken-reality", "hard").score > 1 && (FunkinSave.getSongHighscore("you-are", "hard").score > 1 || FunkinSave.getSongHighscore("the-uprising", "hard").score > 1))
        introDialogue = "afterStoryMode";
    else
        // The shop is available even on a completely fresh story save.
        introDialogue = "beforeStoryMode";

    (lastReturnDialogue == introDialogue) ? introDialogue = "return" : lastReturnDialogue = introDialogue;

    playMusic("gaster_shop", 0.7);

    if (Options.gameplayShaders && FlxG.save.data.water) {
        bg.shader = new CustomShader("waterDistortion");
        bg.shader.strength = 0.5;
        bg.shader.time = 0;
    }

    bg.alpha = 0.6;
    bg.scrollFactor.set();
    bg.antialiasing = gaster.antialiasing = Options.antialiasing;

    for (a in ["idle", "talk", "focus", "scary", "goofy", "surprised"])
        gaster.addAnim(a, a, 12, true);

    light.antialiasing = gaster.antialiasing = Options.antialiasing;
    light.alpha = 0.75;

    add(bg).screenCenter();
    if(dustinShop["boughtAll"]) {
        FlxG.sound.music.pitch = 0.05;
        if(Options.gameplayShaders && FlxG.save.data.saturation) {
            var contrast = new CustomShader("saturation");
            contrast.contrast = 1.3;
            contrast.sat = 0.5;
            camera.addShader(contrast);
            bg.alpha = 0.8;
        } else bg.alpha = 0.3;
        bgText = textCrispy(new ShakingText(550, 510, 670, '', 40, true).setFormat(Paths.font("pixel-wingdings.otf"), 32));
        bgText.breakText = true;
        bgText.letterSpacing = 8.0;
        bgText.alpha = 0.2;

        dialogue.typeText.flxtext = bgText;
        dialogue.clear();
        add(dialogue.typeText.flxtext);

        FlxG.camera.scroll.x = CAM_SCROLL = CAM_SCROLL_GASTER;
        gasterVanished = true;
        return;
    }

    add(light).blend = 0;
    add(gaster).playAnim("idle");

    CAM_SCROLL_GASTER = (gaster.x + gaster.width * .5) - (camera.width * .5);

    if(introDialogue != "beforeStoryMode" && introDialogue != "boughtItAll") {
        add(money.box).pixels.fillRect(new Rectangle(5, 5, 100, 200), 0xFF000000); // money box
        add(money.text).setPosition(Math.floor(money.box.x + Math.max(20, (money.text.width - money.box.width)) / 2), Math.floor(466 - money.text.height));
        money.text.font = Paths.font("8bit-jve.ttf");
        money.text.onDraw = (spr) -> { if(dialogue.lines == null || shop.curYesno != null) glowDraw(spr); else spr.draw(); }

        add(stats.box).pixels.fillRect(new Rectangle(5, 5, 785, 460), 0xFF000000); // item box
        stats.box.alpha = 0;

        itemScript.call("preloadCDs");
        itemScript.call("preloadKeys");
        add(stats.item);
        stats.item.scale.set(0.5, 0.5);
        stats.item.antialiasing = Options.antialiasing;

        add(stats.cost).setPosition(1040, 235);
        stats.cost.alignment = "center";
        stats.cost.font = Paths.font("8bit-jve.ttf");
        stats.cost.alpha = 0;
        stats.cost.bold = true;

        add(shop.box).pixels.fillRect(new Rectangle(5, 5, 785, 460), 0xFF000000); // shop box
        shop.box.alpha = 0;

        add(dialogue.box).pixels.fillRect(new Rectangle(5, 5, 690, 200), 0xFF000000); // text box
        function filteredBought(items) {
            var newItems:Array<Dynamic> = [];
            for(item in items) {
                if(item.week != null && !dustinShop["keys"][item.week])
                    newItems.push(item);
                else if(item.song != null && !dustinShop["cds"][item.song])
                    newItems.push(item);
                    
            }
            return newItems;
        }
        function generateList(id:String, items:Dynamic, y:Float, ?size:Int = 11) {
            var textSize:Float = 32.5;

            var list:Array<Dynamic> = [];
            var title:FunkinText = textCrispy(new FunkinText(110, y, 0, "* " + id, 32.5, false));
            add(title).font = Paths.font("8bit-jve.ttf");
            title.updateHitbox();
            y += title.height;

            if(items.length == 0)
                title.text += " (SOLD OUT)";
            title.color = FlxColor.GRAY;


            for(i in items) {
                var item = i;
                i.text = textCrispy(new FunkinText(125, y, 0, i.title, 32.5, false));
                add(i.text).font = Paths.font("8bit-jve.ttf");
                i.text.updateHitbox();
                y += i.text.height + 7;
                i.text.color = FlxColor.WHITE;
                list.push(i);
                shop.items.push(i);
            }

            return {title: title, items: list};
        }
        var size = shop.data.items.keys.length + shop.data.items.cds.length;
        shop.keys = generateList("Keys", filteredBought(shop.data.items.keys), shop.box.y + 16, size);
        shop.cds = generateList("CDs", filteredBought(shop.data.items.cds), (shop.keys.items.length != 0 ? shop.keys.items[shop.keys.items.length - 1].text : shop.keys.title).y + 48, size);

        if (shop.items[0] != null) {
            for(i => a in shop.yesno) {
                a.ID = i;
                add(a).setFormat(Paths.font("8bit-jve.ttf"), 40);
                a.visible = false;
            }
            shop.yesno[0].onDraw = glowDraw;
            
            var heartSize:Int = 24;
            for(i in 0...(shop.items.length - 12))
                heartSize -= 1;
            heartSize = Math.max(heartSize, 5);
            shop.heart.setGraphicSize(heartSize, heartSize);
            add(shop.heart).updateHitbox();
            shop.heart.setPosition(85, shop.items[0]?.y + (shop.items[0]?.height - shop.heart.height) / 2);
            shop.items[shop.curItem]?.text?.color = FlxColor.YELLOW;
            refreshCostText();
            for(i => item in shop.items) {
                item.text.ID = i;
            }
        }
    } else add(dialogue.box).pixels.fillRect(new Rectangle(5, 5, 690, 200), 0xFF000000); // text box

    bgText = textCrispy(new ShakingText(550, 510, 670, 'hawk tuah', 40, true).setFormat(Paths.font("pixel-wingdings.otf"), 32));
    bgText.breakText = true;
    bgText.letterSpacing = 8.0;
    bgText.alpha = 0.2;
    add(bgText);

    add(dialogue.txt).setFormat(Paths.font("8bit-jve.ttf"), 40);
    dialogue.txt.letterSpacing = 8.0;
    dialogue.txt.onDraw = glowDraw;

    dialogue.clear();

    FlxG.camera.scroll.x = CAM_SCROLL = CAM_SCROLL_GASTER;
    dialogue.start(shop.data.dialogue, introDialogue);
    if (introDialogue != "beforeStoryMode")
        shop.changeItem(0);
    updateColors(0, 1);
}

function boughtAll() {
    //var shopData:Dynamic =
    trace('CHECKING ITEMS...');
    var boughtAll:Bool = true;
    for(key in shop.data.items.keys) {
        if(!dustinShop["keys"][key.week])
            boughtAll = false;
    }
    for(cd in shop.data.items.cds) {
        if(!dustinShop["cds"][cd.song])
            boughtAll = false;
    }
    if(boughtAll) {
        FlxTween.tween(bg, {alpha: 0.3}, 1);
        FlxTween.tween(money.box, {alpha: 0}, 1);
        FlxTween.tween(money.text, {alpha: 0}, 1);
        money.text.onDraw = null;
        for(i in shop.items)
            remove(i.text);
        remove(shop.cds.title);
        remove(shop.keys.title);
        remove(shop.box);
        introDialogue = "boughtItAll";
        stats.appear = false;
        shop.curYesno = null;
        remove(shop.heart);
        dialogue.lines = null;
        dialogue.clear();
        dialogue.start(shop.data.dialogue, introDialogue);
    }
    return dustinShop["boughtAll"] = boughtAll;
}

function defaultText() {
    gaster.playAnim("idle", true);
    if(dialogue.intro) {
        dialogue.intro = false;
        FlxG.sound.play(Paths.sound("menu/gaster-vanish"), 0.2);
    }
    if(introDialogue == "boughtItAll") {
        if(gaster.alpha == 1) {
            FlxG.sound.music.fadeOut(8, 0);
            FlxTween.tween(gaster, {alpha: 0}, 1);
            FlxTween.tween(light, {alpha: 0}, 1);
            FlxTween.tween(bg, {alpha: 0}, 1.5);
            FlxTween.color(dialogue.box, 1.5, FlxColor.WHITE, FlxColor.BLACK);
            dialogue.speed = 0.06;
            dialogue.clear();
            new FlxTimer().start(1.8, function() {
                FlxG.sound.music.fadeOut(1.25, 0);
                camera.fade(FlxColor.BLACK, 1.5, false, exit);
            });
        } else {
            FlxG.sound.music.fadeOut(1.25, 0);
            camera.fade(FlxColor.BLACK, 1.5, false, exit);
            return true;
        }
        return true;
    }
    stats.appear = true;
    colorTimer = 0;
    if(shop.curYesno == null) {
        dialogue.lines = null;
        dialogue.typeText.resetText("CHOOSE AN ITEM YOU WOULD\nLIKE TO PURCHASE.", dialogue.typeText);
        dialogue.typeText.start(0.06, dialogue.typeText);
        bgText.alpha = 0;
    }
}


function idleShop() {
    if(!defaultText())
        CAM_SCROLL = 0;
    FlxG.sound.play(Paths.sound("menu/select"));
}

var left = false;
var _sin = 0;
var autodia = 0;
var autodiaLimit = 2;
function update(elapsed:Float) {
    updateFunkinTypeText(elapsed, dialogue.typeText);
    coolTimer += elapsed;
    bg.shader?.time = coolTimer * 0.6;
    if(gasterVanished && !left) {
        if(dialogue.typeText.isTyping && (prevTxt != (prevTxt = bgText.text))) {
            FlxG.sound.play(Paths.sound("wing_oggster/snd_wngdng" + FlxG.random.int(1, 7)), 0.025).pitch = 0.3;
        }
        autodia += elapsed;
        bg.shader?.time *= 0.2;
        if(autodia > autodiaLimit) {
            autodiaLimit = FlxG.random.float(5, 15);
            autodia = 0;
            var randomIndex = FlxG.random.int(0, shop.data.dialogue.length -1);
            for(i => field in Reflect.fields(shop.data.dialogue)) {
                if(i == randomIndex) {
                    dialogue.start(shop.data.dialogue, field);
                    break;
                }
            }
            //dialogue.start(shop.data.dialogue, introDialogue);
        }
        if(controls.BACK) {
            left = true;
            FlxG.sound.music.fadeOut(0.8, 0);
            camera.fade(FlxColor.BLACK, 1, false, exit);
        }
        return;
    }

    if(shop.items[shop.curItem]?.song == "lorem-ipsum") {
        nullCostTimer += elapsed;
        if(nullCostTimer >= 0.25) {
            nullCostTimer %= 0.25;
            refreshCostText();
        }
    } else nullCostTimer = 0;

    _sin += elapsed;
    if(shop.items[0] != null)
        stats.item.angle = FlxMath.fastSin(_sin);

    /*if(FlxG.keys.justPressed.F6) {
        FlxG.switchState(new ModState("OldShopState"));
        return;
    }*/

    if(dialogue.typeText.isTyping && (prevTxt != (prevTxt = dialogue.txt.text)) && dialogue.txt.text != "" && !endsWithArray(dialogue.txt.text, [" ", "\n"])) {
        if(bgText.alpha != 0)
            FlxG.sound.play(Paths.sound("wing_oggster/snd_wngdng" + FlxG.random.int(1, 7)), 0.7);
    }
    updateControls();
    
    bgText.text = dialogue.txt.text;

    updateColors(elapsed * 0.75, 0.13);

    var validQuestion = shop.curYesno != null;

    if(shop.items[0] != null) {
        stats.box.y = CoolUtil.fpsLerp(stats.box.y, (stats.appear || validQuestion) ? 60 : 120, 0.05);
        stats.cost.y = CoolUtil.fpsLerp(stats.cost.y, (stats.appear || validQuestion) ? 235 : 295, 0.05);
        stats.item.y = CoolUtil.fpsLerp(stats.item.y, (stats.appear || validQuestion) ? stats.itemY : (stats.itemY + 60), 0.05);
        shop.box.alpha = CoolUtil.fpsLerp(shop.box.alpha, dialogue.lines == null ? 1 : 0, 0.05);
        stats.item.alpha = stats.cost.alpha = stats.box.alpha = CoolUtil.fpsLerp(stats.box.alpha, (stats.appear || validQuestion) ? 1 : 0, 0.05);
        if(shop.items != null) {
            shop.keys.title.alpha = shop.cds.title.alpha = shop.box.alpha;
            for(item in shop.items)
                item.text.alpha = shop.box.alpha;
        }

        if(shop.heart != null) {
            if(validQuestion)
                shop.heart.x = CoolUtil.fpsLerp(shop.heart.x, shop.yesno[shop.curYesno].x - 50, FlxEase.backOut(0.15));
            else
                shop.heart.y = CoolUtil.fpsLerp(shop.heart.y, shop.items[shop.curItem]?.text.y + (shop.items[shop.curItem]?.text.height - shop.heart.height) / 2, FlxEase.backOut(0.15));
        }
    }

    FlxG.camera.scroll.x = CoolUtil.fpsLerp(FlxG.camera.scroll.x, CAM_SCROLL, 0.05); 
}

var colorTimer:Float = 0;
var coolTimer:Float = 0;
function updateColors(elapsed:Float, speed:Float) {
    if(colorTimer < 1) {
        colorTimer += elapsed;

        lerpColor.color = dialogue.box.color;
        lerpColor.fpsLerpTo(dialogue.lines != null ? 0xFFFFFF : 0x666666, speed);
        dialogue.box.color = lerpColor.color;

        lerpColor.color = money.text.color;
        lerpColor.fpsLerpTo((stats.appear || shop.curYesno != null) ? 0xFFFFFF : 0x666666, speed);
        money.text.color = shop.box.color = stats.box.color = lerpColor.color;

        lerpColor.color = money.box.color;
        lerpColor.fpsLerpTo((stats.appear != null && shop.curYesno == null) ? 0x666666 : 0xFFFFFF, speed);
        money.box.color = lerpColor.color;

        lerpColor.color = gaster.color;
        lerpColor.fpsLerpTo(dialogue.lines != null ? 0xFFFFFF : 0xC7C7C7, speed);
        gaster.color = lerpColor.color;
    }
}

function updateControls() {
    if(!dialogueCondition()) {
        if(controls.BACK)
            exit();
        else if(shop.items.length != 0) {
            var change = ((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0)) - FlxG.mouse.wheel;
            if(change != 0)
                shop.changeItem(change);
            if(controls.ACCEPT || FlxG.keys.justPressed.Z || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(shop.box))) {
                if(!(controls.ACCEPT || FlxG.keys.justPressed.Z) && FlxG.mouse.justPressed) {
                    var cancelFunction = true;
                    for(a in shop.items) {
                        a.text.scale.set(a.text.scale.x * 4, a.text.scale.y); // hitbox increase (not visible for you dw!)
                        a.text.updateHitbox();

                        if(FlxG.mouse.overlaps(a.text)) {
                            if(!a.sold && a.text.ID != shop.curItem) {
                                if(!shop.items[shop.curItem].sold)
                                    shop.items[shop.curItem].text.color = FlxColor.WHITE;
                                shop.curItem = shop.items.indexOf(a);
                                shop.changeItem(0);
                                CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.8);
                                a.text.color = FlxColor.YELLOW;
                            } else if(a.text.color == FlxColor.YELLOW) cancelFunction = false;

                            a.text.scale.set(a.text.scale.x / 4, a.text.scale.y);
                            a.text.updateHitbox();
                            break;
                        }
                        a.text.scale.set(a.text.scale.x / 4, a.text.scale.y);
                        a.text.updateHitbox();
                    }
                    if(cancelFunction)
                        return;
                }
                if(shop.items[shop.curItem].sold)
                    return;
                shop.curYesno = 0;
                shop.heart.visible = false;
                shop.yesno[shop.curYesno].color = FlxColor.WHITE;
                shop.yesno[shop.curYesno].onDraw = null;
                shop.heart.setPosition(85, 608);
                shop.yesno[0].color = FlxColor.YELLOW;
                shop.yesno[shop.curYesno].onDraw = glowDraw;
                stats.appear = true;
                dialogue.start(shop.items[shop.curItem], "dialogue");
                FlxG.sound.play(Paths.sound("menu/select"));
            }
        }
    }
}

function dialogueCondition():Bool {
    if(dialogue.lines != null) {
        var yesno = dialogueQnA();
        if(dialogue.typeText.isTyping) {
            if(FlxG.keys.pressed.C && dialogue.txt.text.length > 1) {
                dialogue.typeText.skip(dialogue.typeText);
                if(dialogue.lines?.length > 0)
                    dialogue.resume();
                else
                    idleShop();
            } if(FlxG.keys.anyPressed([FlxKey.SHIFT, FlxKey.X]) || controls.BACK || ((shop.curYesno == null || (dialogue.lines.length != 0 && !yesno)) && FlxG.mouse.justPressed && FlxG.mouse.overlaps(dialogue.box))) {
                dialogue.typeText.skip(dialogue.typeText);
            }
        } else if((((controls.ACCEPT || FlxG.keys.justPressed.Z) || ((shop.curYesno == null || dialogue.lines.length != 0) && FlxG.mouse.justPressed && FlxG.mouse.overlaps(dialogue.box))) || FlxG.keys.justPressed.Z) && !yesno) {
            if(dialogue.lines?.length > 0) {
                dialogue.resume();
            } else if(dialogue.lines?.length == 0) {
                introDialogue == "beforeStoryMode" ? {dialogue.typeText.resetText("", dialogue.typeText); add(gaster).playAnim("idle"); exit();} : idleShop();
            }
        }
    } else return false;
    return true;
}

function dialogueQnA():Bool {
    if(shop.curYesno != null && dialogue.lines.length == 0) {
        if((controls.ACCEPT || FlxG.keys.justPressed.Z || FlxG.mouse.justPressed)) {
            if(FlxG.mouse.justPressed) {
                var cancelFunction = true;
                for (a in shop.yesno) {
                    a.scale.set(4, 4);
                    a.updateHitbox();
                    a.x -= a.width / 2;
                    a.y -= a.height / 2;
                    if (FlxG.mouse.overlaps(a)) {
                        cancelFunction = a.ID != shop.curYesno;
                        if(cancelFunction) {
                            CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.8);
                            shop.yesno[shop.curYesno].color = FlxColor.WHITE;
                            shop.yesno[shop.curYesno].onDraw = null;
                            shop.curYesno = a.ID;
                            shop.yesno[shop.curYesno].color = FlxColor.YELLOW;
                            shop.yesno[shop.curYesno].onDraw = glowDraw;
                        }
                        a.x += a.width / 2;
                        a.y += a.height / 2;
                        a.scale.set(1, 1);
                        a.updateHitbox();
                        break;
                    }
                    a.x += a.width / 2;
                    a.y += a.height / 2;
                    a.scale.set(1, 1);
                    a.updateHitbox();
                }
                if(cancelFunction)
                    return true;
            }

            idleShop();
            if(shop.curYesno == 0 && FlxG.save.data.dustinCash < shop.items[shop.curItem].cost) {
                shop.yesno[shop.curYesno].color = FlxColor.WHITE;
                shop.yesno[shop.curYesno].onDraw = null;
                dialogue.start(shop.data.dialogue, "buyFail");
                shop.curYesno = null;
                bgText.alpha = 0.2;
                shop.heart.x = 85;
                for(a in shop.yesno)
                    a.visible = false;
                return true;
            } else {
                if(shop.curYesno == 0) {
                    FlxG.save.data.dustinCash -= shop.items[shop.curItem].cost;
                    money.text.text = "EXP: " + FlxG.save.data.dustinCash;
                    money.text.updateHitbox();
                    money.text.x = Math.floor(money.box.x + (money.box.width - money.text.width) / 2);
                    if(shop.items[shop.curItem].song != null) {
                        FunkinSave.setSongHighscore(shop.items[shop.curItem].song, 'hard', null, {
                            score: 1,
                            misses: 0,
                            accuracy: 0,
                            hits: [],
                            date: ""
                        }, []);
                        if(!FlxG.save.data.dustinPurchasedShopCDs.contains(shop.items[shop.curItem].song)) {
                            FlxG.save.data.dustinPurchasedShopCDs.push(shop.items[shop.curItem].song);
                            FlxG.save.flush();
                        }
                        dustinShop["cds"][shop.items[shop.curItem].song] = true;
                        trace(dustinShop);
                    } else if(shop.items[shop.curItem].week != null ) {
                        FunkinSave.setWeekHighscore(shop.items[shop.curItem].week + '-1', 'hard', {
                            score: 1,
                            misses: 0,
                            accuracy: 0,
                            hits: [],
                            date: ""
                        });
                        dustinShop["keys"][shop.items[shop.curItem].week] = true;
                    }
                    shop.items[shop.curItem].text.color = FlxColor.GRAY;
                    shop.items[shop.curItem].text.text += " (SOLD OUT)";
                    shop.items[shop.curItem].sold = true;
                }
                if(!boughtAll())
                    dialogue.lines = Reflect.getProperty(shop.data.dialogue, shop.curYesno == 0 ? "buySuccess" : "buyCancel").copy();
                else
                    return true;
            }

            dialogue.resume();
            dialogue.lines = null;
            shop.yesno[shop.curYesno].color = FlxColor.WHITE;
            shop.yesno[shop.curYesno].onDraw = null;

            shop.curYesno = null;
            bgText.alpha = 0.2;
            shop.heart.x = 85;
            for(a in shop.yesno)
                a.visible = false;

        } else {
            var change = ((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
            if (change != 0) {
                CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.8);
                shop.yesno[shop.curYesno].color = FlxColor.WHITE;
                shop.yesno[shop.curYesno].onDraw = null;
                shop.curYesno = FlxMath.wrap(shop.curYesno + change, 0, shop.yesno.length-1);
                shop.yesno[shop.curYesno].color = FlxColor.YELLOW;
                shop.yesno[shop.curYesno].onDraw = glowDraw;
            }
        }
    } else return false;
    return true;
}

function exit() {
    left = true;
    if (FlxG.sound.music != null) FlxG.sound.music.stop();
        FlxG.sound.music = null;

    shopMusicStarted = false;
    if(FlxG.save.data.EggOne != true && FlxG.random.bool(5))
        FlxG.switchState(new ModState("EggState", "NewMainMenu"));
    else
        FlxG.switchState(new ModState("NewMainMenu"));
}

function destroy() FlxG.save.flush();
