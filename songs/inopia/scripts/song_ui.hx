//

var sans_pause = ["inopia", "* SANS 1 ATK 1 DEF\n* Hasn't eaten in 7 years.\n* He seems to be in pain.", 0];
var papyrus_pause = ["horror-paps", "* PAPYRUS - 20 ATK 20 DEF\n* Towers over you with an eerie grin.\n* He loves making spaguetti.", -25];

function changePause(info) {
    pauseInfo.character.sprite = info[0];
    pauseInfo.stats = info[1];
    pauseInfo.character.x = info[2];
}

var target:Int = -1;

function onCameraMove() {
    if(target != (target = curCameraTarget) && curStep > 1024) {
        if(curCameraTarget == 0)
            changePause(sans_pause);
        else if(curCameraTarget == 2)
            changePause(papyrus_pause);
    }
}