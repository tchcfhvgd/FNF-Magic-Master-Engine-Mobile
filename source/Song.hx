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

	var strumToPlay:Int;

	var uiStyle:String;

	var stage:String;	
	var characters:Array<Dynamic>;

	var generalSection:Array<SwagGeneralSection>;
	var sectionStrums:Array<SwagStrum>;
}

typedef SwagStrum = {
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
	var display:String;
	var title:String;
	var data:Array<Dynamic>;
	var songs:Array<String>;
	var keyLock:String;
	var hiddenOnWeeks:Bool;
	var hiddenOnFreeplay:Bool;
}
typedef ItemSong = {
	var song:String;
	var data:Array<Dynamic>;
	var keyLock:String;
	var hidden:Bool;
}
typedef ModSongs = {
	var mod:String;
	var songs:Array<ItemSong>;
}

class Song{
	public static function getStrumKeys(strum:SwagStrum, section:Int):Int {
		if(strum.notes[section].changeKeys){return strum.notes[section].keys;}
        return strum.keys;
	}

	public static function getNoteCharactersToSing(note:Note, strum:SwagStrum, section:Int):Array<Int> {
		if(note.singCharacters != null){return note.singCharacters;}
		if(strum.notes[section].changeSing){return strum.notes[section].charToSing;}
		return strum.charToSing;
	}


	public static function addSongToList(songItem:ItemSong, list:Array<ItemSong>):Void {
		for(lItem in list){if(songItem.song == lItem.song){return;}}
		list.push(songItem);
	}
	public static function addSongToModList(songItem:ItemSong, data:Array<Dynamic>, list:Array<ModSongs>):Void {
		for(lItem in list){
			if(lItem.mod != data[0]){continue;}
			for(song in lItem.songs){if(songItem.song == song.song){return;}}
			lItem.songs.push(songItem); return;
		}
	}

	public static function getSongModList():Array<ModSongs> {
		var SongList:Array<ModSongs> = [];

		var weeks:Map<String, Dynamic> = Paths.readFileToMap('assets/data/weeks.json');
		for(i in weeks.keys()){
			var bWeek:SongsData = cast Json.parse(Paths.getText(weeks.get(i)));
			var mod = i.split("|")[1];

			SongList.push({mod: mod, songs: []});

			for(week in bWeek.weekData){
				if(week.hiddenOnFreeplay){continue;}

				var cats:Array<Dynamic> = week.data;
				var lock:String = week.keyLock;

				for(song in week.songs){
					var songItem:ItemSong = {
						song: song,
						data: cats,
						keyLock: lock,
						hidden: false
					};
					addSongToModList(songItem, [mod], SongList);
				}
			}

			for(song in bWeek.freeplayData){
				if(song.hidden){continue;}

				var cats:Array<Dynamic> = song.data;
				var lock:String = song.keyLock;
					
				var songItem:ItemSong = {
					song: song.song,
					data: cats,
					keyLock: lock,
					hidden: false
				};
				addSongToModList(songItem, [mod], SongList);
			}

			#if sys
			if(bWeek.showArchiveSongs){
				var songsDirectory:String = weeks[i];
				songsDirectory = songsDirectory.replace('data/weeks.json', 'songs');

				for(song in FileSystem.readDirectory(songsDirectory)){
					if(!FileSystem.isDirectory('${songsDirectory}/${song}') || !FileSystem.exists('${songsDirectory}/${song}/Data') || FileSystem.readDirectory('${songsDirectory}/${song}/Data').length <= 0){continue;}

					var data:Array<Dynamic> = [];
					for(chart in FileSystem.readDirectory('${songsDirectory}/${song}/Data')){
						var cStats:Array<String> = chart.replace(".json", "").split("-");
						if(cStats[1] == null){cStats[1] = "Normal";}
						if(cStats[2] == null){cStats[2] = "Normal";}
						var hasCat:Bool = false;
						for(d in data){
							if(d[0] == cStats[1]){continue;}
							
							hasCat = true;
							d[1].push(cStats[2]);
						}
						if(!hasCat){data.push([cStats[1], [cStats[2]]]);}
					}
					
					var songItem:ItemSong = {
						song: song,
						data: data,
						keyLock: null,
						hidden: false
					};
					addSongToModList(songItem, [mod], SongList);
				}
			}
			#end
		}

		return SongList;
	}

