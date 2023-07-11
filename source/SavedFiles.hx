package;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetManifest;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetLibrary;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import haxe.format.JsonParser;
import flixel.math.FlxPoint;
import openfl.system.System;
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

class SavedFiles {
	public static var savedTempMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var usedAssets:Array<String> = [];

	public static function gc():Void {System.gc();}
	public static function clearAsset(key:String, asset_type:AssetType = IMAGE):Void {
		if(!savedTempMap.exists(key)){return;}

		@:privateAccess
		switch(asset_type){
			case BINARY, MOVIE_CLIP, TEMPLATE, TEXT:{}
			case IMAGE:{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				//trace('deleted image: [${key}]');
			}
			case SOUND, MUSIC:{
				openfl.Assets.cache.removeSound(key);
				//trace('deleted sound: [${key}]');
			}
			case FONT:{
				openfl.Assets.cache.removeFont(key);
				//trace('deleted font: [${key}]');
			}
		}
		
		savedTempMap.remove(key);
	}
	public static function clearUnusedAssets() {
		for(key in savedTempMap.keys()){
			if(usedAssets.contains(key)){continue;}

			var cur_asset = savedTempMap.get(key);
			if(cur_asset == null){continue;}

			@:privateAccess
			switch(cur_asset.asset_type){
				case IMAGE:{
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					//trace('deleted image: [${key}]');
				}
				case SOUND, MUSIC:{
					openfl.Assets.cache.removeSound(key);
					//trace('deleted sound: [${key}]');
				}
				case FONT:{
					openfl.Assets.cache.removeFont(key);
					//trace('deleted font: [${key}]');
				}
			}
			
			if(Reflect.hasField(cur_asset.asset, 'destroy')){cur_asset.asset.destroy();}
			savedTempMap.remove(key);
		}
		System.gc();
	}
	public static function clearMemoryAssets():Void {
		@:privateAccess
		for(key in FlxG.bitmap._cache.keys()){
			var cur_asset = FlxG.bitmap._cache.get(key);
			if(cur_asset == null || savedTempMap.exists(key)) {continue;}

			openfl.Assets.cache.removeBitmapData(key);
			FlxG.bitmap._cache.remove(key);
			cur_asset.destroy();
			
			//trace('removed image: [${key}]');
		}

		for (key in savedTempMap.keys()) {
			var cur_saved = savedTempMap.get(key);
			if(cur_saved == null || usedAssets.contains(key)){continue;}
			switch(cur_saved.asset_type){
				default:{
					savedTempMap.remove(key);
					//trace('removed default: [${key}]');
				}
				case SOUND, MUSIC:{
					openfl.Assets.cache.clear(key);
					savedTempMap.remove(key);
					//trace('removed sound: [${key}]');
				}
				case IMAGE:{}
			}
		}

		usedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	inline static public function isSaved(file:String):Bool {
		if(savedTempMap.exists(file)){return true;}
		if(savedTempMap.exists(Paths.setPath(file))){return true;}
		return false;
	}
	inline static public function getSavedFile(file:String):Any {
		if(savedTempMap.exists(file)){return savedTempMap.get(file).asset;}
		if(savedTempMap.exists(Paths.setPath(file))){return savedTempMap.get(Paths.setPath(file)).asset;}
		return null;
	}
	inline static public function saveFile(file:String, instance:Dynamic, type:Dynamic):Void {
		usedAssets.push(file);
		savedTempMap.set(file, {asset_type: type, asset: instance});
		//trace('saved [${file}]');
	}
	inline static public function unsaveFile(file:String):Void {
		savedTempMap.remove(Paths.setPath(file));
		savedTempMap.remove(file);
	}

	inline public static function getSound(file:String):Sound {
		if(isSaved(file)){return getSavedFile(file);}
		saveFile(file, Assets.exists(file) ? Assets.getSound(file) : Sound.fromFile(file), SOUND);
		return getSavedFile(file);
	}
	inline public static function saveSound(file:String):Void {
		if(isSaved(file) || !Paths.exists(file)){return;}
		saveFile(file, Assets.exists(file) ? Assets.getSound(file) : Sound.fromFile(file), SOUND);
	}

	inline public static function getBytes(file:String):Any {
		if(isSaved(file)){return getSavedFile(file);}
		#if sys
		saveFile(file, Assets.exists(file) ? Assets.getBytes(file) : File.getBytes(file), BINARY);
		#else
		saveFile(file, Assets.getBytes(file), BINARY);
		#end
		return getSavedFile(file);
	}
	inline public static function saveBytes(file:String):Void {
		if(isSaved(file) || !Paths.exists(file)){return;}
		#if sys
		saveFile(file, Assets.exists(file) ? Assets.getBytes(file) : File.getBytes(file), BINARY);
		#else
		saveFile(file, Assets.getBytes(file), BINARY);
		#end
	}

	public static function getGraphic(file:String):Any {
		if(isSaved(file)){return getSavedFile(file);}
		var graphic:FlxGraphic = FlxG.bitmap.add(file, false);
		if(graphic == null){
			trace('Null: ${file}');
			var bit:BitmapData = BitmapData.fromFile(file);
			if(bit == null){return file;}
			graphic = FlxGraphic.fromBitmapData(bit, false, file);
		}
		graphic.persist = true;
		saveFile(file, graphic, IMAGE);
		return getSavedFile(file);
	}
	public static function saveGraphic(file:String):Void {
		if(isSaved(file) || !Paths.exists(file)){return;}
		var graphic:FlxGraphic = FlxG.bitmap.add(file, false);
		if(graphic == null){
			trace('Null: ${file}');
			var bit:BitmapData = BitmapData.fromFile(file);
			if(bit == null){return;}
			graphic = FlxGraphic.fromBitmapData(bit, false, file);
		}
		graphic.persist = true;
		saveFile(file, graphic, IMAGE);
	}

	inline public static function getText(file:String):String {
		if(isSaved(file)){return getSavedFile(file);}
		#if sys
		saveFile(file, Assets.exists(file) ? Assets.getText(file) : File.getContent(file), TEXT);
		#else
		saveFile(file, Assets.getText(file), TEXT);
		#end
		return getSavedFile(file);
	}
	inline public static function saveText(file:String):Void {
		if(isSaved(file) || !Paths.exists(file)){return;}
		#if sys
		saveFile(file, Assets.exists(file) ? Assets.getText(file) : File.getContent(file), TEXT);
		#else
		saveFile(file, Assets.getText(file), TEXT);
		#end
	}

	inline static public function getSparrowAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png", "").replace('.xml', '');

		var bit = getGraphic('$path.png');
		var xml = getText('$path.xml');

		if(bit == null || xml == null){return null;}
		return FlxAtlasFrames.fromSparrow(bit, xml);
	}

