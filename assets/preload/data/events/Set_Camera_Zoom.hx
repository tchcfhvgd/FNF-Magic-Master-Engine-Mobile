import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Std");

presset("execute", function(_zoom:Float, _delay:Float, toPercent:Bool){});

var curZoom:Float = 0;
function create():Void {
    curZoom = getState().stage.zoom;
}

function execute(_zoom:Float, _delay:Float, toPercent:Bool):Void {
    if(_zoom == curZoom){return;}

    if(_delay <= 0){
        if(toPercent){FlxG.camera.zoom = _zoom * curZoom / 1;}else{FlxG.camera.zoom = _zoom;}
    }else{
        if(toPercent){
            FlxTween.tween(FlxG.camera, {zoom: _zoom}, _delay, {ease: FlxEase.cubeInOut});
        }else{
            FlxTween.tween(FlxG.camera, {zoom: _zoom * curZoom / 1}, _delay, {ease: FlxEase.cubeInOut});
        }
    }
}