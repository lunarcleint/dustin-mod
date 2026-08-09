// Script by JOSE JUAN

var startPos:Array<Float> = [];
var waveApplied:Bool = false;
var waveTime:Float = 0;
var waveStrength:Float = 0;
var waveSpeed:Float = 2.0;

function postCreate() {
    for (strum in strumLines) startPos.push(strum.members[0].y);
}

function stepHit(curStep:Int) {
    if (curStep == finalHours ? 1273 : 761) {
        waveApplied = true;
        waveSpeed = 2.0;
    } else if (curStep == finalHours ? 1415 : 889) {
        waveSpeed = 6.0;
    } else if (curStep == finalHours ? 1672 : 1107) {
        waveApplied = false;
    }
}

function update(elapsed:Float) {
    waveTime += elapsed;

    var fadeSpeed = 2.5;
    if (waveApplied) {
        waveStrength = Math.min(1, waveStrength + elapsed * fadeSpeed);
    } else {
        waveStrength = Math.max(0, waveStrength - elapsed * fadeSpeed);
    }

    for (a in 0...strumLines.length) {
        for (b in 0...strumLines.members[a].length) {
            var note = strumLines.members[a].members[b];
            var baseY = startPos[a];
            var offset = Math.sin(waveTime * waveSpeed + b) * 20 * waveStrength;
            note.y = baseY + offset;
        }
    }
}

