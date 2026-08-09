import openfl.display.ShaderPrecision;
import openfl.geom.ColorTransform;

import flixel.FlxCamera;
import flixel.FlxStrip;
import flixel.sound.FlxSound;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

import funkin.backend.FunkinText;

var customUI:Array<FlxSprite>;

var tapeGame:CustomShader;
var tapeHUD:CustomShader;
var tapeFailureText:CustomShader;
var exposureGame:CustomShader;
var exposureHUD:CustomShader;
var stageOverlayShader:CustomShader;

var camBorders:FlxCamera;
var camFailureText:FlxCamera;
var songStartBlackOverlay:FlxSprite;
var songStartBlackTween:FlxTween;
var deathTransitionActive:Bool = false;
var allowNormalGameOver:Bool = false;
var deathTransitionTimer:FlxTimer;
var deathGlitchSound:FlxSound;
var deathTransitionDuration:Float = 2.0;
var deathTransitionExposure:Float = 0.8;
var redBeatOverlay:FunkinSprite;
var redBeatOverlayActive:Bool = false;
var failurePhraseText:FunkinText;
var failurePhraseTimer:Float = 0.0;
var failurePhraseIndex:Int = -1;
var failurePhrases:Array<String> = [
    "FAILURE",
    "But it didn't work.",
    "nope",
    "Absorbed",
    "Don't worry about it.",
    "I'm lovin' it."
];

var cameraTimerText:FunkinText;
var cameraModeText:FunkinText;
var cameraScoreText:FunkinText;
var cameraMissesText:FunkinText;
var cameraPlayText:FunkinText;
var cameraRecText:FunkinText;
var cameraRatingText:FunkinText;

var cameraRecDot:FlxSprite;
var healthVignette:FlxSprite;

var quickTimeCursorOuter:FlxSprite;
var quickTimePromptText:FunkinText;
var quickTimeActive:Bool = false;
var quickTimeUseShootEffects:Bool = true;
var quickTimeElapsed:Float = 0.0;
var quickTimeDurationSteps:Int = 12;
var quickTimeEndStep:Int = -1;
var quickTimeApproachDuration:Float = 0.0;
var quickTimeStartingScaleMultiplier:Float = 3.24;
var quickTimeEarlyWindow:Float = 0.12;
var quickTimeLateWindow:Float = 0.12;
var quickTimeTargetScaleX:Float = 1.0;
var quickTimeTargetScaleY:Float = 1.0;
var lookAroundMouseInsideRoomHitbox:Bool = false;
var activeLookAroundRoomTarget:Int = -1;

var showLookAroundRoomHitboxes:Bool = false;
var lookAroundRoomHitboxAlpha:Float = 0.08;

var leftRoomHitboxX:Int = -900;
var leftRoomHitboxY:Int = 330;
var leftRoomHitboxWidth:Int = 180;
var leftRoomHitboxHeight:Int = 350;

var middleRoomHitboxX:Int = 950;
var middleRoomHitboxY:Int = 300;
var middleRoomHitboxWidth:Int = 180;
var middleRoomHitboxHeight:Int = 350;

var rightRoomHitboxX:Int = 2450;
var rightRoomHitboxY:Int = 330;
var rightRoomHitboxWidth:Int = 180;
var rightRoomHitboxHeight:Int = 350;

var left_room_hitbox:FlxSprite;
var middle_room_hitbox:FlxSprite;
var right_room_hitbox:FlxSprite;

var recBlinkTimer:Float = 0.0;

var cameraTimerTime:Float = 0.0;
var cameraTimerRunning:Bool = false;

var cameraLeftMargin:Float = 280;
var cameraRightMargin:Float = 260;
var cameraTopMargin:Float = 40;
var cameraBottomMargin:Float = 40;

var cameraFrameLength:Int = 42;
var cameraFrameThickness:Int = 4;
var cameraFrameHorizontalGap:Float = 24;
var cameraFrameVerticalGap:Float = 16;

var vignetteMaximumAlpha:Float = 1;

var shaderTime:Float = 0;
var vhsAnimationFrozen:Bool = false;

var wobbleStrength:Float = 5.65;

var handheldX:Float = 0;
var handheldY:Float = 0;
var handheldAngle:Float = 0;

var handheldVelocityX:Float = 0;
var handheldVelocityY:Float = 0;
var handheldVelocityAngle:Float = 0;

var driftTargetX:Float = 0;
var driftTargetY:Float = 0;
var driftTargetAngle:Float = 0;

var driftTimer:Float = 0;

var microX:Float = 0;
var microY:Float = 0;
var microAngle:Float = 0;

var microTargetX:Float = 0;
var microTargetY:Float = 0;
var microTargetAngle:Float = 0;

var microTimer:Float = 0;

var correctionTimer:Float = 0.8;

var noteHitX:Float = 0.0;
var noteHitY:Float = 0.0;
var noteHitAngle:Float = 0.0;

var noteHitVelocityX:Float = 0.0;
var noteHitVelocityY:Float = 0.0;
var noteHitVelocityAngle:Float = 0.0;

var noteHitMoveStrength:Float = 0.0200;
var noteHitAngleStrength:Float = 0.0550;

var noteHitHoldTimer:Float = 0.0;
var noteHitHoldDuration:Float = 0.045;

var cameraBaseZoom:Float = 1.060;
var cameraEnemyZoomLevel:Float = 1.500;
var cameraAnimatedZoom:Float = 1.060;
var cameraFocusBlur:Float = 0.0;

var cameraEnemyOffsetY:Float = -0.080;
var cameraAnimatedOffsetY:Float = 0.0;

var cameraZoomTween:FlxTween;
var cameraFocusTween:FlxTween;
var cameraMoveTween:FlxTween;


var cameraRoomTween:FlxTween;
var cameraRoom:Int = 0;
var cameraRoomOffsetX:Float = 0.0;
var cameraRoomLastAppliedOffsetX:Float = 0.0;
var cameraRoomDistance:Float = 2000.0;
var cameraRoomTweenDuration:Float = 0.23;
var cameraRoomSettleDuration:Float = 0.12;
var cameraRoomOvershootDistance:Float = 38.0;
var cameraRoomTiltStrength:Float = 0.034;
var cameraRoomTilt:Float = 0.0;
var cameraRoomDipAmount:Float = 0.0100;
var cameraRoomDipDuration:Float = 0.075;
var cameraRoomDip:Float = 0.0;
var cameraRoomRestoreFollowEnabled:Bool = true;


var cameraRoomMotionBlur:Float = 0.0;
var cameraRoomMotionDirection:Float = 0.0;

var cameraZoomSequence:Int = 0;

var showCameraButtonHitboxes:Bool = false;

var cameraButtonHitboxWidth:Int = 160;
var cameraButtonHitboxHeight:Int = 460;

var cameraRightHitboxOffsetX:Float = 0.0;
var cameraRightHitboxOffsetY:Float = 0.0;
var cameraLeftHitboxOffsetX:Float = 0.0;
var cameraLeftHitboxOffsetY:Float = 0.0;

var cameraRightHitbox:FlxSprite;
var cameraLeftHitbox:FlxSprite;

var warningFlipTimer:Float = 0.0;
var warningText:FunkinText;

var lookAroundActive:Bool = false;
var lookAroundTimer:FlxTimer;
var lookAroundTargetSpawnTimer:FlxTimer;
var lookAroundTargetFadeTween:FlxTween;
var lookAroundTargetTimeRemaining:Float = 0.0;
var lookAroundTimedTarget:Int = -1;
var warningFadeTween:FlxTween;
var warningTextFadeTween:FlxTween;
var dadFadeTween:FlxTween;
var dadIntroFadeStarted:Bool = false;
var jumpscareActive:Bool = false;
var jumpscareDad:Dynamic;
var jumpscarePreviousFinishCallback:Dynamic;
var jumpscareLoopEffectsActive:Bool = false;
var jumpscareLoopShakeIntensity:Float = 0.030;
var jumpscareLoopBlurStrength:Float = 0.05;
var jumpscareLoopBlur:Float = 0.0;
var jumpscareExposurePeak:Float = 0.75;
var jumpscareExposure:Float = 0.0;
var jumpscareExposureTween:FlxTween;
var scriptedExposure:Float = 0.0;
var scriptedExposureTween:FlxTween;
var safeCameraShakeBurstIntensity:Float = 0.0;
var safeCameraShakeBurstTime:Float = 0.0;
var safeCameraShakeX:Float = 0.0;
var safeCameraShakeY:Float = 0.0;
var sixbonesThirdWarmup:Character;
var lookAroundStaticTween:FlxTween;

var lookAroundStaticBurst:Float = 0.0;
var lookAroundInitialized:Bool = false;

var lookAroundShooting:Bool = false;
var lookAroundShootTimer:FlxTimer;
var lookAroundShootFlashTween:FlxTween;
var lookAroundShootBlurTween:FlxTween;
var lookAroundShootFocusTween:FlxTween;
var lookAroundShootHeavyBlurTween:FlxTween;
var lookAroundShootExposureTween:FlxTween;
var lookAroundShootRecoilTween:FlxTween;
var lookAroundShootAngleTween:FlxTween;

var lookAroundShootFocusBlur:Float = 0.0;
var lookAroundShootHeavyBlur:Float = 0.0;
var lookAroundShootExposure:Float = 0.0;
var lookAroundShootRecoilY:Float = 0.0;
var lookAroundShootRecoilAngle:Float = 0.0;

function create()
{
    autoTitleCard = true;

    if (Options.gameplayShaders)
    {
        tapeGame = createTapeShader(true);
        tapeHUD = createTapeShader(false);

        exposureGame = createExposureShader();
        exposureHUD = createExposureShader();
        stageOverlayShader = createWhiteOverlayShader();

        camGame.addShader(stageOverlayShader);
        camGame.addShader(tapeGame);
        camGame.addShader(exposureGame);

        camHUD.addShader(tapeHUD);
        camHUD.addShader(exposureHUD);
    }
}

function startJumpscareLoopEffects()
{
    if (jumpscareLoopEffectsActive)
        return;

    jumpscareLoopEffectsActive = true;
    jumpscareLoopBlur = jumpscareLoopBlurStrength;

    // custom shake thing because if not it clips
    if (
        camGame != null &&
        (!Options.gameplayShaders || tapeGame == null)
    )
        camGame.shake(
            jumpscareLoopShakeIntensity,
            86400.0
        );
}

function stopJumpscareLoopEffects()
{
    jumpscareLoopBlur = 0.0;

    if (!jumpscareLoopEffectsActive)
        return;

    jumpscareLoopEffectsActive = false;

    if (
        camGame != null &&
        (!Options.gameplayShaders || tapeGame == null)
    )
        camGame.shake(0.0, 0.0);
}

function shakeCamGameSafely(
    intensity:Float,
    duration:Float
)
{
    if (
        !Options.gameplayShaders ||
        tapeGame == null
    )
    {
        if (camGame != null)
            camGame.shake(intensity, duration);

        return;
    }

    safeCameraShakeBurstIntensity =
        Math.max(
            safeCameraShakeBurstIntensity,
            intensity
        );

    safeCameraShakeBurstTime =
        Math.max(
            safeCameraShakeBurstTime,
            duration
        );
}

function updateSafeCameraShake(elapsed:Float)
{
    if (safeCameraShakeBurstTime > 0.0)
    {
        safeCameraShakeBurstTime =
            Math.max(
                0.0,
                safeCameraShakeBurstTime - elapsed
            );

        if (safeCameraShakeBurstTime <= 0.0)
            safeCameraShakeBurstIntensity = 0.0;
    }

    var intensity:Float =
        jumpscareLoopEffectsActive
            ? jumpscareLoopShakeIntensity
            : 0.0;

    intensity = Math.max(
        intensity,
        safeCameraShakeBurstIntensity
    );

    if (intensity <= 0.0)
    {
        safeCameraShakeX = 0.0;
        safeCameraShakeY = 0.0;
        return;
    }

    var shaderShakeIntensity:Float =
        Math.min(0.0230, intensity * 0.75);

    safeCameraShakeX = FlxG.random.float(
        -shaderShakeIntensity,
        shaderShakeIntensity
    );

    safeCameraShakeY = FlxG.random.float(
        -shaderShakeIntensity,
        shaderShakeIntensity
    );
}

