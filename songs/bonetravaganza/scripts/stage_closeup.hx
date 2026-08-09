//
public var tvScreen:FlxCamera;
var fakeTV:FlxSprite;

var tvPosition:FlxPoint = null;
var tvSize:FlxPoint = null;
var tvWorldPosition:FlxPoint = null;
var tvSizeWorld:FlxPoint = null;

var originalTvWidth:Float = 1800;
var originalTvHeight:Float = 1000;

var tvScrollX:Float = 850;
var tvScrollY:Float = 1300;
var tvScrollZoom:Float = 1;

function create() {
    tvScreen = new FlxCamera(0, 0, originalTvWidth, originalTvHeight);
    tvScreen.rotateSprite = true; tvScreen.bgColor = 0xFF000000;

    insert_camera(tvScreen, 0, false);

    tvWorldPosition = FlxPoint.get(boyfriend.x - 660, boyfriend.y-650);
    tvSizeWorld = FlxPoint.get(tvWorldPosition.x + originalTvWidth, tvWorldPosition.y + originalTvHeight);

    tvPosition = FlxPoint.get();
    tvSize = FlxPoint.get();

    tvScreen.scroll.x = tvScrollX;
    tvScreen.scroll.y = tvScrollY;
    tvScreen.zoom = tvScrollZoom;

    FlxG.camera.bgColor = 0x00000000;

    oldstatic = new CustomShader("static");
    oldstatic.time = 0; oldstatic.strength = 7;

    tape_noise = new CustomShader("tapenoise");
    tape_noise.res = [FlxG.width, FlxG.height];
    tape_noise.time = 0; tape_noise.strength = 1;

    screenVignette = new CustomShader("coloredVignette");
    screenVignette.strength = .4; screenVignette.transperency = false;
    screenVignette.amount = .4;
    screenVignette.color = [0.0, 0.0, 0.0];

    if (Options.gameplayShaders) {
        if (FlxG.save.data.bloom) tvScreen.addShader(bloom_new);

        if (FlxG.save.data.saturation) {
            tvScreen.addShader(saturation);
            tvScreen.addShader(contrast);
        }

        if (FlxG.save.data.static) {
            tvScreen.addShader(oldstatic);
            tvScreen.addShader(tape_noise);
        }

        tvScreen.addShader(screenVignette);
    }
}

var ogTvWorldWidth:Int = 0;
var ogTvWorldHeight:Int = 0;

function postCreate() {
    scaleTVToWorld();

    ogTvWorldWidth = tvScreen.width;
    ogTvWorldHeight = tvScreen.height;
}

function update(elapsed:Float) {
    oldstatic.time += elapsed;
    tape_noise.time += elapsed;

    switch (curCameraTarget) {
        case 0:
            tvScrollX = 850; 
            tvScrollY = 1000; 
            tvScrollZoom = 1;
        case 4:
            tvScrollX = 1600; 
            tvScrollY = 1000; 
            tvScrollZoom = 1;
        case 2:
            tvScrollX = 850; 
            tvScrollY = 1300; 
            tvScrollZoom = 1;
        case 1:
            tvScrollX = 2250; 
            tvScrollY = 1300; 
            tvScrollZoom = 1.1;
    }

    tvScreen.visible = stage.stageSprites["tenna"].alpha != 1;

    // tvScreen.scroll.y = 1340 - (170*(.4 + Math.min(1, ((FlxG.camera.zoom/.45) - 1) * 6)));
    // tvScreen.zoom = .9;
}

function scaleTVToWorld() {
    pointToScreenPosition(tvWorldPosition, FlxG.camera, tvPosition);
    pointToScreenPosition(tvSizeWorld, FlxG.camera, tvSize);

    var tvScale:Float =  (tvSize.x - tvPosition.x) / (tvSizeWorld.x - tvWorldPosition.x);
    tvScreen.x = tvPosition.x; tvScreen.y = tvPosition.y;

    tvScreen.width = (tvSizeWorld.x - tvWorldPosition.x) * tvScale;
    tvScreen.height = (tvSizeWorld.y - tvWorldPosition.y) * tvScale;

    tvScreen.angle = FlxG.camera.angle;
}

