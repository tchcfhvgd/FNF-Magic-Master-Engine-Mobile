
import("flixel.FlxG", "FlxG");

import("Paths");
import("Note");
import("Std");

preset("defaultValues", 
    [
        {name:"Id",type:"Int",value:0},
        {name:"Name",type:"String",value:"hey"},
        {name:"Force",type:"Bool",value:false},
        {name:"Special",type:"Bool",value:false}
    ]
);

function execute(id:Int, name:String, force:Bool, special:Bool):Void {
    if(getState().stage == null){return;}
    var _character:Character = getState().stage.getCharacterById(id);
    if(_character == null){return;}
    _character.playAnim(name, force, special);
}