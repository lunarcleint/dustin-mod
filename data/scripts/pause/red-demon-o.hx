//

function onPause(parent, event) {
    if(!Options.gameplayShaders)
		return;
    var fillShader = PlayState.instance.scripts.publicVariables.get("fillShader");
    var impactShader = new CustomShader("impact_frames_col");
    impactShader.impactCol = impactShader.impactCol;
    impactShader.threshold = 0.22;
    parent.get("heart").shader = impactShader;
    parent.get("character").shader = impactShader;
}