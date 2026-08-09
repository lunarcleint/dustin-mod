import funkin.backend.utils.FlxInterpolateColor;

var iconGroupUpdateList:Array<Dynamic> = [];

// icon1 & icon2 are meant to be a Strumline, but return FlxSprites
static function newIconGroup(tracker:FlxSprite, iconList:Array<Dynamic>, ?flip:Bool) {
    tracker.visible = false;
    var group:FlxSpriteGroup = new FlxSpriteGroup();
    group.cameras = tracker.cameras;

    for(i in iconList) {
        if (i == null) {
            iconList.remove(i);
            continue;
        }
        var id:Int = strumLines.members.indexOf(i);
        group.add(i = createHealthIcon(i.characters[0].getIcon(), flip)).ID = id;
        i.scrollFactor.set();
    }

    var iconGroup:Dynamic = {
        tracker: tracker,
        group: group,
        icons: group.members.copy(),
        follow: true,
        offset: FlxPoint.get(0,0),
        ID: iconGroupUpdateList.length + 1,
        interp: {
            timer: {
                wait: 0,
                start: 0,
                end: 0
            },
            update: false,
            color: new FlxInterpolateColor(FlxColor.WHITE)
        },
        target: curCameraTarget,
        insertIcons: false,
        shadeColor: 0x005E5E5E,
        forceTarget: null,
        updateTarget: null
    }

    iconGroup.forceFocus = function(focus:Int) {
        iconGroup.interp.update = false;
        iconGroup.target = null;
        iconGroup.forceTarget = focus; // tankman
        iconGroup.updateTarget = true;
    }

    iconGroup.defaultFocus = function() {
        iconGroup.target = null; // so it can transition easy
        iconGroup.forceTarget = null;
        iconGroup.updateTarget = null;
    }

    iconGroup.destroy = function() {
        iconGroupUpdateList.remove(iconGroup);
        remove(iconGroup, true);
        for (i in icons)
            i.destroy();
        iconGroup.group.destroy();
        iconGroup.interp.color.destroy();
        iconGroup = null;
    }

    updateIconGroup(iconGroup, 1);
    updateIcons(iconGroup, 1);
    iconGroupUpdateList.push(iconGroup);

    insert(members.indexOf(tracker), iconGroup.group);
    hudElements.push(iconGroup.group);

    return iconGroup;
}

function update(elapsed) {
    for (iconGroup in iconGroupUpdateList) {
        if (iconGroup != null)
            updateIconGroup(iconGroup, elapsed);
    }
}

function updateIconGroup(iconGroup, elapsed) {
    if (!iconGroup.group.visible)
        return;

    if (iconGroup.follow) {
        iconGroup.group.setPosition(iconGroup.tracker.x + iconGroup.offset.x, iconGroup.tracker.y + iconGroup.offset.y);
        iconGroup.group.alpha = iconGroup.tracker.alpha;
    }

    for(i => icon in iconGroup.icons)
        icon.animation.curAnim.curFrame = iconGroup.tracker.animation.curAnim.curFrame;

    if (iconGroup.updateTarget || iconGroup.target != (iconGroup.target = curCameraTarget)) {

        if ((iconGroup.updateTarget == null && iconGroup.forceTarget != (iconGroup.forceTarget = iconGroup.target)) || iconGroup.updateTarget && (iconGroup.target != (iconGroup.target = iconGroup.forceTarget))) {
            if (iconGroup.updateTarget != null)
                iconGroup.updateTarget = false;
            iconGroup.interp.timer.wait = ((Conductor.stepCrochet * .25) / (FlxG.camera.followLerp * 1000));
            iconGroup.interp.timer.start = inst.time;
            iconGroup.interp.timer.end = inst.time +((Conductor.stepCrochet * 87.75) / (FlxG.camera.followLerp * 1000));
            iconGroup.interp.update = true;
            iconGroup.insertIcons = true;
        }
    }

    if(iconGroup.interp.update) {
        if(inst.time - iconGroup.interp.timer.start > iconGroup.interp.timer.wait) {
            var progress:Float = FlxEase.circOut(FlxMath.bound((((inst.time - iconGroup.interp.timer.wait) - iconGroup.interp.timer.start)) / ((iconGroup.interp.timer.end * 2) - iconGroup.interp.timer.start), 0 ,1)); // what the fuck is this math - higg
            updateIcons(iconGroup, progress);
            if(progress >= 1) {
                iconGroup.interp.update = false;
                if (iconGroup.updateTarget == null)
                    iconGroup.forceTarget = null;
            }
        }
        if(iconGroup.insertIcons && inst.time - iconGroup.interp.timer.start > iconGroup.interp.timer.wait * 2) {
            var target:Int = -1;
            var focus = iconGroup.forceTarget == null ? iconGroup.target : iconGroup.forceTarget;
            for(icon in iconGroup.group.members) {
                iconGroup.group.remove(icon);
                if (icon.ID == focus)
                    target = iconGroup.icons.indexOf(icon);
            }
            if(target == 0) {
                iconGroup.group.add(iconGroup.icons[1]);
                iconGroup.group.add(iconGroup.icons[0]);
            } else {
                iconGroup.group.add(iconGroup.icons[0]);
                iconGroup.group.add(iconGroup.icons[1]);
            }
            iconGroup.insertIcons = false;
        }
    }
}

function updateIcons(iconGroup, progress:Float)  {
    if (progress == 0)
        return;
    var iconInterp = iconGroup.interp.color;
    for(i => icon in iconGroup.group.members) {
        iconInterp.color = icon.color; // same as icon.shader.color
        iconInterp.lerpTo(i == 0 ? iconGroup.shadeColor : FlxColor.WHITE, progress);
        icon.scale.x = icon.scale.y = FlxMath.lerp(icon.scale.x, i == 0 ? 0.7 : .9, FlxMath.bound(progress * 2, 0 ,1));
        icon.offset.x = FlxMath.lerp(icon.offset.x, i == 0 ? 50 : 0, FlxMath.bound(progress * 2, 0 ,1));
        icon.offset.y = FlxMath.lerp(icon.offset.y, (i == 0 ? 20 : -5) + 10, FlxMath.bound(progress * 2, 0 ,1));
        icon.color = iconInterp.color;
    }
}