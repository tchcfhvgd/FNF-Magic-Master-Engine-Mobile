/* "Packages": {"Paths":"Paths","Type":"Type","FlxSprite":"flixel.FlxSprite","FlxTypedGroup":"flixel.group.FlxTypedGroup"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"6","id":"initChar"},{"type":"Array","isPresset":true,"value":[230,330],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[1130,700],"id":"camP_2"},{"id":"zoom","value":0.9,"isPresset":true,"type":"Float"}] */

import("Type", "Type");
import("Paths", "Paths");
import("flixel.group.FlxTypedGroup", "FlxTypedGroup");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 6);
presset("camP_1", [230,330]);
presset("camP_2", [1130,700]);
presset("zoom", 0.9);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-120,-50],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"limoSunset","Graphic_Library":"stages/limo","Sprite_Name":"sunset","Scroll":[0.1,0.1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var sunset_position:Array<Int> = [-120,-50];

var sunset = new FlxSprite(sunset_position[0], sunset_position[1]);
instance.add(sunset);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-120,-50],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"limoSunset","Graphic_Library":"stages/limo","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"sunset","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var sunset_scroll:Array<Int> = [0.1,0.1];
var sunset_scale:Array<Int> = [1,1];

sunset.scale.set(sunset_scale[0], sunset_scale[1]);
sunset.scrollFactor.set(sunset_scroll[0], sunset_scroll[1]);
sunset.visible = true;
sunset.angle = 0;
sunset.alpha = 1;
sunset.flipX = false;
sunset.flipY = false;
sunset.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-120,-50],"Scale":[1,1],"Visible":true,"Graphic_File":"limoSunset","Angle":0,"Graphic_Library":"stages/limo","Sprite_Name":"sunset","Scroll":[0.1,0.1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

sunset.loadGraphic(Paths.image('limoSunset', 'stages/limo'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-500,220],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"metalPole","Graphic_Library":"stages/limo","Sprite_Name":"limo","Scroll":[0.4,0.4],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var limo_position:Array<Int> = [-500,220];

var limo = new FlxSprite(limo_position[0], limo_position[1]);
instance.add(limo);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-500,220],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"metalPole","Graphic_Library":"stages/limo","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"limo","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var limo_scroll:Array<Int> = [0.4,0.4];
var limo_scale:Array<Int> = [1,1];

limo.scale.set(limo_scale[0], limo_scale[1]);
limo.scrollFactor.set(limo_scroll[0], limo_scroll[1]);
limo.visible = true;
limo.angle = 0;
limo.alpha = 1;
limo.flipX = false;
limo.flipY = false;
limo.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-500,220],"Scale":[1,1],"Visible":true,"Graphic_File":"metalPole","Angle":0,"Graphic_Library":"stages/limo","Sprite_Name":"limo","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

limo.loadGraphic(Paths.image('metalPole', 'stages/limo'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-150,480],"Scale":[1,1],"Visible":true,"Graphic_File":"bgLimo","Angle":0,"Play_Anim":"idle","Graphic_Library":"stages/limo","Sprite_Name":"bglimo","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","background limo pink"]],"Flip_Y":false} */

var bglimo_position:Array<Int> = [-150,480];

var bglimo = new FlxSprite(bglimo_position[0], bglimo_position[1]);
instance.add(bglimo);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-150,480],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"bgLimo","Graphic_Library":"stages/limo","Play_Anim":"idle","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"bglimo","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","background limo pink"]]} */

var bglimo_scroll:Array<Int> = [0.4,0.4];
var bglimo_scale:Array<Int> = [1,1];

bglimo.scale.set(bglimo_scale[0], bglimo_scale[1]);
bglimo.scrollFactor.set(bglimo_scroll[0], bglimo_scroll[1]);
bglimo.visible = true;
bglimo.angle = 0;
bglimo.alpha = 1;
bglimo.flipX = false;
bglimo.flipY = false;
bglimo.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-150,480],"Visible":true,"Scale":[1,1],"Graphic_File":"bgLimo","Angle":0,"Graphic_Library":"stages/limo","Play_Anim":"idle","Scroll":[0.4,0.4],"Sprite_Name":"bglimo","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","background limo pink"]],"Flip_Y":false} */

bglimo.frames = Paths.getAtlas(Paths.image('bgLimo', 'stages/limo', true));

