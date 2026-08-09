//
function create() {
    if (FlxG.save.data.mechanics)
        strumLines.members[1].onNoteUpdate.add(onNoteUpdate);
}

function onNoteUpdate(e:NoteUpdateEvent) {
    var note:Note = e.note;
    if (note.noteType != "NOTE_undyne") return;

    if (note.extra["wasMoved"]) {
        note.extra["wasMoved"] = false;
        e.__reposNote = false;
        return;
    }

    var finishedWindow:Float = hitWindow * 0.5;
    var startWindow:Float = finishedWindow + 255;
    var timeUntilNote:Float = note.strumTime - Conductor.songPosition;

    var strumTo:Strum = strumLines.members[1].members[note.noteData];
    var baseScrollFactor:Float = 0.35 * CoolUtil.quantize(scrollSpeed, 100);
    var targetX:Float = strumTo.x + ((strumTo.width - note.width) / 2);

    var oppositeData:Int = switch (note.noteData) {
        case 0: 2;
        case 1: 3;
        case 2: 0;
        case 3: 1;
        default: note.noteData;
    }

    var strumFrom:Strum = strumLines.members[1].members[oppositeData];
    var startX:Float = strumFrom.x + ((strumFrom.width - note.width) / 2);

    if (!note.extra.exists("undyneInitRot")) {
        note.angle = 90; 
        note.extra["undyneInitRot"] = true;
    }

    var lerpedX:Float = 0;
    var angleLerp:Float = 0;

    // if (FlxG.save.data.mechanics) {
    //     lerpedX = targetX;
    //     angleLerp = 0;
    // } else 
    if (timeUntilNote >= startWindow) {
        lerpedX = startX;
        angleLerp = 90;
    } else if (timeUntilNote <= finishedWindow) {
        lerpedX = targetX;
        angleLerp = 0;
    } else {
        var progress:Float = 1 - ((timeUntilNote - finishedWindow) / (startWindow - finishedWindow));
        progress = FlxEase.backOut(FlxMath.bound(progress, 0, 1));

        lerpedX = FlxMath.lerp(startX, targetX, progress);
        angleLerp = FlxMath.lerp(90, 0, progress);
    }

    e.__reposNote = false;
    note.extra["wasMoved"] = true;

    var posy:Float = timeUntilNote * baseScrollFactor;
    if (note.isSustainNote) posy += Strum.N_WIDTHDIV2;
    posy += strumTo.y;

    note.y = posy;
    note.x = lerpedX;
    note.angle = angleLerp;

    var curTail:Note = note.nextNote;
    while (curTail != null && curTail.isSustainNote) {
        var tailOffset:Float = curTail.strumTime - Conductor.songPosition;
        var tailY:Float = tailOffset * baseScrollFactor;
        if (curTail.isSustainNote) tailY += Strum.N_WIDTHDIV2;
        tailY += strumTo.y;

        var centeredTailX:Float = lerpedX + ((note.width - curTail.width) / 2);

        curTail.y = tailY;
        curTail.x = centeredTailX;
        curTail.angle = angleLerp;
        curTail.extra["wasMoved"] = true;

        curTail = curTail.nextNote;
    }
}