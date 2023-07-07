import("SavedFiles", "SavedFiles");
import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 2);
presset("camP_1", [-60,-2210]);
presset("camP_2", [1110,490]);
presset("zoom", 1.1);

var background:FlxSprite = null;
var tree:FlxSprite = null;
var floorSnow:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('evilBG','stages/mallEvil')});
	temp.push({type: "IMAGE", instance: Paths.image('evilTree','stages/mallEvil')});
	temp.push({type: "IMAGE", instance: Paths.image('evilSnow','stages/mallEvil')});
}

function create():Void {
	background = new FlxSprite(-615, -620);
	background.scrollFactor.set(0.2, 0.2);
	background.loadGraphic(SavedFiles.getGraphic(Paths.image('evilBG', 'stages/mallEvil')));
	instance.add(background);

	tree = new FlxSprite(400, -250);
	tree.scrollFactor.set(0.4, 0.4);
	tree.loadGraphic(SavedFiles.getGraphic(Paths.image('evilTree', 'stages/mallEvil')));
	instance.add(tree);

	floorSnow = new FlxSprite(-620, 700);
	floorSnow.loadGraphic(SavedFiles.getGraphic(Paths.image('evilSnow', 'stages/mallEvil')));
	instance.add(floorSnow);

}