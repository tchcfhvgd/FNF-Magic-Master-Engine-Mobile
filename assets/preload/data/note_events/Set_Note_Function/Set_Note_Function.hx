import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("execute", function(funct:String, args:Array<Dynamic>){});

function execute(funct:String, args:Array<Dynamic>){
    if(_note == null || funct == "" || args.lenght <= 0){trace("JAJA RETURN"); return;}
    Reflect.callMethod(_note, Reflect.field(_note, funct), args);
}