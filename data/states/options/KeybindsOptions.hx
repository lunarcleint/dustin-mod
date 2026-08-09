public var color:FlxColor = FlxColor.WHITE;

var keys:Array<Dynamic> = [];
var txts:Array<FlxText> = [];

function create() {
    coloredBG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    coloredBG.alpha = .85;
    for(i in members) {
        if(i.text != null && i.textField == null) {
            var txt = textCrispy(new FunkinText(i.x, i.y, i.width, i.text, 36, false));
            txt.setFormat(Paths.font("8bit-jve.ttf"),78, FlxColor.WHITE, 'center');
            i.destroy();
            txts.push(txt);
            add(txt);
        }
    }
    for(i in alphabets) {
        for(spr in [i.title, i.bind1, i.bind2]) {
            var txt = textCrispy(new FunkinText(spr.x - i.x, spr.y - i.y, 0, spr.text, 24, false));
            if(spr != i.title)
                keys.push([txt, spr]);
            else spr.scale.set();
            txt.setFormat(Paths.font("8bit-jve.ttf"), 68, FlxColor.WHITE, 'left');
            spr.visible = false;
            txts.push(txt);
            i.add(txt);
        }
    }

    for (key in keys) {
        var isArrow = arrowCheck(key[1].text);
        key[0].visible = !isArrow;
        key[1].visible = isArrow;
    }
}

function postUpdate() {
    if (txts[0].color != color) {
        for(txt in txts) {
            txt.color = color;
        }
        for (key in keys) {
            key[1].color = color;
        }
    }
    if (!FlxG.keys.pressed.ANY) return;
    for (key in keys) {
        var e = key[0];
        var spr = key[1];
        var isArrow = arrowCheck(spr.text);
        e.visible = !isArrow;
        spr.visible = isArrow;
        spr.scale.x = isArrow ? spr.scale.y : 0;
        if (!isArrow && spr.text != e.text) e.text = spr.text;
    }
    for (key in keys) {
        key[0].alpha = key[1].alpha;
    }
}

function arrowCheck(str:String) {
    return (str == "←" || str == "↓" || str == "↑" || str == "→");
}
