package;

import ListStuff.Songs;
import Section.SwagSection;
import Section.SwagGeneralSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong = {
	var song:String;
	var difficulty:String;
	var category:String;

	var bpm:Float;
	var speed:Float;

	var needsVoices:Bool;
	var singleVoices:Bool;

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

class Song{
	public var song:String;
	public var difficulty:String;
	public var category:String;

	public var bpm:Float;
	public var speed:Float = 1;
	
	public var needsVoices:Bool = true;
	public var singleVoices:Bool = false;

	public var strumToPlay:Int = 0;
	
	var ui_style:String = "Default";

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
		trace("Loading: " + song);

		var rawJson = Assets.getText(Paths.chart(jsonInput, song)).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}