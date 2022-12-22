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

	public var loadingText:Alphabet;

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
        bg.color = 0xffff8cf7;
		bg.screenCenter();
		add(bg);

		var shape_1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 100, FlxColor.BLACK); add(shape_1);
        var shape_2:FlxSprite = new FlxSprite(0, 105).makeGraphic(FlxG.width, 5, FlxColor.BLACK); add(shape_2);
        var shape_3:FlxSprite = new FlxSprite(0, FlxG.height - 110).makeGraphic(FlxG.width, 5, FlxColor.BLACK); add(shape_3);
        var shape_4:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, FlxColor.BLACK); add(shape_4);

		loadingText = new Alphabet(20,500,[{text:'${LangSupport.getText("loading_info_1")} 0%'}]); add(loadingText);

		loadingBar = new FlxBar(loadingText.x, loadingText.y + loadingText.height + 30, LEFT_TO_RIGHT, Std.int(FlxG.width / 3), 10, null, null, 0, totalCount); add(loadingBar);

		loadStuff();
				
		super.create();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		loadingBar.value = totalCount - tempLoadingStuff.length;

		var percent:Int = Std.int((totalCount - tempLoadingStuff.length) * 100 / totalCount);
		loadingText.cur_data = [{text:'${LangSupport.getText("loading_info_1")} ${percent}%'}];
		loadingText.loadText();
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

						var song_path:String = Paths.song_script(_song.song);
						if(Paths.exists(song_path)){
							var song_script:Script = new Script();
							song_script.Name = "ScriptSong";
							song_script.exScript(Paths.getText(song_path));
							TARGET.tempScripts.set("ScriptSong", song_script);
						}

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

				if(_stuff.type == null || _stuff.instance == null){continue;}

				switch(_stuff.type){
					default:{trace(_stuff);}
					case IMAGE: Paths.getGraphic(_stuff.instance);
					case SOUND, MUSIC: Paths.getSound(_stuff.instance);
					case TEXT: Paths.getText(_stuff.instance);
					case "ATLAS": Paths.getAtlas(_stuff.instance);

					case "FUNCTION":{_stuff.instance();}
				}
			}
		});
	}

	private function onLoad():Void {
		trace("Loaded All");

		if(isGlobal){trace("Setting to Global"); isGlobal = false; Paths.setTempToGlobal();}

		MusicBeatState.switchState(TARGET);
	}
}