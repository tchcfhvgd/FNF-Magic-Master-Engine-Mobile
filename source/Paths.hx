package;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetManifest;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetLibrary;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import haxe.format.JsonParser;
import openfl.utils.Assets;
import flash.media.Sound;
import haxe.io.Bytes;
import haxe.io.Path;
import flixel.FlxG;
import haxe.Json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Paths {
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	
	static var curLibrary:String = "shared";
	static public function setCurrentLibrary(name:String){curLibrary = name.toLowerCase();}

	inline static public function setTempToGlobal():Void{
		for(i in savedTempMap.keys()){savedGlobMap.set(i, savedTempMap.copy()[i]);}
		savedTempMap.clear();
	}
	public static var savedTempMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var savedGlobMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	inline static public function isSaved(file:String):Bool {
		if(savedTempMap.exists(file)){return true;}
		if(savedTempMap.exists(setPath(file))){return true;}
		if(savedGlobMap.exists(file)){return true;}
		if(savedGlobMap.exists(setPath(file))){return true;}
		return false;
	}
	inline static public function getSavedFile(file:String):Any {
		if(savedTempMap.exists(file)){return savedTempMap.get(file);}
		if(savedTempMap.exists(setPath(file))){return savedTempMap.get(setPath(file));}
		if(savedGlobMap.exists(file)){return savedGlobMap.get(file);}
		if(savedGlobMap.exists(setPath(file))){return savedGlobMap.get(setPath(file));}
		return null;
	}
	inline static public function saveFile(file:String, instance:Dynamic, isGlobal:Bool = false):Void {
		if(isGlobal){savedGlobMap.set(file, instance); return;}
		savedTempMap.set(file, instance);
	}
	
	public static function getFileName(key:String, toFile:Bool = false){
		if(toFile){return key.replace(" ", "_");}
		return key.replace("_", " ");
	}

	inline public static function exists(path:String){
		if(Assets.exists(path)){return true;}
		#if sys	if(FileSystem.exists(setPath(path))){return true;} #end

		return false;
	}

	inline public static function readDirectory(file:String, isPath:Bool = false):Array<Dynamic>{
		var toReturn:Array<Dynamic> = [];

		#if sys
		var hideVan:Bool = false;
		for(mod in ModSupport.MODS){if(mod.enabled && mod.hideVanilla){hideVan = true;}}

		var _path:String = setPath(file);

		if(!hideVan && FileSystem.exists(_path) && FileSystem.isDirectory(_path)){
			for(i in FileSystem.readDirectory(_path)){
				if(!toReturn.contains(i)){
					toReturn.push('${isPath ? '$_path/' : ''}$i');
				}
			}
		}
		
		for(mod in ModSupport.MODS){
			var mod_path:String = setPath('${mod.path}/$file');
			if(mod.enabled && FileSystem.exists(mod_path) && FileSystem.isDirectory(mod_path)){
				for(i in FileSystem.readDirectory(mod_path)){
					if(!toReturn.contains(i)){
						toReturn.push('${isPath ? '$mod_path/' : ''}$i');
					}
				}

				if(mod.onlyThis){break;}
			}
		}
		#end

		return toReturn;
	}

	inline public static function readFileToArray(file:String, forceVanilla:Bool = false):Array<Dynamic> {
		var toReturn:Array<Dynamic> = [];

		#if sys
		var hideVan:Bool = false;
		for(mod in ModSupport.MODS){if(mod.enabled && mod.hideVanilla){hideVan = true;}}
		if((forceVanilla || (!forceVanilla && !hideVan)) && FileSystem.exists(setPath(file))){toReturn.push(setPath(file));}
		for(mod in ModSupport.MODS){
			var _path = setPath('${mod.path}/$file');
			if(mod.enabled && FileSystem.exists(_path)){toReturn.push(_path);
			if(mod.onlyThis){break;}}
		}
		#end

		return toReturn;
	}
	inline public static function readFileToMap(file:String):Map<String, Dynamic> {
		var toReturn:Map<String, Dynamic> = [];
		#if sys
		var hideVan:Bool = false; var i:Int = 0;
		for(mod in ModSupport.MODS){if(mod.enabled && mod.hideVanilla){hideVan = true;}}
		if(!hideVan && FileSystem.exists(setPath(file))){toReturn.set('$i|Friday Night Funkin', setPath(file)); i++;}
		for(mod in ModSupport.MODS){if(mod.enabled && FileSystem.exists(setPath('${mod.path}/$file'))){toReturn.set('$i|${mod.name}', setPath('${mod.path}/$file')); i++; if(mod.onlyThis){break;}}}
		#end

		return toReturn;
	}

	public static function setPath(key):String {return #if sys FileSystem.absolutePath(key) #else key #end;}
	public static function getPath(file:String, type:AssetType, library:Null<String>, ?mod_name:String){
		if(mod_name != null){return getModPath(file, mod_name);}		
		if(library != null){return getLibraryPath(file, library);}

		if (curLibrary != null){
			var levelPath = getLibraryPathForce(file, curLibrary);
			if(Paths.exists(levelPath)){return levelPath;}

			levelPath = getLibraryPathForce(file, "shared");
			if(Paths.exists(levelPath)){return levelPath;}
		}

		return getForcedPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload"){
		return if (library == "preload" || library == "default") getForcedPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String){
		var path = getForcedPath('$library/$file');
		if(!Paths.exists(path)){path = '$library:assets/$library/$file';}
		return path;
	}

	inline static function getForcedPath(file:String){
		var path = '';
		for(mod in ModSupport.MODS){
			if(!mod.enabled){continue;}
			path = '${mod.path}/assets/$file';
			if(mod.onlyThis #if sys || FileSystem.exists(path) #end){break;}
		}
		if(!Assets.exists(path) #if sys && !FileSystem.exists(path) #end){path = 'assets/$file';}
		return path;
	}
	inline static function getModPath(file:String, mod_name:String){
		var path = '';
		for(mod in ModSupport.MODS){
			if(mod.name != mod_name){continue;}
			path = '${mod.path}/assets/$file';
			break;
		}
		if(!Assets.exists(path) #if sys && !FileSystem.exists(path) #end){path = 'assets/$file';}
		return path;
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String){
		return getPath(file, type, library);
	}

	inline public static function getSound(file:String):Sound{
		if(getSavedFile(file)){return getSavedFile(file);}

		saveFile(file, Assets.exists(file) ? Assets.getSound(file) : Sound.fromFile(file));

		return getSavedFile(file);
	}
	inline public static function getBytes(file:String):Any{
		if(isSaved(file)){return getSavedFile(file);}

		saveFile(file, Assets.exists(file) ? Assets.getBytes(file) : File.getBytes(file));
		
		return getSavedFile(file);
	}
	inline public static function getGraphic(file:String):Any{
		if(isSaved(file)){return getSavedFile(file);}

		var bit:BitmapData = BitmapData.fromFile(file);

		if(bit == null){return file;}

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bit, false, file);
		graphic.persist = true;

		saveFile(file, graphic);
		
		return getSavedFile(file);
	}
	inline public static function getText(file:String):String{
		if(isSaved(file)){return getSavedFile(file);}
		
		saveFile(file, Assets.exists(file) ? Assets.getText(file) : File.getContent(file));
		
		return getSavedFile(file);
	}

	inline static public function image(key:String, ?library:String, isPath:Bool = false, ?mod_name:String):Any {
		var path = getPath('images/$key.png', IMAGE, library, mod_name);
		
		return isPath ? path : getGraphic(path);
	}
		
	inline static public function styleImage(key:String, style:String = "Default", ?library:String, isPath:Bool = false, ?mod:String):Any {
		var path = getPath('images/style_UI/$style/$key.png', IMAGE, library, mod);

		if(!Paths.exists(path)){path = getPath('images/style_UI/Default/$key.png', IMAGE, library, mod);}

		return isPath ? path : getGraphic(path);
	}
	

	inline static public function font(key:String, ?mod:String){
		return getPath('$key', TEXT, 'fonts', mod);
	}

	inline static public function txt(key:String, ?library:String, isPath:Bool = false, ?mod:String){
		var path = getPath('data/$key.txt', TEXT, library, mod);
		return isPath ? path : getText(path);
	}

	inline static public function shader(key:String, ?library:String, isPath:Bool = false, ?mod:String){
		var path = getPath('shaders/$key.frag', TEXT, library, mod);
		return isPath ? path : getText(path);
	}

	inline static public function xml(key:String, ?library:String, isPath:Bool = false, ?mod:String){
		var path = getPath('data/$key.xml', TEXT, library, mod);
		return isPath ? path : getText(path);
	}

	inline static public function json(key:String, ?library:String, isPath:Bool = false, ?mod:String):Dynamic{
		var path = getPath('data/$key.json', TEXT, library, mod);
		return isPath ? path : Json.parse(getText(path));
	}

	static public function sound(key:String, ?library:String, isPath:Bool = false, ?mod:String):Dynamic {
		var path = getPath('sounds/$key.$SOUND_EXT', SOUND, library, mod);
		return isPath ? path : getSound(path);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String, isPath:Bool = false, ?mod:String){
		return sound(key + FlxG.random.int(min, max), library, isPath, mod);
	}

	inline static public function music(key:String, ?library:String, isPath:Bool = false, ?mod:String):Dynamic{
		var path = getPath('music/$key.$SOUND_EXT', MUSIC, library, mod);
		return isPath ? path : getSound(path);
	}

	inline static public function voice(id:Int, char:String, song:String, category:String, isPath:Bool = false, ?mod:String):Dynamic {
		var path = getPath('${song}/Audio/${id}-${char}-${category}.$SOUND_EXT', SOUND, 'songs', mod);

		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Default-${category}.$SOUND_EXT', SOUND, 'songs', mod);}
		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Default.$SOUND_EXT', SOUND, 'songs', mod);}
			
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices-${category}.$SOUND_EXT', SOUND, 'songs', mod);}
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices.$SOUND_EXT', SOUND, 'songs', mod);}
			
		return isPath ? path : getSound(path);
	}

	inline static public function inst(song:String, category:String, isPath:Bool = false, ?mod:String):Any {
		var path = getPath('${song}/Audio/Inst-${category}.$SOUND_EXT', MUSIC, 'songs', mod);

		if(!Paths.exists(path)){path = getPath('${song}/Audio/Inst.$SOUND_EXT', MUSIC, 'songs', mod);}
		
		return isPath ? path : getSound(path);
	}

	inline static public function chart_events(jsonInput:String, ?mod:String):String {
		var path = getPath('${jsonInput.split('-')[0]}/Data/global_events.json', TEXT, 'songs', mod);
		
		if(!Paths.exists(path)){path = getPath('Test/Data/global_events.json', TEXT, 'songs', mod);}
	
		return path;
	}
	inline static public function chart(jsonInput:String, ?mod:String):String {
		var path = getPath('${jsonInput.split('-')[0]}/Data/${jsonInput}.json', TEXT, 'songs', mod);

		if(!Paths.exists(path)){path = getPath('Test/Data/Test-Normal-Normal.json', TEXT, 'songs', mod);}

		return path;
	}
	
	inline static public function character(char:String, key:String, ?mod:String){
		return getPath('${char}/Sprites/${key}.png', IMAGE, 'characters', mod);
	}

	inline static public function stage(key:String, ?mod:String){
		var path = getPath('${key}.hx', TEXT, 'stages', mod);

		if(!Paths.exists(path)){path = getPath('Stage.hx', TEXT, 'stages', mod);}

		return path;
	}

	inline static public function colorNote(key:String):String {
		var fileName:String = key.split("/").pop();
		var toReturn:String = "None";
		if(!Paths.exists(key.replace(fileName,"") + "colors.txt")){return toReturn;}
		var arrColors:Array<String> = Paths.getText(key.replace(fileName,"") + "colors.txt").split("\n");
		for(t in arrColors){var tt:Array<String> = t.split(":"); if(tt[0] == fileName){toReturn = tt[1];}}
		return toReturn;
	}
	
	inline static public function note(image:String, style:String, ?type:String, ?mod:String){
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}
		
		var path:String = getPath('${type}/${style}/${image}.png', IMAGE, 'notes', mod);
		if(!Paths.exists(path)){path = getPath('${type}/Default/${image}.png', IMAGE, 'notes', mod);}
		if(!Paths.exists(path)){path =  getPath('Default/Default/${image}.png', IMAGE, 'notes', mod);}
		
		return path;
	}

	inline static public function event(key:String, ?mod:String){
		var path = getPath('events/$key/${key}.hx', TEXT, 'data', mod);
		if(!Paths.exists(path)){path = getPath('note_events/$key/${key}.hx', TEXT, 'data', mod);}
		return path;
	}
	inline static public function event_info(key:String, ?mod:String):Array<Dynamic> {
		var pre_Language:String = PreSettings.getPreSetting("Language","Game Settings");

		var path = getPath('events/$key/information/lang_${pre_Language}.json', TEXT, 'data', mod);
		if(!Paths.exists(path)){path = getPath('note_events/$key/information/lang_${pre_Language}.json', TEXT, 'data', mod);}

		if(Paths.exists(path)){return Json.parse(getText(path)).information;}
		return null;
	}
	
	inline static public function strumline_json(keys:Int, ?type:String, isPath:Bool = false):StrumLine.StrumLine_Graphic_Data {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}

		var path = getPath('${type}/${keys}k.json', TEXT, 'notes');
		if(!Paths.exists(path)){path = getPath('Default/${keys}k.json', TEXT, 'notes');}
		if(!Paths.exists(path)){path = getPath('Default/_k.json', TEXT, 'notes');}

		return cast Json.parse(getText(path));
	}

	inline static public function note_json(data:Int, keys:Int, ?type:String):Note.Note_Graphic_Data {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}

		var strumJSON:StrumLine.StrumLine_Graphic_Data = strumline_json(keys, type);
		var noteJSON:Note.Note_Graphic_Data = strumJSON.gameplay_notes.notes[data % keys];

		if(strumJSON == null || strumJSON.gameplay_notes == null || strumJSON.gameplay_notes.general_animations == null || strumJSON.gameplay_notes.general_animations.length <= 0){return noteJSON;}
		for(anim in strumJSON.gameplay_notes.general_animations){noteJSON.animations.push(anim);}
		return noteJSON;
	}

	inline static public function strum_json(data:Int, keys:Int, ?type:String):Note.Note_Graphic_Data {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}

		var strumJSON:StrumLine.StrumLine_Graphic_Data = strumline_json(keys, type);
		var noteJSON:Note.Note_Graphic_Data = strumJSON.static_notes.notes[data % keys];
		
		if(strumJSON == null || strumJSON.gameplay_notes == null || strumJSON.static_notes.general_animations == null || strumJSON.static_notes.general_animations.length <= 0){return noteJSON;}
		for(anim in strumJSON.static_notes.general_animations){noteJSON.animations.push(anim);}
		return noteJSON;
	}

	inline static public function getCharacterJSON(char:String, skin:String, cat:String, ?mod:String){
		var path = getPath('${char}/Skins/${char}-${skin}-${cat}.json', TEXT, 'characters', mod);

		if(!Paths.exists(path)){path = getPath('${char}/Skins/${char}-${skin}-Default.json', TEXT, 'characters', mod);}
		if(!Paths.exists(path)){path = getPath('${char}/Skins/${char}-Default-Default.json', TEXT, 'characters', mod);}
		if(!Paths.exists(path)){path = getPath('Boyfriend/Skins/Boyfriend-Default-Default.json', TEXT, 'characters', mod);}

		return Json.parse(getText(path));
	}

	inline static public function getSparrowAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png","").replace('.xml','');
		var custom_path:String = '$path.custom_atlas';

		if(isSaved(custom_path)){return getSavedFile(custom_path);}

		var bit = Paths.getGraphic('$path.png');
		var xml = Paths.getText('$path.xml');

		if(bit == null|| xml == null){return null;}

		saveFile(custom_path, FlxAtlasFrames.fromSparrow(bit, xml));
		return getSavedFile(custom_path);
	}

	inline static public function getPackerAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png","").replace('.txt','');
		var custom_path:String = '$path.custom_atlas';

		if(isSaved(custom_path)){return getSavedFile(custom_path);}

		var bit = Paths.getGraphic('$path.png');
		var txt = Paths.getText('$path.txt');

		if(bit == null|| txt == null){return null;}

		saveFile(custom_path, FlxAtlasFrames.fromSpriteSheetPacker(bit, txt));
		return getSavedFile(custom_path);
	}

	static public function getAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png", "").replace(".xml", "").replace(".txt", "");
		
		if(Paths.exists('${path}.xml')){return getSparrowAtlas('$path.xml');}
		else if(Paths.exists('${path}.txt')){return getPackerAtlas('$path.txt');}
		return null;
	}
}
