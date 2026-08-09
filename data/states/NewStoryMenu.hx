/*
░░░░░░░░░░░░░░░░██████████████████░░░░░░░░░░░░░░
░░░░░░░░░░░░████░░░░░░░░░░░░░░░░░░████░░░░░░░░░░
░░░░░░░░░░██░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░░░░░
░░░░░░░░░░██░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░░░░░
░░░░░░░░██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░░░
░░░░░░░░██░░░░░░░░░░░░░░░░░░░░██████░░░░██░░░░░░
░░░░░░░░██░░░░░░░░░░░░░░░░░░░░██████░░░░██░░░░░░
░░░░░░░░██░░░░██████░░░░██░░░░██████░░░░██░░░░░░
░░░░░░░░░░██░░░░░░░░░░██████░░░░░░░░░░██░░░░░░░░
░░░░░░░░████░░██░░░░░░░░░░░░░░░░░░██░░████░░░░░░
░░░░░░░░██░░░░██████████████████████░░░░██░░░░░░
░░░░░░░░██░░░░░░██░░██░░██░░██░░██░░░░░░██░░░░░░
░░░░░░░░░░████░░░░██████████████░░░░████░░░░░░░░
░░░░░░░░██████████░░░░░░░░░░░░░░██████████░░░░░░
░░░░░░██░░██████████████████████████████░░██░░░░
░░░░████░░██░░░░██░░░░░░██░░░░░░██░░░░██░░████░░
░░░░██░░░░░░██░░░░██████░░██████░░░░██░░░░░░██░░
░░██░░░░████░░██████░░░░██░░░░██████░░████░░░░██
░░██░░░░░░░░██░░░░██░░░░░░░░░░██░░░░██░░░░░░░░██
░░██░░░░░░░░░░██░░██░░░░░░░░░░██░░██░░░░░░░░░░██
░░░░██░░░░░░██░░░░████░░░░░░████░░░░██░░░░░░██░░
░░░░░░████░░██░░░░██░░░░░░░░░░██░░░░██░░████░░░░
░░░░░░░░██████░░░░██████████████░░░░██████░░░░░░
░░░░░░░░░░████░░░░██████████████░░░░████░░░░░░░░
░░░░░░░░██████████████████████████████████░░░░░░
░░░░░░░░████████████████░░████████████████░░░░░░
░░░░░░░░░░████████████░░░░░░████████████░░░░░░░░
░░░░░░██████░░░░░░░░██░░░░░░██░░░░░░░░██████░░░░
░░░░░░██░░░░░░░░░░████░░░░░░████░░░░░░░░░░██░░░░
░░░░░░░░██████████░░░░░░░░░░░░░░██████████░░░░░░
*/

import flixel.addons.util.FlxSimplex;
import funkin.backend.MusicBeatState;
import funkin.backend.utils.BitmapUtil;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.menus.StoryMenuState.StoryWeeklist;
import funkin.savedata.FunkinSave;

import openfl.Lib;

//WEEK DATA
function pushWeekData(x:Float, y:Float, ?key:Null<String> = null, color:Int)
    return {
        x: x,
        y: y,
        week: null,
        weeks: [],
        key: key,
        color: color,

        scale: 1,
        spr: null,
        lock: null,
        unlocked: false
    }

var weeks:StoryWeeklist = StoryWeeklist.get();
var weekList = [
    "dusttale" => pushWeekData(125, 50, null, FlxColor.WHITE),
    "dustswap" => pushWeekData(130, 405, "mirror key", FlxColor.ORANGE),
    "dustfell" => pushWeekData(395, 400, "wrath key", FlxColor.RED),
    "dustbelief" => pushWeekData(670, 405, "guilty key", FlxColor.CYAN),
    "dustshift" => pushWeekData(925, 400, "virus key", FlxColor.RED)
];

//makes keyboard support easier to handle
var weekArray(get, default) = [];
function get_weekArray() {
    var arr = [];
    for(week in [weekList["dustswap"], weekList["dustfell"], weekList["dustbelief"], weekList["dustshift"]]) {
        if(week.unlocked) arr.push(week);
    }
    return arr;
}

