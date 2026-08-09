import flixel.FlxCamera;
import flixel.FlxG;
import hxvlc.flixel.FlxVideoSprite;

var vid:FlxVideoSprite;
var vidCam:FlxCamera;

function postCreate() {
    vidCam = new FlxCamera();

    for (dih in ["bgColor", "zoom", "alpha", "angle", "color", "visible", "x", "y"]) Reflect.setField(vidCam, dih, Reflect.field(camHUD, dih));
    vidCam.setSize(camHUD.width, camHUD.height);


    FlxG.cameras.add(vidCam, false);
    vid = new FlxVideoSprite();
    vid.load(Assets.getPath(Paths.video('bargain', 'mkv')));
    vid.scale.set(FlxG.width / 1920, FlxG.height / 1080);
    vid.x = FlxG.width / 2 - 1920 / 2;
    vid.y = FlxG.height / 2 - 1080 / 2;
    vid.camera = vidCam;
    add(vid);

    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

}


function stepHit(step:Int) {
    if (step == 1) {
        vid.play();
    }

    if (step == 156) {
        vid.visible = false;
    }
}
