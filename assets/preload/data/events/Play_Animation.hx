import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

presset("execute", function(id:Int, name:String){});

function execute(id:Int, name:String):Void {
    getState().stage.getCharacterById(id).playAnim(name);
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Play Animation] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this Event you will make a Character execute an animation."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"ID"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"ANIM"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nID: (Int)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Character ID"},
        {animated:true,bold:true,scale:0.5,text:"\n\nANIM: (String)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe name of the animation"},
    ]
);