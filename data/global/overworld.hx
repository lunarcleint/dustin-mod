//

static var NEXT_ROOM:String = null;
static var NEXT_ENTERANCE:Int = -1;

static function overWorldTransition(fadeIn:Bool, complete:Void->Void) {
    var fade:FunkinSprite = new FunkinSprite(-FlxG.width/2, -FlxG.height/2).makeSolid(FlxG.width*2, FlxG.height*2, 0xFF000000);
    fade.alpha = fadeIn ? 0 : 1; fade.scrollFactor.set(0, 0); 
    fade.zoomFactor = 0; FlxG.state.add(fade);

    FlxTween.tween(fade, {alpha: fadeIn ? 1 : 0}, 0.2, {onComplete: complete});
}

static function exitOverworld() {
    NEXT_ROOM = null; NEXT_ENTERANCE = -1;
}