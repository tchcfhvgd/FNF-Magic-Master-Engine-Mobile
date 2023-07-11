package;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetManifest;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetLibrary;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import haxe.format.JsonParser;
import flixel.math.FlxPoint;
import flash.geom.Rectangle;
import openfl.utils.Assets;
import flixel.math.FlxRect;
import flash.media.Sound;
import haxe.xml.Access;
import haxe.io.Bytes;
import haxe.io.Path;
import flixel.FlxG;
import haxe.Json;

import Character.Skins;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Paths {
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
		
	public static function getFileName(key:String, toFile:Bool = false){
		if(toFile){return key.replace(" ", "_");}
		return key.replace("_", " ");
	}

	inline public static function exists(path:String){
		if(Assets.exists(path)){return true;}
		#if sys	if(FileSystem.exists(setPath(path))){return true;} #end
		return false;
	}

	inline public static function readDirectory(file:String):Array<String> {
		var toReturn:Array<String> = [];

		#if sys
		var _path:String = setPath(file);

		if(FileSystem.exists(_path) && FileSystem.isDirectory(_path)){
			for(i in FileSystem.readDirectory(_path)){
				if(!toReturn.contains(i)){
					toReturn.push('$_path/$i');
				}
			}
		}
		
		for(mod in ModSupport.MODS){
			var mod_path:String = setPath('${mod.path}/$file');
			if(mod.enabled && FileSystem.exists(mod_path) && FileSystem.isDirectory(mod_path)){
				for(i in FileSystem.readDirectory(mod_path)){
					if(!toReturn.contains(i)){
						toReturn.push('$mod_path/$i');
					}
				}

				if(mod.onlyThis){break;}
			}
		}
		#end

		return toReturn;
	}

	inline public static function readFile(file:String):Array<String> {
		var toReturn:Array<String> = [];

		#if sys
		if(FileSystem.exists(setPath(file))){toReturn.push(setPath(file));}
		for(mod in ModSupport.MODS){
			var _path = setPath('${mod.path}/$file');
			if(mod.enabled && FileSystem.exists(_path)){toReturn.push(_path);
			if(mod.onlyThis){break;}}
		}
		#end

		return toReturn;
	}

	public static function setPath(key):String {return #if sys FileSystem.absolutePath(key) #else key #end;}
	public static function getPath(file:String, type:AssetType, library:Null<String>, ?mod_name:String){
		if(mod_name != null){return getModPath(file, mod_name);}
		if(library != null){return getLibraryPath(file, library);}

		var levelPath = getLibraryPathForce(file, "shared");
		if(Paths.exists(levelPath)){return levelPath;}

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

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String, ?mod:String):String {return getPath(file, type, library, mod);}
	inline static public function sound(key:String, ?library:String, ?mod:String):String {return getPath('sounds/$key.$SOUND_EXT', SOUND, library, mod);}
	inline static public function music(key:String, ?library:String, ?mod:String):String {return getPath('music/$key.$SOUND_EXT', MUSIC, library, mod);}
	inline static public function shader(key:String, ?library:String, ?mod:String):String {return getPath('shaders/$key.frag', TEXT, library, mod);}
	inline static public function song_script(song:String, ?mod:String):String {return getPath('${song}/Data/Song_Events.hx', TEXT, 'songs', mod);}
	inline static public function image(key:String, ?library:String, ?mod:String):String {return getPath('images/$key.png', IMAGE, library, mod);}
	inline static public function json(key:String, ?library:String, ?mod:String):String {return getPath('data/$key.json', TEXT, library, mod);}
	inline static public function xml(key:String, ?library:String, ?mod:String):String {return getPath('images/$key.xml', TEXT, library, mod);}
	inline static public function txt(key:String, ?library:String, ?mod:String):String {return getPath('data/$key.txt', TEXT, library, mod);}
	inline static public function text(key:String, ?library:String, ?mod:String):String {return getPath('data/$key', TEXT, library, mod);}
	inline static public function font(key:String, ?mod:String):String {return getPath('$key', TEXT, 'fonts', mod);}
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String, ?mod:String):String {
		return sound(key + FlxG.random.int(min, max), library, mod);
	}
	inline static public function styleImage(key:String, style:String = "Default", ?library:String, ?mod:String):String {
		var path = getPath('images/style_UI/$style/$key.png', IMAGE, library, mod);
		if(!Paths.exists(path)){path = getPath('images/style_UI/Default/$key.png', IMAGE, library, mod);}
		return path;
	}
	inline static public function styleSound(key:String, style:String = "Default", ?library:String, ?mod:String):String {
		var path = getPath('sounds/style_UI/$style/$key.$SOUND_EXT', SOUND, library, mod);
		if(!Paths.exists(path)){path = getPath('sounds/style_UI/Default/$key.$SOUND_EXT', SOUND, library, mod);}
		return path;
	}
	inline static public function styleMusic(key:String, style:String = "Default", ?library:String, ?mod:String):String {
		var path = getPath('music/style_UI/$style/$key.$SOUND_EXT', MUSIC, library, mod);
		if(!Paths.exists(path)){path = getPath('music/style_UI/Default/$key.$SOUND_EXT', SOUND, library, mod);}
		return path;
	}	
	inline static public function inst(song:String, category:String, ?mod:String):String {
		var path = getPath('${song}/Audio/Inst-${category}.$SOUND_EXT', MUSIC, 'songs', mod);
		if(!Paths.exists(path)){path = getPath('${song}/Audio/Inst.$SOUND_EXT', MUSIC, 'songs', mod);}
		return path;
	}
	inline static public function voice(id:Int, char:String, song:String, category:String, ?mod:String):String {
		var path = getPath('${song}/Audio/${id}-${char}-${category}.$SOUND_EXT', SOUND, 'songs', mod);
		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Default-${category}.$SOUND_EXT', SOUND, 'songs', mod);}
		if(!Paths.exists(path)){path = getPath('${song}/Audio/${id}-Default.$SOUND_EXT', SOUND, 'songs', mod);}
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices-${category}.$SOUND_EXT', SOUND, 'songs', mod);}
		if(!Paths.exists(path) && id == 0){path = getPath('${song}/Audio/Voices.$SOUND_EXT', SOUND, 'songs', mod);}
		return path;
	}
	inline static public function chart(jsonInput:String, ?mod:String):String {
		var path = getPath('${jsonInput.split('-')[0]}/Data/${jsonInput}.json', TEXT, 'songs', mod);
		if(!Paths.exists(path)){path = getPath('Test/Data/Test-Normal-Normal.json', TEXT, 'songs', mod);}
		return path;
	}
	inline static public function chart_events(jsonInput:String, ?mod:String):String {
		var path = getPath('${jsonInput.split('-')[0]}/Data/global_events.json', TEXT, 'songs', mod);
		if(!Paths.exists(path)){path = getPath('Test/Data/global_events.json', TEXT, 'songs', mod);}
		return path;
	}
	inline static public function dialogue(song:String, ?mod:String):String {
		var language = PreSettings.getPreSetting("Language", "Game Settings");
		var path = getPath('${song}/Data/${language}_dialog.json', TEXT, 'songs', mod);
		if(!Paths.exists(path)){path = getPath('${song}/Data/Default_dialog.json', TEXT, 'songs', mod);}
		return path;
	}
	inline static public function stage(key:String, ?mod:String):String {
		var path = getPath('${key}.hx', TEXT, 'stages', mod);
		if(!Paths.exists(path)){path = getPath('Stage.hx', TEXT, 'stages', mod);}
		return path;
	}
	inline static public function note(image:String, style:String, ?type:String, ?mod:String):String {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}
		var path:String = getPath('${type}/${style}/${image}.png', IMAGE, 'notes', mod);
		if(!Paths.exists(path)){path = getPath('${type}/Default/${image}.png', IMAGE, 'notes', mod);}
		if(!Paths.exists(path)){path =  getPath('Default/Default/${image}.png', IMAGE, 'notes', mod);}
		return path;
	}
	inline static public function event(key:String, ?mod:String):String {
		var path = getPath('events/${key}.hx', TEXT, 'data', mod);
		if(!Paths.exists(path)){path = getPath('note_events/${key}.hx', TEXT, 'data', mod);}
		if(!Paths.exists(path)){
			for(p in Paths.readDirectory('assets/stages')){
				if(!Paths.exists('$p/events')){continue;}
				if(!Paths.exists('$p/events/${key}.hx')){continue;}
				path = '$p/events/${key}.hx'; break;
			}
		}
		return path;
	}	
	inline static public function strum_keys(keys:Int, ?type:String):String {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}
		var path = getPath('${type}/${keys}k.json', TEXT, 'notes');
		if(!Paths.exists(path)){path = getPath('${type}/_k.json', TEXT, 'notes');}
		if(!Paths.exists(path)){path = getPath('Default/${keys}k.json', TEXT, 'notes');}
		if(!Paths.exists(path)){path = getPath('Default/_k.json', TEXT, 'notes');}
		return path;
	}
	inline static public function character(char:String, asp:String, ?skin:String, ?is_death:Bool, ?mod:String):String {
		if(skin == null){skin = Skins.getSkin(char);}
		var cur_char_file:String = '${char}'; if(is_death){cur_char_file = '${cur_char_file}_Death';}
		var path = getPath('${char}/${cur_char_file}-${skin}-${asp}.json', TEXT, 'characters', mod);
		if(!Paths.exists(path)){path = getPath('${char}/${cur_char_file}-Default-${asp}.json', TEXT, 'characters', mod);}
		if(!Paths.exists(path)){path = getPath('${char}/${cur_char_file}-Default-Default.json', TEXT, 'characters', mod);}
		if(!Paths.exists(path)){path = getPath('Boyfriend/Boyfriend-Default-Default.json', TEXT, 'characters', mod);}
		return path;
	}
}