function applyCombinedExposure()
{
    var combinedExposure:Float =
        Math.min(
            1.0,
            lookAroundShootExposure +
            jumpscareExposure +
            scriptedExposure
        );

    updateExposureShader(
        exposureGame,
        combinedExposure
    );

    updateExposureShader(
        exposureHUD,
        combinedExposure
    );
}

function setScriptedExposure(
    target:Float,
    duration:Float = 0.0
)
{
    if (scriptedExposureTween != null)
    {
        scriptedExposureTween.cancel();
        scriptedExposureTween = null;
    }

    if (duration <= 0.0)
    {
        scriptedExposure = target;
        applyCombinedExposure();
        return;
    }

    scriptedExposureTween =
        FlxTween.num(
            scriptedExposure,
            target,
            duration,
            {
                ease: FlxEase.linear,
                onComplete: function(_)
                {
                    scriptedExposureTween = null;
                    scriptedExposure = target;
                    applyCombinedExposure();
                }
            },
            function(value:Float)
            {
                scriptedExposure = value;
                applyCombinedExposure();
            }
        );
}

function setJumpscareExposure(active:Bool)
{
    if (jumpscareExposureTween != null)
    {
        jumpscareExposureTween.cancel();
        jumpscareExposureTween = null;
    }

    jumpscareExposure = 0.0;
    applyCombinedExposure();

    if (
        !active ||
        !Options.gameplayShaders ||
        exposureGame == null
    )
    {
        return;
    }

    jumpscareExposureTween =
        FlxTween.num(
            0.0,
            jumpscareExposurePeak,
            0.25,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    jumpscareExposureTween = null;
                    jumpscareExposure =
                        jumpscareExposurePeak;
                    applyCombinedExposure();
                }
            },
            function(value:Float)
            {
                jumpscareExposure = value;
                applyCombinedExposure();
            }
        );
}

function onGameOver(event)
{
    if (allowNormalGameOver)
        return;

    event.cancel();

    if (deathTransitionActive)
        return;

    deathTransitionActive = true;
    canPause = false;
    paused = true;
    persistentUpdate = false;
    cameraTimerRunning = false;
    vhsAnimationFrozen = true;

    quickTimeActive = false;
    quickTimeEndStep = -1;
    setQuickTimeObjectsVisible(false);

    lookAroundActive = false;
    activeLookAroundRoomTarget = -1;
    setLookAroundRoomHitboxesVisible(false);
    cancelLookAroundEffects();

    jumpscareActive = false;
    stopJumpscareLoopEffects();

    if (jumpscareExposureTween != null)
    {
        jumpscareExposureTween.cancel();
        jumpscareExposureTween = null;
    }

    if (scriptedExposureTween != null)
    {
        scriptedExposureTween.cancel();
        scriptedExposureTween = null;
    }

    if (lookAroundShootExposureTween != null)
    {
        lookAroundShootExposureTween.cancel();
        lookAroundShootExposureTween = null;
    }

    jumpscareExposure = 0.0;
    lookAroundShootExposure = 0.0;
    scriptedExposure = deathTransitionExposure;
    applyCombinedExposure();

    if (death_face != null)
    {
        death_face.visible = true;
        death_face.alpha = 1.0;
    }

    if (healthVignette != null)
    {
        healthVignette.alpha = 0.0;
        healthVignette.visible = false;
    }

    if (vocals != null)
        vocals.stop();

    if (inst != null)
        inst.stop();

    if (FlxG.sound.music != null)
        FlxG.sound.music.stop();

    if (strumLines != null)
    {
        for (strumLine in strumLines.members)
        {
            if (
                strumLine != null &&
                strumLine.vocals != null
            )
            {
                strumLine.vocals.stop();
            }
        }
    }

    deathGlitchSound = FlxG.sound.play(
        Paths.sound("glitch"),
        1.0
    );

    deathTransitionTimer =
        new FlxTimer().start(
            deathTransitionDuration,
            function(_)
            {
                deathTransitionTimer = null;

                if (deathGlitchSound != null)
                {
                    deathGlitchSound.stop();
                    deathGlitchSound = null;
                }

                allowNormalGameOver = true;
                paused = false;
                persistentUpdate = true;
                gameOver();
            }
        );
}

public function triggerJumpscare(active:Bool = true)
{
    if (jumpscareDad != null && jumpscareDad.animation != null)
        jumpscareDad.animation.finishCallback =
            jumpscarePreviousFinishCallback;

    jumpscareDad = null;
    jumpscarePreviousFinishCallback = null;
    jumpscareActive = active;
    stopJumpscareLoopEffects();
    setJumpscareExposure(active);

    if (dad == null || dad.animation == null)
        return;

    if (!active)
    {
        dad.playAnim("idle", true);
        return;
    }

    jumpscareDad = dad;
    jumpscarePreviousFinishCallback = dad.animation.finishCallback;

    dad.animation.finishCallback = function(animName:String)
    {
        if (
            jumpscareActive &&
            jumpscareDad != null &&
            animName == "jumpscare"
        )
        {
            jumpscareDad.playAnim("loop_jumpscare", true);
            startJumpscareLoopEffects();
            return;
        }

        if (jumpscarePreviousFinishCallback != null)
            jumpscarePreviousFinishCallback(animName);
    };

    dad.playAnim("jumpscare", true);
}

function pulseRedBeatOverlay()
{
    if (redBeatOverlay == null)
        return;

    FlxTween.cancelTweensOf(redBeatOverlay);
    redBeatOverlay.alpha = 0;

    FlxTween.tween(
        redBeatOverlay,
        {alpha: 0.05},
        0.2,
        {
            ease: FlxEase.linear,
            onComplete: function(_)
            {
                FlxTween.tween(
                    redBeatOverlay,
                    {alpha: 0},
                    1.0,
                    {ease: FlxEase.linear}
                );
            }
        }
    );
}

function beatHit(curBeat:Int)
{
    if (
        redBeatOverlayActive &&
        curBeat >= 0 &&
        curBeat % 4 == 0
    )
        pulseRedBeatOverlay();
}


function stepHit(curStep:Int)
{
    if (
        quickTimeActive &&
        quickTimeEndStep >= 0 &&
        curStep >= quickTimeEndStep
    )
    {
        if (!FlxG.save.data.mechanics)
        {
            finishShootQuickTimeEvent();
        }
        else
        {
            quickTimeActive = false;
            quickTimeEndStep = -1;
            health = 0;
            gameOver();
        }

        return;
    }

    switch (curStep)
    {
        case 234:
            shootQuickTimeEvent(false);


        case 20:
            if (
                door_right != null &&
                door_left != null &&
                door_shadow != null
            )
            {
                door_shadow.alpha = 1.0;

                FlxTween.tween(
                    door_right,
                    {x: door_right.x + 500},
                    30.0,
                    {ease: FlxEase.linear}
                );

                FlxTween.tween(
                    door_left,
                    {x: door_left.x - 500},
                    30.0,
                    {
                        ease: FlxEase.linear,
                        onComplete: function(_)
                        {
                            FlxTween.tween(
                                door_shadow,
                                {alpha: 0.0},
                                5.0,
                                {ease: FlxEase.linear}
                            );
                        }
                    }
                );
            }

        case 72:
            if (dad != null)
            {
                dadIntroFadeStarted = true;

                if (dadFadeTween != null)
                    dadFadeTween.cancel();

                dadFadeTween = FlxTween.tween(
                    dad,
                    {alpha: 1.0},
                    5.0,
                    {
                        ease: FlxEase.linear,
                        onComplete: function(_)
                        {
                            dadFadeTween = null;
                        }
                    }
                );
            }

        case 176:
            camEnemyZoom(true);

        case 232:
            camEnemyZoom(false);

        case 246:
            flash_shoot_start.alpha = 1;
            vhsAnimationFrozen = true;

        case 255:
            vhsAnimationFrozen = false;

            if (failurePhraseText != null)
            {
                failurePhraseTimer = 0.0;
                changeFailurePhrase();
                failurePhraseText.visible = true;
            }

        case 261:
            flash_shoot_start.alpha = 0;
            if (failurePhraseText != null)
                failurePhraseText.visible = false;

        case 274:
            stageOverlayShader.amount = 255.0 / 255.0;

        case 476:
            cameraEnemyOffsetY = 0;
            camEnemyZoom(true);

        case 570:
            camEnemyZoom(false);

        case 668:
            camEnemyZoom(true);

        case 764:
            camEnemyZoom(false);

        case 856:
            activateLookAround(true);

        case 1048:
            activateLookAround(false);

        case 1560:
            activateLookAround(true);
            //redBeatOverlayActive = true;

        case 1752:
            activateLookAround(false);
            //redBeatOverlayActive = false;

            if (redBeatOverlay != null)
            {
                FlxTween.cancelTweensOf(redBeatOverlay);
                redBeatOverlay.alpha = 0;
            }

        case 1764, 1812, 1860, 1908:
            triggerJumpscare(true);
            shootQuickTimeEvent(true);

        case 1776, 1824, 1872, 1920:
            triggerJumpscare(false);

        case 2344:
            setScriptedExposure(0.2, 0.2);

        case 2432:
            // cutout 1
            cut_1.alpha = 1;

        case 2434:
            // cutout 2
            cut_1.alpha = 0;
            cut_2.alpha = 1;

        case 2436:
            // cutout 3
            cut_2.alpha = 0;
            cut_3.alpha = 1;

        case 2439:
            cut_3.alpha = 0;

        case 2488:
            setScriptedExposure(0.0);

            if (camHUD != null)
                camHUD.visible = false;

            if (camBorders != null)
                camBorders.visible = false;



    }

    /*switch (curStep)
    {
        case 112:
            triggerJumpscare(true);

        case 120:
            triggerJumpscare(false);

        case 8:
            camEnemyZoom(true);

        case 30:
            camEnemyZoom(false);

        case 35:
            activateLookAround(true);

        case 100:
            activateLookAround(false);

            if (stageOverlayShader != null)
                stageOverlayShader.amount = 2.0 / 255.0;

        case 132:
            cameraEnemyOffsetY = 0;
            camEnemyZoom(true);
    }*/
}



// --------------------- all the stuff

function createTapeShader(useHandheldZoom:Bool):CustomShader
{
    var shader = new CustomShader("vhs");
    shader.precisionHint = ShaderPrecision.FULL;

    shader.time = 0.0;

    shader.res = [
        FlxG.width,
        FlxG.height
    ];

    shader.strength = 1.0;

    shader.handheldOffset = [
        0.0,
        0.0
    ];

    shader.handheldAngle = 0.0;
    shader.handheldZoom = useHandheldZoom ? cameraAnimatedZoom : 1.0;
    shader.focusBlur = 0.0;
    shader.motionBlurAmount = 0.0;
    shader.motionBlurDirection = 0.0;
    shader.staticBurst = 0.0;
    shader.shootBlurAmount = 0.0;

    return shader;
}

function createExposureShader():CustomShader
{
    var shader =
        new CustomShader("exposure");

    shader.amount = 0.0;

    return shader;
}

function createWhiteOverlayShader():CustomShader
{
    var shader =
        new CustomShader("whiteOverlay");

    shader.amount = 0.0;

    return shader;
}

function changeFailurePhrase()
{
    if (failurePhraseText == null || failurePhrases.length == 0)
        return;

    var nextIndex:Int = FlxG.random.int(
        0,
        failurePhrases.length - 1
    );

    if (
        failurePhrases.length > 1 &&
        nextIndex == failurePhraseIndex
    )
    {
        nextIndex =
            (
                nextIndex +
                FlxG.random.int(
                    1,
                    failurePhrases.length - 1
                )
            ) %
            failurePhrases.length;
    }

    failurePhraseIndex = nextIndex;
    failurePhraseText.text = failurePhrases[failurePhraseIndex];
    failurePhraseText.updateHitbox();
    failurePhraseText.x = 100;
    failurePhraseText.y =
        (FlxG.height - failurePhraseText.height) * 0.5 - 150;
}

function createLookAroundRoomHitbox(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    color:FlxColor
):FlxSprite
{
    var hitbox = new FlxSprite(x, y);
    hitbox.makeGraphic(width, height, color);
    hitbox.scrollFactor.set(1, 1);
    hitbox.cameras = [camGame];
    hitbox.alpha = lookAroundRoomHitboxAlpha;
    hitbox.visible = false;

    return hitbox;
}

