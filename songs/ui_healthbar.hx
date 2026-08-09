import Std;
import Xml;

import funkin.backend.utils.FlxInterpolateColor;

import flixel.math.FlxRect;

public var noMissIconAnim:Bool = false;
public var reverseIcons:Bool = false;

static var dustinHealthBG:FlxSprite;
static var dustinHealthBar:FlxSprite;

static var dustiniconP1:FlxSprite;
static var dustiniconP2:FlxSprite;

static var ogHealthColors:Array<Int> = [
    0xFF000000,
    0xFF000000
];

static var healthBarColors:Array<Int> = [
    0xFF000000,
    0xFF000000
];

public var __lerpColor:FlxInterpolateColor;

var cacheRect:FlxRect = new FlxRect();

var healthLossCooldown:Float = 0.2;
var healthLossTimer:Float = 0.0;

var __lastHealth:Float = 0.0;

public var lerpedHealth:Float = 0.0;
static var healthPrecent:Float = 50.0;

public var hurtColor:Float = 0xFF7F0000;

var __healthTween:FlxTween;
var __ratio:Float = 0.0;

function postCreate()
{
    lerpedHealth = health;
    __lastHealth = health;

    var safeMaxHealth:Float =
        Math.max(
            0.0001,
            maxHealth
        );

    healthPrecent =
        FlxMath.bound(
            health /
            safeMaxHealth *
            100,
            0,
            100
        );

    for (sprite in [
        healthBar,
        healthBarBG,
        iconP1,
        iconP2
    ])
    {
        if (sprite == null)
            continue;

        remove(sprite);

        sprite.visible = false;
        sprite.active = false;
        sprite.exists = false;
    }

    var healthBarSkin:String = "snowdin";

    if (
        stage != null &&
        stage.stageXML != null &&
        stage.stageXML.exists("healthBarSkin")
    )
    {
        healthBarSkin =
            stage.stageXML.get(
                "healthBarSkin"
            );
    }

    dustinHealthBG =
        createHealthBG(
            healthBarSkin
        );

    var leftColor:Int =
        dad != null &&
        dad.iconColor != null &&
        Options.colorHealthBar
            ? dad.iconColor
            : (
                PlayState.opponentMode
                    ? 0xFF66FF33
                    : 0xFFFF0000
            );

    var rightColor:Int =
        boyfriend != null &&
        boyfriend.iconColor != null &&
        Options.colorHealthBar
            ? boyfriend.iconColor
            : (
                PlayState.opponentMode
                    ? 0xFFFF0000
                    : 0xFF66FF33
            );

    healthBarColors = [
        leftColor,
        rightColor
    ];

    ogHealthColors = [
        leftColor,
        rightColor
    ];

    dustinHealthBar =
        createHealthFill(
            healthBarSkin
        );

    if (dustinHealthBar != null)
    {
        var barIndex:Int =
            members.indexOf(
                strumLines
            ) +
            1;

        if (barIndex < 0)
            barIndex = 0;

        insert(
            barIndex,
            dustinHealthBar
        );

        if (hudElements != null)
            hudElements.push(
                dustinHealthBar
            );
    }

    if (dustinHealthBG != null)
    {
        var backgroundIndex:Int =
            dustinHealthBar != null
                ? members.indexOf(
                    dustinHealthBar
                ) +
                1
                : members.indexOf(
                    strumLines
                ) +
                1;

        if (backgroundIndex < 0)
            backgroundIndex = 0;

        insert(
            backgroundIndex,
            dustinHealthBG
        );

        if (hudElements != null)
            hudElements.push(
                dustinHealthBG
            );
    }

    var playerIconName:String =
        boyfriend != null
            ? boyfriend.getIcon()
            : "face";

    var opponentIconName:String =
        dad != null
            ? dad.getIcon()
            : "face";

    for (index => iconName in [
        playerIconName,
        opponentIconName
    ])
    {
        var icon:FlxSprite =
            createHealthIcon(
                iconName,
                index == 0
            );

        if (icon == null)
            continue;

        updateIconXml(
            icon,
            iconName
        );

        switch (index)
        {
            case 0:
                dustiniconP1 = icon;

            case 1:
                dustiniconP2 = icon;
        }

        var iconIndex:Int =
            dustinHealthBG != null
                ? members.indexOf(
                    dustinHealthBG
                ) +
                1
                : members.indexOf(
                    strumLines
                ) +
                1;

        if (iconIndex < 0)
            iconIndex = 0;

        insert(
            iconIndex,
            icon
        );

        if (hudElements != null)
            hudElements.push(icon);

        if (
            index == 0 &&
            Options.gameplayShaders
        )
        {
            var iconShader:CustomShader =
                new CustomShader(
                    "iconshader"
                );

            if (iconShader != null)
            {
                icon.shader =
                    iconShader;

                iconShader.minBrightness =
                    0.2;

                iconShader.color = [
                    0.5,
                    0.0,
                    0.0
                ];

                iconShader.ratio =
                    0.0;
            }
        }
    }

    if (dustinHealthBar != null)
    {
        dustinHealthBar.onDraw = () ->
        {
            if (dustinHealthBar == null)
                return;

            var barWidth:Float =
                dustinHealthBar.width;

            var barHeight:Float =
                dustinHealthBar.height;

            if (
                barWidth <= 0 ||
                barHeight <= 0
            )
            {
                return;
            }

            var percentWidth:Float =
                barWidth *
                Math.abs(
                    1.0 -
                    healthPrecent /
                    100.0
                );

            percentWidth =
                FlxMath.bound(
                    percentWidth,
                    0,
                    barWidth
                );

            for (index => color in healthBarColors)
            {
                if (color == 0x00000000)
                    continue;

                switch (index)
                {
                    case 0:
                        cacheRect.set(
                            0,
                            2,
                            percentWidth,
                            Math.max(
                                0,
                                barHeight - 2
                            )
                        );

                    case 1:
                        cacheRect.set(
                            percentWidth,
                            2,
                            Math.max(
                                0,
                                barWidth -
                                percentWidth
                            ),
                            Math.max(
                                0,
                                barHeight - 2
                            )
                        );
                }

                dustinHealthBar.colorTransform.color =
                    color;

                dustinHealthBar.clipRect =
                    cacheRect;

                dustinHealthBar.draw();
            }

            dustinHealthBar.clipRect =
                null;
        };
    }

    __lerpColor =
        new FlxInterpolateColor(
            ogHealthColors[1]
        );
}

