/* ||===================================================|| */
/* || SCRIPTED STAGE - DON'T EXPORT IN THE STAGE EDITOR || */
/* ||===================================================|| */

/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"6","id":"initChar"},{"isPresset":true,"type":"Float","id":"zoom","value":1},{"isPresset":true,"type":"Array","id":"camP_1","value":[380,310]},{"isPresset":true,"type":"Array","id":"camP_2","value":[930,530]}] */

import("openfl.filters.ShaderFilter", "ShaderFilter");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxGame", "FlxGame");
import("flixel.FlxG", "FlxG");

import("states.PlayState", "PlayState");
import("FlxCustomShader");
import("Paths");
import("Std");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('weebSky','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('weebSchool','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('weebStreet','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('weebTreesBack','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('weebTrees','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('petals','stages/school',true)});
temp.push({type:"ATLAS",instance:Paths.image('bgFreaks','stages/school',true)});
}

presset("initChar", 6);
presset("zoom", 1);
presset("camP_1", [380,310]);
presset("camP_2", [930,530]);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebSky","Graphic_Library":"stages/school","Antialiasing":false,"Sprite_Name":"bgSky","Scroll":[0.1,0.1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bgSky_position:Array<Int> = [500,350];

var bgSky = new FlxSprite(bgSky_position[0], bgSky_position[1]);
instance.add(bgSky);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebSky","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[0.1,0.1],"Sprite_Name":"bgSky","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bgSky_scroll:Array<Int> = [0.1,0.1];
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
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,350],"Scale":[6,6],"Visible":true,"Graphic_File":"weebSky","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[0.1,0.1],"Sprite_Name":"bgSky","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bgSky.loadGraphic(Paths.image('weebSky', 'stages/school'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebSchool","Graphic_Library":"stages/school","Antialiasing":false,"Sprite_Name":"bgSchool","Scroll":[0.3,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bgSchool_position:Array<Int> = [500,350];

var bgSchool = new FlxSprite(bgSchool_position[0], bgSchool_position[1]);
instance.add(bgSchool);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebSchool","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[0.3,1],"Sprite_Name":"bgSchool","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bgSchool_scroll:Array<Int> = [0.3,1];
var bgSchool_scale:Array<Int> = [6,6];

bgSchool.scale.set(bgSchool_scale[0], bgSchool_scale[1]);
bgSchool.scrollFactor.set(bgSchool_scroll[0], bgSchool_scroll[1]);
bgSchool.visible = true;
bgSchool.angle = 0;
bgSchool.alpha = 1;
bgSchool.flipX = false;
bgSchool.flipY = false;
bgSchool.antialiasing = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,350],"Scale":[6,6],"Visible":true,"Graphic_File":"weebSchool","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[0.3,1],"Sprite_Name":"bgSchool","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bgSchool.loadGraphic(Paths.image('weebSchool', 'stages/school'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebStreet","Graphic_Library":"stages/school","Antialiasing":false,"Sprite_Name":"bgStreet","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bgStreet_position:Array<Int> = [500,350];

var bgStreet = new FlxSprite(bgStreet_position[0], bgStreet_position[1]);
instance.add(bgStreet);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebStreet","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"bgStreet","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bgStreet_scroll:Array<Int> = [1,1];
var bgStreet_scale:Array<Int> = [6,6];

bgStreet.scale.set(bgStreet_scale[0], bgStreet_scale[1]);
bgStreet.scrollFactor.set(bgStreet_scroll[0], bgStreet_scroll[1]);
bgStreet.visible = true;
bgStreet.angle = 0;
bgStreet.alpha = 1;
bgStreet.flipX = false;
bgStreet.flipY = false;
bgStreet.antialiasing = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,350],"Scale":[6,6],"Visible":true,"Graphic_File":"weebStreet","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"bgStreet","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bgStreet.loadGraphic(Paths.image('weebStreet', 'stages/school'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebTreesBack","Graphic_Library":"stages/school","Antialiasing":false,"Sprite_Name":"gfTrees","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var gfTrees_position:Array<Int> = [500,350];

var gfTrees = new FlxSprite(gfTrees_position[0], gfTrees_position[1]);
instance.add(gfTrees);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,350],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebTreesBack","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"gfTrees","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var gfTrees_scroll:Array<Int> = [1,1];
var gfTrees_scale:Array<Int> = [6,6];

gfTrees.scale.set(gfTrees_scale[0], gfTrees_scale[1]);
gfTrees.scrollFactor.set(gfTrees_scroll[0], gfTrees_scroll[1]);
gfTrees.visible = true;
gfTrees.angle = 0;
gfTrees.alpha = 1;
gfTrees.flipX = false;
gfTrees.flipY = false;
gfTrees.antialiasing = false;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,350],"Scale":[6,6],"Visible":true,"Graphic_File":"weebTreesBack","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"gfTrees","Flip_X":false,"Alpha":1,"Flip_Y":false} */

gfTrees.loadGraphic(Paths.image('weebTreesBack', 'stages/school'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[389,171],"Scale":[6,6],"Visible":true,"Graphic_File":"weebTrees","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Play_Anim":"idle","Sprite_Name":"bgTrees","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Anims_Prefix":[],"Flip_Y":false} */

var bgTrees_position:Array<Int> = [389,171];

var bgTrees = new FlxSprite(bgTrees_position[0], bgTrees_position[1]);
instance.add(bgTrees);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[389,171],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"weebTrees","Play_Anim":"idle","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"bgTrees","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[]} */

var bgTrees_scroll:Array<Int> = [1,1];
var bgTrees_scale:Array<Int> = [6,6];

bgTrees.scale.set(bgTrees_scale[0], bgTrees_scale[1]);
bgTrees.scrollFactor.set(bgTrees_scroll[0], bgTrees_scroll[1]);
bgTrees.visible = true;
bgTrees.angle = 0;
bgTrees.alpha = 1;
bgTrees.flipX = false;
bgTrees.flipY = false;
bgTrees.antialiasing = false;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[389,171],"Visible":true,"Scale":[6,6],"Graphic_File":"weebTrees","Angle":0,"Antialiasing":false,"Graphic_Library":"stages/school","Play_Anim":"idle","Scroll":[1,1],"Sprite_Name":"bgTrees","Flip_X":false,"Alpha":1,"Anims_Prefix":[],"Flip_Y":false} */

bgTrees.frames = Paths.getAtlas(Paths.image('weebTrees', 'stages/school', true));

var cur_prefixs:Array<Dynamic> = [];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
bgTrees.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
bgTrees.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[500,450],"Scale":[6,6],"Visible":true,"Graphic_File":"petals","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Play_Anim":"idle","Sprite_Name":"treeLeaves","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","PETALS ALL"]],"Flip_Y":false} */

