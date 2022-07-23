import("PreSettings");
import("Paths");

import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.9);

function create(){
    var skyBG = new FlxSprite(-120, -50).loadGraphic(Paths.image('limoSunset', 'stages/limo'));
    skyBG.antialiasing = PreSettings.getPreSetting("Antialiasing");
    skyBG.scrollFactor.set(0.1, 0.1);
    instance.add(skyBG);
    
    var limoMetalPole = new FlxSprite(-500, 220).loadGraphic(Paths.image('metalPole', 'stages/limo'));
    limoMetalPole.antialiasing = PreSettings.getPreSetting("Antialiasing");
    limoMetalPole.scrollFactor.set(0.4, 0.4);
    instance.add(limoMetalPole);
    
    var bgLimo = new FlxSprite(-150, 480);
    halloweenBG.frames = Paths.getSparrowAtlas('bgLimo', 'stages/limo');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
    bgLimo.animation.play('drive');
    bgLimo.antialiasing = PreSettings.getPreSetting("Antialiasing");
    bgLimo.scrollFactor.set(0.4, 0.4);
    instance.add(bgLimo);
    
    //var grpLimoDancers = new FlxTypedGroup<FlxSprite>();
    //instance.add(grpLimoDancers);

    //for(i in 0...5){
    //    var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
    //    dancer.scrollFactor.set(0.4, 0.4);
    //    grpLimoDancers.add(dancer);
    //}

    var limoLight = new FlxSprite(limoMetalPole.x - 180, limoMetalPole.y - 80).loadGraphic(Paths.image('coldHeartKiller', 'stages/limo'));
    limoLight.scrollFactor.set(0.4, 0.4);
    instance.add(limoLight);

	var grpLimoParticles = new FlxTypedGroup<FlxSprite>();
	instance.add(grpLimoParticles);

	//PRECACHE BLOOD
    var particle = new FlxSprite(-400, -400);
    particle.frames = Paths.getSparrowAtlas('stupidBlood', 'stages/limo');
    particle.animation.addByPrefix('blood', "blood", 24);
    particle.animation.play('blood');
    particle.scrollFactor.set(0.4, 0.4);
	particle.alpha = 0.01;
	grpLimoParticles.add(particle);
}