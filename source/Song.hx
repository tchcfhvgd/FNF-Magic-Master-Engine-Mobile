package;

import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import haxe.format.JsonParser;
import openfl.events.Event;
import haxe.DynamicAccess;
import lime.utils.Assets;
import haxe.Exception;
import flixel.FlxG;
import haxe.Json;

import Note;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using SavedFiles;
using StringTools;

typedef SwagEvent = {
	var sections:Array<{events:Array<Dynamic>}>;
}
typedef SwagSong = {
	var song:String;
	var difficulty:String;
	var category:String;

	var bpm:Float;
	var speed:Float;

	var hasVoices:Bool;

	var validScore:Bool;

	var single_player:Int;

	var uiStyle:String;

	var stage:String;	
	var characters:Array<Dynamic>;

	var generalSection:Array<SwagGeneralSection>;
	var sectionStrums:Array<SwagStrum>;
}

typedef SwagStrum = {
	var isPlayable:Bool;
	var noteStyle:String;
	var keys:Int;
	var charToSing:Array<Int>;
	var notes:Array<SwagSection>;
}

typedef SwagSection = {
	var charToSing:Array<Int>;
	var changeSing:Bool;

	var keys:Int;
	var changeKeys:Bool;

	var altAnim:Bool;
	var sectionNotes:Array<Dynamic>;
}

typedef SwagGeneralSection = {
	var bpm:Float;
	var changeBPM:Bool;
	
	var lengthInSteps:Int;

	var strumToFocus:Int;
	var charToFocus:Int;

	var events:Array<Dynamic>;
}

//
typedef SongsData = {
	var weekData:Array<ItemWeek>;
	var freeplayData:Array<ItemSong>;
	var showArchiveSongs:Bool;
}

typedef ItemWeek = {
	var name:String;
	var image:String;
	var display:String;
	var title:String;
	var categories:Array<SongCategoryData>;
	var songs:Array<String>;
	var keyLock:String;
	var hiddenOnWeeks:Bool;
	var hiddenOnFreeplay:Bool;
	var colorFreeplay:String;
}
typedef ItemSong = {
	var song:String;
	var categories:Array<SongCategoryData>;
	var keyLock:String;
	var hidden:Bool;
	var color:String;
}

typedef SongCategoryData = {
	var category:String;
	var difficults:Array<String>;
}

typedef SongPlayer = {
	var alive:Bool;
	var strum:Int;
}

class SongStuffManager {
	public static function hasCatAndDiff(song:Dynamic, category:String, dificulty:String):Bool {
		var cats:Array<SongCategoryData> = song.categories;
		for(c in cats){
			if(c.category != category){continue;}
			for(d in c.difficults){
				if(d != dificulty){continue;}
				return true;
			}
		}
		return false;
	}

	public static function addCategoryToItemSong(category:SongCategoryData, itemSong:ItemSong):Void {
		for(cat in itemSong.categories){
			if(cat.category == category.category){
				for(diff in category.difficults){
					if(cat.difficults.contains(diff)){continue;}
					cat.difficults.push(diff);
				}
			}
			return;
		}
		itemSong.categories.push(category);
	}
	public static function addSongToSongList(itemSong:ItemSong, SongList:Array<ItemSong>):Void {
		for(item in SongList){if(item.song == itemSong.song){for(cat in itemSong.categories){addCategoryToItemSong(cat, item);} return;}}
		SongList.push(itemSong);
	}

