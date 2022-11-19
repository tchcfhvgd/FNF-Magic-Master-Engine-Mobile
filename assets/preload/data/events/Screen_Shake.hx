import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

presset("defaultValues", 
    [
        {name:"Shake",type:"Float",value:0.03},
        {name:"Duration",type:"Float",value:1}
    ]
);

function execute(_shake:Float, _dur:Float):Void {
    FlxG.camera.shake(_shake, _dur, null, true);
}