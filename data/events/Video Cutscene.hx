//
import hxvlc.flixel.FlxVideoSprite;

import funkin.editors.charter.Charter;

public var videoCam:FlxCamera;
public var curVideo:FlxVideoSprite;
public var preloadedVideos:Map<String, FlxVideoSprite> = [];

var needVideoFix:Bool = false;
var camShouldHideInStart:Bool = false;

var camWasVisible:Bool = true;
function getCamVisible() return camWasVisible; // scope/thread-unsafety fix

function onStartCountdown(e) {
	if (!camShouldHideInStart) return;

	if (camWasVisible == null) camWasVisible = camGame.visible;
	camGame.visible = false;
}

function preloadVideos() {
	for (event in PlayState.SONG.events) {
		if (event.name != "Video Cutscene") continue;

		var video = preloadedVideos.get(event.params[0]);
		if (video != null) {
			video.ID++;
			continue;
		}

		if (event.time <= 0) camShouldHideInStart = true;

		video = new FlxVideoSprite();
		video.bitmap.onFormatSetup.add(() -> {
			if (video.bitmap == null || video.pixels == null) return;

			final scale = Math.min(FlxG.width / video.pixels.width, FlxG.height / video.pixels.height);
			video.scale.set(scale, scale);
			video.updateHitbox();
		});

		// HXVLC <2.0.0 have janky auto pause handler & weird volume scaling (in CNE v1.0.1 and below)
		try {
			video.autoPause = false;
			video.autoVolumeHandle = false;
			needVideoFix = true;
		} catch (e:Any) {}

		video.antialiasing = Options.antialiasing;
		video.camera = videoCam;
		video.ID = 1;

		video.load(Assets.getPath(Paths.video(event.params[0], event.params[1])));
		video.play();
		video.pause();
		video.bitmap.time = 0;

		preloadedVideos.set(event.params[0], video);

		video.bitmap.onEndReached.add(() -> {
			curVideo = null;
			remove(video);

			if (--video.ID <= 0) {
				video.bitmap?.dispose();
				video.destroy();
			}

			var temp = getCamVisible();
			if (temp != null) camGame.visible = temp;
		});
	}
}

function create() {
	videoCam = new FlxCamera(0, 0);
	videoCam.bgColor = 0x00000000;
	insert_camera(videoCam, FlxG.cameras.list.indexOf(camHUD) - 1, false);

	preloadVideos();
}

function update(elapsed:Float) {
	persistentUpdate = false;

	if (needVideoFix && curVideo != null && !curVideo.autoVolumeHandle && curVideo.bitmap != null) {
		final volume = Math.floor(Math.pow(curVideo.getCalculatedVolume(), 0.333) * 100.0);
		if (curVideo.bitmap.volume != volume) curVideo.bitmap.volume = volume;
	}
}

function onEvent(e) {
	if (e.event.name != "Video Cutscene") return;

	final event = e.event;
	if (PlayState.chartingMode && Charter.startHere && event.time < Charter.startTime) return;

	if (curVideo != null) {
		curVideo.stop();
		curVideo.onEndReached.dispatch();
	}

	curVideo = preloadedVideos.get(event.params[0]);
	if (curVideo == null || curVideo.bitmap == null) return;

	insert(members.length, curVideo);

	if (curVideo.bitmap.time != 0) curVideo.bitmap.time = 0;
	curVideo.resume();

	if (camWasVisible == null) camWasVisible = camGame.visible;
	camGame.visible = false;
}

function onGamePause(e) {
	if (curVideo != null) curVideo.pause();
}

function onSubstateClose(e) {
	if (curVideo != null) curVideo.resume();
}

function onFocusLost() {
	if (!needVideoFix || !Options.autoPause || paused) return;
	if (curVideo != null) curVideo.pause();
}

function onFocus() {
	if (!needVideoFix || !Options.autoPause || paused) return;
	if (curVideo != null) curVideo.resume();
}

function destroyVideos() {
	curVideo = null;

	for (name => vid in preloadedVideos) {
		if (vid != null) {
			vid.bitmap?.dispose();
			vid.destroy();
		}
	}
	FlxG.signals.preStateSwitch.remove(destroyVideos);
}

FlxG.signals.preStateSwitch.add(destroyVideos); // destroy doesn't get called in event scripts