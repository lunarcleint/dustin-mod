import funkin.editors.charter.Charter;

var hudTween:FlxTween;

function onEvent(eventEvent) {
    var params:Array = eventEvent.event.params;
    if (eventEvent.event.name == "New Change HUD Alpha") {
        var targetAlpha:Float = params[1];
        var duration:Float = ((Conductor.crochet / 4) / 1000) * params[2];
        var flxease:String = params[3] + (params[3] == "linear" ? "" : params[4]);
        var easeFunc = Reflect.field(FlxEase, flxease);

        // Custom elements array
        var customUI:Array<FlxSprite> = [
            dustinHealthBG, dustinHealthBar,
            dustiniconP1, dustiniconP2,
            timeBarBG, timeTxt, timeBar
        ];

        if (params[0] == false || (PlayState.chartingMode && Charter.startHere && eventEvent.event.time < Charter.startTime)) {
            // Set alpha directly
            healthBar.alpha = targetAlpha;
            healthBarBG.alpha = targetAlpha;
            iconP1.alpha = targetAlpha;
            iconP2.alpha = targetAlpha;
            scoreTxt.alpha = targetAlpha;
            accuracyTxt.alpha = targetAlpha;
            missesTxt.alpha = targetAlpha;

            for (element in customUI)
                element.alpha = targetAlpha;

            for (strum in playerStrums.members)
                if (strum != null) strum.alpha = targetAlpha;

            for (strum in cpuStrums.members)
                if (strum != null) strum.alpha = targetAlpha;

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    note.alpha = targetAlpha;

        } else {
            // Tween alpha
            if (hudTween != null) hudTween.cancel();

            hudTween = FlxTween.tween(healthBar, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(healthBarBG, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(iconP1, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(iconP2, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(scoreTxt, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(accuracyTxt, {alpha: targetAlpha}, duration, {ease: easeFunc});
            FlxTween.tween(missesTxt, {alpha: targetAlpha}, duration, {ease: easeFunc});

            for (element in customUI)
                FlxTween.tween(element, {alpha: targetAlpha}, duration, {ease: easeFunc});

            for (strum in playerStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: targetAlpha}, duration, {ease: easeFunc});

            for (strum in cpuStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: targetAlpha}, duration, {ease: easeFunc});

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    FlxTween.tween(note, {alpha: targetAlpha}, duration, {ease: easeFunc});
        }
    }
}
