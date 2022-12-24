/* ||===================================================|| */
/* || SCRIPTED STAGE - DON'T EXPORT IN THE STAGE EDITOR || */
/* ||===================================================|| */

/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": [{"type":"Int","isPresset":true,"value":"5","id":"initChar"},{"type":"Array","isPresset":true,"value":[585,305],"id":"camP_1"},{"type":"Array","isPresset":true,"value":[980,610],"id":"camP_2"},{"isPresset":true,"type":"Float","id":"zoom","value":1.1}] */

import("flixel.system.FlxSound", "FlxSound");
import("flixel.FlxSprite", "FlxSprite");
import("PreSettings", "PreSettings");
import("Character", "Character");
import("flixel.FlxG", "FlxG");
import("Paths", "Paths");

function addToLoad(temp){
temp.push({type:"ATLAS",instance:Paths.image('sky','stages/philly',true)});
temp.push({type:"ATLAS",instance:Paths.image('city','stages/philly',true)});
temp.push({type:"ATLAS",instance:Paths.image('win','stages/philly',true)});
temp.push({type:"ATLAS",instance:Paths.image('behindTrain','stages/philly',true)});
temp.push({type:"ATLAS",instance:Paths.image('train','stages/philly',true)});
temp.push({type:"ATLAS",instance:Paths.image('street','stages/philly',true)});
temp.push({type:"SOUND",instance:Paths.sound('train_passes','stages/philly',true)});
}

presset("initChar", 5);
presset("camP_1", [585,305]);
presset("camP_2", [980,610]);
presset("zoom", 1.1);

var phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
var train:FlxSprite;
var trainSound:FlxSound;
var lights:FlxSprite;

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;

var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;

var startedMoving:Bool = false;

var curLight:Int = -1;

function create(){
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-100,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"sky","Antialiasing":true,"Graphic_Library":"stages/philly","Sprite_Name":"sky","Scroll":[0.1,0.1],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

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
/* "Variables": {"Position":[-100,0],"Scale":[1,1],"Visible":true,"Graphic_File":"sky","Angle":0,"Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.1,0.1],"Sprite_Name":"sky","Alpha":1,"Flip_X":false,"Flip_Y":false} */

sky.loadGraphic(Paths.image('sky', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[-10,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"city","Antialiasing":true,"Graphic_Library":"stages/philly","Sprite_Name":"city","Scroll":[0.3,0.3],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

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
/* "Variables": {"Position":[-10,0],"Scale":[1,1],"Visible":true,"Graphic_File":"city","Angle":0,"Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"city","Alpha":1,"Flip_X":false,"Flip_Y":false} */

city.loadGraphic(Paths.image('city', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Position":[0,0],"Visible":true,"Scale":[1,1],"Angle":0,"Graphic_File":"win","Antialiasing":true,"Graphic_Library":"stages/philly","Sprite_Name":"lights","Scroll":[0.3,0.3],"Flip_X":false,"Alpha":1,"Flip_Y":false} */

var lights_position:Array<Int> = [0,0];

lights = new FlxSprite(lights_position[0], lights_position[1]);
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
/* "Variables": {"Position":[0,0],"Scale":[1,1],"Visible":true,"Graphic_File":"win","Angle":0,"Graphic_Library":"stages/philly","Antialiasing":true,"Scroll":[0.3,0.3],"Sprite_Name":"lights","Alpha":1,"Flip_X":false,"Flip_Y":false} */

lights.loadGraphic(Paths.image('win', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/philly","Sprite_Name":"bhtrain","Position":[-40,50],"Graphic_File":"behindTrain"} */

var bhtrain_position:Array<Int> = [-40,50];

var bhtrain = new FlxSprite(bhtrain_position[0], bhtrain_position[1]);
instance.add(bhtrain);
//-{Basic_Graphic}-//
/* "Packages": {"Paths":"Paths"} */
/* "Variables": {"Graphic_Library":"stages/philly","Graphic_File":"behindTrain","Position":[-40,50],"Sprite_Name":"bhtrain"} */

bhtrain.loadGraphic(Paths.image('behindTrain', 'stages/philly'));
//-[Basic_Graphic]-//
//->Sprite_Object<-//
//-<Sprite_Object>-//
/* "Packages": {"Paths":"Paths","FlxSprite":"flixel.FlxSprite"} */
/* "Variables": {"Graphic_Library":"stages/philly","Sprite_Name":"train","Position":[2000,360],"Graphic_File":"train"} */

var train_position:Array<Int> = [2000,360];

train = new FlxSprite(train_position[0], train_position[1]);
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

trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'stages/philly'));
FlxG.sound.list.add(trainSound);

pushGlobal();
}

function update(elapsed:Float):Void {
    if(trainMoving){
        trainFrameTiming += elapsed;

        if(trainFrameTiming >= 1 / 24){
            updateTrainPos();
            trainFrameTiming = 0;
        }
    }

    lights.alpha -= (getState().conductor.crochet / 1000) * FlxG.elapsed * 1.5;
}

function beatHit(curBeat:Int):Void {
    if(!trainMoving){trainCooldown += 1;}

    if(curBeat % 4 == 0){
        curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
        lights.color = phillyLightsColors[curLight];
        lights.alpha = 1;
    }

    if(curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8){
        trainCooldown = FlxG.random.int(-4, 0);
        trainStart();
    }
}

function trainStart():Void {
    trainMoving = true;
    if(!trainSound.playing){trainSound.play(true);}
}

function updateTrainPos():Void {
    if(trainSound.time >= 4700){
        train.visible = true;
        startedMoving = true;

        var gf_char:Character = getState().stage.getCharacterByType("Girlfriend");
        if(gf_char != null){gf_char.playAnim('hairBlow', true, true);}
    }

    if(startedMoving){
        train.x -= 400;

        if(train.x < -2000 && !trainFinishing){
            train.x = -1150;
            trainCars -= 1;

            if(trainCars <= 0){trainFinishing = true;}
        }

        if(train.x < -4000 && trainFinishing){trainReset();}
    }
}

function trainReset():Void {
    train.x = FlxG.width + 200;
    train.visible = false;
    trainMoving = false;
    // trainSound.stop();
    // trainSound.time = 0;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
    
    var gf_char:Character = getState().stage.getCharacterByType("Girlfriend");
    if(gf_char != null){gf_char.playAnim('hairFall', true, true);}
}