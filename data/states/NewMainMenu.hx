//
import funkin.backend.MusicBeatState;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;

import flixel.addons.util.FlxSimplex;
import funkin.backend.utils.FlxInterpolateColor;
import openfl.display.BlendMode;
import funkin.savedata.FunkinSave;
import flixel.text.FlxText.FlxTextBorderStyle;

import funkin.backend.utils.HttpUtil;
import openfl.Lib;

var background:FunkinSprite;
var logo:FunkinSprite;
var menuEgg:FunkinSprite;
var eggClickSounds:Array<String> = Paths.getFolderContent("sounds/egg_sounds_1", false, -1, true);

var _list = CoolUtil.coolTextFile(Paths.txt("config/menuItems"));
var _socialList = CoolUtil.coolTextFile(Paths.txt("config/menuSocials"));
var _socialLinks = CoolUtil.coolTextFile(Paths.txt("config/menuSocials_link"));
var socialsTxt:FunkinText;

var options:Array<FunkinText> = [];
var selectedColor:FlxInterpolateColor = new FlxInterpolateColor(0xFFFFFFFF);

function colorText(a:FlxText) {
    var selected = focused == "y" && a.ID == curSelected.y;

    a.color = selected ? 0xFFFFFF00 : selectedColor.color;
    a.borderColor = selected ? 0xFF532B00 : 0xFF222222;
}

var socialOptions:Array<FunkinSprite> = [];

// ui navigation, control with mouse/keyboard.
var curSelected:FlxPoint = FlxPoint.get();
var prevSelected = FlxPoint.get();

var focused:String = "y";

var hasInternet:Bool = HttpUtil.hasInternet();

var canSelect:Bool = true;

function changeSelection(x:Null<Float>, y:Null<Float>, ?force:Bool = false) {
    if(y != null) {
        curSelected.y = FlxMath.wrap(force ? y : curSelected.y + y, 0, options.length - 1);
        if (prevSelected.y != curSelected.y || focused == "x") {
            focused = "y";
            colorTimer = 0;
            FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
            for (a in options)
                colorText(a);
        }
    }

    if(hasInternet) {
        if(x != null) {
            curSelected.x = FlxMath.wrap(force ? x : curSelected.x + x, 0, socialOptions.length - 1);
            if (prevSelected.x != curSelected.x || focused == "y") {
                focused = "x";
                colorTimer = 0;
                FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
                for (a in options)
                    colorText(a);
            }
        }
    }

    prevSelected.set(curSelected.x, curSelected.y);
}

var intro:Bool = true;
static var firstIntro:Bool = true;

var blockInput:Bool = false;

//Depending on what ending you got in storymode
static var menuType:String = "default";

