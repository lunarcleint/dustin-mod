//
import funkin.backend.system.RotatingSpriteGroup;
import flixel.text.FlxTextBorderStyle;
import funkin.game.ComboRating;

public var ratingScale:Float = 0.5;
public var ratingColor:FlxColor = null;
public var ratingsGroup:RotatingSpriteGroup;

function postCreate() {
    // I can see how it makes sense but the text could start clipping in the ratings
    comboBreaks = false;
    if (timeTxt != null) {
        ratingColor = fullColor;
        timeTxt.color = fullColor;
    }

    hitWindow *= .7; // UH OH STRICTER HIT REG
    for (txt in [scoreTxt, missesTxt, accuracyTxt]) {
        txt.setFormat(Paths.font("DTM-Mono.ttf"), 16, fullColor);

        txt.borderStyle = FlxTextBorderStyle.OUTLINE;
        txt.borderSize = 2;
        txt.borderColor = 0xFF000000;

        textCrispy(txt);

        hudElements.push(txt);
    }
    scoreTxt.x -= 50;
    missesTxt.x += 10;
    accuracyTxt.x += 10;

    comboRatings = [
		new ComboRating(0, "F", 0xFFFF4444),
		new ComboRating(0.5, "E", 0xFFFF8844),
		new ComboRating(0.7, "D", 0xFFFFAA44),
		new ComboRating(0.8, "C", 0xFFFFFF44),
		new ComboRating(0.85, "B", 0xFFAAFF44),
		new ComboRating(0.9, "A", 0xFF88FF44),
		new ComboRating(0.95, "S", 0xFF44FFFF),
		new ComboRating(1, "=)", 0xFFFE3A3A),
	];

    ratingsGroup = new RotatingSpriteGroup();
    ratingsGroup.cameras = [camHUD];
    ratingsGroup.maxSize = 40;
    for (i in 0...ratingsGroup.maxSize)
        ratingsGroup.add(createRatingSprite());

    add(ratingsGroup);

    for (combo in comboGroup.members) combo.destroy();
    remove(comboGroup);

    for (strumLines in strumLines.members)
        for (strum in strumLines.members)
            hudElements.push(strum);
}

