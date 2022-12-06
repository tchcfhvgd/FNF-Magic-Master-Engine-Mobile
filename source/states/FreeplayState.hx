package states;

import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxGradient;
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
import states.PlayState.SongListData;
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

class FreeplayState extends MusicBeatState {
	var songList:Array<ItemSong> = [];

	var grpSongs:FlxTypedGroup<Alphabet>;

	var curMod:Int = 0;
	var curSong:Int = 0;
	var curDiff:String = "";
	var curCat:String = "";

	override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Selecting', '[Freeplay]');
		MagicStuff.setWindowTitle('Freeplay', 1);
		#end

		songList = SongStuffManager.getSongList();

        var bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.color = FlxColor.GRAY;
		bg.screenCenter();
		add(bg);
		
		grpSongs = new FlxTypedGroup<Alphabet>();
		for(i in 0...songList.length){
			var songText:Alphabet = new Alphabet(10,0,Paths.getFileName(songList[i].song));

			if(Highscore.checkLock(songList[i].keyLock)){
				var cText:String = "";
				while(cText.length < songText.text.length){cText = '${cText}?';}
				songText.text = cText; songText.loadText();
			}

			songText.scrollFactor.set();
			songText.ID = i;
			
			grpSongs.add(songText);
		}
		add(grpSongs);
		
		var btnPlay:FlxUIButton = new FlxUICustomButton(0, 0, 300, 100, "PLAY", null, null, function(){chooseSong();});
		btnPlay.setPosition(FlxG.width - btnPlay.width , FlxG.height - btnPlay.height);
		btnPlay.scrollFactor.set();
		add(btnPlay);

		super.create();

		changeSong();
	}

	override function update(elapsed:Float){
		if(canControlle){
			if(FlxG.mouse.wheel < 0){changeSong(1);}
			if(FlxG.mouse.wheel > 0){changeSong(-1);}

			if(FlxG.mouse.justPressed){
				for(btn in grpSongs){if(FlxG.mouse.overlaps(btn)){changeSong(btn.ID, true); break;}}
			}
		}
		
		MagicStuff.sortMembersByY(cast grpSongs, (FlxG.height / 2) - (grpSongs.members[curSong].height / 2), curSong);
		
		super.update(elapsed);		
	}
	
	public function changeSong(change:Int = 0, force:Bool = false):Void {
		curSong += change; if(force){curSong = change;}

		if(curSong < 0){curSong = songList.length - 1;}
		if(curSong >= songList.length){curSong = 0;}

		for(i in 0...grpSongs.members.length){
			grpSongs.members[i].alpha = 0.5;
			if(i == curSong){grpSongs.members[i].alpha = 1;}
		}
	}

	public function chooseSong():Void {
		var songInput:String = Song.fileSong(songList[curSong].song, "Normal", "Hard");
		var songdata:SwagSong = Song.loadFromJson(songInput);
		SongListData.loadAndPlaySong(songdata);
	}
}