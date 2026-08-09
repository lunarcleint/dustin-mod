//
var cahced:Array<String> = [];
var daPixelZoom = 6;

function postCreate() {
    var strumChanges:Array<Float> = [];

    for (i => event in PlayState.SONG.events) {
        if (event.name != "Change Strum Skin") continue;

        var skin = event.params[0];
        var pixel = event.params[1];
        if (!cahced.contains(skin)) {
            graphicCache.cache(Paths.image("game/notes/" + skin));
            if (pixel) graphicCache.cache(Paths.image("game/notes/" + skin + "_ENDs"));
        }
        
        event.params[2] = strumChanges.length; // secret THIRD PARAM????
        strumChanges.push(event.time);
    }

    for (eventi => time in strumChanges) {
        var startTime:Float = time;
        var endTime:Float = strumChanges[eventi+1] != null ? strumChanges[eventi+1] : Math.POSITIVE_INFINITY;

        for (strumLine in strumLines.members) {
            for (i => note in strumLine.notes.members) 
                if (note.strumTime >= startTime && note.strumTime < endTime) 
                    note.extra["CHANGE_EVENT"] = eventi;
        }
    }
}

var strumAnimPrefix = ["left", "down", "up", "right"];
function onEvent(eventEvent) {
    if (eventEvent.event.name == "Change Strum Skin") {
        var skin:String = eventEvent.event.params[0];
        var isPixel:Bool = eventEvent.event.params[1];

        var frames:Dynamic = isPixel ? Paths.image("game/notes/" + skin) : Paths.getFrames("game/notes/" + skin);
        
        for (strumLine in strumLines.members) {
            for (i => note in strumLine.notes.members) {
                if ((note.noteTypeID != 0 && (note.noteType != "No Animation" && note.noteType != "No Anim Note")) || note.extra["CHANGE_EVENT"] != eventEvent.event.params[2]) continue; // avoid notetypes/notes that will be changed later
                if (skin == noteSkin) break; // avoid notes that are alreadly the default skin and are being changed back (were never changed in the first place)

                var oldAnimName:String = note.animation.name;
                var oldAnimFrame:Int = note.animation?.curAnim?.curFrame;
                if (oldAnimFrame == null) oldAnimFrame = 0;

                note.frames = isPixel ? null : frames;
                note.animation._animations.clear();
		        note.animation._curAnim = null;

                if (isPixel) {
                    if (note.isSustainNote) {
                        note.loadGraphic(Paths.image("game/notes/" + skin + "_ENDs"), true, 7, 6);
                        note.animation.add("hold", [note.noteData]);
                        note.animation.add("holdend", [4 + note.noteData]);
                    } else {
                        note.loadGraphic(frames, true, 17, 17);
		                note.animation.add("scroll", [4 + note.noteData]);
                    }
                    note.antialiasing = false;
                } else {
                    switch(note.noteData % 4) {
						case 0:
							note.animation.addByPrefix('scroll', 'purple0');
							note.animation.addByPrefix('hold', 'purple hold piece');
							note.animation.addByPrefix('holdend', 'pruple end hold');
						case 1:
							note.animation.addByPrefix('scroll', 'blue0');
							note.animation.addByPrefix('hold', 'blue hold piece');
							note.animation.addByPrefix('holdend', 'blue hold end');
						case 2:
							note.animation.addByPrefix('scroll', 'green0');
							note.animation.addByPrefix('hold', 'green hold piece');
							note.animation.addByPrefix('holdend', 'green hold end');
						case 3:
							note.animation.addByPrefix('scroll', 'red0');
							note.animation.addByPrefix('hold', 'red hold piece');
							note.animation.addByPrefix('holdend', 'red hold end');
				    }
                    note.antialiasing = Options.antialiasing;
                }

                note.scale.set(isPixel ? daPixelZoom : finalNotesScale, isPixel ? daPixelZoom : finalNotesScale);

                note.animation.play(oldAnimName, true);
                note.animation?.curAnim?.curFrame = oldAnimFrame;

                note.updateHitbox();
                note.gapFix = skin == "default" ? 3.5 : 0;

                var len = 0.45 * CoolUtil.quantize(scrollSpeed, 100);

                if (note.nextSustain != null) {
                    note.scale.y = (note.sustainLength * len) / note.frameHeight;
                    note.updateHitbox();
                    note.scale.y += note.gapFix / note.frameHeight;
                }
            }

            for (i => strum in strumLine.members) {
                var oldAnimName:String = strum.animation.name;
                var oldAnimFrame:Int = strum.animation?.curAnim?.curFrame;
                if (oldAnimFrame == null) oldAnimFrame = 0;

                strum.frames = isPixel ? null : frames;
                strum.animation._animations.clear();
		        strum.animation._curAnim = null;

                if(isPixel){
                    strum.loadGraphic(frames, true, 17, 17);
                    strum.animation.add("static", [strum.ID]);
                    strum.animation.add("pressed", [4 + strum.ID, 8 + strum.ID], 12, false);
                    strum.animation.add("confirm", [12 + strum.ID, 16 + strum.ID], 24, false);
                    strum.antialiasing = false;
                } else {
                    strum.animation.addByPrefix('static', 'arrow' + strumAnimPrefix[i % strumAnimPrefix.length].toUpperCase(), true);
                    strum.animation.addByPrefix('pressed', strumAnimPrefix[i % strumAnimPrefix.length] + ' press', 24, false);
                    strum.animation.addByPrefix('confirm', strumAnimPrefix[i % strumAnimPrefix.length] + ' confirm', 24, false);
                    strum.antialiasing = Options.antialiasing;
                }

                strum.scale.set(isPixel ? daPixelZoom : finalNotesScale,isPixel ? daPixelZoom : finalNotesScale);
                strum.updateHitbox();

                strum.playAnim(oldAnimName, true);
                strum.animation?.curAnim?.curFrame = oldAnimFrame;
            }
        }
    }
}