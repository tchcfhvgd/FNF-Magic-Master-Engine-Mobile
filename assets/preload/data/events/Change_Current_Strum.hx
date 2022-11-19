import("Note");
import("Paths");
import("Std");

presset("defaultValues", 
    [
        {name:"Strum",type:"Int",value:0}
    ]
);

function execute(strum:Int){
    getState().changeStrum(strum);
}