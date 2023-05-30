/* ||===================================================|| */
/* || SCRIPTED STAGE - DON'T EXPORT IN THE STAGE EDITOR || */
/* ||===================================================|| */

/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"9","id":"initChar"},{"type":"Float","isPresset":true,"value":1.1,"id":"zoom"},{"type":"Array","isPresset":true,"value":[340,-3000],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[1070,630],"id":"camP_2"}] */

import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxG", "FlxG");
import("Paths", "Paths");
import("Math", "Math");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('tankSky','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankClouds','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankMountains','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankBuildings','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankRuins','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('smokeLeft','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('smokeRight','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankWatchtower','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankRolling','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tankGround','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank0','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank1','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank2','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank4','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank5','stages/war',true)});
temp.push({type:"ATLAS",instance:Paths.image('tank3','stages/war',true)});
}

presset("initChar", 9);
presset("zoom", 0.9);
presset("camP_1", [540,-3000]);
presset("camP_2", [970,530]);

var tankWatchTower:FlxSprite;
var tankRolling:FlxSprite;

var tank0:FlxSprite;
var tank1:FlxSprite;
var tank2:FlxSprite;
var tank3:FlxSprite;
var tank4:FlxSprite;
var tank5:FlxSprite;

var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-250,-250],"Visible":true,"Scale":[2,3],"Angle":0,"Graphic_File":"tankSky","Graphic_Library":"stages/war","Antialiasing":true,"Sprite_Name":"tankBG","Scroll":[0,0],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tankBG_position:Array<Int> = [-250,-250];

var tankBG = new FlxSprite(tankBG_position[0], tankBG_position[1]);
instance.add(tankBG);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-250,-250],"Visible":true,"Scale":[2,3],"Angle":0,"Graphic_File":"tankSky","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0,0],"Sprite_Name":"tankBG","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tankBG_scroll:Array<Int> = [0,0];
var tankBG_scale:Array<Int> = [2,3];

tankBG.scale.set(tankBG_scale[0], tankBG_scale[1]);
tankBG.scrollFactor.set(tankBG_scroll[0], tankBG_scroll[1]);
tankBG.visible = true;
tankBG.angle = 0;
tankBG.alpha = 1;
tankBG.flipX = false;
tankBG.flipY = false;
tankBG.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-250,-250],"Scale":[2,3],"Visible":true,"Graphic_File":"tankSky","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0,0],"Sprite_Name":"tankBG","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tankBG.loadGraphic(Paths.image('tankSky', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-500,150],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankClouds","Graphic_Library":"stages/war","Antialiasing":true,"Sprite_Name":"tankClouds","Scroll":[0.1,0.1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tankClouds_position:Array<Int> = [-500,150];

var tankClouds = new FlxSprite(tankClouds_position[0], tankClouds_position[1]);
instance.add(tankClouds);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-500,150],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankClouds","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"tankClouds","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tankClouds_scroll:Array<Int> = [0.1,0.1];
var tankClouds_scale:Array<Int> = [1,1];

tankClouds.scale.set(tankClouds_scale[0], tankClouds_scale[1]);
tankClouds.scrollFactor.set(tankClouds_scroll[0], tankClouds_scroll[1]);
tankClouds.visible = true;
tankClouds.angle = 0;
tankClouds.alpha = 1;
tankClouds.flipX = false;
tankClouds.flipY = false;
tankClouds.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-500,150],"Scale":[1,1],"Visible":true,"Graphic_File":"tankClouds","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"tankClouds","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tankClouds.loadGraphic(Paths.image('tankClouds', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-90,100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankMountains","Graphic_Library":"stages/war","Antialiasing":true,"Sprite_Name":"tankMountains","Scroll":[0.2,0.2],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tankMountains_position:Array<Int> = [-90,100];

var tankMountains = new FlxSprite(tankMountains_position[0], tankMountains_position[1]);
instance.add(tankMountains);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-90,100],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankMountains","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.2,0.2],"Sprite_Name":"tankMountains","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tankMountains_scroll:Array<Int> = [0.2,0.2];
var tankMountains_scale:Array<Int> = [1,1];

