var drainTimer:Float = 0;
var drainEnabled:Bool = true;
public var drainAmount:Float = 1.2;

function update(elapsed:Float) {
    if (drainEnabled && drainTimer > 0) {
        if (health >= 0.15) health -= 0.05 * (drainAmount * ((__script__.interp.publicVariables.exists("didDamage") && didDamage) ? .65 : 1)) * elapsed;
        drainTimer -= elapsed;
    }
}

function onDadHit()  {
    if (!FlxG.save.data.mechanics) return;
    drainTimer += .12;
}

public function enableDrain() {
    if (!FlxG.save.data.mechanics) return;
    drainEnabled = true;
    drainTimer = 0;
}

public function disableDrain() {
    if (!FlxG.save.data.mechanics) return;
    drainEnabled = false;
    drainTimer = 0;
}

public function changeDrainAmount(salpha:String) {
    if (!FlxG.save.data.mechanics) return;
    var falpha = Std.parseFloat(salpha);
    drainAmount = falpha;
}