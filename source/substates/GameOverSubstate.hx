package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import states.MusicBeatState;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;

using SavedFiles;

class GameOverSubstate extends MusicBeatSubstate {
    public var characters_created:Bool = false;

    public var cur_style_ui:String;

    public var death_characters:FlxTypedGroup<Character>;
    public var camFollow:FlxObject;
    
	public function new(characters:Array<Character>, style_ui:String){
		cur_style_ui = style_ui;
        super();
        curCamera.bgColor.alpha = 0;

        var blackGround = new FlxSprite().makeGraphic(FlxG.width * 10, FlxG.height * 10, FlxColor.BLACK);
		blackGround.scrollFactor.set();
        blackGround.screenCenter();
        blackGround.alpha = 0;
        add(blackGround);

        death_characters = new FlxTypedGroup<Character>();
        add(death_characters);

		for(i in 0...characters.length){
			var die_char:String = characters[i].dieCharacter;
            if(die_char == null && i > 0){continue;}

            var new_character = new Character(characters[i].x, characters[i].y, die_char, characters[i].curAspect, characters[i].curType, true);
            new_character.noDance = true;
            new_character.turnLook(characters[i].onRight);
            new_character.playAnim('firstDeath', true);
            death_characters.add(new_character);
		}
        characters_created = true;

		FlxG.sound.play(Paths.sound('fnf_loss_sfx').getSound());
		FlxTween.tween(blackGround, {alpha: 1}, 2, {ease: FlxEase.linear});

		conductor.changeBPM(100);

		camFollow = new FlxObject(characters[0].c.x + (characters[0].c.width / 2), characters[0].c.y + (characters[0].c.height / 2), 1, 1); add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

        if(characters_created && !canControlle){
            if(death_characters.members.length > 0 && death_characters.members[0].c.animation.curAnim != null){
                if(death_characters.members[0].c.animation.curAnim.finished){
                    FlxG.sound.playMusic(Paths.styleMusic('gameOver', cur_style_ui).getSound());
                    for(char in death_characters){char.playAnim('deathLoop', true);}
                    MusicBeatState.state.persistentDraw = false;
                    characters_created = false;
                    canControlle = true;
                }
            }else{
                FlxG.sound.playMusic(Paths.styleMusic('gameOver', cur_style_ui).getSound());
                MusicBeatState.state.persistentDraw = false;
                characters_created = false;
                canControlle = true;
            }
        }

        if(canControlle){
            if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){retrySong();}
            if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){exitSong();}
        }

		if(FlxG.sound.music.playing){conductor.songPosition = FlxG.sound.music.time;}
	}
    
	override function beatHit(){
		super.beatHit();

        if(canControlle){
            for(char in death_characters){char.playAnim('deathLoop', true);}
        }
	}

    function exitSong():Void {
        canControlle = false;
        FlxG.sound.music.stop();

        if(states.PlayState.isStoryMode){states.MusicBeatState.switchState("states.MainMenuState", []);}
        else{states.MusicBeatState.switchState("states.FreeplayState", [null, "states.MainMenuState"]);}
    }

    function retrySong():Void {
        canControlle = false;

        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.styleMusic('gameOverEnd', cur_style_ui).getSound());

        for(char in death_characters){char.playAnim('deathConfirm', true);}

        new FlxTimer().start(0.7, function(tmr:FlxTimer){FlxG.camera.fade(FlxColor.BLACK, 2, false, function(){states.MusicBeatState.loadState("states.PlayState", [], [[{type:"SONG", instance:states.PlayState.SONG}], false]);});});
    }

}