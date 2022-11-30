package states;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetManifest;
import flixel.util.FlxGradient;
import lime.utils.AssetLibrary;
import openfl.utils.AssetType;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import sys.thread.Thread;
import flixel.FlxSprite;
import lime.app.Promise;
import flixel.ui.FlxBar;
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

	private var totalCount:Int = 0;
	private var tempLoadingStuff:Array<Dynamic> = [];
	
	private var TARGET:MusicBeatState;
	private var WithMusic:Bool = false;
	
	private var thdLoading:Thread;

	public var loadingBar:FlxBar;

	public function new(target:MusicBeatState, _toLoadStuff:Array<Dynamic>, withMusic:Bool = false){
		this.WithMusic = withMusic;
		this.toLoadStuff = _toLoadStuff;
		this.TARGET = target;
		super();
	}

	override function create(){
		if(!WithMusic && FlxG.sound.music != null){FlxG.sound.music.stop();}
				
		preLoadStuff();
		
		totalCount = tempLoadingStuff.length;

		var bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		add(bg);

		var grad_1:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 300, [FlxColor.BLACK, FlxColor.TRANSPARENT]); add(grad_1);
		var grad_2:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 300, [FlxColor.TRANSPARENT, FlxColor.BLACK]); grad_2.y = FlxG.height - 300; add(grad_2);
		
		loadingBar = new FlxBar(0, FlxG.height - 15, LEFT_TO_RIGHT, FlxG.width, 15, null, null, 0, totalCount); add(loadingBar);

		loadStuff();
				
		super.create();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		loadingBar.value = totalCount - tempLoadingStuff.length;
	}

	private function preLoadStuff():Void {
		for(stuff in toGlobalLoadStuff){tempLoadingStuff.push(stuff);}

		for(i in Paths.readDirectory('assets/notes/Default/Default', true)){
			var _i:String = cast i; 
			tempLoadingStuff.push({type:"ATLAS",instance:_i});
		}

		for(i in Paths.readDirectory('assets/notes/${PreSettings.getPreSetting("Note Skin", "Visual Settings")}', true)){
			var _i:String = cast i; 
			if(_i.contains('.json')){tempLoadingStuff.push({type:TEXT,instance:_i});}
		}
		
		for(stuff in toLoadStuff){
			if(stuff.type != IMAGE && stuff.type != SOUND && stuff.type != MUSIC && stuff.type != TEXT){
				switch(stuff.type){
					case "SONG":{
						var _song:SwagSong = cast stuff.instance;
		
						trace("SONG");
						
						tempLoadingStuff.push({type:SOUND,instance:Paths.inst(_song.song, _song.category, true)});

						if(_song.hasVoices){for(i in 0..._song.characters.length){tempLoadingStuff.push({type:SOUND,instance:Paths.voice(i, _song.characters[i][0], _song.song, _song.category, true)});}}
						
						for(i in Paths.readDirectory('assets/shared/images/style_UI/${_song.uiStyle}', true)){
							var _i:String = cast i; 
							if(_i.contains(".png")){tempLoadingStuff.push({type:IMAGE,instance:_i});}
						}
						for(i in Paths.readDirectory('assets/shared/sounds/style_UI/${_song.uiStyle}', true)){
							var _i:String = cast i; 
							if(_i.contains(".ogg")){tempLoadingStuff.push({type:SOUND,instance:_i});}
						}
						
						Stage.getStageScript(_song.stage).exFunction("addToLoad", [tempLoadingStuff]);

						for(char in _song.characters){Character.addPreloadersToList(tempLoadingStuff, char[0], char[3], char[4]);}

						for(gen in _song.generalSection){
							for(ev in gen.events){
								var cur_Event:EventData = Note.getEventData(ev);
								if(cur_Event == null || cur_Event.isBroken){continue;}
								for(dat in cur_Event.eventData){
									tempLoadingStuff.push({type:"FUNCTION",instance:function(){TARGET.pushTempScript(dat[0]);}});
									if(!TARGET.tempScripts.exists(dat[0]) || TARGET.tempScripts.get(dat[0]).getFunction("Preload") == null){continue;}
									tempLoadingStuff.push({type:"FUNCTION",instance:function(){TARGET.tempScripts.get(dat[0]).exFunction("Preload", cast cast(dat[1],Array<Dynamic>));}});
								}
							}
						}

						for(strum in _song.sectionStrums){
							for(i in Paths.readDirectory('assets/notes/${PreSettings.getPreSetting("Note Skin", "Visual Settings")}/${strum.noteStyle}', true)){
								var _i:String = cast i; 
								tempLoadingStuff.push({type:"ATLAS",instance:_i});
							}

							for(s in strum.notes){
								for(ss in s.sectionNotes){
									var cur_Note:NoteData = Note.getNoteData(ss);
									if(cur_Note.eventData == null){continue;}
									for(dat in cur_Note.eventData){
										tempLoadingStuff.push({type:"FUNCTION",instance:function(){TARGET.pushTempScript(dat[0]);}});
										tempLoadingStuff.push({type:"FUNCTION",instance:function(){Script.getScript(dat[0]).exFunction("Preload", cast cast(dat[1],Array<Dynamic>));}});
									}
								}
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
				
				//trace('Cached: ${_stuff.instance}');
			}
		});
	}

	private function onLoad():Void {
		trace("Loaded All");

		if(isGlobal){trace("Setting to Global"); isGlobal = false; Paths.setTempToGlobal();}

		MusicBeatState.switchState(TARGET);
	}
}