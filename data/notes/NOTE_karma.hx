//
var karmaDrainTimer:Float = 0;
var karmaDrainDuration:Float = 5;
var karmaDrainTick:Float = 0.1;
var karmaDrainTimeLeft:Float = 0;

function onNoteCreation(event:NoteCreationEvent) if (event.note.noteType == "NOTE_karma" || event.noteType == "NOTE_hate") {
    if (!FlxG.save.data.mechanics) {
        event.note.strumTime -= 999999;
        event.note.exists = event.note.active = event.note.visible = false;
        return;
    }
    event.note.extra.set("hurtNote", true);
    //event.note.avoid = true; Hitbox is weird when you try hitting a regular note
}

function onPlayerMiss(event) {
    if (event.noteType == "NOTE_karma" || event.noteType == "NOTE_hate") {
        event.cancel(true); 
        event.note.strumLine.deleteNote(event.note);
    }
}

function onPlayerHit(event) {
    if (event.noteType == "NOTE_karma" && validHurtNoteHit(event.note)) {
        karmaDrainTimeLeft = karmaDrainDuration;
        karmaDrainTimer = 0;

        FlxG.camera.shake(0.01, 0.2);
        FlxG.sound.play(Paths.sound("hurt_note"));
    }

    if (event.noteType == "NOTE_hate" && validHurtNoteHit(event.note)) {
        if (stage.getSprite("hate_vignette").alpha != 1) {
            stage.getSprite("hate_vignette").alpha += 0.2;
        }
        else {
            health -= 2;
        }

        FlxG.camera.shake(0.01, 0.2);
        FlxG.sound.play(Paths.sound("hurt_note"));
    }
}

function update(elapsed:Float) {
    // Karma health drain logic
    if (karmaDrainTimeLeft > 0) {
        karmaDrainTimer += elapsed;
        if (karmaDrainTimer >= karmaDrainTick) {
            karmaDrainTimer = 0;
            karmaDrainTimeLeft -= karmaDrainTick;
            ogHealthColors[0] = healthBarColors[0] = 0xF300FF;
            if (health > 0.1) {
                health -= 0.01;
                if (health < 0.1)
                    health = 0.1;
            }
        }
    } else {
        ogHealthColors[0] = healthBarColors[0] = dad.iconColor;
    }
}
