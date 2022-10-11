import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("execute", function(value:Array<Int>){});

function execute(value:Array<Int>){
    if(_note == null || value.length <= 0){trace("JAJA RETURN"); return;}
    Reflect.setProperty(_note, "singCharacters", value);
}