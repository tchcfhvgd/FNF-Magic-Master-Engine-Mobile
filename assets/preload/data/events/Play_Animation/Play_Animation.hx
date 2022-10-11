import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

presset("execute", function(id:Int, name:String){});

function execute(id:Int, name:String):Void {
    getState().stage.getCharacterById(id).playAnim(name);
}