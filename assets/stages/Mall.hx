/* ||===================================================|| */
/* || SCRIPTED STAGE - DON'T EXPORT IN THE STAGE EDITOR || */
/* ||===================================================|| */

/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"isPresset":true,"type":"Int","id":"initChar","value":"5"},{"type":"Float","isPresset":true,"value":0.8,"id":"zoom"},{"type":"Array","isPresset":true,"value":[-15,-290],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[1340,490],"id":"camP_2"}] */

import("flixel.system.FlxSound", "FlxSound");
import("flixel.FlxSprite", "FlxSprite");
import("PreSettings", "PreSettings");
import("Character", "Character");
import("flixel.FlxG", "FlxG");
import("Paths", "Paths");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('bgWalls','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('upperBop','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('bgEscalator','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('christmasTree','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('bottomBop','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('fgSnow','stages/mall',true)});
temp.push({type:"ATLAS",instance:Paths.image('santa','stages/mall',true)});
temp.push({type:"SOUND",instance:Paths.sound('Lights_Shut_off','stages/mall',true)});
}

presset("initChar", 5);
presset("zoom", 0.8);
presset("camP_1", [-15,-290]);
presset("camP_2", [1340,490]);

var upperBoopers:FlxSprite;
var bottomBopers:FlxSprite;
var santa:FlxSprite;

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1300,-500],"Visible":true,"Scale":[1,1],"Graphic_File":"bgWalls","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/mall","Sprite_Name":"bg","Scroll":[0.2,0.2],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bg_position:Array<Int> = [-1300,-500];

var bg = new FlxSprite(bg_position[0], bg_position[1]);
instance.add(bg);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1300,-500],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"bgWalls","Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.2,0.2],"Sprite_Name":"bg","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bg_scroll:Array<Int> = [0.2,0.2];
var bg_scale:Array<Int> = [1,1];

bg.scale.set(bg_scale[0], bg_scale[1]);
bg.scrollFactor.set(bg_scroll[0], bg_scroll[1]);
bg.visible = true;
bg.angle = 0;
bg.alpha = 1;
bg.flipX = false;
bg.flipY = false;
bg.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1300,-500],"Scale":[1,1],"Visible":true,"Graphic_File":"bgWalls","Angle":0,"Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.2,0.2],"Sprite_Name":"bg","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bg.loadGraphic(Paths.image('bgWalls', 'stages/mall'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-330,0],"Scale":[1,1],"Visible":true,"Angle":0,"Graphic_File":"upperBop","Play_Anim":"beat","Graphic_Library":"stages/mall","Antialiasing":true,"Sprite_Name":"upperBoopers","Scroll":[0.33,0.33],"Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["beat","Upper Crowd Bob",30,false]]} */

var upperBoopers_position:Array<Int> = [-330,0];

upperBoopers = new FlxSprite(upperBoopers_position[0], upperBoopers_position[1]);
instance.add(upperBoopers);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-330,0],"Visible":true,"Scale":[1,1],"Graphic_File":"upperBop","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/mall","Play_Anim":"beat","Scroll":[0.33,0.33],"Sprite_Name":"upperBoopers","Alpha":1,"Flip_X":false,"Anims_Prefix":[["beat","Upper Crowd Bob",30,false]],"Flip_Y":false} */

upperBoopers.frames = Paths.getAtlas(Paths.image('upperBop', 'stages/mall', true));

var cur_prefixs:Array<Dynamic> = [["beat","Upper Crowd Bob",30,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
upperBoopers.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
upperBoopers.animation.play('beat');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-330,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"upperBop","Graphic_Library":"stages/mall","Play_Anim":"beat","Antialiasing":true,"Scroll":[0.33,0.33],"Sprite_Name":"upperBoopers","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["beat","Upper Crowd Bob",30,false]]} */

var upperBoopers_scroll:Array<Int> = [0.33,0.33];
var upperBoopers_scale:Array<Int> = [1,1];

upperBoopers.scale.set(upperBoopers_scale[0], upperBoopers_scale[1]);
upperBoopers.scrollFactor.set(upperBoopers_scroll[0], upperBoopers_scroll[1]);
upperBoopers.visible = true;
upperBoopers.angle = 0;
upperBoopers.alpha = 1;
upperBoopers.flipX = false;
upperBoopers.flipY = false;
upperBoopers.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-1350,-550],"Visible":true,"Scale":[1,1],"Graphic_File":"bgEscalator","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/mall","Sprite_Name":"bgEscalator","Scroll":[0.3,0.3],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var bgEscalator_position:Array<Int> = [-1350,-550];

var bgEscalator = new FlxSprite(bgEscalator_position[0], bgEscalator_position[1]);
instance.add(bgEscalator);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-1350,-550],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"bgEscalator","Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"bgEscalator","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bgEscalator_scroll:Array<Int> = [0.3,0.3];
var bgEscalator_scale:Array<Int> = [1,1];

bgEscalator.scale.set(bgEscalator_scale[0], bgEscalator_scale[1]);
bgEscalator.scrollFactor.set(bgEscalator_scroll[0], bgEscalator_scroll[1]);
bgEscalator.visible = true;
bgEscalator.angle = 0;
bgEscalator.alpha = 1;
bgEscalator.flipX = false;
bgEscalator.flipY = false;
bgEscalator.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-1350,-550],"Scale":[1,1],"Visible":true,"Graphic_File":"bgEscalator","Angle":0,"Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"bgEscalator","Flip_X":false,"Alpha":1,"Flip_Y":false} */

