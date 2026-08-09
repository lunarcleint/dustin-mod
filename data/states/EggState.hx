importScript("data/scripts/DialogueBoxBG");
importScript("data/scripts/FunkinTypeText");

var backgrounds:Array<FunkinSprite> = [];
var backgroundFrame:Int = 0;
var backgroundTimer:Float = 0;
var backgroundFrameDuration:Float = 0.5;

var dialogueBox:FunkinSprite;
var dialoguePrefix:FunkinText;
var typeText:Dynamic;
var dialogueData:Dynamic;
var dialogueLines:Array<Dynamic> = [];
var currentLine:Int = 0;
var dialogueStarted:Bool = false;
var dialogueSection:String = "intro";

var choices:Array<FunkinText> = [];
var heart:FunkinSprite;
var currentChoice:Int = 0;
var choosing:Bool = false;
var dialogueFinished:Bool = false;
var leaving:Bool = false;

function parseJson(path:String) {
    var jsonPath:String = Paths.json("gaster/" + path);
    if (Assets.exists(jsonPath)) {
        try {
            return Json.parse(Assets.getText(jsonPath));
        } catch (e:Dynamic) {
            trace("INVALID EGG DIALOGUE JSON: " + e);
        }
    }
    return null;
}

function create() {
    if (FlxG.save.data.EggOne == true) {
        var destination:String = data == "NewMainMenu" ? "NewMainMenu" : "ShopState";
        FlxG.switchState(new ModState(destination));
        return;
    }

    FlxG.camera.bgColor = FlxColor.BLACK;

    if (FlxG.sound.music != null)
        FlxG.sound.music.stop();
    FlxG.sound.music = null;
    FlxG.sound.playMusic(Paths.music("eggroom_theme"), 0.7, true);

    dialogueData = parseJson("eggDialogue");
    dialogueLines = dialogueData.dialogue.copy();

    for (i in 1...4) {
        var background = new FunkinSprite(0, 0, Paths.image("menus/eggroom/frame" + i));
        background.setGraphicSize(FlxG.camera.width, FlxG.camera.height);
        background.updateHitbox();
        background.setPosition(0, 0);
        background.antialiasing = Options.antialiasing;
        background.visible = i == 1;
        backgrounds.push(background);
        add(background);
    }

    var boxWidth:Float = 760;
    var boxHeight:Float = 150;
    var boxX:Float = (FlxG.width - boxWidth) / 2;
    var boxY:Float = 45;

    dialogueBox = newDialogueBoxBG(boxX, boxY, null, boxWidth, boxHeight, 5);
    dialogueBox.visible = false;
    add(dialogueBox);

    var dialogueTextX:Float = boxX + 28;
    var dialogueTextY:Float = boxY + 20;
    var dialogueTextSize:Int = 32.5;

    dialoguePrefix = new FunkinText(dialogueTextX, dialogueTextY, 0, "*", dialogueTextSize, false);
    dialoguePrefix.setFormat(Paths.font("8bit-jve.ttf"), dialogueTextSize, FlxColor.WHITE);
    dialoguePrefix.letterSpacing = 3;
    dialoguePrefix.antialiasing = false;
    dialoguePrefix.visible = false;
    add(dialoguePrefix);

    typeText = newFunkinTypeText(dialogueTextX + 34, dialogueTextY, boxWidth - 90, "", dialogueTextSize);
    typeText.flxtext.setFormat(Paths.font("8bit-jve.ttf"), dialogueTextSize, FlxColor.WHITE);
    typeText.flxtext.letterSpacing = 3;
    typeText.flxtext.antialiasing = false;
    typeText.flxtext.visible = false;
    typeText.defaultSound = FlxG.sound.load(Paths.sound("default_text"), 0.7);
    typeText.sound = typeText.defaultSound;
    add(typeText.flxtext);

    for (i => label in dialogueData.choices) {
        var option = textCrispy(new FunkinText(0, boxY + boxHeight - 45, 0, label, 34, false));
        option.setFormat(Paths.font("8bit-jve.ttf"), dialogueTextSize, FlxColor.WHITE);
        option.letterSpacing = 3;
        option.antialiasing = false;
        option.ID = i;
        option.updateHitbox();
        option.x = boxX + (boxWidth * (i == 0 ? 0.3 : 0.7)) - option.width / 2;
        option.visible = false;
        choices.push(option);
        add(option);
    }

    heart = new FunkinSprite(0, 0, Paths.image("game/heart"));
    heart.setGraphicSize(22, 22);
    heart.updateHitbox();
    heart.antialiasing = false;
    heart.visible = false;
    add(heart);
}

