// funny script that makes Red Demon O unlockable  - Nex
import funkin.backend.MusicBeatState;
import funkin.backend.chart.Chart;

var step = 0;

function postUpdate() {  // To finish this once we have the freeplay ready  - Nex
    var one = FlxG.keys.justPressed.ONE;
    var seven = FlxG.keys.justPressed.SEVEN;
    if (!one && !seven) return;

    if (step < 2 ? one : seven) {
        trace(step < 2 ? "one" : "seven");
        step++;

        if (step == 3) {
            var diffs = Chart.loadChartMeta("red-demon-o").difficulties;
            PlayState.loadSong("red-demon-o", diffs[diffs.length - 1]);
            MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
            FlxG.resetState();
        }
    } else {
        trace("wrong:kys:");
        step = 0;
    }
}