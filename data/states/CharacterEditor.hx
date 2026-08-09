import funkin.backend.system.FakeCamera.FakeCallCamera;
import funkin.editors.character.CharacterGhost;
import flixel.animation.FlxAnimation;

using StringTools;

//meant to help with offseting for the new atlas versions of the original sprites
var enabled:Bool = false;
var songPath:String = "";
var charName:String = "papyrus_lyrics";
var forceAnimation = "1"; // leave null if you don't want this
var ghostsLength:Int;
var old_character;

function postCreate() {
    if (enabled) {
        old_character = new Character(0,0, charName, false, false);
		old_character.debugMode = true;
		old_character.cameras = [charCamera];
        add(old_character);

        if (stage == null) {
            changeisPlayer(character.isPlayer);
        } else {
            if (stage.characterPoses.exists(stagePosition))
			    stage.characterPoses[stagePosition].revertCharacter(old_character);

            changeisPlayer(character.isPlayer);
            changeStagePos(stagePosition);
        }
    }
    trace(characterGizmo.character.sprite);
}

function changeisPlayer(player:Bool) {
    if (old_character.__swappedLeftRightAnims)
        old_character.swapLeftRightAnimations();
    if (old_character.isPlayer) 
        old_character.flipX = !old_character.__baseFlipped;

    old_character.isPlayer = player;
    old_character.fixChar(false, false);
}

function changeStagePos(pos:String) {
    remove(old_character);
    if (stage.characterPoses.exists(stagePosition))
        stage.applyCharStuff(old_character, stagePosition, 0);
}

var index = -1;
function update(elapsed) {
    if (songPath != (songPath = characterGizmo.character.sprite.split("/")[0])) {
        FlxG.sound.music.stop();
        playMusic('gameovers/' + songPath, 0.35);
        if (FlxG.sound.music == null)
            playMusic("mainMenu", 0.35);
        FlxG.sound.music?.pitch = 0.9;
    }

    if (enabled && FlxG.keys.justPressed.SPACE) {
        if (forceAnimation != null)
            old_character.playAnim(forceAnimation, true);
    }

}