var keyScript;
var keys = [
    "dustswap" => null,
    "dustfell" => null,
    "dustbelief" => null,
    "dustshift" => null
];

var quedLocks:Array<Dynamic> = [];

function createWeekSprites() {

    weeks.weeks.sort((a, b) -> return Std.parseInt(a.id.split("-")[1]) - Std.parseInt(b.id.split("-")[1]));
    for (week in weeks.weeks) {
        var idk = weekList[getWeekName(week)];
        if (idk != null) idk.weeks.push(week);
    }

    var countedWeeks:Array<String> = [];
    for (week in weeks.weeks) {
        var weekID = getWeekName(week);
        if(!countedWeeks.contains(weekID))
            countedWeeks.push(weekID);
        else 
            continue;
        if(weekList[weekID] != null)
            weekList[weekID].week = week;
    }
    countedWeeks = null;

    var frames = Paths.getFrames("menus/freeplay/characters");
    var ID:Int = -1;
    for(key in weekList.keys()) {

        graphicCache.cache(Paths.image("menus/story/select_screens/" + key)); // select screen

        var data = weekList[key];
        var spr:FunkinSprite = new FunkinSprite(data.x, data.y);
        spr.frames = frames;

        spr.addAnim("idle", key + "0", true);
        spr.addAnim("selected", key + " select", true);
        spr.playAnim("idle");
        spr.updateHitbox();

        spr.origin.y = spr.height;

        spr.antialiasing = Options.antialiasing;

        spr.color = colorLOCKED;

        data.spr = spr;
        add(spr);
        weekSprites.push(spr);

        final score:Float = FunkinSave.getWeekHighscore(data.week.id, data.week.difficulties[0]).score;
        data.unlocked = score > 0 && score != 1;

        if(data.key != null) {
            spr.alpha = 0;
            spr.ID = 0;
            ID++;
        } else spr.ID = (data.unlocked ? 3 : 0); // unlocked

        if(data.unlocked || key == "dusttale") {
            spr.ID = 1;
            if(key != "dusttale") hasUnlockedWeeks = true;
        }
        else if(spr.ID == 0) {
            final offset:Array<Int> = switch (key) {
                case "dustswap": [25, -15];
                case "dustfell": [-5, -15];
                case "dustbelief": [5, -10];
                case "dustshift": [-30, -30];
                default: [0, 0];
            };
            final anim:String = data.key.split(" ")[0];
            var lock:FunkinSprite = new FunkinSprite(0, 0, Paths.image("menus/story/locks"));
            lock.antialiasing = Options.antialiasing;
            lock.setPosition(spr.getMidpoint().x - lock.width / 2 + offset[0], spr.getMidpoint().y - lock.height / 2 + offset[1]);
            lock.addAnim(anim, anim, 0, false);
            lock.playAnim(anim, true, null, true);
            lock.ID = ID;
            data.lock = lock;
            insert(members.indexOf(spr) + 1, lock);
            spr.color = FlxColor.BLACK;
            if(Options.gameplayShaders && FlxG.save.data.water)
                spr.shader = water;
            if(score == 1 && data.key != null && dustinShop["keys"][key]) {
                quedLocks.push(key);
            }
        }
    }
}

function getWeekName(week)
    return week.id.split("-")[0];

// SPRITES
var pillarFront:FunkinSprite;
var pillarBack:FunkinSprite;

var dustText:FunkinSprite;

var weekSprites:Array<FunkinSprite> = [];
var curWeek = {
    week: null,
    weeks: null,
    sprite: null
}

var selectScreen:FunkinSprite;

// FILTERS
var water:CustomShader;
var camWater:CustomShader;
var distortion:CustomShader;
var warp:CustomShader;

var bloom:CustomShader;
var blackFlash:CustomShader;
var glitch:CustomShader;

var colorLerp:FlxInterpolateColor = new FlxInterpolateColor(FlxColor.WHITE);

// MISC
var fadeMusic:Bool = false;
var colorLOCKED:Int = 0xFFB1B1B1; 
var camKey:FlxCamera;

