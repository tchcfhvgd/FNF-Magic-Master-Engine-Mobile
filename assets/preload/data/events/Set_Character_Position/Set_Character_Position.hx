import("Note");
import("Paths");
import("Character");
import("Std");

presset("execute", function(id:Int, x:Int, y:Int){});

function execute(id:Int, x:Int, y:Int):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    _character.setPosition(x + _character.positionArray[0], y + _character.positionArray[1]);
}