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
import("Stage");
import("Type");
import("Std");

presset("startCountdown", true);

var tankman:Character;
var boyfriend:Character;
var girlfriend:Character;

var camFollow:FlxObject;
var stage:Stage;

var onCinematic:Bool = false;

function addToLoad(list:Array<Dynamic>){
    list.push({type: "MUSIC", instance: Paths.music("DISTORTO", "stages/war", true)});
    list.push({type: "SOUND", instance: Paths.sound("stress_1", "stages/war", true)});
}

function preload():Void {
    tankman = getState().stage.getCharacterByName("Tankman");
    boyfriend = getState().stage.getCharacterByName("Boyfriend");
    girlfriend = getState().stage.getCharacterByName("Pico");

    camFollow = getState().camFollow;
    stage = getState().stage;

    boyfriend.playAnim("singleIdle", true, true, false, 0);
    girlfriend.playAnim("gf_idle", true, true, false, 0);
}

function startSong(startCountdown:Void->Void):Void {
    onCinematic = true;

    Character.setCameraToCharacter(tankman, camFollow);

    FlxTween.tween(getState().camHUD, {alpha: 0}, 0.5);

    Timer.delay(function(){
        tankman.playAnim("Cinematic_STRESS_1", true, true, false, 0);
        
        FlxG.sound.play(Paths.sound("stress_1", "stages/war"), 1, false, null, true, function(){
            onCinematic = false;
            
            boyfriend.specialAnim = false;
            girlfriend.specialAnim = false;
            tankman.specialAnim = false;

            girlfriend.dance();
            boyfriend.dance();
            tankman.dance();
                            
            FlxTween.tween(getState().camHUD, {alpha: 1}, 0.5);
            
            startCountdown();
        });

        // GIRLFRIEND Timer
        Timer.delay(function(){
            girlfriend.playAnim("demon_1", true, true, false, 0);

            Character.setCameraToCharacter(girlfriend, camFollow);
            FlxTween.tween(FlxG.camera, {zoom: 1.25}, 1, {ease: FlxEase.quadInOut});

            Timer.delay(function(){
                girlfriend.playAnim("demon_2", true, true, false, 0);
    
                Timer.delay(function(){
                    FlxTween.tween(FlxG.camera, {zoom: stage.zoom}, 1, {ease: FlxEase.quadInOut});

                    girlfriend.playAnim("pico_1", true, true, false, 0);
                    boyfriend.playAnim("catch", true, true, false, 0);
        
                    Timer.delay(function(){
                        girlfriend.playAnim("pico_2", true, true, false, 0);
            
                        Timer.delay(function(){
                            girlfriend.playAnim("pico_3", true, true, false, 0);
                
                            Timer.delay(function(){
                                girlfriend.playAnim("right1-loop", true, true, false, 0);
                    
                            }, 1628);
                        }, 1375);
                    }, 1008);
                }, 953);
            }, 1534);
        }, 14750);

        // TANKMAN Timer
        Timer.delay(function(){
            tankman.playAnim("Cinematic_STRESS_2", true, true, false, 0);
            Character.setCameraToCharacter(tankman, camFollow);
        }, 19250);

        // BOYFRIEND Timer
        Timer.delay(function(){
            Character.setCameraToCharacter(boyfriend, camFollow);
            boyfriend.playAnim("singUPmiss", true, true, false, 0);
        }, 32250);

    }, 500);
}

function update(elapsed:Float){}