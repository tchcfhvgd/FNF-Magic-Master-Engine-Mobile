import("Note");
import("Paths");
import("Stage");
import("Std");

presset("execute", function(name:String){});

function preload():Void {for(e in prefunctions){var _stage = new Stage(e[0]);}}

function execute(name:String):Void {
    getState().stage.loadStage(name);
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Change Stage] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this Event you will be able to change the Stage."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"NAME"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nNAME: (String)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe name of the New Stage"},
    ]
);