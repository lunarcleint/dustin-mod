//
importScript("data/scripts/DialogueBoxBG");

import flixel.FlxObject;
import flixel.math.FlxRect;

public var camUndertale:FlxCamera;
public var camBones:FlxCamera;
public var soulSprite:FlxSprite;
public var soulHitbox:FlxSprite;

public var battleBox:DialogueBoxBG;
var battleBoxColliderLeft:FlxObject;
var battleBoxColliderRight:FlxObject;
var battleBoxColliderUp:FlxObject;
var battleBoxColliderDown:FlxObject;

#if REGION
function create() {
    camUndertale = new FlxCamera(0, 0);
    camUndertale.bgColor = 0x00000000;
    camUndertale.pixelPerfectRender = true;
    FlxG.cameras.add(camUndertale, false);

    camBones = new FlxCamera(0, 0);
    camBones.bgColor = 0x00000000;
    camBones.pixelPerfectRender = true;
    camBones.rotateSprite = true;
    FlxG.cameras.add(camBones, false);
    
    soulSprite = new FunkinSprite().loadGraphic(Paths.image("game/undertale/spr_heart_0"));
	soulSprite.scale.set(1.5, 1.5);
    soulSprite.cameras = [camUndertale];
	soulSprite.updateHitbox();
	soulSprite.antialiasing = false;
    soulSprite.alpha = 0;

    battleBox = newDialogueBoxBG(0, 0, null, 270, 240, 8);
    battleBox.cameras = [camUndertale];
    battleBox.alpha = 0;

    battleBoxColliderLeft = new FlxObject();
    battleBoxColliderRight = new FlxObject();
    battleBoxColliderUp = new FlxObject();
    battleBoxColliderDown = new FlxObject();

    soulHitbox = new FlxSprite().makeSolid(16, 16, 0xFF00FF00);
    soulHitbox.cameras = [camUndertale]; soulHitbox.updateHitbox();
    soulHitbox.visible = false;

    add(battleBox);
	add(soulSprite);

    add(soulHitbox);

    for (collider in [battleBoxColliderLeft, battleBoxColliderRight, battleBoxColliderUp, battleBoxColliderDown]) {
        setup_collider(collider); collider.immovable = true;
    }
    
    setup_sfx();
}

public var idealBoxWidth:Int = 50;
public var idealBoxHeight:Int = 50;
var idealBoxAngle:Int = 0;
var idealBoxSpeed:Float = 1;

public function box_open_animation() {
    player.ghostTapping = true;
    undertaleUpdateActive = true;
    FlxTween.num(0, 1, 1, null, (val:Float) -> {
        soulSprite.alpha = Math.floor(val*10)/10;
    });

    battleBox.extra["bWidth"] = 50;
    battleBox.extra["bHeight"] = 50;
    battleBox.alpha = 1;

    idealBoxWidth = 270;
    idealBoxHeight = 240;
    idealBoxAngle = 0;

    battleBox.angle = 90;
}

public function box_close_animation() {
    FlxTween.num(1, 0, .2, null, (val:Float) -> {
        soulSprite.alpha = Math.floor(val*10)/10;
        soulSprite.immovable = true;
    });

    idealBoxWidth = 40;
    idealBoxHeight = 40;
    idealBoxAngle = 90;

    new FlxTimer().start(.67, function () {
        FlxTween.tween(battleBox, {alpha:0}, .4);
        undertaleUpdateActive = false;
        player.ghostTapping = Options.ghostTapping;
    });
}

