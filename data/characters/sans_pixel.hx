// fix weird animation bug -lunar
var sustainAnim:Bool = false;

function onPlaySingAnim(_) {
    if (animation.name == _.animName && _.animName != "idle" && sustainAnim) _.cancel();
}

function onNoteHit(_) {
    sustainAnim = _.note.isSustainNote;
}