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

	var hasCharVoices:Bool;
	var voices:Array<String>;

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

typedef FreeplayData = {
	var showArchiveSongs:Bool;
	var freeplay:Array<ItemSong>;
}
typedef ItemSong = {
	var song:String;
	var data:Array<Dynamic>;
	var lock:Bool;
}

class Song{
	public static function addToList(item:Dynamic, list:Dynamic):Void {
		if((list is Array<ItemSong>)){
			var list:Array<ItemSong> = cast list;
			var isTrue:Bool = false;

			for(lItem in list){
				if(item.song == lItem.song){
					isTrue = true;
					break;
				}
			}

			if(!isTrue){list.push(item);}
		}
		
	}

	public static function getSongList():Array<ItemSong> {
		var SongList:Array<ItemSong> = [];

		//Adding Base Weeks
		var bWeeks:WFData = Json.parse(Assets.getText('assets/data/weeks.json'));
		for(week in bWeeks.weekData.weeks){
			if(!week.hiddenOnFreeplay){
				var cats:Array<Dynamic> = week.data;
				var lock:Bool = week.lock;

				for(song in week.songs){
					var item:ItemSong = {
						song: song,
						data: cats,
						lock: lock
					};

					addToList(item, SongList);
				}
			}			
		}

		for(song in bWeeks.freeplayData.freeplay){
			var cats:Array<Dynamic> = song.data;
			var lock:Bool = song.lock;

			var item:ItemSong = {
				song: song.song,
				data: cats,
				lock: lock
			};

			addToList(item, SongList);	
		}

		for(mod in ModSupport.MODS){var path = '${mod.path}/assets/data/weeks.json';
			if(mod.enabled && Paths.exists(path)){
				var bWeeks:WFData = Json.parse(Paths.getText(path));
				for(week in bWeeks.weekData.weeks){
					if(!week.hiddenOnFreeplay){
						var cats:Array<Dynamic> = week.data;
						var lock:Bool = week.lock;

						for(song in week.songs){
							var item:ItemSong = {
								song: song,
								data: cats,
								lock: lock
							};

							addToList(item, SongList);
						}
					}			
				}

				for(song in bWeeks.freeplayData.freeplay){
					var cats:Array<Dynamic> = song.data;
					var lock:Bool = song.lock;

					var item:ItemSong = {
						song: song.song,
						data: cats,
						lock: lock
					};

					addToList(item, SongList);	
				}

				#if sys
				if(bWeeks.freeplayData.showArchiveSongs){
					var songsDirectory:String = FileSystem.absolutePath('${mod.path}/assets/songs');
					for(song in FileSystem.readDirectory(songsDirectory)){
						var data:Array<Dynamic> = [];
						if(FileSystem.isDirectory('${songsDirectory}/${song}') && FileSystem.exists('${songsDirectory}/${song}/Data')){
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
				
								if(!hasCat){
									data.push([cStats[1], [cStats[2]]]);
								}

								var item:ItemSong = {
									song: Paths.getFileName(song, true),
									data: data,
									lock: false
								}; 
								
								addToList(item, SongList);
							}
						}
					}
				}
				#end	
			}
		}