function showLine() {
    dialoguePrefix.visible = true;
    var lineText:String = dialogueLines[currentLine].text;

    if (lineText == "(You received the Egg.)")
        FlxG.sound.play(Paths.sound("egg_sound"));

    typeText.resetText(lineText, typeText);
    typeText.start(0.04, typeText);
}

function showChoices() {
    choosing = true;
    currentChoice = 0;
    for (option in choices) option.visible = true;
    heart.visible = true;
    updateChoiceVisuals();
}

function hideChoices() {
    choosing = false;
    for (option in choices) option.visible = false;
    heart.visible = false;
}

function updateChoiceVisuals() {
    for (i => option in choices)
        option.color = i == currentChoice ? FlxColor.YELLOW : FlxColor.WHITE;

    var selected = choices[currentChoice];
    heart.setPosition(selected.x - 38, selected.y + (selected.height - heart.height) / 2);
}

function selectChoice() {
    hideChoices();

    if (currentChoice == 0) {
        FlxG.save.data.EggOne = true;
        FlxG.save.flush();
    }

    dialogueSection = currentChoice == 0 ? "yes" : "no";
    dialogueLines = (currentChoice == 0 ? dialogueData.yes : dialogueData.no).copy();
    currentLine = 0;
    showLine();
}

function finishDialogue() {
    dialogueFinished = true;
    typeText.isTyping = false;
    typeText.sound?.stop();
    dialoguePrefix.visible = false;
    typeText.flxtext.visible = false;
    dialogueBox.visible = false;
    hideChoices();
}

function updateChoices() {
    var change:Int = (controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0);
    if (change != 0) {
        currentChoice = FlxMath.wrap(currentChoice + change, 0, choices.length - 1);
        updateChoiceVisuals();
    }

    if (controls.BACK) {
        currentChoice = 1;
        selectChoice();
        return;
    }

    if (FlxG.mouse.justPressed) {
        for (option in choices) {
            if (FlxG.mouse.overlaps(option)) {
                if (currentChoice == option.ID)
                    selectChoice();
                else {
                    currentChoice = option.ID;
                    updateChoiceVisuals();
                }
                return;
            }
        }
    }

    if (controls.ACCEPT || FlxG.keys.justPressed.Z)
        selectChoice();
}

function update(elapsed:Float) {
    backgroundTimer += elapsed;
    while (backgroundTimer >= backgroundFrameDuration) {
        backgroundTimer -= backgroundFrameDuration;
        backgrounds[backgroundFrame].visible = false;
        backgroundFrame = (backgroundFrame + 1) % backgrounds.length;
        backgrounds[backgroundFrame].visible = true;
    }

    if (dialogueFinished) {
        if (!leaving && FlxG.keys.justPressed.ESCAPE)
            leaveState();
        return;
    }

    if (!dialogueStarted) {
        if (FlxG.keys.justPressed.ANY) {
            dialogueStarted = true;
            dialogueBox.visible = true;
            dialoguePrefix.visible = true;
            typeText.flxtext.visible = true;
            showLine();
        }
        return;
    }

    updateFunkinTypeText(elapsed, typeText);

    if (dialogueSection == "intro" && currentLine == dialogueLines.length - 1 && !typeText.isTyping && !choosing) {
        showChoices();
        return;
    }

    if (choosing) {
        updateChoices();
        return;
    }

    if (!leaving && (controls.ACCEPT || controls.BACK || FlxG.keys.justPressed.Z || FlxG.mouse.justPressed)) {
        if (typeText.isTyping) {
            typeText.skip(typeText);
        } else if (currentLine < dialogueLines.length - 1) {
            currentLine++;
            showLine();
        } else {
            finishDialogue();
        }
    }
}

function leaveState() {
    leaving = true;
    typeText.sound?.stop();

    if (FlxG.sound.music != null)
        FlxG.sound.music.stop();
    FlxG.sound.music = null;

    FlxG.switchState(new ModState("NewMainMenu"));
}
