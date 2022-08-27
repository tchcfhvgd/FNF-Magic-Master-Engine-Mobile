package substates;

import states.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import states.PlayState.SongListData;

class PauseSubState extends MusicBeatSubstate{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(onClose:Void->Void){
		super(onClose);

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true); pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set(); bg.alpha = 0; add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.text += states.PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, states.PlayState.SONG.difficulty, 32);
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(10, (70 * i) + 30, menuItems[i], true, false);
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float){
		if(pauseMusic.volume < 0.5){pauseMusic.volume += 0.01 * elapsed;}

		super.update(elapsed);

		var upP = principal_controls.checkAction("Menu_Up", JUST_PRESSED);
		var downP = principal_controls.checkAction("Menu_Down", JUST_PRESSED);
		var accepted = principal_controls.checkAction("Menu_Accept", JUST_PRESSED);

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					toClose();
				case "Options":
					openSubState(new OptionsSubState());
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					SongListData.resetVariables();
					MusicBeatState.switchState(new states.MainMenuState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

	}

	function toClose(){close(); onClose();}
}
