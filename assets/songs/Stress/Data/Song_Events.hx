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

var gf_idle:FlxSprite;
var gf_demon_1:FlxSprite;
var gf_demon_2:FlxSprite;
var pico_arrives_1:FlxSprite;
var pico_arrives_2:FlxSprite;
var pico_arrives_3:FlxSprite;
var stressCinematic1:FlxSprite;
var stressCinematic2:FlxSprite;

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
    if(!PlayState.isStoryMode || PlayState.total_plays > 1){return;}
    list.push({type: "IMAGE", instance: Paths.image("characters/Girlfriend/gfTankmen")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Pico/Pico_Arrives_1")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Pico/Pico_Arrives_2")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Pico/Pico_Arrives_3")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Pico/Gf_Demon_1")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Pico/Gf_Demon_2")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Tankman/stress2")});
    list.push({type: "IMAGE", instance: Paths.image("characters/Tankman/stress")});
    list.push({type: "MUSIC", instance: Paths.music("DISTORTO", "stages/war")});
    list.push({type: "SOUND", instance: Paths.sound("stress_1", "stages/war")});
}

function preload():Void {
    if(!PlayState.isStoryMode || PlayState.total_plays > 1){return false;}

    tankman = getState().stage.getCharacterByName("Tankman");
    boyfriend = getState().stage.getCharacterByName("Boyfriend");
    girlfriend = getState().stage.getCharacterByName("Pico");

    camFollow = getState().camFollow;
    stage = getState().stage;

    // Tankman Assets
    stressCinematic1 = new FlxSprite(tankman.x - 160, tankman.y + 110);
    stressCinematic1.frames = SavedFiles.getSparrowAtlas(Paths.image("characters/Tankman/stress"));
    stressCinematic1.animation.addByPrefix("play", "TANK TALK 3 P1 UNCUT", 24, false);
    tankman.add(stressCinematic1);
    
    stressCinematic2 = new FlxSprite(tankman.x - 160, tankman.y + 110);
    stressCinematic2.frames = SavedFiles.getSparrowAtlas(Paths.image("characters/Tankman/stress2"));
    stressCinematic2.animation.addByPrefix("play", "TANK TALK 3 P2 UNCUT", 24, false);
    stressCinematic2.visible = false;
    tankman.add(stressCinematic2);
    
    // Pico Assets
    gf_idle = new FlxSprite(girlfriend.x, girlfriend.y);
    gf_idle.frames = SavedFiles.getAtlas(Paths.image("characters/Girlfriend/gfTankmen"));
    gf_idle.animation.addByPrefix("play", "GF Dancing at Gunpoint", 24, false);
    gf_idle.animation.play("play");
    girlfriend.add(gf_idle);

    gf_demon_1 = new FlxSprite(girlfriend.x, girlfriend.y);
    gf_demon_1.frames = SavedFiles.getAtlas(Paths.image("characters/Pico/Gf_Demon_1"));
    gf_demon_1.animation.addByPrefix("play", "GF STARTS TO TURN PART 1", 24, false);
    gf_demon_1.visible = false;
    girlfriend.add(gf_demon_1);
    
    gf_demon_2 = new FlxSprite(girlfriend.x, girlfriend.y);
    gf_demon_2.frames = SavedFiles.getAtlas(Paths.image("characters/Pico/Gf_Demon_2"));
    gf_demon_2.animation.addByPrefix("play", "GF STARTS TO TURN PART 2", 24, false);
    gf_demon_2.visible = false;
    girlfriend.add(gf_demon_2);
    
    pico_arrives_1 = new FlxSprite(girlfriend.x, girlfriend.y);
    pico_arrives_1.frames = SavedFiles.getAtlas(Paths.image("characters/Pico/Pico_Arrives_1"));
    pico_arrives_1.animation.addByPrefix("play", "PICO ARRIVES PART 1", 24, false);
    pico_arrives_1.visible = false;
    girlfriend.add(pico_arrives_1);
    
    pico_arrives_2 = new FlxSprite(girlfriend.x, girlfriend.y);
    pico_arrives_2.frames = SavedFiles.getAtlas(Paths.image("characters/Pico/Pico_Arrives_2"));
    pico_arrives_2.animation.addByPrefix("play", "PICO ARRIVES PART 2", 24, false);
    pico_arrives_2.visible = false;
    girlfriend.add(pico_arrives_2);
    
    pico_arrives_3 = new FlxSprite(girlfriend.x, girlfriend.y);
    pico_arrives_3.frames = SavedFiles.getAtlas(Paths.image("characters/Pico/Pico_Arrives_3"));
    pico_arrives_3.animation.addByPrefix("play", "PICO ARRIVES PART 3", 24, false);
    pico_arrives_3.visible = false;
    girlfriend.add(pico_arrives_3);

    tankman.c.visible = false;
    girlfriend.c.visible = false;
    
    boyfriend.playAnim("singleIdle", true, true, false, 0);
    girlfriend.playAnim("gf_idle", true, true, false, 0);
}

