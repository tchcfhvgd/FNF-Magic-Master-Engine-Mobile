import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

preset("defaultValues", 
    [
        {name:"Id",type:"Int",value:0},
        {name:"Name",type:"String",value:"hey"}
    ]
);

function execute(id:Int, name:String):Void {
    getState().stage.getCharacterById(id).singAnim(name);
}