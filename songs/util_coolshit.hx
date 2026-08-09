//
static var hudElements:Array<FlxBasic> = [];
static var camHUD2:FlxCamera = null;
static var safetyCam:FlxCamera = null; // for epilepsy

public var dustinPauseScript:Null<String> = null;

function create() {
    downscroll = Options.downscroll;
    hudElements = []; allowGitaroo = false;
    PauseSubState.script = "data/states/UndertalePause.hx";
    GameOverSubstate.script = "data/scripts/gameOverUndertale";
    camHUD2 = new FlxCamera();
    camHUD2.bgColor = 0x00000000;
    camHUD2.visible = true;
    FlxG.cameras.add(camHUD2, false);

    var metaColor = PlayState.SONG.meta.customValues.color;
}

function postCreate() {
    insert_camera(safetyCam = new FlxCamera(), FlxG.cameras.list.indexOf(PlayState.instance.scripts.publicVariables.get("videoCam") != null ? videoCam : camHUD), false);
    safetyCam.bgColor = FlxColor.BLACK;
    safetyCam.alpha = 0;
}

function update(elapsed:Float) {
    camHUD2.visible = true;
    for (strumLine in strumLines) {
        strumLine.notes.forEachAlive(function (note:Note) {
            note.alpha = strumLine.members[note.noteData%4].alpha * (note.isSustainNote ? 0.6 : 1);
            if (note.health != -1) note.angle = strumLine.members[note.noteData%4].angle;
        });
    }
}

// cause sojas flixel is brainrot
public function insert_camera(newCamera:FlxCamera, position:Int, defaultDrawTarget = true):T {
    if (position < 0)
        position += FlxG.cameras.list.length;
    
    if (position >= FlxG.cameras.list.length)
        return FlxG.cameras.add(newCamera);
    
    final childIndex = FlxG.game.getChildIndex(FlxG.cameras.list[position].flashSprite);
    FlxG.game.addChildAt(newCamera.flashSprite, childIndex);
    
    FlxG.cameras.list.insert(position, newCamera);
    if (defaultDrawTarget)
        FlxG.cameras.defaults.push(newCamera);
    
    for (i in position...(FlxG.cameras.list.length))
        FlxG.cameras.list[i].ID = i;
    
    FlxG.cameras.cameraAdded.dispatch(newCamera);
    return newCamera;
}

function draw(e) {
    FlxG.camera.zoom = Math.floor(FlxG.camera.zoom * 10000) / 10000;
    camHUD.zoom = Math.floor(camHUD.zoom * 10000) / 10000;
}

function onEvent(eventEvent) {
    var params:Array = eventEvent.event.params;
    switch(eventEvent.event.name) {
        case "Scroll Speed Change" || "Change Scroll Speed":
            if (!FlxG.save.data.scrollSpeedChange) eventEvent.cancel(true);
        case "Camera Flash":
            if( FlxG.save.data.antiFlash) {
                eventEvent.cancel(true);
                eventEvent.event.params[1] = FlxColor.GRAY;
                var time:Float = eventEvent.event.params[2];
                if((Conductor.stepCrochet / 1000) * time < 0.5)
                    time = 0.5 / (Conductor.stepCrochet / 1000);

                var cam:FlxCamera = eventEvent.event.params[3] == "camHUD" ? camHUD : camGame;
                

            }
    }
}