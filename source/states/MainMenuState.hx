package states;

import states.editors.CharacterEditorState;
import states.editors.XMLEditorState;
import flixel.input.mouse.FlxMouse;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.FlxSubState;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class MainMenuState extends MusicBeatState{
	var typeMenu:String = "MainMenuState";

	var curSelected:Int = 0;
	var arrayOptions:Array<String> = [
		"StoryMode",
		"FreePlay",
		"Skins",
		"Options",
		"Mods",
		"Extras",
		"Credits"
	];
	var grpOptions:FlxTypedGroup<Alphabet>;

	var stage:Stage;

    var camFollow:FlxObject;
	override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		MagicStuff.setWindowTitle('In the Menus');
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)){FlxG.sound.playMusic(Paths.music('freakyMenu'));}

		persistentUpdate = persistentDraw = true;

		stage = new Stage("Stage", [
			["Girlfriend", [400, 130], 1, false, "Default", "GF", 0],
            ["Daddy_Dearest", [100, 100], 1, true, "Default", "NORMAL", 0],
            ["Boyfriend", [770, 100], 1, false, "Default", "NORMAL", 0]
		]);
		add(stage);

		grpOptions = new FlxTypedGroup<Alphabet>();
		grpOptions.cameras = [camHUD];
		add(grpOptions);

		for(opt in arrayOptions){
			
		}

		changeSelect(0);

		super.create();
	}

	override function update(elapsed:Float){
		if (FlxG.sound.music.volume < 0.8){
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		super.update(elapsed);
		
		switch(typeMenu){
			case "MainMenuState":{
				if(canControlle){
					if(principal_controls.checkAction("Menu_Left", JUST_PRESSED)){changeSelect(-1);}
					if(principal_controls.checkAction("Menu_Right", JUST_PRESSED)){changeSelect(1);}
					if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
						switch(arrayOptions[curSelected]){
							case "Options":{
								canControlle = false;
								FlxTween.tween(camHUD, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween){
									openSubState(new substates.OptionsSubState());
									typeMenu = "OptionState";
								}});
							}
							case "FreePlay":{
								canControlle = false;
								MusicBeatState.switchState(new FreeplayState(null, MainMenuState));
							}
						}
					}

					if(FlxG.keys.justPressed.ONE){states.editors.ChartEditorState.editChart(null, MainMenuState);}
					if(FlxG.keys.justPressed.FOUR){states.editors.CharacterEditorState.editCharacter(null, MainMenuState);}
					//if(FlxG.keys.justPressed.TWO){states.editors.StageEditorState.editStage(null, new MainMenuState());}
					if(FlxG.keys.justPressed.THREE){states.editors.XMLEditorState.editXML(null, MainMenuState);}
				}
			}

			case "OptionState":{
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.05);
				//camFollow.setPosition(250, 150);
			}
		}
	}

	function changeSelect(change:Int){
		curSelected += change;

		if(curSelected >= arrayOptions.length){curSelected = 0;}
		if(curSelected < 0){curSelected = arrayOptions.length - 1;}
	}

	override function openSubState(SubState:FlxSubState){
		camHUD.alpha = 0;

		super.openSubState(SubState);
	}

	override function closeSubState(){
		FlxTween.tween(camHUD, {alpha: 1}, 0.5, {onComplete: function(twn:FlxTween){canControlle = true;}});
		typeMenu = "MainMenuState";

		FlxG.mouse.visible = false;
		
		super.closeSubState();
	}
}
