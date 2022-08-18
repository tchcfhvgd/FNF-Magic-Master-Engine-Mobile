package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;

class GameOverSubstate extends MusicBeatSubstate {
    public var chars:FlxTypedGroup<Character>;
    
	public function new(characters:Array<Character>){
		super();

        var blackGround = new FlxSprite().makeGraphic(FlxG.width * 10, FlxG.height * 10, FlxColor.BLACK);
		blackGround.scrollFactor.set();
        blackGround.screenCenter();
        blackGround.alpha = 0;
        add(blackGround);

        chars = new FlxTypedGroup<Character>();
        add(chars);

		for(i in 0...characters.length){
			var nameChar:String = characters[i].dieCharacter;
			if(nameChar == null){nameChar = characters[i].curCharacter;}
			if(nameChar != null){
				var nChar = new Character(characters[i].x, characters[i].y, nameChar, 'Death', characters[i].curType);
				nChar.turnLook(characters[i].onRight);
				nChar.playAnim('firstDeath');
				chars.add(nChar);
			}
		}

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		FlxTween.tween(blackGround, {alpha: 1}, 2, {ease: FlxEase.linear, onComplete: function(twn:FlxTween){FlxG.sound.playMusic(Paths.music('gameOver'));}});

		conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		//FlxG.camera.scroll.set();
		//FlxG.camera.target = null;

        //FlxG.camera.follow(camFollow, LOCKON, 0.01);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

        if(canControlle){
            if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){retrySong();}
            if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){exitSong();}
        }

		if(FlxG.sound.music.playing){conductor.songPosition = FlxG.sound.music.time;}
	}

    function exitSong():Void {
        canControlle = false;
        FlxG.sound.music.stop();

        if(states.PlayState.isStoryMode){states.MusicBeatState.switchState(new states.MainMenuState());}
        else{states.MusicBeatState.switchState(new states.FreeplayState(null, states.MainMenuState));}
    }

    function retrySong():Void {
        canControlle = false;

        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.music('gameOverEnd'));

        for(char in chars){char.playAnim('deathConfirm', true);}

        new FlxTimer().start(0.7, function(tmr:FlxTimer){FlxG.camera.fade(FlxColor.BLACK, 2, false, function(){states.MusicBeatState.switchState(new states.PlayState());});});
    }

}