function create() {
    var delay:Float = 0.28;

    if(Options.gameplayShaders) {
        if (FlxG.save.data.water) water = new CustomShader("waterDistortion");
        if (FlxG.save.data.bloom) {
            bloom = new CustomShader("bloom");
            bloom.size = 20;
            bloom.brightness = 5;
            bloom.directions = 8;
            bloom.quality = 10;
        }
        if (FlxG.save.data.impact)
            blackFlash = new CustomShader("impact_frames");
        if (FlxG.save.data.glitch) {
            glitch = new CustomShader("glitching");
            glitch.SPEED = 1;
            glitch.AMT = 0.7;
        }
    }

    FlxG.camera.fade(FlxColor.BLACK, 1.25, true);

    add(pillarFront = new FunkinSprite().loadGraphic(Paths.image("menus/story/background 1")));
    pillarFront.zoomFactor = 0.8;

    add(pillarBack = new FunkinSprite().loadGraphic(Paths.image("menus/story/background 2")));
    pillarBack.zoomFactor = 0.8;

    createWeekSprites();
    weekList["dusttale"].spr.zoomFactor = 1.4;

    add(dustText = new FunkinSprite().loadGraphic(Paths.image("menus/story/text")));
    dustText.alpha = 0;

    add(selectScreen = new FunkinSprite());
    selectScreen.visible = false;

    pillarFront.antialiasing = pillarBack.antialiasing = dustText.antialiasing = selectScreen.antialiasing = Options.antialiasing;

    if(quedLocks.length > 0) {
        delay = 0;
        playMusic('storyNfreeplay', 1, false);
        if (FlxG.sound.music != null)
            FlxG.sound.music.volume = 0;
        fadeMusic = false;
        keyScript = importScript("data/scripts/PreloadSongItems");
        createLockSequence();
    } else {
        if (curMusicID != 'storyNfreeplay' || FlxG.sound.music == null) {
            playMusic('storyNfreeplay', 1, true);
            FlxG.sound.music.volume = 0;
        }
        if (!FlxG.sound.music.playing) {
            FlxG.sound.music.play();
            FlxG.sound.music.volume = 0;
        }
        fadeMusic = true;
    }

    //Tweening animations

    FlxTween.tween(dustText, {alpha: 1}, 1.25, {ease: FlxEase.quartOut, startDelay: delay});
    if(Options.gameplayShaders && FlxG.save.data.water) {
        dustText.shader = water;
        water.time = 0;
        water.strength = 0.5;
        FlxTween.tween(water, {strength: 0.1}, 2, {ease: FlxEase.quartOut, startDelay: delay});
    }

    for(spr in weekSprites) {
        if(spr.alpha == 0)
            FlxTween.tween(spr, {alpha: 1}, 1.25, {ease: FlxEase.quartOut, startDelay: delay});
    }

    camera.zoom = (quedLocks.length == 0) ? 1.2 : 1.3;
    camera.scroll.y = (quedLocks.length == 0) ? -60 : -90;

    if(quedLocks.length == 0) {
        new FlxTimer().start(0.75, () -> {
            canLerp = true;
            Lib.application.window.onMouseMove.add(onMouseMoved);
            onMouseMoved();
        });
    }

    FlxTween.tween(camera, {zoom: 1}, 1.25, {
        ease: FlxEase.quartOut,
        startDelay: delay,
    });

    FlxTween.tween(camera.scroll, {y: 0}, 1.25, {ease: FlxEase.quartOut, startDelay: delay});
}

