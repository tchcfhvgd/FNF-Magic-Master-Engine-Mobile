/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":8,"id":"initChar"},{"isPresset":true,"type":"Array","id":"camP_1","value":[250,-3200]},{"isPresset":true,"type":"Array","id":"camP_2","value":[1000,850]},{"isPresset":true,"type":"Float","id":"zoom","value":0.4}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('Sky','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('BackBuildings','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('BG','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('Flechas','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('Flechas','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('BGP','stages/street',true)});
temp.push({type:"ATLAS",instance:Paths.image('BANQUETA','stages/street',true)});
}

presset("initChar", 8);
presset("camP_1", [250,-3200]);
presset("camP_2", [1000,850]);
presset("zoom", 0.4);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1800,-1650],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"Sky","Antialiasing":true,"Graphic_Library":"stages/street","Sprite_Name":"sky","Scroll":[0.1,0.1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var sky_position:Array<Int> = [-1800,-1650];

var sky = new FlxSprite(sky_position[0], sky_position[1]);
instance.add(sky);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1800,-1650],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"Sky","Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"sky","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var sky_scroll:Array<Int> = [0.1,0.1];
var sky_scale:Array<Int> = [1,1];

sky.scale.set(sky_scale[0], sky_scale[1]);
sky.scrollFactor.set(sky_scroll[0], sky_scroll[1]);
sky.visible = true;
sky.angle = 0;
sky.alpha = 1;
sky.flipX = false;
sky.flipY = false;
sky.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1800,-1650],"Scale":[1,1],"Visible":true,"Graphic_File":"Sky","Angle":0,"Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"sky","Alpha":1,"Flip_X":false,"Flip_Y":false} */

sky.loadGraphic(Paths.image('Sky', 'stages/street'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1500,-600],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BackBuildings","Graphic_Library":"stages/street","Antialiasing":true,"Sprite_Name":"city","Scroll":[0.5,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var city_position:Array<Int> = [-1500,-600];

var city = new FlxSprite(city_position[0], city_position[1]);
instance.add(city);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1500,-600],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BackBuildings","Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.5,1],"Sprite_Name":"city","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var city_scroll:Array<Int> = [0.5,1];
var city_scale:Array<Int> = [1,1];

city.scale.set(city_scale[0], city_scale[1]);
city.scrollFactor.set(city_scroll[0], city_scroll[1]);
city.visible = true;
city.angle = 0;
city.alpha = 1;
city.flipX = false;
city.flipY = false;
city.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1500,-600],"Scale":[1,1],"Visible":true,"Graphic_File":"BackBuildings","Angle":0,"Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.5,1],"Sprite_Name":"city","Flip_X":false,"Alpha":1,"Flip_Y":false} */

city.loadGraphic(Paths.image('BackBuildings', 'stages/street'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1410,-700],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BG","Graphic_Library":"stages/street","Antialiasing":true,"Sprite_Name":"mall","Scroll":[0.8,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var mall_position:Array<Int> = [-1410,-700];

var mall = new FlxSprite(mall_position[0], mall_position[1]);
instance.add(mall);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1410,-700],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BG","Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"mall","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var mall_scroll:Array<Int> = [0.8,1];
var mall_scale:Array<Int> = [1,1];

mall.scale.set(mall_scale[0], mall_scale[1]);
mall.scrollFactor.set(mall_scroll[0], mall_scroll[1]);
mall.visible = true;
mall.angle = 0;
mall.alpha = 1;
mall.flipX = false;
mall.flipY = false;
mall.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1410,-700],"Scale":[1,1],"Visible":true,"Graphic_File":"BG","Angle":0,"Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"mall","Flip_X":false,"Alpha":1,"Flip_Y":false} */

mall.loadGraphic(Paths.image('BG', 'stages/street'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"arrow_4","Position":[220,-260]} */

var arrow_4_position:Array<Int> = [220,-260];

var arrow_4 = new FlxSprite(arrow_4_position[0], arrow_4_position[1]);
instance.add(arrow_4);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[220,-260],"Visible":true,"Scale":[1,1],"Angle":0,"Antialiasing":true,"Sprite_Name":"arrow_4","Scroll":[0.8,1],"Flip_X":true,"Alpha":1,"Flip_Y":false} */

var arrow_4_scroll:Array<Int> = [0.8,1];
var arrow_4_scale:Array<Int> = [1,1];

arrow_4.scale.set(arrow_4_scale[0], arrow_4_scale[1]);
arrow_4.scrollFactor.set(arrow_4_scroll[0], arrow_4_scroll[1]);
arrow_4.visible = true;
arrow_4.angle = 0;
arrow_4.alpha = 1;
arrow_4.flipX = true;
arrow_4.flipY = false;
arrow_4.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/street","Play_Anim":"flecha","Position":[220,-260],"Sprite_Name":"arrow_4","Anims_Prefix":[["flecha","2flecha"]],"Graphic_File":"Flechas"} */

arrow_4.frames = Paths.getAtlas(Paths.image('Flechas', 'stages/street', true));

