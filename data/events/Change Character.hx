var preloadedCharacters:Map<String, Character> = [];

function postCreate() {
    for (event in PlayState.SONG.events)
        if (event.name == "Change Character" && !preloadedCharacters.exists(event.params[1])) {
            // Look for character that alreadly exists
            /*var foundPreExisting:Bool = false;  // sorry lunar but this can lead to several bugs and kinda breaks easily since youre not copying the character but literally stealing it  - Nex
            for (strum in strumLines)
                for (char in strum.characters)
                    if (char.curCharacter == event.params[1]) {
                        preloadedCharacters.set(event.params[1], char);
                        graphicCache.cache(Paths.image("icons/" + char.getIcon()));
                        foundPreExisting = true; break;
                    }
            if (foundPreExisting) continue;*/

            // Create New Character
            var strumLine = strumLines.members[event.params[0]];
            var oldCharacter = strumLine.characters[0];
            var newCharacter = new Character(oldCharacter.x, oldCharacter.y, event.params[1], stage.isCharFlipped(event.params[1], oldCharacter.isPlayer));
            stage.applyCharStuff(newCharacter, strumLine.data.position == null ? (switch(strumLine.data.type) {
				case 0: "dad";
				case 1: "boyfriend";
				case 2: "girlfriend";
			}) : strumLine.data.position, 0);
            newCharacter.active = newCharacter.visible = false;
            newCharacter.drawComplex(FlxG.camera); // Push to GPU
            preloadedCharacters.set(event.params[1], newCharacter);
            graphicCache.cache(Paths.image("icons/" + newCharacter.getIcon()));
        }
}

//var offs:Array<Float> = [icon.offset.x, icon.offset.y];

function reloadHealthBar(character:Character, charIdx:Int, charPosName:String) {
	// DUSTIN' CODES
	var icon:HealthIcon = charPosName == "boyfriend" ? dustiniconP1 : dustiniconP2;
	var iconName:String = character.getIcon();
	icon.loadGraphicFromSprite(createHealthIcon(iconName, charPosName == "boyfriend"));
    icon.updateHitbox();
	updateIconXml(icon, iconName);

	if (healthBarColors != null && Options.colorHealthBar && boyfriend.iconColor != null && dad.iconColor != null) {
		var i:Int = (charPosName == "boyfriend") != PlayState.opponentMode ? 1 : 0;
		ogHealthColors[i] = healthBarColors[i] = character.iconColor;
	}


	// ORIGINAL VANILLA CODES
	/*
	var icon:HealthIcon = charPosName == "boyfriend" ? iconP1 : iconP2;
	var prevAnim:Int = icon.animation.curAnim.curFrame;
	icon.setIcon(character.getIcon());
	icon.animation.curAnim.curFrame = prevAnim;

	if (Options.colorHealthBar && boyfriend.iconColor != null && dad.iconColor != null) {
		if (PlayState.opponentMode) healthBar.createFilledBar(boyfriend.iconColor, dad.iconColor);
		else healthBar.createFilledBar(dad.iconColor, boyfriend.iconColor);
		healthBar.updateBar();
	}
	*/
}

function onEvent(_) {
    var params:Array = _.event.params;
    if (_.event.name == "Change Character") {
        // Change Character
        var oldCharacter = strumLines.members[params[0]].characters[0];
        var newCharacter = preloadedCharacters.get(params[1]);  // ehhh this breaks if there were two same preloaded character, for now its not an issue though  - Nex
        if (oldCharacter.curCharacter == newCharacter.curCharacter) return;


        var strumLine:StrumLine = strumLines.members[params[0]];
		var char:String = params[1], charIdx:Int = FlxMath.wrapMax(params[2], strumLine.characters.length - 1);
        var charPosName:String = strumLine.data.position == null ? (switch(strumLine.data.type) {
            case 0: "dad";
            case 1: "boyfriend";
            case 2: "girlfriend";
        }) : strumLine.data.position;

        insert(members.indexOf(oldCharacter), newCharacter);
        newCharacter.active = newCharacter.visible = true; newCharacter.alpha = 1;
        remove(oldCharacter);

        if (stage.characterPoses[params[1]] == null) newCharacter.setPosition(oldCharacter.x, oldCharacter.y);
        if (newCharacter.hasAnim(oldCharacter.getAnimName())) newCharacter.playAnim(oldCharacter.getAnimName(), true, oldCharacter.lastAnimContext, false, oldCharacter.animation?.curAnim?.curFrame);
        strumLines.members[params[0]].characters[0] = newCharacter;

        // Change Icon
        if (params[0] <= 1) {
            reloadHealthBar(newCharacter, params[0], charPosName);
        }   
    }
}