//

import Reflect;
import funkin.game.HudCamera;

var forceScroll; // a script for downscroll to work on camgame

function create() {

    bloom_new = new CustomShader("bloom_new");
    bloom_new.size = 50; bloom_new.brightness = 1.2;
    bloom_new.directions = 16; bloom_new.quality = 5;
    bloom_new.threshold = .85;

    if (Options.gameplayShaders && FlxG.save.data.bloom) {
        camGame.addShader(bloom_new);
        camHUD.addShader(bloom_new);
    }
}

var blackBG:FlxSprite;
var blackBG2:FlxSprite;
var blackBG3:FlxSprite;

function postCreate() {
    if(camHUD.downscroll) {
        forceScroll = importScript("data/scripts/mechanics/strumDirectionChange");
        negMultY = desiredMultY = -1;
        forcedScrollOffset = 325;
        for (i in 0...4) {
            strumOffset.set(0,camHUD.height - (strumLines.members[1].members[0].y) - (strumLines.members[1].members[i].height / 2));
            strumOffsetLerp.set(0,camHUD.height - (strumLines.members[1].members[0].y) - (strumLines.members[1].members[i].height / 2));
        }
        ignoreHUDScroll = true;
        applyDirectionStrum(cpuStrums);
    }
    
    //
    gf.alpha = 0;

    camMoveOffset = 0;
    camAngleOffset = 0;

    // STUFF TO REMOVE FROM BG

    bg_second.visible = false;



    //

    remove(boyfriend);
    remove(dad, true);

    remove(bg_start_left);
    remove(bg_start_right);

    remove(haunted_sans_bg_left);
    remove(haunted_sans_bg_right);
    remove(haunted_sans_bg_middle);

    blackBG2 = new FlxSprite();
    blackBG2.makeGraphic(4000, 4000, 0xFF000000); 
    blackBG2.scrollFactor.set(1, 1);
    blackBG2.cameras = [camGame]; 
    blackBG2.setPosition(0, 0);     
    
    add(blackBG2);
    
    add(bg_start_left);
    add(bg_start_right);
    add(haunted_sans_bg_left);
    
    add(dad);

    add(haunted_sans_bg_right);
    add(haunted_sans_bg_middle);


    /*fgBorder = new FlxSprite(fg_start_right.x, fg_start_right.y);
    fgBorder.makeGraphic(fg_start_right.width, fg_start_right.height, FlxColor.BLACK); 
    fgBorder.cameras = [camGame];

    fg_start_right.onDraw = (spr) -> {
        spr.draw();
        fgBorder.x = spr.x + spr.width;
        fgBorder.draw();
        fgBorder.setPosition(spr.x + spr.width, spr.y);
        fgBorder.draw();
        fgBorder.setPosition(spr.x, spr.y + spr.height);
        fgBorder.draw();
        fgBorder.setPosition(spr.x, spr.y - spr.height);
        fgBorder.draw();
        fgBorder.setPosition(fg_start_left.x, fg_start_left.y + spr.height);
        fgBorder.draw();
        fgBorder.setPosition(fg_start_left.x, fg_start_left.y - spr.height);
        fgBorder.draw();
    }*/
    remove(fg_start_left);
    add(boyfriend);

    remove(fg_start_right);
    remove(haunted_fault);

    remove(haunted_paps_jjk);
    remove(haunted_sans_jjk);
    remove(haunted_bf_jjk);

    remove(haunted_weak);
    remove(haunted_punch);
    
    
    var customUI:Array<FlxSprite> = [
        dustinHealthBG, dustinHealthBar,
        dustiniconP1, dustiniconP2,
        timeBarBG, timeTxt, timeBar
    ];
    
    var customUItime:Array<FlxSprite> = [
        timeBarBG, timeTxt, timeBar
    ];
    
    remove(strumLines);
    insert(members.indexOf(boyfriend) + 2, strumLines);
    strumOverlay?.cameras = [camGame];
    
    for (strum in cpuStrums.members) {
        if (strum != null)
            strum.camera = camGame;
        strum.scrollFactor.set(1, 1);
    }
    
    for (strum in playerStrums.members) {
        if (strum != null)
            strum.camera = camGame;
        strum.scrollFactor.set(1, 1);
    }
    
    for (strumLine in strumLines)
        for (note in strumLine.notes) {
            remove(note);
            add(note);
        }
        
    for (strum in playerStrums.members) {
        strum.alpha = 0;
        strum.visible = false;
    }
    
    for (strum in cpuStrums.members) {
        strum.alpha = 0;
        strum.visible = false;
    }
        
    for (strumLine in strumLines)
        for (note in strumLine.notes) {
            note.alpha = 0;
            note.visible = false;
        }
        
            
            
        for (element in customUI) {
            element.angle = 90;
            element.y -= 290;
            element.scale.set(0.6, 0.6);
            
            if (camHUD.downscroll) {
                element.y += 20;
            }
        }
            
        dustinHealthBar.y -= 30;
        
        for (element in customUItime) {
            element.visible = false;
        }
        
        dustiniconP1.visible = false;
        dustiniconP2.visible = false;
        dustinHealthBG.alpha = 0;
        dustinHealthBar.alpha = 0;
        
        if (camHUD.downscroll) {
            scoreTxt.y -= 650;
            accuracyTxt.y -= 650;
            missesTxt.y -= 650;
        }
        
        
        
        
        blackBG = new FlxSprite();
        blackBG.makeGraphic(4000, 4000, 0xFF000000); 
        blackBG.scrollFactor.set(1, 1);
        blackBG.cameras = [camGame]; 
        blackBG.setPosition(0, 1050); 
        
        add(blackBG);
        
        blackBG3 = new FlxSprite();
        blackBG3.makeGraphic(2000, 2000, 0xFF000000); 
        blackBG3.scrollFactor.set(1, 1);
        blackBG3.cameras = [camGame]; 
        blackBG3.setPosition(0, -2000); 
        
        add(blackBG3);
        
        
        add(fg_start_left);
        add(fg_start_right);
        add(haunted_fault);
        add(haunted_weak);
        add(haunted_punch);

        add(haunted_paps_jjk);
        add(haunted_sans_jjk);
        add(haunted_bf_jjk);
        
        ogbg_start_left = bg_start_left.x;
        ogbg_start_right = bg_start_right.x;
        ogfg_start_left = fg_start_left.x;
        ogfg_start_right = fg_start_right.x;
        ogboyfriend = boyfriend.x;
        ogdad = dad.x;
        
        bg_start_left.x -= 1200;
        bg_start_right.x += 1200;
        fg_start_left.x -= 1200;
        fg_start_right.x += 1200;
        boyfriend.x += 1200;
        dad.x -= 1200;
        camGame.fade(FlxColor.BLACK, 0);

        haunted_papyrus_stare.visible = false;
        haunted_bf_stare.visible = false;
        
        haunted_fault.visible = false;
        haunted_weak.visible = false;
        haunted_punch.visible = false;

        haunted_paps_jjk.visible = false;
        haunted_sans_jjk.visible = false;
        haunted_bf_jjk.visible = false;
        
        haunted_sans_bg_left.visible = false;
        haunted_sans_bg_right.visible = false;
        haunted_sans_bg_middle.visible = false;

        ratingsGroup.cameras = [FlxG.camera];
        remove(ratingsGroup, true);
        add(ratingsGroup);
}