	inline static public function getPackerAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png", "").replace('.txt', '');

		var bit = getGraphic('$path.png');
		var txt = getText('$path.txt');

		if(bit == null || txt == null){return null;}
		return FlxAtlasFrames.fromSpriteSheetPacker(bit, txt);
	}

	static public function getAtlas(path:String):FlxAtlasFrames {
		path = path.replace(".png", "").replace(".xml", "").replace(".txt", "");

		if(Paths.exists('${path}.xml')){return getSparrowAtlas('$path.xml');}
		else if(Paths.exists('${path}.txt')){return getPackerAtlas('$path.txt');}
		return null;
	}
	
	inline static public function getJson(path:String):Dynamic {
		return Json.parse(getText(path).trim());
	}

	inline static public function getColorNote(key:String):String {
		var toReturn:String = "None";

		var fileName:String = key.split("/").pop();
		var note_path:String = key.replace(fileName, "colors.txt");
		if(!Paths.exists(note_path)){return toReturn;}

		var arrColors:Array<String> = getText(note_path).split("\n");
		for(t in arrColors){var tt:Array<String> = t.split(":"); if(tt[0] == fileName){toReturn = tt[1];}}
		return toReturn;
	}
	inline static public function getDataNote(data:Int, keys:Int, ?type:String):Note.Note_Graphic_Data {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}
		var strumJSON:StrumLine.StrumLine_Graphic_Data = getJson(Paths.strum_keys(keys, type));
		var noteJSON:Note.Note_Graphic_Data = strumJSON.gameplay_notes.notes[(data % keys) % strumJSON.gameplay_notes.notes.length];
		if(strumJSON == null || strumJSON.gameplay_notes == null || strumJSON.gameplay_notes.general_animations == null || strumJSON.gameplay_notes.general_animations.length <= 0){return noteJSON;}
		for(anim in strumJSON.gameplay_notes.general_animations){noteJSON.animations.push(anim);}
		return noteJSON;
	}
	inline static public function getDataStaticNote(data:Int, keys:Int, ?type:String):Note.Note_Graphic_Data {
		if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}
		var strumJSON:StrumLine.StrumLine_Graphic_Data = getJson(Paths.strum_keys(keys, type));
		var noteJSON:Note.Note_Graphic_Data = strumJSON.static_notes.notes[(data % keys) % strumJSON.static_notes.notes.length];
		if(strumJSON == null || strumJSON.gameplay_notes == null || strumJSON.static_notes.general_animations == null || strumJSON.static_notes.general_animations.length <= 0){return noteJSON;}
		for(anim in strumJSON.static_notes.general_animations){noteJSON.animations.push(anim);}
		return noteJSON;
	}
	
	public static function fromUncachedSparrow(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames {
        var graphic:FlxGraphic = FlxG.bitmap.add(Source);
    
        if(graphic == null || Description == null){return null;}
    
        var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);
        
        var data:Access = new Access(Xml.parse(Description).firstElement());
    
        for(texture in data.nodes.SubTexture){
            var name = texture.att.name;
            var trimmed = texture.has.frameX;
            var rotated = (texture.has.rotated && texture.att.rotated == "true");
            var flipX = (texture.has.flipX && texture.att.flipX == "true");
            var flipY = (texture.has.flipY && texture.att.flipY == "true");
    
            var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));

            var size = if(trimmed){new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));}else{new Rectangle(0, 0, rect.width, rect.height);}
    
            var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
    
            var offset = FlxPoint.get(-size.left, -size.top);
            var sourceSize = FlxPoint.get(size.width, size.height);
    
            if(rotated && !trimmed){sourceSize.set(size.height, size.width);}
    
            frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
        }
    
        return frames;
    }	
	public static function fromUncachedSpriteSheetPacker(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames {
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		
		if(graphic == null){return null;}
		if(graphic == null || Description == null){return null;}
	
		var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);
	
		if(Paths.exists(Description)){Description = getText(Description);}
	
		var pack = StringTools.trim(Description);
		var lines:Array<String> = pack.split("\n");
	
		for (i in 0...lines.length){
			var _frame_data = lines[i].split(":");

			var _name = StringTools.trim(_frame_data[0]);

			var _frame_region = StringTools.trim(_frame_data[1]).split(",");
			var _frame_size = StringTools.trim(_frame_data[2]).split(",");

			var _rect = FlxRect.get(Std.parseInt(_frame_region[0]), Std.parseInt(_frame_region[1]), Std.parseInt(_frame_region[2]), Std.parseInt(_frame_region[3]));

			var _size = new Rectangle(0, 0, _rect.width, _rect.height);
			if(_frame_size != null && _frame_size.length >= 4){_size = new Rectangle(Std.parseInt(_frame_size[0]), Std.parseInt(_frame_size[1]), Std.parseInt(_frame_size[2]), Std.parseInt(_frame_size[3]));}
			
			var _offset = FlxPoint.get(-_size.left, -_size.top);
			var _source_size = FlxPoint.get(_size.width, _size.height);

			frames.addAtlasFrame(_rect, _source_size, _offset, _name, FlxFrameAngle.ANGLE_0);
		}
	
		return frames;
	}
}