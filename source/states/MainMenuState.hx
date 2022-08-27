package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import states.editors.CharacterEditorState;
import flixel.addons.text.FlxTypeText;
import states.editors.XMLEditorState;
import flixel.addons.ui.FlxUIButton;
import flixel.input.mouse.FlxMouse;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.util.FlxGradient;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import io.newgrounds.NG;
import flixel.FlxCamera;
import flixel.FlxG;

import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomNumericStepper;

import Song.SwagSong;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class MainMenuState extends MusicBeatState{
    var camFollow:FlxObject;
	var stage:Stage;

	override function create(){		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		MagicStuff.setWindowTitle('In the Menus');
		#end

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)){FlxG.sound.playMusic(Paths.music('freakyMenu'));}

		var rSong:SwagSong = getRandomSong();
		stage = new Stage(rSong.stage, rSong.characters);
		add(stage);

		FlxG.camera.zoom = stage.zoom;
		
		addUI();
		
		super.create();

        camFollow = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON);
		add(camFollow);
	}

	override function update(elapsed:Float){
		if(FlxG.sound.music.volume < 0.8){FlxG.sound.music.volume += 0.5 * FlxG.elapsed;}
		conductor.songPosition = FlxG.sound.music.time;

		if(canControlle){			
			if(FlxG.keys.justPressed.ONE){states.editors.ChartEditorState.editChart(null, MainMenuState);}
			if(FlxG.keys.justPressed.FOUR){states.editors.CharacterEditorState.editCharacter(null, MainMenuState);}
			//if(FlxG.keys.justPressed.TWO){states.editors.StageEditorState.editStage(null, new MainMenuState());}
			if(FlxG.keys.justPressed.THREE){states.editors.XMLEditorState.editXML(null, MainMenuState);}

			if(FlxG.mouse.justPressed){
				for(i in 0...stage.character_Length){
					var nChar = stage.getCharacterById(i);
					if(FlxG.mouse.overlaps(nChar)){nChar.playAnim("hey", true);}
				}
			}			
		}
		
		if(stage.camP_1 != null && stage.camP_2 != null){
			camFollow.setPosition((stage.camP_1.x + (FlxG.mouse.x * (stage.camP_2.x - stage.camP_1.x) / FlxG.width)), (stage.camP_1.y + (FlxG.mouse.y * (stage.camP_2.y - stage.camP_1.y) / FlxG.height)));
		}
		

		super.update(elapsed);		
	}

	var beatLogo:FlxSprite;
	var grpOptions:FlxTypedGroup<FlxUIButton>;
	public function addUI():Void {
		beatLogo = new FlxSprite().loadGraphic(Paths.image('LOGO'));
		beatLogo.setGraphicSize(Std.int(FlxG.width / 4));
		beatLogo.updateHitbox();
		beatLogo.y = 10; beatLogo.screenCenter(X);
		beatLogo.antialiasing = PreSettings.getPreSetting("Antialiasing");
		beatLogo.camera = camHUD;
		add(beatLogo);

		grpOptions = new FlxTypedGroup<FlxUIButton>();
		add(grpOptions);

		// MENU BUTTONS
		var btnStory:FlxUIButton = new FlxUICustomButton(0, 0, 200, 200, "StoryMenu", null, null, function(){});
		btnStory.screenCenter(); btnStory.x -= 200;
		btnStory.camera = camHUD;
		grpOptions.add(btnStory);
		
		var btnFreePlay:FlxUIButton = new FlxUICustomButton(0, 0, 200, 200, "Freeplay", null, null, function(){MusicBeatState.switchState(new FreeplayState(null, MainMenuState));});
		btnFreePlay.screenCenter(); btnFreePlay.x += 200;
		btnFreePlay.camera = camHUD;
		grpOptions.add(btnFreePlay);

		var btnSkins:FlxUIButton = new FlxUICustomButton(0, 0, 200, 80, "Skins", null, null, function(){});
		btnSkins.screenCenter(); btnSkins.y += 200;
		btnSkins.camera = camHUD;
		grpOptions.add(btnSkins);
		
		var btnCredits:FlxUIButton = new FlxUICustomButton(0, FlxG.height - 50, 200, 50, "Credits", null, null, function(){});
		btnCredits.camera = camHUD;
		grpOptions.add(btnCredits);

		var btnOptions:FlxUIButton = new FlxUICustomButton(btnCredits.x + btnCredits.width + 25, btnCredits.y, 200, 50, "Options", null, null, function(){});
		btnOptions.camera = camHUD;
		grpOptions.add(btnOptions);
		
		var btnMods:FlxUIButton = new FlxUICustomButton(btnOptions.x + btnOptions.width + 25, btnOptions.y, 200, 50, "Mods", null, null, function(){MusicBeatState.switchState(new ModListState(MainMenuState, null));});
		btnMods.camera = camHUD;
		grpOptions.add(btnMods);
	}

	function getRandomSong():SwagSong {
		var arrSongs:Array<String> = [];
		for(song in Highscore.songScores.keys()){arrSongs.push(song);}

		var sSong:SwagSong = Song.loadFromJson(arrSongs[FlxG.random.int(arrSongs.length - 1)]);
		return sSong;
	}
}
