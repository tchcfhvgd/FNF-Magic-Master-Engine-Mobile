import("Note");
import("Paths");
import("Character");
import("Std");

presset("defaultValues", 
    [
        {name:"Id",type:"Int",value:0},
        {name:"X",type:"Int",value:0},
        {name:"Y",type:"Int",value:0}
    ]
);

function execute(id:Int, x:Int, y:Int):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    _character.setPosition(x + _character.positionArray[0], y + _character.positionArray[1]);
}