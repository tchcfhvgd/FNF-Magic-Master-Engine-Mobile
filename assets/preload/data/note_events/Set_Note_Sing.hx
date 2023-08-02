import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Reflect");
import("StringTools");
import("PreSettings");

preset("defaultValues", 
    [
        {name:"Char List",type:"Array",value:[]}
    ]
);

function execute(value:Array<Int>){
    if(_note == null || value.length <= 0){return;}
    Reflect.setProperty(_note, "singCharacters", value);
}