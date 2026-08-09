//
import funkin.options.keybinds.KeybindsOptions;
import funkin.editors.charter.Charter;

var dialogueBoxBG = PlayState.instance.scripts.importScript("data/scripts/DialogueBoxBG");
var funkinTypeText = PlayState.instance.scripts.importScript("data/scripts/FunkinTypeText");
var script;

var bottom:FunkinSprite;
var top:FunkinSprite;
var heart:FunkinSprite;
var character:FunkinSprite;
var statTextObj;
var statText:FunkinTypeText;
var bonesStatsImage:FunkinSprite;
var frozenCameras:Array<FlxCamera> = [];

var bonesStatsImageX:Float = 30.0;
var bonesStatsImageY:Float = 0.0;
var bonesStatsImageSize:Float = 140.0;

var bonesStatsTokenIndex:Int = -1;
var bonesStatsTextX:Float = 0.0;
var bonesStatsTextY:Float = 0.0;

var meta:ChartData = PlayState.SONG.meta;
var utItems:Array<FlxSprite> = [];

var pauseInfo = PlayState.instance.scripts.publicVariables.get("pauseInfo");
var dustinPauseScript = PlayState.instance.scripts.publicVariables.get("dustinPauseScript");

var post:Bool = false;
var mouseFocus:Bool = true;