static function createHealthBG(
    image:String
):FlxSprite
{
    var background:FlxSprite =
        new FlxSprite(
            0,
            FlxG.height * 0.8 - 12
        );

    var imagePath:String =
        Paths.image(
            "game/ui/healthbar_" +
            image
        );

    if (Assets.exists(imagePath))
    {
        background.loadGraphic(
            imagePath
        );
    }
    else
    {
        background.makeGraphic(
            600,
            64,
            0xFF000000
        );
    }

    background.cameras = [
        camHUD
    ];

    background.scrollFactor.set();

    background.antialiasing =
        Options.antialiasing;

    background.screenCenter(
        FlxAxes.X
    );

    return background;
}

static function createHealthFill(
    image:String
):FlxSprite
{
    var backgroundX:Float =
        dustinHealthBG != null
            ? dustinHealthBG.x
            : 0;

    var backgroundY:Float =
        dustinHealthBG != null
            ? dustinHealthBG.y
            : FlxG.height * 0.8;

    var backgroundWidth:Float =
        dustinHealthBG != null &&
        dustinHealthBG.width > 92
            ? dustinHealthBG.width
            : 600;

    var fill:FlxSprite =
        new FlxSprite(
            backgroundX + 46,
            backgroundY +
            (
                camHUD.downscroll
                    ? 25
                    : 32
            )
        );

    var fillPath:String =
        Paths.image(
            "game/ui/healthbar_fill_" +
            image
        );

    if (Assets.exists(fillPath))
    {
        fill.loadGraphic(
            fillPath
        );
    }
    else
    {
        fill.makeGraphic(
            Std.int(
                Math.max(
                    1,
                    backgroundWidth - 92
                )
            ),
            18,
            0xFFFFFFFF
        );
    }

    fill.cameras = [
        camHUD
    ];

    fill.scrollFactor.set();

    fill.screenCenter(
        FlxAxes.X
    );

    return fill;
}

