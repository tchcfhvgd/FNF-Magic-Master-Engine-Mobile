import("PreSettings", "PreSettings");
import("SavedFiles", "SavedFiles");
import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 5);
presset("camP_1", [-15,-290]);
presset("camP_2", [1340,490]);
presset("zoom", 0.8);

var background:FlxSprite = null;
var upperBoopers:FlxSprite = null;
var backstairs:FlxSprite = null;
var tree:FlxSprite = null;
var bottomBoopers:FlxSprite = null;
var floorSnow:FlxSprite = null;
var santa:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('bgWalls','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('upperBop','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('bgEscalator','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('christmasTree','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('bottomBop','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('fgSnow','stages/mall')});
	temp.push({type: "IMAGE", instance: Paths.image('santa','stages/mall')});
	temp.push({type: "SOUND", instance: Paths.sound('Lights_Shut_off','stages/mall')});
}

function create():Void {
	background = new FlxSprite(-1300, -500);
	background.scrollFactor.set(0.2, 0.2);
	background.loadGraphic(SavedFiles.getGraphic(Paths.image('bgWalls', 'stages/mall')));
	instance.add(background);

	upperBoopers = new FlxSprite(-330, 0);
	upperBoopers.frames = SavedFiles.getAtlas(Paths.image('upperBop', 'stages/mall'));
	upperBoopers.animation.addByPrefix('beat', 'Upper Crowd Bob');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){upperBoopers.animation.play('idle');}
	upperBoopers.scrollFactor.set(0.3, 0.3);
	instance.add(upperBoopers);

	backstairs = new FlxSprite(-1350, -550);
	backstairs.loadGraphic(SavedFiles.getGraphic(Paths.image('bgEscalator', 'stages/mall')));
	backstairs.scrollFactor.set(0.3, 0.3);
	instance.add(backstairs);

	tree = new FlxSprite(400, -250);
	tree.scrollFactor.set(0.4, 0.4);
	tree.loadGraphic(SavedFiles.getGraphic(Paths.image('christmasTree', 'stages/mall')));
	instance.add(tree);

	bottomBoopers = new FlxSprite(-470, 140);
	bottomBoopers.frames = SavedFiles.getAtlas(Paths.image('bottomBop', 'stages/mall'));
	bottomBoopers.animation.addByPrefix('beat', 'Bottom Level Boppers Idle');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){bottomBoopers.animation.play('idle');}
	bottomBoopers.scrollFactor.set(0.9, 0.9);
	instance.add(bottomBoopers);

	floorSnow = new FlxSprite(-820, 700);
	floorSnow.loadGraphic(SavedFiles.getGraphic(Paths.image('fgSnow', 'stages/mall')));
	instance.add(floorSnow);

	santa = new FlxSprite(-640, 150);
	santa.frames = SavedFiles.getAtlas(Paths.image('santa', 'stages/mall'));
	santa.animation.addByPrefix('idle', 'santa idle in fear');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){santa.animation.play('idle');}
	instance.add(santa);

	pushGlobal();
}

function beatHit(curBeat:Int):Void {
    if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
    upperBoopers.animation.play("beat");
    bottomBoopers.animation.play("beat");
    santa.animation.play("idle");
}