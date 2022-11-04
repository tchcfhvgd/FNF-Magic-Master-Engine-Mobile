package states;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetManifest;
import lime.utils.AssetLibrary;
import openfl.utils.AssetType;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import sys.thread.Thread;
import flixel.FlxSprite;
import lime.app.Promise;
import flixel.FlxState;
import lime.app.Future;
import haxe.io.Path;
import flixel.FlxG;
import haxe.Json;

import Stage;
import Song.SwagSong;
import Note.NoteData;
import Note.EventData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LoadingState extends MusicBeatState {
	public static var isGlobal:Bool = true;

	public static var toGlobalLoadStuff:Array<Dynamic> = [
		{type:MUSIC,instance:Paths.music("breakfast","shared",true)},
		{type:SOUND,instance:Paths.sound("missnote1","shared",true)},
		{type:SOUND,instance:Paths.sound("missnote2","shared",true)},
		{type:SOUND,instance:Paths.sound("missnote3","shared",true)}
	];
	public var toLoadStuff:Array<Dynamic> = [];

	private var tempLoadingStuff:Array<Dynamic> = [];
	
	private var TARGET:MusicBeatState;
	private var WithMusic:Bool = false;
	
	private var thdLoading:Thread;

	public function new(target:MusicBeatState, _toLoadStuff:Array<Dynamic>, withMusic:Bool = false){
		this.WithMusic = withMusic;
		this.toLoadStuff = _toLoadStuff;
		this.TARGET = target;
		super();
	}

	override function create(){
		if(!WithMusic && FlxG.sound.music != null){FlxG.sound.music.stop();}
				
		preLoadStuff();
				
		var bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		add(bg);
		
		loadStuff();
				
		super.create();
	}

	private function preLoadStuff():Void {
		for(stuff in toGlobalLoadStuff){tempLoadingStuff.push(stuff);}
		
		for(stuff in toLoadStuff){
			if(stuff.type != IMAGE && stuff.type != SOUND && stuff.type != MUSIC && stuff.type != TEXT){
				switch(stuff.type){
					case "SONG":{
						var _song:SwagSong = cast stuff.instance;
		
						trace("SONG");

						for(i in Paths.readDirectory('assets/songs/${Paths.getFileName(_song.song, true)}/Audio', true)){
							var _i:String = cast i; trace(_i);
							if(_i.contains(".ogg")){tempLoadingStuff.push({type:SOUND,instance:_i});}
						}
						for(i in Paths.readDirectory('assets/songs/${_song.song}/Data', true)){
							var _i:String = cast i; trace(_i);
							if(_i.contains(".json")){tempLoadingStuff.push({type:TEXT,instance:_i});}
						}
						
						for(i in Paths.readDirectory('assets/shared/images/style_UI/${_song.uiStyle}', true)){
							var _i:String = cast i; trace(_i);
							if(_i.contains(".png")){tempLoadingStuff.push({type:IMAGE,instance:_i});}
						}
						for(i in Paths.readDirectory('assets/shared/sounds/style_UI/${_song.uiStyle}', true)){
							var _i:String = cast i; trace(_i);
							if(_i.contains(".ogg")){tempLoadingStuff.push({type:SOUND,instance:_i});}
						}

						for(char in _song.characters){
							for(i in Paths.readDirectory('assets/characters/${char[0]}/Skins', true)){
								var _i:String = cast i; trace(_i);
								if(_i.contains(".json")){tempLoadingStuff.push({type:TEXT,instance:_i});}
							}
							for(i in Paths.readDirectory('assets/characters/${char[0]}/Sprites', true)){
								var _i:String = cast i; trace(_i);
								tempLoadingStuff.push({type:"ATLAS",instance:_i});}
						}

						Stage.getStageScript(_song.stage).exFunction("addToLoad", cast [tempLoadingStuff]);

						for(i in _song.generalSection){
							for(ii in i.events){
								var cur_Event:EventData = Note.getEventData(ii);
								if(cur_Event == null || cur_Event.isBroken){continue;}
								for(iii in cur_Event.eventData){
									tempLoadingStuff.push({type:"FUNCTION",instance:function(){TARGET.pushTempScript(iii[0], iii[1]);}});
								}
							}
						}

						for(strum in _song.sectionStrums){
							for(s in strum.notes){
								for(ss in s.sectionNotes){
									var cur_Note:NoteData = Note.getNoteData(ss);
									if(cur_Note.eventData == null){continue;}
									for(i in cur_Note.eventData){
										tempLoadingStuff.push({type:"FUNCTION",instance:function(){TARGET.pushTempScript(i[0], i[1]);}});
									}
								}
							}

							for(i in Paths.readDirectory('assets/notes/${PreSettings.getPreSetting("Note Skin", "Visual Settings")}/${strum.noteStyle}', true)){
								var _i:String = cast i; trace(_i);
								tempLoadingStuff.push({type:"ATLAS",instance:_i});
							}
						}
					}
					case "PRELOAD":{if(stuff.instance != null){stuff.instance();}}
				}

				continue;
			}

			tempLoadingStuff.push(stuff);
		}
	}

	private function loadStuff():Void {
		thdLoading = Thread.create(() -> {
			while(true){
				if(tempLoadingStuff.length <= 0){onLoad(); return;}
				
				var _stuff:Dynamic = tempLoadingStuff.shift();

				switch(_stuff.type){
					default:{trace(_stuff);}
					case IMAGE: Paths.getGraphic(_stuff.instance);
					case SOUND, MUSIC: Paths.getSound(_stuff.instance);
					case TEXT: Paths.getText(_stuff.instance);
					case "ATLAS": Paths.getAtlas(_stuff.instance);

					case "FUNCTION":{if(_stuff.instance != null){_stuff.instance();}}
				}
				
				trace('Cached: ${_stuff.instance}');
			}
		});
	}

	private function onLoad():Void {
		if(isGlobal){trace("Setting to Global"); isGlobal = false; Paths.setTempToGlobal();}

		MusicBeatState.switchState(TARGET);
	}
}