package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.format.JsonParser;
import flash.media.Sound;
import haxe.io.Path;
import haxe.Json;

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

	inline public static function exists(path:String){
		if(OpenFlAssets.exists(path)){return true;}
		#if sys	if(FileSystem.exists(FileSystem.absolutePath(path))){return true;} #end

		return false;
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>){
		if (library != null){return getLibraryPath(file, library);}

		if (curLibrary != null){
			var levelPath = getLibraryPathForce(file, curLibrary);
			if(Paths.exists(levelPath)){return levelPath;}

			levelPath = getLibraryPathForce(file, "shared");
			if(Paths.exists(levelPath)){return levelPath;}
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload"){
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String){
		var path = '$library:assets/$library/$file';
		if(!Paths.exists(path)){path = getPreloadPath('$library/$file');}
		return path;
	}

	inline static function getPreloadPath(file:String){
		var path = '';
		for(mod in ModSupport.MODS){
			#if sys if(FileSystem.exists(path)){break;} #end
			if(mod.enabled){path = '${mod.path}/assets/$file';}
		}
		#if sys if(!FileSystem.exists(path)){path = 'assets/$file';} #else path = 'assets/$file'; #end
		return path;
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String){
		return getPath(file, type, library);
	}
	
	private static var savedMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static function getSound(file:String):Sound{
		if(!savedMap.exists(file)){savedMap.set(file, Assets.exists(file) ? Assets.getSound(file) : Sound.fromFile(file));}
		return savedMap.get(file);
	}
	private static function getGraphic(file):Any{
		if(savedMap.exists(file)){return savedMap.get(file);}

		var bit:BitmapData = BitmapData.fromFile(file);
		var graphic:Dynamic = null;
		if(bit != null){
			graphic = FlxGraphic.fromBitmapData(bit, false, file);
			graphic.persist = true;
		}else{
			graphic = file;
		}
		savedMap.set(file, graphic);
		
		return savedMap.get(file);
	}
	public static function getText(file:String):String{
		if(savedMap.exists(file)){return savedMap.get(file);}
		
		#if sys
		if(Assets.exists(file, TEXT)){savedMap.set(file, Assets.getText(file));}
		if(FileSystem.exists(FileSystem.absolutePath(file))){savedMap.set(file, File.getContent(FileSystem.absolutePath(file)));}
		#else
		if(Assets.exists(file, TEXT)){savedMap.set(file, Assets.getText(file));}
		#end
		
		if(!savedMap.exists(file)){return null;}
		return savedMap.get(file);
	}

	inline static public function image(key:String, ?library:String):Any {
		var path = getPath('images/$key.png', IMAGE, library);
		
		return getGraphic(path);
	}
		
	inline static public function styleImage(key:String, style:String = "Default", ?library:String):Any {
		var path = getPath('images/style_UI/$style/$key.png', IMAGE, library);

		if(!Paths.exists(path)){path = getPath('images/style_UI/Default/$key.png', IMAGE, library);}

		return getGraphic(path);
	}

	inline static public function txt(key:String, ?library:String){
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String){
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String){
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String):Sound{
		return getSound(getPath('sounds/$key.$SOUND_EXT', SOUND, library));
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String){
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound{
		return getSound(getPath('music/$key.$SOUND_EXT', MUSIC, library));
	}

	inline static public function voice(id:Int, char:String, song:String, category:String):Sound {
		var path = getPath('${song}/Audio/${id}-${char}-${category}.$SOUND_EXT', SOUND, 'songs');

		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-${char}.$SOUND_EXT', SOUND, 'songs');}
		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-${char}Voice-${category}.$SOUND_EXT', SOUND, 'songs');}

		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Voice-${category}.$SOUND_EXT', SOUND, 'songs');}
		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Voice.$SOUND_EXT', SOUND, 'songs');}
			
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices-${category}.$SOUND_EXT', SOUND, 'songs');}
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices.$SOUND_EXT', SOUND, 'songs');}
			
		return getSound(path);
	}

	inline static public function inst(song:String, category:String):Any {
		var path = getPath('${song}/Audio/Inst-${category}.$SOUND_EXT', MUSIC, 'songs');

		if(!Paths.exists(path)){path = getPath('${song}/Audio/Inst.$SOUND_EXT', MUSIC, 'songs');}
		
		trace(path);
		return getSound(path);
	}

	inline static public function chart(jsonInput:String, song:String):String {
		var path = getPath('${song}/Data/${jsonInput}.json', TEXT, 'songs');

		if(!Paths.exists(path)){path = getPath('Template.json', TEXT, 'songs');}

		return path;
	}

	inline static public function font(key:String){
		return 'assets/fonts/$key';
	}

	inline static public function getStageJSON(key:String){key = Paths.getFileName(key);
		var path = getPath('${key}.json', TEXT, 'stages');

		if(!Paths.exists(path)){path = getPath('Stage.json', TEXT, 'stages');}

		return path;
	}

	inline static public function getStrumJSON(keys:Int, typeStrum:String = null){
		if(typeStrum == null){typeStrum = PreSettings.getFromArraySetting("NoteSyle");}
		var path = getPath('${typeStrum}/${keys}k.json', TEXT, 'notes');

		if(!Paths.exists(path)){path = getPath('Default/${keys}k.json', TEXT, 'notes');}
		if(!Paths.exists(path)){path = getPath('Default/_k.json', TEXT, 'notes');}

		return path; 
	}

	inline static public function getCharacterJSON(char:String, cat:String, skin:String){char = Paths.getFileName(char); cat = Paths.getFileName(cat); skin = Paths.getFileName(skin);
		var path = getPath('${char}/Skins/${char}-${cat}-${skin}.json', TEXT, 'characters');

		if(!Paths.exists(path)){path = getPath('${char}/Skins/${char}-Default-${skin}.json', TEXT, 'characters');}
		if(!Paths.exists(path)){path = getPath('${char}/Skins/${char}-Default-Default.json', TEXT, 'characters');}
		if(!Paths.exists(path)){path = getPath('Boyfriend/Skins/Boyfriend-Default-Default.json', TEXT, 'characters');}

		return path; 
	}

	inline static public function getSparrowAtlas(key:String, ?library:String){
		return FlxAtlasFrames.fromSparrow(Paths.getGraphic(getPath('images/$key.png', IMAGE, library)), Paths.getText(file('images/$key.xml', library)));
	}

	inline static public function getPackerAtlas(key:String, ?library:String){
		return FlxAtlasFrames.fromSpriteSheetPacker(Paths.getGraphic(getPath('images/$key.png', IMAGE, library)), Paths.getText(file('images/$key.txt', library)));
	}

	inline static public function getCharacterAtlas(char:String, key:String){
		char = Paths.getFileName(char);

		var path = getPath('${char}/Sprites/${key}', IMAGE, 'characters');
		
		return getAtlas(path);
	}

	inline static public function getNoteAtlas(key:String, typeCheck:String = "Default"){
		var typeNotes:String = PreSettings.getFromArraySetting("NoteSyle");

		var path:String = getPath('${typeNotes}/${typeCheck}/${key}', IMAGE, 'notes');
		if(!Paths.exists('${path}.png')){path = getPath('${typeNotes}/Default/${key}', IMAGE, 'notes');}
		if(!Paths.exists('${path}.png')){path =  getPath('Default/Default/${key}', IMAGE, 'notes');}

		return getAtlas(path);
	}

	inline static public function getStageAtlas(key:String, ?directory:String = "Stage"){
		var imagePath = getPath('images/${directory}/${key}', IMAGE, 'stages');
		var path = getPath('images/${directory}/${key.split(".")[0]}', TEXT, 'stages');

		if(!Paths.exists(imagePath)){
			imagePath = getPath('images/Stage/${key}', IMAGE, 'stages');
			path = getPath('images/Stage/${key.split(".")[0]}', TEXT, 'stages');
		}

		return getAtlas(path);
	}

	inline static public function getAtlas(path:String){
		if(Paths.exists('${path}.xml')){return FlxAtlasFrames.fromSparrow(Paths.getGraphic('${path}.png'), Paths.getText('${path}.xml'));}
		return FlxAtlasFrames.fromSpriteSheetPacker(Paths.getGraphic('${path}.png'), Paths.getText('${path}.txt'));
	}
}
