//
import sys.FileSystem;
import funkin.options.type.TextOption;
import funkin.options.type.Checkbox;
import funkin.options.type.NumOption;
import funkin.options.keybinds.KeybindsOptions;
import funkin.options.TreeMenuScreen;
import funkin.savedata.FunkinSave;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

using StringTools;

var menuLength:Int = -1;

var previewSprite:FunkinSprite = new FunkinSprite();
var previewSpriteOverlay:FunkinSprite = new FunkinSprite();
var overlay:Float = FlxG.save.data.strumOverlay;

function create() {
    forceUpdate.push(globalUpdate);
}

var descText:String = "";

function postCreate() {
    playMusic("mainMenu", 1);
    
    bg.visible = false;

    titleLabel.font = Paths.font("8bit-jve.ttf");
    descLabel.font = Paths.font("8bit-jve.ttf");

    titleLabel.size = 48;
    descLabel.size = 32;

    titleLabel.x += 10;
    descLabel.x += 10;

    for(txt in [titleLabel, descLabel])
        textCrispy(txt);

    for(spr in [previewSprite, previewSpriteOverlay]) {
        add(spr);
        spr.alpha = 0;
        spr.setPosition(FlxG.width + 75, FlxG.height * .5 + 135);
        spr.antialiasing = Options.antialiasing;
        spr.scale.set(0.5,0.5);
        spr.scrollFactor.set();
    }

    previewSprite.ID = 1;
    previewSprite.alpha = 0;
    previewSprite.loadGraphic(Paths.image("menus/options/preview-no-overlay"));
    previewSpriteOverlay.loadGraphic(Paths.image("menus/options/preview-overlay"));
    previewSpriteOverlay.onDraw = (spr) -> {
        spr.alpha = previewSprite.alpha * FlxG.save.data.strumOverlay / 100;
        spr.draw();
    }

    for(spr in [previewSprite, previewSpriteOverlay]) {
        spr.updateHitbox();
        spr.x -= spr.width * 1.15;
        spr.y -= spr.height * .5;
    }
}

