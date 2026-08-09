//
import haxe.io.Path;
import sys.FileSystem;
// ! DO NOT FUCK WITH THIS SCRIPT AS IT INSURES THE SCRIPTS CAN INTERACT WITH EACHOTHER PROPERLY -lunar
// ! Also its named z_ with the start so it can be rand last by the 

var folderPath = Paths.getAssetsRoot() + "/songs/" + PlayState.SONG.meta.name + "/scripts/";
if(FileSystem.isDirectory(folderPath)) {
    for(path in FileSystem.readDirectory(folderPath)) {
        var variant:String = (PlayState.variation == null ? "Vanilla" : PlayState.variation).toLowerCase();
        if(StringTools.startsWith(path, "variant-") && StringTools.contains(path, variant)) {
            for (file in Paths.getFolderContent("songs/" + PlayState.SONG.meta.name + "/scripts/" + path, true, PlayState.fromMods ? 1 : -1)) {
                addScript(file);
            }
        }
    }
}

var oldScripts:Array<Script> = PlayState.instance.scripts.scripts;
PlayState.instance.scripts.scripts = [];

var debug_Scripts:Array<Script> = [];
var event_Scripts:Array<Script> = [];
var util_Scripts:Array<Script> = [];
var ui_Scripts:Array<Script> = [];
var stage_Scripts:Array<Script> = [];
var story_Scripts:Array<Script> = [];
var modchart_Scripts:Array<Script> = [];
var note_Scripts:Array<Script> = [];
var song_Scripts:Array<Script> = [];
var other_Scripts:Array<Script> = [];

// ! SORTS SCRIPTS INTO DA ARRAYS ABOVE
for (script in oldScripts) {
    if (script.fileName == "z_script_orderer.hx") continue;

    switch (Path.directory(script.path)) {
        case "assets/data/stages": stage_Scripts.push(script);
        case "assets/data/events": event_Scripts.push(script);
        case "assets/data/notes": note_Scripts.push(script);
        case "songs/" + PlayState.SONG.meta.name + "/scripts":
            if (StringTools.startsWith(script.fileName, "modchart_")) modchart_Scripts.push(script);
            else song_Scripts.push(script);
        case "songs":
            if (StringTools.startsWith(script.fileName, "debug_")) debug_Scripts.push(script);
            else if (StringTools.startsWith(script.fileName, "util_")) util_Scripts.push(script);
            else if (StringTools.startsWith(script.fileName, "ui_")) ui_Scripts.push(script);
            else if (StringTools.startsWith(script.fileName, "stage_")) stage_Scripts.push(script);
            else if (StringTools.startsWith(script.fileName, "story_")) story_Scripts.push(script);
            else other_Scripts.push(script);
        default: other_Scripts.push(script);
    }
}

var finalScripts:Array<Script> = [];
for (g_scripts in [debug_Scripts, event_Scripts, util_Scripts, ui_Scripts, stage_Scripts, modchart_Scripts, note_Scripts, song_Scripts, story_Scripts, other_Scripts])
    for (script in g_scripts) finalScripts.push(script);
// for (script in finalScripts) trace(script.fileName);
PlayState.instance.scripts.scripts = finalScripts;

// destroy scripts
__script__.didLoad = __script__.active = false;