function create(_) {
	FlxG.signals.focusLost.add(onFocusLost);
    forceUpdate.push(globalUpdate);

	_.cancel();

	if (dustinPauseScript != null)
		dustinPauseScript = PlayState.instance.scripts.importScript("data/scripts/pause/" + dustinPauseScript);

	add(top = newDialogueBoxBG(-Math.floor(FlxG.width / 4.06), Math.floor(FlxG.height * 0.084), null, Math.floor(FlxG.width / 4.74), Math.floor(FlxG.height / 2.285), 5));
	add(bottom = newDialogueBoxBG(top.x, top.y + top.extra["bHeight"] + Math.floor(FlxG.height * 0.056), null, Math.floor(FlxG.width /1.765), Math.floor(FlxG.height / 3.2), 5));
	top.color = fullColor; bottom.color = fullColor;

	__offsets = [Math.floor(top.extra["bWidth"] * 0.2595), Math.floor(bottom.extra["bWidth"] * 0.049), bottom.extra["bWidth"] * 0.05863];

	var statsDescription:String = pauseInfo.stats;
	if (statsDescription == null)
		statsDescription = "* GASTER - ?? ATK ?? DEF\n* Dark, yet darker.\n* You are not supposed to see this.";

	if (
		meta.name.toLowerCase() == "lorem-ipsum" &&
		statsDescription.indexOf("[bones]") >= 0
	)
	{
		bonesStatsTokenIndex = statsDescription.indexOf("[bones]");
		statsDescription = StringTools.replace(
			statsDescription,
			"[bones]",
			"       "
		);
	}

	statTextObj = newFunkinTypeText(bottom.x + Math.floor(FlxG.width * 0.0395), bottom.y + Math.floor(FlxG.height * 0.043), bottom.extra["bWidth"] - bottom.extra["border"] - 15, statsDescription);
	statText = statTextObj.flxtext;
	statText.setFormat(Paths.font("8bit-jve.ttf"), Math.floor(bottom.extra["bWidth"] / 19), fullColor);
	statText._defaultFormat.letterSpacing = Math.floor(bottom.extra["bWidth"] * 0.0042);
	statText._defaultFormat.leading = Math.floor(bottom.extra["bWidth"] / 36);
	statText.updateDefaultFormat();
	statTextObj.sound = new FlxSound().loadEmbedded(Paths.sound("default_text"));

	statTextObj.start(null, statTextObj);
	add(statText);

	if (bonesStatsTokenIndex >= 0)
	{
		statText.text = statsDescription;
		statText.updateHitbox();

		var firstTokenBounds =
			statText.textField.getCharBoundaries(
				bonesStatsTokenIndex
			);

		var lastTokenBounds =
			statText.textField.getCharBoundaries(
				bonesStatsTokenIndex + 6
			);

		statText.text = "";
		statText.updateHitbox();

		bonesStatsImage = new FunkinSprite();
		bonesStatsImage.loadGraphic(Paths.image("bones"));
		bonesStatsImage.setGraphicSize(
			Std.int(bonesStatsImageSize)
		);
		bonesStatsImage.updateHitbox();
		bonesStatsImage.antialiasing = false;
		bonesStatsImage.visible = false;

		if (firstTokenBounds != null)
		{
			var reservedWidth:Float =
				firstTokenBounds.width;

			if (lastTokenBounds != null)
				reservedWidth =
					lastTokenBounds.x +
					lastTokenBounds.width -
					firstTokenBounds.x;

			bonesStatsTextX =
				firstTokenBounds.x +
				(
					reservedWidth -
					bonesStatsImage.width
				) * 0.5;

			bonesStatsTextY =
				firstTokenBounds.y +
				(
					firstTokenBounds.height -
					bonesStatsImage.height
				) * 0.5;
		}

		add(bonesStatsImage);
	}

	add(grpMenuShit = new FlxGroup());

	var fakeItems = [
		"RESUME",
		"RESTART",
		"CONTROLS",
		"OPTIONS",
		"EXIT"
	];

	for (i=>item in menuItems) {
		var itemTxt = textCrispy(new FlxText(top.x + __offsets[0], top.y + Math.floor(top.extra["bHeight"] * 0.09) + (Math.floor(top.extra["bHeight"] * 0.851) / menuItems.length) * i, 0, fakeItems[i] != null ? fakeItems[i] : item.toUpperCase()));
		itemTxt.setFormat(Paths.font("8bit-jve.ttf"), Math.floor(top.extra["bWidth"] * 0.141), fullColor);
		itemTxt._defaultFormat.letterSpacing = Math.floor(top.extra["bWidth"] * 0.02);
		itemTxt.updateDefaultFormat();
		
		add(itemTxt);
		utItems.push(itemTxt);
	}

	var soulType:Null<Bool> = pauseInfo.isMonster;
    var heartPath:String = soulType ? "game/gameover/monster_heart" : "game/gameover/heart";

	var idk:Int = Math.floor(top.extra["bWidth"] * 0.093);
	heart = new FunkinSprite().loadGraphic(Paths.image(heartPath));
	if (soulType == null)
		heart.visible = heart.active = false;
	if (FlxG.width == 640) heart.setGraphicSize(Std.int(16));
	else heart.setGraphicSize(Std.int(24));
	heart.updateHitbox();
	heart.antialiasing = false;
	add(heart);

	var charName = pauseInfo?.character.sprite;
	if (charName == null) charName = meta.name;
	character = new FunkinSprite(FlxG.width, FlxG.height * 0.4515).loadGraphic(Paths.image("game/ui/pause/characterIcons/" + charName));

	add(character);
	idk = Math.floor(FlxG.width * 0.0032);
	if ((character.x + character.width) * idk > FlxG.width) idk = (character.x - character.width) * 0.0032;
	character.scale.set(idk, idk);

	var charOffsetX:Float = 0;
	var charOffsetY:Float = 0;
	if (pauseInfo?.character.x != null)
		charOffsetX = Std.parseFloat(pauseInfo.character.x);
	if (pauseInfo?.character.y != null)
		charOffsetY = Std.parseFloat(pauseInfo.character.y);

	// doesn't work well atm sorry
	/*var pauseGraph = createGraphic(0, 0, "PauseBuffer");
	captureScreenToBitmapData(null, null, pauseGraph.bitmap);
	resizeGraphic(pauseGraph, pauseGraph.bitmap.width, pauseGraph.bitmap.height);

	for (camera in cameras) {
		if (camera.visible) {
			camera.visible = false;
			frozenCameras.push(camera);
		}
	}
	*/

	camera = new FlxCamera();
	camera.pixelPerfectRender = true;
	camera.bgColor = 0x00000000;
	FlxG.cameras.add(camera, false);

	top.cameras = [camera];
	bottom.cameras = [camera];
	if (bonesStatsImage != null)
		bonesStatsImage.cameras = [camera];

	bg = new FunkinSprite(0, 0);
	bg.makeGraphic(1,1, FlxColor.BLACK);
	bg.alpha = 0.45;
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.updateHitbox();
	bg.antialiasing = true;
	insert(0, bg);

	//visible = false;

	changeSelection(0);
	FlxTween.tween(top, {x: top.y}, 0.5, {ease: FlxEase.backOut});
	FlxTween.tween(bottom, {x: top.y}, 0.6, {ease: FlxEase.backOut});
	character.y += charOffsetY;
	FlxTween.tween(character, {x: switch (charName.toLowerCase()) {
		case "homiecide": 900;
		default: Math.floor(FlxG.width / 1.312);
	} + charOffsetX}, 0.6, {ease: FlxEase.backOut, startDelay: 0.1});

	if (dustinPauseScript != null) {
		dustinPauseScript.setParent(__script__.parent);
		dustinPauseScript.call("onPause", [__script__.interp.variables, _]);
	}
}

