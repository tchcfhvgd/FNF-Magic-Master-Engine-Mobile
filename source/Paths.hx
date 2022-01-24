package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end

import ListStuff;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, category:String)
	{
		#if desktop
			return Songs.getSongAudioPath("Voices", song, category);
		#else
			return 'songs:assets/songs/${song}/Audio/Voices-${category}.$SOUND_EXT';
		#end
	}

	inline static public function singleVoices(id:Int, char:String, song:String, category:String)
		{
			#if desktop
				return Songs.getSongAudioPath(char, song, category, true, id);
			#else
				return 'songs:assets/songs/${song}/Audio/${id}-${char}Voices-${category}.$SOUND_EXT';
			#end
		}

	inline static public function inst(song:String, category:String){
		#if desktop
			return ListStuff.Songs.getSongAudioPath("Inst", song, category);
		#else
			return 'songs:assets/songs/${song}/Audio/Inst-${category}.$SOUND_EXT';
		#end
	}

	inline static public function chart(jsonInput:String, song:String){
		#if desktop
			return ListStuff.Songs.getChartPath(jsonInput, song);
		#else
			return 'songs:assets/songs/${song}/Data/${jsonInput}.json';
		#end
	}

	inline static public function strumline(keys:Int){
		var typeNotes = PreSettings.getArraySetting(PreSettings.getPreSetting("NoteSyle"));
		var toReturn = '';

		toReturn = 'notes:assets/notes/${typeNotes}/${keys}k.json';

		#if desktop
		if(!FileSystem.exists(toReturn)){
			toReturn = 'notes:assets/notes/Default/${keys}k.json';
		}
		#end

		return toReturn; 
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getNoteAtlas(key:String, typeCheck:String){
		var typeNotes = PreSettings.getArraySetting(PreSettings.getPreSetting("NoteSyle"));

		var curTypeCheck = typeCheck;
		var curTypeNotes = typeNotes;

		var imagePath = 'notes:assets/notes/${curTypeNotes}/${curTypeCheck}/${image}.png';

		while(!Assets.exists(imagePath)){
			if(curTypeCheck == typeCheck && curTypeNotes == typeNotes){
				curTypeCheck = 'Default';
			}else if(curTypeCheck != typeCheck && curTypeNotes == typeNotes){
				curTypeNotes = 'Default';
			}else if(curTypeCheck == 'Default' && curTypeNotes == 'Default'){
				break;	
			}

			imagePath = 'notes:assets/notes/${curTypeNotes}/${curTypeCheck}/${image}.png';
		}

		var path = 'notes:assets/notes/${curTypeNotes}/${curTypeCheck}/${image}.xml';

		if(Assets.exists(path)){
			return FlxAtlasFrames.fromSparrow(imagePath, path);
		}else{
			path = 'notes:assets/notes/${curTypeNotes}/${curTypeCheck}/${image}.txt';
			return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, path);
		}
	}
}