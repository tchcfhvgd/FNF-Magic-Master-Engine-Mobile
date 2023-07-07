import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxG", "FlxG");

import("Std");
import("Note");
import("Paths");

presset("defaultValues", 
    [
        {name:"Appear",type:"Bool",value:true},
    ]
);

var upBar:FlxSprite;
var bottomBar:FlxSprite;
var current_tween_up:FlxTween = null;
var current_tween_bottom:FlxTween = null;

function preload():Void {
    upBar = new FlxSprite(0, -110).makeGraphic(FlxG.width, 110, 0xFF000000);
    upBar.cameras = [getState().camBHUD];
    getState().add(upBar);

    bottomBar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 110, 0xFF000000);
    bottomBar.cameras = [getState().camBHUD];
    getState().add(bottomBar);
}

function execute(_appear:Float):Void {
    var step:Float = getState().conductor.stepCrochet / 1000;

    if(current_tween_up != null){current_tween_up.cancel();}
    if(current_tween_bottom != null){current_tween_bottom.cancel();}

    if(_appear){
        current_tween_up = FlxTween.tween(upBar, {y: 0}, (step * 4), {ease: FlxEase.quadOut});
        current_tween_bottom = FlxTween.tween(bottomBar, {y: FlxG.height - 110}, (step * 4), {ease: FlxEase.quadOut});
    }else{
        current_tween_up = FlxTween.tween(upBar, {y: - 110}, (step * 4), {ease: FlxEase.quadOut});
        current_tween_bottom = FlxTween.tween(bottomBar, {y: FlxG.height}, (step * 4), {ease: FlxEase.quadOut});
    }
}