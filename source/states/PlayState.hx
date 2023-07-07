package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.editors.tiled.TiledMap;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.atlas.FlxAtlas;
import flixel.system.FlxSoundGroup;
import substates.MusicBeatSubstate;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.util.FlxStringUtil;
import flixel.util.FlxCollision;
import openfl.display.BlendMode;
import substates.PauseSubState;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import flixel.text.FlxText;
import flixel.FlxSubState;
import lime.utils.Assets;
import sys.thread.Thread;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxGame;
import flixel.FlxG;
import haxe.Timer;
import haxe.Json;

import StrumLine;
import Note.Note;
import DialogueBox;
import Song.SwagSong;
import Song.ItemWeek;
import Note.StrumNote;
import Note.EventData;
import Song.SongPlayer;
import Song.SwagSection;
import Song.SongStuffManager;

#if desktop
import Discord.DiscordClient;
#end

using SavedFiles;
using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var strum_players:Array<SongPlayer> = null;

    public var curSection(get, never):Int;
	inline function get_curSection():Int{return Std.int(conductor.getCurStep() / 16);}

	//Audio
	public var inst:FlxSound;
	public var voices:FlxSoundGroup;

	//Strumlines
	public var strumsGroup:FlxTypedGroup<StrumLine>;
	public var strumLeftPos:Float = 50;
	public var strumMiddlePos:Float = FlxG.width / 2;
	public var strumRightPos:Float = FlxG.width - 50;

	//Song Stats
	public var song_Length:Float = 0;
	public var song_Time:Float = 0;
	
	//PreSettings Variables
	public var pre_OnlyNotes:Bool = PreSettings.getPreSetting("Only Notes", "Graphic Settings");
	public var pre_TypeMiddle:String = PreSettings.getPreSetting("Type Middle Scroll", "Visual Settings");
	public var pre_DefaultNonPos:String = PreSettings.getPreSetting("Default Strum Position", "Visual Settings");
	public var pre_TypeScroll:String = PreSettings.getPreSetting("Type Scroll", "Visual Settings");

	//Gameplay Style
	public var uiStyleCheck:String = 'Default';

	private static var prevCamFollow:FlxObject;
	
	// Gameplay Bools
	public var followChar:Bool = true;
	public var moveStrums:Bool = true;

	//Other
	private var songGenerated:Bool = false;
	private var songPlaying:Bool = false;
	public var canPause:Bool = false;
	public var isPaused:Bool = false;
	public var onGameOver:Bool = false;
	
	public var introAssets:Array<{asset:String, sound:String}> = [{asset:null, sound: 'intro3'}, {asset:'ready', sound: 'intro2'}, {asset:'set', sound: 'intro1'}, {asset:'go', sound: 'introGo'}];
	public function startCountdown(onComplete:Void->Void = null):Void {
		var swagCounter:Int = 0;
		timers.push(new FlxTimer().start(conductor.crochet / 1000, function(tmr:FlxTimer){
			if(introAssets[swagCounter] != null){
				if(introAssets[swagCounter].sound != null){FlxG.sound.play(Paths.styleSound(introAssets[swagCounter].sound, uiStyleCheck).getSound(), 0.6);}
			
				if(introAssets[swagCounter].asset != null){
					var iAssets:FlxSprite = new FlxSprite().loadGraphic(Paths.styleImage(introAssets[swagCounter].asset, uiStyleCheck).getGraphic());
					iAssets.scrollFactor.set();
					iAssets.updateHitbox();
					iAssets.screenCenter();
					add(iAssets);

					FlxTween.tween(iAssets, {y: iAssets.y += 100, alpha: 0}, conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){iAssets.kill();}});
				}
			}

			if(swagCounter == introAssets.length){if(onComplete != null){onComplete();}}

			swagCounter++;
		}, introAssets.length + 1));
	}

	public var timers:Array<FlxTimer> = [];
	
	public var stage:Stage;

    public var camFollow:FlxObject;

	override public function create(){
		super.create();

		FlxG.mouse.visible = false;
		
		persistentUpdate = true;
		persistentDraw = true;

		StrumLine.GLOBAL_VARIABLES = {};

		if(SongListData.songPlaylist.length > 0){
			SONG = SongListData.songPlaylist[0];
		}else{
			SONG = Song.loadFromJson('Tutorial-Normal-Normal');
		}
		
		uiStyleCheck = SONG.uiStyle;

		if(!pre_OnlyNotes){
			stage = new Stage(SONG.stage, SONG.characters);
			add(stage);
		
			FlxG.camera.zoom = stage.zoom;
		}

		conductor.songPosition = -5000;

		strumsGroup = new FlxTypedGroup<StrumLine>();
		strumsGroup.cameras = [camHUD];
		add(strumsGroup);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
			
        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		if (prevCamFollow != null){
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		add(camFollow);

		if(strum_players == null){Song.setPlayersByChart(SONG);}
		for(s in strum_players){s.alive = true;}

		generateSong(function(){
			conductor.songPosition = -(conductor.crochet * (introAssets.length + 1));
			songPlaying = true;

			startCountdown(startSong);
		});
	}

	private var loadedStrums:Int = 0;
	private function generateSong(toEndFun:Void->Void):Void {
		var songData = SONG;

		conductor.changeBPM(songData.bpm);
		conductor.mapBPMChanges(songData);

		//Loading Instrumental
		inst = new FlxSound().loadEmbedded(Paths.inst(songData.song, songData.category).getSound(), false, false, endSong);
		inst.looped = false;
		inst.onComplete = endSong.bind();
		FlxG.sound.list.add(inst);

		//Loading Voices
		voices = new FlxSoundGroup();		
		voices.sounds = [];

		if(songData.hasVoices){
            for(i in 0...songData.characters.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, songData.characters[i][0], songData.song, songData.category).getSound());
                FlxG.sound.list.add(voice);
                voices.add(voice);
            }
        }else{
            var voice = new FlxSound();
            FlxG.sound.list.add(voice);
            voices.add(voice);
        }

		//Loading Strumlines
		for(i in 0...songData.sectionStrums.length){
			var strumLine = new StrumLine(0, 0, songData.sectionStrums[i].keys, Std.int(FlxG.width / 3) - 40, principal_controls, null, songData.sectionStrums[i].noteStyle);

			strumLine.onHIT = function(note:Note){
				if(stage == null){return;}
				var focus:Bool = false;
				
				var song_animation:String = note.singAnimation;
				if(strumLine.swagStrum.notes[strumLine.curSection] != null && strumLine.swagStrum.notes[strumLine.curSection].altAnim){song_animation += '-alt';}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){
					var new_character:Character = stage.getCharacterById(ii);
					
					new_character.playAnim(song_animation, true);

					if(!focus){
						if(strumLine.typeStrum == "Playing"){StrumLine.GLOBAL_VARIABLES.Player = new_character;}
						else{StrumLine.GLOBAL_VARIABLES.Enemy = new_character;}
						strumLine.LOCAL_VARIABLES.Player = new_character;
						focus = true;
					}
				}
			};

			strumLine.onMISS = function(note:Note){
				if(stage == null){return;}
				var focus:Bool = false;
				
				var song_animation:String = '${note.singAnimation}miss';
				if(strumLine.swagStrum.notes[strumLine.curSection] != null && strumLine.swagStrum.notes[strumLine.curSection].altAnim){song_animation += '-alt';}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){
					var new_character:Character = stage.getCharacterById(ii);
					new_character.playAnim(song_animation, true);

					if(!focus){
						if(strumLine.typeStrum == "Playing"){StrumLine.GLOBAL_VARIABLES.Player = new_character;}
						else{StrumLine.GLOBAL_VARIABLES.Enemy = new_character;}
						strumLine.LOCAL_VARIABLES.Player = new_character;
						focus = true;
					}
				}

				for(i in 0...stage.character_Length){
					var cur_character:Character = stage.getCharacterById(i);
					if(cur_character.curType != "Girlfriend"){continue;}
					cur_character.playAnim('sad', true);
				}
			};

			strumLine.ui_style = uiStyleCheck;

			strumLine.scrollSpeed = songData.speed;
			strumLine.strumConductor = conductor;
			strumLine.bpm = songData.bpm;
			
			strumLine.x = (FlxG.width / 2) - (strumLine.genWidth / 2);
			strumLine.y = -strumLine.genHeight*2;
			strumLine.alpha = 0;

			strumLine.loadStrumNotes(songData.sectionStrums[i]);
			strumLine.ID = i;

			strumsGroup.add(strumLine);
		}

		for(i in 0...strum_players.length){
			var player_strum:Int = strum_players[i].strum;
			var cur_strum:StrumLine = strumsGroup.members[player_strum];

			if(cur_strum == null){continue;}

			cur_strum.player = i;

			if(strum_players.length > 1){
				cur_strum.controls = PlayerSettings.getPlayer(i).controls;
				cur_strum.load_solo_ui();
				cur_strum.onGAME_OVER = function(){
					cur_strum.LOCAL_VARIABLES.set("GameOver", true);
					strum_players[i].alive = false;
					cur_strum.changeTypeStrum("BotPlay");

					var canGAMEOVER:Bool = true;
					for(sp in strum_players){if(sp.alive){canGAMEOVER = false;}}
					if(canGAMEOVER){doGameOver(player_strum);}
				}
			}else{
				cur_strum.load_global_ui();
				cur_strum.onGAME_OVER = function(){doGameOver(player_strum);}
			}
		}

		for(s in scripts){s.exFunction('preload');}

		songGenerated = true;

		var song_script:Script = Script.getScript("ScriptSong");
		if(song_script != null && song_script.exFunction("startSong", [toEndFun])){return;}
		toEndFun();
	}
	
	var previousFrameTime:Int = 0;
	function startSong():Void{	
		previousFrameTime = FlxG.game.ticks;
		
		conductor.songPosition = 0;

		inst.play(true);
		for(sound in voices.sounds){sound.play(true);}
		
		for(s_player in strum_players){strumsGroup.members[s_player.strum].changeTypeStrum("Playing");}
		
		#if desktops
		// Song duration in a float, useful for the time left feature
		song_Length = inst.length;
		#end
		
		canPause = true;
		resyncVocals();
		
		for(s in scripts){s.exFunction('song_started');}
	}

	var last_conductor:Float = -10000;
	function resyncVocals():Void{
		if(!songPlaying){return;}

		for(sound in voices.sounds){sound.pause();}
	
		inst.play();
		conductor.songPosition = inst.time;
		for(sound in voices.sounds){
			sound.time = conductor.songPosition;
			sound.play();
		}

		if(conductor.songPosition < last_conductor){endSong();}
		last_conductor = conductor.songPosition;
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		if(FlxG.keys.justPressed.T){trace('${conductor.songPosition} [${inst.time}] / ${inst.length}');}

		checkEvents();

		if(canControlle){	
			if(principal_controls.checkAction("Menu_Pause", JUST_PRESSED) && canPause){
				for(s in strumsGroup){s.changeTypeStrum("BotPlay");}
				pauseAndOpen(
					"substates.PauseSubState",
					[
						function(){
							if(!songGenerated){isPaused = false; pauseSong(false); return;}
							startCountdown(function(){
								for(s_player in strum_players){if(!s_player.alive){continue;} strumsGroup.members[s_player.strum].changeTypeStrum("Playing");}
								persistentUpdate = false;
								persistentDraw = true;
								canControlle = true;
								isPaused = false;
								pauseSong(false);
							});
						}
					],
					true
				);
			}
			if(FlxG.keys.justPressed.SEVEN){
				states.editors.ChartEditorState._song = SONG;
				MusicBeatState.switchState("states.editors.ChartEditorState", []);
			}
			
			if(FlxG.keys.justPressed.R){doGameOver(strum_players[0].strum);}
		}

		if(songPlaying){			
			// conductor.songPosition = inst.time;
			conductor.songPosition += FlxG.elapsed * 1000;
	
			if(!isPaused){
				song_Time += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
	
				// Interpolation type beat
				if(conductor.lastSongPos != conductor.songPosition){
					song_Time = (song_Time + conductor.songPosition) / 2;
					conductor.lastSongPos = conductor.songPosition;
					// conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}	
			// conductor.lastSongPos = inst.time;
		}

		if(songGenerated && SONG.generalSection[curSection] != null){
			if(moveStrums){
				var used_strums:Array<Bool> = [false, false, false];
				var id_strums:Array<Int> = []; 
				for(s_player in strum_players){id_strums.push(s_player.strum);}
				for(i in 0...strumsGroup.length){if(id_strums.contains(i)){continue;} id_strums.push(i);}

				for(i in id_strums){
					var curStrumLine = strumsGroup.members[i];
					var strum_character:Character = null;
					if(!pre_OnlyNotes){strum_character = stage.getCharacterById(Character.getFocusCharID(SONG, curSection, i));}
					var curStrumPosX:String = "";
					
					var newStrumLineX:Float = strumLeftPos;
					var newStrumLineY:Float = 30; if(pre_TypeScroll == "DownScroll"){newStrumLineY = FlxG.height - curStrumLine.genHeight - 30;}
					var newStrumLineAlpha:Float = 1;	
					
					var setSide = function(_initSide:String):Void {
						switch(_initSide){
							case "Left":{
								if(!used_strums[0]){newStrumLineX = strumLeftPos; used_strums[0] = true;}else
								if(!used_strums[2]){newStrumLineX = strumRightPos - curStrumLine.genWidth; used_strums[2] = true;}else
								if(!used_strums[1]){newStrumLineX = strumMiddlePos - (curStrumLine.genWidth / 2); used_strums[1] = true;}
								else{newStrumLineAlpha = 0;}
							}
							case "Middle":{
								if(!used_strums[1]){newStrumLineX = strumMiddlePos - (curStrumLine.genWidth / 2); used_strums[1] = true;}else
								if(!used_strums[2]){newStrumLineX = strumRightPos - curStrumLine.genWidth; used_strums[2] = true;}else
								if(!used_strums[0]){newStrumLineX = strumLeftPos; used_strums[0] = true;}
								else{newStrumLineAlpha = 0;}
							}
							case "Right":{
								if(!used_strums[2]){newStrumLineX = strumRightPos - curStrumLine.genWidth; used_strums[2] = true;}else
								if(!used_strums[0]){newStrumLineX = strumLeftPos; used_strums[0] = true;}else
								if(!used_strums[1]){newStrumLineX = strumMiddlePos - (curStrumLine.genWidth / 2); used_strums[1] = true;}
								else{newStrumLineAlpha = 0;}
							}
						}
					};

					var isPlayer:Bool = false; for(s_player in strum_players){if(s_player.strum == i){isPlayer = true;}}
					var toSet:String = "";

					if(isPlayer){
						if(strum_character == null){toSet = pre_DefaultNonPos;
						}else{
							if(pre_TypeMiddle != "None"){toSet = "Middle";}
							else{toSet = strum_character.onRight ? "Left" : "Right";}
						}		
					}else{
						if(pre_TypeMiddle == "OnlyPlayer"){newStrumLineAlpha = 0;}
						if(pre_TypeMiddle == "FadeOthers"){newStrumLineAlpha = 0.3;}
						if(strum_character != null){toSet = strum_character.onRight ? "Left" : "Right";}
						if(!SONG.sectionStrums[i].isPlayable){newStrumLineAlpha = 0;}
					}
					setSide(toSet);
					
					curStrumLine.y = FlxMath.lerp(curStrumLine.y, newStrumLineY, 0.1);
					curStrumLine.x = FlxMath.lerp(curStrumLine.x, newStrumLineX, 0.1);
					curStrumLine.alpha = FlxMath.lerp(curStrumLine.alpha, newStrumLineAlpha, 0.1);
				}
			}
						
			if(!pre_OnlyNotes){
				if(followChar){Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(SONG, curSection)), camFollow);}
			}			
		}

		if(stage != null){
			if(stage.camP_1 != null){
				if(camFollow.x < stage.camP_1[0]){camFollow.x = stage.camP_1[0];}
				if(camFollow.y < stage.camP_1[1]){camFollow.y = stage.camP_1[1];}
			}
			if(stage.camP_2 != null){
				if(camFollow.x > stage.camP_2[0]){camFollow.x = stage.camP_2[0];}
				if(camFollow.y > stage.camP_2[1]){camFollow.y = stage.camP_2[1];}
			}
		}
	}

	private var exEvents:Array<Dynamic> = [];
	function checkEvents(){
		if(!songGenerated || PlayState.SONG.generalSection[curSection] == null || PlayState.SONG.generalSection[curSection].events.length <= 0){return;}
		var sEvents:Array<Dynamic> = SONG.generalSection[curSection].events;
		for(event in sEvents.copy()){
			var cur_Event:EventData = Note.getEventData(event);
			if(conductor.songPosition > cur_Event.strumTime && !cur_Event.isBroken && !exEvents.contains(event)){
				exEvents.push(event);
				for(e in cur_Event.eventData.copy()){
					var _args = cast(e[1],Array<Dynamic>).copy();
					var _srp = Script.getScript(e[0]);
					if(_srp == null){continue;}
					_srp.exFunction("execute", cast _args);
				}
			}
		}
	}

	var songEnded:Bool = false;
	function endSong():Void {
		if(songEnded){return;}
		songEnded = true;

		var toEndFun:Void->Void = function (){
			for(s in scripts){s.exFunction('song_ended');}
			
			if(SongListData.songPlaylist.length <= 0){
				SongListData.resetVariables();
				if(states.PlayState.isStoryMode){states.MusicBeatState.switchState("states.MainMenuState", []);}
				else{states.MusicBeatState.switchState("states.FreeplayState", [null, "states.MainMenuState"]);}
			}else{
				trace('LOADING NEXT SONG');
	
				prevCamFollow = camFollow;
	
				SongListData.playSong();
			}
		};

		trace("End Song");

		canPause = false;
		isPaused = true;
		songPlaying = false;
		moveStrums = false;

		inst.stop();
		for(sound in voices.sounds){sound.stop();}

		var song_score:Int = 0;
		for(s_player in strum_players){song_score += strumsGroup.members[s_player.strum].STATS.Score;}

		if(SONG.validScore){Highscore.saveSongScore(Paths.getFileName(SONG.song, true), song_score, SONG.difficulty, SONG.category);}

		SongListData.nextSong(song_score);

		if(SONG.validScore && SongListData.songPlaylist.length <= 0){
			NGio.unlockMedal(60961);
			Highscore.saveWeekScore(SongListData.weekName, SongListData.campScore, SONG.difficulty, SONG.category);
		}

		var song_script:Script = Script.getScript("ScriptSong");
		if(song_script != null && song_script.exFunction("endSong", [toEndFun])){return;}
		
		toEndFun();
	}

	public function pauseSong(pause:Bool = true){
		songPlaying = !pause;

		if(!songPlaying){
			if(inst != null){
				inst.pause();
				for(sound in voices.sounds){sound.pause();}
			}
			for(timer in timers){if(!timer.finished){timer.active = false;}}
		}else{
			if(songGenerated && inst != null){resyncVocals();}	
			for(timer in timers){if(!timer.finished){timer.active = true;}}
		}
	}

	public function pauseAndOpen(substate:String, args:Array<Dynamic>, hasEasterEgg:Bool = false, per_update:Bool = false, per_draw:Bool = true){
		if(isPaused){return;}
		persistentUpdate = per_update;
		persistentDraw = per_draw;
		isPaused = true;

		pauseSong();

		// 1 / 1000 chance for Gitaroo Man easter egg
		if(hasEasterEgg && FlxG.random.bool(0.1)){
			trace('GITAROO MAN EASTER EGG');
			MusicBeatState.switchState("GitarooPause", []);
		}else{
			canControlle = false;
			loadSubState(substate, args);
		}
	}

	function doGameOver(_player:Int):Void {
		onGameOver = true;
		camHUD.visible = false;
		
		var chars:Array<Character> = [];
		var char:Array<Int> = SONG.sectionStrums[_player].charToSing;
		if(SONG.sectionStrums[_player].notes[curSection].changeSing){char = SONG.sectionStrums[0].notes[curSection].charToSing;}
		for(i in char){chars.push(stage.getCharacterById(i)); stage.getCharacterById(i).visible = false;}

		pauseAndOpen("substates.GameOverSubstate", [chars, uiStyleCheck], false, false);
	}

	override public function onFocusLost():Void {
		super.onFocusLost();

		if(!songPlaying){return;}

		pauseAndOpen(
			"substates.PauseSubState",
			[
				function(){
					startCountdown(function(){
						persistentUpdate = false;
						persistentDraw = true;
						canControlle = true;
						isPaused = false;
						pauseSong(false);
					});
				}
			],
			true
		);
}

	override function stepHit(){
		super.stepHit();
		
		if(songPlaying && inst.time > conductor.songPosition + 20 || inst.time < conductor.songPosition - 20){resyncVocals();}
		
		//trace('${inst.time} / ${inst.length}');
	}

	override function beatHit(){
		super.beatHit();

		if(SONG.generalSection[curSection] != null){
			if(SONG.generalSection[curSection].changeBPM){
				conductor.changeBPM(SONG.generalSection[curSection].bpm);
				FlxG.log.add('CHANGED BPM!');
				trace('Changed BPM');
			}
		}
	}
}

