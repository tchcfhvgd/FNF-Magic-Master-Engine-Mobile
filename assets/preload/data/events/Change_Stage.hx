import("Note");
import("Paths");
import("Stage");
import("Std");

presset("execute", function(name:String){});

function preload():Void {for(e in prefunctions){var _stage = new Stage(e[0]);}}

function execute(name:String):Void {
    getState().stage.loadStage(name);
}