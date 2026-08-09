// david i cant not tell you enough about how much the insterects repo means to me
// thank you so much :D -lunar
// https://github.com/davidfig/intersects/blob/master/ellipse-line.js
static function ellipse_line_collision(xe:float, ye:float, rex:float, rey:float, x1:float, y1:float, x2:float, y2:float):Bool {
    x1 -= xe; x2 -= xe; y1 -= ye; y2 -= ye;

    var A = Math.pow(x2 - x1, 2) / rex / rex + Math.pow(y2 - y1, 2) / rey / rey;
    var B = 2 * x1 * (x2 - x1) / rex / rex + 2 * y1 * (y2 - y1) / rey / rey;
    var C = x1 * x1 / rex / rex + y1 * y1 / rey / rey - 1;
    var D = B * B - 4 * A * C;
    if (D == 0) {
        var t = -B / 2 / A;
        return (t >= 0 && t <= 1);
    }
    if (D > 0) {
        var sqrt = Math.sqrt(D);
        var t1 = (-B + sqrt) / 2 / A;
        var t2 = (-B - sqrt) / 2 / A;
        return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
    }
    return false;
}

// jeffrey thompson your acuttaly such a real one -lunar
// https://www.jeffreythompson.org/collision-detection/rect-rect.php
static function rect_rect_collision(r1x:Float, r1y:Float, r1w:Float, r1h:Float, r2x:Float, r2y:Float, r2w:Float, r2h:Float):Bool
    return r1x + r1w > r2x && r1x < r2x + r2w && r1y + r1h > r2y && r1y < r2y + r2h;

disableScript();