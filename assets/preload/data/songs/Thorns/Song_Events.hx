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

import("LangSupport");
import("DialogueBox");
import("PreSettings");
import("SavedFiles");
import("MagicStuff");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Type");
import("Std");

var whiteScreen:FlxSprite;
var dialogue:DialogueBox;

var cur_portrait:FlxSprite;

function preload():Void {
    if(!PlayState.isStoryMode || PlayState.total_plays > 1){return;}
    whiteScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
    whiteScreen.cameras = [getState().camBHUD];
    whiteScreen.screenCenter();
    whiteScreen.alpha = 0;

    getState().add(whiteScreen);
}

function startSong(startCountdown:Void->Void):Void {
    if(!PlayState.isStoryMode || PlayState.total_plays > 1){return false;}

    FlxG.sound.playMusic(SavedFiles.getSound(Paths.music("LunchboxScary", "stages/schoolEvil")));
    FlxG.sound.music.fadeIn();
    
    FlxTween.tween(whiteScreen, {alpha: 0.5}, 3, {ease: FlxEase.linear});
    FlxTween.tween(getState().camHUD, {alpha: 0}, 1, {ease: FlxEase.linear, onComplete: function(twn){
        dialogue = new DialogueBox(SavedFiles.getJson(Paths.dialogue(PlayState.SONG.song)), {onComplete: function(){onEndDialogue(startCountdown);}, script: this});
        dialogue.cameras = [getState().camBHUD];
        getState().add(dialogue);
    }});

    return true;
}

function onEndDialogue(startCountdown:Void->Void):Void {
    FlxG.sound.music.fadeOut();
    FlxTween.tween(whiteScreen, {alpha: 0}, 1, {ease: FlxEase.linear});
    FlxTween.tween(getState().camHUD, {alpha: 1}, 1, {ease: FlxEase.linear, onComplete: function(twn){startCountdown();}});
}