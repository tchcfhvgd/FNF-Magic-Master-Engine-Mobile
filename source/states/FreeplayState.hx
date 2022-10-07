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
import Song.SongsData;
import Song.ItemSong;
import Song.ModSongs;
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
	var modList:Array<ModSongs> = [];

	var grpSongs:FlxTypedGroup<Alphabet>;
	var grpMods:FlxTypedGroup<Alphabet>;

	var stage:Stage;
    var camFollow:FlxObject;

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

		modList = Song.getSongModList(); trace(modList);
		for(mod in modList){
			for(song in mod.songs){songList.push(song);}
		}

		stage = new Stage("Stage",[
			["Girlfriend", [400, 130], 1, false, "Default", "GF", 0],
			["Daddy_Dearest", [100, 100], 1, true, "Default", "NORMAL", 0],
			["Boyfriend", [770, 100], 1, false, "Default", "NORMAL", 0]
		]);
		add(stage);
		
		FlxG.camera.zoom = stage.zoom;

		grpSongs = new FlxTypedGroup<Alphabet>();
		for(i in 0...songList.length){
			var songText:Alphabet = new Alphabet(10,0,Paths.getFileName(songList[i].song));
			songText.ID = i;
			if(Highscore.checkLock(songList[i].keyLock)){
				var cText:String = "";
				while(cText.length < songText.text.length){cText = '${cText}?';}
				songText.text = cText; songText.loadText();
			}
			grpSongs.add(songText);
		}
		for(b in grpSongs){b.scrollFactor.set();}
		add(grpSongs);
		
		var gradBox:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 120, [FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT]);
		gradBox.scrollFactor.set();
		add(gradBox);

		grpMods = new FlxTypedGroup<Alphabet>();
		for(i in 0...modList.length){
			var modText:Alphabet = new Alphabet(10,0,Paths.getFileName(modList[i].mod));
			modText.ID = i;
			grpMods.add(modText);
		}
		for(b in grpMods){b.scrollFactor.set();}
		add(grpMods);

		var btnPlay:FlxUIButton = new FlxUICustomButton(0, 0, 300, 100, "PLAY", null, null, function(){chooseSong();});
		btnPlay.setPosition(FlxG.width - btnPlay.width , FlxG.height - btnPlay.height);
		btnPlay.scrollFactor.set();
		add(btnPlay);

		super.create();

        camFollow = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON);
		add(camFollow);

		changeSong();
	}

	override function update(elapsed:Float){
		if(canControlle){
			if(FlxG.mouse.wheel < 0){changeSong(1);}
			if(FlxG.mouse.wheel > 0){changeSong(-1);}

			if(FlxG.mouse.justPressed){
				for(i in 0...stage.character_Length){
					var nChar = stage.getCharacterById(i);
					if(FlxG.mouse.overlaps(nChar)){nChar.playAnim("hey", true);}
				}

				for(btn in grpSongs){if(FlxG.mouse.overlaps(btn)){changeSong(btn.ID, true); break;}}
			}			
		}
		
		if(stage.camP_1 != null && stage.camP_2 != null){
			camFollow.setPosition((stage.camP_1.x + (FlxG.mouse.x * (stage.camP_2.x - stage.camP_1.x) / FlxG.width)), (stage.camP_1.y + (FlxG.mouse.y * (stage.camP_2.y - stage.camP_1.y) / FlxG.height)));
		}

		MagicStuff.sortMembersByY(cast grpSongs, (FlxG.height / 2) - (grpSongs.members[curSong].height / 2), curSong);
		MagicStuff.sortMembersByX(cast grpMods, (FlxG.width / 2) - (grpMods.members[curMod].width / 2), curMod, FlxG.width * 2);

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

		for(i in 0...modList.length){
			var cBreak:Bool = false;
			for(song in modList[i].songs){if(songList[curSong].song == song.song){curMod = i; cBreak = true; break;}}
			if(cBreak){break;}
		}
	}

	public function chooseSong():Void {
		var songInput:String = Song.fileSong(songList[curSong].song, "Normal", "Hard");
		var songdata:SwagSong = Song.loadFromJson(songInput);
		SongListData.playSong(songdata);
	}
}