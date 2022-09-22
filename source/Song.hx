package;

import Section.SwagGeneralSection;
import haxe.format.JsonParser;
import Section.SwagSection;
import haxe.DynamicAccess;
import lime.utils.Assets;
import haxe.Json;

import Note;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

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

		var weeks:Map<String, Dynamic> = Paths.readFileToMap('assets/data/', 'weeks.json');
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
				var songsDirectory:String = weeks.get(i);
				songsDirectory = songsDirectory.replace('data/weeks.json', 'songs');

				for(song in FileSystem.readDirectory(songsDirectory)){
					if(FileSystem.isDirectory('${songsDirectory}/${song}') && FileSystem.exists('${songsDirectory}/${song}/Data')){
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

		while(!rawJson.endsWith("}")){rawJson = rawJson.substr(0, rawJson.length - 1);}
		
		return parseJSONshit(rawJson, songFormat);
	}

	public static function parseJSONshit(rawJson:String, sName:String):SwagSong {
		var swagShit:SwagSong = convertJSON(sName, cast Json.parse(rawJson).song);
		
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
		if(swagShit.generalSection == null){swagShit.generalSection = [];}else{for(gen in swagShit.generalSection){if(gen.events == null){gen.events = [];}}}
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
				if(strum.notes == null){strum.notes = [];}else{
					for(sec in strum.notes){
						if(sec.charToSing == null){sec.charToSing = [];}
						if(sec.keys <= 0){sec.keys = strum.keys;}
						if(sec.sectionNotes == null){sec.sectionNotes = [];}
					}
				}
			}
		}
		
		swagShit.validScore = true;
		
		return swagShit;
	}

	public static function convertJSON(sName:String, songJSON:Dynamic):SwagSong {
		var aSong:DynamicAccess<Dynamic> = songJSON;

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
		if(!aSong.exists("stage")){aSong.set("stage", "stage");}

		if(!aSong.exists("strumToPlay")){aSong.set("strumToPlay", 1);}
		if(!aSong.exists("uiStyle")){aSong.set("uiStyle", "Default");}

		if(!aSong.exists("hasVoices")){aSong.set("hasVoices", aSong.get("needsVoices"));}
		if(!aSong.exists("hasVoices")){aSong.set("hasVoices", true);}

		if(!aSong.exists("characters")){
			var chrs:Array<Dynamic> = [];

			if(aSong.exists("player3")){chrs.push([aSong.get("player3"),[400,130],1,true,"Default","GF",0]);}
			else if(aSong.exists("gfVersion")){chrs.push([aSong.get("gfVersion"),[400,130],1,true,"Default","GF",0]);}
			else if(aSong.exists("gf")){chrs.push([aSong.get("gf"),[400,130],1,true,"Default","GF",0]);}
			else{chrs.push(["Girlfriend",[400,130],1,true,"Default","GF",0]);}

			if(aSong.exists("player2")){chrs.push([aSong.get("player2"),[100,100],1,true,"Default","NORMAL",0]);}
			else{chrs.push(["Daddy_Dearest",[100,100],1,true,"Default","NORMAL",0]);}

			if(aSong.exists("player1")){chrs.push([aSong.get("player1"),[770,100],1,false,"Default","NORMAL",0]);}
			else{chrs.push(["Boyfriend",[770,100],1,false,"Default","NORMAL",0]);}

			aSong.set("characters", chrs);
		}

		if(!aSong.exists("generalSection")){
			aSong.set("generalSection", []);

			if(aSong.exists("notes")){
				var notes:Array<Dynamic> = aSong.get("notes");

				for(sec in notes){
					var cSec:DynamicAccess<Dynamic> = sec;

					var iBpm:Float = aSong.get("bpm");
					if(cSec.exists("bpm")){iBpm = cSec.get("bpm");}

					var iChangeBPM:Bool = cSec.get("changeBPM");

					var iLengthInSteps:Int = 16;
					if(cSec.exists("lengthInSteps")){iLengthInSteps = cSec.get("lengthInSteps");}

					var iStrumToFocus:Int = 0;
					if(cSec.get("mustHitSection") == true){iStrumToFocus = 1;}

					var cgSec:SwagGeneralSection = {
						bpm: iBpm,
						changeBPM: iChangeBPM,

						lengthInSteps: iLengthInSteps,
						strumToFocus: iStrumToFocus,
						charToFocus: 0,

						events: []
					};

					aSong.get("generalSection").push(cgSec);
				}
			}
		}

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


		var gen:Array<SwagGeneralSection> = aSong.get("generalSection");
		if(gen.length <= 0){
			gen.push({
				bpm: aSong.get("bpm"),
				changeBPM: false,

				lengthInSteps: 16,
				strumToFocus: 0,
				charToFocus: 0,

				events: []
			});
		}
		for(g in gen){
			if(g.bpm == 0){g.bpm = aSong.get("bpm");}
			if(g.lengthInSteps == 0){g.lengthInSteps = 16;}
			if(g.events == null){g.events = [];}
			if(g.events.length > 0){g.events.sort((a, b) -> (a[0] - b[0]));}
		}
		aSong.set("generalSection", gen);

		var sStrums:Array<SwagStrum> = aSong.get("sectionStrums");
		for(strum in sStrums){
			if(strum.noteStyle == null){strum.noteStyle = aSong.get("uiStyle");}
			if(strum.charToSing == null){strum.charToSing = [];}
			
			if(strum.notes == null){
				strum.notes = [{
					charToSing: [],
					changeSing: false,
					keys: 4,
					changeKeys: false,
					altAnim: false,
					sectionNotes: []
				}];
			}
			if(strum.notes.length > 0){
				for(sNotes in strum.notes){
					if(sNotes.charToSing == null){sNotes.charToSing = [];}
					if(sNotes.sectionNotes == null){sNotes.sectionNotes = [];}
					if(sNotes.sectionNotes.length > 0){sNotes.sectionNotes.sort((a, b) -> (a[0] - b[0]));}
				}
			}
		}
		aSong.set("sectionStrums", sStrums);

		var dSong:Dynamic = aSong;
		var toReturn:SwagSong = dSong;
		return toReturn;
	}	
}