function setLookAroundRoomHitboxesVisible(active:Bool)
{
    var showHitboxes:Bool =
        active &&
        showLookAroundRoomHitboxes;

    if (left_room_hitbox != null)
        left_room_hitbox.visible =
            showHitboxes &&
            activeLookAroundRoomTarget == 0;

    if (middle_room_hitbox != null)
        middle_room_hitbox.visible =
            showHitboxes &&
            activeLookAroundRoomTarget == 1;

    if (right_room_hitbox != null)
        right_room_hitbox.visible =
            showHitboxes &&
            activeLookAroundRoomTarget == 2;

    if (sb_left != null)
        sb_left.visible =
            active &&
            activeLookAroundRoomTarget == 0;

    if (sb_front != null)
        sb_front.visible =
            active &&
            activeLookAroundRoomTarget == 1;

    if (sb_right != null)
        sb_right.visible =
            active &&
            activeLookAroundRoomTarget == 2;
}

function chooseNextLookAroundRoomTarget(
    previousTarget:Int,
    targetDuration:Float,
    allowMiddleTarget:Bool
)
{
    if (previousTarget < 0 || previousTarget > 2)
    {
        if (allowMiddleTarget)
        {
            activeLookAroundRoomTarget =
                FlxG.random.int(0, 2);
        }
        else
        {
            activeLookAroundRoomTarget =
                FlxG.random.int(0, 1) == 0
                    ? 0
                    : 2;
        }
    }
    else
    {
        var nextTarget:Int =
            FlxG.random.int(0, 1);

        if (nextTarget >= previousTarget)
            nextTarget++;

        activeLookAroundRoomTarget =
            nextTarget;
    }

    setLookAroundRoomHitboxesVisible(
        lookAroundActive
    );

    lookAroundTimedTarget =
        activeLookAroundRoomTarget;

    lookAroundTargetTimeRemaining =
        targetDuration;
}

function scheduleNextLookAroundRoomTarget()
{
    if (lookAroundTargetSpawnTimer != null)
    {
        lookAroundTargetSpawnTimer.cancel();
        lookAroundTargetSpawnTimer = null;
    }

    // Hide the Sixbones that was just shot while waiting for the next one.
    activeLookAroundRoomTarget = -1;
    lookAroundTimedTarget = -1;
    lookAroundTargetTimeRemaining = 0.0;
    setLookAroundRoomHitboxesVisible(false);

    var spawnDelay:Float =
        FlxG.random.float(1.0, 3.0);

    lookAroundTargetSpawnTimer =
        new FlxTimer().start(
            spawnDelay,
            function(_)
            {
                lookAroundTargetSpawnTimer = null;

                if (!lookAroundActive)
                    return;

                // cameraRoom uses -1/0/1 while the targets use 0/1/2.
                // Passing the viewed room as the excluded target guarantees
                // the new Sixbones appears in one of the other two rooms.
                var viewedTarget:Int = cameraRoom + 1;

                if (viewedTarget < 0 || viewedTarget > 2)
                    viewedTarget = 1;

                chooseNextLookAroundRoomTarget(
                    viewedTarget,
                    4.0,
                    true
                );

                fadeInActiveLookAroundRoomTarget();
            }
        );
}

function fadeInActiveLookAroundRoomTarget()
{
    if (lookAroundTargetFadeTween != null)
    {
        lookAroundTargetFadeTween.cancel();
        lookAroundTargetFadeTween = null;
    }

    var target:FlxSprite = null;

    switch (activeLookAroundRoomTarget)
    {
        case 0:
            target = sb_left;

        case 1:
            target = sb_front;

        case 2:
            target = sb_right;
    }

    if (target == null)
        return;

    target.alpha = 0.0;

    lookAroundTargetFadeTween =
        FlxTween.tween(
            target,
            {alpha: 1.0},
            0.25,
            {
                ease: FlxEase.linear,
                onComplete: function(_)
                {
                    lookAroundTargetFadeTween = null;
                }
            }
        );
}

function updateLookAroundTargetDeadline(elapsed:Float)
{
    if (!FlxG.save.data.mechanics)
        return;

    if (
        !lookAroundActive ||
        lookAroundTargetTimeRemaining <= 0.0
    )
    {
        return;
    }

    if (
        cameraRoomTween != null ||
        lookAroundShooting
    )
    {
        return;
    }

    if (
        activeLookAroundRoomTarget !=
        lookAroundTimedTarget
    )
    {
        lookAroundTargetTimeRemaining = 0.0;
        lookAroundTimedTarget = -1;
        return;
    }

    lookAroundTargetTimeRemaining -= elapsed;

    if (lookAroundTargetTimeRemaining > 0.0)
        return;

    lookAroundTargetTimeRemaining = 0.0;
    lookAroundTimedTarget = -1;
    health = 0;
    gameOver();
}

function isMouseInsideLookAroundRoomHitbox():Bool
{
    if (camGame == null)
        return false;

    var mousePosition =
        FlxG.mouse.getWorldPosition(camGame);

    var insideActiveTarget:Bool = false;

    switch (activeLookAroundRoomTarget)
    {
        case 0:
            insideActiveTarget =
                left_room_hitbox != null &&
                left_room_hitbox.overlapsPoint(
                    mousePosition,
                    false,
                    camGame
                );

        case 1:
            insideActiveTarget =
                middle_room_hitbox != null &&
                middle_room_hitbox.overlapsPoint(
                    mousePosition,
                    false,
                    camGame
                );

        case 2:
            insideActiveTarget =
                right_room_hitbox != null &&
                right_room_hitbox.overlapsPoint(
                    mousePosition,
                    false,
                    camGame
                );
    }

    mousePosition.put();

    return insideActiveTarget;
}

function setQuickTimeObjectsVisible(visible:Bool)
{
    if (cursor2 != null)
        cursor2.visible = visible;

    if (quickTimeCursorOuter != null)
        quickTimeCursorOuter.visible = visible;

    if (quickTimePromptText != null)
        quickTimePromptText.visible =
            visible &&
            FlxG.save.data.mechanics;
}

public function shootQuickTimeEvent(useShootEffects:Bool = true)
{
    if (
        cursor2 == null ||
        quickTimeCursorOuter == null ||
        quickTimePromptText == null
    )
    {
        return;
    }

    FlxTween.cancelTweensOf(cursor2);
    FlxTween.cancelTweensOf(quickTimeCursorOuter);
    FlxTween.cancelTweensOf(quickTimeCursorOuter.scale);
    FlxTween.cancelTweensOf(quickTimePromptText);

    quickTimeActive = true;
    quickTimeUseShootEffects = useShootEffects;
    quickTimeElapsed = 0.0;
    quickTimeEndStep = curStep + quickTimeDurationSteps;

    var quickTimeTotalDuration:Float =
        (Conductor.stepCrochet / 1000.0) *
        quickTimeDurationSteps;

    // Leave the existing late hit window inside the 12-step lifetime.
    quickTimeApproachDuration = Math.max(
        0.01,
        quickTimeTotalDuration - quickTimeLateWindow
    );

    if (quickTimeUseShootEffects)
        FlxG.sound.play(
            Paths.sound("gun-reload"),
            0.6
        );

    quickTimeTargetScaleX = cursor2.scale.x;
    quickTimeTargetScaleY = cursor2.scale.y;

    cursor2.screenCenter();
    cursor2.color = FlxColor.WHITE;
    cursor2.alpha = 0.0;

    quickTimeCursorOuter.setPosition(
        cursor2.x,
        cursor2.y
    );
    quickTimeCursorOuter.scale.set(
        quickTimeTargetScaleX * quickTimeStartingScaleMultiplier,
        quickTimeTargetScaleY * quickTimeStartingScaleMultiplier
    );
    quickTimeCursorOuter.color = FlxColor.WHITE;
    quickTimeCursorOuter.alpha = 0.0;

    quickTimePromptText.alpha = 0.0;
    quickTimePromptText.color = FlxColor.WHITE;
    quickTimePromptText.updateHitbox();
    quickTimePromptText.x = 0;
    quickTimePromptText.y =
        cursor2.y +
        cursor2.height +
        20;

    setQuickTimeObjectsVisible(true);

    FlxTween.tween(
        cursor2,
        {alpha: 0.5},
        0.20,
        {ease: FlxEase.quadOut}
    );

    FlxTween.tween(
        quickTimeCursorOuter,
        {alpha: 1.0},
        0.50,
        {ease: FlxEase.quadOut}
    );

    FlxTween.tween(
        quickTimePromptText,
        {alpha: 1.0},
        0.20,
        {ease: FlxEase.quadOut}
    );

    FlxTween.tween(
        quickTimeCursorOuter.scale,
        {
            x: quickTimeTargetScaleX,
            y: quickTimeTargetScaleY
        },
        quickTimeApproachDuration,
        {ease: FlxEase.linear}
    );
}

function finishShootQuickTimeEvent()
{
    quickTimeActive = false;
    quickTimeEndStep = -1;

    if (cursor2 != null)
    {
        cursor2.color = FlxColor.WHITE;

        FlxTween.tween(
            cursor2,
            {alpha: 0.0},
            0.15,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    setQuickTimeObjectsVisible(false);
                }
            }
        );
    }

    if (quickTimeCursorOuter != null)
        FlxTween.tween(
            quickTimeCursorOuter,
            {alpha: 0.0},
            0.15,
            {ease: FlxEase.quadOut}
        );

    if (quickTimePromptText != null)
    {
        quickTimePromptText.color = FlxColor.WHITE;

        FlxTween.tween(
            quickTimePromptText,
            {alpha: 0.0},
            0.15,
            {ease: FlxEase.quadOut}
        );
    }
}

function updateShootQuickTimeEvent(elapsed:Float)
{
    if (!quickTimeActive || cursor2 == null)
        return;

    quickTimeElapsed += elapsed;

    var windowStart:Float =
        quickTimeApproachDuration -
        quickTimeEarlyWindow;

    var windowEnd:Float =
        quickTimeApproachDuration +
        quickTimeLateWindow;

    var insideHitWindow:Bool =
        quickTimeElapsed >= windowStart &&
        quickTimeElapsed <= windowEnd;

    cursor2.color =
        insideHitWindow
            ? FlxColor.RED
            : FlxColor.WHITE;

    var shouldShoot:Bool =
        !FlxG.save.data.mechanics ||
        FlxG.keys.justPressed.SPACE;

    if (insideHitWindow && shouldShoot)
    {
        if (quickTimeUseShootEffects)
        {
            FlxG.sound.play(
                Paths.sound("gun-shoot"),
                1.0
            );

            triggerLookAroundStaticBurst();
        }

        finishShootQuickTimeEvent();
        return;
    }

}

function warmUpSixbonesThird()
{
    if (sixbonesThirdWarmup != null)
        return;

    sixbonesThirdWarmup = new Character(
        0,
        0,
        "sixbones_third",
        false
    );

    if (sixbonesThirdWarmup.graphic != null)
        sixbonesThirdWarmup.graphic.destroyOnNoUse = false;

    sixbonesThirdWarmup.scrollFactor.set(0, 0);
    sixbonesThirdWarmup.cameras = [camGame];
    sixbonesThirdWarmup.alpha = 0.0001;
    sixbonesThirdWarmup.screenCenter();
    add(sixbonesThirdWarmup);

    new FlxTimer().start(
        0.25,
        function(_)
        {
            if (sixbonesThirdWarmup == null)
                return;

            sixbonesThirdWarmup.visible = false;


            remove(sixbonesThirdWarmup, false);
            sixbonesThirdWarmup.destroy();
            sixbonesThirdWarmup = null;
        }
    );
}

