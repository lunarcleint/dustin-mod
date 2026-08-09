//
import Lambda;
import String;
import StringTools;
import Type;
import flixel.util.FlxSave;
import funkin.savedata.FunkinSave;
import funkin.savedata.FunkinSave.HighscoreEntry;
import funkin.backend.week.Week;
import haxe.Unserializer;
import haxe.ds.StringMap;
import lime.system.System;
import openfl.net.SharedObject;
import funkin.menus.FreeplayState.FreeplaySonglist;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

import funkin.menus.StoryMenuState.StoryWeeklist;

using StringTools;

static var dustinShop:Map<String, Dynamic> = ["cds" => [], "keys" => [], "boughtAll" => false];

static function load_save() {
    // cuz only windows users had the old build accessible, if someone used a compatibility layer it was inside another path anyways, also this potentially crashes in mac, soo  - Nex
    #if windows
    migrate_save();
    #end
    FlxG.save.data.dustinBoughtStuff ??= [];
    FlxG.save.data.mechanics ??= true;
    FlxG.save.data.scrollSpeedChange ??= true;
    FlxG.save.data.nh ??= false;
    FlxG.save.data.dustinSeenUnlockAnims ??= [];
    FlxG.save.data.dustinCash ??= 0;
    FlxG.save.data.EggOne ??= false;
    FlxG.save.data.gSwag ??= true;
    FlxG.save.data.mWindow ??= true;
    FlxG.save.data.strumOverlay ??= 0;

    FlxG.save.data.antiFlash ??= false;

    FlxG.save.data.dustinMigratedV2 ??= false;

    load_shaders_data();

    /* TEMP
    FlxG.save.data.dustinPurchasedShopCDs?.remove("lorem-ipsum");
    FlxG.save.flush();
    var loremScores:Array<Dynamic> = [];
    for(entry in FunkinSave.highscores.keys()) {
        var params:Array<Dynamic> = Type.enumParameters(entry);
        if(Type.enumConstructor(entry) == "HSongEntry" && params[0] == "lorem-ipsum")
            loremScores.push(entry);
    }
    for(entry in loremScores)
        FunkinSave.highscores.remove(entry);
    FunkinSave.save.data.highscores = {};
    FunkinSave.flush();
    */

    load_shop_data();

    Options.devMode = false;

    // CAUSES ISSUES WITH MEMORY, STREAMED AUDIO IS BROKEN IN CNE <=v1.0.1
    final cneVersion = FlxG.stage.application.meta.get('version');
    if (Flags.CURRENT_API_VERSION < 2 || cneVersion == "1.0.1") {
        Options.streamedMusic = false;
        Options.streamedVocals = false;
    }

    // Chezz killed me
    Options.colorHealthBar = true;
}

