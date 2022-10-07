import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

presset("execute", function(_shake:Float, _dur:Float){});

function execute(_shake:Float, _dur:Float):Void {
    FlxG.camera.shake(_shake, _dur, null, true);
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Screen Shake] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you will make the camera shake."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"INTENSITY"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"DURATION"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nINTENSITY: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Shake Intensity (0.05 is recommended)"},
        {animated:true,bold:true,scale:0.5,text:"\n\nDURATION: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe duration of the shake in seconds"},
    ]
);