function postCreate()
{
    health = maxHealth;

    dad.alpha = 0;

    customUI = [
        dustinHealthBG,
        dustinHealthBar,
        dustiniconP1,
        dustiniconP2,
        timeBarBG,
        timeTxt,
        timeBar,
        scoreTxt,
        missesTxt,
        accuracyTxt
    ];

    for (element in customUI)
    {
        if (element != null)
            element.alpha = 0;
    }

    camBorders = new FlxCamera();
    camBorders.bgColor = 0x00000000;

    camFailureText = new FlxCamera();
    camFailureText.bgColor = 0x00000000;

    FlxG.cameras.remove(camGame, false);
    FlxG.cameras.remove(camHUD, false);

    FlxG.cameras.add(camGame, true);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.add(camBorders, false);
    FlxG.cameras.add(camFailureText, false);

    if (Options.gameplayShaders)
    {
        tapeFailureText = createTapeShader(true);
        camFailureText.addShader(tapeFailureText);
    }

    cursor.cameras = [camHUD];
    cursor.scrollFactor.set(0, 0);
    cursor.screenCenter();


    left_room_hitbox = createLookAroundRoomHitbox(
        leftRoomHitboxX,
        leftRoomHitboxY,
        leftRoomHitboxWidth,
        leftRoomHitboxHeight,
        FlxColor.BLUE
    );

    middle_room_hitbox = createLookAroundRoomHitbox(
        middleRoomHitboxX,
        middleRoomHitboxY,
        middleRoomHitboxWidth,
        middleRoomHitboxHeight,
        FlxColor.RED
    );

    right_room_hitbox = createLookAroundRoomHitbox(
        rightRoomHitboxX,
        rightRoomHitboxY,
        rightRoomHitboxWidth,
        rightRoomHitboxHeight,
        FlxColor.YELLOW
    );

    var cursorIndex:Int = members.indexOf(cursor);

    if (cursorIndex >= 0)
    {
        insert(cursorIndex, left_room_hitbox);
        insert(cursorIndex + 1, middle_room_hitbox);
        insert(cursorIndex + 2, right_room_hitbox);
    }
    else
    {
        add(left_room_hitbox);
        add(middle_room_hitbox);
        add(right_room_hitbox);
    }

    cursor2.cameras = [camHUD];
    cursor2.scrollFactor.set(0, 0);
    cursor2.screenCenter();
    cursor2.color = FlxColor.WHITE;
    cursor2.alpha = 0.0;
    cursor2.visible = false;

    quickTimeCursorOuter = new FlxSprite();
    quickTimeCursorOuter.loadGraphic(cursor2.graphic);
    quickTimeCursorOuter.setPosition(cursor2.x, cursor2.y);
    quickTimeCursorOuter.scale.set(
        cursor2.scale.x,
        cursor2.scale.y
    );
    quickTimeCursorOuter.antialiasing = cursor2.antialiasing;
    quickTimeCursorOuter.scrollFactor.set(0, 0);
    quickTimeCursorOuter.cameras = [camHUD];
    quickTimeCursorOuter.alpha = 0.0;
    quickTimeCursorOuter.visible = false;

    var cursor2Index:Int = members.indexOf(cursor2);

    if (cursor2Index >= 0)
        insert(cursor2Index, quickTimeCursorOuter);
    else
        add(quickTimeCursorOuter);

    quickTimePromptText = new FunkinText(
        0,
        0,
        FlxG.width,
        "PRESS SPACE",
        40,
        true
    );
    quickTimePromptText.setFormat(
        Paths.font("Camera.ttf"),
        40,
        FlxColor.WHITE,
        FlxTextAlign.CENTER
    );
    quickTimePromptText.antialiasing = false;
    quickTimePromptText.scrollFactor.set(0, 0);
    quickTimePromptText.cameras = [camHUD];
    quickTimePromptText.alpha = 0.0;
    quickTimePromptText.visible = false;
    quickTimePromptText.updateHitbox();
    quickTimePromptText.y =
        cursor2.y +
        cursor2.height +
        20;
    add(quickTimePromptText);

    warning.cameras = [camHUD];
    warning.scrollFactor.set(0, 0);
    warning.screenCenter();
    warning.y -= 30;

    warningText = new FunkinText(
        0,
        0,
        FlxG.width,
        "LOOK AROUND YOU AND SHOOT IT",
        30,
        true
    );

    warningText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.CENTER,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    warningText.borderSize = 1.5;
    warningText.antialiasing = true;
    warningText.scrollFactor.set(0, 0);
    warningText.cameras = [camHUD];
    warningText.updateHitbox();
    warningText.screenCenter();
    warningText.y =
        warning.y +
        warning.height +
        -120;

    add(warningText);


    if (borders != null)
    {
        borders.cameras = [camBorders];
        borders.scrollFactor.set(0, 0);
        borders.screenCenter();

        box.cameras = [camBorders];
        box.scrollFactor.set(0, 0);
        box.screenCenter();
        box.x += 540;
        box.alpha = 0.5;

        box_left.cameras = [camBorders];
        box_left.scrollFactor.set(0, 0);
        box_left.screenCenter();
        box_left.x -= 540;
        box_left.flipX = true;
        box_left.alpha = 0.5;
    }

    createCameraButtonHitboxes();
    createCameraViewfinder();

    cameraTimerText = new FunkinText(
        0,
        0,
        300,
        "00:00:00:00",
        30,
        true
    );

    cameraTimerText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.RIGHT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraTimerText.borderSize = 1.5;
    cameraTimerText.antialiasing = true;
    cameraTimerText.scrollFactor.set(0, 0);
    cameraTimerText.cameras = [camHUD];

    cameraTimerText.updateHitbox();

    cameraTimerText.x =
        FlxG.width -
        cameraTimerText.width -
        cameraRightMargin;

    cameraTimerText.y =
        FlxG.height -
        cameraTimerText.height -
        cameraBottomMargin;

    add(cameraTimerText);

    cameraScoreText = new FunkinText(
        0,
        0,
        300,
        "SCORE: 0",
        20,
        true
    );

    cameraScoreText.setFormat(
        Paths.font("Camera.ttf"),
        15,
        FlxColor.WHITE,
        FlxTextAlign.RIGHT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraScoreText.borderSize = 1.25;
    cameraScoreText.antialiasing = true;
    cameraScoreText.scrollFactor.set(0, 0);
    cameraScoreText.cameras = [camHUD];

    cameraScoreText.updateHitbox();

    cameraScoreText.x =
        cameraTimerText.x;

    cameraScoreText.y =
        cameraTimerText.y -
        cameraScoreText.height -
        4;

    add(cameraScoreText);

    cameraMissesText = new FunkinText(
        0,
        0,
        300,
        "MISSES: 0",
        20,
        true
    );

    cameraMissesText.setFormat(
        Paths.font("Camera.ttf"),
        15,
        FlxColor.WHITE,
        FlxTextAlign.RIGHT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraMissesText.borderSize = 1.25;
    cameraMissesText.antialiasing = true;
    cameraMissesText.scrollFactor.set(0, 0);
    cameraMissesText.cameras = [camHUD];

    cameraMissesText.updateHitbox();

    cameraMissesText.x =
        cameraTimerText.x;

    cameraMissesText.y =
        cameraScoreText.y -
        cameraMissesText.height -
        2;

    add(cameraMissesText);

    cameraModeText = new FunkinText(
        0,
        0,
        120,
        "SLP",
        30,
        true
    );

    cameraModeText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.LEFT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraModeText.borderSize = 1.5;
    cameraModeText.antialiasing = true;
    cameraModeText.scrollFactor.set(0, 0);
    cameraModeText.cameras = [camHUD];

    cameraModeText.updateHitbox();

    cameraModeText.x =
        cameraLeftMargin;

    cameraModeText.y =
        FlxG.height -
        cameraModeText.height -
        cameraBottomMargin;

    add(cameraModeText);

    cameraPlayText = new FunkinText(
        0,
        0,
        120,
        "PLAY",
        30,
        true
    );

    cameraPlayText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.LEFT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraPlayText.borderSize = 1.5;
    cameraPlayText.antialiasing = true;
    cameraPlayText.scrollFactor.set(0, 0);
    cameraPlayText.cameras = [camHUD];

    cameraPlayText.updateHitbox();

    cameraPlayText.x =
        cameraLeftMargin;

    cameraPlayText.y =
        cameraTopMargin;

    add(cameraPlayText);

    cameraRatingText = new FunkinText(
        0,
        0,
        300,
        "SICK",
        30,
        true
    );

    cameraRatingText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.RIGHT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraRatingText.borderSize = 1.5;
    cameraRatingText.antialiasing = true;
    cameraRatingText.scrollFactor.set(0, 0);
    cameraRatingText.cameras = [camHUD];
    cameraRatingText.alpha = 0;

    cameraRatingText.updateHitbox();

    cameraRatingText.x =
        cameraMissesText.x;

    cameraRatingText.y =
        cameraPlayText.y;

    add(cameraRatingText);

    cameraRecText = new FunkinText(
        0,
        0,
        120,
        "REC",
        30,
        true
    );

    cameraRecText.setFormat(
        Paths.font("Camera.ttf"),
        30,
        FlxColor.WHITE,
        FlxTextAlign.LEFT,
        FlxTextBorderStyle.OUTLINE,
        FlxColor.BLACK
    );

    cameraRecText.borderSize = 1.5;
    cameraRecText.antialiasing = true;
    cameraRecText.scrollFactor.set(0, 0);
    cameraRecText.cameras = [camHUD];

    cameraRecText.updateHitbox();

    cameraRecText.x =
        cameraLeftMargin;

    cameraRecText.y =
        cameraPlayText.y +
        cameraPlayText.height +
        2;

    add(cameraRecText);

    cameraRecDot = new FlxSprite();

    cameraRecDot.makeGraphic(
        14,
        14,
        FlxColor.TRANSPARENT
    );

    FlxSpriteUtil.drawCircle(
        cameraRecDot,
        7,
        7,
        6,
        FlxColor.RED
    );

    cameraRecDot.antialiasing = true;
    cameraRecDot.scrollFactor.set(0, 0);
    cameraRecDot.cameras = [camHUD];

    cameraRecDot.x =
        cameraRecText.x +
        75;

    cameraRecDot.y =
        cameraRecText.y +
        (
            cameraRecText.height -
            cameraRecDot.height
        ) *
        0.5;

    add(cameraRecDot);

    hideDefaultRatings();
    createHealthVignette();
    activateLookAround(false);

    failurePhraseText = new FunkinText(
        0,
        0,
        FlxG.width,
        "",
        45,
        true
    );
    failurePhraseText.setFormat(
        Paths.font("8bit-jve.ttf"),
        45,
        FlxColor.RED,
        FlxTextAlign.CENTER
    );
    failurePhraseText.antialiasing = false;
    failurePhraseText.scrollFactor.set(0, 0);
    failurePhraseText.cameras = [camFailureText];
    failurePhraseText.visible = false;
    add(failurePhraseText);
    changeFailurePhrase();

    songStartBlackOverlay = new FlxSprite();
    songStartBlackOverlay.makeGraphic(
        FlxG.width,
        FlxG.height,
        FlxColor.BLACK
    );
    songStartBlackOverlay.scrollFactor.set(0, 0);
    songStartBlackOverlay.cameras = [camBorders];
    songStartBlackOverlay.alpha = 1;
    add(songStartBlackOverlay);

    warmUpSixbonesThird();

    redBeatOverlay = new FunkinSprite();
    redBeatOverlay.makeSolid(
        FlxG.width,
        FlxG.height,
        FlxColor.RED
    );
    redBeatOverlay.scrollFactor.set(0, 0);
    redBeatOverlay.zoomFactor = 0;
    redBeatOverlay.cameras = [camGame];
    redBeatOverlay.alpha = 0;
    add(redBeatOverlay);

    if (death_face != null)
    {
        death_face.cameras = [camHUD];
        death_face.scrollFactor.set(0, 0);
        death_face.screenCenter();
        death_face.alpha = 0.0;

        // Re-add it last so it draws above every other camHUD member.
        remove(death_face, false);
        add(death_face);
    }
}

function cancelLookAroundEffects()
{
    if (lookAroundTimer != null)
    {
        lookAroundTimer.cancel();
        lookAroundTimer = null;
    }

    if (lookAroundTargetSpawnTimer != null)
    {
        lookAroundTargetSpawnTimer.cancel();
        lookAroundTargetSpawnTimer = null;
    }

    if (lookAroundTargetFadeTween != null)
    {
        lookAroundTargetFadeTween.cancel();
        lookAroundTargetFadeTween = null;
    }

    if (sb_left != null)
        sb_left.alpha = 1.0;

    if (sb_front != null)
        sb_front.alpha = 1.0;

    if (sb_right != null)
        sb_right.alpha = 1.0;

    lookAroundTargetTimeRemaining = 0.0;
    lookAroundTimedTarget = -1;

    if (warningFadeTween != null)
    {
        warningFadeTween.cancel();
        warningFadeTween = null;
    }

    if (warningTextFadeTween != null)
    {
        warningTextFadeTween.cancel();
        warningTextFadeTween = null;
    }

    if (dadFadeTween != null)
    {
        dadFadeTween.cancel();
        dadFadeTween = null;
    }

    if (lookAroundStaticTween != null)
    {
        lookAroundStaticTween.cancel();
        lookAroundStaticTween = null;
    }

    if (lookAroundShootTimer != null)
    {
        lookAroundShootTimer.cancel();
        lookAroundShootTimer = null;
    }

    if (lookAroundShootFlashTween != null)
    {
        lookAroundShootFlashTween.cancel();
        lookAroundShootFlashTween = null;
    }

    if (lookAroundShootBlurTween != null)
    {
        lookAroundShootBlurTween.cancel();
        lookAroundShootBlurTween = null;
    }

    if (lookAroundShootFocusTween != null)
    {
        lookAroundShootFocusTween.cancel();
        lookAroundShootFocusTween = null;
    }

    if (lookAroundShootHeavyBlurTween != null)
    {
        lookAroundShootHeavyBlurTween.cancel();
        lookAroundShootHeavyBlurTween = null;
    }

    if (lookAroundShootExposureTween != null)
    {
        lookAroundShootExposureTween.cancel();
        lookAroundShootExposureTween = null;
    }

    if (lookAroundShootRecoilTween != null)
    {
        lookAroundShootRecoilTween.cancel();
        lookAroundShootRecoilTween = null;
    }

    if (lookAroundShootAngleTween != null)
    {
        lookAroundShootAngleTween.cancel();
        lookAroundShootAngleTween = null;
    }

    lookAroundShooting = false;
    lookAroundShootFocusBlur = 0.0;
    lookAroundShootHeavyBlur = 0.0;
    lookAroundShootExposure = 0.0;
    lookAroundShootRecoilY = 0.0;
    lookAroundShootRecoilAngle = 0.0;
    cameraRoomMotionBlur = 0.0;
    cameraRoomMotionDirection = 0.0;

    setLookAroundFlashOneAlpha(0.0);
    setLookAroundFlashTwoAlpha(0.0);
}

function setLookAroundFlashOneAlpha(value:Float)
{
    if (flash_1_middle != null)
        flash_1_middle.alpha = value;

    if (flash_1_left != null)
        flash_1_left.alpha = value;

    if (flash_1_right != null)
        flash_1_right.alpha = value;
}

function setLookAroundFlashTwoAlpha(value:Float)
{
    if (flash_2_middle != null)
        flash_2_middle.alpha = value;

    if (flash_2_left != null)
        flash_2_left.alpha = value;

    if (flash_2_right != null)
        flash_2_right.alpha = value;
}

function shootLookAround(direction:Float, force:Bool = false)
{
    if (
        (!lookAroundActive && !force) ||
        lookAroundShooting ||
        cameraRoomTween != null
    )
    {
        return;
    }

    lookAroundShooting = true;

    FlxG.sound.play(
        Paths.sound("gun-shoot"),
        1.0
    );

    setLookAroundFlashOneAlpha(1.0);
    setLookAroundFlashTwoAlpha(0.0);

    var recoilDirection:Float =
        direction == 0.0
            ? 1.0
            : direction;

    cameraRoomMotionDirection =
        recoilDirection;

    cameraRoomMotionBlur = 1.0;
    lookAroundShootFocusBlur = 1.0;
    lookAroundShootHeavyBlur = 1.0;
    lookAroundShootExposure = 1.0;
    lookAroundShootRecoilY = 0.0;
    lookAroundShootRecoilAngle = 0.0;

    shakeCamGameSafely(
        0.052,
        0.22
    );

    lookAroundShootBlurTween =
        FlxTween.num(
            1.0,
            0.0,
            0.95,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    lookAroundShootBlurTween = null;
                    cameraRoomMotionBlur = 0.0;

                    if (cameraRoomTween == null)
                        cameraRoomMotionDirection = 0.0;
                }
            },
            function(value:Float)
            {
                cameraRoomMotionBlur = value;
            }
        );

    lookAroundShootFocusTween =
        FlxTween.num(
            1.0,
            0.0,
            0.92,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    lookAroundShootFocusTween = null;
                    lookAroundShootFocusBlur = 0.0;
                }
            },
            function(value:Float)
            {
                lookAroundShootFocusBlur = value;
            }
        );

    lookAroundShootHeavyBlurTween =
        FlxTween.num(
            1.0,
            0.0,
            1.05,
            {
                ease: FlxEase.expoOut,
                onComplete: function(_)
                {
                    lookAroundShootHeavyBlurTween = null;
                    lookAroundShootHeavyBlur = 0.0;
                }
            },
            function(value:Float)
            {
                lookAroundShootHeavyBlur = value;
            }
        );

    lookAroundShootExposureTween =
        FlxTween.num(
            1.0,
            0.0,
            0.56,
            {
                ease: FlxEase.expoOut,
                onComplete: function(_)
                {
                    lookAroundShootExposureTween = null;
                    lookAroundShootExposure = 0.0;
                }
            },
            function(value:Float)
            {
                lookAroundShootExposure = value;
            }
        );

    lookAroundShootRecoilTween =
        FlxTween.num(
            0.0,
            -0.036,
            0.055,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    lookAroundShootRecoilTween =
                        FlxTween.num(
                            lookAroundShootRecoilY,
                            0.0,
                            0.34,
                            {
                                ease: FlxEase.backOut,
                                onComplete: function(_)
                                {
                                    lookAroundShootRecoilTween = null;
                                    lookAroundShootRecoilY = 0.0;
                                }
                            },
                            function(value:Float)
                            {
                                lookAroundShootRecoilY = value;
                            }
                        );
                }
            },
            function(value:Float)
            {
                lookAroundShootRecoilY = value;
            }
        );

    lookAroundShootAngleTween =
        FlxTween.num(
            0.0,
            recoilDirection * 0.522,
            0.065,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    lookAroundShootAngleTween =
                        FlxTween.num(
                            lookAroundShootRecoilAngle,
                            0.0,
                            0.30,
                            {
                                ease: FlxEase.backOut,
                                onComplete: function(_)
                                {
                                    lookAroundShootAngleTween = null;
                                    lookAroundShootRecoilAngle = 0.0;
                                }
                            },
                            function(value:Float)
                            {
                                lookAroundShootRecoilAngle = value;
                            }
                        );
                }
            },
            function(value:Float)
            {
                lookAroundShootRecoilAngle = value;
            }
        );

    lookAroundShootTimer =
        new FlxTimer().start(
            0.2,
            function(_)
            {
                lookAroundShootTimer = null;

                setLookAroundFlashOneAlpha(0.0);
                setLookAroundFlashTwoAlpha(1.0);

                lookAroundShootTimer =
                    new FlxTimer().start(
                        0.1,
                        function(_)
                        {
                            lookAroundShootTimer = null;
                            setLookAroundFlashTwoAlpha(0.0);
                            lookAroundShooting = false;
                        }
                    );
            }
        );
}