static function load_shop_data() {
    //var shopData:Dynamic =
    var totalItems:Int;
    var jsonPath:String = Paths.json("gaster/shop/items");
    var boughtAll:Bool = true;
    var ignoreSongs:Array<String> = [];

    // Fail open when the shop catalogue changes or cannot be read. This prevents
    // an old "bought everything" result from hiding newly added items.
    dustinShop["boughtAll"] = false;

    for(week in Paths.getFolderContent("data/weeks/weeks", false, -1, true))
        for (song in Week.loadWeek(week, false).songs) ignoreSongs.push(song.name);

    if(Assets.exists(jsonPath)) {
        var raw = Assets.getText(jsonPath);
        try {
            raw = Json.parse(raw);

            // CD ownership used to be inferred from song scores. Migrate the old
            // catalogue once, excluding the newly introduced Null CD. From this
            // point onward, new catalogue entries are unowned until purchased.
            var purchasedCDs:Array<String> = FlxG.save.data.dustinPurchasedShopCDs;
            if(purchasedCDs == null) {
                purchasedCDs = [];
                for(cd in raw.cds) {
                    if(cd.song != "lorem-ipsum" && (FlxG.save.data.dustinBoughtStuff.contains(cd.song) || FunkinSave.getSongHighscore(cd.song, "hard").score > 0))
                        purchasedCDs.push(cd.song);
                }
                FlxG.save.data.dustinPurchasedShopCDs = purchasedCDs;
                FlxG.save.flush();
            }

            var weekProgression = [];
            var weeks:StoryWeeklist = StoryWeeklist.get();

            for (week in weeks.weeks) {
                if (weekProgression.contains(week.id.split("-")[0]))
                    continue;
                //trace(week.songs[0].name);
                if (FunkinSave.getSongHighscore(week.songs[0].name, "hard").score > 0) {
                    //trace('yeah I played ' + week.id.split("-")[0]);
                    weekProgression.push(week.id.split("-")[0]);
                }// else trace('I did not fucking play ' + week.id.split("-")[0]);
            }

            for(key in raw.keys) {
                var weekName:String = switch(key.week) {
                    case 'dustswap':
                        'mirror';
                    case 'dustfell':
                        'wrath';
                    case 'dustbelief':
                        'guilty';
                    case 'dustshift':
                        'virus';
                }
                var bought:Bool = FlxG.save.data.dustinBoughtStuff.contains(weekName + ' key') || FunkinSave.getWeekHighscore(key.week + "-1", "hard").score > 0 || weekProgression.contains(key.week);
                
                if(bought || FlxG.save.data.dustinBoughtStuff.contains(weekName + ' key') || weekProgression.contains(key.week)) {
                    FunkinSave.setWeekHighscore(key.week + '-1', 'hard', {
                        score: (FunkinSave.getWeekHighscore(key.week + "-1", "hard").data != null) ? 1 : 3,
                        misses: 0,
                        accuracy: 0,
                        hits: [],
                        date: ""
                    });
                    //trace(key.week + 'unlocked');
                }/* else {
                    trace(key.week + ' not unlocked');
                }*/
                dustinShop["keys"][key.week] = bought;
                // checking dusttale save data...
                if(!bought)
                    boughtAll = false;
            }
            for (i => song in FreeplaySonglist.get().songs) {
                if (ignoreSongs.contains(song.name)) {
                    if (FlxG.save.data.dustinBoughtStuff.contains(song.name) && FunkinSave.getSongHighscore(song.name, "hard").score == 0) {
                        FunkinSave.setSongHighscore(song.name, 'hard', null, {
                            score: 1,
                            misses: 0,
                            accuracy: 0,
                            hits: [],
                            date: ""
                        }, []);
                    }
                    continue;
                }
                var bought:Bool = purchasedCDs.contains(song.name);
                dustinShop["cds"][song.name] = bought;
            }

            // Use the current shop catalogue as the source of truth. If an update
            // adds a CD that is not present in the player's save, reopen the shop.
            for(cd in raw.cds) {
                var bought:Bool = purchasedCDs.contains(cd.song);
                dustinShop["cds"][cd.song] = bought;
                if(!bought)
                    boughtAll = false;
            }
            dustinShop["boughtAll"] = boughtAll;
            //trace(boughtAll);
        } catch (e:Dynamic) {trace('INVALID JSON PARSING : ' + e);}
    }
}

