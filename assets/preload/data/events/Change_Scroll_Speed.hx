import("Note");
import("Paths");
import("Std");

presset("execute", function(id:Int, scroll:Float){});

function execute(scroll:Float, id:Int):Void {
    if(id != null){getState().strumsGroup.members[id].scrollSpeed = scroll;}else{
        for(s in getState().strumsGroup){s.scrollSpeed = scroll;}
    }
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Change Current Strum] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you will be able to change the speed of the notes."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"STRUM"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nSTRUM: (Integer)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe ID of the new Strum to be used"},
    ]
);