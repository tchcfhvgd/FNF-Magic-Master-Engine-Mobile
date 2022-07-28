package states;

import substates.PauseSubState;
import substates.MusicBeatSubstate;
import StrumLineNote.StrumNote;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
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

import StrumLineNote.StrumLine;
import StrumLineNote.Note;

using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;

	private var curSection:Int = 0;
	private var curStrum:Int = 0;

	//Audio
	private var inst:FlxSound;
	private var voices:FlxSoundGroup;

	//Strumlines
	private var strumsGroup:FlxTypedGroup<StrumLine>;

	//Song Stats
	var song_Length:Float = 0;
	var song_Time:Float = 0;

	//Gameplay Stats
	private var game_Health:Float = 1;
	private var game_MaxHealth:Float = 2;
	private var game_Stamina:Float = 1;
	private var game_MaxStamina:Float = 1;

	private var stats_Score:Int = 0;
	private var stats_Combo:Int = 0;

	//PreSettings Variables
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay");
	var pre_OnlyNotes:Bool = PreSettings.getPreSetting("OnlyNotes");

	//Gameplay Style
	var uiStyleCheck:String = 'Default';

	private static var prevCamFollow:FlxObject;

	//Other
	private var songGenerated:Bool = false;
	private var songPlaying:Bool = false;
	private var canPause:Bool = true;
	private var isPaused:Bool = false;

	private var timers:Array<FlxTimer> = [];
	
    private var recycleGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	//Stage
	public var stage:Stage;

    var camFollow:FlxObject;

	override public function create(){
		persistentUpdate = true;
		persistentDraw = true;

		//Audio Stuff
		voices = new FlxSoundGroup();
		inst = new FlxSound();
		inst.persist = false;
		FlxG.sound.list.add(inst);

		//Adding Items to Recycle
		recycleGroup.add(new FlxSprite());
		add(recycleGroup);

		if(SongListData.songPlaylist.length > 0){
			SONG = SongListData.songPlaylist[0];
		}else{
			SONG = Song.loadFromJson('Flippy_Roll-Normal-Hard', 'Flippy_Roll');
		}

		conductor.mapBPMChanges(SONG);
		conductor.changeBPM(SONG.bpm);

		if(SONG.uiStyle != null){uiStyleCheck = SONG.uiStyle;}
		curStrum = SONG.strumToPlay;

		if(!pre_OnlyNotes){
			stage = new Stage(SONG.stage, SONG.characters);
			add(stage);
		}

		conductor.songPosition = -5000;

		strumsGroup = new FlxTypedGroup<StrumLine>();
		strumsGroup.cameras = [camHUD];
		add(strumsGroup);

		generateSong();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		
		//StartSongMethod
		if(SongListData.isStoryMode){
			switch(SONG.song){
				default:{startCountdown(true);}
			}
		}else{
			switch(SONG.song){
				default:{startCountdown(true);}
			}
		}
	
		super.create();
	
        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		if (prevCamFollow != null){
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		add(camFollow);
	}

	function startCountdown(init:Bool = false):Void{
		if(init){
			songPlaying = true;

			conductor.songPosition = 0;
			conductor.songPosition -= conductor.crochet * 5;
		}

		var swagCounter:Int = 0;
		timers.push(new FlxTimer().start(conductor.crochet / 1000, function(tmr:FlxTimer){
			var introAlts:Array<String> = ['ready', 'set', 'go'];

			switch(swagCounter){
				case 0:{FlxG.sound.play(Paths.sound('intro3'), 0.6);}
				case 1:{
					var ready:FlxSprite = recycleGroup.recycle(FlxSprite);
					ready.loadGraphic(Paths.styleImage(introAlts[0], uiStyleCheck));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){ready.kill();}});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				}
				case 2:{
					var set:FlxSprite = recycleGroup.recycle(FlxSprite);
					set.loadGraphic(Paths.styleImage(introAlts[1], uiStyleCheck));
					set.scrollFactor.set();
					set.updateHitbox();
					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){set.kill();}});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				}
				case 3:{
					var go:FlxSprite = recycleGroup.recycle(FlxSprite);
					go.loadGraphic(Paths.styleImage(introAlts[2], uiStyleCheck));
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){go.kill();}});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				}
				case 4:{if(init){startSong();}}
			}
			
			swagCounter += 1;
		}, 5));
	}

	var previousFrameTime:Int = 0;
	function startSong():Void{	
		previousFrameTime = FlxG.game.ticks;
	
		if(!isPaused){inst.play(true);}
		inst.onComplete = endSong;
		for(sound in voices.sounds){sound.play(true);}

		strumsGroup.members[curStrum].typeStrum = "Playing";
		
		#if desktop
		// Song duration in a float, useful for the time left feature
		song_Length = inst.length;
		#end
	}

	private function generateSong():Void{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		conductor.changeBPM(songData.bpm);

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

		var lastStrum:StrumLine = null;
		for(i in 0...songData.sectionStrums.length){
			var strumLine = new StrumLine(5 + (lastStrum != null ? 55 + lastStrum.strumSize : 0), 30, songData.sectionStrums[i].keys, Std.int(FlxG.width / 3));

			for(daStrum in strumLine.staticNotes){daStrum.alpha = 0;}
			
			strumLine.onHIT = function(note:Note) {
				//trace("HITS++ | TOTAL HITS: " +  strumLine.HITS);

				var char:Array<Int> = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}
				if(note.otherData.exists('Set_CharToSing')){char = cast note.otherData.get('Set_CharToSing');}

				for(i in char){stage.getCharacterById(i).playAnim(note.chAnim);}
			}

			strumLine.onMISS = function(note:Note) {
				//trace("MISS++ | TOTAL MISSES: " +  strumLine.MISSES);
				var char:Array<Int> = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}
				if(note.otherData.exists('Set_CharToSing')){char = cast note.otherData.get('Set_CharToSing');}
				
				for(i in char){stage.getCharacterById(i).playAnim('${note.chAnim}miss');}
			}

			strumLine.controls = principal_controls;
			strumLine.strumConductor = conductor;

			lastStrum = strumLine;
			strumLine.scrollSpeed = songData.speed;
			strumLine.bpm = songData.bpm;
			strumLine.setNotes(songData.sectionStrums[i]);
			strumLine.ID = i;
			strumsGroup.add(strumLine);
		}

		songGenerated = true;
	}

	override function closeSubState(){
		if(isPaused){
			if(inst != null){resyncVocals();}
	
			for(timer in timers){if(!timer.finished){timer.active = true;}}
			isPaused = false;
			
			persistentUpdate = true;
			persistentDraw = false;
		}
		
		super.closeSubState();
	}

	function resyncVocals():Void{
		for(sound in voices.sounds){sound.pause();}
	
		inst.play();
		conductor.songPosition = inst.time;
	
		for(sound in voices.sounds){
			sound.time = conductor.songPosition;
			sound.play();
		}
	}

	var sLeft:StrumLine = null;
	var sMiddle:StrumLine = null;
	var sRight:StrumLine = null;
	var sCurStrum:StrumLine = null;
	override public function update(elapsed:Float){
		super.update(elapsed);


		FlxG.camera.zoom = stage.zoom;

		if(FlxG.keys.anyPressed([O, L])){
			if(FlxG.keys.pressed.O){inst.time -= conductor.stepCrochet * 0.2;}
			if(FlxG.keys.pressed.L){inst.time += conductor.stepCrochet * 0.1;}
		}

		if(principal_controls.checkAction("Menu_Pause", JUST_PRESSED) && canPause){pauseAndOpen(new PauseSubState(), true);}

		if(FlxG.keys.justPressed.SEVEN){
			states.editors.ChartEditorState.editChart(SONG);
		}

		if(game_Health > game_MaxHealth){game_Health = game_MaxHealth;}

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
			var char = null;
			if(songGenerated && PlayState.SONG.generalSection[Std.int(curStep / 16)] != null){
				var pre_ForceMiddle:Bool = PreSettings.getPreSetting("ForceMiddleScroll");
				var gSection = PlayState.SONG.generalSection[Std.int(curStep / 16)];

				strumsGroup.forEach(function(daStrumline:StrumLine){
					var cStrum = PlayState.SONG.sectionStrums[daStrumline.ID];
					var cSection = PlayState.SONG.sectionStrums[daStrumline.ID].notes[Std.int(curStep / 16)];

					if(cSection.changeSing && cSection.charToSing != null){
						char = stage.getCharacterById(cSection.charToSing[gSection.charToFocus]);
						if(char == null){stage.getCharacterById(cSection.charToSing[cSection.charToSing.length - 1]);}
					}else{
						char = stage.getCharacterById(cStrum.charToSing[gSection.charToFocus]);
						if(char == null){stage.getCharacterById(cStrum.charToSing[cStrum.charToSing.length - 1]);}
					}

					var getStrumLeftX = 100;
					var getStrumMiddleX = (FlxG.width / 2) - (daStrumline.strumSize / 2);
					var getStrumRightX = FlxG.width - daStrumline.strumSize - 100;

					var curX:Float = 0;
					if(pre_ForceMiddle){
						curX = getStrumMiddleX;
						
						if(daStrumline.ID == curStrum){
							for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}
							sMiddle = daStrumline;
							sCurStrum = daStrumline;
						}else{
							if(cStrum.charToSing.length > 0){
								for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, (0.5 * daStrum._alpha / 1), 0.1);}

								if(char.onRight){
									curX = getStrumLeftX;
									sLeft = daStrumline;
								}else{
									curX = getStrumRightX;
									sRight = daStrumline;
								}
							}else{
								for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, 0, 0.1);}
							}
						}
					}else{
						if(cStrum.charToSing.length > 0){							
							if(daStrumline.ID == curStrum){
								for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}

								if(char.onRight){
									sLeft = daStrumline;
									curX = getStrumLeftX;
								}else{
									sRight = daStrumline;
									curX = getStrumRightX;
								}

								sCurStrum = daStrumline;
							}else{
								if(char.onRight){
									curX = getStrumLeftX;
									if(sLeft != sCurStrum){
										for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}
										sLeft = daStrumline;
									}else{
										for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, 0, 0.1);}
									}
								}

								if(!char.onRight){
									curX = getStrumRightX;
									if(sRight != sCurStrum){
										for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}
										sRight = daStrumline;
									}else{
										for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, 0, 0.1);}
									}
								}
							}
						}else{
							if(daStrumline.ID == curStrum){	
								for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}

								sRight = daStrumline;
								curX = getStrumRightX;
							}else{
								if(sLeft == null){
									for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, daStrum._alpha, 0.1);}
									sLeft = daStrumline;
									curX = getStrumLeftX;
								}else{
									for(daStrum in daStrumline.staticNotes){daStrum.alpha = FlxMath.lerp(daStrum.alpha, 0, 0.1);}
								}
							}
						}
					}

					for(daStrum in daStrumline.staticNotes){daStrum.x = FlxMath.lerp(daStrum.x, curX + ((daStrumline.strumSize / daStrumline.keys) * daStrum.ID), 0.1);}
				});

				// CHARACTER CAMERA
				var camMoveX = 0.0;
				var camMoveY = 0.0;
	
				var offsetX = 0;
				var offsetY = -100;

				camMoveX += offsetX;
				camMoveY += offsetY;

				var cCharacter = null;
				var cCharacter = stage.getCharacterById(Character.getFocusCharID(SONG, Std.int(curStep / 16)));

				if(cCharacter == null){
					camMoveX += FlxG.width / 2;
					camMoveY += FlxG.height / 2;
				}else{
					camMoveX += cCharacter.getMidpoint().x;
					camMoveY += cCharacter.getMidpoint().y;
					
					camMoveX += cCharacter.cameraPosition[0];
					camMoveY += cCharacter.cameraPosition[1];

					if(cCharacter.animation.curAnim != null){
						switch(cCharacter.animation.curAnim.name){
							case 'singUP':{camMoveY -= 100;}
							case 'singRIGHT':{camMoveX += 100;}
							case 'singDOWN':{camMoveY += 100;}
							case 'singLEFT':{camMoveX -= 100;}
						}
					}

					//FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1 - char.scale.x, 0.05);
				}
				camFollow.setPosition(camMoveX, camMoveY);
			}
		}

		if(FlxG.keys.justPressed.R){
			game_Health = 0;
			trace("RESET = True");
		}

		if(game_Health <= 0){
			isPaused = true;

			for(sound in voices.sounds){sound.stop();}
			inst.stop();

			openSubState(new substates.GameOverSubstate(0, 0, "Boyfriend"));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	function endSong():Void{
		trace("End Song");
		canPause = false;
		inst.volume = 0;
		for(sound in voices.sounds){sound.volume = 0;}
		inst.pause();
		for(sound in voices.sounds){sound.pause();}

		if (SONG.validScore){
			#if !switch
			Highscore.saveScore(SONG.song, stats_Score, SONG.difficulty, SONG.category);
			#end
		}

		SongListData.nextSong(stats_Score);
		if(SongListData.songPlaylist.length <= 0){
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			isPaused = true;

			inst.stop();
			for(sound in voices.sounds){sound.stop();}

			SongListData.resetVariables();
			FlxG.switchState(new states.MainMenuState());

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
			inst.stop();
		}
	}

	private function pauseAndOpen(substate:FlxSubState, hasEasterEgg:Bool = false){
		persistentUpdate = false;
		persistentDraw = true;

		isPaused = true;

		if(inst != null){
			inst.pause();
			for(sound in voices.sounds){sound.pause();}
		}

		for(timer in timers){if(!timer.finished){timer.active = false;}}

		// 1 / 1000 chance for Gitaroo Man easter egg
		if(hasEasterEgg && FlxG.random.bool(0.1)){
			trace('GITAROO MAN EASTER EGG');
			FlxG.switchState(new GitarooPause());
		}else{
			openSubState(substate);
		}
	}

	override function openSubState(substate:FlxSubState){
		super.openSubState(substate);
	}

	override public function onFocus():Void{
		super.onFocus();
	}

	override public function onFocusLost():Void{
		super.onFocusLost();
		
		pauseAndOpen(new PauseSubState(), true);
	}

	override function stepHit(){
		super.stepHit();
		if(inst.time > conductor.songPosition + 20 || inst.time < conductor.songPosition - 20){
			resyncVocals();
		}
	}

	override function beatHit(){
		super.beatHit();

		for(char in stage.characterData){if(char.holdTimer <= 0){char.dance();}}

		if (SONG.generalSection[Math.floor(curStep / 16)] != null){
			if (SONG.generalSection[Math.floor(curStep / 16)].changeBPM){
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