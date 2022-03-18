package states;

import Song.SwagSong;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import ListStuff;

import haxe.io.Path;

class LoadingState extends MusicBeatState{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;
	
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;

	var songToLoad:SwagSong;
	
	function new(target:FlxState, song:SwagSong = null, stopMusic:Bool = false){
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.songToLoad = song;
	}
	
	override function create(){
		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = true;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logo);

		if(songToLoad == null){songToLoad = PlayState.SongListData.songPlaylist[0];} 
		trace("Loading: " + songToLoad.song);
		
		initSongsManifest().onComplete(
			function (lib){
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				
				checkLibrary("shared");

				checkLoadSong(songToLoad.song);

				var characters = [];
				for(char in songToLoad.characters){
					characters.push(char[0]);
				}
				checkCharacters(characters);
				
				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
	}

	function checkBitMap(path:String){
		if (!Assets.cache.hasBitmapData(path)){
			var callback = callbacks.add("BitMap: " + path);
			Assets.loadBitmapData(path).onComplete(function (_) { callback(); });
			trace("Cached BitMap: " + path);
		}
	}

	function checkSound(path:String){
		if (!Assets.cache.hasSound(path)){
			var callback = callbacks.add("Sound: " + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
			trace("Cached Sound: " + path);
		}
	}

	function checkCharacters(path:Array<String>){
		for(char in path){
			var sprites = Characters.checkSprites(char);

			for(sprite in sprites){
				if (!Assets.cache.hasBitmapData(sprite[1])){
					var callback = callbacks.add("Character (" + char + "): " + sprite[1]);
					Assets.loadBitmapData(Std.string(sprite[1])).onComplete(function (_) { callback(); });
					trace("Cached " + char + " Sprite: " + sprite[1]);
				}
			}
		}
	}

	function checkLoadSong(path:String){
		var sounds = Songs.checkAudios(path);
		for(sound in sounds){
			if (!Assets.cache.hasSound(Std.string(sound[1]))){
				var callback = callbacks.add("Song (" + path + "): " + sound[1]);
				Assets.loadSound(Std.string(sound[1])).onComplete(function (_) { callback(); });
				trace("Cached " + path + " Sound: " + sound[1]);
			}
		}
	}
	
	function checkLibrary(library:String){
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;
			
			var callback = callbacks.add("Library: " + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		logo.animation.play('bump');
		danceLeft = !danceLeft;
		
		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, song:SwagSong = null, stopMusic = false){
		Paths.setCurrentLevel("week1");
		FlxG.switchState(new LoadingState(target, song, stopMusic));
	}
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}