var blackBG:FunkinSprite;
function createLockSequence() {
    camKey = new FlxCamera();
    camKey.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(camKey, false);

    blackBG = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBG.alpha = 0;
    insert(members.indexOf(dustText), blackBG);
    if(Options.gameplayShaders) {
        if (FlxG.save.data.bloom)
            camKey.addShader(bloom);

        if (FlxG.save.data.chromwarp) {
            distortion = new CustomShader("chromaticWarp");
            distortion.distortion = 0.15;
            camera.addShader(distortion);
        }

        if (FlxG.save.data.warp) {
            warp = new CustomShader("warp");
            camKey.addShader(warp);
        }

        if (FlxG.save.data.water) {
            camWater = new CustomShader("waterDistortion");
            camWater.time = 0;
            camWater.strength = 0.5;
            camera.addShader(camWater);
        }

        if (Options.gameplayShaders) {
            FlxTween.num(0, 0.15, 1.25, {ease: FlxEase.quartOut}, function(num) {
                if (FlxG.save.data.warp)
                    warp.distortion = num * 2;
                if (FlxG.save.data.camWater)
                    camWater.strength = 0.5 - (num * 0.3);
            });
        }
    }
    var ID:Int = -1;
    for(i => lockData in quedLocks) {
        ID++;
        var path = weekList[lockData].key;
        var data = weekList[lockData];
        final anim:String = data.key.split(" ")[0];

        var key:FunkinSprite = new FunkinSprite(0, 0, keyScript.call("image", ["key", path]));
        key.camera = camKey;
        key.antialiasing = Options.antialiasing;
        key.setPosition(FlxG.width / 2 - key.width / 2, -key.height);
        key.scale.set(0.5, 0.5);
        key.addAnim(path, path);
        key.playAnim(path, true, null, true);
        key.ID = ID;
        add(key);

        FlxTween.tween(key, {
            x: FlxG.width / (quedLocks.length + 1) * (i + 1) - key.width / 2,
            y: FlxG.height / 2 - key.height / 2,
            'scale.x': 1,
            'scale.y': 1
        }, 1, {ease: FlxEase.circInOut});

        if(Options.gameplayShaders && FlxG.save.data.bloom) {
            new FlxTimer().start(1, function(_) {
                FlxTween.num(5, 1.15, 2, {ease: FlxEase.sineOut}, function(num) {
                    bloom.brightness = num;
                });
            });
        }



        keys[lockData] = {
            lock: weekList[lockData].lock,
            key: key,
            week: weekList[lockData],
            ID: lockData
        };
    }

    quedLocks = [];

    for(key in keys.keys()) {
        if(keys[key] != null)
            quedLocks.push(keys[key]);
    }

    loadLocks();
}

