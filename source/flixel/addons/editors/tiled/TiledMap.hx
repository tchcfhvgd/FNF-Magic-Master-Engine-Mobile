package flixel.addons.editors.tiled;

import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.typeLimit.OneOfTwo;
import flixel.addons.ui.FlxUIState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import haxe.io.Path;

#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

using SavedFiles;
using StringTools;

/**
 * Copyright (c) 2013 by Samuel Batista
 * (original by Matt Tuttle based on Thomas Jahn's. Haxe port by Adrien Fischer)
 * This content is released under the MIT License.
 */
class TiledMap {
	public var version:String;
	public var orientation:String;

	public var backgroundColor:FlxColor;

	public var width:Int;
	public var height:Int;
	public var tileWidth:Int;
	public var tileHeight:Int;

	public var fullWidth:Int;
	public var fullHeight:Int;

	public var tilemaps:Map<String, FlxTilemap> = [];
	public var colliders:FlxTypedGroup<FlxSprite>;
	public var objects:FlxTypedGroup<Dynamic>;

	public var properties:TiledPropertySet = new TiledPropertySet();

	/**
	 * Use to get a tileset by name
	 */
	public var tilesets:Map<String, TiledTileSet> = new Map<String, TiledTileSet>();

	/**
	 * Use for iterating over tilesets, and for merging tilesets (because order is important)
	 */
	public var tilesetArray:Array<TiledTileSet> = [];

	public var layers:Array<TiledLayer> = [];

	// Add a "noload" property to your Map Properties.
	// Add comma separated values of tilesets, layers, or object names.
	// These will not be loaded.
	var noLoadHash:Map<String, Bool> = new Map<String, Bool>();
	var layerMap:Map<String, TiledLayer> = new Map<String, TiledLayer>();

	var rootPath:String;

	/**
	 * @param data Either a string or XML object containing the Tiled map data
	 * @param rootPath Path to use as root to resolve any internal file references
	 */
	public function new(data:FlxTiledMapAsset, ?rootPath:String){
		var source:Access = null;

		if(rootPath != null){this.rootPath = rootPath;}

		if ((data is String)){
			if (this.rootPath == null) {this.rootPath = Path.directory(data) + "/";}

			source = new Access(Xml.parse('${this.rootPath}${data}'.getText()));
		} else if ((data is Xml)) {
			if (this.rootPath == null) {this.rootPath = Path.directory(data) + "/";}

			var xml:Xml = cast data;
			source = new Access(xml);
		}

		source = source.node.map;

		loadAttributes(source);
		loadProperties(source);
		loadTilesets(source);
		loadLayers(source);

		colliders = new FlxTypedGroup<FlxSprite>();
		objects = new FlxTypedGroup<Dynamic>();
	}

