//

importScript("data/scripts/DialogueBoxBG");
importScript("data/scripts/galleryBG");

import openfl.geom.Rectangle;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxTextAlign;

var optionBoxes:Array<DialogueBoxBG> = [];
var optionTexts:Array<FlxText> = [];
static var galleryMusicStarted:Bool = false;

static var gallerySelected:Int = 0;

var curSelected:Int = 0;
var prevSelected:Int = 0;

function create() {
    createGalleryBG();
    if (!galleryMusicStarted) {
        FlxG.sound.playMusic(Paths.music("gallery_placeholder"), 0.3, true);
        galleryMusicStarted = true;
    }

    var baseX:Float = 450;
    var baseY:Float = 100;
    var spacingY:Float = 200;

    var configs = [
        { text: "CHARACTERS" },
        { text: "SONGS" },
        { text: "EXTRAS" },
    ];

    for (i in 0...configs.length) {
        var yPos = baseY + i * spacingY;
        var box = createOptionBox(baseX, yPos);
        optionBoxes.push(box);

        var txt = createOptionText(baseX, yPos + 10, configs[i].text, 70);
        txt.alignment = "center";
        txt.fieldWidth = 400;
        txt.updateHitbox();
        txt.ID = i;
        optionTexts.push(txt);
    }

    changeSelection(gallerySelected, true);
}

function createOptionBox(x:Float, y:Float):DialogueBoxBG {
    var box = newDialogueBoxBG(x, y, null, 400, 100, 5);
    box.pixels.fillRect(
        new Rectangle(5, 5, box.width - 10, box.height - 10),
        0xFF000000
    );
    box.visible = true;
    add(box);
    return box;
}

function createOptionText(x:Float, y:Float, str:String, size:Int = 25):FlxText {
    var txt = textCrispy(new FlxText(x, y, 140, str, size, true));
    txt.setFormat(Paths.font("8bit-jve.ttf"), size, FlxColor.WHITE, FlxTextAlign.CENTER);
    add(txt);
    return txt;
}

function changeSelection(amt:Int = 0, force:Bool = false) {
    prevSelected = curSelected;
    curSelected = force ? amt : FlxMath.wrap(curSelected + amt, 0, optionBoxes.length - 1);

    for (i in 0...optionBoxes.length) {
        for (i in 0...optionBoxes.length) {
        var isSelected = (i == curSelected);
        optionBoxes[i].color = isSelected ? 0xFFFFFF00 : 0xFFFFFFFF;
        optionBoxes[i].pixels.fillRect(new Rectangle(5, 5, optionBoxes[i].width - 10, optionBoxes[i].height - 10), 0xFF000000);
        optionBoxes[i].dirty = true;
        optionTexts[i].color = isSelected ? 0xFFFFFF00 : 0xFFFFFFFF;
    }
    }

    if (prevSelected != curSelected)
        FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
}

function update(elapsed:Float):Void {
    if (controls.BACK || controls.BACK) {
        galleryMusicStarted = false;
        curSelected = 0;
        FlxG.sound.music.stop();
        FlxG.switchState(new MainMenuState());
    }

    var change = (FlxG.keys.justPressed.UP ? -1 : 0)
               + (FlxG.keys.justPressed.DOWN ? 1 : 0)
               - FlxG.mouse.wheel;
    if (change != 0)
        changeSelection(change, false);

    if (FlxG.mouse.justMoved) {
        for (a in optionTexts) {
            if (FlxG.mouse.overlaps(a)) {
                changeSelection(a.ID, true);
                break;
            }
        }
    }

    if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed)
        selectOption();
}

function selectOption() {
    switch (curSelected) {
        case 0: FlxG.switchState(new ModState("gallery/Chars"));
        case 1: FlxG.switchState(new ModState("gallery/Songs"));
        case 2: FlxG.switchState(new ModState("gallery/Extras"));
        default: trace("⬥︎❒︎□︎■︎♑︎");
    }
}

function destroy() gallerySelected = curSelected;