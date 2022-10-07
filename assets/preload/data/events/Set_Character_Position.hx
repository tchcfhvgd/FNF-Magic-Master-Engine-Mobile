import("Note");
import("Paths");
import("Character");
import("Std");

presset("execute", function(id:Int, x:Int, y:Int){});

function execute(id:Int, x:Int, y:Int):Void {
    var _character:Character = getState().stage.getCharacterById(id);
    _character.setPosition(x + _character.positionArray[0], y + _character.positionArray[1]);
}

presset("info",
    [
        {animated:true,bold:true,scale:0.9,text:"  [Character Position] Event Wiki"},
        {animated:true,bold:true,scale:0.7,text:"\n\nDescription: \nWith this event you will make a character change its position."},
        {animated:true,bold:true,scale:0.7,text:"\n\nSyntax:"},
        {animated:false,bold:true,scale:0.7,text:"["},
        {animated:true,bold:true,scale:0.7,text:"ID"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"X"},
        {animated:false,bold:true,scale:0.7,text:","},
        {animated:true,bold:true,scale:0.7,text:"Y"},
        {animated:false,bold:true,scale:0.7,text:"]"},

        {animated:true,bold:true,scale:0.5,text:"\n\nID: (Int)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe Character ID"},
        {animated:true,bold:true,scale:0.5,text:"\n\nX: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe new position in X"},
        {animated:true,bold:true,scale:0.5,text:"\n\nY: (Float)"},
        {animated:true,bold:true,scale:0.35,text:"\nThe new position in Y"},
    ]
);