function update(elapsed:Float) {
    if (previewSprite.ID == 0)
        previewSprite.alpha += elapsed * 5;
    else
        previewSprite.alpha -= elapsed * 10;

    if(menuLength != treeLength) {
        menuLength = treeLength;
        for (menu in tree) {
            if (menu.health != -1) {
                menu.health = -1;
                switch (menu.rawName) {
                    case "optionsTree.gameplay-name":
                        menu.members.remove(menu.members[2]); // remove naughtyness

                        final cneVersion = FlxG.stage.application.meta.get('version');
                        if (Flags.CURRENT_API_VERSION < 2 || cneVersion == "1.0.1") {
                            menu.members.remove(menu.members[8]); // remove stream vocals due to issues with memory
                        }

                        var noHitCheckbox:Checkbox = null;
                        var mechanicsHitCheckbox:Checkbox = null;
                        var scrollSpeedChangeCheckbox:Checkbox = null;

                        menu.insert(1, noHitCheckbox = new Checkbox("No Hit Mode", "Don't miss a note or you lose!!! Effects exp gained after songs (#1X Multipler# -> _2X Multipler_).", "nh", null, FlxG.save.data));
                        menu.insert(1, scrollSpeedChangeCheckbox = new Checkbox("Scroll Speed Changes", "Enable/Disable any scroll speed changes midsong.", "scrollSpeedChange", null, FlxG.save.data));
                        menu.insert(1, mechanicsHitCheckbox = new Checkbox("Mechanics", "Enable/Disable Gameplay Mechanics, effects exp gained after songs (#1X Multipler# -> *.5X Multipler*).", "mechanics", null, FlxG.save.data));

                        for (i => checkBox in [mechanicsHitCheckbox, scrollSpeedChangeCheckbox, noHitCheckbox])
                            checkBox.members[0].color = FlxColor.interpolate(0xFF8CDBFF, 0xFFC9FEFF, i/3);

                    case "optionsTree.appearance-name":
                        menu.insert(1, new NumOption("Strum Overlay", "Change the opacity of the black overlay behind your strumline.", 0, 100, 5, "strumOverlay", null, FlxG.save.data));
                        // It isn't ready yet, sorry
                        //menu.insert(1, new Checkbox("Photo-Sensitive Mode", "Check this if you are sensitive to flashing lights.", "antiFlash", null, FlxG.save.data));

                        for (i in 2...4) menu.members.remove(menu.members[i]);
                        menu.members.remove(menu.members[2]);
                        //menu.members[4].suffix = "/Shaders >";
                    case "optionsMenu.advanced":

                        var shaderOption = menu.members[3];
                        menu.members.remove(shaderOption);
                        menu.members.insert(4, shaderOption);

                        menu.members.remove(menu.members[2]); // remove low memory mode
                        
                        shaderOption.selectCallback = () -> {
                            menu.members[4].locked = !shaderOption.checked;
                        };

                        menu.add(new TextOption("Specific Shaders ", "Change more advanced Shader options.", ">", () -> {
                            var spefShadersTree:TreeMenuScreen = new TreeMenuScreen("Specific Shaders", "Change more advanced Shader options (HIGH END being shaders that lag the most, MEDIUM being shaders that kinda lag, and LOW END being shaders that don't cause issues on most systems).");
                            var highEndText:TextOption = null;
                            spefShadersTree.add(highEndText = new TextOption("High End Shaders ", "", ">", () -> {
                                var intShadersTree:TreeMenuScreen = new TreeMenuScreen("Intensive Shaders", "Change INTENSIVE Shader options (Hardest to run -> easiest to run, top to bottom).");
                                intShadersTree.add(new Checkbox("Bloom Effects", "Enable/Disable Bloom Shaders.", "bloom", null, FlxG.save.data));
                                intShadersTree.add(new Checkbox("God Rays Shaders", "Enable/Disable God Rays Shaders.", "godrays", null, FlxG.save.data));
                                intShadersTree.add(new Checkbox("Particles Shaders", "Enable/Disable Particles Shaders.", "particles", null, FlxG.save.data));
                                intShadersTree.add(new Checkbox("Glitch Shaders", "Enable/Disable Glitch Shaders.", "glitch", null, FlxG.save.data));
                                spefShadersTree.parent.addMenu(intShadersTree);

                                for (i => member in intShadersTree.members)
                                    member.members[0].color = FlxColor.interpolate(0xFFFE2323, 0xFFFFE3E3, i/intShadersTree.members.length);
                            }));
                            highEndText.color = 0xFFFFACAC;
                            var medEndText:TextOption = null;
                            spefShadersTree.add(medEndText = new TextOption("Medium Shaders ", "", ">", () -> {
                                var medShadersTree:TreeMenuScreen = new TreeMenuScreen("Medium Shaders", "Change MEDIUM Shader options (Hardest to run -> easiest to run, top to bottom).");
                                medShadersTree.add(new Checkbox("Fog Shaders", "Enable/Disable Fog Shaders.", "fog", null, FlxG.save.data));
                                medShadersTree.add(new Checkbox("Water Shaders", "Enable/Disable Water Shaders.", "water", null, FlxG.save.data));
                                medShadersTree.add(new Checkbox("Chromatic Shaders", "Enable/Disable Chromatic Shaders.", "chromwarp", null, FlxG.save.data));
                                medShadersTree.add(new Checkbox("Warp Shaders", "Enable/Disable Warp Shaders.", "warp", null, FlxG.save.data));
                                medShadersTree.add(new Checkbox("Fire Shaders", "Enable/Disable Fire Shaders.", "fire", null, FlxG.save.data));
                                spefShadersTree.parent.addMenu(medShadersTree);

                                for (i => member in medShadersTree.members)
                                    member.members[0].color = FlxColor.interpolate(0xFFFFF97D, 0xFFFFFFFF, i/medShadersTree.members.length);
                            }));
                            medEndText.color = 0xFFFFF5AC;
                            var lowEndText:TextOption = null;
                            spefShadersTree.add(lowEndText = new TextOption("Low End Shaders ", "", ">", () -> {
                                var lowShadersTree:TreeMenuScreen = new TreeMenuScreen("Low Shaders", "Change LOW Shader options (Hardest to run -> easiest to run, top to bottom).");
                                lowShadersTree.add(new Checkbox("Static Shaders", "Enable/Disable Static Shaders.", "static", null, FlxG.save.data));
                                lowShadersTree.add(new Checkbox("Pixel Shaders", "Enable/Disable Pixel Shaders.", "pixel", null, FlxG.save.data));
                                lowShadersTree.add(new Checkbox("Saturation Shaders", "Enable/Disable Saturation Shaders.", "saturation", null, FlxG.save.data));
                                lowShadersTree.add(new Checkbox("Impact Shaders", "Enable/Disable Impact Shaders.", "impact", null, FlxG.save.data));
                                spefShadersTree.parent.addMenu(lowShadersTree);
                                
                                for (i => member in lowShadersTree.members)
                                    member.members[0].color = FlxColor.interpolate(0xFF88FF5D, 0xFFFFFFFF, i/lowShadersTree.members.length);
                            }));
                            lowEndText.color = 0xFFC2FFAC;
                            menu.parent.addMenu(spefShadersTree);
                        }));

                        menu.members[0].changedCallback(Std.string(Options.quality));
                        shaderOption.selectCallback();

                    case "optionsTree.miscellaneous-name":
                        for (member in 1...5) // get rid of some cne stuff that will mess with the build
                            menu.members.remove(menu.members[1]);

                        #if desktop
                        menu.add(new Checkbox("Genocides Swag", "Uncheck this if you cannot play Genocides. You'll loose a VERY swag surprise....", "gSwag", null, FlxG.save.data));
                        #end

                        if (!FileSystem.exists("dev.txt")) menu.members.shift();

                        for (member in menu.members)
                            if (member.rawText == "MiscOptions.resetSaveData-name") {
                                member.selectCallback = () -> {
                                    persistentUpdate = false;
                                    openSubState(new ModSubState("options/ResetWarningSubState"));
                                }
                            }
                }
                for(member in menu.members) {
                    if(member.__text != null) {
                        var txt = textCrispy(new FunkinText(0, 0, 0, member.__text.text, 24, false));
                        txt.setFormat(Paths.font("8bit-jve.ttf"), 68, member.__text.color, 'left');

                        if(member.checkbox != null) {
                            member.checkbox.x = member.__text.x + txt.width + 20;
                            member.checkbox.y -= txt.height * .25;
                        }

                        if(member.__number != null) {
                            member.__number.visible = false;
                            var numTxt = textCrispy(new FunkinText(txt.width + 15, 0, 0, member.__number.text, 24, false));
                            numTxt.setFormat(Paths.font("8bit-jve.ttf"), 68, member.__text.color, 'left');
                            if (member.text == "Strum Overlay") {
                                txt.onDraw = (spr) -> {
                                    previewSprite.ID = previewSpriteOverlay.ID = (member.alpha == 1 ? 0 : 1);
                                    txt.draw();
                                }
                            }
                            member.changedCallback = (num) -> {
                                numTxt.text = ": " + num;
                            }
                            member.add(numTxt);
                        }

                        if(member.slider != null) {
                            member.slider.x = member.__text.x + txt.width;
                            //member.slider.y -= txt.height * .25;
                        }

                        if(member.__selectionText != null) {
                            member.__selectionText.visible = false;
                            var selTxt = textCrispy(new FunkinText(txt.width + 15, 0, 0, member.__selectionText.text, 24, false));
                            selTxt.setFormat(Paths.font("8bit-jve.ttf"), 68, member.color, 'left');
                            switch(member.rawText) {
                                case "AppearanceOptions.Advanced.quality-name":
                                    member.changedCallback = (val:String) -> {
                                        var qualitly:Int = Std.parseInt(val);
                                        switch (qualitly) {
                                            case 0: // LOW
                                                set_shaders_low();
                                            case 1: // HIGH
                                                set_shaders_high();
                                        }

                                        if (qualitly <= 1) Options.antialiasing = true;
                                        menu.members[1].checked = Options.antialiasing;
                                        menu.members[2].checked = Options.gameplayShaders;

                                        for (member in 0...menu.members.length) 
                                            menu.members[member].locked = false;
                                        
                                        menu.members[3].locked = qualitly <= 1;
                                        menu.members[2].locked = qualitly <= 1;

                                        var antialiasing = qualitly == 0 ? false : (qualitly == 1 ? true : Options.antialiasing);
                                        FlxG.game.stage.quality = (FlxG.enableAntialiasing = antialiasing) ? 0/*BEST*/ : 2/*LOW*/;
                                        selTxt.text = member.formatTextOption();
                                    };
                                default:
                                    member.changedCallback = (str) -> {
                                        selTxt.text = member.formatTextOption();
                                    }
                            }
                            member.add(selTxt);
                        }
                        member.remove(member.__text);
                        member.add(txt);
                    }
                }
            }
        }
    }
}

var markup:Array<FlxTextFormatMarkerPair> = [
    new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF5D5D), "*"),
    new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF55DAFF), "#"),
    new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFF00), "_")
];

function postUpdate() {
    if(descText != descLabel.text) {
        descLabel.text = descLabel.text.replace("Naughtyness", "Mechanics");
        descLabel.applyMarkup(descLabel.text, markup);
        descText = descLabel.text;
    }
}

function globalUpdate(elapsed:Float) {
    if(KeybindsOptions.instance != null) {
        if(KeybindsOptions.instance.scriptName == "optionsTree.controls-desc") {
            KeybindsOptions.instance.scriptName = "options/KeybindsOptions";
            KeybindsOptions.instance.scriptsAllowed = true;
            KeybindsOptions.instance.loadScript();
            KeybindsOptions.instance.stateScripts.call("create");
        }
    }
}

function destroy() {
    FlxG.save.flush(); // I am tired of the variables reseting sometimes
}