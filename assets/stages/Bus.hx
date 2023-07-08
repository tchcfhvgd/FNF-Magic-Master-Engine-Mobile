import("PreSettings", "PreSettings");
import("SavedFiles", "SavedFiles");
import("Paths", "Paths");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 4);
presset("camP_1", [450,360]);
presset("camP_2", [820,520]);
presset("zoom", 1.1);

var window:FlxSprite = null;
var back:FlxSprite = null;
var bars:FlxSprite = null;
var blue:FlxSprite = null;
var radio:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('window','stages/bus')});
	temp.push({type: "IMAGE", instance: Paths.image('back','stages/bus')});
	temp.push({type: "IMAGE", instance: Paths.image('bars','stages/bus')});
	temp.push({type: "IMAGE", instance: Paths.image('filtro','stages/bus')});
	temp.push({type: "IMAGE", instance: Paths.image('radio','stages/bus')});
}

function create():Void {
	window = new FlxSprite(-600, -50);
	window.frames = SavedFiles.getAtlas(Paths.image('window', 'stages/bus'));
	window.animation.addByPrefix('idle', 'window');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){window.animation.play('idle');}
	window.scale.set(1.2, 1.2);
	window.updateHitbox();
	window.scrollFactor.set(0.8, 0.8);
	instance.add(window);

	back = new FlxSprite(-200, -50);
	back.loadGraphic(SavedFiles.getGraphic(Paths.image('back', 'stages/bus')));
	back.scrollFactor.set(0.9, 0.9);
	back.scale.set(1.2, 1.2);
	back.updateHitbox();
	instance.add(back);

	bars = new FlxSprite(-70, 0);
	bars.loadGraphic(SavedFiles.getGraphic(Paths.image('bars', 'stages/bus')));
	bars.scale.set(1.2, 1.2);
	bars.updateHitbox();
	instance.add(bars);

	blue = new FlxSprite(0, 0);
	blue.loadGraphic(SavedFiles.getGraphic(Paths.image('filtro', 'stages/bus')));
	blue.scrollFactor.set(1.38777878078145e-16, 1.38777878078145e-16);
	instance.add(blue);

	radio = new FlxSprite(480, 530);
	radio.frames = SavedFiles.getAtlas(Paths.image('radio', 'stages/bus'));
	radio.animation.addByPrefix('idle', 'RADIO', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){radio.animation.play('idle');}
	instance.add(radio);

	pushGlobal();
}

function beatHit(curBeat:Int):Void {
	if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
	radio.animation.play('idle');
}