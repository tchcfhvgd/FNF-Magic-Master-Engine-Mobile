import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Std");

preset("defaultValues", 
    [
        {name:"X",type:"Int",value:0},
        {name:"Y",type:"Int",value:0},
        {name:"Steps",type:"Float",value:1}
    ]
);

function execute(x:Int, y:Int, time:Float):Void {
    getState().followChar = false;
    getState().camFollow.setPosition(x,y);
    
    var step:Float = getState().conductor.stepCrochet / 1000;
    getState().timers.push(new FlxTimer().start((time * step), function(tmr:FlxTimer){getState().followChar = true;}));
}