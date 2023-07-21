import("flixel.FlxG", "FlxG");

preset("defaultValues", []);

function execute():Void {
    FlxG.camera.zoom += 0.015;
    getState().camHUD.zoom += 0.03;
}