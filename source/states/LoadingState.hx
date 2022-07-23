package states;


import haxe.Json;
import flixel.tweens.FlxTween;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import Song.SwagSong;
import Stage;

import haxe.io.Path;

#if sys
import sys.FileSystem;
import sys.io.File;
#end


using StringTools;

class LoadingState extends MusicBeatState{
    inline static var MIN_TIME = 1.0;
	inline static var FADE_TIME = 0.5;

	private var TARGET:FlxState;
	private var SONG:SwagSong;

	private var bg:FlxSprite;

	public static function loadAndSwitchState(target:FlxState, song:SwagSong, withMusic:Bool = true){
		var load:Void->Void = function(){FlxG.switchState(new LoadingState(target, song));};
		
		if(!withMusic){
			FlxTween.tween(FlxG.sound.music, {volume: 0}, 1, {onComplete: function(twn:FlxTween){
				FlxG.sound.music.stop();
				load();
			}});
		}else{
			load();
		}
	}

	public function new(target:FlxState, song:SwagSong){
		super();

		this.TARGET = target;
		this.SONG = song;
	}

	override function create(){
		bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		add(bg);

		super.create();

		checkLibrary("shared");

		#if sys
			trace("Sys Method");
		#else
			trace("Alternative Method");
		#end

		loadSong();
		loadCharacters();

		FlxG.camera.fade(FlxG.camera.bgColor, FADE_TIME, true);
		new FlxTimer().start(FADE_TIME + MIN_TIME, function(_) onLoad());
	}

	private function onLoad(){
		FlxG.switchState(TARGET);
	}

	function loadSong(){
		trace('Loading Song [${SONG.song}] Audio Files');
		var nSong:String = SONG.song;
		
		#if sys
			if(FileSystem.exists(FileSystem.absolutePath('assets/songs/${nSong}/Audio'))){
				for(sound in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs/${nSong}/Audio'))){
					if(sound.endsWith(".ogg")){
						var sPath:String = 'songs:assets/songs/${nSong}/Audio/' + sound;
						checkSound(Std.string(sPath));
					}
				}
			}else{
				trace('Song [${nSong}]: Doesn\'t Exist');
			}
		#else
			checkSound(Paths.inst(nSong, SONG.category));
			for(i in 0...SONG.voices.length){checkSound(Paths.voice(i, SONG.voices[i], nSong, SONG.category));}
		#end
	}

	function loadCharacters(){
		trace('Loading Song [${SONG.song}] Characters');

		#if sys
			for(charData in SONG.characters){
				var char = charData[0];
				if(!FileSystem.exists(FileSystem.absolutePath('assets/characters/${char}'))){char = "Boyfriend";}

				for(file in FileSystem.readDirectory(FileSystem.absolutePath('assets/characters/${char}/Sprites'))){
					if(file.endsWith(".png") || file.endsWith(".jpg")){
						var sPath:String = 'characters:assets/characters/${char}/Sprites/' + file;
						checkBitMap(Std.string(sPath));
					}
				}
			}
		#end
	}

	function checkLibrary(library:String){
		trace("Checking Library [" + library + "]: " + Assets.hasLibrary(library));
		if(Assets.getLibrary(library) == null){
			@:privateAccess
			if(!LimeAssets.libraryPaths.exists(library)){throw "Missing library: " + library;}

			Assets.loadLibrary(library).onComplete(function (_) { trace("Library [" + library + "]: Loaded"); });
		}
	}

	function checkSound(path:String){
		if(!Assets.cache.hasSound(path)){
			Assets.loadSound(path).onComplete(function (_) { trace("Cached Sound: " + path); });
		}else{
			trace('[${path}]: Already Cached');
		}
	}

	function checkBitMap(path:String){
		if(!Assets.cache.hasBitmapData(path)){
			Assets.loadBitmapData(path).onComplete(function (_) { trace("Cached BitMap: " + path); });
		}else{
			trace('[${path}]: Already Cached');
		}
	}
}