tankMountains.scale.set(tankMountains_scale[0], tankMountains_scale[1]);
tankMountains.scrollFactor.set(tankMountains_scroll[0], tankMountains_scroll[1]);
tankMountains.visible = true;
tankMountains.angle = 0;
tankMountains.alpha = 1;
tankMountains.flipX = false;
tankMountains.flipY = false;
tankMountains.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-90,100],"Scale":[1,1],"Visible":true,"Graphic_File":"tankMountains","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.2,0.2],"Sprite_Name":"tankMountains","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tankMountains.loadGraphic(Paths.image('tankMountains', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-200,130],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankBuildings","Graphic_Library":"stages/war","Antialiasing":true,"Sprite_Name":"tankBuildings","Scroll":[0.3,0.3],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tankBuildings_position:Array<Int> = [-200,130];

var tankBuildings = new FlxSprite(tankBuildings_position[0], tankBuildings_position[1]);
instance.add(tankBuildings);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-200,130],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankBuildings","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"tankBuildings","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tankBuildings_scroll:Array<Int> = [0.3,0.3];
var tankBuildings_scale:Array<Int> = [1,1];

tankBuildings.scale.set(tankBuildings_scale[0], tankBuildings_scale[1]);
tankBuildings.scrollFactor.set(tankBuildings_scroll[0], tankBuildings_scroll[1]);
tankBuildings.visible = true;
tankBuildings.angle = 0;
tankBuildings.alpha = 1;
tankBuildings.flipX = false;
tankBuildings.flipY = false;
tankBuildings.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-200,130],"Scale":[1,1],"Visible":true,"Graphic_File":"tankBuildings","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"tankBuildings","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tankBuildings.loadGraphic(Paths.image('tankBuildings', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-180,150],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankRuins","Graphic_Library":"stages/war","Antialiasing":true,"Sprite_Name":"tankRuins","Scroll":[0.35,0.35],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tankRuins_position:Array<Int> = [-180,150];

var tankRuins = new FlxSprite(tankRuins_position[0], tankRuins_position[1]);
instance.add(tankRuins);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-180,150],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankRuins","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.35,0.35],"Sprite_Name":"tankRuins","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tankRuins_scroll:Array<Int> = [0.35,0.35];
var tankRuins_scale:Array<Int> = [1,1];