function triggerLookAroundStaticBurst()
{
    if (!Options.gameplayShaders)
        return;

    if (lookAroundStaticTween != null)
    {
        lookAroundStaticTween.cancel();
        lookAroundStaticTween = null;
    }

    lookAroundStaticBurst = 1.0;

    lookAroundStaticTween =
        FlxTween.num(
            1.0,
            0.0,
            1,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    lookAroundStaticBurst = 0.0;
                    lookAroundStaticTween = null;
                }
            },
            function(value:Float)
            {
                lookAroundStaticBurst = value;
            }
        );
}

function setLookAroundObjectsVisible(visible:Bool)
{
    if (box != null)
        box.visible = visible;

    if (box_left != null)
        box_left.visible = visible;

    if (cursor != null)
        cursor.visible = visible;

    if (warning != null)
        warning.visible = visible;

    if (warningText != null)
        warningText.visible = visible;

    if (cameraRightHitbox != null)
        cameraRightHitbox.visible =
            visible &&
            showCameraButtonHitboxes;

    if (cameraLeftHitbox != null)
        cameraLeftHitbox.visible =
            visible &&
            showCameraButtonHitboxes;
}

function setGameplayNotesVisible(visible:Bool)
{
    if (strumLines != null)
        strumLines.visible = visible;

    if (splashHandler != null)
        splashHandler.visible = visible;
}

function moveCameraBackToMiddle()
{
    if (
        camGame == null ||
        camFollow == null
    )
    {
        resetCameraRoom();
        return;
    }

    var previousRoom:Int =
        cameraRoom;

    var restoreFollowEnabled:Bool =
        cameraRoomTween != null
            ? cameraRoomRestoreFollowEnabled
            : camGame.followEnabled;

    if (cameraRoomTween != null)
    {
        cameraRoomTween.cancel();
        cameraRoomTween = null;
    }

    cameraRoom = 0;
    cameraRoomOffsetX = 0.0;
    applyCameraRoomOffset();

    cameraRoomRestoreFollowEnabled =
        restoreFollowEnabled;

    camGame.followEnabled = false;

    var targetScrollX:Float =
        camFollow.x -
        camGame.width *
        0.5;

    if (
        Math.abs(
            camGame.scroll.x -
            targetScrollX
        ) <= 0.5
    )
    {
        cameraRoomTilt = 0.0;
        cameraRoomMotionBlur = 0.0;
        cameraRoomMotionDirection = 0.0;
        cameraRoomLastAppliedOffsetX = 0.0;
        camGame.followEnabled =
            cameraRoomRestoreFollowEnabled;
        return;
    }

    var direction:Float =
        previousRoom > 0
            ? -1.0
            : previousRoom < 0
                ? 1.0
                : targetScrollX > camGame.scroll.x
                    ? 1.0
                    : -1.0;

    startHumanCameraRoomTween(
        targetScrollX,
        direction,
        true
    );
}

function activateLookAround(active:Bool)
{
    cancelLookAroundEffects();

    if (lookAroundInitialized)
        triggerLookAroundStaticBurst();

    lookAroundInitialized = true;
    lookAroundActive = active;
    lookAroundMouseInsideRoomHitbox = false;
    warningFlipTimer = 0.0;

    if (active)
    {
        chooseNextLookAroundRoomTarget(
            -1,
            10.0,
            false
        );
    }
    else
    {
        activeLookAroundRoomTarget = -1;
        setLookAroundRoomHitboxesVisible(false);
    }

    if (cursor != null)
        cursor.color = FlxColor.WHITE;

    if (!active)
    {
        setLookAroundObjectsVisible(false);
        setGameplayNotesVisible(true);

        if (warning != null)
        {
            warning.alpha = 0.8;
            warning.flipX = false;
        }

        if (warningText != null)
            warningText.alpha = 1.0;

        if (dad != null)
            dad.alpha = 1.0;

        moveCameraBackToMiddle();
        return;
    }

    if (warning != null)
    {
        warning.alpha = 0.8;
        warning.flipX = false;
    }

    if (warningText != null)
        warningText.alpha = 1.0;

    if (box != null)
        box.alpha = 0.5;

    if (box_left != null)
        box_left.alpha = 0.5;

    setLookAroundObjectsVisible(true);
    setGameplayNotesVisible(false);

    if (dad != null)
    {
        dadFadeTween =
            FlxTween.tween(
                dad,
                {
                    alpha: 0.0
                },
                0.65,
                {
                    ease: FlxEase.quadOut,
                    onComplete: function(_)
                    {
                        dadFadeTween = null;
                    }
                }
            );
    }

    lookAroundTimer =
        new FlxTimer().start(
            3.0,
            function(_)
            {
                lookAroundTimer = null;

                if (!lookAroundActive)
                    return;

                if (warning != null)
                {
                    warningFadeTween =
                        FlxTween.tween(
                            warning,
                            {
                                alpha: 0.0
                            },
                            0.65,
                            {
                                ease: FlxEase.quadOut,
                                onComplete: function(_)
                                {
                                    warningFadeTween = null;

                                    if (warning != null)
                                        warning.visible = false;
                                }
                            }
                        );
                }

                if (warningText != null)
                {
                    warningTextFadeTween =
                        FlxTween.tween(
                            warningText,
                            {
                                alpha: 0.0
                            },
                            0.65,
                            {
                                ease: FlxEase.quadOut,
                                onComplete: function(_)
                                {
                                    warningTextFadeTween = null;

                                    if (warningText != null)
                                        warningText.visible = false;
                                }
                            }
                        );
                }
            }
        );
}

