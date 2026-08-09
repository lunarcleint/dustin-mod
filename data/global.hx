//


import funkin.backend.assets.ModsFolder;
import funkin.backend.scripting.GlobalScript;
import funkin.backend.system.Logs;
import funkin.backend.MusicBeatState;

import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.NativeAPI;
import funkin.backend.utils.WindowUtils;
import lime.graphics.Image;
import hxvlc.util.Handle;
import haxe.io.Path;

import Type;
import Sys;

// Compatibility stuff for versions that doesnt have Flags for some reason??
// i genuinely thought it exists in every versions
try {
    import funkin.backend.system.Flags;
    static var Flags = Flags;
}
catch (e:Any) {
    static var Flags = {CURRENT_API_VERSION: 1};
}

for (dih in Paths.getFolderContent("data/global/", true, -1, true)) importScript(dih);

// Un-comment this when we're done debugging,
// seriously the text became uncomprehensible with this font.
Framerate.fontName = Paths.getFontName(Paths.font("DTM-Mono.ttf"));

function new() {
    Handle.init([]);

    if (!Assets.exists(Paths.image('DO_NOT_DELETE', null, false, 'jpg'))) {
        NativeAPI.showMessageBox('WHY', 'HOW DRE YOU!! >:((');
        Sys.exit(0);
    }
    load_save();

    FlxG.signals.preStateCreate.add(initializeFramerate);

    // WindowUtils.winTitle = window.title = "Friday Night Dustin'";
    #if !CUSTOM_BUILD
    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image('window/icon'))));
    #end
}

function initializeFramerate(state) {
    //Disable antialiasing on the fps text
    var formatText:Array<String> = [
        ["fpsCounter", "fpsNum"],
        ["fpsCounter", "fpsLabel"],
        ["memoryCounter", "memoryText"],
        ["memoryCounter", "memoryPeakText"],
    ];

    Framerate.codenameBuildField.text = Flags.VERSION_MESSAGE;
    if (Options.devMode) Framerate.codenameBuildField.text += ' (Debug Mode)';

    #if !CUSTOM_BUILD
    Framerate.codenameBuildField.text += '\nCodename Engine v' + Flags.VERSION;

    #if TEST_BUILD
    Framerate.codenameBuildField.text += ' (Test Build)';
    #elseif COMPILE_EXPERIMENTAL
    Framerate.codenameBuildField.text += ' (Experimental Build)';
    #end

    #if (debug || COMPILE_EXPERIMENTAL)
    Framerate.codenameBuildField.text += '\n' + Flags.COMMIT_MESSAGE;
    #end
    #end

    // This too.
    //Framerate.codenameBuildField.antiAliasType = 0;
    //Framerate.codenameBuildField.sharpness = 400;
    //for(textFields in Framerate.instance.categories) {
    //    for(field in [textFields.title, textFields.text]) {
    //        field.antiAliasType = 0;
    //        field.sharpness = 400/*MAX ON OPENFL*/;
    //    }
    //}

    FlxG.signals.preStateCreate.remove(initializeFramerate);
}

function preStateCreate() {
	FlxG.game.setFilters([]);
    forceUpdate = [];
}

function onScriptCreated(script:Script, type:String) {
    if (!Options.devMode) return;
    Logs.traceColored([
        Logs.logText('SCRIPT CREATED: ', 9),
        Logs.logText(type + ", " + script.path)
    ]);
}
