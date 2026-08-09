//
var _itslikeprettywarpedtoo:CustomShader = null;
function add_abberation() if (Options.gameplayShaders && FlxG.save.data.chromwarp) camGame.addShader(_itslikeprettywarpedtoo);
function remove_abberation() if (Options.gameplayShaders && FlxG.save.data.chromwarp) camGame.removeShader(_itslikeprettywarpedtoo);

function postCreate() {
    if (!Options.gameplayShaders) {
        disableScript();
        return;
    }

    _itslikeprettywarpedtoo = new CustomShader("chromaticWarp");
}

function update()
    _itslikeprettywarpedtoo.distortion = (stage.stageScript.get("stageLerp") - 1) / 1.3;