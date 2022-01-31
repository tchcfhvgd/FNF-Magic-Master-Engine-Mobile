package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.math.FlxMath;

using StringTools;

class MainMenuState extends MusicBeatState{
	var typeMenu:String = "MainMenuState";
	
	var curSelected:Int = 0;

	var arrayOptions:Array<String> = [
		"StoryMode",
		"FreePlay",
		"Skins",
		"Options",
		"Extras",
		"Credits"
	];

	var arrayOther:Array<Dynamic> = [
		[2, [0, 0], 0.8],
		[3, [0, 0], 0.8],
		[1, [0, 0], 0.8],
		[0, [0, 0], 1.1],
		[0, [0, 0], 0.8],
		[0, [0, 0], 0.8]
	];

	var arrayCharOptions:Array<Dynamic> = [
	   // Character    Position   isRight  Category  Type  Layer
		["Cuddles", [200, -200], 0.7, false, "Default", "NORMAL", 1],
		["Girlfriend", [0, 0], 1, true, "Default", "GF", -1],
		["Fliqpy", [-600, 110], 1, true, "Default", "NORMAL", -1],
		["Boyfriend", [600, 110], 1, false, "Default", "NORMAL", -1]
	];

	var stage:Stage;

	var camFollow:FlxObject;

	override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		stage = new Stage("land-cute", arrayCharOptions);
		add(stage);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = 0.8;
		FlxG.camera.focusOn(camFollow.getPosition());

		super.create();
	}

	override function update(elapsed:Float){
		if (FlxG.sound.music.volume < 0.8){
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		super.update(elapsed);

		switch(typeMenu){
			case "MainMenuState":{
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, arrayOther[curSelected][2], 0.05);
				if(stage.characters.members[arrayOther[curSelected][0]].exists){
					var curChar:Character = stage.characters.members[arrayOther[curSelected][0]];

					var toX = curChar.getMidpoint().x + curChar.cameraPosition[0];
					var toY = curChar.getMidpoint().y + curChar.cameraPosition[1];

					var nextFollow:Array<Float> = [toX + arrayOther[curSelected][1][0], toY + arrayOther[curSelected][1][1]];

					camFollow.setPosition(nextFollow[0], nextFollow[1]);

					stage.characters.forEach(function(char:Character){
						if(char != curChar){
							char.alpha = FlxMath.lerp(char.alpha, 0, 0.1);
						}else{
							char.alpha = FlxMath.lerp(char.alpha, 1, 0.2);
						}
					});
				}

				if(Controls.getBind("Menu_Left", "JUST_PRESSED")){changeSelect(-1);}
				if(Controls.getBind("Menu_Right", "JUST_PRESSED")){changeSelect(1);}
			}

			case "OptionState":{
				camFollow.setPosition(0, -5000);
				stage.characters.forEach(function(char:Character){
					char.alpha = FlxMath.lerp(char.alpha, 1, 2);
				});
			}
		}
	}

	function changeSelect(change:Int){
		curSelected += change;

		if(curSelected >= arrayOptions.length){curSelected = 0;}
		if(curSelected < 0){curSelected = arrayOptions.length - 1;}
	}
}