function loadLocks() {
    var keyData = quedLocks[quedLocks.length - 1];
    var lock:FunkinSprite = keyData.lock;
    var key:FunkinSprite = keyData.key;
    keyData.week.spr.ID = 1; // unlocks

    remove(blackBG, true);
    remove(lock, true);
    insert(members.indexOf(dustText), lock);
    insert(members.indexOf(lock), blackBG);

    new FlxTimer().start(1.05, function(_) {
        FlxTween.tween(key, {
            x: keyData.week.spr.getMidpoint().x - key.width / 2,
            y: keyData.week.spr.getMidpoint().y - key.height / 2
        }, 1, {ease: FlxEase.circInOut});

        if(Options.gameplayShaders) {
            if (FlxG.save.data.chromwarp)
                FlxTween.tween(distortion, {distortion: 0.25}, 0.25, {ease: FlxEase.sineIn});
            if (FlxG.save.data.warp)
                FlxTween.tween(warp, {distortion: 0.25 * 2}, 0.25, {ease: FlxEase.sineIn});
        }

        var camPosX:Float = keyData.week.spr.getMidpoint().x - key.width / 2;
        camPosX *= 0.08;

        if(lock.ID != 0 && lock.ID != 3)
            camPosX = -60 + camPosX * 0.08; // LEFT SIDE POSITION

        FlxTween.tween(camera, {zoom: 1.1, "scroll.x": camPosX, "scroll.y": 25}, 2, {ease: FlxEase.cubeInOut});
    });

    new FlxTimer().start(1.35, function(_) {
        FlxTween.tween(lock.scale, {x: 1.15, y: 1.15}, 1.2, {ease: FlxEase.circInOut});
    });

    new FlxTimer().start(1.5, function(_) {
        if(Options.gameplayShaders) {
            if (FlxG.save.data.chromwarp)
                FlxTween.tween(distortion, {distortion: 0.8}, 1.25, {ease: FlxEase.quartOut, startDelay: 0.25});
            if (FlxG.save.data.warp)
                FlxTween.tween(warp, {distortion: 0.8}, 1.25 * 2, {ease: FlxEase.quartOut, startDelay: 0.25});
        }
        FlxG.sound.play(Paths.sound("unlocks/" + keyData.ID));
        lock.animation.curAnim.curFrame = 1;
    });

    new FlxTimer().start(1.55, () -> {
        FlxTween.tween(key, {'scale.x': 0.1, 'scale.y': 0.1, alpha: 0}, 1.2, {ease: FlxEase.circInOut, onComplete: (_) -> {
            if(Options.gameplayShaders && FlxG.save.data.bloom) {
                keyData.week.spr.shader = null;
                if(FlxG.save.data.bloom) camera.addShader(bloom);
            }
            lock.animation.curAnim.curFrame = 3;
            keyData.week.spr.color = FlxColor.WHITE;
            quedLocks.remove(keyData);

            FlxTween.num(FlxG.save.data.antiFlash ? 0.15 : 2, 0, 2, {
                ease: FlxEase.quintOut,
                onComplete: () -> {
                    if(Options.gameplayShaders && FlxG.save.data.bloom) FlxG.camera.removeShader(bloom); // also lowk needed to add this
                    FunkinSave.setWeekHighscore(keyData.week.week.id, 'hard', {
                        score: 2,
                        misses: 0,
                        accuracy: 0,
                        hits: [],
                        date: ""
                    });
                }
            }, (num) -> {
                // restructure
                if(Options.gameplayShaders && FlxG.save.data.bloom) {
                    bloom.size = 20 * num;
                    bloom.brightness = 1 + (20 * num);
                }
            });
            if (Options.gameplayShaders) {
                var intensity:Float = (quedLocks.length == 0) ? 0 : 0.15;
                if (FlxG.save.data.water) {
                    FlxTween.tween(camWater, {strength: 0}, 1, {ease: FlxEase.sineInOut,
                        onComplete: (_) -> {
                            FlxTween.tween(camWater, {strength: (quedLocks.length == 0) ? 0 : 0.15}, 0.8, {ease: FlxEase.sineInOut});
                        }
                    });
                }

                if (FlxG.save.data.chromwarp) FlxTween.tween(distortion, {distortion: intensity}, 1, {ease: FlxEase.sineInOut});
                if (FlxG.save.data.warp) FlxTween.tween(warp, {distortion: intensity * 2}, 1, {ease: FlxEase.sineInOut});
            }
            FlxTween.tween(blackBG, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
            FlxTween.tween(camera, {zoom: 1, "scroll.x": 0, "scroll.y": 0}, 1, {ease: FlxEase.quartOut});
            FlxTween.tween(lock, {alpha: 0}, 2, {ease: FlxEase.quintOut});
        }});
    });
    new FlxTimer().start(1.8, () -> FlxTween.tween(blackBG, {alpha: 0.3}, 0.45, {ease: FlxEase.sineOut}));
    new FlxTimer().start(2.1, () -> lock.animation.curAnim.curFrame = 2);

    if(Options.gameplayShaders && FlxG.save.data.water)
        new FlxTimer().start(3.85, () -> FlxTween.tween(camWater, {strength: (quedLocks.length == 0) ? 0 : 0.15}, 0.8, {ease: FlxEase.sineInOut}));

    new FlxTimer().start(5, () -> {
        if(quedLocks.length == 0) {
            playMusic('storyNfreeplay', 1, true);
            canLerp = true;
            Lib.application.window.onMouseMove.add(onMouseMoved);
            onMouseMoved();
            FlxG.cameras.remove(camKey, true);
            new FlxTimer().start(1, () -> fadeMusic = true);
        } else {
            FlxTween.color(keyData.week.spr, 1, FlxColor.WHITE, colorLOCKED, {ease: FlxEase.sineOut});
            loadLocks();
        }
    });
}

var canLerp:Bool = false;
var weekSelected:Bool = false;
var zoomLevel:Float = 1;

// for keyboard support
var curSelectX:Int = 0;
var hasUnlockedWeeks:Bool = false;

var _timer:Float = FlxG.random.float(1, 100);
function update(elapsed:Float) {
    _timer += elapsed;
    if (Options.gameplayShaders) {
        if (FlxG.save.data.water) {
            water?.time = _timer * 0.25;
            camWater?.time = water?.time;
        }
        if (FlxG.save.data.glitch)
            glitch?.iTime = _timer;
    }

    if(canLerp) {
        if(FlxG.keys.justPressed.ANY) {
            if(controls.UP_P && (curWeek.sprite == null || curWeek.sprite != weekList["dusttale"].spr)) {
                setCurWeek("dusttale");
                zoomLevel = 1.02;
            } else if(controls.DOWN_P && hasUnlockedWeeks > 0 && (curWeek.sprite == null || getWeekName(curWeek.week) == "dusttale")) {

                setCurWeek(getWeekName(weekArray[curSelectX].week));
                zoomLevel = 1;
                
            } else if((controls.LEFT_P || controls.RIGHT_P) && !(controls.LEFT_P && controls.RIGHT_P) && hasUnlockedWeeks && curWeek.sprite != null && getWeekName(curWeek.week) != "dusttale") {
                curSelectX += (controls.RIGHT_P ? 1 : -1);
                var weekArr = weekArray;
                curSelectX = FlxMath.wrap(curSelectX, 0, weekArr.length - 1);
                setCurWeek(getWeekName(weekArr[curSelectX].week));
            } else if (controls.BACK) {
                exit();
            }
        }
        for(spr in weekSprites) {
            var scale:Float = (curWeek.sprite == spr) ? 1.05 : 1;
            if(weekList["dusttale"].spr != spr)
                scale -= zoomLevel - 1;
            else
                scale += (zoomLevel - 1) * 1.05;

            spr.scale.x = spr.scale.y = CoolUtil.fpsLerp(spr.scale.x, scale, 0.085);
            colorLerp.color = spr.color;
            if (spr.color != FlxColor.BLACK) {
                colorLerp.lerpTo((curWeek.sprite == spr) ? FlxColor.WHITE : colorLOCKED, 0.05);
                spr.color = colorLerp.color;
            }
        }

        if(curWeek.sprite != null && (FlxG.mouse.justPressed || controls.ACCEPT))
            select();
        else if(controls.ACCEPT && curWeek.sprite == null) {
            setCurWeek("dusttale");
            zoomLevel = 1.02;
        }

        camera.zoom = CoolUtil.fpsLerp(camera.zoom, zoomLevel, 0.085);
    } else if(weekSelected)  {
        FlxG.camera.scroll.set();
        FlxG.camera.angle = 0;
        updateShake(elapsed);
    } else {
        if(camKey != null) {
            camKey.zoom = camera.zoom; camera.scroll.copyTo(camKey.scroll);
            for(k in keys.keys()) {
                if(keys[k] != null) {
                    var key:FunkinSprite = keys[k].key;
                    key.offset.y = Math.sin((_timer * 2) + key.ID + (1 * 5)) * 5;
                }
            }
        }
    }

    if(fadeMusic && FlxG.sound.music != null) {
        FlxG.sound.music.volume = CoolUtil.fpsLerp(FlxG.sound.music.volume, 1, 0.04);
        fadeMusic = FlxG.sound.music.volume != 1;
    }
}

var windowFocus:Bool = true;
function onFocus() if (FlxG.autoPause) windowFocus = true;
function onFocusLost() if (FlxG.autoPause) windowFocus = false;

function onMouseMoved(?x:Float = 0, ?y:Float = 0) {
    if(windowFocus && !(canLerp || !weekSelected))
        return;
    zoomLevel = 1 + (Math.abs(Math.max(Math.min(425, FlxG.mouse.y), 385) - 425) * 0.0005); // you like my math? - higg
    for(key in weekList.keys()) {
        var spr = weekList[key].spr;
        if(spr.ID == 1 && FlxG.mouse.overlaps(spr)) {
            if(curWeek.sprite != spr) setCurWeek(key);
            return;
        }
    }
    if(curWeek.sprite != null) {
        curWeek.sprite?.playAnim("idle");
        curWeek.sprite = null;
    }
}

function setCurWeek(key) {
    curWeek.week = weekList[key].week;
    curWeek.weeks = weekList[key].weeks;
    curWeek.sprite?.playAnim("idle");
    curWeek.sprite = weekList[key].spr;
    curWeek.sprite?.playAnim("selected");
    FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
}

function exit() {
    fadeMusic = false;
    weekSelected = true;
    canLerp = false;
    if(curWeek.sprite != null)
        FlxTween.color(curWeek.sprite, 0.15, FlxColor.WHITE, colorLOCKED, {ease: FlxEase.sineOut});
    FlxTween.tween(weekList["dusttale"].spr, {zoomFactor: 0.65}, 0.15, {ease: FlxEase.sineInOut});
    CoolUtil.playMenuSFX(2, 0.7);
    FlxTween.tween(camera, {zoom: 1.2}, 0.77, {ease: FlxEase.sineIn});
    FlxTween.tween(camera.scroll, {y: -60}, 0.77, {ease: FlxEase.sineIn});
    FlxG.sound.music.fadeOut(0.75, 0);
    FlxG.camera.fade(FlxColor.BLACK, 0.8, false, () -> {
        MusicBeatState.skipTransOut = true;
        FlxG.switchState(new MainMenuState());
    }, true);
}

function select() {
    if(Options.gameplayShaders && FlxG.save.data.bloom) {
        bloom.size = 40;
        bloom.brightness = 5;
        bloom.directions = 8;
        bloom.quality = 10;
    }
    weekSelected = true;
    canLerp = false;

    FlxTween.cancelTweensOf(camera);

    FlxG.sound.play(Paths.sound("menu/select_freeplay"), 1);
    var week = curWeek.week;
    var locked = FunkinSave.getWeekHighscore(week.id, week.difficulties[0]).score <= 2 || FunkinSave.getSongHighscore(curWeek.weeks[0].songs[0].name, "hard").score == 0;
    if (locked) {
        FunkinSave.setWeekHighscore(week.id, 'hard', {
            score: 3,
            misses: 0,
            accuracy: 0,
            hits: [],
            date: ""
        });
        PlayState.loadWeek(week, week.difficulties[0]);
    }

    pillarFront.visible = pillarBack.visible = dustText.visible = false;
    for(spr in weekSprites)
        spr.visible = false;

    selectScreen.loadGraphic(Paths.image("menus/story/select_screens/" + getWeekName(week)));
    selectScreen.visible = true;

    if(Options.gameplayShaders && FlxG.save.data.bloom)
        FlxG.camera.addShader(bloom);

    if (Options.gameplayShaders && FlxG.save.data.impact) {
        camera.addShader(blackFlash);
        blackFlash.threshold = 0.2;
    } else {
        camera.visible = false;
        var bloomFlash:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.WHITE);

        bloomFlash.blend = 0;
        add(bloomFlash);

        new FlxTimer().start(0.05, function() {
            bloomFlash.color = weekList[getWeekName(week)].color;
            FlxTween.tween(bloomFlash, { alpha: 0 }, 0.5, { ease: FlxEase.quadInOut, onComplete: (_) -> {
                bloomFlash.destroy();
            }});
        });
    }

    var safeCam = new FlxCamera();
    safeCam.bgColor = FlxColor.BLACK;

    if(FlxG.save.data.antiFlash) {
        safeCam.alpha = 0.75;
        FlxG.cameras.add(safeCam, false);
    }

    var barHeight = FlxG.height / 2;

    whiteFlash = new FunkinSprite(0, 0).makeSolid(FlxG.width, FlxG.height, 0xFFFFFFFF);
    whiteFlash.alpha = 0;
    whiteFlash.scrollFactor.set();
    add(whiteFlash);

    barTop = new FunkinSprite(0, -barHeight).makeSolid(FlxG.width, barHeight, 0xFF000000);
    barTop.scrollFactor.set();
    add(barTop);

    barBottom = new FunkinSprite(0, FlxG.height).makeSolid(FlxG.width, barHeight, 0xFF000000);
    barBottom.scrollFactor.set();
    add(barBottom);

    var impactEnabled:Bool = Options.gameplayShaders && FlxG.save.data.impact;
    new FlxTimer().start(0.05, function() {

        camera.shake(0.005, 0.7);
        if(Options.gameplayShaders && FlxG.save.data.impact)
            blackFlash.threshold = 1;

        new FlxTimer().start(impactEnabled ? 0.2 : 0.1, function() {
            if (Options.gameplayShaders && FlxG.save.data.glitch) FlxG.camera.addShader(glitch);
            if(impactEnabled) FlxG.camera.removeShader(blackFlash);
            else camera.visible = true;
            

            if(FlxG.save.data.antiFlash) {
                FlxTween.num(0.75, 0, 2, {}, function(num) {
                    safeCam.alpha = num;
                });
            }

            FlxTween.num(2, 0, 2, {
                ease: FlxEase.quintOut,
                onComplete: () -> {
                    new FlxTimer().start(2.5, function() {
                        if (locked) {
                            weekPlaylist = curWeek.weeks;
                            weekPlaylist.shift();
                            weekDifficulty = curWeek.week.difficulties[0];
                            PlayState.isStoryMode = true;
                            curMusicID = "";
                            FlxG.switchState(new PlayState());
                        } else
                            FlxG.switchState(new ModState("ChapterSelectionMenu", curWeek.weeks));
                    });
                }
            }, function(num) {
                if(Options.gameplayShaders) {
                    if(FlxG.save.data.bloom) {
                        bloom.size = 20 * num;
                        bloom.brightness = 1 + (20 * num);
                    }

                    if(FlxG.save.data.glitch) {
                        glitch.AMT = 0.1 * num;
                        glitch.SPEED = 2 * num;
                    }
                }

                new FlxTimer().start(1.5, function() {
                    FlxTween.tween(barTop, { y: 0 }, 2, { ease: FlxEase.quadInOut });
                    FlxTween.tween(barBottom, { y: FlxG.height / 2 }, 1.5+.3, { ease: FlxEase.quadInOut });
                    FlxTween.tween(whiteFlash, { alpha: 1 }, 2, { ease: FlxEase.sineOut });

                    if(Options.gameplayShaders && FlxG.save.data.glitch) {
                        FlxTween.num(0, 1, 2, { ease: FlxEase.sineInOut }, function(n) {
                            glitch.AMT = 0.01 + 0.01 * n;
                            glitch.SPEED = 1 + 1 * n;
                        });
                    }
                });
            });

            shake(0.6, 0.85);
        });
    });

}

