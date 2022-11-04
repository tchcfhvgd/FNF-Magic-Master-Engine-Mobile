import("PreSettings");
import("Paths");
import("flixel.math.FlxPoint", "FlxPoint");
import("flixel.FlxSprite", "FlxSprite");
//---||---//
presset("addToLoad", function(list:Array<Dynamic>){});
presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.9);
presset("camP_1", new FlxPoint(400, 250));
presset("camP_2", new FlxPoint(900, 600));
//---||---//
function addToLoad(list:Array<Dynamic>){
    //-<load_path>-//
    list.push({type:"IMAGE", instance:Paths.image('stageback', 'stages/stage', true)});
    //->load_path<-//
    //-<load_path>-//
    list.push({type:"IMAGE", instance:Paths.image('stagefront', 'stages/stage', true)});
    //->load_path<-//
    //-<load_path>-//
    list.push({type:"IMAGE", instance:Paths.image('stage_light', 'stages/stage', true)});
    //->load_path<-//
    //-<load_path>-//
    list.push({type:"IMAGE", instance:Paths.image('stagecurtains', 'stages/stage', true)});
    //->load_path<-//
}
//---||---//
function create(){
    //-<sprite_object>-//
    var stageback = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'stages/stage'));
    stageback.scrollFactor.set(0.9, 0.9);
    instance.add(stageback);
    //->sprite_object<-//
    //-<sprite_object>-//
    var stagefront = new FlxSprite(-600, 650).loadGraphic(Paths.image('stagefront', 'stages/stage'));
    instance.add(stagefront);
    //->sprite_object<-//
    //-<sprite_object>-//
    var stage_light_1 = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_1.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_1);
    //->sprite_object<-//
    //-<sprite_object>-//
    var stage_light_2 = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light', 'stages/stage'));
    stage_light_2.flipX = true;
    stage_light_2.scrollFactor.set(0.9, 0.9);
    instance.add(stage_light_2);
    //->sprite_object<-//
    //-<sprite_object>-//
    var stagecurtains = new FlxSprite(-600, -300).loadGraphic(Paths.image('stagecurtains', 'stages/stage'));
    stagecurtains.scrollFactor.set(1.3, 1.3);
    instance.add(stagecurtains);
    //->sprite_object<-//
}
//---||---//