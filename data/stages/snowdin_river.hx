//
importScript("data/scripts/snowing-shader");

import haxe.xml.Access;
import Lambda;

var storedNodes:Array<Access> = [];
var storedSprites:Array<FlxSprite> = [];

public var camCharacters:FlxCamera;

public var fogShader:CustomShader;
public var bloom_new:CustomShader;

public var chromWarp:CustomShader;
public var water:CustomShader;
public var glitching:CustomShader;

public var impact:CustomShader;

function create() {
    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 10; bloom_new.brightness = 0;
    bloom_new.directions = 16; bloom_new.quality = 3;
    bloom_new.threshold = .5;

    fogShader = new CustomShader("fog");
    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    fogShader.res = [FlxG.width, FlxG.height]; fogShader.time = 0;

    fogShader.FOG_COLOR = [166./255., 185./255., 189./255.]; fogShader.BG = [0.0, 0.0, 0.0];
    fogShader.ZOOM = 4.0; fogShader.OCTAVES = 12; fogShader.FEATHER = 180;
    fogShader.INTENSITY = 1;

    fogShader.applyY = 770;
    fogShader.applyRange = 1100;

    camCharacters = new FlxCamera(0, 0);

    chromWarp = new CustomShader("chromaticWarp");
    chromWarp.distortion = 0;

    water = new CustomShader("waterDistortion");
    water.strength = .0;

    impact = new CustomShader("impact_frames");
    impact.threshold = -1;
    // impact.threshold = .4;

    glitching = new CustomShader("glitching2");
    glitching.time = 0; glitching.glitchAmount = 0;

    if (Options.gameplayShaders) {
        if (FlxG.save.data.water) camGame.addShader(water);
        if (FlxG.save.data.fog) camCharacters.addShader(fogShader);
        if (FlxG.save.data.impact) camCharacters.addShader(impact);
        if (FlxG.save.data.glitch) camCharacters.addShader(glitching);
        if (FlxG.save.data.chromwarp) camGame.addShader(chromWarp);
        
        if (FlxG.save.data.bloom) {
            camCharacters.addShader(bloom_new);
            camCharacters.addShader(bloom);
        }

        if (FlxG.save.data.saturation) camCharacters.addShader(saturation);

    }

    for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
    for (cam in [camGame, camCharacters, camHUD, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    snowSpeed = 1.6;
}

function onCountdown(event) event.sprite?.cameras = [camCharacters];

function postCreate() {
    if (Options.gameplayShaders) {
        screenVignette.transperency = true;

        camGame.removeShader(screenVignette);
        camHUD2.addShader(screenVignette);
    
        if (FlxG.save.data.particles) {
            camGame.addShader(snowShader);
            camCharacters.addShader(snowShader2);
        }

        if (FlxG.save.data.water) camHUD.addShader(water);
    }

    snowShader.snowMeltRect = [-700, 460, 1500, 100]; 
    snowShader2.snowMeltRect = [-700, 460, 1500, 100]; 
}

var __timer:Float = 0; 
function update(elapsed:Float) {
    __timer += elapsed;
    fogShader.time = __timer;
    water.time = __timer;
    glitching.time = __timer;

    fogShader.cameraZoom = FlxG.camera.zoom;
    fogShader.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];

    for (strum in strumLines)
        for (char in strum.characters)
            char.cameras = [camCharacters];
}

function postUpdate() DustinUtil.copyCamera(FlxG.camera, camCharacters);

function onStageXMLParsed(actualEvent) {
    // So it wont take ram if not needed  - Nex
    for(event in PlayState.SONG.events) if(event.name.toLowerCase() == "hscript call" && event.params[0] == "switchToSans") {
        var elements:Array<Access> = actualEvent.elems;  // Avoiding an infinite loop just in case  - Nex
        for(mainNode in actualEvent.elems) if(mainNode.nodeName == "precache-sans") {
            actualEvent.elems.remove(mainNode);

            for (node in mainNode.elements()) {
                if(node.nodeName == "high-memory" && !Options.lowMemoryMode) for(e in node) {
                    storedNodes.push(e);
                    elements.push(e);  // .concat is a bitch and wont work here, so easier doing like this  - Nex
                } else {
                    storedNodes.push(node);
                    elements.push(node);
                }
            }
        }
        actualEvent.elems = elements;
        break;
    }
}

function onStageNodeParsed(event) {
    if (storedNodes.contains(event.node)) {
        var last:Int = event.stage.state.members.indexOf(event.sprite);
        event.stage.state.remove(event.sprite);
        event.stage.state.insert(last - Lambda.count(event.stage.characterPoses), event.sprite);

        event.sprite?.visible = false;
        storedSprites.push(event.sprite);
    }
}

function switchToSans() {
    for (sprite in stage.stageSprites)
        sprite.visible = storedSprites.contains(sprite) || sprite.name.toLowerCase() == "bg";
}

function papsDies() {
    if(head == null) return;
    head.playAnim("dies", true);
    head.beatAnims = [];
}