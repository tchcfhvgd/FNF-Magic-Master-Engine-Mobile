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
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.FlxCamera;

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
		[2, [0, 100], 0.8],
		[3, [0, 100], 0.8],
		[1, [0, 100], 0.8],
		[0, [0, 100], 1.1],
		[0, [0, 0], 0.8],
		[0, [0, 0], 0.8]
	];

	var arrayCharOptions:Array<Dynamic> = [
	   // Character    Position   isRight  Category  Type  Layer
		["Cuddles", [200, -300], 0.6, false, "Default", "NORMAL", 1],
		["Sniffles", [400, -250], 0.6, false, "Default", "NORMAL", 1],
		["Girlfriend", [0, 0], 1, true, "Default", "GF", -1],
		["Fliqpy", [-600, 110], 1, true, "Default", "NORMAL", -1],
		["Boyfriend", [600, 110], 1, false, "Default", "NORMAL", -1]
	];

	var stage:Stage;
	var options:FlxTypedGroup<FlxText>;

	var camFollow:FlxObject;

	//Cameras
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

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

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		stage = new Stage("land-cute", arrayCharOptions);
		add(stage);

		var backOpt = new FlxSprite(0, FlxG.height - 120).makeGraphic(FlxG.width, 120, FlxColor.BLACK);
		backOpt.alpha = 0.5;
		backOpt.cameras = [camHUD];
		add(backOpt);

		options = new FlxTypedGroup<FlxText>();
		add(options);
		for(i in 0...arrayOptions.length){
			var option:FlxText = new FlxText(0, FlxG.height - 120, 0, arrayOptions[i], 72);
			option.font = Paths.font("Countryhouse.ttf");
			option.color = FlxColor.WHITE;
			option.cameras = [camHUD];
			option.ID = i;
			options.add(option);

			FlxTween.tween(option, {y: option.y + 5}, 1 + (1 * i), {type: FlxTween.PINGPONG, ease: FlxEase.smootherStepInOut});
		}
		

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = 0.8;
		FlxG.camera.focusOn(camFollow.getPosition());

		changeSelect(0);

		super.create();
	}

	override function update(elapsed:Float){
		if (FlxG.sound.music.volume < 0.8){
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		super.update(elapsed);
		
		options.forEach(function(opt:FlxText){
			if(opt.ID == curSelected){
				opt.x = FlxMath.lerp(opt.x, (FlxG.width / 2) - (opt.width / 2), 0.5);
				opt.alpha = FlxMath.lerp(opt.alpha, 1, 0.5);
			}else if(opt.ID == curSelected - 1 || (opt.ID == options.members.length - 1 && curSelected == 0)){
				opt.x = FlxMath.lerp(opt.x, 0 - (opt.width / 2), 0.5);
				opt.alpha = FlxMath.lerp(opt.alpha, 0.5, 0.5);
			}else if(opt.ID == curSelected + 1 || (opt.ID == 0 && curSelected == options.members.length - 1)){
				opt.x = FlxMath.lerp(opt.x, FlxG.width - (opt.width / 2), 0.5);
				opt.alpha = FlxMath.lerp(opt.alpha, 0.5, 0.5);
			}else{
				opt.alpha = FlxMath.lerp(opt.alpha, 0, 0.5);
				opt.x = FlxMath.lerp(opt.x, (FlxG.width / 2) - (opt.width / 2), 0.5);
			}
		});

		switch(typeMenu){
			case "MainMenuState":{
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, arrayOther[curSelected][2], 0.05);
				if(stage.characters.members[arrayOther[curSelected][0]].exists){
					var curChar:Character = stage.characters.members[arrayOther[curSelected][0]];

					var toX = curChar.getMidpoint().x + curChar.cameraPosition[0];
					var toY = curChar.getMidpoint().y + curChar.cameraPosition[1];

					var nextFollow:Array<Float> = [toX + arrayOther[curSelected][1][0], toY + arrayOther[curSelected][1][1]];

					camFollow.setPosition(nextFollow[0], nextFollow[1]);
				}

				if(Controls.getBind("Menu_Left", "JUST_PRESSED")){changeSelect(-1);}
				if(Controls.getBind("Menu_Right", "JUST_PRESSED")){changeSelect(1);}
				if(Controls.getBind("Menu_Accept", "JUST_PRESSED")){
					switch(arrayOptions[curSelected]){
						case "Options":{
							typeMenu = "OptionState";
						}
					}
				}
			}

			case "OptionState":{
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.45, 0.05);
				camFollow.setPosition(250, 150);

				stage.characters.forEach(function(char:Character){
					char.alpha = FlxMath.lerp(char.alpha, 1, 2);
				});

				if(Controls.getBind("Menu_Back", "JUST_PRESSED")){
					typeMenu = "MainMenuState";
				}
			}
		}
	}

	function changeSelect(change:Int){
		curSelected += change;

		if(curSelected >= arrayOptions.length){curSelected = 0;}
		if(curSelected < 0){curSelected = arrayOptions.length - 1;}
	}
}
