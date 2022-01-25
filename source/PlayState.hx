package;

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

using StringTools;

class PlayState extends MusicBeatState {
	private var curSection:Int = 0;
	public static var curStrum:Int = 0;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;

	//Audio
	private var voices:FlxSoundGroup;

	public static var strumsGroup:FlxTypedGroup<StrumLineNote>;

	//Gameplay Stats
	var defaultCamZoom:Float = 1.05;
	var songLength:Float = 0;
	var songTime:Float = 0;
	var songScore:Int = 0;

	//PreSettings Variables
	var pre_TypeStrums:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeLightStrums"));
	var pre_TypeNotes:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeNotes"));
	var pre_TypeScroll:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeScroll"));
	var pre_NoteOffset:Int = PreSettings.getPreSetting("NoteOffset");
	var pre_BotPlay:Bool = PreSettings.getPreSetting("BotPlay");

	private var health:Float = 1;
	private var combo:Int = 0;

	var uiStyleCheck:String = 'Normal';

	//Cameras
	public var camBHUD:FlxCamera;
	public var camHUD:FlxCamera;
	public var camFHUD:FlxCamera;
	private var camGame:FlxCamera;

	//Other
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var startedCountdown:Bool = false;
	private var paused:Bool = false;
	private var canPause:Bool = true;

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

		Conductor.songPosition = -5000;

		strumsGroup = new FlxTypedGroup<StrumLineNote>();
		add(strumsGroup);

		strumsGroup.cameras = [camHUD];

		generateSong();

		FlxG.camera.zoom = defaultCamZoom;

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
		generateStaticArrows();

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
	
		if(!paused){FlxG.sound.playMusic(Paths.inst(SONG.song, SONG.category), 1, false);}
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

		if(SONG.needsVoices){
			if(SONG.singleVoices){
				for(i in 0...SONG.characters.length){
					var voice = new FlxSound().loadEmbedded(Paths.singleVoices(i, SONG.characters[i][0], SONG.song, SONG.category));
					FlxG.sound.list.add(voice);
					voices.add(voice);
				}
			}else{
				var voice = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, SONG.category));
				FlxG.sound.list.add(voice);
				voices.add(voice);
			}		
		}

		generatedMusic = true;
	}

	private function generateStaticArrows():Void{
		var lastStrum:StrumLineNote = null;
		for(i in 0...SONG.sectionStrums.length){
			var charStrums = new StrumLineNote(5 + (lastStrum != null ? 50 + lastStrum.noteSize * lastStrum.curKeys : 0), 30, SONG.sectionStrums[i].keys, SONG.sectionStrums[i].noteStyle);
			lastStrum = charStrums;
			charStrums.ID = i;
			strumsGroup.add(charStrums);
		}
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

	override public function update(elapsed:Float){
		super.update(elapsed);

		if(controls.PAUSE && startedCountdown && canPause){
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
	
			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1)){
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else{
				openSubState(new PauseSubState());
			}
		}

		if(FlxG.keys.justPressed.SEVEN){
			FlxG.switchState(new ChartingState());
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

		if(controls.RESET){
			health = 0;
			trace("RESET = True");
		}

		if(health <= 0){
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			for(sound in voices.sounds){sound.stop();}
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(0, 0, "Boyfriend"));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	function endSong():Void{
		canPause = false;
		FlxG.sound.music.volume = 0;
		for(sound in voices.sounds){sound.volume = 0;}
		if (SONG.validScore){
			#if !switch
			Highscore.saveScore(SONG.song, songScore, SONG.difficulty, SONG.category);
			#end
		}

		SongListData.nextSong(songScore);
		if(SongListData.songPlaylist.length <= 0){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.switchState(new MainMenuState());

			//if (SONG.validScore){
			//	NGio.unlockMedal(60961);
			//	Highscore.saveWeekScore(storyWeek, campaignScore, curDifficulty, curCategory);
			//}
		}else{
			trace('LOADING NEXT SONG');

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			SongListData.toPlayState(isStoryMode);
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
	public static var songPlaylist:Array<SwagSong> = [];
	public static var isStoryMode:Bool = false;

	public static var campaignScore:Int = 0;

	public static function addWeek(songList:Array<SwagSong>){
		for(song in songList){
			songPlaylist.push(song);
		}
	}

	public static function addSong(song:SwagSong){
		songPlaylist.push(song);
	}

	public static function toPlayState(story:Bool = false){
		isStoryMode = story;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	
	public static function nextSong(score){
		campaignScore += score;
		songPlaylist.remove(songPlaylist[0]);
	}

	public static function resetVariables(){
		campaignScore = 0;
	}
}