	public static function getSongList():Array<ItemSong> {
		var SongList:Array<ItemSong> = [];

		var modlist:Array<String> = Paths.readFile('assets/data/weeks.json');
		if(ModSupport.hideVanillaSongs){modlist.shift();}

		for(_mod in modlist){
			var modData:SongsData = cast _mod.getJson();

			for(week in modData.weekData){
				if(week.hiddenOnFreeplay){continue;}

				var cats:Array<SongCategoryData> = week.categories;
				var lock:String = week.keyLock;
				var color:String = week.colorFreeplay;

				for(song in week.songs){
					var songItem:ItemSong = {
						song: song,
						categories: cats,
						keyLock: lock,
						color: color,
						hidden: false
					};
					addSongToSongList(songItem, SongList);
				}
			}

			for(song in modData.freeplayData){
				if(song.hidden){continue;}

				var cats:Array<SongCategoryData> = song.categories;
				var lock:String = song.keyLock;
				var color:String = song.color;
					
				var songItem:ItemSong = {
					song: song.song,
					categories: cats,
					keyLock: lock,
					color: color,
					hidden: false
				};
				addSongToSongList(songItem, SongList);
			}

			#if sys
			if(modData.showArchiveSongs){
				var songsDirectory:String = _mod;
				songsDirectory = songsDirectory.replace('data/weeks.json', 'songs');

				for(song in FileSystem.readDirectory(songsDirectory)){
					if(!FileSystem.isDirectory('${songsDirectory}/${song}') || !FileSystem.exists('${songsDirectory}/${song}/Data') || FileSystem.readDirectory('${songsDirectory}/${song}/Data').length <= 0){continue;}

					var data:Array<SongCategoryData> = [];
					for(chart in FileSystem.readDirectory('${songsDirectory}/${song}/Data')){
						var cStats:Array<String> = chart.replace(".json", "").split("-");
						if(cStats.length < 3){continue;}

						if(cStats[1] == null){cStats[1] = "Normal";}
						if(cStats[2] == null){cStats[2] = "Normal";}
						
						var hasCat:Bool = false;
						for(d in data){
							if(d.category == cStats[1]){continue;}
							
							hasCat = true;
							d.difficults.push(cStats[2]);
						}
						if(!hasCat){data.push({category:cStats[1], difficults:[cStats[2]]});}
					}
					
					var songItem:ItemSong = {
						song: song,
						categories: data,
						keyLock: null,
						color: "#fffd75",
						hidden: false
					};
					addSongToSongList(songItem, SongList);
				}
			}
			#end
		}

		return SongList;
	}

	public static function getWeekList(showLocked:Bool = false):Array<ItemWeek> {
		var WeekList:Array<ItemWeek> = [];

		var modlist:Array<String> = Paths.readFile('assets/data/weeks.json');
		if(ModSupport.hideVanillaWeeks){modlist.shift();}

		for(_mod in modlist){
			var modData:SongsData = cast _mod.getJson();
			for(week in modData.weekData){
				if(showLocked && Highscore.checkLock(week.keyLock, true)){continue;}
				WeekList.push(week);
			}
		}

		return WeekList;
	}
}

class Song {
	public static function setPlayersByChart(song:SwagSong):Void {
		states.PlayState.strum_players = [{alive: true, strum: song.single_player}];
	}

	public static function getStrumKeys(strum:SwagStrum, section:Int):Int {
		if(strum.notes[section].changeKeys){return strum.notes[section].keys;}
        return strum.keys;
	}

	public static function getNoteCharactersToSing(?note:Note, strum:SwagStrum, section:Int):Array<Int> {
		if(note != null && note.singCharacters != null){return note.singCharacters;}
		if(strum.notes[section].changeSing){return strum.notes[section].charToSing;}
		return strum.charToSing;
	}

	public static function fileSong(song:String, cat:String, diff:String):String {
		var daSong:String = Paths.getFileName(song, true);

		daSong += '-' + Paths.getFileName(cat, true);
		daSong += '-' + Paths.getFileName(diff, true);

		return daSong;
	}

	public static function loadFromJson(songFormat:String):SwagSong {
		if(songFormat == null){songFormat = "Test-Normal-Normal";}

		var rawJson:String = Paths.chart(songFormat).getText().trim();
		var rawEvents:String = Paths.chart_events(songFormat).getText().trim();

		while(!rawJson.endsWith("}")){rawJson = rawJson.substr(0, rawJson.length - 1);}
		while(!rawEvents.endsWith("}")){rawEvents = rawEvents.substr(0, rawEvents.length - 1);}
		
		var toReturn:SwagSong = convert_song(songFormat, rawJson);
		var toEvents:SwagEvent = convert_events(rawEvents);

		parseJSONshit(toReturn, toEvents);
		return toReturn;
	}

