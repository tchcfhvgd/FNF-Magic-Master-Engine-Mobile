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
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.text.FlxText", "FlxText");
import("haxe.format.JsonParser", "Json");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxObject", "FlxObject");
import("flixel.FlxCamera", "FlxCamera");
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
    FlxG.sound.play(Paths.sound("Lights_Turn_On","stages/mallEvil"));

    new FlxTimer().start(0.8, function(tmr:FlxTimer){
        getState().camHUD.visible = true;
        getState().remove(blackScreen);
        FlxTween.tween(FlxG.camera, {zoom: getState().stage.zoom}, 2.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){startCountdown();}});
    });   
}