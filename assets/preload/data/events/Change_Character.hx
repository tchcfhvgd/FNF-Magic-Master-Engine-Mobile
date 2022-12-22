import("Note");
import("Paths");
import("Character");
import("Std");

presset("defaultValues", 
    [
        {name:"Id",type:"Int",value:0},
        {name:"Name",type:"String",value:"Boyfriend"},
        {name:"Category",type:"String",value:"Default"},
        {name:"Type",type:"String",value:"Default"}
    ]
);

function execute(id:Int, name:String, cat:String, type:String):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    _character.setupByName(name, cat, type);
}