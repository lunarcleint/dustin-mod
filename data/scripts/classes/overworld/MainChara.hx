//
import flixel.math.FlxAngle;
import flixel.util.FlxSpriteUtil;

class MainChara extends flixel.FlxSprite {
    public var animFacing:String = null;
    public var allowCollisions:Bool = true;

    public var boxHitboxHeight:Float = 0;

    public var collisionLines:Array<{x1:Float, y1:Float, x2:Float, y2:Float, slope:Bool}> = [];
    public var collisionRects:Array<{x:Float, y:Float, w:Float, h:Float, callback:()->Void}> = [];

    public var rect_rect_collision:Dynamic->Void = null;
    public var ellipse_line_collision:Dynamic->Void = null;

    // public var hitboxBoxIndicator:FlxSprite;

    public function new(x:Float, y:Float, sprite:String = null, _facing:String) {
        super(x, y, sprite);

        if ((x % 3) == 2) x += 1;
        if ((x % 3) == 1) x -= 1;
        if ((y % 3) == 2) y += 1;
        if ((y % 3) == 1) y -= 1;
        
        frames = Paths.getAsepriteAtlasAlt("images/overworld/characters/dustinbf");
        animation.addByPrefix("l", "Left", 6, true);
        animation.addByPrefix("r", "Right", 6, true);
        animation.addByPrefix("d", "Down", 6, true);
        animation.addByPrefix("u", "Up", 6, true);

        animation.play(animFacing = _facing, true);
        animation.stop();

        boxHitboxHeight = (height-18)*0.7;

        // hitboxBoxIndicator = new FlxSprite(x, y).makeGraphic(Std.int(width*.75), boxHitboxHeight, 0x000000FF);
        // FlxSpriteUtil.drawEllipse(hitboxBoxIndicator, 0, 0, width*.75, boxHitboxHeight, 0x00FFFFFF, {color: 0xFFFF0000, smoothing: false});
    }

    public var previous:{x:Float, y:Float} = {x: 0, y: 0};
    public var delta:{x:Float, y:Float} = {x: 0, y: 0};

    public var turned:Int = 1;
    public var moving:Bool = false;
    public var facing:Int = null;
    public override function update(elapsed:Float) {
        previous.set(x, y);
        turned = 1;
        moving = false;
    
        if (FlxG.keys.pressed.LEFT) {
            x -= (previous.x == x + 3) ? 2 : 3;
            moving = true;
            if ((FlxG.keys.pressed.UP && facing == 2) || (FlxG.keys.pressed.DOWN && facing == 0)) turned = 0;
            if (turned == 1) facing = 3;
        }
        if (FlxG.keys.pressed.UP) {
            y -= 3;
            moving = true;
            if ((FlxG.keys.pressed.RIGHT && facing == 1) || (FlxG.keys.pressed.LEFT && facing == 3)) turned = 0;
            if (turned == 1) facing = 2;
        }
        if (FlxG.keys.pressed.RIGHT && !FlxG.keys.pressed.LEFT) {
            x += (previous.x == x - 3) ? 2 : 3;
            moving = true;
            if ((FlxG.keys.pressed.UP && facing == 2) || (FlxG.keys.pressed.DOWN && facing == 0)) turned = 0;
            if (turned == 1) facing = 1;
        }
        if (FlxG.keys.pressed.DOWN && !FlxG.keys.pressed.UP) {
            y += 3;
            moving = true;
            if ((FlxG.keys.pressed.RIGHT && facing == 1) || (FlxG.keys.pressed.LEFT && facing == 3)) turned = 0;
            if (turned == 1) facing = 0;
        }
    
        if (moving) {
            var animFacing = switch (facing) {
                case 0: "d"; 
                case 1: "r"; 
                case 2: "u"; 
                default: "l";
            };
            animation.play(animFacing, animation.name != animFacing);
        } else {
            animation.stop();
            animation?.curAnim?.curFrame = 1;
        }
    
        update_delta();
        if (allowCollisions) update_collisions();
    
        super.update(elapsed);
    
        var camera = cameras[0];
        if (camera != null)
            camera.scroll.set(x + (width / 2) - (FlxG.width / 2), y + (height / 2) - (FlxG.height / 2));
    }

    public function update_delta() {
        delta.x = x - previous.x;
        delta.y = y - previous.y;
    }
    
    public function update_collisions() {
        for (i => rect in collisionRects)
            if (rect_collision(rect) && rect.callback != null) rect.callback();
        for (i => line in collisionLines)
            if (line_collision(line)) seperate_rect_line(line, false);
    }

    public function seperate_rect_line(line:{x1:Float, y1:Float, x2:Float, y2:Float}, ?ignoreslopes:Bool = false) {
        if (!ignoreslopes && line.slope) {
            x -= delta.x; y -= delta.y;

            var playerAngle:Float = Math.atan2(delta.y, delta.x);
            var deltaPower:Float = Math.sqrt(delta.x * delta.x + delta.y * delta.y);
            var lineAngle:Float = Math.atan2(line.y2 - line.y1, line.x2 - line.x1);
            var angleDiff:Float = lineAngle - playerAngle;
            
            if (Math.abs(angleDiff) >= Math.PI / 2) angleDiff += Math.PI;
            
            x += Math.cos(playerAngle + angleDiff) * deltaPower;
            y += Math.sin(playerAngle + angleDiff) * deltaPower;

        } else {
            x -= delta.x;
            if (line_collision(line, false)) {
                x += delta.x; y -= delta.y;
            }
        }
        update_delta();
    }

    public function rect_collision(rect:{x:Float, y:Float, w:Float, h:Float}): Bool {
        return rect_rect_collision(
            rect.x, rect.y,
            rect.w, rect.h,
            x + (width/2) - (width*.75/2), (y + height) - boxHitboxHeight - 3,
            width*.75, boxHitboxHeight
        );
    }

    public function line_collision(line:{x1:Float, y1:Float, x2:Float, y2:Float}, ?checkbounds:Bool = true):Bool  {
        if (checkbounds && !rect_rect_collision(
            (line.x1 - (line.x2 < line.x1 ? Math.abs(line.x1 - line.x2) : 0)),
            (line.y1 - (line.y2 < line.y1 ? Math.abs(line.y1 - line.y2) : 0)),
            Math.abs(line.x1 - line.x2),
            Math.abs(line.y1 - line.y2),
            x + (width/2) - (width*.75/2), (y + height) - boxHitboxHeight - 3,
            width*.75, boxHitboxHeight
        )) return null; // boundingbox first

        return ellipse_line_collision(
            x + width/2,
            (y + height) - (boxHitboxHeight/2) - 3,
            (width*.75)/2, boxHitboxHeight/2,
            line.x1, line.y1,
            line.x2, line.y2
        );
    }
}
