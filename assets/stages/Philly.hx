/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"5","id":"initChar"},{"type":"Array","isPresset":true,"value":[585,305],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[980,610],"id":"camP_2"},{"id":"zoom","value":1.1,"isPresset":true,"type":"Float"}] */

import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 5);
presset("camP_1", [585,305]);
presset("camP_2", [980,610]);
presset("zoom", 1.1);

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-100,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"sky","Graphic_Library":"stages/philly","Sprite_Name":"sky","Scroll":[0.1,0.1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var sky_position:Array<Int> = [-100,0];

var sky = new FlxSprite(sky_position[0], sky_position[1]);
instance.add(sky);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-100,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"sky","Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"sky","Flip_X":false,"Alpha":1,"Flip_Y":false} */

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
/* "Variables": {"Position":[-100,0],"Scale":[1,1],"Visible":true,"Graphic_File":"sky","Angle":0,"Graphic_Library":"stages/philly","Sprite_Name":"sky","Scroll":[0.1,0.1],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

sky.loadGraphic(Paths.image('sky', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-10,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"city","Graphic_Library":"stages/philly","Sprite_Name":"city","Scroll":[0.3,0.3],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var city_position:Array<Int> = [-10,0];

var city = new FlxSprite(city_position[0], city_position[1]);
instance.add(city);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[-10,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"city","Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"city","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var city_scroll:Array<Int> = [0.3,0.3];
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
/* "Variables": {"Position":[-10,0],"Scale":[1,1],"Visible":true,"Graphic_File":"city","Angle":0,"Graphic_Library":"stages/philly","Sprite_Name":"city","Scroll":[0.3,0.3],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

city.loadGraphic(Paths.image('city', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[0,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"win","Graphic_Library":"stages/philly","Sprite_Name":"lights","Scroll":[0.3,0.3],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var lights_position:Array<Int> = [0,0];

var lights = new FlxSprite(lights_position[0], lights_position[1]);
instance.add(lights);
//-{Advanced_Properties}-//
/* "Packages": {} */
/* "Variables": {"Position":[0,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"win","Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"lights","Flip_X":false,"Alpha":1,"Flip_Y":false} */

var lights_scroll:Array<Int> = [0.3,0.3];
var lights_scale:Array<Int> = [1,1];

lights.scale.set(lights_scale[0], lights_scale[1]);
lights.scrollFactor.set(lights_scroll[0], lights_scroll[1]);
lights.visible = true;
lights.angle = 0;
lights.alpha = 1;
lights.flipX = false;
lights.flipY = false;
lights.antialiasing = true;
//-[Advanced_Properties]-//
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Position":[0,0],"Scale":[1,1],"Visible":true,"Graphic_File":"win","Angle":0,"Graphic_Library":"stages/philly","Sprite_Name":"lights","Scroll":[0.3,0.3],"Alpha":1,"Flip_X":false,"Flip_Y":false} */

lights.loadGraphic(Paths.image('win', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/philly","Sprite_Name":"train","Position":[-40,50],"Graphic_File":"behindTrain"} */

var train_position:Array<Int> = [-40,50];

var train = new FlxSprite(train_position[0], train_position[1]);
instance.add(train);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/philly","Graphic_File":"behindTrain","Position":[-40,50],"Sprite_Name":"train"} */

train.loadGraphic(Paths.image('behindTrain', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/philly","Sprite_Name":"train","Position":[2000,360],"Graphic_File":"train"} */

var train_position:Array<Int> = [2000,360];

var train = new FlxSprite(train_position[0], train_position[1]);
instance.add(train);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/philly","Graphic_File":"train","Position":[2000,360],"Sprite_Name":"train"} */

train.loadGraphic(Paths.image('train', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/philly","Sprite_Name":"street","Position":[-40,50],"Graphic_File":"street"} */

var street_position:Array<Int> = [-40,50];

var street = new FlxSprite(street_position[0], street_position[1]);
instance.add(street);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/philly","Graphic_File":"street","Position":[-40,50],"Sprite_Name":"street"} */

street.loadGraphic(Paths.image('street', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
}