function create() {
    //FlxG.save.data.EggOne = true;
    //FlxG.save.flush();
    snow = importScript("data/scripts/light-shader");
    snow.set("initIndex", members.length);

    FlxG.camera.bgColor = 0xFF000000;
    FlxG.mouse.visible = true;
    playMusic("mainMenu", 1);


    if (FlxG.save.data.firstTimeBackgroundAnniversary == null)
        FlxG.save.data.firstTimeBackgroundAnniversary = false;
    else if (FlxG.save.data.firstTimeBackground == null)
        FlxG.save.data.firstTimeBackground = false;
    if (FlxG.save.data.lastBackground == null)
        FlxG.save.data.lastBackground = 1; // default

    background = new FunkinSprite();

    var bgNum:Int = 1;
    switch(menuType) {
        // not too sure on using yet - hig
        // case 'genocide':
        //     bgNum = 7;
        //     background.color = 0x98ABFF;
        //     if(FlxG.save.data.saturation) {
        //         var saturation:CustomShader = new CustomShader('saturation');
        //         saturation.sat = 0.5;
        //         saturation.contrast = 1;
        //         FlxG.camera.addShader(saturation);
        //     }
        default:
            if (!FlxG.save.data.firstTimeBackgroundAnniversary) {
                bgNum = 8;
                FlxG.save.data.firstTimeBackgroundAnniversary = true;
                FlxG.save.flush();
            }
            else if (!FlxG.save.data.firstTimeBackground)
            {
                // First time: show default background
                FlxG.save.data.firstTimeBackground = true;
                FlxG.save.data.lastBackground = 1;
                FlxG.save.flush();
            }
            else
            {
                // Choose a random background from 2–6 that isn't the same as last time
                var limit:Int = 1;
                if(FunkinSave.getSongHighscore("the-uprising", "hard").score > 1)
                    limit = 4;
                if(FunkinSave.getSongHighscore("you-are", "hard").score > 1)
                    limit = 8;
                trace(limit);
                bgNum = FlxG.random.int(1, limit);
                if (bgNum == FlxG.save.data.lastBackground)
                {
                    // If it's the same as last time, reroll once
                    bgNum = FlxG.random.int(1, limit);
                }

                FlxG.save.data.lastBackground = bgNum;
                FlxG.save.flush();
            }
    }
    var bgPath:String = 'menus/main/background_' + bgNum;

    background.loadGraphic(Paths.image(bgPath));
    background.antialiasing = false;
    background.scale.set(0.35, 0.35);
    background.updateHitbox();
    background.screenCenter();
    background.scrollFactor.set(0.5, 0.5);
    add(background);


    logo = new FunkinSprite(0, FlxG.height * 0.25).loadGraphic(Paths.image('menus/main/logo-celebrate'));
    //logo.scale.set(0.25, 0.25);
    logo.scale.set(0.55, 0.55);
    logo.updateHitbox();
    logo.screenCenter();
    //logo.x -= 7.5;
    logo.antialiasing = Options.antialiasing;
    add(logo);

    if (FlxG.save.data.EggOne == true) {
        menuEgg = new FunkinSprite(25, 0, Paths.image("menus/main/egg"));
        menuEgg.scale.set(0.8, 0.8);
        menuEgg.updateHitbox();
        menuEgg.y = FlxG.height - menuEgg.height - 22;
        menuEgg.antialiasing = false;
        add(menuEgg);
    }

    if (!dustinShop["boughtAll"]) _list.remove("GALLERY");

    for (k => v in _list) {
        var txt = textCrispy(new FunkinText(0, 0, 0, v, 24, false));
        txt.setFormat(Paths.font("8bit-jve.ttf"), 48, 0xFFFFFF00, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        txt.ID = k;
        txt.borderSize = 3;
        add(txt);
        colorText(txt);
        options.push(txt);
    }

    if(hasInternet) {
        for (k => v in _socialList) {
            var social = new FunkinSprite(FlxG.width - 100 - (55 * (_socialList.length - k - 1)), FlxG.height - 50).loadGraphic(Paths.image("menus/main/social_" + v));
            social.alpha = 0;
            social.scale.set(2.5, 2.5);
            social.updateHitbox();
            social.y -= social.height;
            add(social);
            social.ID = k;
            socialOptions.push(social);
        }

        socialsTxt = textCrispy(new FunkinText(socialOptions[0].x + 32, socialOptions[0].y + 50, 0, "SOCIALS", 24, false));
        socialsTxt.setFormat(Paths.font("DTM-Mono.ttf"), 20, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        socialsTxt.borderSize = 3;
        add(socialsTxt);
        socialsTxt.alpha = 0;
    }

    logo.alpha = 0;
    if (menuEgg != null) menuEgg.alpha = 0;
    for (a in options) {
        a.alpha = 0;
    }
    background.alpha = 0;

    //Making sure the snow shader script loads first
    Lib.application.window.onMouseMove.add(onMouseMoved);
    // if (FlxG.save.data.particles) {
    //     new FlxTimer().start(0.001, () -> {
    //         switch(menuType) {
    //             case 'genocide':
    //                 snowOpacity = 0.5;
    //                 snowShader.SPEED = 0.25;
    //                 snowShader2.SPEED = 0.25;
    //         }
    //     });
    // }
}
var fadeInTimer:Float = 0;
var fadeInDuration:Float = 2.5;

var idleTimer:Float = 0;
var colorTimer:Float = 0;
function update(elapsed:Float):Void {
    var clickedEgg:Bool = false;

    if (!blockInput && menuEgg != null && menuEgg.alpha > 0 && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuEgg)) {
        clickedEgg = true;
        if (eggClickSounds.length > 0) {
            var soundName:String = eggClickSounds[FlxG.random.int(0, eggClickSounds.length - 1)];
            FlxG.sound.play(Paths.sound("egg_sounds_1/" + soundName));
        }
    }

    if(colorTimer < 1) {
        colorTimer += elapsed * .85;
        selectedColor.lerpTo(focused == "y" ? 0xFFFFFF : 0x666666, Math.min(FlxEase.quadOut(colorTimer), 1));
        for (a in options)
            colorText(a);
    }
    if(!FlxG.keys.justPressed.ANY && (FlxG.mouse.deltaScreenY == 0 && FlxG.mouse.deltaScreenX == 0)) {
        idleTimer += elapsed;
    } else {
        if(idleTimer > 10)
            fadeInTimer = 2.2;
        idleTimer = 0;
    }
    // if (FlxG.keys.justPressed.A)
    //     FlxG.switchState(new ModState("PreMainMenuVideo"));

    if(!blockInput) {
        var change = (controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel;
        if (change != 0) changeSelection(null, focused == "y" ? change : 0);

        if(hasInternet) {
            change = (controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0);
            if (change != 0) changeSelection(focused == "x" ? change : 0, null);
        }
    }

    if (!clickedEgg && (firstIntro ? !intro : true) && (controls.ACCEPT || FlxG.mouse.justPressed) && canSelect) select();

    if (Options.devMode && FlxG.keys.justPressed.SEVEN) {
        persistentUpdate = false;
        persistentDraw = true;
        openSubState(new EditorPicker());
    }

    #if !DUSTIN_CUSTOM_BUILD
    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }
    #end

    FlxG.camera.scroll.x = lerp(FlxG.camera.scroll.x, FlxSimplex.simplex(Conductor.songPosition / 3000, 0) * 4, 0.05);
    FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, FlxSimplex.simplex(Conductor.songPosition / 3000, 1) * 4 + 2 * curSelected.y, 0.05);
    logo.y = lerp(logo.y, FlxG.height * 0.25 - logo.height / 2 + 5 * curSelected.y, 0.05);

    if (background.alpha < 1) {
        background.alpha += elapsed / fadeInDuration;
        if (background.alpha > 1) background.alpha = 1;
    }

    if(!blockInput) {
        if (fadeInTimer <  1) {
            fadeInTimer += elapsed;
        } else if (fadeInTimer <  1 + fadeInDuration) {
            fadeInTimer += elapsed;
            var t = (fadeInTimer -  1) / fadeInDuration;
            t = Math.min(t, 1);

            logo.alpha = t;
            if (menuEgg != null) menuEgg.alpha = t;
            for (a in options)
                a.alpha = t;
            
        } else {
            var alphaV:Float = idleTimer > 10 ? Math.max(0.5, logo.alpha - (elapsed * .1)) : 1;
            var alphaV2:Float = idleTimer > 10 ? Math.max(0, options[0].alpha - (elapsed * .2)) : 1;
            logo.alpha = alphaV;
            if (menuEgg != null) menuEgg.alpha = alphaV;
            for (a in options)
                a.alpha = alphaV2;
            
        }
    }

    if(hasInternet) {
        socialsTxt.alpha = logo.alpha * (focused == "x" ? 1 : 0.85);
    }

    intro = !(fadeInTimer > fadeInDuration*.8);
    if (firstIntro && !intro) firstIntro = false;
}