function onPlayerHit(_) {
    _.healthGain *= 0.75;
    _.showRating = false;

    if (_.note.extra["hurtNote"] != null) {
        _.countScore = false;
        _.preventStrumGlow();
        // I would count as a miss, but sometimes it counts it even if you hit a good note
        if (!(_.misses = !validHurtNoteHit(_.note))) {
            _.countScore = false;
            _.countAsCombo = false;
            _.forceAnim = false;
        } else {
            _.score = -10;
            _.healthGain = -0.04;
            _.animSuffix = "miss";
            _.forceAnim = true;
            _.note.strumLine.vocals.volume = 0;
            vocals.volume = 0;
            _.preventVocalsUnmute();
            FlxG.sound.play(Paths.sound(FlxG.random.getObject(Flags.DEFAULT_MISS_SOUNDS)), FlxG.random.float(0.1, 0.2));
            trace('oh shittings');
        }
        return;
    }
    var noteDiff = Math.abs(Conductor.songPosition - _.note.strumTime);
    if (noteDiff > hitWindow * 0.5)
        _.rating = 'shit';
    else if (noteDiff > hitWindow * 0.4)
        _.rating = 'bad';
    else if (noteDiff > hitWindow * 0.2)
        _.rating = 'good';
    _.showSplash = Options.splashesEnabled && !_.note.isSustainNote && _.rating == "sick";

    if (_.note.extra["overrideRating"] != null)
        _.rating = _.note.extra["overrideRating"];

    if (_.note.isSustainNote) return;
    ratingNum += 1;

    var comboRating:FlxSprite = ratingsGroup.recycleLoop(FlxSprite, createRatingSprite);
    comboRating.animation.play(_.rating, true);

    var strum:FlxSprite = _.note.strumLine.members[_.note.noteData%4];
    comboRating.x = (strum.x + strum.width/2)-comboRating.width/2; 
    comboRating.y = (strum.y + strum.height/2)-comboRating.height/2;
    comboRating.y += 80; comboRating.alpha = 1;

    comboRating.x += FlxG.random.float(4, 20) * FlxG.random.sign();
    comboRating.y += FlxG.random.float(4, 10) * FlxG.random.sign();

    var randomScale:Float = FlxG.random.float(ratingScale/2, ratingScale/1.425);
    comboRating.scale.set(randomScale, randomScale);

    comboRating.angle = FlxG.random.float(0, 6) * FlxG.random.sign();
    comboRating.velocity.set(); comboRating.acceleration.set();
    /*comboRating.color = 0xFFFFFFFF;*/ FlxTween.cancelTweensOf(comboRating);

    comboRating.velocity.x -= FlxG.random.int(0, 100) * FlxG.random.sign();
    if(ratingColor != null) comboRating.color = ratingColor;
    switch (_.rating) {
        case "sick":
            comboRating.scale.x *= .8; comboRating.scale.y *= .8;
            // FlxTween.color(comboRating, .2, 0xFF4EA34E, 0xFFFFFFFF, {ease: FlxEase.circInOut});
            var randomBigScale:Float = FlxG.random.float(1.3, 1.6); // snazzy ik ik -lunar
            FlxTween.tween(comboRating, {'scale.x': comboRating.scale.x*randomBigScale, 'scale.y': comboRating.scale.x*randomBigScale}, FlxG.random.float(.075, .125), {ease: FlxEase.circInOut, onComplete: (_) -> {
                FlxTween.tween(comboRating, {'scale.x': comboRating.scale.x*.4, 'scale.y': comboRating.scale.x*.4, alpha: 0, angle: FlxG.random.float(0, 30) * FlxG.random.sign()}, .1+FlxG.random.float(.175, .255), {ease: FlxEase.circInOut, onComplete: (_) -> {
                    comboRating.kill();
                }});
            }});
            comboRating.velocity.y += FlxG.random.int(140, 175) * .3;
        case "good":
            var randomBigScale:Float = FlxG.random.float(1.1, 1.3); // snazzy ik ik -lunar
            comboRating.scale.x *= randomBigScale; comboRating.scale.y *= randomBigScale;
            FlxTween.tween(comboRating, {'scale.x': comboRating.scale.x/4, 'scale.y': comboRating.scale.x/4, alpha: 0}, .1+FlxG.random.float(.3, .5), {ease: FlxEase.circInOut, onComplete: (_) -> {
                comboRating.kill();
            }});

            comboRating.acceleration.y = 100;
            comboRating.velocity.y += FlxG.random.int(140, 175) * .5;
        case "bad" | "shit":
            comboRating.acceleration.y = 550;
            comboRating.velocity.y += FlxG.random.int(140, 175) * (_.rating == "bad" ? 1.5 : 3);

            FlxTween.tween(comboRating, {alpha: 0, 'scale.x': comboRating.scale.x/2, 'scale.x': comboRating.scale.y/2}, FlxG.random.float(.45, .55)-(_.rating == "shit" ? .1 : 0), {ease: FlxEase.circInOut, onComplete: (_) -> {
                comboRating.kill();
            }});
            
    }
}

function onPlayerMiss(_) _.healthGain *= 2;

function createRatingSprite():FlxSprite {
    var comboSprite:FlxSprite = new FlxSprite();
    comboSprite.frames = Paths.getSparrowAtlas("game/ratings");
    comboSprite.animation.addByPrefix("bad", "bad", 1, true);
    comboSprite.animation.addByPrefix("shit", "shit", 1, true);
    comboSprite.animation.addByPrefix("good", "good", 1, true);
    comboSprite.animation.addByPrefix("sick", "sick", 1, true);
    comboSprite.animation.play("good", true);

    //comboSprite.scrollFactor.set();

    comboSprite.scale.set(ratingScale, ratingScale);
    comboSprite.updateHitbox();

    comboSprite.kill();
    
    return comboSprite;
}