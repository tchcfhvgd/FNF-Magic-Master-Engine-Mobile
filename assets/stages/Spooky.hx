/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"0","id":"initChar"},{"type":"Array","isPresset":true,"value":[400,230],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[1300,570],"id":"camP_2"},{"type":"Float","isPresset":true,"value":1.1,"id":"zoom"}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('halloween_bg','stages/spooky',true)});
}

presset("initChar", 0);
presset("camP_1", [400,230]);
presset("camP_2", [1300,570]);
presset("zoom", 1.1);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Play_Anim":"idle","Graphic_Library":"stages/spooky","Sprite_Name":"background","Position":[-200,-110],"Graphic_File":"halloween_bg","Anims_Prefix":[["idle","halloweem bg lightning strike",30,false]]} */

var background_position:Array<Int> = [-200,-110];

var background = new FlxSprite(background_position[0], background_position[1]);
instance.add(background);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/spooky","Play_Anim":"idle","Position":[-200,-110],"Sprite_Name":"background","Anims_Prefix":[["idle","halloweem bg lightning strike",30,false]],"Graphic_File":"halloween_bg"} */

background.frames = Paths.getAtlas(Paths.image('halloween_bg', 'stages/spooky', true));

var cur_prefixs:Array<Dynamic> = [["idle","halloweem bg lightning strike",30,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
background.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
background.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
}