function postUpdate(elapsed:Float) {
    for (a in options) {
        var selected:Bool = focused == "y" && a.ID == curSelected.y;
        var s = 1.0 + (selected ? 0.2 : 0);
        a.scale.x = a.scale.y = lerp(a.scale.x, s, 0.25);
        a.updateHitbox();
    }

    if(hasInternet) {
        for (b in socialOptions) {
            var selected:Bool = focused =="x" && b.ID == curSelected.x;
            var s = 2.5 + (selected ? 0.2 : 0);
            b.scale.x = b.scale.y = lerp(b.scale.x, s, 0.25);

            b.alpha = lerp(b.alpha, socialsTxt.alpha * (b.ID == curSelected.x ? 1 : 0.65), 0.25);
        }
    }

    // awesome math time woo hoo (╯°□°)╯( ┻━┻
    // evenly splitting them up n shit im da goat like dat

    var minY = FlxG.height * 0.5;
    var maxY = FlxG.height * 0.8;

    var totalLeftoverHeight = maxY - minY;
    for (a in options) totalLeftoverHeight -= a.height;

    var gapSize = totalLeftoverHeight / (options.length - 1) / 1.65;
    var cursorY = minY;
    for (a in options) {
        a.x = FlxG.width / 2 - a.width / 2;
        a.y = cursorY;
        cursorY += gapSize + a.height;
    }
}