function onFocusLost() {
    if (!Options.autoPause) return;
	mouseFocus = false;
}

var __offsets:Array<Int>;
function update(elapsed:Float) {
	if (post != (post = true))
		dustinPauseScript?.call("onPostPause");
	var upP = controls.UP_P;
	var downP = controls.DOWN_P;
	var accepted = controls.ACCEPT;

	var change = (upP ? -1 : 0) + (downP ? 1 : 0) - FlxG.mouse.wheel;
    if (change != 0) changeSelection(change, false);

	if (accepted || (mouseFocus && FlxG.mouse.justPressed))
		selectOption();

	if(!mouseFocus)
		mouseFocus = true;

	for (i in utItems) 
		i.x = top.x + __offsets[0];
	statText.x = bottom.x + __offsets[1];
	heart.x = utItems[curSelected]?.x - __offsets[2];
	updateFunkinTypeText(elapsed, statTextObj);

	if (bonesStatsImage != null)
	{
		bonesStatsImage.x =
			statText.x +
			bonesStatsTextX +
			bonesStatsImageX;

		bonesStatsImage.y =
			statText.y +
			bonesStatsTextY +
			bonesStatsImageY;

		bonesStatsImage.visible =
			statTextObj._curLength >
			bonesStatsTokenIndex;
	}
}

function onChangeItem(e) {
	FlxTween.cancelTweensOf(heart);
	FlxTween.tween(heart, {y: utItems[e.value]?.y + (utItems[e.value].height - heart.height)/2}, 0.25, {ease: FlxEase.backOut});
	CoolUtil.playMenuSFX();

	for (i in 0...utItems.length)
		utItems[i].alpha = (i == e.value) ? 1 : 0.6;
}

function onSelectOption(e) {
	FlxG.sound.play(Paths.sound("menu/select"));
}

function globalUpdate(elapsed:Float) {
    if(KeybindsOptions.instance != null) {
        if(KeybindsOptions.instance.scriptName != "options/KeybindsOptions") {
            KeybindsOptions.instance.scriptName = "options/KeybindsOptions";
            KeybindsOptions.instance.scriptsAllowed = true;
            KeybindsOptions.instance.loadScript();
            KeybindsOptions.instance.stateScripts.call("create");
            KeybindsOptions.instance.stateScripts.set("color", statTextObj.flxtext.color);
        }
    }
}

function destroy() {
	FlxG.signals.focusLost.remove(onFocusLost);
	if (PlayState.instance.scripts != null) {
		for(script in [dialogueBoxBG, funkinTypeText, script]) {
			PlayState.instance.scripts.remove(script, true);
			script = null;
		}
	}
    forceUpdate.remove(globalUpdate);
    //for (camera in frozenCameras) camera.visible = true;
}
