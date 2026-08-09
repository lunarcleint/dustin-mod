//
import openfl.display.BitmapData;

class ShakingText extends FlxText {

    public var shakeIntensity:Float = 6.5;
    public var shakeTimer:Float = 0;
    public var shakeTimerLimit:Float = 0.085;
    public var flicker:Bool = true;
    public var flickerAlpha = 1;


    // these are used to avoid using drawTextFieldTo too much
    private var _splitText:Array<String>;
    private var _prevText:String;

    private var _refresh = true;

    //these are pools or somthin
    var shakePoses:Array = [];

    private var _updateText:Bool = true;

    public var breakText:Bool = false;

    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
        super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
        onDraw = (spr) -> {
            if(flicker) {
                var a = spr.alpha;
                if(FlxG.save.data.antiFlash)
                    spr.alpha *= 0.65;
                else 
                    spr.alpha *= spr.flickerAlpha;
                spr.draw();
                spr.alpha = a;
            } else spr.draw();
        }
    }

    override function update(elapsed:Float)  {
        if(_prevText != (_prevText = text)) {
            _splitText = text.split("");
            _updateText = true;
        }
        if(shakeTimer > shakeTimerLimit) {
            if(visible && alpha > 0) {
                shakeTimer = 0;
                if(flicker && !FlxG.save.data.antiFlash)
                    flickerAlpha = FlxG.random.float(0.65, 1);
                _updateText = true;
                _refresh = true;
            }
        } else {
            shakeTimer += elapsed;
        }

        if(_updateText) {
            _regen = true;
            regenGraphic();
            _refresh = false;
            _updateText = false;
        }
        super.update(elapsed);
    }

    override function drawTextFieldTo(graphic):Void  {
		#if flash
		if (alignment == FlxTextAlign.CENTER && isTextBlurry())
		{
			var h:Int = 0;
			var tx:Float = _matrix.tx;
			for (i in 0...textField.numLines)
			{
				var lineMetrics = textField.getLineMetrics(i);

				// Workaround for blurry lines caused by non-integer x positions on flash
				var diff:Float = lineMetrics.x - Std.int(lineMetrics.x);
				if (diff != 0)
				{
					_matrix.tx = tx + diff;
				}
				_textFieldRect.setTo(0, h, textField.width, lineMetrics.height + lineMetrics.descent);

				graphic.draw(textField, _matrix, null, null, _textFieldRect, false);

				_matrix.tx = tx;
				h += Std.int(lineMetrics.height);
			}

			return;
		}
		#elseif !web
		// Fix to render desktop and mobile text in the same visual location as web
		_matrix.translate(-1, -1); // left and up
        var originx:Float = 0;
        if(_refresh) {
            shakePoses = [];
        }
        var poolIndex:Int = -1;
        if(_splitText != null && _updateText) {
            for(i => textChar in _splitText) {
                if(_refresh || shakePoses[i] == null)
                    shakePoses[i] = [FlxG.random.float(-shakeIntensity/2, shakeIntensity/2), FlxG.random.float(-shakeIntensity/2, shakeIntensity/2)];

                var textRect = textField.getCharBoundaries(i);

                var _x = shakePoses[i][0];
                var _y = shakePoses[i][1];

                if(textRect == null) {
                    poolIndex++;
                    textRect = textField.getCharBoundaries(poolIndex);
                    textRect.y += textRect.height;
                }
                
                if(!breakText) {
                    textRect.x += _x;
                    textRect.y += _y;
                    textRect.width -= 1;
                }
                _matrix.translate(_x, _y);
                graphic.draw(textField, _matrix, null, null, textRect);
                _matrix.translate(-_x, -_y);
            }
        } else {
            graphic.draw(textField, _matrix);
            _matrix.translate(-1, -1);
        }
		_matrix.translate(1, 1); // return to center
		return;
		#end

		graphic.draw(textField, _matrix);
	}
}