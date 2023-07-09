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
import flixel.FlxState;
import flixel.FlxG;
import haxe.Json;

import FlxCustom.FlxUICustomNumericStepper;
import states.PlayState.SongListData;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomList;
import Song.SongStuffManager;
import Song.SongPlayer;
import Song.SongsData;
import Song.ItemSong;
import Song.SwagSong;
import MagicStuff;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using SavedFiles;
using StringTools;

class PlayerSelectorState extends MusicBeatState {
	var strum_players:Array<SongPlayer> = [];
	var selSong:SwagSong;
	
	var background:FlxSprite;

	var cursorGroup:FlxTypedGroup<FlxSprite>;
	var charGroup:FlxTypedGroup<Character>;
	var strumGroup:FlxTypedGroup<FlxSprite>;
	
	public function new(_selSong:SwagSong, ?onConfirm:String, ?onBack:String){
		selSong = _selSong;
		super(onConfirm, onBack);
	}

	override function create(){
		super.create();
		
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Selecting', '[Song Selector]');
		MagicStuff.setWindowTitle('Selector', 1);
		#end		

		background = new FlxSprite().loadGraphic(Paths.image('menuBG').getGraphic());
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.scrollFactor.set(0, 0);
        background.color = 0xfffffd75;
		background.screenCenter();
		add(background);

		var playable_strums:Array<Int> = [];
		for(i in 0...selSong.sectionStrums.length){
			if(!selSong.sectionStrums[i].isPlayable){continue;}
			playable_strums.push(i);
		}

		if(playable_strums.length <= 0){MusicBeatState.switchState(onBack, []);}

		var cur_width:Float = 5; 
		strumGroup = new FlxTypedGroup<FlxSprite>();
		charGroup = new FlxTypedGroup<Character>();
		for(i in 0...playable_strums.length){
			var cur_strum = selSong.sectionStrums[playable_strums[i]];
			var new_stage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mini_stage').getGraphic());
			new_stage.setGraphicSize(Std.int((FlxG.width - 20) / playable_strums.length)); new_stage.updateHitbox();
			new_stage.setPosition(cur_width, FlxG.height - (new_stage.height / 2)); cur_width += new_stage.width + 10;

			if(cur_strum.charToSing.length > 0){
				var char_data:Array<Dynamic> = selSong.characters[cur_strum.charToSing[0]];
				var new_char:Character = new Character(0, 0, char_data[0], char_data[4], char_data[5]);
				new_char.c.setGraphicSize(Std.int((new_stage.width / 2) - 10)); new_char.c.updateHitbox();
				new_char.c.setPosition(new_stage.x + (new_stage.width / 2) - (new_char.c.width / 2), new_stage.y - new_char.c.height + 90);
				new_char.turnLook(char_data[3]);
				charGroup.add(new_char);
			}

			strumGroup.add(new_stage);
		}
		add(strumGroup);
		add(charGroup);

		cursorGroup = new FlxTypedGroup<FlxSprite>();
		for(i in 0...PlayerSettings.getNumPlayers()){
			strum_players.push({alive: true, strum: 0});
			var new_cursor:FlxSprite = new FlxSprite(100, 100);
			if(i == 0){new_cursor.loadGraphic(Paths.image("keyboard_icon").getGraphic());}
			else{new_cursor.loadGraphic(Paths.image("controller_icon").getGraphic());}
			new_cursor.setGraphicSize(150); new_cursor.updateHitbox();
			cursorGroup.add(new_cursor);
		}
		add(cursorGroup);
	}

	override function update(elapsed:Float){
		for(i in 0...strum_players.length){
			var cur_cursor = cursorGroup.members[i];
			var cur_grid = strumGroup.members[strum_players[i].strum];
			if(cur_grid != null){MagicStuff.lerpX(cur_cursor, (cur_grid.x + (cur_grid.width / 2) - (cur_cursor.width / 2)));}
		}

		if(canControlle){
			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){goToSong();}
			for(i in 0...PlayerSettings.getNumPlayers()){
				if(PlayerSettings.getPlayer(i).controls.checkAction("Menu_Left", JUST_PRESSED)){changeStrum(i, -1);}
				if(PlayerSettings.getPlayer(i).controls.checkAction("Menu_Right", JUST_PRESSED)){changeStrum(i, 1);}
			}
        }

        super.update(elapsed);		
	}

	function changeStrum(_id:Int, _change:Int):Void {
		var cur_play = strum_players[_id];
		var cur_change = cur_play.strum;
		var new_change = cur_play.strum + _change;

		if(new_change < 0){new_change = strumGroup.members.length -1;}
		if(new_change >= strumGroup.members.length){new_change = 0;}

		for(cur_strum in strum_players){if(cur_strum.strum != _change){continue;} cur_strum.strum = cur_change;}
		cur_play.strum = new_change;
	}

	function goToSong():Void {
		SongListData.loadAndPlaySong(selSong, FlxG.keys.pressed.SHIFT);
		PlayState.strum_players = strum_players;
	}
}