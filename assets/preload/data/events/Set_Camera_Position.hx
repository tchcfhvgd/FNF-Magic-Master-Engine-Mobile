import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.math.FlxPoint", "FlxPoint");
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Std");

presset("execute", function(x:Int, y:Int, time:Float){});

function execute(x:Int, y:Int, time:Float):Void {
    getState().followChar = false;
    getState().camFollow.setPosition(x,y);
    new FlxTimer().start(time, function(tmr:FlxTimer){getState().followChar = true;});
}