class SongListData {
	public static var onNext:Void->Void;
	public static var onFinish:Void->Void;

	public static var weekName:String = "PlaceHolderWeek";
	public static var weekDisplay:String = "PlaceHolderWeek";

	public static var songPlaylist:Array<SwagSong> = [];

	public static var campScore:Int = 0;

	public static function loadWeek(week:ItemWeek, category:String = "Normal", difficulty:String = "Normal"):Void {
		if(!SongStuffManager.hasCatAndDiff(week, category, difficulty)){return;}
		
		weekName = week.name;
		weekDisplay = week.display;

		for(song in week.songs){
			trace(Song.fileSong(song, category, difficulty));
			var songToPlay:SwagSong = Song.loadFromJson(Song.fileSong(song, category, difficulty));
			songPlaylist.push(songToPlay);
		}
	}

	public static function addSongs(songList:Array<SwagSong>){for(song in songList){songPlaylist.push(song);}}
	public static function addSong(song:SwagSong){songPlaylist.push(song);}

	public static function playSong(_isStoryMode:Bool = true):Void {
		PlayState.isStoryMode = _isStoryMode;
		MusicBeatState.loadState("states.PlayState", [], [[{type:"SONG", instance:songPlaylist[0]}], false]);
	}

	public static function loadAndPlaySong(SONG:SwagSong, _isStoryMode:Bool = false):Void {
		PlayState.isStoryMode = _isStoryMode;

		resetVariables();
		songPlaylist.push(SONG);

		MusicBeatState.loadState("states.PlayState", [], [[{type:"SONG", instance:SONG}], false]);
	}
	
	public static function nextSong(score){
		PlayState.strum_players = null;

		campScore += score;
		songPlaylist.shift();
	}

	public static function resetVariables(){
		PlayState.strum_players = null;

		songPlaylist = [];
		campScore = 0;
	}
}