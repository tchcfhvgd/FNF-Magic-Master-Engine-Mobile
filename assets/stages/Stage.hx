import("PreSettings");
import("Paths");

import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.7);

function create(){
    var stageback = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'stages/stage'));
    stageback.antialiasing = PreSettings.getPreSetting("Antialiasing");
    stageback.scrollFactor.set(0.9, 0.9);
    instance.add(stageback);
    
    var stagefront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'stages/stage'));
    stagefront.antialiasing = PreSettings.getPreSetting("Antialiasing");
    instance.add(stagefront);
    
    var stage_light_1 = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_1.antialiasing = PreSettings.getPreSetting("Antialiasing");
    stage_light_1.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_1);
    
    var stage_light_2 = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_2.antialiasing = PreSettings.getPreSetting("Antialiasing");
    stage_light_2.flipX = true;
    stage_light_2.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_2);
    
    var stagecurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'stages/stage'));
    stagecurtains.antialiasing = PreSettings.getPreSetting("Antialiasing");
    stagecurtains.scrollFactor.set(1.3, 1.3);
    instance.add(stagecurtains);
}