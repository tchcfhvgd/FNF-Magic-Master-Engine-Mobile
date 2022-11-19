/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"2","id":"initChar"},{"id":"camP_1","value":[-60,-2210],"isPresset":true,"type":"Array"},{"id":"camP_2","value":[1410,620],"isPresset":true,"type":"Array"},{"id":"zoom","value":1.1,"isPresset":true,"type":"Float"}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 2);
presset("camP_1", [-60,-2210]);
presset("camP_2", [1410,620]);
presset("zoom", 1.1);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-615,-620],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"evilBG","Graphic_Library":"stages/mallEvil","Sprite_Name":"bg","Scroll":[0.2,0.2],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var bg_position:Array<Int> = [-615,-620];

var bg = new FlxSprite(bg_position[0], bg_position[1]);
instance.add(bg);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-615,-620],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"evilBG","Graphic_Library":"stages/mallEvil","Antialiasing":true,"Scroll":[0.2,0.2],"Sprite_Name":"bg","Flip_X":false,"Alpha":1,"Flip_Y":false} */

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
/* "Variables": {"Position":[-615,-620],"Scale":[1,1],"Visible":true,"Graphic_File":"evilBG","Angle":0,"Graphic_Library":"stages/mallEvil","Sprite_Name":"bg","Scroll":[0.2,0.2],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

bg.loadGraphic(Paths.image('evilBG', 'stages/mallEvil'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[450,-250],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"evilTree","Graphic_Library":"stages/mallEvil","Sprite_Name":"tree","Scroll":[0.4,0.4],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var tree_position:Array<Int> = [450,-250];

var tree = new FlxSprite(tree_position[0], tree_position[1]);
instance.add(tree);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[450,-250],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"evilTree","Graphic_Library":"stages/mallEvil","Antialiasing":true,"Scroll":[0.4,0.4],"Sprite_Name":"tree","Flip_X":false,"Alpha":1,"Flip_Y":false} */

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
/* "Variables": {"Position":[450,-250],"Scale":[1,1],"Visible":true,"Graphic_File":"evilTree","Angle":0,"Graphic_Library":"stages/mallEvil","Sprite_Name":"tree","Scroll":[0.4,0.4],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

tree.loadGraphic(Paths.image('evilTree', 'stages/mallEvil'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/mallEvil","Sprite_Name":"fgSnow","Position":[-620,700],"Graphic_File":"evilSnow"} */

var fgSnow_position:Array<Int> = [-620,700];

var fgSnow = new FlxSprite(fgSnow_position[0], fgSnow_position[1]);
instance.add(fgSnow);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/mallEvil","Graphic_File":"evilSnow","Position":[-620,700],"Sprite_Name":"fgSnow"} */

fgSnow.loadGraphic(Paths.image('evilSnow', 'stages/mallEvil'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}