function updateTVViewport() {
    tvScreen.scroll.x = tvScrollX;
    tvScreen.scroll.y = tvScrollY;
    tvScreen.zoom = tvScrollZoom;

    // tvScreen.zoom /= Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y)/1.5;
    tvScreen.zoom *= (tvScreen.height / ogTvWorldHeight);

    tvScreen.scroll.x += (ogTvWorldWidth - tvScreen.width) * tvScrollZoom;
    tvScreen.scroll.y += (ogTvWorldHeight - tvScreen.height) * tvScrollZoom;
}

function boundTvScreenY() {
    if (tvScreen.y < (1 * (1 / FlxG.scaleMode.scale.y))) { // FlxCameras draw 1 pixel above and 1 pixel below less for some reason... -lunar
        tvScreen.height += tvScreen.y;
        tvScreen.y = (1 * (1 / FlxG.scaleMode.scale.y));
    }

    // no need to account for overhang cause camera never gets that low!!
}

function boundTvScreenX() {
    if (tvScreen.x < 0) {
        tvScreen.width += tvScreen.x;
        tvScreen.x = 0;
    }

    var cameraEndX:Float = FlxG.scaleMode.offset.x + ((tvScreen.x + tvScreen.width)*FlxG.scaleMode.scale.x);
    var gameEndX:Float = FlxG.scaleMode.offset.x + FlxG.scaleMode.gameSize.x;

    if (cameraEndX > gameEndX) {
        tvScreen.width -= Math.ceil((cameraEndX - gameEndX) * (1 / FlxG.scaleMode.scale.x));
    }
}

function draw(_) {
    if (!camGame.visible || tvScreen == null || curVideo != null || !tvScreen.visible)
        return;

    scaleTVToWorld();
    if (!FlxG.fullScreen) {
        if (FlxG.scaleMode.offset.x > 0) boundTvScreenX();
        if (FlxG.scaleMode.offset.y > 0) boundTvScreenY();
    }
    updateTVViewport();

    for (member in members) {
        if (Std.isOfType(member, FlxSprite) && member.camera == FlxG.camera) {
            if (member.isOnScreen == null)
                continue;
            var oldCameras = member.cameras;

            if (member.alpha == 0 || !member.visible || member._frame?.type == 2) continue;

            if (!member.isOnScreen(tvScreen)) continue;

            if (member.isSimpleRender(tvScreen)) 
                member.drawSimple(tvScreen);
            else 
                member.drawComplex(tvScreen);
        }
    }
}

function destroy() {
    tvPosition.put();
    tvWorldPosition.put();
}

// TODO: from CNE dev, replace pointToScreenPosition with CoolUtil.pointToScreenPosition whenever it comes out -lunar
function pointToScreenPosition(object:FlxPoint, ?camera:FlxCamera, ?result:FlxPoint) {
    if (result == null)
        result = FlxPoint.get();
    if (camera == null)
        camera = FlxG.camera;

    result.set(object.x, object.y);
    result.x = (((result.x - camera.scroll.x) * camera.zoom) - ((camera.width * 0.5) * (camera.zoom - camera.initialZoom)));
    result.y = (((result.y - camera.scroll.y) * camera.zoom) - ((camera.height * 0.5) * (camera.zoom - camera.initialZoom)));

    object.putWeak();
    return result;
}

/**
    fakeTV = new FlxSprite().makeSolid(1, 1, 0xFFDC19EA);
    fakeTV.scale.set(1800, 1000); fakeTV.updateHitbox();
    fakeTV.setPosition(boyfriend.x-660, boyfriend.y-650);
    add(fakeTV); fakeTV.visible = false;
 */

function toggleTv(tv:String) {
    var enable:Int = -1;
    if (tv == "I LOVE TV I LOVE TV I LOVE TV I LOVE TV I LOVE TV!!!") enable = 1;
    if (tv == "I HATE TV I HATE TV I HATE TV I HATE TV I HATE TV!!!") enable = 0;

    var tenna:FlxSprite = stage.stageSprites["tenna"];
    if (enable == 1) {
        FlxTween.tween(tenna, {alpha: 0}, .65);
        FlxTween.num(60, 7, .8, null, (val:Float) -> {oldstatic.strength = val;});
    } else if (enable == 0) {
        FlxTween.tween(tenna, {alpha: 1}, .65);
    }
}