tankRuins.scale.set(tankRuins_scale[0], tankRuins_scale[1]);
tankRuins.scrollFactor.set(tankRuins_scroll[0], tankRuins_scroll[1]);
tankRuins.visible = true;
tankRuins.angle = 0;
tankRuins.alpha = 1;
tankRuins.flipX = false;
tankRuins.flipY = false;
tankRuins.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-180,150],"Scale":[1,1],"Visible":true,"Graphic_File":"tankRuins","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.35,0.35],"Sprite_Name":"tankRuins","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tankRuins.loadGraphic(Paths.image('tankRuins', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[0,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"smokeLeft","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"smokeLeft","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","SmokeBlurLeft"]]} */

var smokeLeft_position:Array<Int> = [0,0];

var smokeLeft = new FlxSprite(smokeLeft_position[0], smokeLeft_position[1]);
instance.add(smokeLeft);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[0,0],"Scale":[1,1],"Visible":true,"Graphic_File":"smokeLeft","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[0.4,0.4],"Sprite_Name":"smokeLeft","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","SmokeBlurLeft"]],"Flip_Y":false} */

smokeLeft.frames = Paths.getAtlas(Paths.image('smokeLeft', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","SmokeBlurLeft"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
smokeLeft.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
smokeLeft.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[0,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"smokeLeft","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"smokeLeft","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","SmokeBlurLeft"]]} */

var smokeLeft_scroll:Array<Int> = [0.4,0.4];
var smokeLeft_scale:Array<Int> = [1,1];

smokeLeft.scale.set(smokeLeft_scale[0], smokeLeft_scale[1]);
smokeLeft.scrollFactor.set(smokeLeft_scroll[0], smokeLeft_scroll[1]);
smokeLeft.visible = true;
smokeLeft.angle = 0;
smokeLeft.alpha = 1;
smokeLeft.flipX = false;
smokeLeft.flipY = false;
smokeLeft.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[900,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"smokeRight","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"smokeRight","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","SmokeRight"]]} */

var smokeRight_position:Array<Int> = [900,0];

var smokeRight = new FlxSprite(smokeRight_position[0], smokeRight_position[1]);
instance.add(smokeRight);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[900,0],"Scale":[1,1],"Visible":true,"Graphic_File":"smokeRight","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[0.4,0.4],"Sprite_Name":"smokeRight","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","SmokeRight"]],"Flip_Y":false} */

smokeRight.frames = Paths.getAtlas(Paths.image('smokeRight', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","SmokeRight"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
smokeRight.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
smokeRight.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[900,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"smokeRight","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"smokeRight","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","SmokeRight"]]} */

var smokeRight_scroll:Array<Int> = [0.4,0.4];
var smokeRight_scale:Array<Int> = [1,1];

smokeRight.scale.set(smokeRight_scale[0], smokeRight_scale[1]);
smokeRight.scrollFactor.set(smokeRight_scroll[0], smokeRight_scroll[1]);
smokeRight.visible = true;
smokeRight.angle = 0;
smokeRight.alpha = 1;
smokeRight.flipX = false;
smokeRight.flipY = false;
smokeRight.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[100,50],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankWatchtower","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"tankWatchTower","Scroll":[0.5,0.5],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","watchtower gradient color",30,false]]} */

var tankWatchTower_position:Array<Int> = [100,50];

tankWatchTower = new FlxSprite(tankWatchTower_position[0], tankWatchTower_position[1]);
instance.add(tankWatchTower);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[100,50],"Scale":[1,1],"Visible":true,"Graphic_File":"tankWatchtower","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[0.5,0.5],"Sprite_Name":"tankWatchTower","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","watchtower gradient color",30,false]],"Flip_Y":false} */

tankWatchTower.frames = Paths.getAtlas(Paths.image('tankWatchtower', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","watchtower gradient color",30,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tankWatchTower.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tankWatchTower.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[100,50],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankWatchtower","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.5,0.5],"Sprite_Name":"tankWatchTower","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","watchtower gradient color",30,false]]} */

var tankWatchTower_scroll:Array<Int> = [0.5,0.5];
var tankWatchTower_scale:Array<Int> = [1,1];

tankWatchTower.scale.set(tankWatchTower_scale[0], tankWatchTower_scale[1]);
tankWatchTower.scrollFactor.set(tankWatchTower_scroll[0], tankWatchTower_scroll[1]);
tankWatchTower.visible = true;
tankWatchTower.angle = 0;
tankWatchTower.alpha = 1;
tankWatchTower.flipX = false;
tankWatchTower.flipY = false;
tankWatchTower.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[0,300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankRolling","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"tankRolling","Scroll":[0.5,0.5],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","BG tank w lighting instance 1"]]} */

var tankRolling_position:Array<Int> = [300, 300];

tankRolling = new FlxSprite(tankRolling_position[0], tankRolling_position[1]);
instance.add(tankRolling);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[0,300],"Scale":[1,1],"Visible":true,"Graphic_File":"tankRolling","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[0.5,0.5],"Sprite_Name":"tankRolling","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","BG tank w lighting instance 1"]],"Flip_Y":false} */

tankRolling.frames = Paths.getAtlas(Paths.image('tankRolling', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","BG tank w lighting instance 1"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tankRolling.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tankRolling.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[0,300],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tankRolling","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[0.5,0.5],"Sprite_Name":"tankRolling","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","BG tank w lighting instance 1"]]} */

var tankRolling_scroll:Array<Int> = [0.5,0.5];
var tankRolling_scale:Array<Int> = [1,1];

tankRolling.scale.set(tankRolling_scale[0], tankRolling_scale[1]);
tankRolling.scrollFactor.set(tankRolling_scroll[0], tankRolling_scroll[1]);
tankRolling.visible = true;
tankRolling.angle = 0;
tankRolling.alpha = 1;
tankRolling.flipX = false;
tankRolling.flipY = false;
tankRolling.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/war","Sprite_Name":"tankGround","Position":[-250,-50],"Graphic_File":"tankGround"} */

var tankGround_position:Array<Int> = [-250,-50];

var tankGround = new FlxSprite(tankGround_position[0], tankGround_position[1]);
instance.add(tankGround);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/war","Graphic_File":"tankGround","Position":[-250,-50],"Sprite_Name":"tankGround"} */

tankGround.loadGraphic(Paths.image('tankGround', 'stages/war'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-500,700],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank0","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"tank0","Scroll":[1.7,1.5],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank0_position:Array<Int> = [-500,700];

tank0 = new FlxSprite(tank0_position[0], tank0_position[1]);
instance.add(tank0);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-500,700],"Scale":[1,1],"Visible":true,"Graphic_File":"tank0","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[1.7,1.5],"Sprite_Name":"tank0","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

tank0.frames = Paths.getAtlas(Paths.image('tank0', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","fg",24,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank0.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank0.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-500,700],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank0","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[1.7,1.5],"Sprite_Name":"tank0","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank0_scroll:Array<Int> = [1.7,1.5];
var tank0_scale:Array<Int> = [1,1];

tank0.scale.set(tank0_scale[0], tank0_scale[1]);
tank0.scrollFactor.set(tank0_scroll[0], tank0_scroll[1]);
tank0.visible = true;
tank0.angle = 0;
tank0.alpha = 1;
tank0.flipX = false;
tank0.flipY = false;
tank0.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-300,640],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank1","Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Sprite_Name":"tank1","Scroll":[2,0.2],"Alpha":1,"Flip_X":false,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank1_position:Array<Int> = [-300,740];

tank1 = new FlxSprite(tank1_position[0], tank1_position[1]);
instance.add(tank1);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-300,640],"Scale":[1,1],"Visible":true,"Graphic_File":"tank1","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[2,0.2],"Sprite_Name":"tank1","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

tank1.frames = Paths.getAtlas(Paths.image('tank1', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","fg",24,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank1.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank1.animation.play('idle');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-300,640],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank1","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[2,0.2],"Sprite_Name":"tank1","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank1_scroll:Array<Int> = [2,0.2];
var tank1_scale:Array<Int> = [1,1];

tank1.scale.set(tank1_scale[0], tank1_scale[1]);
tank1.scrollFactor.set(tank1_scroll[0], tank1_scroll[1]);
tank1.visible = true;
tank1.angle = 0;
tank1.alpha = 1;
tank1.flipX = false;
tank1.flipY = false;
tank1.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[450,940],"Scale":[1,1],"Visible":true,"Graphic_File":"tank2","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Play_Anim":"idle","Sprite_Name":"tank2","Scroll":[1.5,1.5],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","foreground",24,"tank"]],"Flip_Y":false} */

var tank2_position:Array<Int> = [450,940];

tank2 = new FlxSprite(tank2_position[0], tank2_position[1]);
instance.add(tank2);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[450,940],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank2","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[1.5,1.5],"Sprite_Name":"tank2","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","foreground",24,"tank"]]} */

var tank2_scroll:Array<Int> = [1.5,1.5];
var tank2_scale:Array<Int> = [1,1];

tank2.scale.set(tank2_scale[0], tank2_scale[1]);
tank2.scrollFactor.set(tank2_scroll[0], tank2_scroll[1]);
tank2.visible = true;
tank2.angle = 0;
tank2.alpha = 1;
tank2.flipX = false;
tank2.flipY = false;
tank2.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[450,940],"Visible":true,"Scale":[1,1],"Graphic_File":"tank2","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[1.5,1.5],"Sprite_Name":"tank2","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","foreground",24,"tank"]],"Flip_Y":false} */

tank2.frames = Paths.getAtlas(Paths.image('tank2', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","foreground",24,"tank"]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank2.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank2.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[1300,900],"Scale":[1,1],"Visible":true,"Graphic_File":"tank4","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Play_Anim":"idle","Sprite_Name":"tank4","Scroll":[1.5,1.5],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

var tank4_position:Array<Int> = [1300,900];

tank4 = new FlxSprite(tank4_position[0], tank4_position[1]);
instance.add(tank4);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[1300,900],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank4","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[1.5,1.5],"Sprite_Name":"tank4","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank4_scroll:Array<Int> = [1.5,1.5];
var tank4_scale:Array<Int> = [1,1];

tank4.scale.set(tank4_scale[0], tank4_scale[1]);
tank4.scrollFactor.set(tank4_scroll[0], tank4_scroll[1]);
tank4.visible = true;
tank4.angle = 0;
tank4.alpha = 1;
tank4.flipX = false;
tank4.flipY = false;
tank4.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[1300,900],"Visible":true,"Scale":[1,1],"Graphic_File":"tank4","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[1.5,1.5],"Sprite_Name":"tank4","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

tank4.frames = Paths.getAtlas(Paths.image('tank4', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","fg",24,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank4.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank4.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[1620,700],"Scale":[1,1],"Visible":true,"Graphic_File":"tank5","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Play_Anim":"idle","Sprite_Name":"tank5","Scroll":[1.5,1.5],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

var tank5_position:Array<Int> = [1620,700];

tank5 = new FlxSprite(tank5_position[0], tank5_position[1]);
instance.add(tank5);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[1620,700],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank5","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[1.5,1.5],"Sprite_Name":"tank5","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank5_scroll:Array<Int> = [1.5,1.5];
var tank5_scale:Array<Int> = [1,1];

tank5.scale.set(tank5_scale[0], tank5_scale[1]);
tank5.scrollFactor.set(tank5_scroll[0], tank5_scroll[1]);
tank5.visible = true;
tank5.angle = 0;
tank5.alpha = 1;
tank5.flipX = false;
tank5.flipY = false;
tank5.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[1620,700],"Visible":true,"Scale":[1,1],"Graphic_File":"tank5","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[1.5,1.5],"Sprite_Name":"tank5","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

tank5.frames = Paths.getAtlas(Paths.image('tank5', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","fg",24,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank5.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank5.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[1000,640],"Scale":[1,1],"Visible":true,"Graphic_File":"tank3","Angle":0,"Graphic_Library":"stages/war","Antialiasing":true,"Play_Anim":"idle","Sprite_Name":"tank3","Scroll":[2,0.3],"Alpha":1,"Flip_X":false,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

var tank3_position:Array<Int> = [1000,740];

tank3 = new FlxSprite(tank3_position[0], tank3_position[1]);
instance.add(tank3);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[1000,640],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"tank3","Play_Anim":"idle","Graphic_Library":"stages/war","Antialiasing":true,"Scroll":[2,0.3],"Sprite_Name":"tank3","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["idle","fg",24,false]]} */

var tank3_scroll:Array<Int> = [2,0.3];
var tank3_scale:Array<Int> = [1,1];

tank3.scale.set(tank3_scale[0], tank3_scale[1]);
tank3.scrollFactor.set(tank3_scroll[0], tank3_scroll[1]);
tank3.visible = true;
tank3.angle = 0;
tank3.alpha = 1;
tank3.flipX = false;
tank3.flipY = false;
tank3.antialiasing = true;
//-[Advanced_Properties]-//
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[1000,640],"Visible":true,"Scale":[1,1],"Graphic_File":"tank3","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/war","Play_Anim":"idle","Scroll":[2,0.3],"Sprite_Name":"tank3","Flip_X":false,"Alpha":1,"Anims_Prefix":[["idle","fg",24,false]],"Flip_Y":false} */

tank3.frames = Paths.getAtlas(Paths.image('tank3', 'stages/war', true));

var cur_prefixs:Array<Dynamic> = [["idle","fg",24,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
tank3.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
tank3.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//

pushGlobal();
}

function beatHit(curBeat:Int):Void {
    tankWatchTower.animation.play('idle');
    tank0.animation.play('idle');
    tank1.animation.play('idle');
    tank2.animation.play('idle');
    tank3.animation.play('idle');
    tank4.animation.play('idle');
    tank5.animation.play('idle');
}

function update(elapsed) {
    tankAngle += elapsed * tankSpeed;
    tankRolling.angle = tankAngle - 90 + 15;
    tankRolling.x = 400 + (1000 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180)));
    tankRolling.y = 700 + (500 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180)));
}