static function migrate_save() {
    if (!FlxG.save.data.dustinMigratedV2 || FlxG.save.data.dustinMigratedV2 == null) {
        trace("No Dustin' V2 PATCH save data found, checking for Dustin' V1 save data...");
        var save2:FlxSave = new FlxSave();
        save2.bind("dustin", "ChezzarCat");

        var oldSave:FlxSave = new FlxSave();
        oldSave.bind("dustin", "Chezzar");
        if (oldSave.isEmpty())
             oldSave.bind("dustin", "ChezzarCat");
        else if (save2.data.dustinCash != null) {
            oldSave.data.dustinCash = save2.data.dustinCash;
        }

        if (!oldSave.isEmpty()) {
            trace("Dustin' V1 save data found, migrating...");

            // resetting the shaders cuz theres a whole new menu for that now  - Nex
            oldSave.data.bloom = null;
            oldSave.data.particles = null;
            oldSave.data.godrays = null;
            oldSave.data.distortion = null;
            FlxG.save.mergeData(oldSave.data, true);

            // silly solutions for backwards compat -lunar
            // save data array for v1 and the hotfix done after
            var encodedDatas:Array<Dynamic> = [];

            var stoageDirect = StringTools.replace(System.applicationStorageDirectory, "Yoshman29\\dustin\\", "");
            stoageDirect = StringTools.replace(stoageDirect, "Chezzar\\dustin\\", "");

            var legacySavePath:String = stoageDirect + "YoshiCrafter29/CodenameEngine" + "\\" + "save-default" + ".sol";
            var hotfixSavePath:String = stoageDirect + "ChezzarCat" + "\\" + "save-default" + ".sol";
            // sorry, I like my spacing in tracing - hig
            trace("");
            for (path in [legacySavePath, hotfixSavePath]) {
                path = StringTools.replace(path, "//", "/");
                path = StringTools.replace(path, "\\", "/");
                trace("Searching " + path + " for high scores...");
                if(FileSystem.exists(path)) {
                    trace("Data found!\n");
                    encodedDatas.push(File.getContent(path));
                }
            }

            for (encodedData in encodedDatas) {
                trace("CHECKING NEW DATA...\n\n\n");
                var rawData:Dynamic = null;
                if (encodedData != null) {
                    try {
                        buf = encodedData;
                        length = buf.length;
                        pos = 0;

                        scache = [];
                        cache = [];

                        resolver = {resolveEnum: Type.resolveEnum, resolveClass: SharedObject.__resolveClass};
                        rawData = unserialize();
                    } catch (e:Dynamic) {trace(e);}
                }

                var fieldMap;
                if (Type.typeof(rawData.highscores) == "TObject") {
                    for(field in Reflect.fields(rawData.highscores)) {
                        var songEntry = FunkinSave.__getHighscoreEntry(field);
                        var songName:String = "";
                        // can't be bothered rn
                        try {
                            data = field;
                            buf = data;
                            length = buf.length;
                            pos = 0;

                            scache = [];
                            cache = [];

                            resolver = {resolveEnum: Type.resolveEnum, resolveClass: SharedObject.__resolveClass};
                            data = unserialize();
                            songName = data.song;
                        } catch (e:Dynamic) {trace(e);}

                        try {
                            if (songEntry != null) {
                                if (fieldMap == null) {
                                    fieldMap = ["_______ not a song please don't name it this" => null]; // so we can recognize it as a map
                                }
                                fieldMap[songName] = Reflect.field(rawData.highscores, field);
                            }

                        } catch (e:Dynamic) {trace(e);}
                    }
                }

                if (fieldMap != null)
                    rawData.highscores = fieldMap;

                if (rawData != null && Lambda.count(rawData.highscores) > 0) {
                    trace("HIGH SCORES FOUND!!!");
                    update_dustin_scores(FunkinSave.highscores, rawData.highscores);
                }
            }

            if (encodedDatas.length != 0)
                FlxG.save.flush();
        } else {
            trace("No Dustin' V1 save data found.");
            oldSave.close();
        }
    }
}

static final dih = ["bloom", "particles", "godrays", "glitch", "fog", "water", "chromwarp", "warp", "fire", "static", "pixel", "saturation", "impact"];

static function load_shaders_data() {
    for (penis in dih)
        if (Reflect.field(FlxG.save.data, penis) == null)
            Reflect.setField(FlxG.save.data, penis, true);
    if (FlxG.save.data.strumOverlay == null)
        FlxG.save.data.strumOverlay = 0;
}

static function set_shaders_high() {
    Options.gameplayShaders = true;
    for (penis in dih) Reflect.setField(FlxG.save.data, penis, true);
}