function createHealthVignette()
{
    healthVignette = new FlxSprite(
        0,
        0
    );

    healthVignette.makeGraphic(
        FlxG.width,
        FlxG.height,
        FlxColor.TRANSPARENT,
        true
    );

    var vignetteLayers:Int = 78;
    var vignetteThickness:Float = 220.0;

    var layerThickness:Float =
        vignetteThickness /
        vignetteLayers;

    for (i in 0...vignetteLayers)
    {
        var progress:Float =
            i /
            vignetteLayers;

        var inset:Float =
            i *
            layerThickness;

        var fadeAmount:Float =
            Math.pow(
                1.0 -
                progress,
                2.4
            );

        var layerAlpha:Int =
            Std.int(
                70 *
                fadeAmount
            );

        var layerColor:FlxColor =
            FlxColor.fromRGB(
                255,
                0,
                0,
                layerAlpha
            );

        var horizontalWidth:Float =
            FlxG.width -
            inset *
            2;

        var verticalHeight:Float =
            FlxG.height -
            (
                inset +
                layerThickness
            ) *
            2;

        if (horizontalWidth > 0)
        {
            FlxSpriteUtil.drawRect(
                healthVignette,
                inset,
                inset,
                horizontalWidth,
                layerThickness,
                layerColor
            );

            FlxSpriteUtil.drawRect(
                healthVignette,
                inset,
                FlxG.height -
                inset -
                layerThickness,
                horizontalWidth,
                layerThickness,
                layerColor
            );
        }

        if (verticalHeight > 0)
        {
            FlxSpriteUtil.drawRect(
                healthVignette,
                inset,
                inset +
                layerThickness,
                layerThickness,
                verticalHeight,
                layerColor
            );

            FlxSpriteUtil.drawRect(
                healthVignette,
                FlxG.width -
                inset -
                layerThickness,
                inset +
                layerThickness,
                layerThickness,
                verticalHeight,
                layerColor
            );
        }
    }

    healthVignette.scrollFactor.set(
        0,
        0
    );

    healthVignette.cameras = [
        camHUD
    ];

    healthVignette.alpha = 0;
    healthVignette.visible = false;
    healthVignette.antialiasing = true;

    add(healthVignette);
}

function updateHealthVignette(elapsed:Float)
{
    if (healthVignette == null)
        return;

    if (deathTransitionActive)
    {
        healthVignette.alpha = 0.0;
        healthVignette.visible = false;
        return;
    }

    var safeMaxHealth:Float =
        Math.max(
            0.0001,
            maxHealth
        );

    var normalizedHealth:Float =
        health /
        safeMaxHealth;

    normalizedHealth =
        Math.max(
            0.0,
            Math.min(
                1.0,
                normalizedHealth
            )
        );

    var healthLost:Float =
        1.0 -
        normalizedHealth;

    var targetAlpha:Float =
        Math.pow(
            healthLost,
            1.35
        ) *
        vignetteMaximumAlpha;

    if (healthLost <= 0.0001)
        targetAlpha = 0;

    var response:Float =
        1.0 -
        Math.exp(
            -9.0 *
            elapsed
        );

    healthVignette.alpha +=
        (
            targetAlpha -
            healthVignette.alpha
        ) *
        response;

    healthVignette.visible =
        healthVignette.alpha >
        0.001;
}

function hideDefaultRatings()
{
    if (ratingsGroup != null)
    {
        ratingsGroup.alpha = 0;
        ratingsGroup.visible = false;
    }
}

function createCameraViewfinder()
{
    var leftX:Float =
        cameraLeftMargin -
        cameraFrameHorizontalGap;

    var rightX:Float =
        FlxG.width -
        cameraRightMargin +
        cameraFrameHorizontalGap;

    var topY:Float =
        cameraTopMargin -
        cameraFrameVerticalGap;

    var bottomY:Float =
        FlxG.height -
        cameraBottomMargin +
        cameraFrameVerticalGap;

    createCameraFramePiece(
        leftX,
        topY,
        cameraFrameLength,
        cameraFrameThickness
    );

    createCameraFramePiece(
        leftX,
        topY,
        cameraFrameThickness,
        cameraFrameLength
    );

    createCameraFramePiece(
        rightX - cameraFrameLength,
        topY,
        cameraFrameLength,
        cameraFrameThickness
    );

    createCameraFramePiece(
        rightX - cameraFrameThickness,
        topY,
        cameraFrameThickness,
        cameraFrameLength
    );

    createCameraFramePiece(
        leftX,
        bottomY - cameraFrameThickness,
        cameraFrameLength,
        cameraFrameThickness
    );

    createCameraFramePiece(
        leftX,
        bottomY - cameraFrameLength,
        cameraFrameThickness,
        cameraFrameLength
    );

    createCameraFramePiece(
        rightX - cameraFrameLength,
        bottomY - cameraFrameThickness,
        cameraFrameLength,
        cameraFrameThickness
    );

    createCameraFramePiece(
        rightX - cameraFrameThickness,
        bottomY - cameraFrameLength,
        cameraFrameThickness,
        cameraFrameLength
    );
}

function createCameraFramePiece(
    x:Float,
    y:Float,
    width:Int,
    height:Int
)
{
    var piece = new FlxSprite(
        x,
        y
    );

    piece.makeGraphic(
        width,
        height,
        FlxColor.WHITE
    );

    piece.scrollFactor.set(
        0,
        0
    );

    piece.cameras = [
        camHUD
    ];

    piece.antialiasing = false;

    add(piece);
}

function resetCameraRoom()
{
    var previousOffsetX:Float =
        cameraRoomOffsetX;

    if (cameraRoomTween != null)
    {
        cameraRoomTween.cancel();
        cameraRoomTween = null;

        if (camGame != null)
            camGame.followEnabled =
                cameraRoomRestoreFollowEnabled;
    }

    cameraRoomTilt = 0.0;
    cameraRoomDip = 0.0;
    cameraRoomMotionBlur = 0.0;
    cameraRoomMotionDirection = 0.0;

    cameraRoom = 0;
    cameraRoomOffsetX = 0.0;

    if (camFollow != null)
    {
        if (curCameraTarget >= 0)
            moveCamera();
        else
            camFollow.x -= previousOffsetX;
    }

    cameraRoomLastAppliedOffsetX = 0.0;
}

function startHumanCameraRoomTween(
    targetScrollX:Float,
    direction:Float,
    clearRoomOffsetAfter:Bool
)
{
    cameraRoomMotionBlur = 0.0;
    cameraRoomMotionDirection = direction;
    cameraRoomTilt = 0.0;

    cameraRoomTween =
        FlxTween.num(
            cameraRoomDip,
            cameraRoomDipAmount,
            cameraRoomDipDuration,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    startHumanCameraRoomPan(
                        targetScrollX,
                        direction,
                        clearRoomOffsetAfter
                    );
                }
            },
            function(value:Float)
            {
                cameraRoomDip = value;
            }
        );
}

function startHumanCameraRoomPan(
    targetScrollX:Float,
    direction:Float,
    clearRoomOffsetAfter:Bool
)
{
    var overshootX:Float =
        targetScrollX +
        direction *
        cameraRoomOvershootDistance;

    cameraRoomTween =
        FlxTween.tween(
            camGame.scroll,
            {
                x: overshootX
            },
            cameraRoomTweenDuration,
            {
                ease: FlxEase.sineInOut,
                onUpdate: function(tween:FlxTween)
                {
                    var progress:Float =
                        tween.percent;

                    var blurCurve:Float =
                        Math.sin(
                            progress *
                            Math.PI
                        );

                    cameraRoomMotionBlur =
                        Math.pow(
                            Math.max(
                                0.0,
                                blurCurve
                            ),
                            0.55
                        ) * 4;

                    var tiltProgress:Float =
                        Math.min(
                            1.0,
                            progress *
                            0.88
                        );

                    cameraRoomTilt =
                        direction *
                        cameraRoomTiltStrength *
                        Math.sin(
                            tiltProgress *
                            Math.PI *
                            0.72
                        );
                },
                onComplete: function(_)
                {
                    var settleStartTilt:Float =
                        cameraRoomTilt;

                    var settleStartDip:Float =
                        cameraRoomDip;

                    cameraRoomMotionDirection =
                        -direction;

                    cameraRoomTween =
                        FlxTween.tween(
                            camGame.scroll,
                            {
                                x: targetScrollX
                            },
                            cameraRoomSettleDuration,
                            {
                                ease: FlxEase.sineOut,
                                onUpdate: function(settleTween:FlxTween)
                                {
                                    var remaining:Float =
                                        1.0 -
                                        settleTween.percent;

                                    cameraRoomMotionBlur =
                                        remaining *
                                        0.8;

                                    cameraRoomTilt =
                                        settleStartTilt *
                                        remaining;

                                    cameraRoomDip =
                                        settleStartDip *
                                        remaining;
                                },
                                onComplete: function(_)
                                {
                                    cameraRoomTilt = 0.0;
                                    cameraRoomDip = 0.0;
                                    cameraRoomMotionBlur = 0.0;
                                    cameraRoomMotionDirection = 0.0;

                                    if (clearRoomOffsetAfter)
                                        cameraRoomLastAppliedOffsetX = 0.0;

                                    cameraRoomTween = null;

                                    camGame.followEnabled =
                                        cameraRoomRestoreFollowEnabled;
                                }
                            }
                        );
                }
            }
        );
}

function moveCameraSides(moveRight:Bool)
{
    if (
        cameraRoomTween != null &&
        cameraRoomTween.finished
    )
    {
        cameraRoomTween = null;
        cameraRoomTilt = 0.0;
        cameraRoomDip = 0.0;
        cameraRoomMotionBlur = 0.0;
        cameraRoomMotionDirection = 0.0;

        if (camGame != null)
            camGame.followEnabled =
                cameraRoomRestoreFollowEnabled;
    }

    if (cameraRoomTween != null)
        return;

    var nextRoom:Int =
        cameraRoom +
        (moveRight ? 1 : -1);

    if (nextRoom < -1 || nextRoom > 1)
        return;

    if (camGame == null || camFollow == null)
        return;

    cameraRoom = nextRoom;
    cameraRoomOffsetX =
        cameraRoom *
        cameraRoomDistance;

    applyCameraRoomOffset();

    cameraRoomRestoreFollowEnabled =
        camGame.followEnabled;

    camGame.followEnabled = false;

    var direction:Float =
        moveRight
            ? 1.0
            : -1.0;

    var targetScrollX:Float =
        camFollow.x -
        camGame.width *
        0.5;

    startHumanCameraRoomTween(
        targetScrollX,
        direction,
        false
    );
}

function applyCameraRoomOffset()
{
    if (camFollow == null || camGame == null)
        return;

    if (curCameraTarget >= 0)
    {


        moveCamera();
    }
    else
    {

        camFollow.x +=
            cameraRoomOffsetX -
            cameraRoomLastAppliedOffsetX;
    }

    cameraRoomLastAppliedOffsetX =
        cameraRoomOffsetX;
}

function onCameraMove(event)
{
    if (event == null || event.position == null)
        return;

    event.position.x +=
        cameraRoomOffsetX;
}


function onSongStart()
{
    dadIntroFadeStarted = false;

    if (dad != null)
        dad.alpha = 0;

    if (songStartBlackTween != null)
    {
        songStartBlackTween.cancel();
        songStartBlackTween = null;
    }

    if (songStartBlackOverlay != null)
    {
        songStartBlackOverlay.visible = true;
        songStartBlackOverlay.alpha = 1;

        songStartBlackTween = FlxTween.tween(
            songStartBlackOverlay,
            {alpha: 0},
            3.0,
            {
                ease: FlxEase.quadOut,
                onComplete: function(_)
                {
                    songStartBlackTween = null;

                    if (songStartBlackOverlay != null)
                        songStartBlackOverlay.visible = false;
                }
            }
        );
    }

    resetCameraRoom();

    health = maxHealth;

    cameraAnimatedZoom =
        cameraBaseZoom;

    cameraAnimatedOffsetY =
        0.0;

    cameraFocusBlur =
        0.0;

    if (healthVignette != null)
    {
        healthVignette.alpha = 0;
        healthVignette.visible = false;
    }

    cameraTimerTime = 0.0;
    cameraTimerRunning = true;

    if (cameraTimerText != null)
        cameraTimerText.text = "00:00:00:00";
}

