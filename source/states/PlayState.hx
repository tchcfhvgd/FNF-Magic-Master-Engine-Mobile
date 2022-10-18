package states;

import substates.PauseSubState;
import substates.MusicBeatSubstate;
import Note.StrumNote;
#if desktop
import Discord.DiscordClient;
#end
import Song.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import haxe.Timer;
import states.editors.StageBuilder;

import StrumLine;
import Note.Note;
import Note.EventData;

using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;

	private var curSection:Int = 0;
	public var curStrum:Int = 0;

	//Audio
	private var inst:FlxSound;
	private var voices:FlxSoundGroup;

	//Strumlines
	public var strumsGroup:FlxTypedGroup<StrumLine>;
	public var strumLeftPos:Float = 100;
	public var strumMiddlePos:Float = FlxG.width / 2;
	public var strumRightPos:Float = FlxG.width - 100;
	public var moveStrums:Bool = true;

	//Song Stats
	var song_Length:Float = 0;
	var song_Time:Float = 0;

	//Gameplay Stats
	private var lerp_health:Float = 0;
	public var game_Health:Float = 1;
	public var game_MaxHealth:Float = 2;

	public var stats_Map:Map<String, Dynamic> = [
		"1.Record" => 0,
		"2.Score" => 0,
		"3.Combo" => 0,
		"4.MaxCombo" => 0,
		"5.Hits" => 0,
		"6.Misses" => 0,
		"7.Rating" => "MAGIC"
	];
	
	//UI ASSETS
	public var healthBar:FlxBar = new FlxBar();
	public var sprite_healthBar:FlxSprite;
	public var lblStats:FlxText;

	//PreSettings Variables
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay", "Cheating Settings");
	var pre_OnlyNotes:Bool = PreSettings.getPreSetting("Only Notes", "Graphic Settings");
	var pre_TypeMiddle:String = PreSettings.getPreSetting("Type Middle Scroll", "Visual Settings");
	var pre_DefaultNonPos:String = PreSettings.getPreSetting("Default Strum Position", "Visual Settings");

	//Gameplay Style
	var uiStyleCheck:String = 'Default';

	private static var prevCamFollow:FlxObject;
	public var followChar:Bool = true;

	//Other
	private var songGenerated:Bool = false;
	private var songPlaying:Bool = false;
	public var canPause:Bool = true;
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
	
    public var recycleGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	//Stage
	public var stage:Stage;

    var camFollow:FlxObject;

	override public function create(){
		super.create();
		
		persistentUpdate = true;
		persistentDraw = true;

		//Audio Stuff
		voices = new FlxSoundGroup();
		inst = new FlxSound();
		FlxG.sound.list.add(inst);

		//Adding Items to Recycle
		recycleGroup.add(new FlxSprite());
		add(recycleGroup);

		if(SongListData.songPlaylist.length > 0){
			SONG = SongListData.songPlaylist[0];
		}else{
			SONG = Song.loadFromJson('Tutorial-Normal-Normal');
		}

		conductor.mapBPMChanges(SONG);
		conductor.changeBPM(SONG.bpm);

		if(SONG.uiStyle != null){uiStyleCheck = SONG.uiStyle;}
		curStrum = SONG.strumToPlay;

		if(!pre_OnlyNotes){
			stage = new Stage(SONG.stage, SONG.characters);
			add(stage);
		
			FlxG.camera.zoom = stage.zoom;
		}

		conductor.songPosition = -5000;

		strumsGroup = new FlxTypedGroup<StrumLine>();
		strumsGroup.cameras = [camHUD];
		add(strumsGroup);
		
		generateSong();
		loadUI();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		
		//StartSongMethod
		if(SongListData.isStoryMode){
			switch(SONG.song){
				default:{startCountdown(startSong);}
			}
		}else{
			switch(SONG.song){
				default:{startCountdown(startSong);}
			}
		}
	
        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		if (prevCamFollow != null){
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		add(camFollow);
	}

	private function generateSong():Void{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		conductor.changeBPM(songData.bpm);

		for(i in songData.generalSection){
			for(ii in i.events){
				var cur_Event:EventData = Note.getEventData(ii);
				if(cur_Event == null || cur_Event.isBroken){continue;}
				for(iii in cur_Event.eventData){MusicBeatState.state.pushTempScript(iii[0], iii[1]);}
			}
		}

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

		for(i in 0...songData.sectionStrums.length){
			var strumLine = new StrumLine(0, 0, songData.sectionStrums[i].keys, Std.int(FlxG.width / 3), principal_controls, null, songData.sectionStrums[i].noteStyle);
			
			strumLine.onHIT = function(note:Note){
				if(note.typeHit == "Hold"){note.missHealth *- 0.25; note.hitHealth *- 0.25;}
				
				if(i == curStrum){
					game_Health += note.hitHealth;

					if(note.typeHit != "Hold"){
						stats_Map["5.Hits"]++;
						stats_Map["3.Combo"]++;
						stats_Map["2.Score"] += 10;
						
						if(stats_Map["3.Combo"] > stats_Map["4.MaxCombo"]){stats_Map["4.MaxCombo"] = stats_Map["3.Combo"];}
						if(stats_Map["2.Score"] > stats_Map["1.Record"]){stats_Map["1.Record"] = stats_Map["2.Score"];}	
					}	
				}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){stage.getCharacterById(ii).playAnim(note.singAnimation, true);}
			};

			strumLine.onMISS = function(note:Note){
				if(note.typeHit == "Hold"){note.missHealth *- 0.25; note.hitHealth *- 0.25;}

				if(i == curStrum){
					game_Health -= note.missHealth;
				
					stats_Map["6.Misses"]++;
					stats_Map["3.Combo"] = 0;
					stats_Map["2.Score"] -= 10;
				}

				for(ii in Song.getNoteCharactersToSing(note, strumLine.swagStrum, strumLine.curSection)){stage.getCharacterById(ii).playAnim('${note.singAnimation}miss', true);}
			};

			strumLine.scrollSpeed = songData.speed;
			strumLine.strumConductor = conductor;
			strumLine.bpm = songData.bpm;

			strumLine.loadStrumNotes(songData.sectionStrums[i]);

			strumLine.x = (FlxG.width / 2) - (strumLine.genWidth / 2);
			strumLine.ID = i;

			strumsGroup.add(strumLine);
		}

		for(s in scripts){s.exFunction('preload');}
	}

	function loadUI(){
		var cont:Array<Bool> = [];
		for(s in scripts){s.exFunction('loadUI'); cont.push(s.getVariable("loadVanillaUI"));}

		if(cont.contains(true)){return; trace("RETURN");}

		sprite_healthBar = new FlxSprite().loadGraphic(Paths.styleImage("HealthBar", uiStyleCheck, "shared"));
		sprite_healthBar.scale.set(0.7,0.7); sprite_healthBar.updateHitbox();
		sprite_healthBar.screenCenter(X);
		sprite_healthBar.y = FlxG.height - sprite_healthBar.height - 40;
		sprite_healthBar.cameras = [camHUD];

		healthBar = new FlxBar(sprite_healthBar.x+3, sprite_healthBar.y+8, RIGHT_TO_LEFT, Std.int(FlxG.width / 2) - 20, 16, this, 'lerp_health', 0, game_MaxHealth);
		healthBar.numDivisions = 500;
		healthBar.cameras = [camHUD];

		lblStats = new FlxText(0,0,0,"|| ...Starting Song... ||");
		lblStats.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lblStats.screenCenter(X);
		lblStats.y = FlxG.height - lblStats.height - 5;
		lblStats.cameras = [camHUD];

		add(healthBar);
		add(sprite_healthBar);
		add(lblStats);
	}
	
	var previousFrameTime:Int = 0;
	function startSong():Void{	
		previousFrameTime = FlxG.game.ticks;
		
		conductor.songPosition = 0;

		inst.onComplete = endSong;

		inst.play(true);
		for(sound in voices.sounds){sound.play(true);}
		songPlaying = true;
		
		strumsGroup.members[curStrum].changeTypeStrum("Playing");
		
		#if desktop
		// Song duration in a float, useful for the time left feature
		song_Length = inst.length;
		#end
		
		songGenerated = true;
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
	var exEvents:Array<Dynamic> = [];
	override public function update(elapsed:Float){

		if (FlxG.keys.justPressed.NINE) {
			StageBuilder.daStage = SONG.stage; 
			StageBuilder.char = SONG.characters;
			MusicBeatState.switchState(new StageBuilder());
		}
		super.update(elapsed);

		lblStats.text = "|"; for(key in stats_Map.keys()){lblStats.text += ' ${key.split(".")[1]}: ${stats_Map[key]} |';} lblStats.screenCenter(X);

		lerp_health = FlxMath.lerp(lerp_health, game_Health, 0.1);

		curSection = Std.int(curStep / 16);

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

		if(game_Health > game_MaxHealth){game_Health = game_MaxHealth;}

		if(songPlaying){
			if(game_Health <= 0){doGameOver();}
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
					var newStrumLineX:Float = strumLeftPos;
					var curStrumPosX:String = "";

					MagicStuff.lerpY(curStrumLine, 30);
					
					if(i == curStrum){
						curStrumLine.alpha = FlxMath.lerp(curStrumLine.alpha, 1, 0.1);

						switch(pre_DefaultNonPos){
							case "Left":{newStrumLineX = strumLeftPos; curStrumLinePos = "Left";}
							case "Middle":{newStrumLineX = strumMiddlePos - (curStrumLine.genWidth/2); curStrumLinePos = "Middle";}
							case "Right":{newStrumLineX = strumRightPos - curStrumLine.genWidth; curStrumLinePos = "Right";}
						}
						if(pre_TypeMiddle != "None"){newStrumLineX = strumMiddlePos - (curStrumLine.genWidth/2); curStrumLinePos = "Middle";}
						if(strumPlayer == null || pre_TypeMiddle != "None"){continue;}
						newStrumLineX = strumPlayer.onRight ? (strumLeftPos) : (strumRightPos - curStrumLine.genWidth);
						curStrumLinePos = strumPlayer.onRight ? "Left" : "Right";
					}else{
						newStrumLineX = strumPlayer.onRight ? (strumLeftPos) : (strumRightPos - curStrumLine.genWidth);
						curStrumPosX = strumPlayer.onRight ? "Left" : "Right";
						if(curStrumPosX != curStrumLinePos){
							switch(pre_TypeMiddle){
								default:{curStrumLine.alpha =  FlxMath.lerp(curStrumLine.alpha, 1, 0.1);}
								case "OnlyPlayer":{curStrumLine.alpha =  FlxMath.lerp(curStrumLine.alpha, 0, 0.1);}
								case "FadeOthers":{curStrumLine.alpha =  FlxMath.lerp(curStrumLine.alpha, 0.5, 0.1);}
							}
						}else{curStrumLine.alpha =  FlxMath.lerp(curStrumLine.alpha, 0, 0.1);}
					}
					
					MagicStuff.lerpX(curStrumLine, newStrumLineX);
				}
				// CHARACTER CAMERA
				if(followChar){Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(SONG, curSection)), camFollow);}
			}
		}

		if(stage.camP_1 != null){
			if(camFollow.x < stage.camP_1.x){camFollow.x = stage.camP_1.x;}
			if(camFollow.y < stage.camP_1.y){camFollow.y = stage.camP_1.y;}
		}
		if(stage.camP_2 != null){
			if(camFollow.x > stage.camP_2.x){camFollow.x = stage.camP_2.x;}
			if(camFollow.y > stage.camP_2.y){camFollow.y = stage.camP_2.y;}
		}
	}

	function checkEvents(){
		if(!songGenerated || PlayState.SONG.generalSection[curSection] == null || PlayState.SONG.generalSection[curSection].events.length <= 0){return;}
		var sEvents:Array<Dynamic> = SONG.generalSection[Math.floor(curStep / 16)].events;
		for(event in sEvents){
			var cur_Event:EventData = Note.getEventData(event);
			if(conductor.songPosition > cur_Event.strumTime && !cur_Event.isBroken && !exEvents.contains(event)){
				exEvents.push(event);
				for(e in cur_Event.eventData){
					var _args = cast(e[1],Array<Dynamic>).copy();
					var _srp = Script.getScript(e[0]);
					if(_srp == null){continue;}
					if(_srp.getVariable("defaultValues") != null){
						var _defArgs = cast(_srp.getVariable("defaultValues"),Array<Dynamic>).copy();
						while(_args.length < _defArgs.length){_args.push(_defArgs[_args.length]);}
					}
					_srp.exFunction("execute", cast _args);
				}
			}			
		}
	}

	function endSong():Void{
		trace("End Song");
		canPause = false;
		songPlaying = false;

		inst.stop();
		for(sound in voices.sounds){sound.stop();}

		if (SONG.validScore){
			#if !switch
			Highscore.saveSongScore(SONG.song, stats_Map["2.Score"], SONG.difficulty, SONG.category);
			#end
		}

		SongListData.nextSong(stats_Map["2.Score"]);
		if(SongListData.songPlaylist.length <= 0){
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			isPaused = true;

			SongListData.resetVariables();
			MusicBeatState.switchState(new states.MainMenuState());

			//if (SONG.validScore){
			//	NGio.unlockMedal(60961);
			//	Highscore.saveWeekScore(storyWeek, campaignScore, curDifficulty, curCategory);
			//}
		}else{
			trace('LOADING NEXT SONG');

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			prevCamFollow = camFollow;

			SongListData.playWeek();
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
		var char:Array<Int> = SONG.sectionStrums[curStrum].charToSing;
		if(SONG.sectionStrums[curStrum].notes[curSection].changeSing){char = SONG.sectionStrums[curStrum].notes[curSection].charToSing;}
		for(i in char){chars.push(stage.getCharacterById(i)); stage.getCharacterById(i).visible = false;}

		pauseAndOpen(substates.GameOverSubstate, [chars], false, false);
	}

	override public function onFocusLost():Void {
		super.onFocusLost();
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
		if(songPlaying && inst.time > conductor.songPosition + 20 || inst.time < conductor.songPosition - 20){resyncVocals();}
	}

	override function beatHit(){
		super.beatHit();
		if(SONG.generalSection[Math.floor(curStep / 16)] != null){
			if(SONG.generalSection[Math.floor(curStep / 16)].changeBPM){
				conductor.changeBPM(SONG.generalSection[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// conductor.changeBPM(SONG.bpm);
		}
	}
}

class SongListData{
	public static var onNext:Void->Void;
	public static var onFinish:Void->Void;

	public static var songPlaylist:Array<SwagSong> = [];
	public static var isStoryMode:Bool = false;

	public static var campScore:Int = 0;

	public static function addWeek(songList:Array<SwagSong>){
		for(song in songList){songPlaylist.push(song);}
	}

	public static function addSong(song:SwagSong){
		songPlaylist.push(song);
	}

	public static function playWeek(){
		isStoryMode = true;
		states.LoadingState.loadAndSwitchState(new PlayState(), songPlaylist[0], false);
	}

	public static function playSong(SONG:SwagSong) {
		isStoryMode = false;

		resetVariables();
		songPlaylist.push(SONG);
		states.LoadingState.loadAndSwitchState(new PlayState(), SONG, false);
	}
	
	public static function nextSong(score){
		campScore += score;
		songPlaylist.remove(songPlaylist[0]);
	}

	public static function resetVariables(){
		songPlaylist = [];
		campScore = 0;
	}
}