var cur_prefixs:Array<Dynamic> = [["flecha","2flecha"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
arrow_4.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
arrow_4.animation.play('flecha');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Sprite_Name":"arrow_3","Position":[780,-260]} */

var arrow_3_position:Array<Int> = [780,-260];

var arrow_3 = new FlxSprite(arrow_3_position[0], arrow_3_position[1]);
instance.add(arrow_3);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[780,-260],"Visible":true,"Scale":[1,1],"Angle":0,"Antialiasing":true,"Sprite_Name":"arrow_3","Scroll":[0.8,1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var arrow_3_scroll:Array<Int> = [0.8,1];
var arrow_3_scale:Array<Int> = [1,1];

arrow_3.scale.set(arrow_3_scale[0], arrow_3_scale[1]);
arrow_3.scrollFactor.set(arrow_3_scroll[0], arrow_3_scroll[1]);
arrow_3.visible = true;
arrow_3.angle = 0;
arrow_3.alpha = 1;
arrow_3.flipX = false;
arrow_3.flipY = false;
arrow_3.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/street","Play_Anim":"flecha","Position":[780,-260],"Sprite_Name":"arrow_3","Anims_Prefix":[["flecha","2flecha"]],"Graphic_File":"Flechas"} */

arrow_3.frames = Paths.getAtlas(Paths.image('Flechas', 'stages/street', true));

var cur_prefixs:Array<Dynamic> = [["flecha","2flecha"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
arrow_3.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
arrow_3.animation.play('flecha');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[910,-70],"Scale":[1,1],"Visible":true,"Angle":0,"Graphic_File":"Flechas","Play_Anim":"flecha","Antialiasing":true,"Graphic_Library":"stages/street","Sprite_Name":"arrow_1","Scroll":[0.8,1],"Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["flecha","flecha"]]} */

var arrow_1_position:Array<Int> = [910,-70];

var arrow_1 = new FlxSprite(arrow_1_position[0], arrow_1_position[1]);
instance.add(arrow_1);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[910,-70],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"Flechas","Graphic_Library":"stages/street","Play_Anim":"flecha","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"arrow_1","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["flecha","flecha"]]} */

var arrow_1_scroll:Array<Int> = [0.8,1];
var arrow_1_scale:Array<Int> = [1,1];

arrow_1.scale.set(arrow_1_scale[0], arrow_1_scale[1]);
arrow_1.scrollFactor.set(arrow_1_scroll[0], arrow_1_scroll[1]);
arrow_1.visible = true;
arrow_1.angle = 0;
arrow_1.alpha = 1;
arrow_1.flipX = false;
arrow_1.flipY = false;
arrow_1.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[910,-70],"Visible":true,"Scale":[1,1],"Graphic_File":"Flechas","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/street","Play_Anim":"flecha","Scroll":[0.8,1],"Sprite_Name":"arrow_1","Alpha":1,"Flip_X":false,"Anims_Prefix":[["flecha","flecha"]],"Flip_Y":false} */

arrow_1.frames = Paths.getAtlas(Paths.image('Flechas', 'stages/street', true));

var cur_prefixs:Array<Dynamic> = [["flecha","flecha"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
arrow_1.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
arrow_1.animation.play('flecha');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[100,-70],"Visible":true,"Scale":[1,1],"Graphic_File":"Flechas","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/street","Play_Anim":"flecha","Sprite_Name":"arrow_2","Scroll":[0.8,1],"Flip_X":true,"Alpha":1,"Anims_Prefix":[["flecha","flecha"]],"Flip_Y":false} */

var arrow_2_position:Array<Int> = [100,-70];

var arrow_2 = new FlxSprite(arrow_2_position[0], arrow_2_position[1]);
instance.add(arrow_2);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[100,-70],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"Flechas","Play_Anim":"flecha","Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"arrow_2","Flip_X":true,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["flecha","flecha"]]} */

var arrow_2_scroll:Array<Int> = [0.8,1];
var arrow_2_scale:Array<Int> = [1,1];

arrow_2.scale.set(arrow_2_scale[0], arrow_2_scale[1]);
arrow_2.scrollFactor.set(arrow_2_scroll[0], arrow_2_scroll[1]);
arrow_2.visible = true;
arrow_2.angle = 0;
arrow_2.alpha = 1;
arrow_2.flipX = true;
arrow_2.flipY = false;
arrow_2.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[100,-70],"Scale":[1,1],"Visible":true,"Graphic_File":"Flechas","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/street","Play_Anim":"flecha","Scroll":[0.8,1],"Sprite_Name":"arrow_2","Alpha":1,"Flip_X":true,"Anims_Prefix":[["flecha","flecha"]],"Flip_Y":false} */

arrow_2.frames = Paths.getAtlas(Paths.image('Flechas', 'stages/street', true));

var cur_prefixs:Array<Dynamic> = [["flecha","flecha"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
arrow_2.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
arrow_2.animation.play('flecha');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1340,130],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BGP","Graphic_Library":"stages/street","Antialiasing":true,"Sprite_Name":"bar","Scroll":[0.8,1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bar_position:Array<Int> = [-1340,130];

var bar = new FlxSprite(bar_position[0], bar_position[1]);
instance.add(bar);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1340,130],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"BGP","Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"bar","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bar_scroll:Array<Int> = [0.8,1];
var bar_scale:Array<Int> = [1,1];

bar.scale.set(bar_scale[0], bar_scale[1]);
bar.scrollFactor.set(bar_scroll[0], bar_scroll[1]);
bar.visible = true;
bar.angle = 0;
bar.alpha = 1;
bar.flipX = false;
bar.flipY = false;
bar.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1340,130],"Scale":[1,1],"Visible":true,"Graphic_File":"BGP","Angle":0,"Graphic_Library":"stages/street","Antialiasing":true,"Scroll":[0.8,1],"Sprite_Name":"bar","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bar.loadGraphic(Paths.image('BGP', 'stages/street'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/street","Sprite_Name":"floor","Position":[-2000,100],"Graphic_File":"BANQUETA"} */

var floor_position:Array<Int> = [-2000,100];

var floor = new FlxSprite(floor_position[0], floor_position[1]);
instance.add(floor);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/street","Graphic_File":"BANQUETA","Position":[-2000,100],"Sprite_Name":"floor"} */

floor.loadGraphic(Paths.image('BANQUETA', 'stages/street'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}