/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"id":"initChar","value":"1","isPresset":true,"type":"Int"}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"stageback","Position":[-600,-300]} */

var stageback_position:Array<Int> = [-600,-300];

var stageback = new FlxSprite(stageback_position[0], stageback_position[1]);
instance.add(stageback);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Sprite_Name":"stageback","Scroll":[0.5,0.5],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var stageback_scroll:Array<Int> = [0.5,0.5];
var stageback_scale:Array<Int> = [1,1];

stageback.scale.set(stageback_scale[0], stageback_scale[1]);
stageback.scrollFactor.set(stageback_scroll[0], stageback_scroll[1]);
stageback.visible = true;
stageback.angle = 0;
stageback.alpha = 1;
stageback.flipX = false;
stageback.flipY = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/stage","Graphic_File":"stageback","Position":[-600,-300],"Sprite_Name":"stageback"} */

stageback.loadGraphic(Paths.image('stageback', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"stage_front","Position":[-600,650]} */

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
/* "Variables": {"Sprite_Name":"stage_light_1","Position":[-125,-100]} */

var stage_light_1_position:Array<Int> = [-125,-100];

var stage_light_1 = new FlxSprite(stage_light_1_position[0], stage_light_1_position[1]);
instance.add(stage_light_1);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-125,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Sprite_Name":"stage_light_1","Scroll":[0.9,0.9],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var stage_light_1_scroll:Array<Int> = [0.9,0.9];
var stage_light_1_scale:Array<Int> = [1,1];

stage_light_1.scale.set(stage_light_1_scale[0], stage_light_1_scale[1]);
stage_light_1.scrollFactor.set(stage_light_1_scroll[0], stage_light_1_scroll[1]);
stage_light_1.visible = true;
stage_light_1.angle = 0;
stage_light_1.alpha = 1;
stage_light_1.flipX = false;
stage_light_1.flipY = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/stage","Graphic_File":"stage_light","Position":[-125,-100],"Sprite_Name":"stage_light_1"} */

stage_light_1.loadGraphic(Paths.image('stage_light', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"stage_light_2","Position":[1225,-100]} */

var stage_light_2_position:Array<Int> = [1225,-100];

var stage_light_2 = new FlxSprite(stage_light_2_position[0], stage_light_2_position[1]);
instance.add(stage_light_2);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[1225,-100],"Visible":true,"Scale":[1,1],"Angle":0,"Sprite_Name":"stage_light_2","Scroll":[0.9,0.9],"Alpha":1,"Flip_X":true,"Flip_Y":false} */

var stage_light_2_scroll:Array<Int> = [0.9,0.9];
var stage_light_2_scale:Array<Int> = [1,1];

stage_light_2.scale.set(stage_light_2_scale[0], stage_light_2_scale[1]);
stage_light_2.scrollFactor.set(stage_light_2_scroll[0], stage_light_2_scroll[1]);
stage_light_2.visible = true;
stage_light_2.angle = 0;
stage_light_2.alpha = 1;
stage_light_2.flipX = true;
stage_light_2.flipY = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/stage","Graphic_File":"stage_light","Position":[1225,-100],"Sprite_Name":"stage_light_2"} */

stage_light_2.loadGraphic(Paths.image('stage_light', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"stagecurtains","Position":[-600,-300]} */

var stagecurtains_position:Array<Int> = [-600,-300];

var stagecurtains = new FlxSprite(stagecurtains_position[0], stagecurtains_position[1]);
instance.add(stagecurtains);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-600,-300],"Visible":true,"Scale":[1,1],"Angle":0,"Sprite_Name":"stagecurtains","Scroll":[1.3,1.3],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var stagecurtains_scroll:Array<Int> = [1.3,1.3];
var stagecurtains_scale:Array<Int> = [1,1];

stagecurtains.scale.set(stagecurtains_scale[0], stagecurtains_scale[1]);
stagecurtains.scrollFactor.set(stagecurtains_scroll[0], stagecurtains_scroll[1]);
stagecurtains.visible = true;
stagecurtains.angle = 0;
stagecurtains.alpha = 1;
stagecurtains.flipX = false;
stagecurtains.flipY = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/stage","Graphic_File":"stagecurtains","Position":[-600,-300],"Sprite_Name":"stagecurtains"} */

stagecurtains.loadGraphic(Paths.image('stagecurtains', 'stages/stage'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}