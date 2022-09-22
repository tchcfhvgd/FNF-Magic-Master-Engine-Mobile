import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("execute", function(property:String, value:String){});

var note:Note = null;
function setNote(setNote:Note){note = setNote;}

function execute(property:String, value:String){
    if(note == null || property == "" ||value == ""){trace("JAJA RETURN"); return;}
    Reflect.setProperty(note, property, value);
}