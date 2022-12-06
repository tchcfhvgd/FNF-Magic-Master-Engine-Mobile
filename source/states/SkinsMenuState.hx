package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIButton;
import flixel.input.mouse.FlxMouse;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.util.FlxGradient;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import io.newgrounds.NG;
import flixel.FlxCamera;
import flixel.FlxG;

import Song.ItemWeek;
import Song.SwagSong;
import Song.SongStuffManager;
import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomButton;
import states.PlayState.SongListData;
import FlxCustom.FlxUICustomNumericStepper;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class SkinsMenuState extends MusicBeatState {
    public var stage:Stage;
	public var character:Character;
	public var curtains:FlxSprite;

	public var camFollow:FlxObject;

	override function create(){
		FlxG.mouse.visible = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a Skin", null);
		MagicStuff.setWindowTitle('Selecting a Skin');
		#end

        stage = new Stage("Stage", [["Boyfriend", [400, 100], 1, false, "Default", "NORMAL", 0]]);
        add(stage);

		curtains = stage.script.getVariable("stagecurtains");
		character = stage.getCharacterById(0);

        var shape_1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 80, FlxColor.BLACK);
		shape_1.scrollFactor.set(0, 0);
        add(shape_1);

        var shape_2:FlxSprite = new FlxSprite(0, 85).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
		shape_2.scrollFactor.set(0, 0);
        add(shape_2);
		
        var shape_3:FlxSprite = new FlxSprite(0, FlxG.height - 90).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
		shape_3.scrollFactor.set(0, 0);
        stage.stageData.add(shape_3);

        var shape_4:FlxSprite = new FlxSprite(0, FlxG.height - 80).makeGraphic(FlxG.width, 80, FlxColor.BLACK);
		shape_4.scrollFactor.set(0, 0);
        stage.stageData.add(shape_4);

		stage.charge();

		trace(curtains);
		curtains.animation.play("close", true);

		super.create();
        
		camFollow = new FlxObject(character.character_sprite.getGraphicMidpoint().x, character.character_sprite.getGraphicMidpoint().y, 1, 1);
        camGame.follow(camFollow, LOCKON);
		add(camFollow);
	}

	override function update(elapsed:Float){		
		super.update(elapsed);
	}
}
