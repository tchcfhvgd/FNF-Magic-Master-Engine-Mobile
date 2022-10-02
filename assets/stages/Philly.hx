import("PreSettings");
import("Paths");
import("Std");

import("flixel.FlxG", "FlxG");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.system.FlxSound", "FlxSound");
import("flixel.group.FlxTypedGroup", "FlxTypedGroup");

presset("initChar", 5);
presset("chrome", 0);
presset("zoom", 1.05);

var pre_Antialiasing:Bool = PreSettings.getPreSetting("Antialiasing", "Graphic Settings");
var pre_BackgroundAnimated:Bool = PreSettings.getPreSetting("Background Animated", "Graphic Settings");

var startedMoving:Bool = false;

var trainMoving:Bool = false;
var trainFrameTiming:Int = 0;

var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;

var trainSound:FlxSound = null;

var phillyTrain:FlxSprite = null;

var light:FlxSprite = null;

var phillyCityLights:Array<Int> = [
    0xFF31A2FD,
    0xFF31FD8C,
    0xFFFB33F5,
    0xFFFD4531,
    0xFFFBA633,
];

function create(){
    Paths.save(Paths.getPath('sounds/train_passes.'+Paths.SOUND_EXT, "SOUND"), "SOUND", "shared");

    var bg = new FlxSprite(-100, 0).loadGraphic(Paths.image('sky', 'stages/philly'));
    bg.scrollFactor.set(0.1, 0.1);
    instance.add(bg);
    
    var city = new FlxSprite(-10, 0).loadGraphic(Paths.image('city', 'stages/philly'));
    city.scrollFactor.set(0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    instance.add(city);
    
    light = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('win', 'stages/philly'));
    light.scrollFactor.set(0.3, 0.3);
    light.setGraphicSize(Std.int(light.width * 0.85));
    light.updateHitbox();
    instance.add(light);	
    
    var streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('behindTrain', 'stages/philly'));
    instance.add(streetBehind);
        
    phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('train', 'stages/philly'));
    if(!pre_BackgroundAnimated){phillyTrain.x = -40;}
    instance.add(phillyTrain);
    
    var street = new FlxSprite(-40, 50).loadGraphic(Paths.image('street', 'stages/philly'));
    instance.add(street);
    
    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
	FlxG.sound.list.add(trainSound);

    pushGlobal();
}

function update(elapsed){
    if(pre_BackgroundAnimated){
        if(trainMoving){
            trainFrameTiming += elapsed;

            if(trainFrameTiming >= 1 / 24){
               updateTrainPos();
               trainFrameTiming = 0;
            }
        }
    }
}

function updateTrainPos(){
		if(trainSound.time >= 4700){
			startedMoving = true;
            for(i in 0...stage.character_Length){stage.getCharacterById(i).playAnim('hairBlow', true);}
		}

		if(startedMoving){
			phillyTrain.x -= 400;

			if(phillyTrain.x < -2000 && !trainFinishing){
				phillyTrain.x = -1150;
				trainCars -= 1;

				if(trainCars <= 0){trainFinishing = true;}
			}

			if(phillyTrain.x < -4000 && trainFinishing){trainReset();}
		}
	}

function trainReset(){
    for(i in 0...stage.character_Length){stage.getCharacterById(i).playAnim('hairFall', true);}
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	// trainSound.stop();
	// trainSound.time = 0;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

function stepHit(curStep){
    //trace("Step: " + curStep);
}

function beatHit(curBeat){
    if(pre_BackgroundAnimated){
        //trace("Beat: " + curBeat);

        if(!trainMoving){trainCooldown += 1;}
    
        if(curBeat % 4 == 0){
            var rl = FlxG.random.int(0, phillyCityLights.length - 1);
            light.color = phillyCityLights[rl];
        }
        //curLight.loadGraphic(Paths.image('win' + FlxG.random.int(0, 4), 'stages/philly'));
    
        if(curBeat % 8 == 4 && !trainMoving && trainCooldown > 8){
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
        }
    }
}

function trainStart(){
	trainMoving = true;
	if(!trainSound.playing){trainSound.play(true);}
}