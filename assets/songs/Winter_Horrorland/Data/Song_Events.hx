import("flixel.group.FlxTypedGroup", "FlxTypedGroup");
import("states.MusicBeatState", "MusicBeatState");
import("flixel.util.FlxGradient", "FlxGradient");
import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.text.FlxText", "FlxText");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxObject", "FlxObject");
import("flixel.FlxCamera", "FlxCamera");
import("haxe.Timer", "Timer");
import("flixel.FlxG", "FlxG");

import("LangSupport");
import("PreSettings");
import("SavedFiles");
import("MagicStuff");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Type");
import("Std");

var blackScreen:FlxSprite;

function preload():Void {
    blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x000000);
    blackScreen.cameras = [getState().camHUD];
    blackScreen.screenCenter();
    getState().add(blackScreen);

    getState().camFollow.setPosition(970, -800);
}

function startSong(startCountdown:Void->Void):Void {
    getState().camHUD.visible = false;
    FlxG.camera.zoom = 1.5;

    FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {getState().remove(blackScreen);}});
    FlxG.sound.play(SavedFiles.getSound(Paths.sound("Lights_Turn_On","stages/mallEvil")));

    new FlxTimer().start(0.8, function(tmr:FlxTimer){
        getState().camHUD.visible = true;
        getState().remove(blackScreen);
        FlxTween.tween(FlxG.camera, {zoom: getState().stage.zoom}, 2.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){startCountdown();}});
    });

    return true;
}