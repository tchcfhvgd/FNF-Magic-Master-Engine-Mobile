import("Note");
import("PreSettings");
import("Reflect");
import("Paths");
import("StringTools");

import("flixel.FlxG", "FlxG");

presset("defaultValues", 
    [
        {name:"Char List",type:"Array",value:"[]"}
    ]
);

function execute(value:Array<Int>){
    if(_note == null || value.length <= 0){return;}
    Reflect.setProperty(_note, "singCharacters", value);
}