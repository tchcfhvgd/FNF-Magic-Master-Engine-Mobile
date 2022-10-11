import("Note");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");

presset("execute", function(_shake:Float, _dur:Float){});

function execute(_shake:Float, _dur:Float):Void {
    FlxG.camera.shake(_shake, _dur, null, true);
}