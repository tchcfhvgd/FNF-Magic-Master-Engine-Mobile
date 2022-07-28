import("PreSettings");
import("Paths");

import("flixel.FlxG", "FlxG");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.util.FlxTimer", "FlxTimer");

presset("initChar", 15);
presset("chrome", 0);
presset("zoom", 0.9);

var grpLimoDancers:Array<FlxSprite> = [];
var danced:Bool = false;

var fastCar:FlxSprite;
var fastCarCanDrive:Bool = true;

function create(){
    var skyBG = new FlxSprite(-120, -50).loadGraphic(Paths.image('limoSunset', 'stages/limo'));
    skyBG.antialiasing = PreSettings.getPreSetting("Antialiasing");
    skyBG.scrollFactor.set(0.1, 0.1);
    instance.add(skyBG);
    
    var limoMetalPole = new FlxSprite(-500, 220).loadGraphic(Paths.image('metalPole', 'stages/limo'));
    limoMetalPole.antialiasing = PreSettings.getPreSetting("Antialiasing");
    limoMetalPole.scrollFactor.set(0.4, 0.4);
    instance.add(limoMetalPole);
    
    var limoLight = new FlxSprite(limoMetalPole.x - 180, limoMetalPole.y - 80).loadGraphic(Paths.image('coldHeartKiller', 'stages/limo'));
    limoLight.scrollFactor.set(0.4, 0.4);
    instance.add(limoLight);
    
    var bgLimo = new FlxSprite(-150, 480);
    bgLimo.frames = Paths.getSparrowAtlas('bgLimo', 'stages/limo');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
    bgLimo.animation.play('drive');
    bgLimo.antialiasing = PreSettings.getPreSetting("Antialiasing");
    bgLimo.scrollFactor.set(0.4, 0.4);
    instance.add(bgLimo);
    
    for(i in 0...5){
        var dancer:FlxSprite = new FlxSprite((370 * i) + 130, bgLimo.y - 400);
        dancer.frames = Paths.getSparrowAtlas("limoDancer", "stages/limo");
		dancer.antialiasing = PreSettings.getPreSetting("Antialiasing");
        dancer.scrollFactor.set(0.4, 0.4);
		dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		dancer.animation.play('danceLeft');
        grpLimoDancers.push(dancer);
        instance.add(dancer);
    }
    
    fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('fastCarLol', 'stages/limo'));
    resetFastCar();
    instance.add(fastCar);
    
    var limo = new FlxSprite(-120, 550);
    limo.frames = Paths.getSparrowAtlas('limoDrive', "stages/limo");
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = PreSettings.getPreSetting("Antialiasing");
    instance.add(limo);

    pushGlobal();
}

function beatHit(curBeat){
    danced = !danced;
    for(dancer in grpLimoDancers){
		if(danced){
            dancer.animation.play('danceRight', true);
        }else{
            dancer.animation.play('danceLeft', true);
        }
    }

    if(FlxG.random.bool(10) && fastCarCanDrive){fastCarDrive();}
}

function resetFastCar(){
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
}
    
function fastCarDrive(){
    var r = FlxG.random.int(0, 1);
    FlxG.sound.play(Paths.sound('carPass' + r), 0.7);
    
    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer){resetFastCar();});
}