static function createHealthIcon(
    image:String,
    flip:Bool
):FlxSprite
{
    var iconName:String =
        image;

    var iconPath:String =
        Paths.image(
            "icons/" +
            iconName
        );

    if (!Assets.exists(iconPath))
    {
        iconName = "face";

        iconPath =
            Paths.image(
                "icons/face"
            );
    }

    var icon:FlxSprite =
        new FlxSprite();

    if (Assets.exists(iconPath))
    {
        icon.loadGraphic(
            iconPath,
            true,
            150,
            150
        );
    }
    else
    {
        icon.makeGraphic(
            150,
            150,
            0xFFFFFFFF
        );
    }

    var frameCount:Int = 1;

    if (
        icon.frames != null &&
        icon.frames.frames != null &&
        icon.frames.frames.length > 0
    )
    {
        frameCount =
            icon.frames.frames.length;
    }

    var animationFrames:Array<Int> = [];

    for (frame in 0...frameCount)
        animationFrames.push(frame);

    icon.animation.add(
        "health",
        animationFrames,
        0,
        false,
        flip
    );

    icon.animation.play(
        "health"
    );

    icon.antialiasing =
        Options.antialiasing;

    icon.scrollFactor.set();

    icon.scale.set(
        0.9,
        0.9
    );

    icon.updateHitbox();

    icon.cameras = [
        camHUD
    ];

    return icon;
}

static function updateIconXml(
    icon:FlxSprite,
    path:String
)
{
    if (icon == null)
        return;

    var xmlPath:String =
        Paths.getPath(
            "images/icons/" +
            path +
            ".xml"
        );

    if (!Assets.exists(xmlPath))
        return;

    var xmlText:String =
        Assets.getText(
            xmlPath
        );

    if (xmlText == null)
        return;

    var xmlData:Xml =
        Xml.parse(
            xmlText
        );

    if (xmlData == null)
        return;

    xmlData =
        xmlData.firstElement();

    if (xmlData == null)
        return;

    if (xmlData.exists("antialiasing"))
    {
        icon.antialiasing =
            xmlData
                .get("antialiasing")
                .toLowerCase() ==
            "true";
    }

    if (
        xmlData.exists("offsetX") &&
        xmlData.get("offsetX") != ""
    )
    {
        var offsetX:Float =
            Std.parseFloat(
                xmlData.get("offsetX")
            );

        if (!Math.isNaN(offsetX))
            icon.offset.x =
                -offsetX;
    }

    if (
        xmlData.exists("offsetY") &&
        xmlData.get("offsetY") != ""
    )
    {
        var offsetY:Float =
            Std.parseFloat(
                xmlData.get("offsetY")
            );

        if (!Math.isNaN(offsetY))
            icon.offset.y =
                -offsetY;
    }
}

