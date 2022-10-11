import("Note");
import("Paths");
import("Std");

presset("execute", function(strum:String){});

function execute(strum:String){
    getState().changeStrum(Std.parseInt(strum));
}