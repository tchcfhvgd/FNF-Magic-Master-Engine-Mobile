import("Note");
import("Paths");
import("Character");
import("Std");

import("flixel.math.FlxPoint", "FlxPoint");

presset("execute", function(id:Int, name:String, cat:String, type:String){});

function preload():Void {for(e in prefunctions){var _char = new Character(0, 0, e[1], e[2], e[3]);}}

function execute(id:Int, name:String, cat:String, type:String):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    var prePoint:FlxPoint = new FlxPoint(_character.x - _character.positionArray[0], _character.y - _character.positionArray[1]);
    _character.setupByName(name, cat, type);
    _character.setPosition(prePoint.x + _character.positionArray[0], prePoint.y + _character.positionArray[0]);
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Change Character] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this Event you will be able to change a character that is on the Stage."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"ID"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"NAME"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"CATEGORY"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"TYPE"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nID: (Integer)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe ID of the Character you want to change"},
        {animated:true,bold:true,scale:0.5,text:"\n\nNAME: (String)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Name of the New Character"},
        {animated:true,bold:true,scale:0.5,text:"\n\nCategory: (String)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Category of the New Character\nIf you don't want to change it. Leave this argument in `null`"},
        {animated:true,bold:true,scale:0.5,text:"\n\nTYPE: (String)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Type of the New Character\nIf you don't want to change it. Leave this argument in `null`"},
    ]
);