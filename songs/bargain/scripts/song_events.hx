//

function postCreate() {
    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    FlxG.cameras.remove(videoCam, false);
    FlxG.cameras.add(videoCam, false);
}

function onSongStart() {
    preloadedVideos["bargain"].antialiasing = false; // as brainrot as possible - lunar
}