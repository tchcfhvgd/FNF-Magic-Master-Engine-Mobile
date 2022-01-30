package;

import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class StoryMenuState extends MusicBeatSubstate
{
	var scoreText:FlxText;

	var bg:FlxSprite;

	public static var weekData:Array<Dynamic> = [
		[
			[
				["Normal", ["Hard", "Trauma"]],
				["Original", ["Old", "Hard", "Trauma"]]
			],
			['Flippy Roll', 'Happy Tree Land', 'Massacre', 'Flippin Out', 'UnFlipped Out']
		]
	];
	//Get Cat = weekData[0][0][0][0];
	//Get Diff = weekData[0][0][0][1][0];
	
	var curDifficulty:String = "Hard";
	var curCategory:String = "Normal";

	public static var weekUnlocked:Array<Bool> = [true];

	var curWeek:Int = 0;
	var canUse:Bool = false;

	var txtTracklist:FlxText;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var sprMusic:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var paperTrack:FlxSprite;

	var text:FlxText;
    var blackBorder:FlxSprite;

	//Book
	var backBook:FlxSprite;
	var frontBook:FlxSprite;
	var week:FlxSprite;

	public function new()
	{
		super();

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		text = new FlxText(5, FlxG.height, 0, "Press TAB to change category (Remix / Original)", 20);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        blackBorder = new FlxSprite(-30,FlxG.height).makeGraphic((Std.int(text.width + 900)),Std.int(text.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;
		blackBorder.scrollFactor.set();

		add(blackBorder);
        add(text);
		
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(text,{y: FlxG.height - 28},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - text.height - 5},2, {ease: FlxEase.elasticInOut});


		backBook = new FlxSprite(-1000,10).loadGraphic(Paths.image('storymenu/Back_Book'));
		backBook.antialiasing = true;
		backBook.setGraphicSize(Std.int(backBook.width * 0.75));
		backBook.updateHitbox();
		add(backBook);

		week = new FlxSprite(-1000,30);
		week.frames = Paths.getSparrowAtlas('storymenu/week'+curWeek);
		week.antialiasing = true;
		week.animation.addByPrefix('apear', 'Week '+curWeek+' Apear', 24, false);
		week.animation.addByPrefix('idle', 'Week '+curWeek+' Idle', 24, true);
		week.setGraphicSize(Std.int(week.width * 0.75));
		week.updateHitbox();
		add(week);

		frontBook = new FlxSprite(-1201,-430);
		frontBook.frames = Paths.getSparrowAtlas('storymenu/Front_Book');
		frontBook.antialiasing = true;
		frontBook.animation.addByPrefix('open', 'Book Front', 24, false);
		frontBook.setGraphicSize(Std.int(frontBook.width * 0.75));
		frontBook.updateHitbox();
		add(frontBook);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(35, 505);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "Left_Arrow");
		leftArrow.animation.addByPrefix('press', "Press Left_Arrow");
		leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.75));
		leftArrow.antialiasing = true;
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprMusic = new FlxSprite(330, -10);
		sprMusic.frames = ui_tex;
		sprMusic.animation.addByPrefix('original', 'Original');
		sprMusic.animation.addByPrefix('remix', 'Remix');
		sprMusic.setGraphicSize(Std.int(sprMusic.width * 0.65));
		sprMusic.antialiasing = true;
		sprMusic.angle = 10;
		sprMusic.animation.play('remix');
		add(sprMusic);

		sprDifficulty = new FlxSprite(leftArrow.x + 60, leftArrow.y - 33);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('old', 'Old');
		sprDifficulty.animation.addByPrefix('hard', 'Hard');
		sprDifficulty.animation.addByPrefix('trauma', 'Trauma');
		sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.75));
		sprDifficulty.antialiasing = true;
		sprDifficulty.animation.play('hard');
		//changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width - 57, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'Right_Arrow');
		rightArrow.animation.addByPrefix('press', "Press Right_Arrow", 24, false);
		rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.75));
		rightArrow.antialiasing = true;
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		FlxTween.tween(backBook, {x: 0}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(week, {x: -30}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(frontBook, {x: -201}, 1, {
			ease: FlxEase.quartInOut,
			onComplete: function(twn:FlxTween)
			{
				frontBook.animation.play('open');
				week.animation.play('apear');
				new FlxTimer().start(1.7, function(tmr:FlxTimer){	
					week.animation.play('idle');
					week.x += 30;
					week.y -= 10;
					canUse = true;
				});
			}
		});
	}

	override function update(elapsed:Float){

		super.update(elapsed);
		
		if(!canUse){
			difficultySelectors.visible = false;
			sprMusic.visible = false;
		}else{
			difficultySelectors.visible = true;
			sprMusic.visible = true;

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					//if (gamepad.justPressed.DPAD_UP)
					//{
					//	changeWeek(-1);
					//}
					//if (gamepad.justPressed.DPAD_DOWN)
					//{
					//	changeWeek(1);
					//}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				//if (FlxG.keys.justPressed.UP)
				//{
				//	changeWeek(-1);
				//}

				//if (FlxG.keys.justPressed.DOWN)
				//{
				//	changeWeek(1);
				//}

				if (Controls.getBind("Menu_Right", "PRESSED"))
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (Controls.getBind("Menu_Left", "PRESSED"))
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (Controls.getBind("Menu_Right", "JUST_PRESSED"))
					changeDifficulty(1);
				if (Controls.getBind("Menu_Left", "JUST_PRESSED"))
					changeDifficulty(-1);
				if (FlxG.keys.justPressed.TAB)
					changeCat(1);
				if (Controls.getBind("Menu_Back", "JUST_PRESSED"))
					closingMenu();
		}
		if (Controls.getBind("Menu_Accept", "JUST_PRESSED"))
			{
				selectWeek();
			}
	}
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				stopspamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));				
			}

			for(i in 0...weekData[curWeek][1].lenght){
				var songFormat = StringTools.replace(weekData[curWeek][1][i], " ", "_");
				var poop:String = Highscore.formatSong(songFormat, curDifficulty, curCategory);
				var song:SwagSong = Song.loadFromJson(poop, weekData[curWeek][1][i]);

				PlayState.SongListData.addSong(song);
			}
			PlayState.SongListData.resetVariables();
			new FlxTimer().start(1, function(tmr:FlxTimer){
				PlayState.SongListData.toPlayState(true);
			});		
		}
	}

	function changeCat(change:Int = 0):Void{
		var cats:Array<String> = [];
		for(i in 0...weekData[curWeek][0].length){
			cats.push(weekData[curWeek][0][i][0]);
		}

		trace("Cats List: " + cats);

		var hasCat = false;
		var curCat = 0;
		for(i in 0...cats.length){
			if(curCategory == cats[i]){
				hasCat = true;
				curCat = i;
			}
		}

		if(hasCat){
			var ch = curCat += change;
			if(ch >= cats.length){ch = 0;}
			if(ch < 0){ch = cats.length - 1;}
			curCategory = cats[ch];
		}else{
			curCategory = cats[0];
		}

		changeDifficulty();
		trace("Current Category: " + curCategory);

		sprMusic.offset.x = 0;
		switch (curCategory){
			case 'Original':
				sprMusic.animation.play('original');
				sprMusic.offset.x = 10;
				sprMusic.offset.y = -20;	
			case 'Normal':
				sprMusic.animation.play('remix');
				sprMusic.offset.x = 0;
				sprMusic.offset.y = 0;
		}

		sprMusic.alpha = 0;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty, curCategory);
		#end

		FlxTween.tween(sprMusic, { alpha: 1}, 0.07);
	}

	function changeDifficulty(change:Int = 0):Void{
		var diffs:Array<String> = [];
		for(i in 0...weekData[curWeek][0].length){
			if(weekData[curWeek][0][i][0] == curCategory){
				diffs = weekData[curWeek][0][i][1];
			}
		}

		trace("Diff List: " + diffs);

		var curDiff = 0;
		var hasDiff = false;
		for(i in 0...diffs.length){
			if(diffs[i] == curDifficulty){
				hasDiff = true;
				curDiff = i;
			}
		}
			
		if(hasDiff){
			var ch = curDiff += change;
			if(ch >= diffs.length){ch = 0;}
			if(ch < 0){ch = diffs.length - 1;}
			curDifficulty = diffs[ch];
		}else{
			curDifficulty = diffs[0];
		}

		trace("Current Difficulty: " + curDifficulty);

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case "Old":
				sprDifficulty.animation.play('old');
				sprDifficulty.offset.x = -45;
				sprDifficulty.offset.y = 15;	
			case "Hard":
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 0;
				sprDifficulty.offset.y = 0;
			case "Trauma":
				sprDifficulty.animation.play('trauma');
				sprDifficulty.offset.x = 15;
				sprDifficulty.offset.y = -10;	
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		//sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty, curCategory);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty, curCategory);
		#end

		FlxTween.tween(sprDifficulty, { alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{

		txtTracklist.text = "\nTracks:\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x += FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty, curCategory);
		#end
	}

	function closingMenu():Void {
		canUse = false;
		week.x -= 30;
		week.y += 10;
		frontBook.animation.play('open', false, true);
		week.animation.play('apear', false, true);
		new FlxTimer().start(1.7, function(tmr:FlxTimer){
			FlxTween.tween(backBook, {x: -1000}, 1, {ease: FlxEase.quartInOut});
			FlxTween.tween(week, {x: -1000}, 1, {ease: FlxEase.quartInOut});
			FlxTween.tween(frontBook, {x: -1201}, 1, {
				ease: FlxEase.quartInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(text,{y: FlxG.height},1.5,{ease: FlxEase.elasticInOut});
					FlxTween.tween(blackBorder,{y: FlxG.height},1.5, {ease: FlxEase.elasticInOut});
					new FlxTimer().start(2, function(tmr:FlxTimer){close();});
				}
			});
		});
	}
}