var undertaleUpdateActive:Bool = false;
public function start_test_fight() {
    battleBox.x = FlxG.width/2 - battleBox.extra["bWidth"]/2;
    battleBox.y = FlxG.height*.525 - battleBox.extra["bHeight"]/2;

    update_battlebox();

    soulHitbox.x = battleBox.x + (battleBox.extra["bWidth"]/2 - soulHitbox.width/2);
    soulHitbox.y = battleBox.y + (battleBox.extra["bHeight"]/2 - soulHitbox.height/2);

    spawn_bonewalls();

    (new FlxTimer()).start(1, function () {
        FlxTween.num(0, 1, 3.1, {ease: FlxEase.circOut}, (val:Float) -> {
            boneAppearLeft = Math.floor(val*70)/70;
        });

        FlxTween.num(0, 1, 3.1, {ease: FlxEase.circOut, startDelay: 0.2}, (val:Float) -> {
            boneAppearRight = Math.floor(val*70)/70;
        });
    });

    FlxTween.num(0, 1, 1, null, (val:Float) -> {
        camHUD.bgColor = FlxColor.interpolate(0x00000000, 0x82000000, Math.floor(val*10)/10);
    });

    new FlxTimer().start(7, function () {
        spawn_gasterblaster(300, 280, -90, 2, 5);
        new FlxTimer().start(.6, function () {
            spawn_gasterblaster(960, 400, 90, 2, 5);
        });
    });

    new FlxTimer().start(9, function () {
        spawn_mttbomb(650 + FlxG.random.float(-30, 30), 400 + FlxG.random.float(-20, -100));
        spawn_mttbomb(600 + FlxG.random.float(-30, 30), 400 + FlxG.random.float(-20, -100));
        spawn_mttbomb(650 + FlxG.random.float(-30, 30), 350 + FlxG.random.float(-20, -100));
        spawn_mttbomb(600 + FlxG.random.float(-30, 30), 350 + FlxG.random.float(-20, -100));

        spawn_mttbomb(300 + 260, 520);
        spawn_mttbomb(340 + 260, 520);
        spawn_mttbomb(380 + 260, 520);
        spawn_mttbomb(420 + 260, 520);

        new FlxTimer().start(.6, function () {
            switch_soul_mode(SOUL_YELLOW);
        });
    });

    (new FlxTimer()).start(14, function () {
        switch_soul_mode(SOUL_RED);

        for (bomb in bombs) bomb.ID = 0; // mark to explode

        spawn_gasterblaster(160, 300, -90, 3.5, 30);

        FlxTween.num(1, 0, 3.1, {ease: FlxEase.circOut}, (val:Float) -> {
            boneAppearLeft = Math.floor(val*35)/35;
        });

        FlxTween.num(1, 0, 3.1, {ease: FlxEase.circOut, startDelay: 0.2}, (val:Float) -> {
            boneAppearRight = Math.floor(val*35)/35;
        });

        new FlxTimer().start(3, function () {
            box_close_animation();
        });

        FlxTween.num(1, 0, 3, null, (val:Float) -> {
            camHUD.bgColor = FlxColor.interpolate(0x00000000, 0x82000000, Math.floor(val*10)/10);
        });
    });

    box_open_animation();

}

public var SOUL_RED:Int = 0xFFFF0000;
public var SOUL_YELLOW:Int = 0xFFFFFF00;
public var SOUL_BLUE:Int = 0xFF003cfe;
var soulMode:Int = SOUL_RED;

public function switch_soul_mode(mode:Int) {
    soulSprite.flipY = mode == SOUL_YELLOW;
    soulSprite.colorTransform.color = mode;

    soulMode = mode;
}
#end

#if REGION
var SFX_VOLUME:Float = 1;

var snd_hurt1:FlxSound;
var snd_heartshot:FlxSound;
var snd_mtt_prebomb:FlxSound;
var snd_bomb:FlxSound;
var mus_sfx_segapower:FlxSound;
var mus_sfx_rainbowbeam_1:FlxSound;

function setup_sfx() {
    snd_hurt1 = new FlxSound().loadEmbedded(Paths.sound("undertale/snd_hurt1"));
    snd_hurt1.volume = 0.8 * SFX_VOLUME;

    snd_heartshot = new FlxSound().loadEmbedded(Paths.sound("undertale/snd_heartshot"));
    snd_heartshot.volume = 0.8 * SFX_VOLUME;

    snd_mtt_prebomb = new FlxSound().loadEmbedded(Paths.sound("undertale/snd_mtt_prebomb"), true);
    snd_mtt_prebomb.volume = 0.9 * SFX_VOLUME;

    snd_bomb = new FlxSound().loadEmbedded(Paths.sound("undertale/snd_bomb"));
    snd_bomb.volume = 0.9 * SFX_VOLUME;

    mus_sfx_segapower = new FlxSound().loadEmbedded(Paths.sound("undertale/mus_sfx_segapower"));
    mus_sfx_segapower.volume = 0.5 * SFX_VOLUME;
    mus_sfx_segapower.pitch =  1.2;

    mus_sfx_rainbowbeam_1 = new FlxSound().loadEmbedded(Paths.sound("undertale/mus_sfx_rainbowbeam_1"));
    mus_sfx_rainbowbeam_1.volume = 0.5 * SFX_VOLUME;
}

// everything else is okay its just THIS sound bro
function pause_sfx() 
    snd_mtt_prebomb.pause();

function resume_sfx()
    snd_mtt_prebomb.resume();
#end


