/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"isPresset":true,"type":"Int","id":"initChar","value":"1"},{"type":"Float","isPresset":true,"value":1.1,"id":"zoom"},{"type":"Array","isPresset":true,"value":[430,310],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[1080,600],"id":"camP_2"}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);
presset("zoom", 1.1);
presset("camP_1", [430,310]);
presset("camP_2", [1080,600]);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,200],"Scale":[6,6],"Visible":true,"Angle":0,"Graphic_File":"animatedEvilSchool","Graphic_Library":"stages/schoolEvil","Antialiasing":false,"Play_Anim":"idle","Sprite_Name":"bgSky","Scroll":[1,1],"Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","background 2"]]} */

var bgSky_position:Array<Int> = [500,200];

var bgSky = new FlxSprite(bgSky_position[0], bgSky_position[1]);
instance.add(bgSky);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,200],"Visible":true,"Scale":[6,6],"Graphic_File":"animatedEvilSchool","Angle":0,"Antialiasing":false,"Graphic_Library":"stages/schoolEvil","Play_Anim":"idle","Scroll":[1,1],"Sprite_Name":"bgSky","Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","background 2"]],"Flip_Y":false} */

bgSky.frames = Paths.getAtlas(Paths.image('animatedEvilSchool', 'stages/schoolEvil', true));

var cur_prefixs:Array<Dynamic> = [["idle","background 2"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
bgSky.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
bgSky.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,200],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"animatedEvilSchool","Play_Anim":"idle","Graphic_Library":"stages/schoolEvil","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"bgSky","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","background 2"]]} */

var bgSky_scroll:Array<Int> = [1,1];
var bgSky_scale:Array<Int> = [6,6];

bgSky.scale.set(bgSky_scale[0], bgSky_scale[1]);
bgSky.scrollFactor.set(bgSky_scroll[0], bgSky_scroll[1]);
bgSky.visible = true;
bgSky.angle = 0;
bgSky.alpha = 1;
bgSky.flipX = false;
bgSky.flipY = false;
bgSky.antialiasing = false;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
}