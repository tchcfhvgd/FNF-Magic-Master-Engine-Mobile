import("states.MusicBeatState", "MusicBeatState");
import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.tweens.FlxEase", "FlxEase");
import("states.PlayState", "PlayState");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxObject", "FlxObject");
import("flixel.FlxCamera", "FlxCamera");
import("haxe.Timer", "Timer");
import("flixel.FlxG", "FlxG");

import("PreSettings");
import("MagicStuff");
import("SavedFiles");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Stage");
import("Type");
import("Std");

var tankman:Character;
var boyfriend:Character;
var girlfriend:Character;

var camFollow:FlxObject;
var stage:Stage;

var onCinematic:Bool = false;
var total_time:Float = 0;
var total_events:Int = 0;
var startCountdown:Void->Void = function(){};

function addToLoad(list:Array<Dynamic>){
    list.push({type: "MUSIC", instance: Paths.music("DISTORTO", "stages/war")});
    list.push({type: "SOUND", instance: Paths.sound("stress_1", "stages/war")});
}

function preload():Void {
    tankman = getState().stage.getCharacterByName("Tankman");
    boyfriend = getState().stage.getCharacterByName("Boyfriend");
    girlfriend = getState().stage.getCharacterByName("Pico");

    camFollow = getState().camFollow;
    stage = getState().stage;

    if(!PlayState.isStoryMode){return;}

    boyfriend.playAnim("singleIdle", true, true, false, 0);
    girlfriend.playAnim("gf_idle", true, true, false, 0);

    boyfriend.holdTimer = 1000;
    girlfriend.holdTimer = 1000;
}

function startSong(_startCountdown:Void->Void):Void {
    if(!PlayState.isStoryMode){return false;}
    startCountdown = _startCountdown;
    onCinematic = true;

    Character.setCameraToCharacter(tankman, camFollow);
    FlxTween.tween(getState().camHUD, {alpha: 0}, 0.5);

    return true;
}

function update(elapsed:Float){
    if(!onCinematic){return;}
    total_time += elapsed;

    boyfriend.holdTimer = 1000;
    girlfriend.holdTimer = 1000;
    tankman.holdTimer = 1000;

    if(total_time >= 0.5 && total_events == 0){total_events++;
        tankman.playAnim("Cinematic_STRESS_1", true, true, false, 0);
        FlxG.sound.play(SavedFiles.getSound(Paths.sound("stress_1", "stages/war")), 1, false, null, true);
    }else if(total_time >= 15.25 && total_events == 1){total_events++;
        girlfriend.playAnim("demon_1", true, true, false, 0);
        Character.setCameraToCharacter(girlfriend, camFollow);
        FlxTween.tween(FlxG.camera, {zoom: 1.25}, 1, {ease: FlxEase.quadInOut});
    }else if(total_time >= 16.784 && total_events == 2){total_events++;
        girlfriend.playAnim("demon_2", true, true, false, 0);
    }else if(total_time >= 17.737  && total_events == 3){total_events++;
        FlxTween.tween(FlxG.camera, {zoom: stage.zoom}, 1, {ease: FlxEase.quadInOut});
        girlfriend.playAnim("pico_1", true, true, false, 0);
        boyfriend.playAnim("catch", true, true, false, 0);
    }else if(total_time >= 18.745  && total_events == 4){total_events++;
        girlfriend.playAnim("pico_2", true, true, false, 0);
    }else if(total_time >= 19.75  && total_events == 5){total_events++;
        tankman.playAnim("Cinematic_STRESS_2", true, true, false, 0);
        Character.setCameraToCharacter(tankman, camFollow);
    }else if(total_time >= 20.12  && total_events == 6){total_events++;
        girlfriend.playAnim("pico_3", true, true, false, 0);
    }else if(total_time >= 21.748  && total_events == 7){total_events++;
        girlfriend.playAnim("right1-loop", true, true, false, 0);
    }else if(total_time >= 32.75  && total_events == 8){total_events++;
        Character.setCameraToCharacter(boyfriend, camFollow);
        boyfriend.playAnim("singUPmiss", true, true, false, 0);
    }else if(total_time >= 35  && total_events == 9){total_events++;
        onCinematic = false;
        boyfriend.holdTimer = 0;
        girlfriend.holdTimer = 0;
        tankman.holdTimer = 0;
        boyfriend.specialAnim = false;
        girlfriend.specialAnim = false;
        tankman.specialAnim = false;
        girlfriend.dance();
        boyfriend.dance();
        tankman.dance();
        FlxTween.tween(getState().camHUD, {alpha: 1}, 0.5);
        startCountdown();
    }
}