function startSong(_startCountdown:Void->Void):Void {
    if(!PlayState.isStoryMode || PlayState.total_plays > 1){return false;}
    startCountdown = _startCountdown;

    Character.setCameraToCharacter(tankman, camFollow, getState().stage);
    FlxTween.tween(getState().camHUD, {alpha: 0}, 0.5);

    Timer.delay(function(){onCinematic = true;}, 1000);

    return true;
}

function update(elapsed:Float){
    if(!onCinematic){return;}
    total_time += elapsed;
    
    if(total_time >= 0.5 && total_events == 0){
        total_events++;

        stressCinematic1.animation.play("play");
        FlxG.sound.play(SavedFiles.getSound(Paths.sound("stress_1", "stages/war")), 1, false, null, true);
    }else if(total_time >= 15.25 && total_events == 1){
        total_events++;

        gf_idle.visible = false;
        gf_demon_1.visible = true;
        gf_demon_1.animation.play("play");
        Character.setCameraToCharacter(girlfriend, camFollow, getState().stage);
        FlxTween.tween(FlxG.camera, {zoom: 1.25}, 1, {ease: FlxEase.quadInOut});
    }else if(total_time >= 16.784 && total_events == 2){
        total_events++;

        gf_demon_2.visible = true;
        gf_demon_1.visible = false;
        gf_demon_2.animation.play("play");
    }else if(total_time >= 17.737  && total_events == 3){
        total_events++;

        FlxTween.tween(FlxG.camera, {zoom: stage.zoom}, 1, {ease: FlxEase.quadInOut});
        
        gf_demon_2.visible = false;
        pico_arrives_1.visible = true;
        pico_arrives_1.animation.play("play");
        boyfriend.playAnim("catch", true, true, false, 0);
    }else if(total_time >= 18.745  && total_events == 4){
        total_events++;

        pico_arrives_2.visible = true;
        pico_arrives_1.visible = false;
        pico_arrives_2.animation.play("play");
    }else if(total_time >= 19.75  && total_events == 5){
        total_events++;

        stressCinematic2.visible = true;
        stressCinematic1.visible = false;
        stressCinematic2.animation.play("play");
        Character.setCameraToCharacter(tankman, camFollow, getState().stage);
    }else if(total_time >= 20.12  && total_events == 6){
        total_events++;

        pico_arrives_3.visible = true;
        pico_arrives_2.visible = false;
        pico_arrives_3.animation.play("play");
    }else if(total_time >= 21.748  && total_events == 7){
        total_events++;

        pico_arrives_3.visible = false;
        girlfriend.c.visible = true;
        girlfriend.playAnim("right1-loop", true, true, false, 0);
    }else if(total_time >= 32.75  && total_events == 8){
        total_events++;

        Character.setCameraToCharacter(boyfriend, camFollow, getState().stage);
        boyfriend.playAnim("singUPmiss", true, true, false, 0);
    }else if(total_time >= 35  && total_events == 9){
        total_events++;
        
        girlfriend.c.visible = true;
        tankman.c.visible = true;
        
        gf_idle.kill();
        gf_demon_1.kill();
        gf_demon_2.kill();
        pico_arrives_1.kill();
        pico_arrives_2.kill();
        pico_arrives_3.kill();
        stressCinematic1.kill();
        stressCinematic2.kill();

        boyfriend.specialAnim = false;
        girlfriend.specialAnim = false;
        tankman.specialAnim = false;

        girlfriend.dance();
        boyfriend.dance();
        tankman.dance();

        FlxTween.tween(getState().camHUD, {alpha: 1}, 0.5);

        startCountdown();
    }else if(total_time >= 36  && total_events == 10){
        total_events++;
        
        girlfriend.remove(gf_idle);
        girlfriend.remove(gf_demon_1);
        girlfriend.remove(gf_demon_2);
        girlfriend.remove(pico_arrives_1);
        girlfriend.remove(pico_arrives_2);
        girlfriend.remove(pico_arrives_3);
        tankman.remove(stressCinematic2);
        tankman.remove(stressCinematic1);

        gf_idle.destroy();
        gf_demon_1.destroy();
        gf_demon_2.destroy();
        pico_arrives_1.destroy();
        pico_arrives_2.destroy();
        pico_arrives_3.destroy();
        stressCinematic2.destroy();
        stressCinematic1.destroy();

        onCinematic = false;
    }
}