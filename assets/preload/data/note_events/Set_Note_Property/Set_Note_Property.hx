import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("execute", function(property:String, value:String){});

function execute(property:String, value:String){
    if(_note == null || property == "" ||value == ""){trace("JAJA RETURN"); return;}
    Reflect.setProperty(_note, property, value);
}