function postUpdate(elapsed:Float)
{
    if (!dadIntroFadeStarted && dad != null)
        dad.alpha = 0;

    if (camGame != null && camFailureText != null)
    {
        DustinUtil.copyCamera(camGame, camFailureText);

        camFailureText.setPosition(
            camGame.x +
            (
                camGame.flashSprite.x -
                (
                    camGame.x * FlxG.scaleMode.scale.x +
                    camGame._flashOffset.x
                )
            ),
            camGame.y +
            (
                camGame.flashSprite.y -
                (
                    camGame.y * FlxG.scaleMode.scale.y +
                    camGame._flashOffset.y
                )
            )
        );
    }

}

function camEnemyZoom(zoomToEnemy:Bool)
{
    if (
        !Options.gameplayShaders ||
        tapeGame == null
    )
    {
        return;
    }

    cameraZoomSequence++;

    var sequence:Int =
        cameraZoomSequence;

    cancelCameraZoomTweens();

    var targetZoom:Float =
        zoomToEnemy
            ? cameraEnemyZoomLevel
            : cameraBaseZoom;

    var targetOffsetY:Float =
        zoomToEnemy
            ? cameraEnemyOffsetY
            : 0.0;

    var overshootZoom:Float =
        zoomToEnemy
            ? targetZoom + 0.013
            : targetZoom - 0.010;

    var overshootOffsetY:Float =
        zoomToEnemy
            ? targetOffsetY + 0.006
            : -0.004;

    cameraFocusTween =
        FlxTween.num(
            cameraFocusBlur,
            1.0,
            0.16,
            {
                ease: FlxEase.quadOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraFocusBlur = value;
            }
        );

    cameraZoomTween =
        FlxTween.num(
            cameraAnimatedZoom,
            overshootZoom,
            0.52,
            {
                ease: FlxEase.sineInOut,
                onComplete: function(_)
                {
                    if (sequence != cameraZoomSequence)
                        return;

                    startCameraFocusCorrection(
                        sequence,
                        targetZoom,
                        targetOffsetY,
                        zoomToEnemy
                    );
                }
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedZoom = value;
            }
        );

    cameraMoveTween =
        FlxTween.num(
            cameraAnimatedOffsetY,
            overshootOffsetY,
            0.52,
            {
                ease: FlxEase.sineInOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedOffsetY = value;
            }
        );
}

function startCameraFocusCorrection(
    sequence:Int,
    targetZoom:Float,
    targetOffsetY:Float,
    zoomToEnemy:Bool
)
{
    var firstCorrectionZoom:Float =
        zoomToEnemy
            ? targetZoom - 0.009
            : targetZoom + 0.008;

    var firstCorrectionOffsetY:Float =
        zoomToEnemy
            ? targetOffsetY - 0.004
            : 0.003;

    cameraFocusTween =
        FlxTween.num(
            cameraFocusBlur,
            0.46,
            0.18,
            {
                ease: FlxEase.quadOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraFocusBlur = value;
            }
        );

    cameraZoomTween =
        FlxTween.num(
            cameraAnimatedZoom,
            firstCorrectionZoom,
            0.18,
            {
                ease: FlxEase.quadInOut,
                onComplete: function(_)
                {
                    if (sequence != cameraZoomSequence)
                        return;

                    finishCameraFocusCorrection(
                        sequence,
                        targetZoom,
                        targetOffsetY,
                        zoomToEnemy
                    );
                }
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedZoom = value;
            }
        );

    cameraMoveTween =
        FlxTween.num(
            cameraAnimatedOffsetY,
            firstCorrectionOffsetY,
            0.18,
            {
                ease: FlxEase.quadInOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedOffsetY = value;
            }
        );
}

function finishCameraFocusCorrection(
    sequence:Int,
    targetZoom:Float,
    targetOffsetY:Float,
    zoomToEnemy:Bool
)
{
    var secondCorrectionZoom:Float =
        zoomToEnemy
            ? targetZoom + 0.005
            : targetZoom - 0.004;

    var secondCorrectionOffsetY:Float =
        zoomToEnemy
            ? targetOffsetY + 0.002
            : -0.0015;

    cameraFocusTween =
        FlxTween.num(
            cameraFocusBlur,
            0.18,
            0.13,
            {
                ease: FlxEase.quadOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraFocusBlur = value;
            }
        );

    cameraZoomTween =
        FlxTween.num(
            cameraAnimatedZoom,
            secondCorrectionZoom,
            0.13,
            {
                ease: FlxEase.quadInOut,
                onComplete: function(_)
                {
                    if (sequence != cameraZoomSequence)
                        return;

                    settleCameraFocus(
                        sequence,
                        targetZoom,
                        targetOffsetY
                    );
                }
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedZoom = value;
            }
        );

    cameraMoveTween =
        FlxTween.num(
            cameraAnimatedOffsetY,
            secondCorrectionOffsetY,
            0.13,
            {
                ease: FlxEase.quadInOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedOffsetY = value;
            }
        );
}

function settleCameraFocus(
    sequence:Int,
    targetZoom:Float,
    targetOffsetY:Float
)
{
    cameraFocusTween =
        FlxTween.num(
            cameraFocusBlur,
            0.0,
            0.17,
            {
                ease: FlxEase.quadOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraFocusBlur = value;
            }
        );

    cameraZoomTween =
        FlxTween.num(
            cameraAnimatedZoom,
            targetZoom,
            0.17,
            {
                ease: FlxEase.sineOut,
                onComplete: function(_)
                {
                    if (sequence != cameraZoomSequence)
                        return;

                    cameraAnimatedZoom =
                        targetZoom;

                    cameraAnimatedOffsetY =
                        targetOffsetY;

                    cameraFocusBlur =
                        0.0;

                    cameraZoomTween =
                        null;

                    cameraFocusTween =
                        null;

                    cameraMoveTween =
                        null;
                }
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedZoom = value;
            }
        );

    cameraMoveTween =
        FlxTween.num(
            cameraAnimatedOffsetY,
            targetOffsetY,
            0.17,
            {
                ease: FlxEase.sineOut
            },
            (value:Float) ->
            {
                if (sequence == cameraZoomSequence)
                    cameraAnimatedOffsetY = value;
            }
        );
}

function cancelCameraZoomTweens()
{
    if (cameraZoomTween != null)
    {
        cameraZoomTween.cancel();
        cameraZoomTween = null;
    }

    if (cameraFocusTween != null)
    {
        cameraFocusTween.cancel();
        cameraFocusTween = null;
    }

    if (cameraMoveTween != null)
    {
        cameraMoveTween.cancel();
        cameraMoveTween = null;
    }
}

function onPlayerHit(event):Void
{
    if (event == null || event.note == null)
        return;

    var note = event.note;

    if (note.isSustainNote)
        return;

    if (cameraRatingText != null)
    {
        var displayedRating:String = "SICK";

        switch (event.rating)
        {
            case "sick":
                displayedRating = "SICK";

            case "good":
                displayedRating = "GOOD";

            case "bad":
                displayedRating = "BAD";

            case "shit":
                displayedRating = "SHIT";
        }

        FlxTween.cancelTweensOf(
            cameraRatingText
        );

        cameraRatingText.text =
            displayedRating;

        cameraRatingText.alpha =
            1;

        FlxTween.tween(
            cameraRatingText,
            {
                alpha: 0
            },
            0.5,
            {
                ease: FlxEase.quadOut
            }
        );
    }

    if (!Options.gameplayShaders)
        return;

    noteHitHoldTimer =
        noteHitHoldDuration;

    switch (note.direction)
    {
        case 0:
            noteHitX =
                Math.min(
                    0.022,
                    noteHitX +
                    noteHitMoveStrength
                );

            noteHitAngle =
                Math.min(
                    0.060,
                    noteHitAngle +
                    noteHitAngleStrength
                );

            noteHitVelocityX = 0;
            noteHitVelocityAngle = 0;

        case 1:
            noteHitY =
                Math.min(
                    0.022,
                    noteHitY +
                    noteHitMoveStrength
                );

            noteHitVelocityY = 0;

        case 2:
            noteHitY =
                Math.max(
                    -0.022,
                    noteHitY -
                    noteHitMoveStrength
                );

            noteHitVelocityY = 0;

        case 3:
            noteHitX =
                Math.max(
                    -0.022,
                    noteHitX -
                    noteHitMoveStrength
                );

            noteHitAngle =
                Math.max(
                    -0.060,
                    noteHitAngle -
                    noteHitAngleStrength
                );

            noteHitVelocityX = 0;
            noteHitVelocityAngle = 0;
    }
}

function createCameraButtonHitboxes()
{
    if (
        box == null ||
        box_left == null ||
        camBorders == null
    )
    {
        return;
    }

    cameraRightHitbox =
        new FlxSprite();

    cameraRightHitbox.makeGraphic(
        cameraButtonHitboxWidth,
        cameraButtonHitboxHeight,
        FlxColor.fromRGB(
            0,
            255,
            0,
            110
        )
    );

    cameraRightHitbox.scrollFactor.set(
        0,
        0
    );

    cameraRightHitbox.cameras = [
        camBorders
    ];

    cameraRightHitbox.visible =
        showCameraButtonHitboxes;

    add(cameraRightHitbox);

    cameraLeftHitbox =
        new FlxSprite();

    cameraLeftHitbox.makeGraphic(
        cameraButtonHitboxWidth,
        cameraButtonHitboxHeight,
        FlxColor.fromRGB(
            0,
            140,
            255,
            110
        )
    );

    cameraLeftHitbox.scrollFactor.set(
        0,
        0
    );

    cameraLeftHitbox.cameras = [
        camBorders
    ];

    cameraLeftHitbox.visible =
        showCameraButtonHitboxes;

    add(cameraLeftHitbox);

    positionCameraButtonHitboxes();
}

function positionCameraButtonHitboxes()
{
    if (
        box != null &&
        cameraRightHitbox != null
    )
    {

        cameraRightHitbox.x =
            box.x +
            (
                box.width -
                cameraButtonHitboxWidth
            ) *
            0.5 +
            cameraRightHitboxOffsetX;

        cameraRightHitbox.y =
            box.y +
            (
                box.height -
                cameraButtonHitboxHeight
            ) *
            0.5 +
            cameraRightHitboxOffsetY;
    }

    if (
        box_left != null &&
        cameraLeftHitbox != null
    )
    {

        cameraLeftHitbox.x =
            box_left.x +
            (
                box_left.width -
                cameraButtonHitboxWidth
            ) *
            0.5 +
            cameraLeftHitboxOffsetX;

        cameraLeftHitbox.y =
            box_left.y +
            (
                box_left.height -
                cameraButtonHitboxHeight
            ) *
            0.5 +
            cameraLeftHitboxOffsetY;
    }
}

function isMouseOverCameraHitbox(hitbox:FlxSprite):Bool
{
    if (
        hitbox == null ||
        camBorders == null ||
        !hitbox.exists
    )
    {
        return false;
    }


    var mouseScreen =
        FlxG.mouse.getScreenPosition(
            camBorders
        );

    var hovering:Bool =
        hitbox.overlapsPoint(
            mouseScreen,
            true,
            camBorders
        );

    mouseScreen.put();

    return hovering;
}

function finishCameraRoomTweenIfNeeded()
{
    if (
        cameraRoomTween == null ||
        !cameraRoomTween.finished
    )
    {
        return;
    }

    cameraRoomTween = null;
    cameraRoomTilt = 0.0;
    cameraRoomDip = 0.0;
    cameraRoomMotionBlur = 0.0;
    cameraRoomMotionDirection = 0.0;

    if (camGame != null)
        camGame.followEnabled =
            cameraRoomRestoreFollowEnabled;
}

