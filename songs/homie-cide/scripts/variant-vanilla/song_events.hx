//
var strumShiftAmount:Float = -320;
var strumsShifted:Bool = false;

function create() {
    doHealthbarFade = false;
}

function postCreate() {
    executeEvent({
        name: "Screen Coverer",
        time: Conductor.songPosition,
        params: [false, 0xFF000000, 1, 4, "linear", "In", "camHUD", "front"]
    });

    FlxG.cameras.remove(videoCam, false);
    FlxG.cameras.add(videoCam, false);

}

function stepHit(step:Int) {
    switch(step) {
        case 2692:
            FlxG.cameras.remove(videoCam, false);
            insert_camera(videoCam, FlxG.cameras.list.indexOf(camHUD), false);
        case 2272:
            shiftStrums();
        case 2872:
            FlxTween.tween(camHUD, {alpha: 0}, 2.25, {ease: FlxEase.quadOut});
    }
}

function shiftStrums():Void {
    var shift = strumsShifted ? -strumShiftAmount : strumShiftAmount;
    var tweenTime = 2;
    var tweensLeft = 0;


    for (strumLine in strumLines) {
        for (sprite in strumLine.members) {
            if (sprite != null) {
                tweensLeft++;
                FlxTween.tween(sprite, {x: sprite.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }

        for (note in strumLine.notes) {
            if (note != null) {
                tweensLeft++;
                FlxTween.tween(note, {x: note.x + shift}, tweenTime, {
                    ease: FlxEase.quadOut,
                });
            }
        }
    }

            FlxTween.tween(scoreTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(accuracyTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(missesTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBG, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP1, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(dustiniconP2, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeBarBG, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeBar, {alpha: 1}, 3, {ease: FlxEase.quadOut});
            FlxTween.tween(timeTxt, {alpha: 1}, 3, {ease: FlxEase.quadOut});

            for (strum in playerStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: 0.8}, 3, {ease: FlxEase.quadOut});

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    FlxTween.tween(note, {alpha: 0.8}, 3, {ease: FlxEase.quadOut});

    strumsShifted = !strumsShifted;
}
