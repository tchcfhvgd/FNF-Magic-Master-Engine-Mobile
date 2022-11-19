import("Note");
import("Paths");
import("Std");

presset("defaultValues", 
    [
        {name:"Scroll",type:"Float",value:3},
        {name:"Id",type:"Int",value:0}
    ]
);

function execute(scroll:Float, id:Int):Void {
    if(id != null){getState().strumsGroup.members[id].scrollSpeed = scroll;}else{
        for(s in getState().strumsGroup){s.scrollSpeed = scroll;}
    }
}