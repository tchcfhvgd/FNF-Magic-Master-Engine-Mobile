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

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Camera Position] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you will make the camera change its position."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"X"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"Y"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"TIME"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nX: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe new position in X"},
        {animated:true,bold:true,scale:0.5,text:"\n\nY: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe new position in Y"},
        {animated:true,bold:true,scale:0.5,text:"\n\nTIME: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe length of time the camera will be in that position"},
    ]
);