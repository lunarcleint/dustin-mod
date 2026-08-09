//

function stepHit(step:Int) {
    switch(step) {
        case 114:
            FlxTween.num(0, 0.65, (Conductor.stepCrochet / 1000) * 14, {ease: FlxEase.sineIn}, function(num) {
                safetyCam.alpha = num;
            });
        case 128:
            FlxTween.num(0.65, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineOut}, function(num) {
                safetyCam.alpha = num;
            });
        case 148:
            FlxTween.num(0, 0.65, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineIn}, function(num) {
                safetyCam.alpha = num;
            });
        case 165:
            FlxTween.num(0.65, 0, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.sineOut}, function(num) {
                safetyCam.alpha = num;
            });
    }
}