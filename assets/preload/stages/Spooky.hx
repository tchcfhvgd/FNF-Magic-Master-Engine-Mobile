import("flixel.FlxSprite", "FlxSprite");
import("PreSettings", "PreSettings");
import("SavedFiles", "SavedFiles");
import("flixel.FlxG", "FlxG");
import("Paths", "Paths");

presset("initChar", 0);
presset("camP_1", [400,230]);
presset("camP_2", [1300,570]);
presset("zoom", 1.1);

var background:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('halloween_bg','stages/spooky')});
}

function create():Void {
	background = new FlxSprite(-200, -110);
	background.frames = SavedFiles.getAtlas(Paths.image('halloween_bg', 'stages/spooky'));
	background.animation.addByPrefix('idle', 'halloweem bg lightning strike', 30, false);
	background.animation.play('idle');
	instance.add(background);

	pushGlobal();
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;
function beatHit(curBeat:Int):Void {
	if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
    if(FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset){lightningStrikeShit(curBeat);}
}

function lightningStrikeShit(curBeat:Int):Void {
	FlxG.sound.play(SavedFiles.getSound(Paths.soundRandom('thunder_', 1, 2, 'stages/spooky')));
	background.animation.play('idle');
	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);
    for(i in 0...getState().stage.character_Length){getState().stage.getCharacterById(i).singAnim('scared');}
}