static function set_shaders_low() {
    Options.gameplayShaders = false;
    for (penis in dih) Reflect.setField(FlxG.save.data, penis, false);
}
static function update_dustin_scores(newData, legacyData) {
    var songsList:Array<String> = [for (song in Paths.getFolderDirectories('songs', false, 1)) song.toLowerCase()];
    if (newData != null) {
        for (song in songsList) {
            var songData = FunkinSave.getSongHighscore(song, "hard");
            if (songData == null) {     // new data doesn't hard a score, so the old one will fully replace
                songData = soft_getSongHighscore(legacyData, song, "hard");
                if (songData?.score != null) {
                    trace(song, songData.score);
                    FunkinSave.setSongHighscore(song, "hard", null, songData, true);
                }
            } else {                    // comparing which score is higher
                var oldSongData = soft_getSongHighscore(legacyData, song, "hard");
                if (oldSongData != null && oldSongData.score > songData.score) {
                    FunkinSave.setSongHighscore(song, "hard", null, oldSongData, true);
                }
            }
            FunkinSave.flush();
        }
    } else {
        trace("There is nothing new to our current data, so the previous save is a complete replacement.");
        if (Type.typeof(data) != "TClass(haxe.ds.StringMap)") {
            FunkinSave.highscores = legacyData;
            FunkinSave.flush();
        }
    }

    for (song in FunkinSave.highscores.keys()) {
		var enumParams:Array<Dynamic> = Type.enumParameters(song);
        if (songsList.contains((enumParams[0])) && !FlxG.save.data.dustinBoughtStuff.contains((enumParams[0]))) 
            FlxG.save.data.dustinBoughtStuff.push(enumParams[0]);
	}
}

// support for softcoded maps

function soft_getSongEntry(name:String, diff:String, ?variation:String, ?changes:Array<HighscoreChange>):HighscoreEntry
		return HighscoreEntry.HSongEntry(name.toLowerCase(), diff.toLowerCase(), variation, changes);

function soft_safeGetHighscore(data, entry:HighscoreEntry) {
    if (Type.typeof(data) == "TClass(haxe.ds.StringMap)") { // this is a soft-coded map
        if (data[entry] == null) {
            return {
                score: 0,
                accuracy: 0,
                misses: 0,
                hits: [],
                date: null
            };
        }
    } else {
        if (!data.exists(entry)) {
            return {
                score: 0,
                accuracy: 0,
                misses: 0,
                hits: [],
                date: null
            };
        }
    }

    return Type.typeof(data) == "TClass(haxe.ds.StringMap)" ? data[entry] : data.get(entry);
}

function soft_getSongHighscore(data, name:String, diff:String, ?variation:String, ?changes:Array<HighscoreChange>) {
    if (changes == null) changes = [];
    if (Type.typeof(data) == "TClass(haxe.ds.StringMap)")
        return data[name];

    return soft_safeGetHighscore(data, soft_getSongEntry(name, diff, variation, changes));
}

static var FULL_VOLUME:Bool = false;

static var weekPlaylist:Array<Dynamic> = [];
static var weekDifficulty:String = "";

#if windows
// REIMPLEMENTED SERIALIZER 
function get(p:Int):Int {
    return StringTools.fastCodeAt(buf, p);
}

function readDigits() {
    var k = 0;
    var s = false;
    var fpos = pos;
    while (true) {
        var c = get(pos);
        if (StringTools.isEof(c))
            break;
        if (c == 45) {
            if (pos != fpos)
                break;
            s = true;
            pos++;
            continue;
        }
        if (c < 48 || c > 57)
            break;
        k = k * 10 + (c - 48);
        pos++;
    }
    if (s)
        k *= -1;
    return k;
}

function readFloat() {
    var p1 = pos;
    while (true) {
        var c = get(pos);
        if (StringTools.isEof(c))
            break;
        // + - . , 0-9
        if ((c >= 43 && c < 58) || c == 101 || c == 69)
            pos++;
        else
            break;
    }
    return Std.parseFloat(fastSubstr(buf, p1, pos - p1));
}