var treeLeaves_position:Array<Int> = [500,450];

var treeLeaves = new FlxSprite(treeLeaves_position[0], treeLeaves_position[1]);
instance.add(treeLeaves);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[500,450],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"petals","Play_Anim":"idle","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"treeLeaves","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","PETALS ALL"]]} */

var treeLeaves_scroll:Array<Int> = [1,1];
var treeLeaves_scale:Array<Int> = [6,6];

treeLeaves.scale.set(treeLeaves_scale[0], treeLeaves_scale[1]);
treeLeaves.scrollFactor.set(treeLeaves_scroll[0], treeLeaves_scroll[1]);
treeLeaves.visible = true;
treeLeaves.angle = 0;
treeLeaves.alpha = 1;
treeLeaves.flipX = false;
treeLeaves.flipY = false;
treeLeaves.antialiasing = false;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[500,450],"Visible":true,"Scale":[6,6],"Graphic_File":"petals","Angle":0,"Antialiasing":false,"Graphic_Library":"stages/school","Play_Anim":"idle","Scroll":[1,1],"Sprite_Name":"treeLeaves","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","PETALS ALL"]],"Flip_Y":false} */

treeLeaves.frames = Paths.getAtlas(Paths.image('petals', 'stages/school', true));

var cur_prefixs:Array<Dynamic> = [["idle","PETALS ALL"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
treeLeaves.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
treeLeaves.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[502,351],"Scale":[6,6],"Visible":true,"Graphic_File":"bgFreaks","Angle":0,"Graphic_Library":"stages/school","Antialiasing":false,"Play_Anim":"idle","Sprite_Name":"bgGirls","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","BG girls group"]],"Flip_Y":false} */

var bgGirls_position:Array<Int> = [502,351];

var bgGirls = new FlxSprite(bgGirls_position[0], bgGirls_position[1]);
instance.add(bgGirls);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[502,351],"Visible":true,"Scale":[6,6],"Angle":0,"Graphic_File":"bgFreaks","Play_Anim":"idle","Graphic_Library":"stages/school","Antialiasing":false,"Scroll":[1,1],"Sprite_Name":"bgGirls","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","BG girls group"]]} */

var bgGirls_scroll:Array<Int> = [1,1];
var bgGirls_scale:Array<Int> = [6,6];

bgGirls.scale.set(bgGirls_scale[0], bgGirls_scale[1]);
bgGirls.scrollFactor.set(bgGirls_scroll[0], bgGirls_scroll[1]);
bgGirls.visible = true;
bgGirls.angle = 0;
bgGirls.alpha = 1;
bgGirls.flipX = false;
bgGirls.flipY = false;
bgGirls.antialiasing = false;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[502,351],"Visible":true,"Scale":[6,6],"Graphic_File":"bgFreaks","Angle":0,"Antialiasing":false,"Graphic_Library":"stages/school","Play_Anim":"idle","Scroll":[1,1],"Sprite_Name":"bgGirls","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","BG girls group"]],"Flip_Y":false} */

bgGirls.frames = Paths.getAtlas(Paths.image('bgFreaks', 'stages/school', true));

var cur_prefixs:Array<Dynamic> = [["idle","BG girls group"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
bgGirls.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
bgGirls.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//

if(!Std.isOfType(getState(), PlayState)){return;}

var shFilter:ShaderFilter = new ShaderFilter(new FlxCustomShader({fragmentsrc: Paths.shader("Pixel_Perfect")}));
FlxG.game.setFilters([shFilter]);
}