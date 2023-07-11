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

using SavedFiles;
using StringTools;

class LoadingState extends MusicBeatState {
	public static var toGlobalLoadStuff:Array<Dynamic> = [
		{type:MUSIC,instance:Paths.music("breakfast","shared")},
		{type:SOUND,instance:Paths.sound("fnf_loss_sfx","shared")},
		{type:SOUND,instance:Paths.sound("missnote1","shared")},
		{type:SOUND,instance:Paths.sound("missnote2","shared")},
		{type:SOUND,instance:Paths.sound("missnote3","shared")},
		{type:IMAGE,instance:Paths.image("alphabet")},
		{type:IMAGE,instance:Paths.image("icons/icon-face")},
		{type:MUSIC,instance:Paths.music("freakyMenu")},
		{type:SOUND,instance:Paths.sound("cancelMenu")},
		{type:SOUND,instance:Paths.sound("confirmMenu")},
		{type:SOUND,instance:Paths.sound("scrollMenu")},
	];
	public var toLoadStuff:Array<Dynamic> = [];

	public var loadingText:Alphabet;

	private var totalCount:Int = 0;
	private var tempLoadingStuff:Array<Dynamic> = [];
	
	private var TARGET:MusicBeatState;
	private var WithMusic:Bool = false;
	
	private var thdLoading:Thread;

	public function new(_target:MusicBeatState, _toLoadStuff:Array<Dynamic>, withMusic:Bool = false){
		if(_toLoadStuff == null){_toLoadStuff = [];}
		this.WithMusic = withMusic;
		this.toLoadStuff = _toLoadStuff;
		this.TARGET = _target;
		super();
	}

	override function create(){
		if(!WithMusic && FlxG.sound.music != null){FlxG.sound.music.stop();}
		preLoadStuff();
		
		totalCount = tempLoadingStuff.length;
		
		var bg = new FlxSprite().loadGraphic(Paths.image('menuBG').getGraphic());
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.color = 0xffff8cf7;
		bg.screenCenter();
		add(bg);

		var shape_1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 100, FlxColor.BLACK); add(shape_1);
        var shape_2:FlxSprite = new FlxSprite(0, 105).makeGraphic(FlxG.width, 5, FlxColor.BLACK); add(shape_2);
        var shape_3:FlxSprite = new FlxSprite(0, FlxG.height - 110).makeGraphic(FlxG.width, 5, FlxColor.BLACK); add(shape_3);
        var shape_4:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, FlxColor.BLACK); add(shape_4);

		loadingText = new Alphabet(20,525,[{text:'${LangSupport.getText("loading_info_1")} 0%'}]); add(loadingText);

		loadStuff();
				
		super.create();
	}

	override function update(elapsed:Float){
		super.update(elapsed);
	}

	function updateText():Void {
		var percent:Int = Std.int((totalCount - tempLoadingStuff.length) * 100 / totalCount);
		loadingText.cur_data = [{text:'${LangSupport.getText("loading_info_1")} ${percent}%'}];
		loadingText.loadText();
	}

	private function preLoadStuff():Void {
		for(stuff in toGlobalLoadStuff){tempLoadingStuff.push(stuff);}

		for(i in Paths.readDirectory('assets/notes/Default/Default')){tempLoadingStuff.push({type:IMAGE,instance:i});}
		for(i in Paths.readDirectory('assets/notes/${PreSettings.getPreSetting("Note Skin", "Visual Settings")}')){if(i.contains('.json')){tempLoadingStuff.push({type:TEXT,instance:i});}}
		
		for(stuff in toLoadStuff){
			if(stuff.type != IMAGE && stuff.type != SOUND && stuff.type != MUSIC && stuff.type != TEXT){
				switch(stuff.type){
					case "SONG":{
						var _song:SwagSong = cast stuff.instance;
		
						trace("SONG");
						
						tempLoadingStuff.push({type:SOUND,instance:Paths.inst(_song.song, _song.category)});
						if(_song.hasVoices){for(i in 0..._song.characters.length){tempLoadingStuff.push({type:SOUND,instance:Paths.voice(i, _song.characters[i][0], _song.song, _song.category)});}}
						
						for(i in Paths.readDirectory('assets/shared/images/style_UI/${_song.uiStyle}')){if(i.contains(".png")){tempLoadingStuff.push({type:IMAGE,instance:i});}}
						for(i in Paths.readDirectory('assets/shared/sounds/style_UI/${_song.uiStyle}')){if(i.contains(".ogg")){tempLoadingStuff.push({type:SOUND,instance:i});}}
						
						Stage.getStageScript(_song.stage).exFunction("addToLoad", [tempLoadingStuff]);

						var song_path:String = Paths.song_script(_song.song);
						if(Paths.exists(song_path)){
							var song_script:Script = new Script();
							song_script.Name = "ScriptSong";
							song_script.exScript(song_path.getText());
							TARGET.tempScripts.set("ScriptSong", song_script);
							song_script.exFunction("addToLoad", [tempLoadingStuff]);
						}

						for(char in _song.characters){Character.addToLoad(tempLoadingStuff, char[0], char[4]);}

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
							for(i in Paths.readDirectory('assets/notes/${PreSettings.getPreSetting("Note Skin", "Visual Settings")}/${strum.noteStyle}')){tempLoadingStuff.push({type:IMAGE,instance:i});}

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
					case IMAGE: SavedFiles.saveGraphic(_stuff.instance);
					case SOUND, MUSIC: SavedFiles.saveSound(_stuff.instance);
					case TEXT: SavedFiles.saveText(_stuff.instance);
					case "FUNCTION":{_stuff.instance();}
				}

				updateText();
			}
		});
	}

	private function onLoad():Void {
		trace('Loaded All -> $TARGET');
		VoidState.clearAssets = false;
		MusicBeatState._switchState(TARGET);
	}
}