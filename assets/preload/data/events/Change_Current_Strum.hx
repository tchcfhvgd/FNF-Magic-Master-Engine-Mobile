import("Note");
import("Paths");
import("Std");

presset("execute", function(strum:String){});

function execute(strum:String){
    getState().changeStrum(Std.parseInt(strum));
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Change Current Strum] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you can change the Strum used by the player."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"STRUM"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nSTRUM: (Integer)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe ID of the new Strum to be used"},
    ]
);