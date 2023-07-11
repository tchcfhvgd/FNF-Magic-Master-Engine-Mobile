import("Note");
import("Paths");
import("Character");
import("Std");

presset("defaultValues", []);

function execute():Void {
    getState().stage.script.exFunction("run_car", []);
}