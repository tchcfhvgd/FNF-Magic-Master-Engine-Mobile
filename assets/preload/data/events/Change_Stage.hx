import("Note");
import("Paths");
import("Stage");
import("Std");

presset("defaultValues", 
    [
        {name:"Name",type:"String",value:"Stage"}
    ]
);

function execute(name:String):Void {
    getState().stage.loadStage(name);
}