//
import funkin.savedata.FunkinSave;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import Xml;

var WHITE = 0xFFFFFFFF;
var YELLOW = 0xFFFFF000;

var songCards:Array<Dynamic> = []; // includes the white (or yellow if selected) boxes and the card
var songChapters:Array<Dynamic> = []; // box surrounding cards, "CHAPTER X" text, chapter description

var curSelected:Int = 0;
var cardSize:Int = 300;

var weekXMLs:Array<Dynamic> = [];
function create() {
    for (i in 0...data.length) weekXMLs.push(Xml.parse(data[i].xml).firstElement());

    var _i:Int = 0;
    for (cI => xml in weekXMLs) {
        var chapter:String = xml.get("name");
        var songs:Array<String> = [];
        for (s in xml.elementsNamed("song"))
            songs.push(s.firstChild().nodeValue);

        var prevBoxWidths = 0;
        if (cI != 0) for (i in 0...cI) prevBoxWidths += 25 + songChapters[i].chapterBox.width;

        var chapterBox = new FunkinSprite().makeSolid((cardSize + 22.5) * songs.length, cardSize + 50, 0xFFFFFFFF);
        chapterBox.setPosition(prevBoxWidths, FlxG.height / 2 - chapterBox.height / 2);
        add(chapterBox);

        var chapterBoxInner = new FunkinSprite().makeSolid(chapterBox.width - 5, chapterBox.height - 5, 0xFF000000);
        chapterBoxInner.setPosition(chapterBox.x + chapterBox.width / 2 - chapterBoxInner.width / 2, chapterBox.y + chapterBox.height / 2 - chapterBoxInner.height / 2);
        add(chapterBoxInner);

        var chapterTxt = textCrispy(new FunkinText(64, 64, 0, "CHAPTER " + (cI + 1) + "\n-- " + chapter + " --", 48, true));
        chapterTxt.alignment = "center";
        chapterTxt.setFormat(Paths.font("8bit-jve.ttf"), 48, 0xFFFFFFFF);
        chapterTxt.setPosition(chapterBox.x + chapterBox.width / 2 - chapterTxt.width / 2, chapterBox.y + chapterBox.height);
        add(chapterTxt);

        var songData = [];
        for (sI => song in songs) {
            var high = FunkinSave.getSongHighscore(song.toLowerCase(), "hard").score;

            var songCard = new FunkinSprite().loadGraphic(Paths.image('menus/covers/' + song, null, false, "jpg"));
            songCard.setGraphicSize(cardSize, cardSize);
            songCard.antialiasing = Options.antialiasing;
            songCard.updateHitbox();

            var boxOutline = new FunkinSprite().makeSolid(songCard.width + 5, songCard.height + 5, WHITE);
    
            // need to swap these ideas around i think
            boxOutline.setPosition(chapterBox.x + 10 + sI * (cardSize + 20), FlxG.height / 2 - boxOutline.height / 2);
            songCard.setPosition(boxOutline.x + boxOutline.width / 2 - songCard.width / 2, boxOutline.y + boxOutline.height / 2 - songCard.height / 2);

            add(boxOutline);
            add(songCard);

            if (high <= 0) songCard.colorTransform.color = 0xFF000000;
            songCard.ID = high <= 0 ? -1 : 0;

            songData.push({outline: boxOutline, card: songCard}); // to put it in songChapters
            songCards.push({outline: boxOutline, card: songCard, curChapter: cI}); // for curSelected

            _i++;
        }

        songChapters.push({
            title: chapterTxt,
            chapterBox: chapterBox,
            chapterBoxInner: chapterBoxInner,
            songs: songData
        });
    }

    updateSelection(0);

    var vignette = new FunkinSprite().loadGraphic(Paths.image('vignette'));
    vignette.setGraphicSize(FlxG.width, FlxG.height);
    vignette.updateHitbox();
    vignette.zoomFactor = 0;
    vignette.scrollFactor.set();
    vignette.alpha = 0.7;
    add(vignette);

    var chooseTxt = textCrispy(new FunkinText(64, 64, 0, "CHOOSE _SAVE_ POINT", 64, true));
    chooseTxt.setFormat(Paths.font("8bit-jve.ttf"), 64, 0xFFFFFFFF);
    chooseTxt.applyMarkup(chooseTxt.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(YELLOW), "_")]);
    chooseTxt.scrollFactor.set();
    add(chooseTxt);

    var screenVignette = new CustomShader("coloredVignette");
    screenVignette.strength = 0.6; screenVignette.transperency = false;
    screenVignette.amount = 0.7;
    screenVignette.color = [0.0, 0.0, 0.0];

    var bloom:CustomShader;
    bloom = new CustomShader("bloom");
    bloom.size = 10;
    bloom.brightness = 2;
    bloom.directions = 8;
    bloom.quality = 10;

    if (Options.gameplayShaders) {
        FlxG.camera.addShader(screenVignette);
        FlxG.camera.addShader(bloom);
    }
}

function update(elapsed:Float) {
    var selectChange:Int = (controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0) - FlxG.mouse.wheel;
    if (selectChange != 0) updateSelection(selectChange);

    var curCard = songCards[curSelected].card;
    FlxG.camera.scroll.x = lerp(FlxG.camera.scroll.x, curCard.x + curCard.width / 2 - FlxG.width / 2, 0.15);

    if (controls.BACK) {
        FlxG.switchState(new ModState("NewStoryMenu"));
    }

    if ((controls.ACCEPT || FlxG.mouse.justPressed) && curCard.ID == 0) {
        selectWeek();
    }
}

function selectWeek() {
    var playList:Array<String> = [];
    var chapter:Week = null;
    var songIndexInChapter:Int = -1;

    var totalIndex = 0;
    for (week in data) {
        for (i in 0...week.songs.length) {
            if (totalIndex == curSelected) {
                chapter = week;
                songIndexInChapter = i;
            }
            totalIndex++;
        }
    }

    if (chapter != null && songIndexInChapter != -1) {
        for (i in songIndexInChapter...chapter.songs.length)
            playList.push(chapter.songs[i].name);
    }

    var weeksAfter:Array<Week> = data.copy();
    var startIndex = data.indexOf(chapter)+1;
    var i:Int = 0;
    while (startIndex > i) {
        weeksAfter.shift();
        i++;
    }

    if (playList[0] == "the-uprising") playList.pop(); // Remove "You Are"

    PlayState.loadWeek(data[0], data[0].difficulties[0]);
    PlayState.storyPlaylist = playList;
    weekPlaylist = weeksAfter.copy();
    PlayState.isStoryMode = true;

    PlayState.__loadSong(playList[0], data[0].difficulties[0]);
    curMusicID = "";
    FlxG.switchState(new PlayState());
}

function updateSelection(amt:Int) {
    curSelected = FlxMath.wrap(curSelected + amt, 0, songCards.length - 1);

    if (amt != 0)
        FlxG.sound.play(Paths.sound("menu/scroll"), 1);

    for (i => card in songCards) {
        card.outline.color = i == curSelected ? YELLOW : WHITE; 
    }
}