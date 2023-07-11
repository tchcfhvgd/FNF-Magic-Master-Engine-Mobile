import("flixel.text.FlxTextFormatMarkerPair", "FlxTextFormatMarkerPair");
import("states.editors.CharacterEditorState", "CharacterEditorState");
import("flixel.graphics.frames.FlxAtlasFrames", "FlxAtlasFrames");
import("flixel.addons.ui.FlxUI9SliceSprite", "FlxUI9SliceSprite");
import("flixel.text.FlxTextBorderStyle", "FlxTextBorderStyle");
import("flixel.FlxCameraFollowStyle", "FlxCameraFollowStyle");
import("flixel.addons.ui.FlxUIButton", "FlxUIButton");
import("flixel.group.FlxTypedGroup", "FlxTypedGroup");
import("openfl.filters.ShaderFilter", "ShaderFilter");
import("flixel.text.FlxTextFormat", "FlxTextFormat");
import("flixel.addons.ui.FlxUIGroup", "FlxUIGroup");
import("states.MusicBeatState", "MusicBeatState");
import("flixel.util.FlxGradient", "FlxGradient");
import("flixel.tweens.FlxTween", "FlxTween");
import("openfl.geom.Rectangle", "Rectangle");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.text.FlxText", "FlxText");
import("haxe.format.JsonParser", "Json");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxObject", "FlxObject");
import("flixel.FlxCamera", "FlxCamera");
import("states.PlayState", "PlayState");
import("haxe.Timer", "Timer");
import("flixel.FlxG", "FlxG");

import("FlxUICustomButton");
import("FlxCustomShader");
import("LangSupport");
import("PreSettings");
import("MagicStuff");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Type");
import("Std");

presset("startCountdown", true);

var step:Float = 1;
var camFollow:FlxObject = null;

var fadeStart:FlxSprite;

function preload():Void {
    step = getState().conductor.stepCrochet / 1000;
    camFollow = getState().camFollow;
}

function startSong(startCountdown:Void->Void):Void {
    getState().followChar = false;

    fadeStart = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    fadeStart.cameras = [getState().camBHUD];
    getState().add(fadeStart);

    camFollow.setPosition(550, -7000);
    
    getState().introAssets = [{asset:null, sound:null}, {asset:null, sound:null}, {asset:null, sound:null}, {asset:null, sound:null}];

    startCountdown();

    FlxTween.tween(fadeStart, {alpha: 0}, (step * 32), {ease: FlxEase.quadInOut, onComplete: function(tween:FlxTween){
        getState().introAssets = [{asset:null, sound: 'intro3'}, {asset:'ready', sound: 'intro2'}, {asset:'set', sound: 'intro1'}, {asset:'go', sound: 'introGo'}];
    }});
}

function beatHit(curBeat:Int):Void {    
    switch(curBeat){
        case 1:{
            getState().tweens.push(FlxTween.tween(camFollow, {y: 40}, (step * 60), {ease: FlxEase.quadInOut, onComplete: function(tween:FlxTween){getState().followChar = true;}}));
        }
    }
}