bgEscalator.loadGraphic(Paths.image('bgEscalator', 'stages/mall'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[400,-250],"Visible":true,"Scale":[1,1],"Graphic_File":"christmasTree","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/mall","Sprite_Name":"tree","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

var tree_position:Array<Int> = [400,-250];

var tree = new FlxSprite(tree_position[0], tree_position[1]);
instance.add(tree);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[400,-250],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"christmasTree","Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"tree","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tree_scroll:Array<Int> = [0.4,0.4];
var tree_scale:Array<Int> = [1,1];

tree.scale.set(tree_scale[0], tree_scale[1]);
tree.scrollFactor.set(tree_scroll[0], tree_scroll[1]);
tree.visible = true;
tree.angle = 0;
tree.alpha = 1;
tree.flipX = false;
tree.flipY = false;
tree.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[400,-250],"Scale":[1,1],"Visible":true,"Graphic_File":"christmasTree","Angle":0,"Graphic_Library":"stages/mall","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"tree","Flip_X":false,"Alpha":1,"Flip_Y":false} */

tree.loadGraphic(Paths.image('christmasTree', 'stages/mall'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-470,140],"Scale":[1,1],"Visible":true,"Angle":0,"Graphic_File":"bottomBop","Play_Anim":"beat","Graphic_Library":"stages/mall","Antialiasing":true,"Sprite_Name":"bottomBopers","Scroll":[0.9,0.9],"Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["beat","Bottom Level Boppers Idle",30,false]]} */

var bottomBopers_position:Array<Int> = [-470,140];

bottomBopers = new FlxSprite(bottomBopers_position[0], bottomBopers_position[1]);
instance.add(bottomBopers);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[-470,140],"Visible":true,"Scale":[1,1],"Graphic_File":"bottomBop","Angle":0,"Antialiasing":true,"Graphic_Library":"stages/mall","Play_Anim":"beat","Scroll":[0.9,0.9],"Sprite_Name":"bottomBopers","Alpha":1,"Flip_X":false,"Anims_Prefix":[["beat","Bottom Level Boppers Idle",30,false]],"Flip_Y":false} */

bottomBopers.frames = Paths.getAtlas(Paths.image('bottomBop', 'stages/mall', true));

var cur_prefixs:Array<Dynamic> = [["beat","Bottom Level Boppers Idle",30,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
bottomBopers.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
bottomBopers.animation.play('beat');
//-[Animated_Graphic]-//
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-470,140],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"bottomBop","Graphic_Library":"stages/mall","Play_Anim":"beat","Antialiasing":true,"Scroll":[0.9,0.9],"Sprite_Name":"bottomBopers","Flip_X":false,"Alpha":1,"Flip_Y":false,"Anims_Prefix":[["beat","Bottom Level Boppers Idle",30,false]]} */

var bottomBopers_scroll:Array<Int> = [0.9,0.9];
var bottomBopers_scale:Array<Int> = [1,1];

bottomBopers.scale.set(bottomBopers_scale[0], bottomBopers_scale[1]);
bottomBopers.scrollFactor.set(bottomBopers_scroll[0], bottomBopers_scroll[1]);
bottomBopers.visible = true;
bottomBopers.angle = 0;
bottomBopers.alpha = 1;
bottomBopers.flipX = false;
bottomBopers.flipY = false;
bottomBopers.antialiasing = true;
//-[Advanced_Properties]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/mall","Sprite_Name":"fgSnow","Position":[-820,700],"Graphic_File":"fgSnow"} */

var fgSnow_position:Array<Int> = [-820,700];

var fgSnow = new FlxSprite(fgSnow_position[0], fgSnow_position[1]);
instance.add(fgSnow);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/mall","Graphic_File":"fgSnow","Position":[-820,700],"Sprite_Name":"fgSnow"} */

fgSnow.loadGraphic(Paths.image('fgSnow', 'stages/mall'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/mall","Play_Anim":"idle","Sprite_Name":"santa","Position":[-640,150],"Anims_Prefix":[["idle","santa idle in fear",30,false]],"Graphic_File":"santa"} */

var santa_position:Array<Int> = [-640,150];

santa = new FlxSprite(santa_position[0], santa_position[1]);
instance.add(santa);
//-{Animated_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/mall","Play_Anim":"idle","Position":[-640,150],"Sprite_Name":"santa","Anims_Prefix":[["idle","santa idle in fear",30,false]],"Graphic_File":"santa"} */

santa.frames = Paths.getAtlas(Paths.image('santa', 'stages/mall', true));

var cur_prefixs:Array<Dynamic> = [["idle","santa idle in fear",30,false]];
for(i in 0...cur_prefixs.length){
var cur_anim:Array<Dynamic> = cur_prefixs[i];
while(cur_anim.length < 6){cur_anim.push(null);}
santa.animation.addByPrefix(cur_anim[0], cur_anim[1], cur_anim[2], cur_anim[3], cur_anim[4], cur_anim[5]);
}
santa.animation.play('idle');
//-[Animated_Graphic]-//
//->Sprite_Object<-//

pushGlobal();
}

function beatHit(curBeat:Int):Void {    
    upperBoopers.animation.play("beat");
    bottomBopers.animation.play("beat");
    santa.animation.play("idle");
}