/*import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

var scroll:FlxBackdrop = new FlxBackdrop(FlxG.bitmap.create(5, FlxG.height * .075, 0xFF245E26), FlxAxes.X, 100, 0);
var scrollBottom:FlxBackdrop = new FlxBackdrop(FlxG.bitmap.create(5, FlxG.height * .075, 0xFF245E26), FlxAxes.X, 100, 0);

function create() {
    for(i in [scroll, scrollBottom]) {
        i.scrollFactor.set();
        add(i);
    }

    scrollBottom.y = FlxG.height - scrollBottom.height;

    var spr:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 4, 0xFF4CAF4F);
    spr.y = 54 - spr.height;
    spr.scrollFactor.set();
    add(spr);

    var spr:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 4, 0xFF4CAF4F);
    spr.y = FlxG.height * .925;
    spr.scrollFactor.set();
    add(spr);
}

function update(elapsed:Float) {
    scroll.offset.x -= 25 * elapsed;
    scrollBottom.offset.x += 25 * elapsed;
}*/

import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;

var sprites:Array<FlxBackdrop> = [];

public function setGalleryCamera(cam:FlxCamera)
    camera = cam;

public function createGalleryBG() {
    for(i in 0...2) {
        var bone:FlxBackdrop = new FlxBackdrop(Paths.image("game/undertale/spr_s_bonewall_wide"), 0x01, -180);
        bone.color = 0xFF2C2C2C;
        bone.scrollFactor.set();
        bone.y = (FlxG.height - bone.height) * i;
        bone.y += 145 * (i == 0 ? -1 : 1);
        bone.scale.set(2, 2);
        bone.angle = 90;
        add(bone);

        bone.camera = camera;

        sprites.push(bone);

        var gradientSprite:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 70, [0x00000000, 0xA5000000], 1, 90, true);
        gradientSprite.antialiasing = Options.antialiasing;
        gradientSprite.flipY = i == 1;
        gradientSprite.y = (FlxG.height - gradientSprite.height) * i;
        gradientSprite.scrollFactor.set(0, 0);
        gradientSprite.updateHitbox();
        add(gradientSprite);
    }
}

function update(elapsed:Float) {
    if(sprites.length > 0) {
        sprites[0].offset.x -= 25 * elapsed;
        sprites[1].offset.x += 25 * elapsed;
    }
}