var cur_prefixs:Array<Dynamic> = [["idle","background limo pink"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
bglimo.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
bglimo.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Dancers_Group>-//
/* "Packages": {"Paths":"Paths","Type":"Type","FlxTypedGroup":"flixel.group.FlxTypedGroup","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"dancers","Position":[150,100]} */

var dancers_position:Array<Int> = [150,100];

var dancers:FlxTypedGroup<FlxSprite> = Type.createInstance(FlxTypedGroup, []);

for(i in 0...5){
var dancer:FlxSprite = new FlxSprite(dancers_position[0] + (370 * i), dancers_position[1]);
dancer.frames = Paths.getAtlas(Paths.image("limoDancer", "stages/limo", true));
dancer.scrollFactor.set(0.4, 0.4);
dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
dancer.animation.play('danceLeft');
dancers.add(dancer);
}
instance.add(dancers);
//->Dancers_Group<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-700,180],"Visible":true,"Scale":[1,1],"Graphic_File":"coldHeartKiller","Angle":0,"Graphic_Library":"stages/limo","Sprite_Name":"limolight","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var limolight_position:Array<Int> = [-700,180];

var limolight = new FlxSprite(limolight_position[0], limolight_position[1]);
instance.add(limolight);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-700,180],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"coldHeartKiller","Graphic_Library":"stages/limo","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"limolight","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var limolight_scroll:Array<Int> = [0.4,0.4];
var limolight_scale:Array<Int> = [1,1];

limolight.scale.set(limolight_scale[0], limolight_scale[1]);
limolight.scrollFactor.set(limolight_scroll[0], limolight_scroll[1]);
limolight.visible = true;
limolight.angle = 0;
limolight.alpha = 1;
limolight.flipX = false;
limolight.flipY = false;
limolight.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-700,180],"Scale":[1,1],"Visible":true,"Graphic_File":"coldHeartKiller","Angle":0,"Graphic_Library":"stages/limo","Sprite_Name":"limolight","Scroll":[0.4,0.4],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

limolight.loadGraphic(Paths.image('coldHeartKiller', 'stages/limo'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[0,0],"Visible":false,"Scale":[1,1],"Angle":0,"Sprite_Name":"placeholder","Scroll":[1,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var placeholder_position:Array<Int> = [0,0];

var placeholder = new FlxSprite(placeholder_position[0], placeholder_position[1]);
instance.add(placeholder);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[0,0],"Visible":false,"Scale":[1,1],"Angle":0,"Antialiasing":true,"Sprite_Name":"placeholder","Scroll":[1,1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var placeholder_scroll:Array<Int> = [1,1];
var placeholder_scale:Array<Int> = [1,1];

placeholder.scale.set(placeholder_scale[0], placeholder_scale[1]);
placeholder.scrollFactor.set(placeholder_scroll[0], placeholder_scroll[1]);
placeholder.visible = false;
placeholder.angle = 0;
placeholder.alpha = 1;
placeholder.flipX = false;
placeholder.flipY = false;
placeholder.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/limo","Play_Anim":"idle","Sprite_Name":"limo_floor","Position":[-120,550],"Anims_Prefix":[["idle","Limo stage"]],"Graphic_File":"limoDrive"} */

var limo_floor_position:Array<Int> = [-120,550];

var limo_floor = new FlxSprite(limo_floor_position[0], limo_floor_position[1]);
instance.add(limo_floor);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/limo","Play_Anim":"idle","Position":[-120,550],"Sprite_Name":"limo_floor","Anims_Prefix":[["idle","Limo stage"]],"Graphic_File":"limoDrive"} */

limo_floor.frames = Paths.getAtlas(Paths.image('limoDrive', 'stages/limo', true));

var cur_prefixs:Array<Dynamic> = [["idle","Limo stage"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
limo_floor.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
limo_floor.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/limo","Sprite_Name":"fastcar","Position":[-2000,500],"Graphic_File":"fastCarLol"} */

var fastcar_position:Array<Int> = [-2000,500];

var fastcar = new FlxSprite(fastcar_position[0], fastcar_position[1]);
instance.add(fastcar);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/limo","Graphic_File":"fastCarLol","Position":[-2000,500],"Sprite_Name":"fastcar"} */

fastcar.loadGraphic(Paths.image('fastCarLol', 'stages/limo'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}