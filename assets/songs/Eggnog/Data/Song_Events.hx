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
import("flixel.util.FlxTimer", "FlxTimer");
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

var blackScreen:FlxSprite;

preset("endCountdown", true);

function preload():Void {
    blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    blackScreen.cameras = [getState().camFHUD];
    blackScreen.visible = false;
    blackScreen.screenCenter();
    getState().add(blackScreen);
}

function endSong(endCountdown:Void->Void):Void {
    blackScreen.visible = true;
    FlxG.sound.play(Paths.sound("Lights_Shut_off","stages/mall"));

    new FlxTimer().start(1, function(tmr:FlxTimer){endCountdown();});   
}