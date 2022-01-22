package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:String = "Hard", ?cat:String = "Normal"):Void{
		var daSong:String = formatSong(song, diff, cat);

		#if !switch
		NGio.postScore(score, song);
		#end

		if(PreSettings.getPreSetting("BotPlay")){
			if(songScores.exists(daSong)){
				if(songScores.get(daSong) < score){
					setScore(daSong, score);
				}
			}
			else{
				setScore(daSong, score);
			}
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:String = "Hard", ?cat:String = "Normal"):Void{
		#if !switch
		NGio.postScore(score, "Week " + week);
		#end


		var daWeek:String = formatSong('week' + week, diff, cat);

		if(songScores.exists(daWeek)){
			if(songScores.get(daWeek) < score){
				setScore(daWeek, score);
			}
		}
		else{
			setScore(daWeek, score);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:String, cat:String):String{
		var daSong:String = song;

		daSong += '-' + cat;
		daSong += '-' + diff;

		return daSong;
	}

	public static function getScore(song:String, diff:String, cat:String):Int {
		if (!songScores.exists(formatSong(song, diff, cat)))
			setScore(formatSong(song, diff, cat), 0);

		return songScores.get(formatSong(song, diff, cat));
	}

	public static function getWeekScore(week:Int, diff:String, cat:String):Int{
		if (!songScores.exists(formatSong('week' + week, diff, cat)))
			setScore(formatSong('week' + week, diff, cat), 0);

		return songScores.get(formatSong('week' + week, diff, cat));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
