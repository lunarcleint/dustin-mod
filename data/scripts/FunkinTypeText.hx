// jank -lunar

import StringTools;
import EReg;

static function newFunkinTypeText(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
	var textObj:Dynamic = {
		delay: 0.04,
		isTyping: false,
		eventsCallbacks: [
			"pause" => function(txt, param) {
				txt.delay = Std.parseFloat(param);
			},
			"changeDelay" => function(txt, param) {
				txt._realDelay = Std.parseFloat(param);
			},
			"changePitchModule" => function(txt, param) {
				txt.pitchModule = Std.parseFloat(param);
			},
			"changeSound" => function(txt, param) {
				txt.sound = FlxG.sound.load(Paths.sound(StringTools.replace(param, ".", "/")));
			}
		],
		completeCallback: null,

		sound: null,
		defaultSound: null,
		excludeKeys: [" ", "*", "\n"],
		
		_finalText: "",
		_curLength: 0,
		_timer: 0,
		_realDelay: 0,

		pitchModule: 0,
		defaultPitchModule: 0,

		start: (newDelay:Float, textObj:Dynamic) -> {
			textObj.pitchModule = textObj.defaultPitchModule;
			textObj.sound = textObj.defaultSound;
			textObj.delay = newDelay != null ? newDelay : textObj.delay;
			textObj._realDelay = textObj.delay;
			textObj.isTyping = true;
		},
		resetText: (newText:String, textObj:Dynamic) -> {
			textObj.flxtext.text = "";
			textObj._finalText = newText;
			textObj._curLength = 0;
			textObj._timer = 0;
		},
		skip: (textObj:Dynamic) -> {
			textObj.delay = textObj._realDelay;
			textObj._curLength = textObj._finalText.length;
			for (i in textObj.regexMatch(textObj._finalText, new EReg("\\/([^\\/]+)\\/", "")))
				textObj._finalText = StringTools.replace(textObj._finalText, "/" + i + "/", "");
			textObj.flxtext.text = textObj._finalText;
		},
		regexMatch: (str:String, regex:EReg) -> {    
			var matches:Array<String> = [];
			while (regex.match(str)) {
				matches.push(regex.matched(1));
				str = regex.matchedRight();
			}
		
			return matches;
		},
		flxtext: null,
	};

	textObj.flxtext = textCrispy(new FlxText(X, Y, FieldWidth, Text, Size, EmbeddedFont));
	textObj._finalText = textObj.flxtext.text;
	textObj.flxtext.text = "";

	return textObj;
}

static function updateFunkinTypeText(elapsed:Float, textObj:Dynamic) {
	textObj._timer += elapsed;
	if (textObj.isTyping) {
		if (textObj._timer > textObj.delay) {
			if (textObj._curLength < textObj._finalText.length) {
				textObj.delay = textObj._realDelay;
				if (textObj._finalText.charAt(textObj._curLength) == "/" && !StringTools.contains(textObj._finalText, "https://")) {
					var events = textObj._finalText.substring(textObj._curLength + 1, textObj._finalText.indexOf("/", textObj._curLength + 1));
					
					for (i in events.split(",")) {
						var eventName = i.substring(0, i.indexOf("(") != -1 ? i.indexOf("(") : i.length);
						var eventParam = i.indexOf("(") != -1 ? i.substring(i.indexOf("(") + 1, i.length - 1) : null;
						if (textObj.eventsCallbacks[eventName] != null) textObj.eventsCallbacks[eventName](this, eventParam);
					}

					textObj._finalText = StringTools.replace(textObj._finalText, "/" + events + "/", "");
					return;
				}
				textObj.flxtext.text += textObj._finalText.charAt(textObj._curLength);
				if (textObj.sound != null && !textObj.excludeKeys.contains(textObj._finalText.charAt(textObj._curLength))) {
					textObj.sound.pitch = FlxG.random.float(1-textObj.pitchModule, 1+textObj.pitchModule);
					textObj.sound.play(true);
				}

				textObj._curLength++;
				textObj._timer = 0;
			}
			else {
				textObj.isTyping = false;
				textObj._timer = 0;
				if (textObj.completeCallback != null) textObj.completeCallback();
				textObj.completeCallback = null;
			}
		}
	}
}
