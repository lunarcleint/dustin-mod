public var bone:FlxSprite = new FlxSprite(0, FlxG.height);
bone.alive = false;
public var boneAppear(default, set):Bool = false;
function set_boneAppear(value:Bool) {
    bone.animation.play((health == maxHealth) ? "appear" : (value ? "appear" : "dissapear"), true);
    bone.alive = value;
    return boneAppear = value;
}
public var boneHealthLimit:Float = 0.55;

var boneYOff:Float = (camHUD.downscroll ? -20 : -15);
public var boneFollowHealth:Bool = true;

public function insertBone() {
    insert(members.indexOf(dustiniconP1), bone);
    hudElements.push(bone);
    if(__script__.interp.publicVariables.exists("onDirectionChangePost"))
        onDirectionChangePost.push(directionChange);
    centerBone();
}

bone.frames = Paths.getFrames("game/mechanics/bone_assets");
bone.animation.addByPrefix("idle", "bone idle", 24, false);
bone.animation.addByPrefix("appear", "bone appear", 24, false);
bone.animation.addByPrefix("dissapear", "bone dissapear", 24, false);
bone.animation.play("dissapear", true);
bone.animation.finish();

bone.camera = camHUD;

bone.antialiasing = Options.antialiasing;
bone.flipY = camHUD.downscroll;

bone.y -= bone.height + boneYOff;

function update(elapsed) {
    if(bone.alive) {
        centerBone();
        if(__script__.interp.publicVariables.exists("hudY"))
            bone.y = hudY + hudOffY + boneYOff;
        if(health > (maxHealth * boneHealthLimit)) {
            if (FlxG.save.data.mechanics)
                health -= 0.1 * elapsed;
            if(bone.animation.name == "dissapear")
                bone.animation.play("appear");
            else if(bone.animation.name != "appear" || bone.animation.finished)
                bone.animation.play("idle", false);
        }
    }
}

function onPlayerHit(_) {
    if(FlxG.save.data.mechanics && bone.alive)
        _.healthGain *= 0.75;
}

function centerBone() {
    var precentWidth:Float = dustinHealthBar.width * Math.abs(1-(healthPrecent/100));
    bone.x = healthBar.x + precentWidth - (bone.width / 2) - 25;
}

function directionChange(direc:Bool) {
    bone.flipY = (direc ? !Options.downscroll : Options.downscroll);
    boneYOff = direc ? (camHUD.downscroll ? -115 : -95): (camHUD.downscroll ? -20 : -15);
}