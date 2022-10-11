import("Note");
import("Paths");
import("Std");

presset("execute", function(id:Int, scroll:Float){});

function execute(scroll:Float, id:Int):Void {
    if(id != null){getState().strumsGroup.members[id].scrollSpeed = scroll;}else{
        for(s in getState().strumsGroup){s.scrollSpeed = scroll;}
    }
}