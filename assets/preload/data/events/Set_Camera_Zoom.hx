import("flixel.tweens.FlxTween", "FlxTween");
import("flixel.tweens.FlxEase", "FlxEase");
import("flixel.FlxG", "FlxG");

import("Note");
import("Paths");
import("Std");

presset("execute", function(_zoom:Float, _delay:Float, toPercent:Bool){});

var curZoom:Float = 0;
function create():Void {
    curZoom = getState().stage.zoom;
}

function execute(_zoom:Float, _delay:Float, toPercent:Bool):Void {
    if(_zoom == curZoom){return;}

    if(_delay <= 0){
        if(toPercent){FlxG.camera.zoom = _zoom * curZoom / 1;}else{FlxG.camera.zoom = _zoom;}
    }else{
        if(toPercent){
            FlxTween.tween(FlxG.camera, {zoom: _zoom}, _delay, {ease: FlxEase.cubeInOut});
        }else{
            FlxTween.tween(FlxG.camera, {zoom: _zoom * curZoom / 1}, _delay, {ease: FlxEase.cubeInOut});
        }
    }
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Camera Zoom] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you will change the Zoom of the camera."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"ZOOM"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"DELAY"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"PERCENT"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nZOOM: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe new Zoom"},
        {animated:true,bold:true,scale:0.5,text:"\n\nDELAY: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe time it will take for the camera to take that Zoom (in seconds)"},
        {animated:true,bold:true,scale:0.5,text:"\n\nPERCENT: (Bool)"},
        {animated:true,bold:true,scale:0.35,text:"\n\tIf True: The camera will zoom according to ZOOM percentage with respect to the original zoom \t Example:\n If CameraZoom:0.8 and ZOOM:1.5, the new Zoom is (0.8*1.5) = 1.2"},
        {animated:true,bold:true,scale:0.35,text:"\n\tIf False: The camera will take a Zoom according to ZOOM \t Example:\n If CameraZoom:0.8 and ZOOM:1.5, the new Zoom is = 1.5"},
    ]
);