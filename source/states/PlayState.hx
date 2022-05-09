package states;

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
	private var curSection:Int = 0;
	private var curStrum:Int = 0;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;

	//Audio
	private var voices:FlxSoundGroup;

	private var strumsGroup:FlxTypedGroup<StrumLine>;

	//Gameplay Stats
	var defaultCamZoom:Float = 1.05;
	var songLength:Float = 0;
	var songTime:Float = 0;
	var songScore:Int = 0;

	//PreSettings Variables
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay");
	var pre_OnlyNotes:Bool = PreSettings.getPreSetting("OnlyNotes");

	private var health:Float = 1;
	private var combo:Int = 0;

	var uiStyleCheck:String = 'Normal';

	//Cameras
	public var camBHUD:FlxCamera;
	public var camHUD:FlxCamera;
	public var camFHUD:FlxCamera;
	private var camGame:FlxCamera;

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	//Other
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var startedCountdown:Bool = false;
	private var paused:Bool = false;
	private var canPause:Bool = true;

	//Stage
	public var stage:Stage;

	override public function create(){
		if(FlxG.sound.music != null){FlxG.sound.music.stop();}

		camGame = new FlxCamera();
		camBHUD = new FlxCamera();
		camBHUD.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camFHUD = new FlxCamera();
		camFHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBHUD);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camFHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if(SongListData.songPlaylist.length > 0){
			SONG = SongListData.songPlaylist[0];
		}else{
			SONG = Song.loadFromJson('Tutorial-Normal-Hard', 'Tutorial');
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if(SONG.uiStyle != null){uiStyleCheck = SONG.uiStyle;}

		curStrum = SONG.strumToPlay;

		voices = new FlxSoundGroup();

		if(!pre_OnlyNotes){
			stage = new Stage(SONG.stage, SONG.characters);
			add(stage);
		}

		Conductor.songPosition = -5000;

		strumsGroup = new FlxTypedGroup<StrumLine>();
		strumsGroup.cameras = [camHUD];
		add(strumsGroup);

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		if (prevCamFollow != null){
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.02);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		startingSong = true;

		//StartSongMethod
		if(SongListData.isStoryMode){
			switch(SONG.song){
				default:{startCountdown();}
			}
		}else{
			switch(SONG.song){
				default:{startCountdown();}
			}
		}

		super.create();
	}

	var startTimer:FlxTimer;
	function startCountdown():Void{
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer){
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');

			switch (swagCounter){
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	function startSong():Void{
		startingSong = false;
	
		previousFrameTime = FlxG.game.ticks;
	
		if(!paused){FlxG.sound.playMusic(Paths.inst(SONG.song.replace(" ", "_"), SONG.category), 1, false);}
		FlxG.sound.music.onComplete = endSong;
		for(sound in voices.sounds){sound.play();}
	
		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		#end
	}

	private function generateSong():Void{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		voices.sounds = [];
        if(songData.voices != null && songData.voices.length > 0){
            for(i in 0...songData.voices.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, songData.voices[i], songData.song.replace(" ", "_"), songData.category));
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

				var char = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}

				for(i in char){
					var char:Character = stage.getCharacterById(i);

					if(char != null){
						char.playAnim(false, note.chAnim, true);
						char.holdTimer = FlxG.elapsed * 10;
					}
				}
			}

			strumLine.onMISS = function(note:Note) {
				//trace("MISS++ | TOTAL MISSES: " +  strumLine.MISSES);
				var char = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}

				for(i in char){
					var char:Character = stage.getCharacterById(i);

					if(char != null){
						char.playAnim(false, note.chAnim + "-miss", true);
						char.holdTimer = FlxG.elapsed * 10;
					}
				}
			}

			strumLine.controls = principal_controls;

			lastStrum = strumLine;
			strumLine.scrollSpeed = songData.speed;
			strumLine.bpm = songData.bpm;
			strumLine.setNotes(songData.sectionStrums[i]);
			strumLine.ID = i;
			strumsGroup.add(strumLine);
		}

		generatedMusic = true;
	}

	override function openSubState(SubState:FlxSubState){
		if (paused){
			if (FlxG.sound.music != null){
				FlxG.sound.music.pause();
				for(sound in voices.sounds){sound.pause();}
			}
	
			if (!startTimer.finished){startTimer.active = false;}
		}
	
		super.openSubState(SubState);
	}

	override function closeSubState(){
		if(paused){
			if (FlxG.sound.music != null && !startingSong){
				resyncVocals();
			}
	
			if(!startTimer.finished){startTimer.active = true;}
			paused = false;
		}
		
		super.closeSubState();
	}

	function resyncVocals():Void{
		for(sound in voices.sounds){sound.pause();}
	
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
	
		for(sound in voices.sounds){
			sound.time = Conductor.songPosition;
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

		strumsGroup.forEach(function(strumLine:StrumLine){
            if(curStrum == strumLine.ID){strumLine.typeStrum = "Playing";}else{strumLine.typeStrum = "BotPlay";}
        });

		if(FlxG.keys.anyPressed([O, L])){
			if(FlxG.keys.pressed.O){FlxG.sound.music.time -= Conductor.stepCrochet * 0.2;}
			if(FlxG.keys.pressed.L){FlxG.sound.music.time += Conductor.stepCrochet * 0.1;}
		}

		if(principal_controls.checkAction("Menu_Pause", JUST_PRESSED) && startedCountdown && canPause){
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
	
			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1)){
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}else{
				openSubState(new substates.PauseSubState());
			}
		}

		if(FlxG.keys.justPressed.SEVEN){
			states.editors.ChartEditorState.editChart(SONG);
		}

		if(health > 2){health = 2;}

		if(startingSong){
			if(startedCountdown){
				Conductor.songPosition += FlxG.elapsed * 1000;
				if(Conductor.songPosition >= 0){startSong();}
			}
		}else{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
	
			if(!paused){
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
	
				// Interpolation type beat
				if(Conductor.lastSongPos != Conductor.songPosition){
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}
	
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if(!pre_OnlyNotes){
			var char = null;
			if(generatedMusic && PlayState.SONG.generalSection[Std.int(curStep / 16)] != null){
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

				var cCharacter = stage.getCharacterById(Character.getFocusCharID(SONG, Std.int(curStep / 16)));

				if(cCharacter == null){
					camMoveX += FlxG.width / 2;
					camMoveY += FlxG.height / 2;
				}else{
					camMoveX += cCharacter.getMidpoint().x;
					camMoveY += cCharacter.getMidpoint().y;

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
			health = 0;
			trace("RESET = True");
		}

		if(health <= 0){
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			for(sound in voices.sounds){sound.stop();}
			FlxG.sound.music.stop();

			openSubState(new substates.GameOverSubstate(0, 0, "Boyfriend"));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	function endSong():Void{
		trace("End Song");
		canPause = false;
		FlxG.sound.music.volume = 0;
		for(sound in voices.sounds){sound.volume = 0;}
		FlxG.sound.music.pause();
		for(sound in voices.sounds){sound.pause();}

		if (SONG.validScore){
			#if !switch
			Highscore.saveScore(SONG.song, songScore, SONG.difficulty, SONG.category);
			#end
		}

		SongListData.nextSong(songScore);
		if(SongListData.songPlaylist.length <= 0){
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			paused = true;

			FlxG.sound.music.stop();
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
			FlxG.sound.music.stop();
		}
	}

	override public function onFocus():Void{
		super.onFocus();
	}

	override public function onFocusLost():Void{
		super.onFocusLost();
	}

	override function stepHit(){
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20){
			resyncVocals();
		}
	}

	override function beatHit(){
		super.beatHit();

		for(i in 0...stage.getChars().length){
			var cChar:Character = stage.getCharacterById(i);
			if(cChar.holdTimer <= 0){
				cChar.dance();
			}
		}

		if (SONG.generalSection[Math.floor(curStep / 16)] != null){
			if (SONG.generalSection[Math.floor(curStep / 16)].changeBPM){
				Conductor.changeBPM(SONG.generalSection[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
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
		states.LoadingState.loadAndSwitchState(new PlayState(), SONG);
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