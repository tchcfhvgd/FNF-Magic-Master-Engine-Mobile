/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":1,"id":"initChar"},{"isPresset":true,"type":"Array","id":"camP_1","value":[250,180]},{"isPresset":true,"type":"Array","id":"camP_2","value":[1095,800]},{"isPresset":true,"type":"Float","id":"zoom","value":0.9}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('stageback','stages/stage',true)});
temp.push({type:"ATLAS",instance:Paths.image('stagefront','stages/stage',true)});
temp.push({type:"ATLAS",instance:Paths.image('stage_light','stages/stage',true)});
temp.push({type:"ATLAS",instance:Paths.image('stage_light','stages/stage',true)});
temp.push({type:"ATLAS",instance:Paths.image('stagecurtains','stages/stage',true)});
}

presset("initChar", 1);
presset("camP_1", [250,180]);
presset("camP_2", [1095,800]);
presset("zoom", 0.9);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stageback","Antialiasing":true,"Graphic_Library":"stages/stage","Sprite_Name":"stageback","Scroll":[0.5,0.5],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var stageback_position:Array<Int> = [-600,-300];

var stageback = new FlxSprite(stageback_position[0], stageback_position[1]);
instance.add(stageback);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stageback","Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.5,0.5],"Sprite_Name":"stageback","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var stageback_scroll:Array<Int> = [0.5,0.5];
var stageback_scale:Array<Int> = [1,1];

stageback.scale.set(stageback_scale[0], stageback_scale[1]);
stageback.scrollFactor.set(stageback_scroll[0], stageback_scroll[1]);
stageback.visible = true;
stageback.angle = 0;
stageback.alpha = 1;
stageback.flipX = false;
stageback.flipY = false;
stageback.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-600,-300],"Scale":[1,1],"Visible":true,"Graphic_File":"stageback","Angle":0,"Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.5,0.5],"Sprite_Name":"stageback","Alpha":1,"Flip_X":false,"Flip_Y":false} */

stageback.loadGraphic(Paths.image('stageback', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/stage","Sprite_Name":"stage_front","Position":[-600,650],"Graphic_File":"stagefront"} */

var stage_front_position:Array<Int> = [-600,650];

var stage_front = new FlxSprite(stage_front_position[0], stage_front_position[1]);
instance.add(stage_front);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/stage","Graphic_File":"stagefront","Position":[-600,650],"Sprite_Name":"stage_front"} */

stage_front.loadGraphic(Paths.image('stagefront', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-125,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stage_light","Antialiasing":true,"Graphic_Library":"stages/stage","Sprite_Name":"stage_light_1","Scroll":[0.9,0.9],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var stage_light_1_position:Array<Int> = [-125,-100];

var stage_light_1 = new FlxSprite(stage_light_1_position[0], stage_light_1_position[1]);
instance.add(stage_light_1);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-125,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stage_light","Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.9,0.9],"Sprite_Name":"stage_light_1","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var stage_light_1_scroll:Array<Int> = [0.9,0.9];
var stage_light_1_scale:Array<Int> = [1,1];

stage_light_1.scale.set(stage_light_1_scale[0], stage_light_1_scale[1]);
stage_light_1.scrollFactor.set(stage_light_1_scroll[0], stage_light_1_scroll[1]);
stage_light_1.visible = true;
stage_light_1.angle = 0;
stage_light_1.alpha = 1;
stage_light_1.flipX = false;
stage_light_1.flipY = false;
stage_light_1.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-125,-100],"Scale":[1,1],"Visible":true,"Graphic_File":"stage_light","Angle":0,"Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.9,0.9],"Sprite_Name":"stage_light_1","Alpha":1,"Flip_X":false,"Flip_Y":false} */

stage_light_1.loadGraphic(Paths.image('stage_light', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[1225,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stage_light","Antialiasing":true,"Graphic_Library":"stages/stage","Sprite_Name":"stage_light_2","Scroll":[0.9,0.9],"Flip_X":true,"Alpha":1,"Flip_Y":false} */

var stage_light_2_position:Array<Int> = [1225,-100];

var stage_light_2 = new FlxSprite(stage_light_2_position[0], stage_light_2_position[1]);
instance.add(stage_light_2);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[1225,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stage_light","Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.9,0.9],"Sprite_Name":"stage_light_2","Flip_X":true,"Alpha":1,"Flip_Y":false} */

var stage_light_2_scroll:Array<Int> = [0.9,0.9];
var stage_light_2_scale:Array<Int> = [1,1];

stage_light_2.scale.set(stage_light_2_scale[0], stage_light_2_scale[1]);
stage_light_2.scrollFactor.set(stage_light_2_scroll[0], stage_light_2_scroll[1]);
stage_light_2.visible = true;
stage_light_2.angle = 0;
stage_light_2.alpha = 1;
stage_light_2.flipX = true;
stage_light_2.flipY = false;
stage_light_2.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[1225,-100],"Scale":[1,1],"Visible":true,"Graphic_File":"stage_light","Angle":0,"Graphic_Library":"stages/stage","Antialiasing":true,"Scroll":[0.9,0.9],"Sprite_Name":"stage_light_2","Alpha":1,"Flip_X":true,"Flip_Y":false} */

stage_light_2.loadGraphic(Paths.image('stage_light', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stagecurtains","Play_Anim":"open","Antialiasing":true,"Graphic_Library":"stages/stage","Sprite_Name":"stagecurtains","Scroll":[1.3,1.3],"Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["open","Curtains",false]]} */

var stagecurtains_position:Array<Int> = [-600,-300];

var stagecurtains = new FlxSprite(stagecurtains_position[0], stagecurtains_position[1]);
instance.add(stagecurtains);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"stagecurtains","Graphic_Library":"stages/stage","Play_Anim":"open","Antialiasing":true,"Scroll":[1.3,1.3],"Sprite_Name":"stagecurtains","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["open","Curtains",false]]} */

var stagecurtains_scroll:Array<Int> = [1.3,1.3];
var stagecurtains_scale:Array<Int> = [1,1];

stagecurtains.scale.set(stagecurtains_scale[0], stagecurtains_scale[1]);
stagecurtains.scrollFactor.set(stagecurtains_scroll[0], stagecurtains_scroll[1]);
stagecurtains.visible = true;
stagecurtains.angle = 0;
stagecurtains.alpha = 1;
stagecurtains.flipX = false;
stagecurtains.flipY = false;
stagecurtains.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-600,-300],"Scale":[1,1],"Visible":true,"Graphic_File":"stagecurtains","Angle":0,"Graphic_Library":"stages/stage","Play_Anim":"open","Antialiasing":true,"Scroll":[1.3,1.3],"Sprite_Name":"stagecurtains","Alpha":1,"Flip_X":false,"Anims_Prefix":[["open","Curtains",false]],"Flip_Y":false} */

stagecurtains.loadGraphic(Paths.image('stagecurtains', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}