package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
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
import Song.SwagSong;
import Song.ItemWeek;
import Note.StrumNote;
import Note.EventData;
import Song.SwagSection;
import Song.SongStuffManager;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var playablesStrums:Array<Int> = [1];

    public var curSection(get, never):Int;
	inline function get_curSection():Int{return Std.int(conductor.getCurStep() / 16);}

	//Audio
	public var inst:FlxSound;
	public var voices:FlxSoundGroup;

	//Strumlines
	public var strumsGroup:FlxTypedGroup<StrumLine>;
	public var strumLeftPos:Float = 100;
	public var strumMiddlePos:Float = FlxG.width / 2;
	public var strumRightPos:Float = FlxG.width - 100;
	public var moveStrums:Bool = true;

	//Song Stats
	var song_Length:Float = 0;
	var song_Time:Float = 0;
	
	//PreSettings Variables
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay", "Cheating Settings");
	var pre_OnlyNotes:Bool = PreSettings.getPreSetting("Only Notes", "Graphic Settings");
	var pre_TypeMiddle:String = PreSettings.getPreSetting("Type Middle Scroll", "Visual Settings");
	var pre_DefaultNonPos:String = PreSettings.getPreSetting("Default Strum Position", "Visual Settings");
	var pre_TypeScroll:String = PreSettings.getPreSetting("Type Scroll", "Visual Settings");

	//Gameplay Style
	var uiStyleCheck:String = 'Default';

	private static var prevCamFollow:FlxObject;
	public var followChar:Bool = true;

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
				if(introAssets[swagCounter].sound != null){FlxG.sound.play(Paths.sound(introAssets[swagCounter].sound), 0.6);}
			
				if(introAssets[swagCounter].asset != null){
					var iAssets:FlxSprite = new FlxSprite().loadGraphic(Paths.styleImage(introAssets[swagCounter].asset, uiStyleCheck));
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

		//Audio Stuff
		voices = new FlxSoundGroup();
		inst = new FlxSound();
		FlxG.sound.list.add(inst);

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
		camFollow.setPosition(0, 0);
		if (prevCamFollow != null){
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		add(camFollow);

		generateSong(
			function(){
				if(SongListData.isStoryMode){
					switch(SONG.song){
						default:{startCountdown(startSong);}
					}
				}else{
					switch(SONG.song){
						default:{startCountdown(startSong);}
					}
				}
			}
		);
	}

	private var loadedStrums:Int = 0;
	private function generateSong(toEndFun:Void->Void):Void {
		var songData = SONG;

		conductor.changeBPM(songData.bpm);
		conductor.mapBPMChanges(songData);

		//Loading Instrumental
		inst.loadEmbedded(Paths.inst(songData.song, songData.category), false);

		//Loading Voices
		voices.sounds = [];
		if(songData.hasVoices){
            for(i in 0...songData.characters.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, songData.characters[i][0], songData.song, songData.category));
                FlxG.sound.list.add(voice);
                voices.add(voice);
            }
        }else{
            var voice = new FlxSound();
            FlxG.sound.list.add(voice);
            voices.add(voice);
        }

		var strumsloaded:Int = songData.sectionStrums.length;
		for(i in 0...songData.sectionStrums.length){
			var strumLine = new StrumLine(0, 0, songData.sectionStrums[i].keys, Std.int(FlxG.width / 3), principal_controls, null, songData.sectionStrums[i].noteStyle);

			strumLine.onHIT = function(note:Note){
				var focus:Bool = false;
				
				var song_animation:String = note.singAnimation;
				if(strumLine.swagStrum.notes[strumLine.curSection] != null && strumLine.swagStrum.notes[strumLine.curSection].altAnim){song_animation += '-alt';}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){
					var new_character:Character = stage.getCharacterById(ii);
					
					new_character.playAnim(song_animation, true);

					if(!focus){
						StrumLine.GLOBAL_VARIABLES[strumLine.typeStrum == "Playing" ? "Player" : "Enemy"] = new_character;
						strumLine.LOCAL_VARIABLES["Player"] = new_character;
						focus = true;
					}
				}
			};

			strumLine.onMISS = function(note:Note){
				var focus:Bool = false;
				
				var song_animation:String = '${note.singAnimation}miss';
				if(strumLine.swagStrum.notes[strumLine.curSection] != null && strumLine.swagStrum.notes[strumLine.curSection].altAnim){song_animation += '-alt';}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){
					var new_character:Character = stage.getCharacterById(ii);
					new_character.playAnim(song_animation, true);

					if(!focus){
						StrumLine.GLOBAL_VARIABLES[strumLine.typeStrum == "Playing" ? "Player" : "Enemy"] = new_character;
						strumLine.LOCAL_VARIABLES["Player"] = new_character;
						focus = true;
					}
				}
			};

			if(playablesStrums.contains(i)){
				for(pi in 0...playablesStrums.length){
					if(playablesStrums[pi] == i){strumLine.player = pi;}
					break;
				}

				if(playablesStrums.length > 1){
					strumLine.onGAME_OVER = function(){strumLine.changeTypeStrum("BotPlay");}
				}else{
					strumLine.onGAME_OVER = function(){doGameOver();}
				}
			}

			strumLine.scrollSpeed = songData.speed;
			strumLine.strumConductor = conductor;
			strumLine.bpm = songData.bpm;
			
			strumLine.x = (FlxG.width / 2) - (strumLine.genWidth / 2);
			strumLine.y = -strumLine.genHeight*2;
			strumLine.alpha = 0;

			strumLine.loadStrumNotes(songData.sectionStrums[i]);
			strumLine.ID = i;

			if(playablesStrums.contains(i)){
				if(playablesStrums.length > 1){
					strumLine.load_solo_ui();
				}else{
					strumLine.load_global_ui();
				}
			}

			strumsGroup.add(strumLine);
		}
		
		for(s in scripts){s.exFunction('preload');}

		songGenerated = true;

		var song_script:Script = Script.getScript("ScriptSong");
		if(song_script != null){
			song_script.exFunction("startSong", [toEndFun]);
			if(song_script.getVariable("startCountdown")){return;}
		}

		toEndFun();
	}
	
	var previousFrameTime:Int = 0;
	function startSong():Void{	
		previousFrameTime = FlxG.game.ticks;
		
		conductor.songPosition = 0;

		inst.onComplete = endSong;

		inst.play(true);
		for(sound in voices.sounds){sound.play(true);}
		songPlaying = true;
		
		for(i in playablesStrums){strumsGroup.members[i].changeTypeStrum("Playing");}
		
		#if desktop
		// Song duration in a float, useful for the time left feature
		song_Length = inst.length;
		#end
		
		canPause = true;
		resyncVocals();
	}

	function resyncVocals():Void{
		if(!songPlaying){return;}

		inst.pause();
		for(sound in voices.sounds){sound.pause();}
	
		conductor.songPosition = inst.time;
		inst.play();
	
		for(sound in voices.sounds){
			sound.time = conductor.songPosition;
			sound.play();
		}
	}

	var curStrumLinePos:String = "";
	override public function update(elapsed:Float){
		super.update(elapsed);

		checkEvents();

		if(canControlle){	
			if(principal_controls.checkAction("Menu_Pause", JUST_PRESSED) && canPause){
				pauseAndOpen(
					PauseSubState,
					[
						function(){
							if(!songGenerated){isPaused = false; pauseSong(false); return;}
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
			if(FlxG.keys.justPressed.SEVEN){states.editors.ChartEditorState._song = SONG; MusicBeatState.switchState(new states.editors.ChartEditorState(null, PlayState));}
			
			if(FlxG.keys.justPressed.R){doGameOver();}
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

		if(!pre_OnlyNotes){
			if(songGenerated && PlayState.SONG.generalSection[curSection] != null){
				for(i in 0...strumsGroup.length){
					var curStrumLine = strumsGroup.members[i];
					var strumPlayer:Character = stage.getCharacterById(Character.getFocusCharID(SONG, curSection, i));
					var curStrumPosX:String = "";
					
					var newStrumLineX:Float = strumLeftPos;
					var newStrumLineY:Float = 30; if(pre_TypeScroll == "DownScroll"){newStrumLineY = FlxG.height - curStrumLine.genHeight - 30;}
					var newStrumLineAlpha:Float = 1;					

					if(playablesStrums.contains(i)){
						if(strumPlayer == null){
							switch(pre_DefaultNonPos){
								case "Left":{newStrumLineX = strumLeftPos; curStrumLinePos = "Left";}
								case "Middle":{newStrumLineX = strumMiddlePos - (curStrumLine.genWidth/2); curStrumLinePos = "Middle";}
								case "Right":{newStrumLineX = strumRightPos - curStrumLine.genWidth; curStrumLinePos = "Right";}
							}
						}else{
							if(pre_TypeMiddle != "None"){
								newStrumLineX = strumMiddlePos - (curStrumLine.genWidth/2); curStrumLinePos = "Middle";
							}else{
								newStrumLineX = strumPlayer.onRight ? (strumLeftPos) : (strumRightPos - curStrumLine.genWidth);
								curStrumLinePos = strumPlayer.onRight ? "Left" : "Right";
							}
						}						
					}else{
						newStrumLineX = strumPlayer.onRight ? (strumLeftPos) : (strumRightPos - curStrumLine.genWidth);
						curStrumPosX = strumPlayer.onRight ? "Left" : "Right";

						if(pre_TypeMiddle == "OnlyPlayer"){newStrumLineAlpha = 0;}
						if(pre_TypeMiddle == "FadeOthers"){newStrumLineAlpha = 0.3;}
					}
					
					curStrumLine.y = FlxMath.lerp(curStrumLine.y, newStrumLineY, 0.1);
					curStrumLine.x = FlxMath.lerp(curStrumLine.x, newStrumLineX, 0.1);
					curStrumLine.alpha = FlxMath.lerp(curStrumLine.alpha, newStrumLineAlpha, 0.1);
				}
				// CHARACTER CAMERA
				if(followChar){Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(SONG, curSection)), camFollow);}
			}
		}

		if(stage.camP_1 != null){
			if(camFollow.x < stage.camP_1[0]){camFollow.x = stage.camP_1[0];}
			if(camFollow.y < stage.camP_1[1]){camFollow.y = stage.camP_1[1];}
		}
		if(stage.camP_2 != null){
			if(camFollow.x > stage.camP_2[0]){camFollow.x = stage.camP_2[0];}
			if(camFollow.y > stage.camP_2[1]){camFollow.y = stage.camP_2[1];}
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

	function endSong():Void{
		trace("End Song");
		canPause = false;
		isPaused = true;
		songPlaying = false;

		inst.stop();
		for(sound in voices.sounds){sound.stop();}

		var song_score:Int = 0;
		for(i in playablesStrums){song_score += strumsGroup.members[i].STATS.get("Score");}

		if(SONG.validScore){Highscore.saveSongScore(SONG.song, song_score, SONG.difficulty, SONG.category);}

		SongListData.nextSong(song_score);

		if(SongListData.songPlaylist.length <= 0){
			if(SONG.validScore){
				NGio.unlockMedal(60961);
				Highscore.saveWeekScore(SongListData.weekName, SongListData.campScore, SONG.difficulty, SONG.category);
			}

			SongListData.resetVariables();
			MusicBeatState.switchState(new states.MainMenuState());
		}else{
			trace('LOADING NEXT SONG');

			prevCamFollow = camFollow;

			SongListData.playSong();
		}
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

	public function pauseAndOpen(substate:Class<FlxSubState>, args:Array<Dynamic>, hasEasterEgg:Bool = false, reDraw = true){
		if(isPaused){return;}
		if(reDraw){
			persistentUpdate = false;
			persistentDraw = true;
		}
		isPaused = true;

		pauseSong();

		// 1 / 1000 chance for Gitaroo Man easter egg
		if(hasEasterEgg && FlxG.random.bool(0.1)){
			trace('GITAROO MAN EASTER EGG');
			MusicBeatState.switchState(new GitarooPause());
		}else{
			canControlle = false;
			openSubState(Type.createInstance(substate, args));
		}
	}

	function doGameOver():Void {
		onGameOver = true;
		camHUD.visible = false;
		
		var chars:Array<Character> = [];
		var char:Array<Int> = SONG.sectionStrums[0].charToSing;
		if(SONG.sectionStrums[0].notes[curSection].changeSing){char = SONG.sectionStrums[0].notes[curSection].charToSing;}
		for(i in char){chars.push(stage.getCharacterById(i)); stage.getCharacterById(i).visible = false;}

		pauseAndOpen(substates.GameOverSubstate, [chars], false, false);
	}

	override public function onFocusLost():Void {
		super.onFocusLost();

		if(!songPlaying){return;}

		pauseAndOpen(
			PauseSubState,
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

		if(songPlaying && inst.time > conductor.songPosition + 20 || inst.time < conductor.songPosition - 20){
			resyncVocals();
		}
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
	public static var songPlaylist:Array<SwagSong> = [];
	public static var isStoryMode:Bool = false;

	public static var campScore:Int = 0;

	public static function loadWeek(week:ItemWeek, category:String = "Normal", difficulty:String = "Normal"):Void {
		if(!SongStuffManager.hasCatAndDiff(week, category, difficulty)){return;}
		
		weekName = week.name;

		for(song in week.songs){
			trace(Song.fileSong(song, category, difficulty));
			var songToPlay:SwagSong = Song.loadFromJson(Song.fileSong(song, category, difficulty));
			songPlaylist.push(songToPlay);
		}
	}

	public static function addSongs(songList:Array<SwagSong>){for(song in songList){songPlaylist.push(song);}}
	public static function addSong(song:SwagSong){songPlaylist.push(song);}

	public static function playSong(_isStoryMode:Bool = true):Void {
		isStoryMode = _isStoryMode;
		MusicBeatState.switchState(new states.LoadingState(new PlayState(), [{type:"SONG", instance:songPlaylist[0]}], false));
	}

	public static function loadAndPlaySong(SONG:SwagSong, _isStoryMode:Bool = false):Void {
		isStoryMode = _isStoryMode;

		resetVariables();
		songPlaylist.push(SONG);
		MusicBeatState.switchState(new states.LoadingState(new PlayState(), [{type:"SONG", instance:SONG}], false));
	}
	
	public static function nextSong(score){
		campScore += score;
		songPlaylist.shift();
	}

	public static function resetVariables(){
		songPlaylist = [];
		campScore = 0;
	}
}