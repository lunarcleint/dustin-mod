using StringTools;

extra.set("flipOffset", -90);

function playSingAnimUnsafe(_) {
    if (isFlippedOffsets()) {
        var miss:String = _.animName.endsWith("miss") ? "miss" : "";
        trace(_.animName);
        if (_.animName.startsWith("singLEFT"))
            _.animName = "singRIGHT" + miss;
        else if (_.animName.startsWith("singRIGHT"))
            _.animName = "singLEFT" + miss;
        trace(_.animName);
    }
}