import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Std");

presset("defaultValues", 
    [
        {name:"Zoom",type:"Float",value:0},
        {name:"Steps",type:"Float",value:4},
        {name:"Type",type:"List",value:0,list:["Add","Set","Percent"]}
    ]
);

var initZoom:Float = 0;
var cur_zoom:Float = 0;
var curTween:FlxTween = null;
function preload():Void {
    curTween = null;
    initZoom = getState().stage.zoom;
    cur_zoom = getState().stage.zoom;
}

function execute(_zoom:Float, _delay:Float, _type:String):Void {
    if(curTween != null){curTween.active = false;}

    switch(_type){
        case "Set":{if(_zoom != 0){cur_zoom = _zoom;}else{cur_zoom = initZoom;}}
        case "Add":{if(_zoom != 0){cur_zoom += _zoom;}else{cur_zoom = initZoom;}}
        case "Percent":{cur_zoom = initZoom * _zoom;}
    }

    var step:Float = getState().conductor.stepCrochet / 1000;
    if(_delay <= 0){FlxG.camera.zoom = cur_zoom;}else{curTween = FlxTween.tween(FlxG.camera, {zoom: cur_zoom}, step * _delay, {ease: FlxEase.quadInOut});}
}