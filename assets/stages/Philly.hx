import("PreSettings");
import("Paths");
import("Std");

import("flixel.FlxSprite", "FlxSprite");
import("flixel.system.FlxSound", "FlxSound");
import("flixel.group.FlxTypedGroup", "FlxTypedGroup");

presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.7);

function create(){
    var bg = new FlxSprite(-100, 0).loadGraphic(Paths.image('sky', 'stages/philly'));
    bg.scrollFactor.set(0.1, 0.1);
    instance.add(bg);
    
    var city = new FlxSprite(-10, 0).loadGraphic(Paths.image('city', 'stages/philly'));
    city.scrollFactor.set(0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    instance.add(city);

    var phillyCityLights = new FlxTypedGroup<FlxSprite>();
    instance.add(phillyCityLights);

	for(i in 0...5){
		var light = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('win' + i, 'stages/philly'));
		light.scrollFactor.set(0.3, 0.3);
		light.setGraphicSize(Std.int(light.width * 0.85));
		light.updateHitbox();
        light.visible = false;
		phillyCityLights.add(light);
	}
    
    var streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('behindTrain', 'stages/philly'));
    instance.add(streetBehind);

    var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('train', 'stages/philly'));
    instance.add(phillyTrain);

    var trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
	FlxG.sound.list.add(trainSound);
    
    var street = new FlxSprite(-40, 50).loadGraphic(Paths.image('street', 'stages/philly'));
    instance.add(street);
}

function update(){
    
}