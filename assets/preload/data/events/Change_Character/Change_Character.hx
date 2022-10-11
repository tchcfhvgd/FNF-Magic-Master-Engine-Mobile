import("Note");
import("Paths");
import("Character");
import("Std");

import("flixel.math.FlxPoint", "FlxPoint");

presset("execute", function(id:Int, name:String, cat:String, type:String){});

function preload():Void {for(e in prefunctions){var _char = new Character(0, 0, e[1], e[2], e[3]);}}

function execute(id:Int, name:String, cat:String, type:String):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    var prePoint:FlxPoint = new FlxPoint(_character.x - _character.positionArray[0], _character.y - _character.positionArray[1]);
    _character.setupByName(name, cat, type);
    _character.setPosition(prePoint.x + _character.positionArray[0], prePoint.y + _character.positionArray[0]);
}