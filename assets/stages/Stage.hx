import("PreSettings");
import("Paths");

import("flixel.math.FlxPoint", "FlxPoint");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.9);

presset("camP_1", new FlxPoint(400, 250));
presset("camP_2", new FlxPoint(900, 600));

function create(){
    var stageback = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'stages/stage'));
    stageback.scrollFactor.set(0.9, 0.9);
    instance.add(stageback);
    
    var stagefront = new FlxSprite(-600, 650).loadGraphic(Paths.image('stagefront', 'stages/stage'));
    instance.add(stagefront);
    
    var stage_light_1 = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_1.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_1);
    
    var stage_light_2 = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_2.flipX = true;
    stage_light_2.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_2);
    
    var stagecurtains = new FlxSprite(-600, -300).loadGraphic(Paths.image('stagecurtains', 'stages/stage'));
    stagecurtains.scrollFactor.set(1.3, 1.3);
    instance.add(stagecurtains);
}