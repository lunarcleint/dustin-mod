//

var iconHandler = importScript("data/scripts/IconGroup");
public var iconGroup;

function postCreate() {
    iconGroup = newIconGroup(dustiniconP2, [strumLines.members[0], strumLines.members[2]], 0);
    
    iconGroup.group.visible = false;
    dustiniconP2.visible = true;

    iconGroup.interp.update = false;
    iconGroup.forceTarget = 0; // tankman
    iconGroup.updateTarget = false;
    iconGroup.target = -1; // so it can transition easy

    iconGroup.icons[0].scale.set(dustiniconP2.scale.x,dustiniconP2.scale.y);
    iconGroup.icons[0].offset.set(dustiniconP2.offset.x,dustiniconP2.offset.y);
    iconGroup.icons[0].color = FlxColor.WHITE;

    iconGroup.icons[1].scale.set(0.75,0.75);
    iconGroup.icons[1].offset.set(0,-5);
    iconGroup.icons[1].color = iconGroup.shadeColor;
}

function fakeIconP2() {
    iconGroup.group.visible = true;
    dustiniconP2.visible = false;
    
    iconGroup.icons[0].alpha = dustiniconP2.alpha;
    iconGroup.icons[1].alpha = 0;
}

function focusIconGroup() {
    iconGroup.group.visible = true;
    dustiniconP2.visible = false;

    iconGroup.defaultFocus();
    FlxTween.tween(iconGroup.icons[1], {alpha: iconGroup.group.alpha}, (Conductor.stepCrochet / 1000), {ease: FlxEase.cubeOut});
    iconGroup.icons[1].scale.set(iconGroup.group.scale.x,iconGroup.group.scale.y);
}

function stepHit(step:Int) {
    switch(step) {
        case 256:
            fakeIconP2();
        case 1336 | 1664 | 2240 | 2880:
            focusIconGroup();
        case 1536 | 1696 | 2368 | 3136:
            iconGroup.forceFocus(0); // focuses on tankman, 0 being the curCameraTarget
    }
}

function postUpdate() {
    iconGroup.icons[1].animation.curAnim.curFrame = (iconGroup.icons[1].scale.x < 0.85 ? 1 : 0); // pico does not loose
}