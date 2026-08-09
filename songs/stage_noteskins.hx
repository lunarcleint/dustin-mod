//
public var finalNotesScale:Float = 0.65;
static var noteSkin:String = "default";
static var splashSkin:String = null;
var confirmSkin:Map<String, Dynamic> = [];

using StringTools;

function create() {
	noteSkin = "default"; splashSkin = null;
	
	if (stage != null && stage.stageXML != null) {
		if (stage.stageXML.exists("noteSkin")) noteSkin = stage.stageXML.get("noteSkin");
		if (stage.stageXML.exists("splashSkin")) splashSkin = stage.stageXML.get("splashSkin");
	}
}

var __usePixel:Bool = false;
function onStrumCreation(event) {
	event.sprite = "game/notes/" + noteSkin;
	if (Assets.exists(Paths.image(event.sprite + "_END"))) {
		__usePixel = true; event.cancel();
		var strum = event.strum;
		strum.loadGraphic(Paths.image(event.sprite), true, 17, 17);
		strum.animation.add("static", [event.strumID]);
		strum.animation.add("pressed", [4 + event.strumID, 8 + event.strumID], 12, false);
		strum.animation.add("confirm", [12 + event.strumID, 16 + event.strumID], 24, false);
	}
}

function onPostStrumCreation(e) {
	var trueScale:Float = __usePixel ? 6 : 1;
	e.strum.scrollFactor.set(1, 1);
	e.strum.scale.set(trueScale, trueScale); e.strum.updateHitbox();
	e.strum.setGraphicSize(Std.int((e.strum.width * finalNotesScale)));
	e.strum.updateHitbox();
}

function onNoteCreation(e) {
	if((e.noteType != null || (e.noteType == "No Animation" || e.noteType == "No Anim Note")) && Assets.exists(Paths.image("game/notes/types/" + e.noteType)))
		e.noteSprite = "game/notes/types/" + e.noteType;
	else {
		e.noteScale = finalNotesScale;
		e.noteSprite = "game/notes/" + noteSkin;
		if (__usePixel) {
			e.cancel();
			var note = e.note;
			if (e.note.isSustainNote) {
				note.loadGraphic(Paths.image(e.noteSprite + "_END"), true, 7, 6);
				note.animation.add("hold", [e.strumID]);
				note.animation.add("holdend", [4 + e.strumID]);
			} else {
				note.loadGraphic(Paths.image(e.noteSprite), true, 17, 17);
				note.animation.add("scroll", [4 + e.strumID]);
			}
			note.scale.set(6, 6); note.updateHitbox();
			note.setGraphicSize(Std.int((note.width * finalNotesScale)));
			note.updateHitbox();
		}
	}
}

var dirOffsets:Array<Array<Int>> = [[-5,-10], [-10,-10], [-10,-10], [-5,-10]];
var dir:Array = ["left", "down", "up", "right"];

function onPostNoteCreation(e) {
	if(e.noteType != null && e.noteType.contains("NOTE") && confirmSkin[e.noteType] == null) {
		if(Assets.exists(Paths.image("game/notes/types/" + e.noteType))) {
			confirmSkin[e.noteType] = [];
			for(i in 0...e.note.strumLine.members.length) {
				var spr:FlxSprite = new FlxSprite(0, 0);
				spr.ID = i;
				spr.active = spr.visible = false;
				spr.frames = Paths.getFrames("game/notes/types/" + e.noteType);
				spr.updateHitbox();
				spr.setGraphicSize(Std.int((spr.width * finalNotesScale)));
				spr.animation.addByPrefix("confirm", dir[i] + " confirm", 24, false);
				spr.animation.play("confirm", true);
				spr.camera = e.note.strumLine.camera;
				add(spr);
				confirmSkin[e.noteType].push(spr);
			}
		}
	}
	e.note.splash = splashSkin;
	switch (noteSkin) {
		case "default":
			e.note.useAntialiasingFix = true;
			if(e.note.gapFix != null)
				e.note.gapFix = 3.5;
	}
}

function postUpdate() {
	for(type in confirmSkin.keys()) {
		for(i => note in confirmSkin[type]) {
			if(note.active) {
				note.setPosition(
					playerStrums.members[i].x - ((playerStrums.members[i].width / 2) * (finalNotesScale / 2)) + dirOffsets[i][0],
					playerStrums.members[i].y -  ((playerStrums.members[i].height / 2) * (finalNotesScale / 2)) + dirOffsets[i][1]
				);
				if(playerStrums.members[i].getAnim() == "static") {
					note.active = note.visible = false;
					playerStrums.members[i].visible = true;
				}
			}
		}
	}
}

function onNoteHit(e) {
	if (splashSkin == null) e.showSplash = false;
	if (e.note.strumLine == playerStrums && (e.note.extra["hurtNote"] == null || validHurtNoteHit(e.note))) {
		if(confirmSkin[e.note.noteType] != null) {
			confirmSkin[e.note.noteType][e.note.strumID].active = true;
			confirmSkin[e.note.noteType][e.note.strumID].animation.play("confirm", true);
			confirmSkin[e.note.noteType][e.note.strumID].updateHitbox();
			confirmSkin[e.note.noteType][e.note.strumID].centerOffsets();
			confirmSkin[e.note.noteType][e.note.strumID].visible = true;
			playerStrums.members[e.note.strumID].visible = false;
		}
	}
}