		return SongList;
	}

	public var song:String;
	public var difficulty:String;
	public var category:String;

	public var bpm:Float;
	public var speed:Float = 1;
	
	public var voices:Array<String> = ["General"];

	public var strumToPlay:Int = 0;
	
	var uiStyle:String = "Default";

	public var stage:String = '';
	public var characters:Array<Dynamic> = [
		["Fliqpy", [140, 210], true, "Default", "NORMAL"],
		["Boyfriend", [140, 210], false, "Default", "NORMAL"],
		["Girlfriend", [140, 210], false, "Default", "GF"]
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

	//TypeChars - [Magic - Magic Master Charts] | [Psych - Psych Engine Charts] | [Kade - Kade Engine Charts] | [Vanilla - Funkin Master Charts]
	public static function convertJSON(sName:String, songJSON:Dynamic, typeChart:String = "Magic"):SwagSong{
		var aSong:DynamicAccess<Dynamic> = songJSON;

		//Adding General Values
		if(aSong.get("validScore") == null){aSong.set("validScore", false);}

		if(aSong.get("song") == null){
			if(sName.split("-")[2] != null){
				aSong.set("song", Paths.getFileName(sName.split("-")[0], true));
			}else{
				aSong.set("song", "PlaceHolderName");
			}
		}

		if(aSong.get("bpm") == null){aSong.set("bpm", 100);}
		if(aSong.get("speed") == null){aSong.set("speed", 1);}
		if(aSong.get("stage") == null){aSong.set("stage", "stage");}

		switch(typeChart){
			default:{ //Magic Charts
				if(aSong.get("strumToPlay") == null){aSong.set("strumToPlay", 1);}
				if(aSong.get("uiStyle") == null){aSong.set("uiStyle", "Default");}
				
				if(aSong.get("difficulty") == null){
					if(sName.split("-")[2] != null){
						aSong.set("difficulty", sName.split("-")[2]);
					}else{
						aSong.set("difficulty", "Normal");
					}
				}
				if(aSong.get("category") == null){
					if(sName.split("-")[1] != null){
						aSong.set("category", sName.split("-")[1]);
					}else{
						aSong.set("category", "Normal");
					}
				}


				if(aSong.get("voices") == null){
					if(aSong.get("needsVoices") != null){
						if(aSong.get("needsVoices") == true){
							if(aSong.get("doubleVoices") == true){
								aSong.set("voices", ["Default_1", "Default_2"]);
							}else{
								aSong.set("voices", ["Default"]);
							}
						}else{
							aSong.set("voices", []);
						}
					}else{
						aSong.set("voices", []);
					}
				}

				if(aSong.get("characters") == null){
					var chrs:Array<Dynamic> = [];

					if(aSong.get("player1") != null){
						if((aSong.get("player1") is Array<Dynamic>)){
							chrs.push([aSong.get("player1")[0],[770,74],1,false,"Default","NORMAL",0]);
						}else{
							chrs.push([aSong.get("player1"),[770,74],1,false,"Default","NORMAL",0]);
						}
					}

					if(aSong.get("player2") != null){
						if((aSong.get("player2") is Array<Dynamic>)){
							chrs.push([aSong.get("player2")[0],[100,381],1,false,"Default","NORMAL",0]);
						}else{
							chrs.push([aSong.get("player2"),[100,381],1,false,"Default","NORMAL",0]);
						}
					}

					if(aSong.get("gfVersion") != null){chrs.push([aSong.get("gfVersion"),[400,130],1,true,"Default","GF",0]);}
					else if(aSong.get("gf") != null){chrs.push([aSong.get("gf"),[400,130],1,true,"Default","GF",0]);}

					aSong.set("characters", chrs);
				}

				if(aSong.get("generalSection") == null){
					if(aSong.get("notes") != null){
						var notes:Array<Dynamic> = aSong.get("notes");

						var gSec:Array<SwagGeneralSection> = [];
						for(sec in notes){
							var cSec:DynamicAccess<Dynamic> = sec;

							var iBpm:Float = cSec.get("bpm");
							if(iBpm == 0){iBpm = aSong.get("bpm");}

							var iChangeBPM:Bool = cSec.get("changeBPM");

							var iLengthInSteps:Int = cSec.get("lengthInSteps");
							if(iLengthInSteps == 0){iLengthInSteps = 16;}

							var iStrumToFocus:Int = 0;
							if(cSec.get("mustHitSection") == true){iStrumToFocus = 1;}

							var cgSec:SwagGeneralSection = {
								bpm: iBpm,
								changeBPM: iChangeBPM,

								lengthInSteps: iLengthInSteps,
								strumToFocus: iStrumToFocus,
								charToFocus: 0
							};

							gSec.push(cgSec);
						}

						aSong.set("generalSection", gSec);
					}else{
						aSong.set("generalSection", []);
					}
				}

				if(aSong.get("sectionStrums") == null){
					var nSecStrums:Array<SwagStrum> = [];

					if(aSong.get("notes") != null){
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
									n = Note.getNoteDynamicData(n, true);

									if(cSec.get("mustHitSection") == true){
										if(n[1] < 4){
											in2.push(n);
										}
										if(n[1] > 3){
											n[1] = n[1] % 4;
											in1.push(n);
										}
									}else{
										if(n[1] < 4){
											in1.push(n);
										}
										if(n[1] > 3){
											n[1] = n[1] % 4;
											in2.push(n);
										}
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
							charToSing: [1],
							notes: sNotes2
						};
						
						nSecStrums.push(str1);
						nSecStrums.push(str2);
					}else{
						nSecStrums = [
							{
								noteStyle: aSong.get("uiStyle"),
								keys: 4,
								charToSing: [1],
								notes: [
								]
							},
							{
								noteStyle: aSong.get("uiStyle"),
								keys: 4,
								charToSing: [2],
								notes: []
							}
						];
					}

					aSong.set("sectionStrums", nSecStrums);
				}
			}
		}

		var dSong:Dynamic = aSong;
		var toReturn:SwagSong = dSong;
		return toReturn;
	}	
}