	public static function fileSong(song:String, cat:String, diff:String):String {
		var daSong:String = Paths.getFileName(song, true);

		daSong += '-' + Paths.getFileName(cat, true);
		daSong += '-' + Paths.getFileName(diff, true);

		return daSong;
	}

	public var song:String;
	public var difficulty:String;
	public var category:String;

	public var bpm:Float;
	public var speed:Float = 1;
	
	public var hasVoices:Bool = true;

	public var strumToPlay:Int = 0;
	
	var uiStyle:String = "Default";

	public var stage:String = '';
	public var characters:Array<Dynamic> = [
		["Daddy_Dearest", [100, 100], true, "Default", "NORMAL"],
		["Boyfriend", [770, 100], false, "Default", "NORMAL"],
		["Girlfriend", [400, 130], false, "Default", "GF"]
	];

	public var generalSection:Array<SwagGeneralSection>;
	public var sectionStrums:Array<SwagStrum>;

	public function new(song, generalSection, sectionStrums, bpm)
	{
		this.song = song;
		this.generalSection = generalSection;
		this.sectionStrums = sectionStrums;
		this.bpm = bpm;
	}

	public static function loadFromJson(songFormat:String):SwagSong {
		var rawJson:String = Paths.getText(Paths.chart(songFormat)).trim();
		var rawEvents:String = Paths.getText(Paths.chart_events(songFormat)).trim();

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
				["Girlfriend", [400, 130], false, "Default", "GF"]
			];
		}
		if(swagShit.generalSection == null){swagShit.generalSection = [];}
		while(swagShit.generalSection.length < swagShit.sectionStrums[0].notes.length){swagShit.generalSection.push({bpm: swagShit.bpm, changeBPM: false, lengthInSteps: 16, strumToFocus: 0, charToFocus: 0, events: []});}
		if(swagEvents != null){
			if(swagEvents.sections == null){swagEvents.sections = [];}
			while(swagEvents.sections.length < swagShit.generalSection.length){swagEvents.sections.push({events: []});}
		}
		
		for(i in 0...swagShit.generalSection.length){
			if(swagShit.generalSection[i].events == null){
				swagShit.generalSection[i].events = [];
			}else{
				for(ev in swagShit.generalSection[i].events){
					Note.set_note(ev, Note.convEventData(Note.getEventData(ev)));
				}
			}

			if(swagEvents != null){
				while(swagEvents.sections[i].events.length > 0){
					var cur_glob:EventData = swagEvents.sections[i].events.shift();
				
					var has_note:Bool = false;
					for(ev in swagShit.generalSection[i].events){
						var cur_ev:EventData = Note.getEventData(ev);
						if(Note.compNotes(cur_glob, cur_ev, false)){
							has_note = true;
						}
					}

					if(!has_note){swagShit.generalSection[i].events.push(Note.convEventData(cur_glob));}
				}
			}
		}

		if(swagShit.sectionStrums == null){
			swagShit.sectionStrums = [];
			swagShit.sectionStrums.push({
				noteStyle: swagShit.uiStyle,
				keys: 4,
				charToSing: [],
				notes: []
			});
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
		
		swagShit.validScore = true;
	}

	public static function convert_events(rawEvents:String):SwagEvent {
		var _global_events:Dynamic = cast Json.parse(rawEvents);
		if(_global_events.global == null){_global_events.global = {};}
		
		var aEvents:DynamicAccess<Dynamic> = cast Json.parse(rawEvents).global;

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

			if(aSong.exists("player3")){chrs.push([aSong.get("player3"),[400,130],1,true,"Default","GF",0]); aSong.remove("player3");}
			else if(aSong.exists("gfVersion")){chrs.push([aSong.get("gfVersion"),[400,130],1,true,"Default","GF",0]); aSong.remove("gfVersion");}
			else if(aSong.exists("gf")){chrs.push([aSong.get("gf"),[400,130],1,true,"Default","GF",0]); aSong.remove("gf");}
			else{chrs.push(["Girlfriend",[400,130],1,true,"Default","GF",0]);}

			if(aSong.exists("player2")){chrs.push([aSong.get("player2"),[100,100],1,true,"Default","NORMAL",0]); aSong.remove("player2");}
			else{chrs.push(["Daddy_Dearest",[100,100],1,true,"Default","NORMAL",0]);}

			if(aSong.exists("player1")){chrs.push([aSong.get("player1"),[770,100],1,false,"Default","NORMAL",0]); aSong.remove("player1");}
			else{chrs.push(["Boyfriend",[770,100],1,false,"Default","NORMAL",0]);}

			aSong.set("characters", chrs);
		}

		if(!aSong.exists("generalSection")){aSong.set("generalSection", []);}
		if(!aSong.exists("sectionStrums") && aSong.exists("notes")){
			var notes:Array<Dynamic> = aSong.get("notes");

			var sNotes1:Array<SwagSection> = [];
			var sNotes2:Array<SwagSection> = [];

			for(sec in notes){
				var cSec:DynamicAccess<Dynamic> = sec;

				var iNotes:Array<Dynamic> = cSec.get("sectionNotes");
				var in1:Array<Dynamic> = [];
				var in2:Array<Dynamic> = [];
				if(iNotes != null){
					for(n in iNotes){
						if(cSec.get("mustHitSection") == true){
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
			}

			var str1:SwagStrum = {
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [1],
				notes: sNotes1
			};

			var str2:SwagStrum = {
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [2],
				notes: sNotes2
			};
			
			aSong.set("sectionStrums", [str1, str2]);
			aSong.remove("notes");
		}
		if(!aSong.exists("sectionStrums")){
			var nStrm:SwagStrum = {
				noteStyle: aSong.get("uiStyle"),
				keys: 4,
				charToSing: [0],
				notes: []
			};

			aSong.set("sectionStrums", [nStrm]);
		}

		return cast aSong;
	}

	public static var song_file:FileMaster = null;
	public static function save_song(fileName:String, songData:SwagSong, options:{?onComplete:Void->Void, ?throwFunc:Exception->Void, ?returnOnThrow:Bool, ?path:String, ?saveAs:Bool}):Void {
		if(song_file != null || songData == null){return;}

		var _song:SwagSong = cast songData;

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
			song_file = new FileMaster(files_to_save, {onComplete: function(){if(options.onComplete != null){options.onComplete();} song_file = null;}});

			song_file.saveFile();
		}else{
			#if sys
				if((song_data != null) && (song_data.length > 0)){File.saveContent(options.path, song_data);}
				if((events_data != null) && (events_data.length > 0)){File.saveContent(options.path.replace('$fileName','global_events'), events_data);}
				if(options.onComplete != null){options.onComplete();}
				song_file = null;
			#end
		}
	}
}

class FileMaster extends FileReference {
	public var stuff_to_save:Array<{name:String, data:Dynamic}> = [];
	public var options_file:Dynamic = {};

	public function new(_stuff_to_save:Array<{name:String, data:Dynamic}>, ?options:{?onComplete:Void->Void}):Void {
		this.stuff_to_save = _stuff_to_save;
		this.options_file = options;
		super();
		
		this.addEventListener(Event.SELECT, saveFile);
		this.addEventListener(Event.COMPLETE, removeListeners);
		this.addEventListener(Event.CANCEL, saveFile);
		this.addEventListener(IOErrorEvent.IO_ERROR, saveFile);
	}

	public function saveFile(?_):Void {
		if(stuff_to_save.length <= 0){removeListeners(); return;}
		var current_file:{name:String, data:Dynamic} = stuff_to_save.shift();
		this.save(current_file.data, current_file.name);
	}

	private function removeListeners(?_){
		this.removeEventListener(Event.SELECT, saveFile);
		this.removeEventListener(Event.COMPLETE, removeListeners);
		this.removeEventListener(Event.CANCEL, saveFile);
		this.removeEventListener(IOErrorEvent.IO_ERROR, saveFile);
		if(options_file.onComplete != null){options_file.onComplete();}
	}
}