	public static function parseJSONshit(swagShit:SwagSong, ?swagEvents:SwagEvent):Void {		
		if(swagShit.song == null){swagShit.song = "PlaceHolder";}
		if(swagShit.difficulty == null){swagShit.difficulty = "Normal";}
		if(swagShit.category == null){swagShit.category = "Normal";}

		if(swagShit.bpm <= 0){swagShit.bpm = 100;}
		if(swagShit.speed <= 0){swagShit.speed = 3.0;}
		
		if(swagShit.uiStyle == null){swagShit.uiStyle = "Default";}
		if(swagShit.stage == null){swagShit.stage = "Stage";}
		
		if(swagShit.characters == null){
			swagShit.characters = [
				["Daddy_Dearest", [100, 100], true, "Default", "NORMAL"],
				["Boyfriend", [770, 100], false, "Default", "NORMAL"],
				["Girlfriend", [540, 50], false, "Default", "GF"]
			];
		}

		if(swagShit.sectionStrums == null){swagShit.sectionStrums = [];}
		if(swagShit.sectionStrums.length <= 0){swagShit.sectionStrums.push({isPlayable: true,noteStyle:"Default", keys:4, charToSing:[], notes:[]});}
		if(swagShit.generalSection == null){swagShit.generalSection = [];}

		while(swagShit.generalSection.length < swagShit.sectionStrums[0].notes.length){swagShit.generalSection.push({bpm: swagShit.bpm, changeBPM: false, lengthInSteps: 16, strumToFocus: 0, charToFocus: 0, events: []});}
		if(swagEvents != null){
			if(swagEvents.sections == null){swagEvents.sections = [];}
			while(swagEvents.sections.length < swagShit.generalSection.length){swagEvents.sections.push({events: []});}
		}
		
		for(i in 0...swagShit.generalSection.length){			
			if(swagShit.generalSection[i].events == null){swagShit.generalSection[i].events = [];}

			if(swagEvents != null){
				while(swagEvents.sections[i].events.length > 0){
					var cur_glob:EventData = Note.getEventData(swagEvents.sections[i].events.shift());
				
					var has_note:Bool = false;
					for(ev in swagShit.generalSection[i].events){
						var cur_ev:EventData = Note.getEventData(ev);
						if(Note.compNotes(cur_glob, cur_ev, false)){has_note = true;}
					}

					if(!has_note){swagShit.generalSection[i].events.push(Note.convEventData(cur_glob));}
				}
			}

			for(ev in swagShit.generalSection[i].events){Note.set_note(ev, Note.convEventData(Note.getEventData(ev)));}

			
			if(swagShit.single_player < 0){swagShit.single_player = swagShit.sectionStrums.length - 1;}
		}

		if(swagShit.sectionStrums == null){
			swagShit.sectionStrums = [{
				isPlayable: true,
				noteStyle: swagShit.uiStyle,
				keys: 4,
				charToSing: [],
				notes: []
			}];
		}else{
			for(strum in swagShit.sectionStrums){
				if(strum.charToSing == null){strum.charToSing = [];}
				if(strum.keys <= 0){strum.keys = 4;}
				if(strum.noteStyle == null){strum.noteStyle = swagShit.uiStyle;}
				if(strum.notes == null){
					strum.notes = [];
				}else{
					for(sec in strum.notes){
						if(sec.charToSing == null){sec.charToSing = [];}
						if(sec.keys <= 0){sec.keys = strum.keys;}
						if(sec.sectionNotes == null){
							sec.sectionNotes = [];
						}else{
							for(nt in sec.sectionNotes){
								Note.set_note(nt, Note.convNoteData(Note.getNoteData(nt)));
							}
						}
					}
				}
			}
		}

		for(gen in swagShit.generalSection){
			if(gen.lengthInSteps <= 0){gen.lengthInSteps = 16;}
		}
		
		swagShit.validScore = true;
	}