public var MARKED_FOR_DELETION_NEXT_FRAME:Int = -928423; 

var undertaleFrameTime:Float = 1/30;
var undertaleFrameCounter:Float = 0;

var justPressedZ:Bool = false; // store outside of 30 fps update for obv reasons

function update(elapsed:Float) {
    camUndertale.visible = undertaleUpdateActive;
    if (!undertaleUpdateActive) return;

    if (!justPressedZ && FlxG.keys.justPressed.Z) justPressedZ = true;

    undertaleFrameCounter += elapsed;
    if (undertaleFrameCounter > undertaleFrameTime) {
        undertaleFrameCounter = 0;
        undertale_update(undertaleFrameTime);

        justPressedZ = false;
    }

    var i:Int = 0;
    while (i < members.length) {
        var member:FlxSprite = members[i];
        if (member != null && member.ID == MARKED_FOR_DELETION_NEXT_FRAME) {
            member.destroy();
            delete_damager(member.ID);
            remove(member);
        } else i++;
    }
}

var soulSpeed:Float = 5.89;

public var undertale_updates:Array<Float->Void> = [];
function undertale_update(elapsed:Float) {
    battleBox.extra["bWidth"] = FlxMath.lerp(battleBox.extra["bWidth"], idealBoxWidth, 1/6 * idealBoxSpeed);
    battleBox.extra["bHeight"] = FlxMath.lerp(battleBox.extra["bHeight"], idealBoxHeight, 1/6 * idealBoxSpeed);
    battleBox.angle = FlxMath.lerp(battleBox.angle, idealBoxAngle, 1/6 * idealBoxSpeed);

    battleBox.x = FlxG.width/2 - battleBox.extra["bWidth"]/2;
    battleBox.y = FlxG.height*.525 - battleBox.extra["bHeight"]/2;

    camBones.x = battleBox.x + battleBox.extra["border"] ; camBones.y = battleBox.y + battleBox.extra["border"]  - 1;
    camBones.width = battleBox.extra["bWidth"] - battleBox.extra["border"] ; camBones.height = battleBox.extra["bHeight"] - (battleBox.extra["border"] );

    camBones.angle = battleBox.angle;

    var sframeSpeed:Float = soulSpeed * (elapsed/undertaleFrameTime);

    if (FlxG.keys.pressed.LEFT) soulHitbox.x -= sframeSpeed;
    if (FlxG.keys.pressed.RIGHT) soulHitbox.x += sframeSpeed;
    if (FlxG.keys.pressed.UP) soulHitbox.y -= sframeSpeed;
    if (FlxG.keys.pressed.DOWN) soulHitbox.y += sframeSpeed;

    update_battlebox();

    soulSprite.x = soulHitbox.x + (soulHitbox.width/2 - soulSprite.width/2);
    soulSprite.y = soulHitbox.y + (soulHitbox.height/2 - soulSprite.height/2);

    update_bullets(elapsed);
    update_gaster_blasters(elapsed);

    shakeIntensity -= 1/2;
    shake_update(elapsed);

    update_scrolling_bones(elapsed);

    soulSprite.colorTransform.color = soulMode;
    if (invisTimer > 0) {
        soulHitbox.ID++;

        if (soulHitbox.ID > 2) {
            switch (soulMode) {
                case SOUL_YELLOW: soulSprite.colorTransform.color = 0xFFffc90e;
                case SOUL_BLUE: soulSprite.colorTransform.color = 0xFF02196a;
                default: soulSprite.colorTransform.color = 0xFF7f0006;
            }

            if (soulHitbox.ID > 4) 
                soulHitbox.ID = 0;
        }
    } else {

        soulHitbox.ID = 0;
        update_damage_collisions();
    }

    invisTimer -= elapsed;

    for (thisupdate in undertale_updates) thisupdate(elapsed);
}

var wasPaused:Bool = false;
function destroy() 
    pause_sfx();

function onGamePause(event) {
    wasPaused = !snd_mtt_prebomb.playing;
    pause_sfx();
}

function onSubstateClose(event) {
    if (!wasPaused) 
        resume_sfx();
}

#if REGION
var BOMB_DAMAGE:Float = .1;
var BOMB_BLAST_DAMAGE:Float = .1;
var BLASTER_DAMAGE:Float = .3;
var BONE_WALL_DAMAGE:Float = .1;

var rotatingDamagerID:Int = 0;