	function loadAttributes(source:Access):Void {
		version = (source.att.version != null) ? source.att.version : "unknown";
		orientation = (source.att.orientation != null) ? source.att.orientation : "orthogonal";
		backgroundColor = (source.has.backgroundcolor && source.att.backgroundcolor != null) ? FlxColor.fromString(source.att.backgroundcolor) : FlxColor.TRANSPARENT;

		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);
		tileWidth = Std.parseInt(source.att.tilewidth);
		tileHeight = Std.parseInt(source.att.tileheight);

		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;
	}

	function loadProperties(source:Access):Void {
		for (node in source.nodes.properties) {
			properties.extend(node);
		}

		var noLoadStr = properties.get("noload");
		if (noLoadStr != null)
		{
			var noLoadArr = ~/[,;|]/.split(noLoadStr);

			for (s in noLoadArr)
			{
				noLoadHash.set(s.trim(), true);
			}
		}
	}

	function loadTilesets(source:Access):Void
	{
		for (node in source.nodes.tileset)
		{
			var name = node.has.name ? node.att.name : "";

			if(noLoadHash.exists(name)){continue;}
			
			var ts = new TiledTileSet(node, rootPath);

			tilesets.set(ts.name, ts);
			tilesetArray.push(ts);
		}
	}

	function loadLayers(source:Access):Void
	{
		for (el in source.elements)
		{
			if (el.has.name && noLoadHash.exists(el.att.name))
				continue;

			var layer:TiledLayer = switch (el.name.toLowerCase())
			{
				case "group": new TiledGroupLayer(el, this, noLoadHash);
				case "layer": new TiledTileLayer(el, this);
				case "objectgroup": new TiledObjectLayer(el, this);
				case "imagelayer": new TiledImageLayer(el, this);
				case _: null;
			}

			if (layer != null){
				layers.push(layer);
				layerMap.set(layer.name, layer);
			}
		}
	}

	public function getTileSet(name:String):TiledTileSet
	{
		return tilesets.get(name);
	}

	public function getLayer(name:String):TiledLayer
	{
		return layerMap.get(name);
	}

	/**
	 * works only after TiledTileSet has been initialized with an image...
	 */
	public function getGidOwner(gid:Int):TiledTileSet
	{
		for (set in tilesets)
		{
			if (set.hasGid(gid))
			{
				return set;
			}
		}

		return null;
	}

    public function generate(_state:FlxUIState, ?_add_list:Map<Int, Dynamic>):Void {
		if(_add_list == null){_add_list = [];}

		tilemaps.clear();
		colliders.clear();
		objects.clear();

		var cur_layer:Int = 0;
        for (layer in this.layers){            
            switch (layer.type){
                default: {trace("Type Not Supported"); break;}
				case TiledLayerType.TILE: {
					var _tileLayer:TiledTileLayer = cast layer;		

					//trace(' <Tile>: ${layer.name}');
					switch(layer.name){
						default:{
							for (tileSet in tilesetArray){								
								var tilemap:FlxTilemap = new FlxTilemap();
								tilemap.loadMapFromArray(_tileLayer.tileArray, width, height, Path.normalize('${tileSet.rootPath}${tileSet.imageSource}').getGraphic(), tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);
								
								tilemaps.set(layer.name, tilemap);
								_state.add(tilemap);
							}
						}
						case "Objects":{
							var _x = -1, _y = 0;			
							for (cell in _tileLayer.tileArray){
								_x++; if (_x >= this.width){_x = 0; _y++;}
								if(cell == 0){continue;}

								var _object = new FlxObject(_x * this.tileWidth, _y * this.tileHeight);
								_object._.type = "FlxObject";
								_object.ID = cell;

								objects.add(_object);
								_state.add(_object);
							}
						}
						case "Collisions":{
							var _x = -1, _y = 0;	
							for(cell in _tileLayer.tileArray){
								_x++; if (_x >= this.width){_x = 0; _y++;}
								if (cell == 0){continue;}

								var _object = new FlxSprite(_x * this.tileWidth, _y * this.tileHeight).makeGraphic(this.tileWidth, this.tileHeight);
								_object.alpha = 0;

								colliders.add(_object);
								_state.add(_object);
							}
						}
					}
                }
				case TiledLayerType.OBJECT:{					
					var _objectLayer:TiledObjectLayer = cast layer;
					
					//trace(' <Object>: ${layer.name}');
					switch(layer.name){
						case "Objects":{
							for(_obj in _objectLayer.objects){
								var _object = new FlxSprite(_obj.x, _obj.y - _obj.height).makeGraphic(_obj.width, _obj.height);
								_object._.type = "FlxSprite";
								_object._.name = _obj.name;
								_object._.properties = {};
								for(key in _obj.properties.keys.keys()){
									Reflect.setProperty(_object._.properties, key, _obj.properties.get(key));
								}
								_object.immovable = true;
								_object.alpha = 0;
								
								objects.add(_object);
								_state.add(_object);
							}
						}
						case "Collisions":{
							for(_obj in _objectLayer.objects){
								var _object = new FlxSprite(_obj.x, _obj.y).makeGraphic(_obj.width, _obj.height);
								_object.immovable = true;
								_object.alpha = 0;
								
								colliders.add(_object);
								_state.add(_object);
							}
						}
					}
				}
			}

			if(_add_list.exists(cur_layer)){_state.add(_add_list.get(cur_layer));}

			cur_layer++;
        }
    }
}

typedef FlxTiledMapAsset = OneOfTwo<String, Xml>;