function update(elapsed:Float)
{
    updateShootQuickTimeEvent(elapsed);
    updateLookAroundTargetDeadline(elapsed);

    if (
        lookAroundActive &&
        warning != null &&
        warning.visible
    )
    {
        warningFlipTimer += elapsed;

        while (warningFlipTimer >= 0.5)
        {
            warningFlipTimer -= 0.5;
            warning.flipX = !warning.flipX;
        }
    }

    if (
        lookAroundActive &&
        cursor != null &&
        camHUD != null
    )
    {
        lookAroundMouseInsideRoomHitbox =
            isMouseInsideLookAroundRoomHitbox();

        setLookAroundRoomHitboxesVisible(true);

        cursor.color =
            lookAroundMouseInsideRoomHitbox
                ? FlxColor.RED
                : FlxColor.WHITE;

        var cursorMousePosition =
            FlxG.mouse.getScreenPosition(
                camHUD
            );

        cursor.x = cursorMousePosition.x - cursor.width * 0.5;


        cursor.y =
            camHUD.downscroll
                ? camHUD.height -
                    cursorMousePosition.y -
                    cursor.height * 0.5
                : cursorMousePosition.y -
                    cursor.height * 0.5;

        cursorMousePosition.put();
    }


    finishCameraRoomTweenIfNeeded();


    positionCameraButtonHitboxes();

    var hoveringRight:Bool =
        isMouseOverCameraHitbox(
            cameraRightHitbox
        );

    var hoveringLeft:Bool =
        isMouseOverCameraHitbox(
            cameraLeftHitbox
        );


    var canMoveRight:Bool =
        lookAroundActive &&
        !lookAroundShooting &&
        cameraRoomTween == null &&
        cameraRoom < 1;

    var canMoveLeft:Bool =
        lookAroundActive &&
        !lookAroundShooting &&
        cameraRoomTween == null &&
        cameraRoom > -1;

    if (box != null)
    {
        if (!canMoveRight)
            box.alpha = 0.1;
        else
            box.alpha =
                hoveringRight
                    ? 1.0
                    : 0.5;
    }

    if (box_left != null)
    {
        if (!canMoveLeft)
            box_left.alpha = 0.1;
        else
            box_left.alpha =
                hoveringLeft
                    ? 1.0
                    : 0.5;
    }

    if (cameraRightHitbox != null)
    {
        cameraRightHitbox.visible =
            lookAroundActive &&
            showCameraButtonHitboxes;

        if (!canMoveRight)
            cameraRightHitbox.alpha = 0.16;
        else
            cameraRightHitbox.alpha =
                hoveringRight
                    ? 0.75
                    : 0.38;
    }

    if (cameraLeftHitbox != null)
    {
        cameraLeftHitbox.visible =
            lookAroundActive &&
            showCameraButtonHitboxes;

        if (!canMoveLeft)
            cameraLeftHitbox.alpha = 0.16;
        else
            cameraLeftHitbox.alpha =
                hoveringLeft
                    ? 0.75
                    : 0.38;
    }

    var leftMousePressed:Bool =
        FlxG.mouse.justPressed;

    var rightMousePressed:Bool =
        FlxG.mouse.justPressedRight;

    var leftClickedCameraButton:Bool =
        leftMousePressed &&
        (
            hoveringRight ||
            hoveringLeft
        );

    if (leftMousePressed)
    {
        if (
            hoveringRight &&
            canMoveRight
        )
        {
            moveCameraSides(true);
        }
        else if (
            hoveringLeft &&
            canMoveLeft
        )
        {
            moveCameraSides(false);
        }
    }

    if (
        lookAroundActive &&
        lookAroundMouseInsideRoomHitbox &&
        !lookAroundShooting &&
        cameraRoomTween == null &&
        (
            rightMousePressed ||
            (
                leftMousePressed &&
                !leftClickedCameraButton
            )
        )
    )
    {
        shootLookAround(
            rightMousePressed
                ? 1.0
                : -1.0
        );

        scheduleNextLookAroundRoomTarget();
    }

    hideDefaultRatings();
    updateHealthVignette(elapsed);

    if (
        failurePhraseText != null &&
        failurePhraseText.visible
    )
    {
        failurePhraseTimer += elapsed;

        while (failurePhraseTimer >= 0.05)
        {
            failurePhraseTimer -= 0.05;
            changeFailurePhrase();
        }
    }

    if (!vhsAnimationFrozen)
        shaderTime += elapsed;

    if (cameraTimerRunning && !vhsAnimationFrozen)
        cameraTimerTime += elapsed;

    if (cameraTimerText != null)
        cameraTimerText.text =
            formatCameraTime(
                cameraTimerTime
            );

    if (cameraScoreText != null)
        cameraScoreText.text =
            "SCORE: " +
            Std.string(songScore);

    if (cameraMissesText != null)
        cameraMissesText.text =
            "MISSES: " +
            Std.string(misses);

    if (!vhsAnimationFrozen)
    {
        recBlinkTimer += elapsed;

        while (recBlinkTimer >= 0.5)
        {
            recBlinkTimer -= 0.5;

            if (cameraRecDot != null)
                cameraRecDot.visible =
                    !cameraRecDot.visible;
        }
    }

    if (!Options.gameplayShaders)
        return;

    if (vhsAnimationFrozen)
        return;

    updateSafeCameraShake(elapsed);

    driftTimer -= elapsed;

    if (driftTimer <= 0)
    {
        driftTimer =
            FlxG.random.float(
                0.35,
                0.90
            );

        driftTargetX =
            FlxG.random.float(
                -0.00110,
                0.00110
            ) *
            wobbleStrength;

        driftTargetY =
            FlxG.random.float(
                -0.00082,
                0.00082
            ) *
            wobbleStrength;

        driftTargetAngle =
            FlxG.random.float(
                -0.00105,
                0.00105
            ) *
            wobbleStrength;
    }

    var positionSpring:Float =
        20.0;

    var positionDamping:Float =
        7.2;

    var angleSpring:Float =
        17.0;

    var angleDamping:Float =
        6.8;

    handheldVelocityX +=
        (
            driftTargetX -
            handheldX
        ) *
        positionSpring *
        elapsed;

    handheldVelocityY +=
        (
            driftTargetY -
            handheldY
        ) *
        positionSpring *
        elapsed;

    handheldVelocityAngle +=
        (
            driftTargetAngle -
            handheldAngle
        ) *
        angleSpring *
        elapsed;

    handheldVelocityX *=
        Math.exp(
            -positionDamping *
            elapsed
        );

    handheldVelocityY *=
        Math.exp(
            -positionDamping *
            elapsed
        );

    handheldVelocityAngle *=
        Math.exp(
            -angleDamping *
            elapsed
        );

    handheldX +=
        handheldVelocityX *
        elapsed;

    handheldY +=
        handheldVelocityY *
        elapsed;

    handheldAngle +=
        handheldVelocityAngle *
        elapsed;

    microTimer -= elapsed;

    if (microTimer <= 0)
    {
        microTimer =
            FlxG.random.float(
                0.065,
                0.150
            );

        microTargetX =
            FlxG.random.float(
                -0.00011,
                0.00011
            ) *
            wobbleStrength;

        microTargetY =
            FlxG.random.float(
                -0.000085,
                0.000085
            ) *
            wobbleStrength;

        microTargetAngle =
            FlxG.random.float(
                -0.000075,
                0.000075
            ) *
            wobbleStrength;
    }

    var microResponse:Float =
        Math.min(
            1.0,
            elapsed *
            18.0
        );

    microX +=
        (
            microTargetX -
            microX
        ) *
        microResponse;

    microY +=
        (
            microTargetY -
            microY
        ) *
        microResponse;

    microAngle +=
        (
            microTargetAngle -
            microAngle
        ) *
        microResponse;

    correctionTimer -= elapsed;

    if (correctionTimer <= 0)
    {
        correctionTimer =
            FlxG.random.float(
                0.85,
                2.10
            );

        handheldVelocityX +=
            FlxG.random.float(
                -0.00145,
                0.00145
            ) *
            wobbleStrength;

        handheldVelocityY +=
            FlxG.random.float(
                -0.00105,
                0.00105
            ) *
            wobbleStrength;

        handheldVelocityAngle +=
            FlxG.random.float(
                -0.00125,
                0.00125
            ) *
            wobbleStrength;
    }

    if (noteHitHoldTimer > 0)
    {
        noteHitHoldTimer -=
            elapsed;

        noteHitVelocityX = 0;
        noteHitVelocityY = 0;
        noteHitVelocityAngle = 0;
    }
    else
    {
        var notePositionSpring:Float =
            95.0;

        var notePositionDamping:Float =
            14.0;

        var noteAngleSpring:Float =
            105.0;

        var noteAngleDamping:Float =
            14.5;

        noteHitVelocityX +=
            -noteHitX *
            notePositionSpring *
            elapsed;

        noteHitVelocityY +=
            -noteHitY *
            notePositionSpring *
            elapsed;

        noteHitVelocityAngle +=
            -noteHitAngle *
            noteAngleSpring *
            elapsed;

        noteHitVelocityX *=
            Math.exp(
                -notePositionDamping *
                elapsed
            );

        noteHitVelocityY *=
            Math.exp(
                -notePositionDamping *
                elapsed
            );

        noteHitVelocityAngle *=
            Math.exp(
                -noteAngleDamping *
                elapsed
            );

        noteHitX +=
            noteHitVelocityX *
            elapsed;

        noteHitY +=
            noteHitVelocityY *
            elapsed;

        noteHitAngle +=
            noteHitVelocityAngle *
            elapsed;
    }

    var finalWobbleX:Float =
        handheldX +
        microX +
        noteHitX +
        safeCameraShakeX;

    var finalWobbleY:Float =
        handheldY +
        microY +
        noteHitY +
        cameraAnimatedOffsetY +
        cameraRoomDip +
        lookAroundShootRecoilY +
        safeCameraShakeY;

    var finalWobbleAngle:Float =
        handheldAngle +
        microAngle +
        noteHitAngle +
        cameraRoomTilt +
        lookAroundShootRecoilAngle;

    finalWobbleX =
        Math.max(
            -0.0260,
            Math.min(
                0.0260,
                finalWobbleX
            )
        );

    finalWobbleY =
        Math.max(
            -0.0750,
            Math.min(
                0.0750,
                finalWobbleY
            )
        );

    finalWobbleAngle =
        Math.max(
            -0.0700,
            Math.min(
                0.0700,
                finalWobbleAngle
            )
        );

    updateTapeShader(
        tapeGame,
        finalWobbleX,
        finalWobbleY,
        finalWobbleAngle,
        cameraAnimatedZoom,
        Math.min(
            1.0,
            cameraFocusBlur +
            lookAroundShootFocusBlur +
            jumpscareLoopBlur
        ),
        cameraRoomMotionBlur,
        cameraRoomMotionDirection,
        lookAroundStaticBurst,
        lookAroundShootHeavyBlur
    );

    updateTapeShader(
        tapeHUD,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        lookAroundStaticBurst,
        lookAroundShootHeavyBlur
    );

    updateTapeShader(
        tapeFailureText,
        finalWobbleX,
        finalWobbleY,
        finalWobbleAngle,
        cameraAnimatedZoom,
        Math.min(
            1.0,
            cameraFocusBlur +
            lookAroundShootFocusBlur +
            jumpscareLoopBlur
        ),
        cameraRoomMotionBlur,
        cameraRoomMotionDirection,
        lookAroundStaticBurst,
        lookAroundShootHeavyBlur
    );

    applyCombinedExposure();
}

function formatCameraTime(totalTime:Float):String
{
    var hours:Int =
        Std.int(
            totalTime /
            3600
        );

    var minutes:Int =
        Std.int(
            totalTime /
            60
        ) %
        60;

    var seconds:Int =
        Std.int(
            totalTime
        ) %
        60;

    var hundredths:Int =
        Std.int(
            totalTime *
            100
        ) %
        100;

    return padTimeNumber(hours)
        + ":"
        + padTimeNumber(minutes)
        + ":"
        + padTimeNumber(seconds)
        + ":"
        + padTimeNumber(hundredths);
}

function padTimeNumber(value:Int):String
{
    if (value < 10)
        return "0" + value;

    return Std.string(value);
}

function updateTapeShader(
    shader:CustomShader,
    wobbleX:Float,
    wobbleY:Float,
    wobbleAngle:Float,
    wobbleZoom:Float,
    focusBlur:Float,
    motionBlurAmount:Float,
    motionBlurDirection:Float,
    staticBurst:Float,
    shootBlurAmount:Float
)
{
    if (shader == null)
        return;

    shader.time = shaderTime;

    shader.res = [
        FlxG.width,
        FlxG.height
    ];

    shader.handheldOffset = [
        wobbleX,
        wobbleY
    ];

    shader.handheldAngle =
        wobbleAngle;

    shader.handheldZoom =
        wobbleZoom;

    shader.focusBlur =
        focusBlur;

    shader.motionBlurAmount =
        motionBlurAmount;

    shader.motionBlurDirection =
        motionBlurDirection;

    shader.staticBurst =
        staticBurst;

    shader.shootBlurAmount =
        shootBlurAmount;
}

function updateExposureShader(
    shader:CustomShader,
    amount:Float
)
{
    if (shader == null)
        return;

    shader.amount =
        amount;
}