public var invisTime:Float = 1 * (2 / 3);
public var invisTimer:Float = 0;
var damageDealers:Array<{object:Dynamic, damage:Float}> = [];
function update_damage_collisions() {
    if (!allowSoulDamage) return;
    for (info in damageDealers) {
        if (Std.isOfType(info.object, FlxObject)) {
            if (FlxG.overlap(soulHitbox, info.object)) {
                deal_damage(info.damage);
                trace('soul damage', info.damage);
                break;
            }
        } else {
            if (rect_soul_collision(info.object?.x, info.object?.y, info.object?.w, info.object?.h)) {
                trace('rect soul damage', info.damage);
                deal_damage(info.damage);
                break;
            }
        }
    }
}

function delete_damager(dID:Int) {
    for (info in damageDealers) {
        if (info.object.dID == dID) {
            damageDealers.remove(info);
            info.object = null;
        }
    }
}

public var allowSoulDamage:Bool = true;
function deal_damage(damage) {
    if (!allowSoulDamage) return;
    health -= damage;
    invisTimer = invisTime + undertaleFrameTime;

    snd_hurt1.play(true);
}
#end

#if REGION
public var bombs:Array<FlxSprite> = [];
public function spawn_mttbomb(spawnx:Float, spawny:Float):FlxSprite {
    var bomb:FlxSprite = new FlxSprite();
    bomb.frames = Paths.getSparrowAtlas("game/undertale/spr_plusbomb");
    bomb.animation.addByPrefix("spr_plusbomb", "spr_plusbomb", 20, false);
    bomb.scale.set(1.5, 1.5);
    bomb.cameras = [camUndertale];
	bomb.updateHitbox();
	bomb.antialiasing = false;
    insert(9999, bomb);

    bomb.x = spawnx; bomb.y = spawny;

    bomb.animation.stop();
    bomb.animation.frameIndex = 0;

    bomb.ID = -1;
    bombs.push(bomb);

    damageDealers.push({object: bomb, damage: BOMB_DAMAGE});
    return bomb;
}

function spawn_mttblast(bomb:FlxSprite) {
    var blast:FlxSprite = new FlxSprite();
    blast.frames = Paths.getSparrowAtlas("game/undertale/spr_plusbomb_coreblast");
    blast.animation.addByPrefix("spr_plusbomb_coreblast", "spr_plusbomb_coreblast", 30, false);
    blast.scale.set(1.5, 1.5);
    blast.cameras = [camUndertale];
	blast.updateHitbox();
	blast.antialiasing = false;
    insert(9999, blast);

    var blast_directional:FlxSprite = new FlxSprite();
    blast_directional.frames = Paths.getSparrowAtlas("game/undertale/spr_plusbomb_horblast");
    blast_directional.animation.addByPrefix("spr_plusbomb_horblast", "spr_plusbomb_horblast", 30, false);
    blast_directional.scale.set(1.5, 1.5);
    blast_directional.cameras = [camUndertale];
	blast_directional.updateHitbox();
	blast_directional.antialiasing = false;
    insert(9999, blast_directional);

    blast_directional.x = blast.x = bomb.x + (bomb.frameWidth / 2 - blast.frameWidth / 2); 
    blast_directional.y = blast.y = bomb.y + (bomb.frameHeight / 2 - blast.frameHeight / 2);

    blast_directional.onDraw = function (spr:FlxSprite) {
        var ogX:Float = spr.x; var ogY:Float = spr.y;
        spr.centerOrigin();

        // tile across X
        for (i in 0...Math.ceil(spr.x/spr.width)) {spr.x -= spr.width; spr.draw();}
        spr.x = ogX; spr.y = ogY;
        for (i in 0...Math.ceil((FlxG.width-(spr.x+spr.width))/spr.width)) {spr.x += spr.width; spr.draw();}
        spr.x = ogX; spr.y = ogY;

        // tile across Y
        spr.angle += 90;
        for (i in 0...Math.ceil(spr.y/spr.height)) {spr.y -= spr.height; spr.draw();}
        spr.x = ogX; spr.y = ogY;
        for (i in 0...Math.ceil((FlxG.height-(spr.y+spr.height))/spr.height)) {spr.y += spr.height; spr.draw();}
        spr.x = ogX; spr.y = ogY;
        spr.angle -= 90;
    };

    blast.animation.play("spr_plusbomb_coreblast");
    blast_directional.animation.play("spr_plusbomb_horblast");

    blast.animation.finishCallback = (_) -> {
        delete_damager(blast.ID);

        remove(blast);
        blast.ID = MARKED_FOR_DELETION_NEXT_FRAME;
    }

    blast_directional.animation.finishCallback = (_) -> {
        remove(blast_directional);
        blast_directional.ID = MARKED_FOR_DELETION_NEXT_FRAME;
    }

    damageDealers.push({object: {x: blast.x, y: blast.y-FlxG.height, w: blast.frameWidth, h: blast.frameHeight + FlxG.height*2, dID: rotatingDamagerID}, damage: BOMB_BLAST_DAMAGE});
    damageDealers.push({object: {x: blast.x-FlxG.width, y: blast.y, w: blast.frameWidth + FlxG.width*2, h: blast.frameHeight, dID: rotatingDamagerID}, damage: BOMB_BLAST_DAMAGE});

    blast.ID = rotatingDamagerID;
    rotatingDamagerID++;

    snd_mtt_prebomb.pause();
    snd_bomb.play(true);

    shakeIntensity = 4;
}
#end

