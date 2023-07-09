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

using SavedFiles;

class PauseSubState extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(onClose:Void->Void){
		super(onClose);
		curCamera.alpha = 0;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast').getSound(), true, true); pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.text += Paths.getFileName(states.PlayState.SONG.song);
		levelInfo.cameras = [curCamera];
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, states.PlayState.SONG.difficulty, 32);
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.cameras = [curCamera];
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(10,(70*i)+30,menuItems[i]);
			grpMenuShit.add(songText);
		}
		grpMenuShit.cameras = [curCamera];
		add(grpMenuShit);

		changeSelection();
		FlxTween.tween(curCamera, {alpha: 1}, 1, {onComplete: function(twn){canControlle = true;}});
	}

	override function update(elapsed:Float){
		if(pauseMusic.volume < 0.5){pauseMusic.volume += 0.01 * elapsed;}

		super.update(elapsed);

		if(canControlle){
			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){
				changeSelection(-1);
			}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){
				changeSelection(1);
			}
			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
				var daSelected:String = menuItems[curSelected];
	
				switch(daSelected){
					case "Resume":{doClose();}
					case "Options":{loadSubState("substates.OptionsSubState", []);}
					case "Restart Song":{MusicBeatState.loadState("states.PlayState", [], [[{type:"SONG", instance:states.PlayState.SONG}], false]);}
					case "Exit to menu":{
						SongListData.resetVariables();
						MusicBeatState.switchState("states.MainMenuState", []);
					}
				}
			}
		}

		MagicStuff.sortMembersByY(cast grpMenuShit, (FlxG.height / 2) - (grpMenuShit.members[curSelected].height / 2), curSelected);
	}

	override function destroy(){
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0, force:Bool = false):Void{
		if(force){curSelected = change;}else{curSelected += change;}

		if(curSelected < 0){curSelected = menuItems.length - 1;}
		if(curSelected >= menuItems.length){curSelected = 0;}

		for(i in 0...grpMenuShit.members.length){
			grpMenuShit.members[i].alpha = 0.5;
			if(i == curSelected){grpMenuShit.members[i].alpha = 1;}
		}
		
		FlxG.sound.play(Paths.sound("scrollMenu").getSound());
	}

	public function doClose(){
		canControlle = false;
		FlxG.sound.play(Paths.sound("cancelMenu").getSound());
		FlxTween.tween(curCamera, {alpha: 0}, 1, {onComplete: function(twn){close();}});
	}
}
