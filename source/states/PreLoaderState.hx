package states;

import substates.PauseSubState;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end

import Note.NoteSplash;
import Character.Skins;

using StringTools;

class PreLoaderState extends FlxUIState {
	override public function create():Void{
		super.create();
		
		FlxG.autoPause = false;

		NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		Controls.init();
		PreSettings.init();
		
        PreSettings.loadSettings();
		
		PlayerSettings.init();

		Highscore.load();	
		LangSupport.init();
		ModSupport.init();
		Skins.init();
		
		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode){DiscordClient.shutdown();});

            #if !switch
                NGio.unlockMedal(60960);

                // If it's Friday according to da clock
                if(Date.now().getDay() == 5){NGio.unlockMedal(61034);}
			#end
		#end

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		MagicStuff.setGlobalTransition("Default", new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4)), MagicStuff.TransitionType.transIn);
		MagicStuff.setGlobalTransition("Default", new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4)), MagicStuff.TransitionType.transOut);
		MagicStuff.changeTransitionType("Default");

		MusicBeatState.switchState(new states.TitleState());
	}
}
