// SOMEBODY PLEASE RECODE THIS - higg

public var strumOverlay:FunkinSprite = new FunkinSprite().makeSolid(1, FlxG.height * 10, FlxColor.BLACK);
strumOverlay.origin.x = 0;
strumOverlay.scrollFactor.y = 0;

strumOverlay.alpha = FlxG.save.data.strumOverlay / 100;
strumOverlay.onDraw = (spr) -> {
    if (spr.alpha == 0)
        return;
    var _a = strumOverlay.alpha;
    for (strum in strumLines.members) {
        if (!strum.visible)
            continue;
        strumOverlay.alpha = _a;
        var c = true;
        var a = 0;
        for (s in strum.members) {
            if (c && (s.visible))
                c = false;
            else if (s.alpha > a)
                a = s.alpha;
        }
        if (c || a == 0)
            continue;
        strumOverlay.alpha *= a;
        strumOverlay.scrollFactor.x = strum.members[0].scrollFactor.x;
        strumOverlay.scale.x = strum.members[0].width + 30 + strum.members[strum.members.length -1].x - strum.members[0].x;
        strumOverlay.x = strum.members[0].x - 15;
        strumOverlay.draw();
    }
    strumOverlay.alpha = _a;
}

var index;

function create()
    strumOverlay.cameras = [camHUD];

function repos() {
    if (strumOverlay.alpha == 0)
        return;
    index = members.indexOf(strumLines);

    remove(strumLines, true);
    remove(strumOverlay, true);
    insert(index - 1, strumOverlay);
    insert(index, strumLines);
    strumOverlay.screenCenter(FlxAxes.Y);
}

function postUpdate() {
    if(members[index + 1] != strumLines)
        repos();
}