var speedizer:Float = 0;
var xoffset:Float = 0;
var yoffset:Float = 0;
var angleoffset:Float = 0;
static function shake(traumatizerr:Float = 0.3, speedizerr:Float = 0.02) {
    t = traumatizerr;
    speedizer = speedizerr;
    xoffset = FlxG.random.float(-100, 100);
    yoffset = FlxG.random.float(-100, 100);
    angleoffset = FlxG.random.float(-100, 100);
}

var t:Float = 0;
var peakAngle:Float = 0;
function updateShake(elapsed:Float) {
    t = FlxMath.bound(t - (speedizer * elapsed), 0, 1);
    FlxG.camera.angle += 4 * (t * t) * FlxSimplex.simplex(t * 25.5, t * 25.5 + angleoffset);
    FlxG.camera.scroll.x += 50 * (t * t) * FlxSimplex.simplex(t * 100 + xoffset, 10);
    FlxG.camera.scroll.y += 50 * (t * t) * FlxSimplex.simplex(10, t * 100 + yoffset);

    if (peakAngle < Math.abs(FlxG.camera.angle))
        peakAngle = Math.abs(FlxG.camera.angle);
}

function destroy() {
    if(FlxG.sound.music.volume != 1) {
        FlxG.sound.music.volume = 1;
        FlxG.sound.music.stop();
    }
    Lib.application.window.onMouseMove.remove(onMouseMoved);
}