#if REGION
var blasters:Array<Dynamic> = [];
public function spawn_gasterblaster(spawnx:Float, spawny:Float, spawnrot:Float, scale:Float, stayframes:Int = 2) {
    var blaster:FlxSprite = new FlxSprite();
    blaster.frames = Paths.getSparrowAtlas("game/undertale/spr_gasterblaster");
    blaster.animation.addByPrefix("spr_gasterblaster", "spr_gasterblaster", 30, false);
    blaster.scale.set(1.6 * scale, 1.6 * scale);
    blaster.cameras = [camUndertale];
	blaster.updateHitbox();
	blaster.antialiasing = false;
    insert(9999, blaster);

    blaster.onDraw = function (spr:FlxSprite) {
        blaster.centerOrigin();
        spr.draw();
    }

    var blasterLine:FlxSprite = new FlxSprite().makeSolid(1, 1, 0xFFFFFFFF);
    blasterLine.cameras = [camUndertale];
	blasterLine.antialiasing = false;
    blasterLine.visible = false;
    insert(9999, blasterLine);

    blasterLine.onDraw = function (spr:FlxSprite) {
        var ogX:Float = spr.x; var ogY:Float = spr.y;
        var ogScaleX:Float = spr.scale.x; var ogScaleY:Float = spr.scale.y;

        spr.x += 18 * (spr.flipX ? -1 : 1);
        spr.draw();

        spr.scale.y *= 0.8;
        spr.scale.x = 9;
        spr.updateHitbox();

        if (spr.flipX) spr.x += ogScaleX - spr.scale.x;
        spr.x -= 9 * (spr.flipX ? -1 : 1);
        spr.y = ogY + ogScaleY/2 - spr.scale.y/2;

        spr.draw();

        spr.scale.y *= 0.8;
        spr.scale.x = 9;
        spr.updateHitbox();

        
        spr.x -= 9 * (spr.flipX ? -1 : 1);
        spr.y = ogY + ogScaleY/2 - spr.scale.y/2;

        spr.draw();

        spr.scale.y = ogScaleY; spr.scale.x = ogScaleX; spr.x = ogX; spr.y = ogY;
        spr.updateHitbox();
    }

    blaster.x = spawnx; blaster.y = spawny;
    blaster.angle = spawnrot*-1;

    blaster.animation.stop();
    blaster.animation.frameIndex = 0;

    if (spawnx > FlxG.width/2) blaster.x = FlxG.width + blaster.frameWidth + FlxG.random.float(10, 100);
    else blaster.x = 0 - blaster.frameWidth - FlxG.random.float(10, 100);

    if (spawny > FlxG.height/2) blaster.y = FlxG.height + blaster.frameHeight + FlxG.random.float(7, 70);
    else blaster.y = 0 - blaster.frameHeight - FlxG.random.float(7, 70);

    blasters.push({
        skipped: false, phase: 0, bbsiner: 0, bt: 0, terminal: stayframes,
        idealx: spawnx, idealy: spawny, idealrot: spawnrot,
        blasterLine: blasterLine, sprite: blaster
    });

    blaster.ID = rotatingDamagerID;
    rotatingDamagerID++;

    mus_sfx_segapower.play(true);
}

