
import("Character");
import("Paths");
import("Note");
import("Std");

preset("defaultValues", 
    [
        {name:"Id",type:"Int",value:0},
        {name:"Name",type:"String",value:"Boyfriend"},
        {name:"Category",type:"String",value:"Default"},
        {name:"Type",type:"String",value:"Default"}
    ]
);

function execute(id:Int, name:String, cat:String, type:String):Void {
    if(getState().stage == null){return;}
    var _character:Character = getState().stage.getCharacterById(id);
    if(_character == null){return;}
    _character.setupByName(name, cat, type);
}