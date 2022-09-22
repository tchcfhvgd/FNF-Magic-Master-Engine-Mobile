import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("execute", function(funct:String, args:Array<Dynamic>){});

var note:Note = null;
function setNote(setNote:Note){note = setNote;}

function execute(funct:String, args:Array<Dynamic>){
    if(note == null || funct == "" || args.lenght <= 0){trace("JAJA RETURN"); return;}
    Reflect.callMethod(note, Reflect.field(note, funct), args);
}