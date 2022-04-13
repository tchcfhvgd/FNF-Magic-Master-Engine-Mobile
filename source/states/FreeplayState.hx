package states;

import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

import ListStuff;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;

	var scoreText:FlxText;
	//var comboText:FlxText;
	var diffText:FlxText;
	var countText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		//for (i in 0...initSonglist.length)
		//{
		//	var data:Array<String> = initSonglist[i].split(':');
		//	songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		//}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC FROM WEEKS
		for(week in StoryMenuState.weekData){
			var category = week[0];

			for(i in 0...week[1].length){
				addSong(week[1][i], category);
			}
		}

		trace("Weeks Songs Added");

		// ADD MUSIC MANUALLY
		addSong("Flippin Force", [["Normal", ["Hard"]]]);

		trace("Manually Songs Added");

		// LOAD MUSIC FROM ARCHIVES
		for(i in 0...Songs.listSongs.length){
			addSong(Songs.checkName(i));
		}

		trace("Archive Songs Added");
		
		bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = true;
		add(bg);

		var songBG:FlxSprite = new FlxSprite(0, FlxG.height - 80).makeGraphic(Std.int(FlxG.width), 96, 0xFF000000);
		songBG.alpha = 0.6;
		add(songBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = "freeItem";
			songText.targetY = i;
			grpSongs.add(songText);
		}

		countText = new FlxText(FlxG.width - 55,FlxG.height * 0.90, Std.string(curSelected) + "/" + Std.string(songs.length), 24);
		countText.setFormat(Paths.font("Countryhouse.ttf"), 24, FlxColor.WHITE, RIGHT);
		add(countText);

		scoreText = new FlxText(0, 0, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("Countryhouse.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 32);
		diffText.setFormat(Paths.font("Countryhouse.ttf"), 32, FlxColor.WHITE, RIGHT);
		diffText.font = scoreText.font;
		add(diffText);

		//comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		//comboText.font = diffText.font;
		//add(comboText);

		add(scoreText);

		changeSelection();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, ?categ:Array<Dynamic>){
		var hasSong = false;
		for(i in songs){
			if(i.songName == songName){hasSong = true;}
		}

		if(!hasSong){
			if(categ != null){
				songs.push(new SongMetadata(songName, categ));
				trace("Song Added: " + songName + " | " + categ);
			}else{
				var category:Array<Dynamic> = [];
				var charts = Songs.checkCharts(songName);
			
				for(chart in charts){
					var split = chart[0].split('-');
					var hasCat = false;

					for(cat in category){
						if(cat[0] == split[1]){
							if(!cat[1].contains(split[2])){
								cat[1].push(split[2]);
							}
							hasCat = true;
						}
					}

					if(!hasCat){
					category.push([split[1], [split[2]]]);
					}
				}
				songs.push(new SongMetadata(songName, category));
				trace("Song Added: " + songName + " | " + category);
			}
		}else{
			trace("Song Already Exists: " + songName);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		diffText.text = songs[curSelected].curDiff.toUpperCase() + " | " + songs[curSelected].curCategory.toUpperCase() + " (TAB TO SWITCH)";
		countText.text = Std.string(curSelected+1) + "/" + Std.string(songs.length);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		//comboText.text = combo + '\n';

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = Controls.getBind("Menu_Accept", "JUST_PRESSED");

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(false);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(true);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(false);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(true);
		if (FlxG.keys.justPressed.TAB)
			changeCat(true);

		if (Controls.getBind("Menu_Back", "JUST_PRESSED"))
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted){
			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[curSelected].songName, " ", "_");
			trace("Selected Song: " + songs[curSelected].songName);

			var poop:String = Highscore.formatSong(songFormat, songs[curSelected].curDiff, songs[curSelected].curCategory);

			trace("Song Format: " + poop);
			
			PlayState.SongListData.addSong(Song.loadFromJson(poop, songFormat));
			PlayState.SongListData.toPlayState();
		}
	}

	function changeDiff(next:Bool = true) {
		//[["Normal", ["Hard", "Trauma"]], ["Original", ["Old", "Hard", "Trauma"]]]

		var diffs = [];
		for(cat in songs[curSelected].category){
			if(cat[0] == songs[curSelected].curCategory){
				diffs = cat[1];
			}
		}

		var curDiff = 0;
		var hasDiff = false;
		for(i in 0...diffs.length){
			if(diffs[i] == songs[curSelected].curDiff){
				hasDiff = true;
				curDiff = i;
			}
		}

		if(hasDiff){
			if(next){
				if(curDiff + 1 >= diffs.length){
					songs[curSelected].curDiff = diffs[0];
				}else{
					songs[curSelected].curDiff = diffs[curDiff + 1];
				}				
			}else{
				if(curDiff - 1 < 0){
					songs[curSelected].curDiff = diffs[diffs.length - 1];
				}else{
					songs[curSelected].curDiff = diffs[curDiff - 1];
				}
			}
		}else{
			songs[curSelected].curDiff = diffs[0];
		}

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "_");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, songs[curSelected].curDiff, songs[curSelected].curCategory);
		#end
	}

	function changeCat(next:Bool = true){
		//[["Normal", ["Hard", "Trauma"]], ["Original", ["Old", "Hard", "Trauma"]]]
		var cats = [];
		for(cat in songs[curSelected].category){
			cats.push(cat[0]);
		}

		var hasCat = false;
		var curCat = 0;
		for(i in 0...cats.length){
			if(cats[i] == songs[curSelected].curCategory){
				hasCat = true;
				curCat = i;
			}
		}

		if(hasCat){
			if(next){
				if(curCat + 1 >= cats.length){
					songs[curSelected].curCategory = cats[0];
				}else{
					songs[curSelected].curCategory = cats[curCat + 1];
				}
			}else{
				if(curCat - 1 < 0){
					songs[curSelected].curCategory = cats[cats.length];
				}else{
					songs[curSelected].curCategory = cats[curCat - 1];
				}
			}
		}else{
			songs[curSelected].curCategory = cats[0];
		}

		changeDiff();

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "_");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
			
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, songs[curSelected].curDiff, songs[curSelected].curCategory);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "_");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		changeDiff();

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, songs[curSelected].curDiff, songs[curSelected].curCategory);
		#end

		#if PRELOAD_ALL
		//FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		bg.loadGraphic(Paths.image('freeplay/' + songHighscore));
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var category:Array<Dynamic> = [];
	public var curCategory:String = "Normal";
	public var curDiff:String = "Hard";

	public function new(song:String, cats:Array<Dynamic>)
	{
		this.songName = song;
		this.category = cats;
	}
}
