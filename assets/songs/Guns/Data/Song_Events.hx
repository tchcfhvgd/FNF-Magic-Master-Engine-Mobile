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

import("states.PlayState", "PlayState");
import("FlxUICustomButton");
import("FlxCustomShader");
import("LangSupport");
import("DialogueBox");
import("PreSettings");
import("MagicStuff");
import("Character");
import("Alphabet");
import("Script");
import("Paths");
import("Type");
import("Std");

presset("startCountdown", true);

var tankman:Character;
var boyfriend:Character;
var girlfriend:Character;

var camFollow:FlxObject;

var onCinematic:Bool = false;

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

function startSong(startCountdown:Void->Void):Void {
    onCinematic = true;

    Character.setCameraToCharacter(tankman, camFollow);

    FlxG.sound.playMusic(Paths.music("DISTORTO", "stages/war"));
    FlxG.sound.music.fadeIn();

    FlxTween.tween(getState().camHUD, {alpha: 0}, 0.5);

    Timer.delay(function(){
        tankman.playAnim("Cinematic_GUNS", true, true, false, 0);
        
        FlxG.sound.play(Paths.sound("guns_1", "stages/war"), 1, false, null, true, function(){
            onCinematic = false;
                            
            FlxG.sound.music.fadeOut();
            FlxTween.tween(getState().camHUD, {alpha: 1}, 0.5);
            
            startCountdown();
        });

        Timer.delay(function(){
            girlfriend.playAnim("sad", true, true, false, 0);
        }, 4150);
    }, 500);
}

function update(elapsed:Float){
    if(onCinematic){
        tankman.holdTimer = 100;
    }
}