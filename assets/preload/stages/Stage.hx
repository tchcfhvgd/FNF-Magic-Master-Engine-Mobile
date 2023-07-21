import("SavedFiles", "SavedFiles");
import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

preset("initChar", 1);
preset("camP_1", [250,180]);
preset("camP_2", [1095,800]);
preset("zoom", 0.9);

var stageback:FlxSprite = null;
var stagefront:FlxSprite = null;
var stagelight1:FlxSprite = null;
var stagelight2:FlxSprite = null;
var stagecurtains:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('stageback','stages/stage')});
	temp.push({type: "IMAGE", instance: Paths.image('stagefront','stages/stage')});
	temp.push({type: "IMAGE", instance: Paths.image('stage_light','stages/stage')});
	temp.push({type: "IMAGE", instance: Paths.image('stage_light','stages/stage')});
	temp.push({type: "IMAGE", instance: Paths.image('stagecurtains','stages/stage')});
}

function create():Void {
	stageback = new FlxSprite(-600, -300);
	stageback.loadGraphic(SavedFiles.getGraphic(Paths.image('stageback', 'stages/stage')));
	stageback.scrollFactor.set(0.5, 0.5);
	instance.add(stageback);

	stagefront = new FlxSprite(-600, 650);
	stagefront.loadGraphic(SavedFiles.getGraphic(Paths.image('stagefront', 'stages/stage')));
	instance.add(stagefront);

	stagelight1 = new FlxSprite(-125, -100);
	stagelight1.loadGraphic(SavedFiles.getGraphic(Paths.image('stage_light', 'stages/stage')));
	stagelight1.scrollFactor.set(0.9, 0.9);
	instance.add(stagelight1);

	stagelight2 = new FlxSprite(1225, -100);
	stagelight2.flipX = true;
	stagelight2.flipY = false;
	stagelight2.scrollFactor.set(0.9, 0.9);
	stagelight2.loadGraphic(SavedFiles.getGraphic(Paths.image('stage_light', 'stages/stage')));
	instance.add(stagelight2);

	stagecurtains = new FlxSprite(-600, -300);
	stagecurtains.scrollFactor.set(1.3, 1.3);
	stagecurtains.loadGraphic(SavedFiles.getGraphic(Paths.image('stagecurtains', 'stages/stage')));
	instance.add(stagecurtains);

}