function update_gaster_blasters(elapsed:Float) {
    for (binfo in blasters) {
        if (binfo == null) continue;
        var sprite = binfo.sprite;
        // this is from undertale decompile PLEASE do NOT kill me -lunar
        switch (binfo.phase) {
            case 0:
                sprite.x += Math.floor((binfo.idealx - sprite.x) / 3);
                sprite.y += Math.floor((binfo.idealy - sprite.y) / 3);
            
                if (sprite.x < binfo.idealx)
                    sprite.x += 1;
                
                if (sprite.y < binfo.idealy)
                    sprite.y += 1;
                
                if (sprite.x > binfo.idealx)
                    sprite.x -= 1;
                
                if (sprite.y > binfo.idealy)
                    sprite.y -= 1;
            
                if (Math.abs(sprite.x - binfo.idealx) < 3)
                    sprite.x = binfo.idealx;
                
                if (Math.abs(sprite.y - binfo.idealy) < 3)
                    sprite.y = binfo.idealy;

                sprite.angle += Math.floor((binfo.idealrot - sprite.angle) / 3);

                if (sprite.angle < binfo.idealrot)
                    sprite.angle += 1;
                
                if (sprite.angle > binfo.idealrot)
                    sprite.angle -= 1;
                
                if (Math.abs(sprite.angle - binfo.idealrot) < 3)
                    sprite.angle = binfo.idealrot;

                if (Math.abs(sprite.x - binfo.idealx) < 0.1 && Math.abs(sprite.y - binfo.idealy) < 0.1 && Math.abs(binfo.idealrot - sprite.angle) < 0.01) {
                    binfo.phase = 4;
                }
            case 4 | 5: 
                binfo.phase++;
            case 6:
                binfo.phase++;
                sprite.animation.frameIndex++;
            case 7:
                var flipBlasterX:Bool = binfo.idealx > FlxG.width/2;
                var blasterDamager:Dynamic = null;
                for (info in damageDealers) {
                    if (info.object.dID == sprite.ID) {
                        blasterDamager = info.object;
                        break;
                    }
                }

                var blasterLine:FlxSprite = binfo.blasterLine;
                blasterLine.flipX = flipBlasterX;

                if (blasterLine.visible == false) {
                    mus_sfx_rainbowbeam_1.play(true);

                    shakeIntensity += 5*1.6;
                }

                blasterLine.visible = true;

                binfo.bbsiner++;

                if (sprite.animation.frameIndex == 4) {
                    sprite.animation.frameIndex = 5;
                } else if (sprite.animation.frameIndex == 5)
                    sprite.animation.frameIndex = 4;
                else 
                    sprite.animation.frameIndex++;

                if (binfo.bbsiner < 4) {
                    binfo.bt += Math.floor((35 * sprite.scale.x) / 4);
                    sprite.x -= (1.5 * 1.2 * (binfo.bt / 4))*(flipBlasterX?-1:1);
                } else 
                    sprite.x -= 4.5 * 1.4 * (binfo.bt / 6)*(flipBlasterX?-1:1);
                
                if (binfo.bbsiner > (5 + binfo.terminal)) {
                    binfo.bt *= 0.8;
                    sprite.alpha -= 0.1*.65;
                    blasterLine.alpha -= 0.1*.65;

                    if (blasterLine.alpha <= 0) {
                        blasters.remove(binfo);
                        delete_damager(sprite.ID);

                        sprite.ID = MARKED_FOR_DELETION_NEXT_FRAME;
                        blasterLine.ID = MARKED_FOR_DELETION_NEXT_FRAME;
                    }
                }

                blasterLine.x = flipBlasterX ? 0 : sprite.x + 135;
                blasterLine.y = sprite.y + sprite.height/2 - blasterLine.scale.y/2 + (sprite.animation.frameIndex == 4 ? -2 : 0);

                blasterLine.scale.x = flipBlasterX ? sprite.x : FlxG.width - blasterLine.x;
                blasterLine.scale.y = binfo.bt + ((Math.sin(binfo.bbsiner / 1.5)) / 4);
                blasterLine.updateHitbox();

                if (blasterDamager == null) {
                    blasterDamager = {x: 0, y: 0, w: 0, y: 0, dID: sprite.ID};
                    damageDealers.push({object: blasterDamager, damage: BLASTER_DAMAGE});
                }

                blasterDamager.x = blasterLine.x-FlxG.width; blasterDamager.y = blasterLine.y;
                blasterDamager.w = blasterLine.scale.x + FlxG.width*2; blasterDamager.h = blasterLine.scale.y;
        }  
    }
}
#end

