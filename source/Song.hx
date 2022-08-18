package;

import Section.SwagSection;
import Section.SwagGeneralSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import haxe.DynamicAccess;

import StrumLineNote.Note;

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
typedef WFData = {
	var weekData:WeekData;
	var freeplayData:FreeplayData;
}

typedef WeekData = {
	var onlyThis:Bool;
	var weeks:Array<ItemWeek>;
}
typedef FreeplayData = {
	var showArchiveSongs:Bool;
	var freeplay:Array<ItemSong>;
}


typedef ItemWeek = {
	var name:String;
	var display:String;
	var title:String;
	var data:Array<Dynamic>;
	var songs:Array<String>;
	var lock:Bool;
	var hiddenOnWeeks:Bool;
	var hiddenOnFreeplay:Bool;
}
typedef ItemSong = {
	var song:String;
	var data:Array<Dynamic>;
	var lock:Bool;
}

class Song{
	public static function addSongToList(name:String, cats:Array<Dynamic>, locked:Bool, list:Dynamic):Void {
		if((list is Array<ItemSong>)){
			var list:Array<ItemSong> = cast list;
			var isTrue:Bool = false;

			for(lItem in list){if(name == lItem.song){isTrue = true; break;}}

			if(!isTrue){
				var item:ItemSong = {
					song: name,
					data: cats,
					lock: locked
				};

				list.push(item);
			}
		}
		
	}

	public static function getSongList():Array<ItemSong> {
		var SongList:Array<ItemSong> = [];

		for(i in Paths.readFile('assets/data/', 'weeks.json')){
			var bWeek:WFData = Json.parse(Paths.getText(i));

			for(week in bWeek.weekData.weeks){
				if(!week.hiddenOnFreeplay){
					var cats:Array<Dynamic> = week.data;
					var lock:Bool = week.lock;
	
					for(song in week.songs){addSongToList(song, cats, lock, SongList);}
				}			
			}

			for(song in bWeek.freeplayData.freeplay){
				var cats:Array<Dynamic> = song.data;
				var lock:Bool = song.lock;
	
				addSongToList(song.song, cats, lock, SongList);	
			}

			#if sys
			if(bWeek.freeplayData.showArchiveSongs){
				var songsDirectory:String = i;
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
								if(d[0] == cStats[1]){
									hasCat = true;
									d[1].push(cStats[2]);
								}
							}
							if(!hasCat){data.push([cStats[1], [cStats[2]]]);}
						}
						addSongToList(song, data, false, SongList);
					}
				}
			}
			#end
		}

		return SongList;
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

	public static function loadFromJson(jsonInput:String, song:String):SwagSong{
		var rawJson:String = Paths.getText(Paths.chart(jsonInput, song)).trim();

		while (!rawJson.endsWith("}")){rawJson = rawJson.substr(0, rawJson.length - 1);}
		
		return parseJSONshit(rawJson, jsonInput);
	}

	public static function parseJSONshit(rawJson:String, sName:String):SwagSong{
		var swagShit:SwagSong = convertJSON(sName, cast Json.parse(rawJson).song);
		swagShit.validScore = true;
		return swagShit;
	}

	public static function convertJSON(sName:String, songJSON:Dynamic):SwagSong{
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
						n = Note.getNoteDynamicData(n);

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
			if(g.events.length > 0){for(event in g.events){event = Note.getEventDynamicData(event);}}
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
					if(sNotes.sectionNotes.length > 0){for(nNote in sNotes.sectionNotes){nNote = Note.getNoteDynamicData(nNote);}}
				}
			}
		}
		aSong.set("sectionStrums", sStrums);

		var dSong:Dynamic = aSong;
		var toReturn:SwagSong = dSong;
		return toReturn;
	}	
}