	public static function convert_events(rawEvents:String):SwagEvent {
		var _global_events:Dynamic = cast Json.parse(rawEvents);
		if(_global_events.global == null){_global_events.global = {};}
		
		var aEvents:DynamicAccess<Dynamic> = cast _global_events.global;

		//Adding General Values
		if(!aEvents.exists("sections")){aEvents.set("sections", []);}

		return cast aEvents;
	}
	public static function convert_song(sName:String, rawSong:String):SwagSong {
		var _global_song:Dynamic = cast Json.parse(rawSong);
		if(_global_song.song == null){_global_song.song = {};}

		var aSong:DynamicAccess<Dynamic> = _global_song.song;

		//Adding General Values
		if(!aSong.exists("validScore")){aSong.set("validScore", false);}

		if(!aSong.exists("song")){
			aSong.set("song", "PlaceHolderName");
			if(sName.split("-")[2] != null){aSong.set("song", sName.split("-")[0]);}
		}
		
		if(!aSong.exists("difficulty")){
			aSong.set("difficulty", "Normal");
			if(sName.split("-")[2] != null){aSong.set("difficulty", sName.split("-")[2]);}
		}
		
		if(!aSong.exists("category")){
			aSong.set("category", "Normal");
			if(sName.split("-")[1] != null){aSong.set("category", sName.split("-")[1]);}
		}

		if(!aSong.exists("bpm")){aSong.set("bpm", 100);}
		if(!aSong.exists("speed")){aSong.set("speed", 1);}
		if(!aSong.exists("stage")){aSong.set("stage", "Stage");}

		if(!aSong.exists("strumToPlay")){aSong.set("strumToPlay", 1);}
		if(!aSong.exists("uiStyle")){aSong.set("uiStyle", "Default");}

		if(!aSong.exists("hasVoices")){aSong.set("hasVoices", aSong.get("needsVoices"));}
		if(!aSong.exists("hasVoices")){aSong.set("hasVoices", true);}

		if(!aSong.exists("characters")){
			var chrs:Array<Dynamic> = [];

			if(aSong.exists("player3")){chrs.push([aSong.get("player3"),[540,50],1,false,"Default","GF",0]); aSong.remove("player3");}
			else if(aSong.exists("gfVersion")){chrs.push([aSong.get("gfVersion"),[540,50],1,false,"Default","GF",0]); aSong.remove("gfVersion");}
			else if(aSong.exists("gf")){chrs.push([aSong.get("gf"),[540,50],1,false,"Default","GF",0]); aSong.remove("gf");}
			else{chrs.push(["Girlfriend",[540, 50],1,false,"Default","GF",0]);}

			if(aSong.exists("player2")){chrs.push([aSong.get("player2"),[100,100],1,true,"Default","NORMAL",0]); aSong.remove("player2");}
			else{chrs.push(["Daddy_Dearest",[100,100],1,true,"Default","NORMAL",0]);}

			if(aSong.exists("player1")){chrs.push([aSong.get("player1"),[770,100],1,false,"Default","NORMAL",0]); aSong.remove("player1");}
			else{chrs.push(["Boyfriend",[770,100],1,false,"Default","NORMAL",0]);}

			aSong.set("characters", chrs);
		}

		if((!aSong.exists("sectionStrums") || !aSong.exists("generalSection")) && aSong.exists("notes")){
			var notes:Array<Dynamic> = aSong.get("notes");

			var sNotes1:Array<SwagSection> = [];
			var sNotes2:Array<SwagSection> = [];
			var sGenSecs:Array<SwagGeneralSection> = [];

			for(sec in notes){
				var cSec:DynamicAccess<Dynamic> = sec;

				var iNotes:Array<Dynamic> = cSec.get("sectionNotes");
				var in1:Array<Dynamic> = [];
				var in2:Array<Dynamic> = [];
				var gen:Array<Dynamic> = [];
				if(iNotes != null){
					for(n in iNotes){
						if(n[0] < 0){
							gen.push(Note.convEventData(cast Note.getNoteData(n)));
						}else if(cSec.get("mustHitSection") == true){
							if(n[1] < 4){in2.push(n);}
							if(n[1] > 3){n[1] = n[1] % 4; in1.push(n);}
						}else{
							if(n[1] < 4){in1.push(n);}
							if(n[1] > 3){n[1] = n[1] % 4; in2.push(n);}
						}
					}
				}

				var iAltAnim:Bool = cSec.get("altAnim");

				var iKeys:Int = 4;
				var iChangeKeys:Bool = false;
				var iChangeSing:Bool = false;

				sNotes1.push({
					charToSing: [1],
					changeSing: iChangeSing,
					keys: iKeys,
					changeKeys: iChangeKeys,
					altAnim: iAltAnim,
					sectionNotes: in1
				});

				sNotes2.push({
					charToSing: [2],
					changeSing: iChangeSing,
					keys: iKeys,
					changeKeys: iChangeKeys,
					altAnim: iAltAnim,
					sectionNotes: in2
				});
				
				sGenSecs.push({
					bpm: aSong.get("bpm"),
					changeBPM: cSec.get("changeBPM"),
				
					lengthInSteps: (cSec.get("lengthInSteps") != null && cSec.get("lengthInSteps") > 0) ? cSec.get("lengthInSteps") : 16,
			
					strumToFocus: cSec.get("mustHitSection") ? 1 : 0,
					charToFocus: 0,
			
					events: gen
				});
			}

			var str1:SwagStrum = {
				isPlayable: true,
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [1],
				notes: sNotes1
			};

			var str2:SwagStrum = {
				isPlayable: true,
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [2],
				notes: sNotes2
			};
			
			if(!aSong.exists("generalSection")){aSong.set("generalSection", sGenSecs);}
			if(!aSong.exists("sectionStrums")){aSong.set("sectionStrums", [str1, str2]);}
			aSong.remove("notes");
		}
		if(!aSong.exists("sectionStrums")){
			var nStrm:SwagStrum = {
				isPlayable: true,
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [0],
				notes: []
			};

			aSong.set("sectionStrums", [nStrm]);
		}
		if(!aSong.exists("generalSection")){
			var nGenSec:SwagGeneralSection = {
				bpm: aSong.get("bpm"),
				changeBPM: false,
				
				lengthInSteps: 16,
			
				strumToFocus: 0,
				charToFocus: 0,
			
				events: []
			};

			aSong.set("generalSection", [nGenSec]);
		}

		return cast aSong;
	}