function unserializeObject(o:{}) {
    while (true) {
        if (pos >= length)
            throw "Invalid object";
        if (get(pos) == 103)
            break;
        var k:Dynamic = unserialize();
        if (!Std.isOfType(k, String))
            throw "Invalid object key";
        var v = unserialize();
        Reflect.setField(o, k, v);
    }
    pos++;
}

function unserializeEnum(edecl:Enum, tag:String) {
    if (get(pos++) != 58)
        throw "Invalid enum format";
    var nargs = readDigits();
    if (nargs == 0)
        return Type.createEnum(edecl, tag);
    var args = [];
    while (nargs-- > 0)
        args.push(unserialize());
    // !! ADDED FOR DUSTIN
    if (edecl == "funkin.savedata.HighscoreEntry" && tag == "HSongEntry" && args.length <= 3) {
        args.insert(2, null);
    }
    return Type.createEnum(edecl, tag, args);
}

var buf:String;
var pos:Int;
var length:Int;
var cache:Array<Dynamic>;
var scache:Array<String>;
var resolver:TypeResolver;
function unserialize():Dynamic {
    switch (get(pos++)) {
        case 110:
            return null;
        case 116:
            return true;
        case 102:
            return false;
        case 122:
            return 0;
        case 105:
            return readDigits();
        case 100:
            return readFloat();
        case 121:
            var len = readDigits();
            if (get(pos++) != 58 || length - pos < len)
                throw "Invalid string length";
            var s = fastSubstr(buf, pos, len);
            pos += len;
            s = StringTools.urlDecode(s);
            scache.push(s);
            return s;
        case 107:
            return Math.NaN;
        case 109:
            return Math.NEGATIVE_INFINITY;
        case 112:
            return Math.POSITIVE_INFINITY;
        case 97:
            var buf = buf;
            var a = [];
            cache.push(a);
            while (true) {
                var c = get(pos);
                if (c == 104) {
                    pos++;
                    break;
                }
                if (c == 117) {
                    pos++;
                    var n = readDigits();
                    a[a.length + n - 1] = null;
                } else
                    a.push(unserialize());
            }
            return a;
        case 111:
            var o = {};
            cache.push(o);
            unserializeObject(o);
            return o;
        case 114:
            var n = readDigits();
            if (n < 0 || n >= cache.length)
                throw "Invalid reference";
            return cache[n];
        case 82:
            var n = readDigits();
            if (n < 0 || n >= scache.length)
                throw "Invalid string reference";
            return scache[n];
        case 120:
            throw unserialize();
        case 99:
            var name = unserialize();
            var cl = resolver.resolveClass(name);
            if (cl == null)
                throw "Class not found " + name;
            var o = Type.createEmptyInstance(cl);
            cache.push(o);
            unserializeObject(o);
            return o;
        case 119:
            var name = unserialize();
            var edecl = resolver.resolveEnum(name);
            if (edecl == null)
                throw "Enum not found " + name;
            var e = unserializeEnum(edecl, unserialize());
            cache.push(e);
            return e;
        case 106:
            var name = unserialize();
            var edecl = resolver.resolveEnum(name);
            if (edecl == null)
                throw "Enum not found " + name;
            pos++; /* skip ':' */
            var index = readDigits();
            var tag = Type.getEnumConstructs(edecl)[index];
            if (tag == null)
                throw "Unknown enum index " + name + "@" + index;
            var e = unserializeEnum(edecl, tag);
            cache.push(e);
            return e;
        case 108:
            var l = new List();
            cache.push(l);
            var buf = buf;
            while (get(pos) != 104)
                l.add(unserialize());
            pos++;
            return l;
        case 98:
            var h = new StringMap();
            cache.push(h);
            var buf = buf;
            while (get(pos) != 104) {
                var s = unserialize();
                h.set(s, unserialize());
            }
            pos++;
            return h;
        case 113:
            var h = new haxe.ds.IntMap();
            cache.push(h);
            var buf = buf;
            var c = get(pos++);
            while (c == 58) {
                var i = readDigits();
                h.set(i, unserialize());
                c = get(pos++);
            }
            if (c != 104)
                throw "Invalid IntMap format";
            return h;
        case 77:
            var h = new haxe.ds.ObjectMap();
            cache.push(h);
            var buf = buf;
            while (get(pos) != 104) {
                var s = unserialize();
                h.set(s, unserialize());
            }
            pos++;
            return h;
        case 118:
            var d;
            if (get(pos) >= 48 && get(pos) <= 57 && get(pos + 1) >= 48 && get(pos + 1) <= 57 && get(pos + 2) >= 48
                && get(pos + 2) <= 57 && get(pos + 3) >= 48 && get(pos + 3) <= 57 && get(pos + 4) == 45) {
                // Included for backwards compatibility
                d = Date.fromString(fastSubstr(buf, pos, 19));
                pos += 19;
            } else
                d = Date.fromTime(readFloat());
            cache.push(d);
            return d;
        case 115:
            var len = readDigits();
            var buf = buf;
            if (get(pos++) != 58 || length - pos < len)
                throw "Invalid bytes length";
            var codes = Unserializer.CODES;
            if (codes == null) {
                codes = Unserializer.initCodes();
                Unserializer.CODES = codes;
            }
            var i = pos;
            var rest = len & 3;
            var size = (len >> 2) * 3 + ((rest >= 2) ? rest - 1 : 0);
            var max = i + (len - rest);
            var bytes = haxe.io.Bytes.alloc(size);
            var bpos = 0;
            while (i < max) {
                var c1 = codes[StringTools.fastCodeAt(buf, i++)];
                var c2 = codes[StringTools.fastCodeAt(buf, i++)];
                bytes.set(bpos++, (c1 << 2) | (c2 >> 4));
                var c3 = codes[StringTools.fastCodeAt(buf, i++)];
                bytes.set(bpos++, (c2 << 4) | (c3 >> 2));
                var c4 = codes[StringTools.fastCodeAt(buf, i++)];
                bytes.set(bpos++, (c3 << 6) | c4);
            }
            if (rest >= 2) {
                var c1 = codes[StringTools.fastCodeAt(buf, i++)];
                var c2 = codes[StringTools.fastCodeAt(buf, i++)];
                bytes.set(bpos++, (c1 << 2) | (c2 >> 4));
                if (rest == 3) {
                    var c3 = codes[StringTools.fastCodeAt(buf, i++)];
                    bytes.set(bpos++, (c2 << 4) | (c3 >> 2));
                }
            }
            pos += len;
            cache.push(bytes);
            return bytes;
        case 67:
            var name = unserialize();
            var cl = resolver.resolveClass(name);
            if (cl == null)
                throw "Class not found " + name;
            var o:Dynamic = Type.createEmptyInstance(cl);
            cache.push(o);
            o.hxUnserialize(this);
            if (get(pos++) != 103)
                throw "Invalid custom data";
            return o;
        case 65:
            var name = unserialize();
            var cl = resolver.resolveClass(name);
            if (cl == null)
                throw "Class not found " + name;
            return cl;
        case 66:
            var name = unserialize();
            var e = resolver.resolveEnum(name);
            if (e == null)
                throw "Enum not found " + name;
            return e;
        default:
    }
    pos--;
    throw "Invalid char " + fastCharAt(buf, pos) + " at position " + pos;
}

#if neko
static var base_decode = neko.Lib.load("std", "base_decode", 2);
#end

function fastLength(s:String):Int {
    #if php
    return php.Global.strlen(s);
    #else
    return s.length;
    #end
}

function fastCharCodeAt(s:String, pos:Int):Int {
    #if php
    return php.Global.ord((s:php.NativeString)[pos]);
    #else
    return s.charCodeAt(pos);
    #end
}

function fastCharAt(s:String, pos:Int):String {
    #if php
    return (s:php.NativeString)[pos];
    #else
    return s.charAt(pos);
    #end
}

function fastSubstr(s:String, pos:Int, length:Int):String {
    #if php
    return php.Global.substr(s, pos, length);
    #else
    return s.substr(pos, length);
    #end
}
#end
