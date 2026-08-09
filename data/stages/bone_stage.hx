//
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

public var bloom_new:CustomShader;
public var bg_char:FlxSprite;

function create() {
    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 100; bloom_new.brightness = 1.1;
    bloom_new.directions = 16; bloom_new.quality = 5;
    bloom_new.threshold = .85;

    if (Options.gameplayShaders && FlxG.save.data.bloom) FlxG.camera.addShader(bloom_new);

    strumLines.members[2].characters[0].visible = false;
    strumLines.members[3].characters[0].visible = false;

    bg_char = stage.stageSprites["bg_char"];

    for (object in [tenna, strumLines.members[3].characters[0], strumLines.members[2].characters[0], lights, bg_char]) {
        remove(object);
    }

    insert(members.indexOf(room), tenna);
    insert(members.indexOf(tenna), strumLines.members[3].characters[0]);
    insert(members.indexOf(boyfriend)+1, strumLines.members[2].characters[0]);
    insert(members.indexOf(strumLines.members[2].characters[0])+1, lights);
    insert(members.indexOf(lights)+1, bg_char);

}

function postCreate() {
    if (Options.gameplayShaders) {
        if (FlxG.save.data.saturation) {
            videoCam.addShader(contrast);
            videoCam.addShader(saturation);
        }
        if (FlxG.save.data.bloom) videoCam.addShader(bloom_new);
    }
}