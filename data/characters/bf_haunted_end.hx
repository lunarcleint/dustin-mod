// fix weird animation bug -lunar
// using the script here becuase of the eye looping looking weird - higg
var sustainAnim:Bool = false;

function onPlaySingAnim(_) {
    if (animation.name == _.animName && _.animName != "idle" && sustainAnim) _.cancel();
}

function onNoteHit(_) {
    sustainAnim = _.note.isSustainNote;
}