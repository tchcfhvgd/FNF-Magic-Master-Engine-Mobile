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

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static function getFileName(key:String, toNormal:Bool = false){
		if(toNormal){
			return key.replace("_", " ");
		}else{
			return key.replace(" ", "_");
		}
	}

	static var curLibrary:String = "shared";

	static public function setCurrentLibrary(name:String){
		curLibrary = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>){
		if (library != null){return getLibraryPath(file, library);}

		if (curLibrary != null){
			var levelPath = getLibraryPathForce(file, curLibrary);
			if(OpenFlAssets.exists(levelPath, type)){return levelPath;}

			levelPath = getLibraryPathForce(file, "shared");
			if(OpenFlAssets.exists(levelPath, type)){return levelPath;}
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

	inline static public function voice(id:Int, char:String, song:String, category:String){
		var path = 'songs:assets/songs/${song}/Audio/${id}-${char}-${category}.$SOUND_EXT';
		if(!Assets.exists(path)){path = 'songs:assets/songs/${song}/Audio/${id}-${char}.$SOUND_EXT';}

		if(!Assets.exists(path)){path = 'songs:assets/songs/${song}/Audio/${id}-${char}Voice-${category}.$SOUND_EXT';}

		if(!Assets.exists(path)){path = 'songs:assets/songs/${song}/Audio/${id}-Voice-${category}.$SOUND_EXT';}
		if(!Assets.exists(path)){path = 'songs:assets/songs/${song}/Audio/${id}-Voice.$SOUND_EXT';}
			
		if(!Assets.exists(path) && id == 0){path = 'songs:assets/songs/${song}/Audio/Voices-${category}.$SOUND_EXT';}
		if(!Assets.exists(path) && id == 0){path = 'songs:assets/songs/${song}/Audio/Voices.$SOUND_EXT';}
			
		return path;
	}

	inline static public function inst(song:String, category:String){
		var path = 'songs:assets/songs/${song}/Audio/Inst-${category}.$SOUND_EXT';

		if(!Assets.exists(path)){path = 'songs:assets/songs/${song}/Audio/Inst.$SOUND_EXT';}

		return path;
	}

	inline static public function chart(jsonInput:String, song:String){
		var path = 'songs:assets/songs/${song}/Data/${jsonInput}.json';

		if(!Assets.exists(path)){path = 'songs:assets/songs/Template.json';}

		return path;
	}

	inline static public function image(key:String, ?library:String){
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String){
		return 'assets/fonts/$key';
	}

	inline static public function StageJSON(key:String){
		var toReturn = 'stages:assets/stages/${key}.json';

		if(!Assets.exists(toReturn)){toReturn = 'stages:assets/stages/Stage.json';}

		return toReturn;
	}

	inline static public function strumJSON(keys:Int, typeStrum:String = null){
		if(typeStrum == null){typeStrum = PreSettings.getFromArraySetting("NoteSyle");}
		var toReturn = '';

		toReturn = 'notes:assets/notes/${typeStrum}/${keys}k.json';

		if(!Assets.exists(toReturn)){toReturn = 'notes:assets/notes/Default/${keys}k.json';}
		if(!Assets.exists(toReturn)){toReturn = 'notes:assets/notes/Default/_k.json';}

		return toReturn; 
	}

	inline static public function getCharacterJSON(char:String, cat:String,skin:String){
		var toReturn = 'characters:assets/characters/${char}/Skins/${char}-${cat}-${skin}.json';

		if(!Assets.exists(toReturn)){toReturn = 'characters:assets/characters/${char}/Skins/${char}-Default-${skin}.json';}
		if(!Assets.exists(toReturn)){toReturn = 'characters:assets/characters/${char}/Skins/${char}-Default-Default.json';}
		if(!Assets.exists(toReturn)){toReturn = 'characters:assets/characters/Boyfriend/Skins/Boyfriend-Default-Default.json';}

		return toReturn; 
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getCharacterAtlas(char:String, key:String){
		var imagePath = 'characters:assets/characters/${char}/Sprites/${key}.png';
		var descPath = 'characters:assets/characters/${char}/Sprites/${key}.xml';

		if(!Assets.exists(descPath)){
			descPath = 'characters:assets/characters/${char}/Sprites/${key}.txt';
			return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, descPath);
		}else{
			return FlxAtlasFrames.fromSparrow(imagePath, descPath);
		}
	}

	inline static public function getNoteAtlas(key:String, typeCheck:String = "Default"){
		var typeNotes:String = PreSettings.getFromArraySetting("NoteSyle");

		var path:String = 'notes:assets/notes/${typeNotes}/${typeCheck}/${key}';
		if(!Assets.exists('${path}.png')){path = 'notes:assets/notes/${typeNotes}/Default/${key}';}
		if(!Assets.exists('${path}.png')){path = 'notes:assets/notes/Default/Default/${key}';}

		return getAtlas(path);
	}

	inline static public function getStageAtlas(key:String, ?directory:String = "Stage"){
		var imagePath = 'stages:assets/stages/images/${directory}/${key}';
		var path = 'stages:assets/stages/images/${directory}/${key.split(".")[0]}';

		if(!Assets.exists(imagePath)){
			imagePath = 'stages:assets/stages/images/Stage/${key}';
			path = 'stages:assets/stages/images/Stage/${key.split(".")[0]}';
		}

		if(Assets.exists(path + '.xml')){
			return FlxAtlasFrames.fromSparrow(imagePath, path + '.xml');
		}else{
			return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, path+ '.txt');
		}
	}

	inline static public function getAtlas(path:String){
		if(Assets.exists('${path}.xml')){
			return FlxAtlasFrames.fromSparrow('${path}.png', '${path}.xml');
		}else{
			return FlxAtlasFrames.fromSpriteSheetPacker('${path}.png', '${path}.txt');
		}
	}
}
