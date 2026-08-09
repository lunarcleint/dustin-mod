function postCreate() {
    playerStrums.cpu = true;
    canPause = false;
}

function onSongStart() {
    new FlxTimer().start(0.0001, function() {
        updateSpeed(15);
        inst.onComplete = end;
    });
}

function stepHit(step:Int) {
    switch(step) {
        case 1216:
            FlxTween.num(2.5, 0.5, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1222:
            FlxTween.num(0.5, 1.2, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1226:
            FlxTween.num(1.2, 0.9, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1232:
            FlxTween.num(0.9, 1.1, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1240:
            FlxTween.num(1.1, 0.8, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1246:
            FlxTween.num(0.8, 1.2, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1250:
            FlxTween.num(1.2, .9, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1258:
            FlxTween.num(.9, 1.3, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1264:
            FlxTween.num(1.3, 1.5, 1, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1269:
            FlxTween.num(1.5, 4, 5, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1930:
            FlxTween.num(4, .9, 2, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1950:
            FlxTween.num(.9, 1.25, 2, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1960:
            FlxTween.num(1.25, .8, 2, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1975:
            FlxTween.num(.8, 1.3, 2, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 1995:
            FlxTween.num(1.3, 3.5, 4, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
        case 2268:
            FlxTween.num(1, .5, 2, {ease: FlxEase.sineOut}, (val:Float) -> {inst.volume = val;});
            FlxTween.num(1.3, .8, 2, {ease: FlxEase.sineOut}, (val:Float) -> {updateSpeed(val);});
    }
}

function updateSpeed(speed:Float) {
    FlxG.timeScale = speed; inst.pitch = speed; vocals.pitch = speed;
    for (strumLine in strumLines.members) strumLine.vocals.pitch = speed;
}

function end() {
    FlxG.timeScale = .8;
    bazinga();
}