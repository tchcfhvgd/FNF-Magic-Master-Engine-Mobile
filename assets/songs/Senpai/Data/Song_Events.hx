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

var whiteScreen:FlxSprite;
var dialogue:DialogueBox;

var cur_portrait:FlxSprite;

function preload():Void {
    whiteScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFF);
    whiteScreen.cameras = [getState().camBHUD];
    whiteScreen.screenCenter();
    whiteScreen.alpha = 1;

    getState().add(whiteScreen);
}

function startSong(startCountdown:Void->Void):Void {
    if(!getState().isStoryMode){startCountdown(); return;}

    FlxTween.tween(whiteScreen, {alpha: 0.5}, 3, {ease: FlxEase.linear});
 
    var dialogue_data:Array<Dynamic> = Paths.dialogue(getState().SONG.song);
    dialogue = new DialogueBox(dialogue_data);
    dialogue.loadDialogueBox("Senpai_Box");
    dialogue.finishFunc = startCountdown;
    dialogue.script = this;
    
    dialogue.dialogue_box.animation.play("Normal_Appear");
}

function toChangeDialogue(curDialogue:Int):Void {
    switch(curDialogue){
        case 0:{

        }
    }
}

function onDialogueChanged(curDialogue:Int):Void {
    switch(curDialogue){
        case 0:{

        }
    }
}