function stepHit(step:Int) {
    switch (step) {
        case 1:
            camGame.fade(FlxColor.BLACK, 0, true);
            FlxTween.tween(bg_start_left, {x: ogbg_start_left}, 3, {ease: FlxEase.quintOut});
            FlxTween.tween(fg_start_left, {x: ogfg_start_left}, 3, {ease: FlxEase.quintOut});
            FlxTween.tween(dad, {x: ogdad}, 3, {ease: FlxEase.quintOut});

        case 32:
            FlxTween.tween(bg_start_right, {x: ogbg_start_right}, 3, {ease: FlxEase.quintOut});
            FlxTween.tween(fg_start_right, {x: ogfg_start_right}, 3, {ease: FlxEase.quintOut});
            FlxTween.tween(boyfriend, {x: ogboyfriend}, 3, {ease: FlxEase.quintOut});

        case 56:
            for (strum in cpuStrums.members) {
                    strum.x += 225;
                    strum.y += 30;
            }

            for (strum in playerStrums.members) {
                    strum.x += 435;
                    strum.y += 30;
            }

            for (strum in playerStrums.members) 
                    strum.visible = true;
                

            for (strum in cpuStrums.members) 
                    strum.visible = true;
                

            for (strumLine in strumLines)
                for (note in strumLine.notes) 
                    note.visible = true;
            
            for (strum in playerStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: 1}, 2, {ease: FlxEase.quadOut});

            for (strum in cpuStrums.members)
                if (strum != null)
                    FlxTween.tween(strum, {alpha: 1}, 2, {ease: FlxEase.quadOut});

            for (strumLine in strumLines)
                for (note in strumLine.notes)
                    FlxTween.tween(note, {alpha: 1}, 2, {ease: FlxEase.quadOut});



        case 60:
            FlxTween.tween(dustinHealthBG, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 1}, 1, {ease: FlxEase.quadOut});

        // SECOND PART

        case 544:
            bg_start_left.visible = false;
            bg_start_right.visible = false;
            fg_start_left.visible = false;
            fg_start_right.visible = false;
            blackBG2.visible = false;
            blackBG3.visible = false;
            blackBG.visible = false;


            bg_second.visible = true;
            var customUI:Array<FlxSprite> = [
                        dustinHealthBG, dustinHealthBar,
                        dustiniconP1, dustiniconP2,
                        timeBarBG, timeTxt, timeBar
                ];

            remove(strumLines);
            insert(members.indexOf(scoreTxt), strumLines);

            for (strum in cpuStrums.members)
                if (strum != null)
                    strum.alpha = 0;

             for (strum in playerStrums.members) {
                strum.cameras = [camHUD];
                strum.x -= 435;
                strum.y -= 30; 
                strum.alpha = 0.8;  
            }

            ratingsGroup.cameras = [camHUD];
            strumOverlay?.cameras = [camHUD];

            if(camHUD.downscroll) {
                for (i in 0...4) {
                    strumOffset.set(0, 0);
                    strumOffset.copyTo(strumOffsetLerp);
                    forcedScrollOffset = 0;
                    negMultY = 1; desiredMultY = 1;
                    removeDirectionStrum(playerStrums);
                    removeDirectionStrum(cpuStrums);
                    forceScroll = null;
                };
            }

             for (strumLine in strumLines)
                for (note in strumLine.notes) 
                    note.alpha = 0.8;

            for (element in customUI) {
                    FlxTween.tween(element, {x: element.x - 550}, 3, {ease: FlxEase.quintOut});
                }
        case 802:
            haunted_papyrus_stare.visible = true;
            haunted_papyrus_stare.x -= 2000;
            FlxTween.tween(haunted_papyrus_stare, {x: haunted_papyrus_stare.x + 2000}, 5, {ease: FlxEase.quintOut});

        case 834:
            haunted_bf_stare.visible = true;
            haunted_bf_stare.x += 2000;
            FlxTween.tween(haunted_bf_stare, {x: haunted_bf_stare.x - 2000}, 5, {ease: FlxEase.quintOut});

        case 253:
            haunted_fault.visible = true;
            haunted_fault.y += 2000;
            FlxTween.tween(haunted_fault, {y: haunted_fault.x - 60}, 3, {ease: FlxEase.quintOut});
            FlxTween.tween(dustinHealthBG, {alpha: 0}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 0}, 1, {ease: FlxEase.quadOut});

        case 288:
             haunted_fault.visible = false;
             FlxTween.tween(dustinHealthBG, {alpha: 1}, 1, {ease: FlxEase.quadOut});
            FlxTween.tween(dustinHealthBar, {alpha: 1}, 1, {ease: FlxEase.quadOut});

        case 1088:
            haunted_bf_stare.visible = false;
            haunted_papyrus_stare.visible = false;

            haunted_sans_bg_left.visible = true;
            haunted_sans_bg_right.visible = true;
            haunted_sans_bg_middle.visible = true;

            remove(boyfriend, true);
            insert(members.indexOf(haunted_sans_bg_right) + 1, boyfriend);
    


            bg_second.visible = false;

        case 1453:
            haunted_weak.visible = true;
            haunted_weak.y += 2000;
            FlxTween.tween(haunted_weak, {y: haunted_weak.x - 60}, 3, {ease: FlxEase.quintOut});

        case 1472:
            haunted_weak.visible = false;

        case 1758:
            haunted_sans_bg_left.visible = false;
            haunted_sans_bg_right.visible = false;
            haunted_sans_bg_middle.visible = false;
            haunted_punch.visible = true;
            haunted_punch.y += 2000;
            FlxTween.tween(haunted_punch, {y: haunted_punch.x - 30}, 3, {ease: FlxEase.quintOut});

        case 1780:
            FlxTween.tween(haunted_punch, {y: haunted_punch.y - 2000}, 3, {ease: FlxEase.quintIn});

        case 1760:
            haunted_end_bg.alpha = 1;

        case 2180:
            FlxTween.tween(gf, {alpha: 0}, 10, {ease: FlxEase.sineInOut});

        case 2016:
            haunted_bf_jjk.visible = true;
            haunted_bf_jjk.y += 2000;
            FlxTween.tween(haunted_bf_jjk, {y: haunted_bf_jjk.y - 2000}, 1.5, {ease: FlxEase.quintOut});

        case 2023:
            haunted_sans_jjk.visible = true;
            haunted_sans_jjk.y -= 2000;
            FlxTween.tween(haunted_sans_jjk, {y: haunted_sans_jjk.y + 2000}, 1.5, {ease: FlxEase.quintOut});

        case 2031:
            haunted_paps_jjk.visible = true;
            haunted_paps_jjk.y += 2000;
            FlxTween.tween(haunted_paps_jjk, {y: haunted_paps_jjk.y - 2000}, 1.5, {ease: FlxEase.quintOut});

        case 2048:
            haunted_paps_jjk.visible = false;
            haunted_sans_jjk.visible = false;
            haunted_bf_jjk.visible = false;
    }
}