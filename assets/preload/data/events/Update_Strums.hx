import("flixel.FlxG", "FlxG");

import("String");
import("Std");

preset("defaultValues", []);

function execute():Void {
    getState().changeStrumPositions();
}