function update(elapsed:Float)
{
    var safeMaxHealth:Float =
        Math.max(
            0.0001,
            maxHealth
        );

    var boundedHealth:Float =
        FlxMath.bound(
            health,
            0,
            safeMaxHealth
        );

    lerpedHealth =
        CoolUtil.fpsLerp(
            lerpedHealth,
            boundedHealth,
            1 / 4
        );

    healthPrecent =
        FlxMath.bound(
            lerpedHealth /
            safeMaxHealth *
            100,
            0,
            100
        );

    updateHealthColors();

    if (
        dustinHealthBar == null ||
        dustiniconP1 == null ||
        dustiniconP2 == null
    )
    {
        return;
    }

    var healthBarX:Float =
        dustinHealthBar.x;

    var healthBarWidth:Float =
        dustinHealthBar.width;

    var healthPosition:Float =
        FlxMath.remapToRange(
            healthPrecent,
            0,
            100,
            reverseIcons ? 0 : 1,
            reverseIcons ? 1 : 0
        );

    var firstIcon:FlxSprite =
        reverseIcons
            ? dustiniconP2
            : dustiniconP1;

    var secondIcon:FlxSprite =
        reverseIcons
            ? dustiniconP1
            : dustiniconP2;

    if (
        firstIcon == null ||
        secondIcon == null
    )
    {
        return;
    }

    firstIcon.x =
        healthBarX +
        healthBarWidth *
        healthPosition +
        2;

    secondIcon.x =
        healthBarX +
        healthBarWidth *
        healthPosition -
        secondIcon.width -
        2;

    for (icon in [
        firstIcon,
        secondIcon
    ])
    {
        if (icon == null)
            continue;

        icon.y =
            dustinHealthBar.y +
            dustinHealthBar.height /
            2 -
            icon.height /
            2 -
            (
                camHUD.downscroll
                    ? 0
                    : 20
            );
    }

    setIconFrame(
        firstIcon,
        reverseIcons
            ? (
                healthPrecent > 70
                    ? 1
                    : 0
            )
            : (
                healthPrecent < 35
                    ? 1
                    : 0
            )
    );

    setIconFrame(
        secondIcon,
        reverseIcons
            ? (
                healthPrecent < 35
                    ? 1
                    : 0
            )
            : (
                healthPrecent > 70
                    ? 1
                    : 0
            )
    );

    if (firstIcon.shader != null)
    {
        firstIcon.shader.ratio =
            __ratio;
    }

    if (secondIcon.shader != null)
    {
        secondIcon.shader.ratio =
            __ratio;
    }
}

function updateHealthColors()
{
    if (
        __lerpColor == null ||
        ogHealthColors == null ||
        ogHealthColors.length < 2 ||
        healthBarColors == null ||
        healthBarColors.length < 2
    )
    {
        return;
    }

    __lerpColor.color =
        hurtColor;

    __lerpColor.lerpTo(
        ogHealthColors[1],
        Math.abs(
            1 -
            __ratio
        )
    );

    healthBarColors[1] =
        __lerpColor.color;
}

static function setIconFrame(
    icon:FlxSprite,
    requestedFrame:Int
)
{
    if (
        icon == null ||
        icon.animation == null ||
        icon.animation.curAnim == null ||
        icon.animation.curAnim.frames == null
    )
    {
        return;
    }

    var frameCount:Int =
        icon.animation.curAnim.frames.length;

    if (frameCount <= 0)
        return;

    icon.animation.curAnim.curFrame =
        Std.int(
            FlxMath.bound(
                requestedFrame,
                0,
                frameCount - 1
            )
        );
}

function postUpdate(elapsed:Float)
{
    var currentHealth:Float =
        FlxMath.bound(
            health,
            0,
            Math.max(
                0.0001,
                maxHealth
            )
        );

    if (!noMissIconAnim)
    {
        if (__lastHealth > currentHealth)
        {
            healthLossTimer =
                healthLossCooldown;

            if (__healthTween != null)
                __healthTween.cancel();

            __healthTween =
                FlxTween.num(
                    0.75,
                    0,
                    healthLossCooldown * 4,
                    {},
                    (value:Float) ->
                    {
                        __ratio =
                            value;
                    }
                );
        }

        healthLossTimer -=
            elapsed;

        if (
            healthLossTimer > 0 &&
            dustiniconP1 != null
        )
        {
            iconShake(
                dustiniconP1,
                healthLossTimer /
                healthLossCooldown
            );

            setIconFrame(
                dustiniconP1,
                1
            );
        }
    }

    __lastHealth =
        currentHealth;
}

static function iconShake(
    icon:FlxSprite,
    amount:Float
)
{
    if (icon == null)
        return;

    var healthShake:Float =
        FlxEase.circOut(
            Math.min(
                amount,
                1
            )
        );

    icon.x +=
        FlxG.random.float(
            -healthShake * 4,
            healthShake * 4
        );

    icon.y +=
        FlxG.random.float(
            -healthShake * 4,
            healthShake * 4
        );
}