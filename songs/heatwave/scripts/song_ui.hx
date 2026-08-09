//

var iconHandler = importScript("data/scripts/IconGroup");
public var iconGroup;

function postCreate() {
    iconGroup = newIconGroup(dustiniconP2, [strumLines.members[0], strumLines.members[2]], 0);
    
    iconGroup.group.visible = false;
    dustiniconP2.visible = true;

    iconGroup.interp.update = false;
    iconGroup.forceTarget = 0; // opponent
    iconGroup.updateTarget = false;
    iconGroup.target = -1; // so it can transition easy
}

function fakeIconP2() {
    iconGroup.group.visible = true;
    dustiniconP2.visible = false;
}

function focusIconGroup() {
    iconGroup.group.visible = true;
    dustiniconP2.visible = false;
}

function stepHit(step:Int) {
    switch(step) {
        case 1214:
            fakeIconP2();
        case 1216:
            focusIconGroup();
        case 2262:
            dustiniconP2.visible = true;
            iconGroup.interp.update = false;
            iconGroup.group.visible = false;
            iconGroup.group.destroy();
            iconHandler.active = false;
    }
}