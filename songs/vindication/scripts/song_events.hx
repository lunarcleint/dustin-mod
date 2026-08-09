
function stepHit(step:Int) {
    if (step == 16) {
        isGlitch = false;
        glitch.AMT = 0;
        shootBlast();
        
    }

    if (step == 2828 || step == 528 || step == 848 || step == 976 || step == 1040 || step == 1936 || step == 2224 || step == 2448 || step == 1936 || step == 2624 || step == 2656 || step == 2676 || step == 2696) {
        shootBlast();
    }

    if (step == 784) {
        isGlitch = true;
        isAngle = false;

        stage.stageSprites["bg"].visible = false;
        stage.stageSprites["fg"].visible = false;

        stage.stageSprites["bg_legacy"].visible = true;
        stage.stageSprites["il_legacy"].visible = true;
        stage.stageSprites["cinematic_bars_vin"].visible = true;

    }

    if (step == 1040) {
        isAngle = true;
        isGlitch = false;
        glitch.AMT = 0;

        stage.stageSprites["bg"].visible = true;
        stage.stageSprites["fg"].visible = true;

        stage.stageSprites["bg_legacy"].visible = false;
        stage.stageSprites["il_legacy"].visible = false;
        stage.stageSprites["cinematic_bars_vin"].visible = false;
    }

    if (step == 1680) {
        isGlitch = true;
        isGlitch2 = true;
    }

    if (step == 1936) {
        isGlitch = false;
        isGlitch2 = false;
        glitch.AMT = 0;
        glitch2.AMT = 0;
    }

    if (step == 2192) {
        isGlitch = true;
        isGlitch2 = true;
        stage.stageSprites["sanses_bg"].visible = true;
        stage.stageSprites["sanses_front"].visible = true;
    }

    if (step == 2448) {
        isGlitch = true;
        isGlitch2 = true;
        
    }

    if (step == 2432 || step == 2704) {
         isGlitch = false;
         isGlitch2 = false;
        glitch.AMT = 0;
        glitch2.AMT = 0;
    }

    if (step == 1296) {
        FlxTween.tween(stage.stageSprites["fg"], {alpha: 0}, 3, {ease: FlxEase.quadOut});
        FlxTween.tween(stage.stageSprites["bg"], {alpha: 0}, 3, {ease: FlxEase.quadOut});
        FlxTween.tween(dad, {alpha: 0}, 3, {ease: FlxEase.quadOut});
        stage.stageSprites["cinematic_bars_vin"].visible = true;
    }

    if (step == 1424) {
        FlxTween.tween(stage.stageSprites["fg"], {alpha: 1}, 10, {ease: FlxEase.quadOut});
        FlxTween.tween(stage.stageSprites["bg"], {alpha: 1}, 10, {ease: FlxEase.quadOut});
        FlxTween.tween(dad, {alpha: 1}, 10, {ease: FlxEase.quadOut});
    }

    if (step == 1552 || step == 1680 || step == 2192 || step == 2448) {
        FlxG.camera.shake(0.01, 0.2);
    }

    if (step == 528 || step == 1040 || step == 1680 || step == 2448) {
        starthittingthegriddy = true;
    }

    if (step == 783 || step == 1296 || step == 1936 || step == 2703) {
        starthittingthegriddy = false;

    }

    if (step == 1552 || step == 1616)
    {
        stage.stageSprites["cinematic_bars_vin"].visible = false;
        itslikeprettywarpedtoo.distortion = 2;

        FlxTween.num(2, 1, 0.5, {
            ease: FlxEase.quadOut}, 
            function(val:Float) {
                itslikeprettywarpedtoo.distortion = val;}

        );
    }

    if (step == 2444)
    {
        FlxTween.num(1, 3, 0.5, {
            ease: FlxEase.quadOut}, 
            function(val:Float) {
                itslikeprettywarpedtoo.distortion = val;}

        );
    }

    if (step == 1520)
    {
        stage.stageSprites["thero_appear"].visible = true;
        stage.stageSprites["thero_appear"].playAnim("thero_appear");
    }

    if (step == 1547)
    {
        gf.alpha = 1;
    }

    if (step == 272)
    {
        showTitleCard();
        stage.stageSprites["cinematic_bars_vin"].visible = false;

    }

    if (step == 272 || step == 304 || step == 336 || step == 368 || step == 400 || step == 432 || step == 464 || step == 496 || step == 576 || step == 592 || step == 704 || step == 720 || step == 2064 || step == 2192 || step == 2448 || step == 2480 || step == 2512 || step == 2544 || step == 2560 || step == 2569 || step == 2608 || step == 2640 || step == 2696) 
    {
        turnCam();
    }

    if (step = 2704)
    {
        stage.stageSprites["cinematic_bars_vin.visible"] = true;
    }

}