#if REGION
var bullets:Array<FlxSprite> = [];
function shoot() {
    var bullet:FlxSprite = new FlxSprite();
    bullet.frames = Paths.getSparrowAtlas("game/undertale/spr_yellowbullet_pl");
    bullet.animation.addByPrefix("spr_yellowbullet_pl", "spr_yellowbullet_pl", 20, false);
    bullet.scale.set(1.6, 1.6);
    bullet.cameras = [camUndertale];
	bullet.updateHitbox();
	bullet.antialiasing = false;
    insert(999, bullet);

    bullet.x = soulHitbox.x+(soulHitbox.width/2-bullet.width/2); 
    bullet.y = (soulHitbox.y-bullet.height)+(soulSprite.height-soulHitbox.height)+(bulletSpeed*.75); 

    bullet.health = 0;
    bullets.push(bullet);

    bullet.animation.play("spr_yellowbullet_pl", true, false);

    snd_heartshot.play(true);
}

var bulletSpeed:Float = 17;
var bulletCooldown:Float = 1/3;
var bulletCooldownTimer:Float = 0;
function update_bullets(elapsed:Float) {
    bulletCooldownTimer -= elapsed;
    if (soulMode == SOUL_YELLOW && justPressedZ && bulletCooldownTimer <= 0) {
        shoot(); bulletCooldownTimer = bulletCooldown;
    }

    var bframeSpeed:Float = bulletSpeed * (elapsed/undertaleFrameTime);

    var bulletCount:Int = bullets.length;
    var bombCount:Int = bombs.length;

    var activeBombs:Array<FlxSprite> = [];
    for (j in 0...bombCount) {
        var bomb = bombs[j];
        if (bomb.ID < 0) activeBombs.push(bomb);
    }

    var i:Int = 0;
    while (i < bulletCount) {
        var bullet:FlxSprite = bullets[i];

        if (bullet.y < -100) {
            bullets.remove(bullet);
            remove(bullet);
            bullet.destroy();
            bulletCount--;
            continue; // don't increment i here, because item removed
        }

        bullet.health++; // count frames 
        bullet.y -= (bframeSpeed + (.2 * bullet.health)) * 1.6;
        bullet.scale.y = 1.6 + (.34 * bullet.health);

        for (bomb in activeBombs) {
            var dx = Math.abs(bullet.x - bomb.x);
            var dy = Math.abs(bullet.y - bomb.y);
            if (dx > 100 || dy > 100) continue; // skip far away bombs

            if (FlxG.overlap(bullet, bomb)) {
                bomb.ID = 0;
                snd_mtt_prebomb.play(true);
                break;
            }
        }

        i++;
    }

    var i:Int = 0;
    while (i < bombs.length) {
        var bomb:FlxSprite = bombs[i];
        if (bomb.ID >= 0) {
            bomb.animation.frameIndex = bomb.ID % 2;
            if (bomb.ID >= 5) {
                spawn_mttblast(bomb);

                bombs.remove(bomb);
                bomb.ID = MARKED_FOR_DELETION_NEXT_FRAME;

                continue;
            }
            bomb.ID++;
        }
        i++;
    }
}
#end

#if REGION
public function update_battlebox() {
    battleBoxColliderLeft.height = battleBoxColliderRight.height = FlxG.height;
    battleBoxColliderUp.width = battleBoxColliderDown.width = FlxG.width;

    battleBoxColliderLeft.width = battleBox.x + battleBox.extra["border"] ;
    battleBoxColliderLeft.x = 0;

    battleBoxColliderRight.width = FlxG.width - (battleBox.x + battleBox.extra["bWidth"] + battleBox.extra["border"] );
    battleBoxColliderRight.x = (battleBox.x + battleBox.extra["bWidth"] - battleBox.extra["border"] );

    battleBoxColliderUp.height = battleBox.y + battleBox.extra["border"] ;
    battleBoxColliderUp.y = 0;

    battleBoxColliderDown.height = FlxG.height - (battleBox.y + battleBox.extra["bHeight"] + battleBox.extra["border"] );
    battleBoxColliderDown.y = (battleBox.y + battleBox.extra["bHeight"] - battleBox.extra["border"] );

    for (collider in [battleBoxColliderLeft, battleBoxColliderRight, battleBoxColliderUp, battleBoxColliderDown]) {
        FlxG.collide(soulHitbox, collider);
    }
}

var colliders:Array<FlxObject> = [];
function setup_collider(collider:FlxObject) {
    collider.cameras = [camUndertale];
    add(collider);

    collider.ID = 0;
    colliders.push(collider);
}

function rect_soul_collision(rx:Float, ry:Float, rw:Float, rh:Float):Bool {
    return rect_rect_collision(soulHitbox.x, soulHitbox.y, soulHitbox.width, soulHitbox.height, rx, ry, rw, rh);
}
#end

#if REGION
var shakeTime:Float = 999999;
var shakeIntensity:Float = 0;

