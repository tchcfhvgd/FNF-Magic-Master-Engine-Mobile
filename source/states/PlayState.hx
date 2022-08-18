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
import haxe.Timer;

import StrumLineNote.StrumLine;
import StrumLineNote.Note;

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


	//Song Stats
	var song_Length:Float = 0;
	var song_Time:Float = 0;

	//Gameplay Stats
	public var game_Health:Float = 1;
	public var game_MaxHealth:Float = 2;

	public var stats_Score:Int = 0;
	public var stats_Combo:Int = 0;
	
	//UI ASSETS
	public var healthBar:FlxBar = new FlxBar();
	public var sprite_healthBar:FlxSprite;

	//PreSettings Variables
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay");
	var pre_OnlyNotes:Bool = PreSettings.getPreSetting("OnlyNotes");

	//Gameplay Style
	var uiStyleCheck:String = 'Default';

	private static var prevCamFollow:FlxObject;

	//Other
	private var songGenerated:Bool = false;
	private var songPlaying:Bool = false;
	public var canPause:Bool = true;
	public var isPaused:Bool = false;
	public var onGameOver:Bool = false;
	
	public var introAssets:Array<{asset:String, sound:String}> = [{asset:null, sound: 'intro3'}, {asset:'ready', sound: 'intro2'}, {asset:'set', sound: 'intro1'}, {asset:'go', sound: 'introGo'}];

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
				var daOtherData:Array<Dynamic> = ii[1];
				if(daOtherData != null && daOtherData.length > 0){
					for(i in daOtherData){
						if(!tempScripts.exists(i[0]) && Paths.exists(Paths.event(i[0]))){
							var nScript = new Script(); nScript.Name = i[0];
							nScript.exScript(Paths.getText(Paths.event(i[0])));
			
							tempScripts.set(i[0], nScript);
						}
					}
				}
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

		var lastStrum:StrumLine = null;
		for(i in 0...songData.sectionStrums.length){
			var strumLine = new StrumLine(5 + (lastStrum != null ? 55 + lastStrum.strumSize : 0), 30, songData.sectionStrums[i].keys, Std.int(FlxG.width / 3));

			for(daStrum in strumLine.staticNotes){daStrum.alpha = 0;}
			
			strumLine.onHIT = function(note:Note){
				//trace("HITS++ | TOTAL HITS: " +  strumLine.HITS);

				if(note.typeHit == "Hold"){note.missHealth *- 0.25; note.hitHealth *- 0.25;}
				if(i == curStrum){game_Health += note.hitHealth;}

				var char:Array<Int> = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}

				for(ii in char){stage.getCharacterById(ii).playAnim(note.chAnim, true);}
			};

			strumLine.onMISS = function(note:Note){
				//trace("MISS++ | TOTAL MISSES: " +  strumLine.MISSES);
				
				if(note.typeHit == "Hold"){note.missHealth *- 0.25; note.hitHealth *- 0.25;}
				if(i == curStrum){game_Health -= note.missHealth;}

				var char:Array<Int> = SONG.sectionStrums[i].charToSing;
				if(SONG.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}
				
				for(ii in char){stage.getCharacterById(ii).playAnim('${note.chAnim}miss', true);}
			};

			strumLine.controls = principal_controls;
			strumLine.strumConductor = conductor;

			lastStrum = strumLine;
			strumLine.scrollSpeed = songData.speed;
			strumLine.bpm = songData.bpm;
			strumLine.setNotes(songData.sectionStrums[i]);
			strumLine.ID = i;
			strumsGroup.add(strumLine);
		}
	}

	function loadUI(){
		var cont:Array<Bool> = [];
		if(script != null){script.exFunction('loadUI'); cont.push(script.getVariable("loadVanillaUI"));}
		for(spt in tempScripts){spt.exFunction('loadUI'); cont.push(spt.getVariable("loadVanillaUI"));}
		for(s in scripts){s.exFunction('loadUI'); cont.push(s.getVariable("loadVanillaUI"));}

		if(cont.contains(true)){return; trace("RETURN");}

		healthBar = new FlxBar(Std.int(FlxG.width / 4) + 12, FlxG.height - 130, RIGHT_TO_LEFT, Std.int(FlxG.width / 2) - 24, 45, this, 'game_Health', 0, game_MaxHealth);
		healthBar.cameras = [camHUD];
		add(healthBar);

		sprite_healthBar = new FlxSprite().loadGraphic(Paths.styleImage("HealthBar", uiStyleCheck, "shared"));
		sprite_healthBar.antialiasing = PreSettings.getPreSetting("Antialiasing");
		sprite_healthBar.scale.y = 0.7; sprite_healthBar.scale.x = 0.7;
		sprite_healthBar.x = (FlxG.width / 2) - (sprite_healthBar.width / 2);
		sprite_healthBar.y = FlxG.height - sprite_healthBar.height;
		sprite_healthBar.cameras = [camHUD];
		add(sprite_healthBar);
	}

	public function startCountdown(onComplete:Void->Void = null):Void{
		var swagCounter:Int = 0;
		timers.push(new FlxTimer().start(conductor.crochet / 1000, function(tmr:FlxTimer){
			if(introAssets[swagCounter] != null){
				if(introAssets[swagCounter].sound != null){FlxG.sound.play(Paths.sound(introAssets[swagCounter].sound), 0.6);}
			
				if(introAssets[swagCounter].asset != null){
					var iAssets:FlxSprite = recycleGroup.recycle(FlxSprite);
					iAssets.loadGraphic(Paths.styleImage(introAssets[swagCounter].asset, uiStyleCheck));
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
	
	var previousFrameTime:Int = 0;
	function startSong():Void{	
		previousFrameTime = FlxG.game.ticks;
		
		conductor.songPosition = 0;
		conductor.songPosition -= conductor.crochet * 5;

		inst.play(true);
		for(sound in voices.sounds){sound.play(true);}
		songPlaying = true;
		
		inst.onComplete = endSong;

		strumsGroup.members[curStrum].typeStrum = "Playing";
		
		#if desktop
		// Song duration in a float, useful for the time left feature
		song_Length = inst.length;
		#end
		
		songGenerated = true;
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

	var sLeft:StrumLine = null;
	var sMiddle:StrumLine = null;
	var sRight:StrumLine = null;
	var sCurStrum:StrumLine = null;
	var exEvents:Array<Dynamic> = [];
	override public function update(elapsed:Float){
		super.update(elapsed);

		FlxG.camera.zoom = stage.zoom;

		checkEvents();

		if(canControlle){	
			if(principal_controls.checkAction("Menu_Pause", JUST_PRESSED) && canPause){pauseAndOpen(new PauseSubState(function(){
				persistentUpdate = false;
				persistentDraw = true;
				startCountdown(function(){canControlle = true; isPaused = false; pauseSong(false);});
			}), true);}
			if(FlxG.keys.justPressed.SEVEN){states.editors.ChartEditorState.editChart(null, PlayState, SONG);}
			
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
				Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(SONG, Std.int(curStep / 16))), camFollow);
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
		if(!songGenerated || PlayState.SONG.generalSection[Std.int(curStep / 16)] == null || PlayState.SONG.generalSection[Std.int(curStep / 16)].events.length <= 0){return;}
		var sEvents:Array<Dynamic> = SONG.generalSection[Math.floor(curStep / 16)].events;
		for(event in sEvents){
			if(conductor.songPosition > event[0] && !exEvents.contains(event)){
				exEvents.push(event);

				var eFuncts:Array<Dynamic> = event[1];
				for(e in eFuncts){
					var ergs:Array<Dynamic> = e[1];
					var args = [null]; for(e in ergs){args.push(e);}
					tempScripts.get(e[0]).exFunction("execute", cast args);
				}
			}
			
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
			inst.stop();
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
		}else if(songGenerated){
			if(inst != null){resyncVocals();}	
			for(timer in timers){if(!timer.finished){timer.active = true;}}
		}
	}

	public function pauseAndOpen(substate:FlxSubState, hasEasterEgg:Bool = false){
		if(isPaused){return;}
		persistentUpdate = false;
		persistentDraw = true;
		isPaused = true;

		pauseSong();

		// 1 / 1000 chance for Gitaroo Man easter egg
		if(hasEasterEgg && FlxG.random.bool(0.1)){
			trace('GITAROO MAN EASTER EGG');
			MusicBeatState.switchState(new GitarooPause());
		}else{
			canControlle = false;
			openSubState(substate);
		}
	}

	function doGameOver():Void {
		onGameOver = true;
		camHUD.visible = false;
		
		var chars:Array<Character> = [];
		var char:Array<Int> = SONG.sectionStrums[curStrum].charToSing;
		if(SONG.sectionStrums[curStrum].notes[Std.int(curStep / 16)].changeSing){char = SONG.sectionStrums[curStrum].notes[Std.int(curStep / 16)].charToSing;}
		for(i in char){chars.push(stage.getCharacterById(i)); stage.getCharacterById(i).visible = false;}

		pauseAndOpen(new substates.GameOverSubstate(chars));
	}

	override public function onFocusLost():Void {super.onFocusLost(); pauseAndOpen(new PauseSubState(function(){
		persistentUpdate = false;
		persistentDraw = true;
		startCountdown(function(){canControlle = true; isPaused = false; pauseSong(false);});
	}), true);}

	override function stepHit(){
		super.stepHit();
		if(inst.time > conductor.songPosition + 20 || inst.time < conductor.songPosition - 20){resyncVocals();}
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

	public function changeStrum(strum:Int){
		curStrum = strum;
		for(strum in strumsGroup.members){strum.typeStrum = "BotPlay";}
		strumsGroup.members[curStrum].typeStrum = "Playing";
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