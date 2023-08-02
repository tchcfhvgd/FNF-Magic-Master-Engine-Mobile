import("flixel.FlxG", "FlxG");

import("String");
import("Std");

preset("defaultValues", [
    {name:"Camera Zoom",type:"Float",value:0.015},
    {name:"HUD Zoom",type:"Float",value:0.03},
]);

function execute(value1:Dymamic, value2:Dymamic):Void {
    if(!getState().pre_BumpingCamera){return;}

    if(Std.isOfType(value1, String)){value1 = Std.parseFloat(value1);}
    if(Std.isOfType(value2, String)){value2 = Std.parseFloat(value2);}

    FlxG.camera.zoom += value1;
    getState().camHUD.zoom += value2;
}