var xMod:Float = 0; var yMod:Float = 0;
function shake_update(elapsed:Float) {
    shakeIntensity = Math.max(shakeIntensity, 0);

    if (shakeTime > 0) {
        xMod = FlxG.random.float(-1, 1) * shakeIntensity;
        yMod = FlxG.random.float(-1, 1) * shakeIntensity;

        shaketime -= elapsed;
    } else {xMod = yMod = 0;}

    camUndertale.scroll.set(0, 0);

    for (cam in [camGame, camUndertale, camHUD]) {
        cam.scroll.x += xMod; cam.scroll.y += yMod;
    }
}
#end 

var boneWallSpr:FlxSprite = null;
var boneScrollTimer:Float = 0;

public var boneAppearLeft:Float = 0;
public var boneAppearRight:Float = 0;

public var BONE_HITBOX_FORGIVENESS:Float = 2;

public function spawn_bonewalls() {
    boneWallSpr = new FlxSprite().loadGraphic(Paths.image("game/undertale/spr_s_bonewall_wide"));
    boneWallSpr.scale.set(1.5, 1.5);
    boneWallSpr.cameras = [camBones];
	boneWallSpr.updateHitbox();
	boneWallSpr.antialiasing = false;
    add(boneWallSpr);

    boneWallSpr.onDraw = function (spr:FlxSprite) {
        var bonesXLeft:Float = -spr.width + FlxMath.lerp(-30, 60, boneAppearLeft);
        var bonesXRight:Float = battleBox.extra["bWidth"] - FlxMath.lerp(-30, 60, boneAppearRight);

        var offsetY:Float = (boneScrollTimer * 40) % (spr.height + 10);
        var startY:Float = -spr.height - offsetY;


        for (i in 0...Math.ceil(battleBox.extra["bHeight"] / (spr.height + 10)) + 2) {
            var drawY = startY + i * (spr.height + 10);
            var wave = Math.sin(drawY / 30 + boneScrollTimer * 2) * 1 + Math.sin(drawY / 80 - boneScrollTimer * 1.5) * 25;

            spr.y = drawY; spr.x = bonesXLeft + wave;
            spr.draw();

            spr.x = bonesXRight + wave;
            spr.draw();
        }
    }
}

public function get_bone_wave_x_left(wavey:Float) {
    var drawY = (-boneWallSpr.height - ((boneScrollTimer * 40) % (boneWallSpr.height + 10))) + Math.ceil((wavey-camBones.y) / (boneWallSpr.height + 10)) * (boneWallSpr.height + 10);
    var wave = Math.sin(drawY / 30 + boneScrollTimer * 2) * 1 + Math.sin(drawY / 80 - boneScrollTimer * 1.5) * 25;
    return (FlxMath.lerp(-30, 60, boneAppearLeft)) + wave;
}

public function get_bone_wave_x_left_smooth(wavey:Float) {
    var drawY = (-boneWallSpr.height - (boneScrollTimer * 40)) + (wavey-camBones.y);
    var wave = Math.sin(drawY / 30 + boneScrollTimer * 2) * 1 + Math.sin(drawY / 80 - boneScrollTimer * 1.5) * 25;
    return (FlxMath.lerp(-30, 60, boneAppearLeft)) + wave;
}

public function get_bone_wave_x_right(wavey:Float) {
    var drawY = (-boneWallSpr.height - ((boneScrollTimer * 40) % (boneWallSpr.height + 10))) + Math.ceil((wavey-camBones.y) / (boneWallSpr.height + 10)) * (boneWallSpr.height + 10);
    var wave = Math.sin(drawY / 30 + boneScrollTimer * 2) * 1 + Math.sin(drawY / 80 - boneScrollTimer * 1.5) * 25;
    return (battleBox.extra["bWidth"] - FlxMath.lerp(-30, 60, boneAppearRight)) + wave;
}

function update_scrolling_bones(elapsed:Float) {
    boneScrollTimer += elapsed;

    camBones.x -= camUndertale.scroll.x;
    camBones.y -= camUndertale.scroll.y;

    if (boneWallSpr == null || invisTimer > 0) return;

    if ((get_bone_wave_x_left(soulHitbox.y) - BONE_HITBOX_FORGIVENESS > (soulHitbox.x - camBones.x)) 
        || (get_bone_wave_x_right(soulHitbox.y) + BONE_HITBOX_FORGIVENESS < (soulHitbox.x - camBones.x + soulHitbox.width))) {
        deal_damage(BONE_WALL_DAMAGE);
    }
}