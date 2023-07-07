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
import("SavedFiles");
import("MagicStuff");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Type");
import("Std");

var tankman:Character;
var boyfriend:Character;
var girlfriend:Character;

var camFollow:FlxObject;

var onCinematic:Bool = false;
var total_time:Float = 0;
var total_events:Int = 0;
var startCountdown:Void->Void = function(){};

function addToLoad(list:Array<Dynamic>){
    list.push({type: "MUSIC", instance: Paths.music("DISTORTO", "stages/war", true)});
    list.push({type: "SOUND", instance: Paths.sound("guns_1", "stages/war", true)});
}

function preload():Void {
    tankman = getState().stage.getCharacterByName("Tankman");
    boyfriend = getState().stage.getCharacterByName("Boyfriend");
    girlfriend = getState().stage.getCharacterByName("Girlfriend");

    camFollow = getState().camFollow;
}

function startSong(_startCountdown:Void->Void):Void {
    if(!PlayState.isStoryMode){return false;}
    startCountdown = _startCountdown;
    onCinematic = true;

    Character.setCameraToCharacter(tankman, camFollow);

    FlxG.sound.playMusic(SavedFiles.getSound(Paths.music("DISTORTO", "stages/war")));
    FlxG.sound.music.fadeIn();

    FlxTween.tween(getState().camHUD, {alpha: 0}, 0.5);

    return true;
}

function update(elapsed:Float){
    if(!onCinematic){return;}
    total_time += elapsed;

    if(total_time >= 0.5 && total_events == 0){total_events++;
        tankman.playAnim("Cinematic_GUNS", true, true, false, 0);
        FlxG.sound.play(SavedFiles.getSound(Paths.sound("guns_1", "stages/war")), 1, false, null, true);
    }else if(total_time >= 4.65 && total_events == 1){total_events++;
        girlfriend.playAnim("sad", true, true, false, 0);
    }else if(total_time >= 11.5 && total_events == 2){total_events++;
        onCinematic = false;
        FlxG.sound.music.fadeOut();
        FlxTween.tween(getState().camHUD, {alpha: 1}, 0.5);
        startCountdown();
    }
}