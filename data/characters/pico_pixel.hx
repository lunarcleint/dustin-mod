// fix weird animation bug -lunar
function onPlaySingAnim(_) {
    if (animation.name == _.animName && _.animName != "idle") _.cancel();
}
