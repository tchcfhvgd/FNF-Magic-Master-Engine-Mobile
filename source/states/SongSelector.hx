package states;

import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import haxe.Json;

import FlxCustom.FlxUICustomNumericStepper;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomList;
import Song.SongStuffManager;
import Song.SongsData;
import Song.ItemSong;
import Song.SwagSong;
import MagicStuff;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class SongSelector extends MusicBeatState {
	override function create(){
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Selecting', '[Song Selector]');
		MagicStuff.setWindowTitle('Selector', 1);
		#end		

		super.create();
	}

	override function update(elapsed:Float){
		if(canControlle){
            
        }

        super.update(elapsed);		
	}
}