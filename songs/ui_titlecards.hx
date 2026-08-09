//

importScript("data/scripts/DialogueBoxBG");
importScript("data/scripts/FunkinTypeText");

import flixel.text.FlxTypeText;
import flixel.FlxObject;

static var titleCard:BasicCard;
static var oldAlphas:Array<Float> = [];
static var fullColor:FlxColor = 0xFFFFFFFF;
static var doHealthbarFade:Bool = true;

static var autoTitleCard:Bool = true;

function create() {
	autoTitleCard = true;
	fullColor = null; doHealthbarFade = true;

	fullColor = FlxColor.fromString(PlayState.SONG.meta?.customValues?.mainColor);
	if (fullColor == null) fullColor = 0xFFFFFFFF;
}

function postCreate() {
	var credit:String = "* Someone made this song/pause(0.5)/\n  but you dont know who";
	if (PlayState.SONG.meta?.customValues?.titleCardSubtext != null)
		credit = PlayState.SONG.meta.customValues.titleCardSubtext;

	titleCard = newBasicCard(0, 0, 0, 0, PlayState.SONG.meta?.customValues?.customName != null ? PlayState.SONG.meta.customValues.customName : PlayState.SONG.meta.name, credit, camHUD2, downscroll);
	insert(members.indexOf(accuracyTxt)+1, titleCard);
}

function onSongStart() {
	if (!autoTitleCard) return;
	showTitleCard();
}

public function showTitleCard() {
	oldAlphas = [for (item in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2]) item.alpha];
	if (doHealthbarFade) {
		for (item in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2])
			if (item.alpha > 0) FlxTween.tween(item, {alpha: 0}, .5, {ease: FlxEase.circOut});
	}

	onComplete = (_) -> {
		if (doHealthbarFade) {
			for (i=>item in [dustinHealthBG, dustinHealthBar, dustiniconP1, dustiniconP2])
				FlxTween.tween(item, {alpha: oldAlphas[i]}, .3, {ease: FlxEase.circIn});
		}
	};
	start();
}

public var Tmembers:Array<FlxBasic> = [];
public var camera:FlxCamera;
public var downscroll:Bool = false;

public var cardBG:FlxSprite;
public var title:FlxText;
public var LINE:FlxSprite;
public var credit:FunkinTypeText;
var creditObj = null;

public var onComplete:Void->Void;
public var startingPos:Float = 0;

public var speedy:Bool = false;

public function newBasicCard(x:Int, y:Int, width:Int, height:Int, _title:String, _credit:String, camera:FlxCamera = FlxG.camera, downscroll:Bool = false) {
	titleCard = new FlxSprite(0,0).makeSolid(0,0);
	titleCard.alpha = 0.000001;
	titleCard.onDraw = (spr:FlxSprite) -> {
		for (member in Tmembers) member.draw();
	};
	titleCard.moves = false;

	cardBG = newDialogueBoxBG(0, 0, null, Math.ceil(camera.width / 1.994), Math.ceil(camera.height / 4.3), 5);
	cardBG.cameras = [camera];
	cardBG.setPosition((camera.width - cardBG.width)/2, startingPos = ((this.downscroll = downscroll) ? -30 -cardBG.height  : camera.height + 30));
	Tmembers.push(cardBG);

	// the capital o for the heart inside  - Nex
	title = textCrispy(new FlxText(0, 0, 0, _title));
	title.setFormat(Paths.font("fallen-down.ttf"), Math.floor(cardBG.width / 20)+2, fullColor);
	title.cameras = [camera];
	title.updateHitbox();
	Tmembers.push(title);

	LINE = new FlxSprite().makeSolid(cardBG.width - 100, Math.round(cardBG.height / 33.6), 0xFFFFFFFF);
	LINE.color = fullColor;
	LINE.cameras = [camera];
	LINE.scale.x = 0;
	Tmembers.push(LINE);

	creditObj = newFunkinTypeText(cardBG.x, cardBG.y + cardBG.height/2 + 100, cardBG.width, _credit);
	credit = creditObj.flxtext;

	// FIX CUSTOM CLASSES
	credit.alignment = "center";

	credit.setFormat(Paths.font("8bit-jve.ttf"), Math.floor(cardBG.width / 20), fullColor);
	credit._defaultFormat.letterSpacing = 1;
	credit.cameras = [camera];
	credit.updateDefaultFormat();
	creditObj.sound = new FlxSound().loadEmbedded(Paths.sound("default_text"));
	Tmembers.push(credit);

	return titleCard;
}

var oldLength = 0;
function update(elapsed:Float) {
    updateFunkinTypeText(elapsed, creditObj);

	title.setPosition(cardBG.x + 5 + (cardBG.width/2) - (title.width/2), cardBG.y + 4);
	LINE.setPosition(cardBG.x + 50, title.y + title.height);

	credit.setPosition(cardBG.x, title.y + title.height + 5);
	credit.update(elapsed);

	credit.color = title.color = LINE.color = cardBG.color = fullColor;
}

public function start() {
	var daY:FLoat = camHUD.height / 1.6;
	if(downscroll) daY = camHUD.height - daY - cardBG.height;
	FlxTween.tween(cardBG, {y: daY}, (Conductor.crochet/1000) * 3, {ease: FlxEase.quartOut});
	new FlxTimer().start((Conductor.crochet/1000) * (speedy ? 1.5 : 3), function(tmr:FlxTimer) {
		credit.visible = true;
		creditObj.start(((Conductor.stepCrochet/1000)/2), creditObj);
		FlxTween.tween(LINE.scale, {x: cardBG.width - 100}, (Conductor.crochet/1000) * 4, {ease: FlxEase.circOut});
		creditObj.completeCallback = function() FlxTween.tween(cardBG, {y: startingPos}, 1, {ease: FlxEase.quadIn, startDelay: 3 * (speedy ? .5 : 1), onComplete: onComplete});
	});
}