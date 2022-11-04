package;

import flixel.FlxG;

using StringTools;

class Highscore {
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveSongScore(song:String, score:Int = 0, ?diff:String = "Hard", ?cat:String = "Normal"):Void {
		var daSong:String = Song.fileSong(song, cat, diff);

		if(PreSettings.getPreSetting("BotPlay", "Cheating Settings") || (songScores.exists(daSong) && songScores.get(daSong) >= score)){return;}

		#if !switch
		NGio.postScore(score, song);
		#end

		setScore(daSong, score);
	}

	public static function saveWeekScore(weekName:String, score:Int = 0, ?diff:String = "Hard", ?cat:String = "Normal"):Void {
		var daWeek:String = Song.fileSong('Week_$weekName', cat, diff);

		#if !switch
		NGio.postScore(score, "Week " + weekName);
		#end

		if(PreSettings.getPreSetting("BotPlay", "Cheating Settings") || (songScores.exists(daWeek) && songScores.get(daWeek) > score)){return;}

		setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void {
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function getScore(song:String, diff:String, cat:String):Int {
		var daSong:String = Song.fileSong(song, cat, diff);

		if(!songScores.exists(daSong)){return 0;}
		return songScores.get(daSong);
	}

	public static function getWeekScore(weekName:String, diff:String, cat:String):Int {
		var daWeek:String = Song.fileSong('Week_$weekName', cat, diff);

		if(!songScores.exists(daWeek)){return 0;}
		return songScores.get(daWeek);
	}

	public static function checkLock(key:String, isWeek:Bool = false):Bool {
		if(key == null){return false;}
		for(get in songScores.keys()){if(get.contains(isWeek ? 'Week_$key-' : '$key-')){return false;}}
		return true;
	}

	public static function load():Void {
		if(FlxG.save.data.songScores != null){songScores = FlxG.save.data.songScores;}
	}
}