function eggRoomRoll(?destination:String = "NewMainMenu"):Bool {
    if (FlxG.save.data.EggOne != true && FlxG.random.bool(5)) {
        FlxG.switchState(new ModState("EggState", destination));
        return true;
    }
    return false;
}

function select() {
    FlxG.sound.play(Paths.sound("menu/select"), 0.9);
    if(focused == "y") {
        canSelect = false;
        new FlxTimer().start(0.15, (_) -> {
            switch (_list[curSelected.y]) {
                case "STORY MODE":
                    if (!eggRoomRoll()) {
                        blockInput = true;
                        FlxG.sound.music.fadeOut(0.75,0);

                        if (FlxG.save.data.particles) {
                            FlxTween.num(snowOpacity, 0, 1, {ease: FlxEase.quartOut}, (val:Float) -> {
                                snowOpacity = val;
                            });
                        }

                        FlxG.camera.fade(FlxColor.BLACK, 0.8, false, () -> {
                            MusicBeatState.skipTransOut = true;
                            FlxG.switchState(new StoryMenuState());
                        }, true);
                    }
                case "FREEPLAY":
                    if (!eggRoomRoll()) {
                        blockInput = true;
                        FlxG.sound.music.fadeOut(0.75,0);

                        if (FlxG.save.data.particles) {
                            FlxTween.num(snowOpacity, 0, 1, {ease: FlxEase.quartOut}, (val:Float) -> {
                                snowOpacity = val;
                            });
                        }
                        FlxG.camera.fade(FlxColor.BLACK, 0.8, false, () -> {
                            MusicBeatState.skipTransOut = true;
                            FlxG.switchState(new ModState("NewFreeplayMenu"));
                        }, true);
                    }
                case "OVERWORLD": FlxG.switchState(new ModState("overworld_rooms/room_area1"));
                case "SHOP":
                    if (!eggRoomRoll("ShopState"))
                        FlxG.switchState(new ModState("ShopState"));
                case "GALLERY":
                    if (!eggRoomRoll())
                        FlxG.switchState(new ModState("gallery/GalleryState"));
                case "OPTIONS":
                    if (!eggRoomRoll())
                        FlxG.switchState(new OptionsMenu());
                case "CREDITS": FlxG.switchState(new ModState("CreditsState"));
                default: 
                    trace('idk');
                    canSelect = true;
            }
        });
    } else if(hasInternet) CoolUtil.openURL(_socialLinks[curSelected.x]);
}


var windowFocus:Bool = true;
function onFocus() if (FlxG.autoPause) windowFocus = true;
function onFocusLost() if (FlxG.autoPause) windowFocus = false;

function onMouseMoved(?x:Float = 0, ?y:Float = 0) {
    if(windowFocus && blockInput && !canSelect)
        return;
    for (a in options) {
        if (FlxG.mouse.overlaps(a)) {
            changeSelection(null, a.ID, true);
            break;
        }
    }

    for (b in socialOptions) {
        if (FlxG.mouse.overlaps(b)) {
            changeSelection(b.ID, null, true);
            break;
        }
    }
}

function destroy() {
    Lib.application.window.onMouseMove.remove(onMouseMoved);
}