	public static var song_file:SaverMaster = null;
	public static function save_song(fileName:String, songData:SwagSong, options:{?onComplete:Void->Void, ?throwFunc:Exception->Void, ?returnOnThrow:Bool, ?path:String, ?saveAs:Bool}):Void {
		if(song_file != null || songData == null){return;}

		var _song:SwagSong = songData;

		parseJSONshit(_song);
		var _global_events:SwagEvent = {sections: []};
		
		for(i in 0..._song.generalSection.length){
			_global_events.sections.push({events:[]});
			var ev_to_del:Array<Dynamic> = [];

			for(ev in _song.generalSection[i].events){
				var _ev_data:EventData = Note.getEventData(ev);
				if(_ev_data.isExternal){
					_global_events.sections[i].events.push(ev);
					if(!_ev_data.isBroken){ev_to_del.push(ev);}
				}
			}

			while(ev_to_del.length > 0){
				var _del_ev:Array<Dynamic> = ev_to_del.shift();
				for(ev in _song.generalSection[i].events){if(ev == _del_ev){_song.generalSection[i].events.remove(ev); break;}}
			}

			for(ev in _global_events.sections[i].events){
				var _ev:EventData = Note.getEventData(ev);
				_ev.isExternal = true;
				_ev.isBroken = false;
				Note.set_note(ev, Note.convEventData(_ev));
			}
		}

		var song_data:String = "";
		var events_data:String = "";

		try{song_data = Json.stringify({song: _song},"\t");}catch(e){trace(e); if(options.throwFunc != null){options.throwFunc(e);} if(options.returnOnThrow){return;}}
		try{events_data = Json.stringify({global: _global_events},"\t");}catch(e){trace(e); if(options.throwFunc != null){options.throwFunc(e);} if(options.returnOnThrow){return;}}

		if(options.saveAs){
			var files_to_save:Array<{name:String, data:Dynamic}> = [{name: '$fileName.json', data: song_data}];
			if(events_data.length > 0){files_to_save.push({name: 'global_events.json', data: events_data});}
			song_file = new SaverMaster(files_to_save, {destroyOnComplete: true, onComplete: function(){if(options.onComplete != null){options.onComplete();} song_file = null;}});
			song_file.saveFile();
		}else{
			#if sys
				if((song_data != null) && (song_data.length > 0)){File.saveContent(options.path, song_data);}
				if((events_data != null) && (events_data.length > 0)){File.saveContent(options.path.replace('$fileName','global_events'), events_data);}
				if(options.onComplete != null){options.onComplete();}
			#end
		}

		for(i in 0..._global_events.sections.length){
			for(ev in _global_events.sections[i].events){
				_song.generalSection[i].events.push(ev);
			}
		}
	}
}

class SaverMaster extends FileReference {
	public var stuff_to_save:Array<{name:String, data:Dynamic}> = [];
	public var current_calls:Array<{event:Dynamic,func:Dynamic}> = [];
	public var options:Dynamic = {};

	public function new(?_stuff_to_save:Array<{name:String, data:Dynamic}>, ?options:Dynamic):Void {
		if(_stuff_to_save != null){this.stuff_to_save = _stuff_to_save;}
		if(options != null){this.options = cast options;}
		super();
	}

	public function saveFile(?_):Void {
		if(_ == null){
			this.addEventListener(Event.SELECT, saveFile);
			this.addEventListener(Event.COMPLETE, completedFiles);
			this.addEventListener(Event.CANCEL, saveFile);
			this.addEventListener(IOErrorEvent.IO_ERROR, saveFile);
		}

		if(stuff_to_save.length <= 0){completedFiles(); return;}
		var current_file:{name:String, data:Dynamic} = stuff_to_save.shift();
		this.save(current_file.data, current_file.name);
	}

	public function completedFiles(?_){
		if(options.onComplete != null){options.onComplete();}
		if(options.destroyOnComplete){removeListeners();}
	}

	private function removeListeners(){
		this.removeEventListener(Event.SELECT, saveFile);
		this.removeEventListener(Event.COMPLETE, completedFiles);
		this.removeEventListener(Event.CANCEL, saveFile);
		this.removeEventListener(IOErrorEvent.IO_ERROR, saveFile);
	}
}