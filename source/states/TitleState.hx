package states;

import flixel.math.FlxRandom;
import flixel.FlxObject;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
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
import flixel.math.FlxMath;

using StringTools;

class TitleState extends MusicBeatState {
	private var inIntro:Bool = true;
	private var toStart:Bool = true;

	private var logo:FlxSprite;

	private var gradient:FlxSprite;
	private var otherStuff:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public function new(started:Bool = true){
		super();

		this.toStart = started;
	}

	override public function create():Void {
		LangSupport.init();
		
		otherStuff.add(new FlxSprite());

		gradient = new FlxSprite().loadGraphic(Paths.image('Gradient'));
		gradient.color = FlxColor.fromRGB(0, 255, 195);
		gradient.y = FlxG.height;
		gradient.setGraphicSize(FlxG.width);
		gradient.screenCenter(X);
		add(gradient);

		logo = new FlxSprite().loadGraphic(Paths.image('LOGO'));
		logo.y = (FlxG.height / 2) - (logo.height / 2);
		logo.cameras = [camFGame];
		logo.screenCenter(X);
		logo.visible = false;
		add(logo);

		if(toStart){new FlxTimer().start(1, function(tmr:FlxTimer){if(inIntro){startIntro();}});}

		super.create();
	}

	override function update(elapsed:Float){
		if(FlxG.sound.music != null){conductor.songPosition = FlxG.sound.music.time;}

		super.update(elapsed);

		logo.scale.set(FlxMath.lerp(logo.scale.x, 1, 0.1), FlxMath.lerp(logo.scale.y, 1, 0.1));

		if(canControlle){
			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
				if(inIntro){
					skipIntro(true);
				}else{
					FlxTween.tween(gradient, {y: FlxG.height}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(logo, {y: FlxG.height}, 1, {ease: FlxEase.quadIn, onComplete: function(twn){MusicBeatState.switchState(new MainMenuState());}});
				}
			}
	
			if(FlxG.keys.justPressed.R){FlxG.resetState();}
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

	}

	private function startIntro():Void {
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		conductor.changeBPM(122);
	}
	
	private function skipIntro(forced:Bool = false):Void {
		inIntro = false;

		if(forced){FlxG.sound.music.time = 47000;}

		var sCount:Int = 0;
		camHUD.flash(FlxColor.WHITE, conductor.crochet / 4000, null, true);
		new FlxTimer().start(conductor.crochet / 2000, function(tmr){
			camHUD.flash(FlxColor.WHITE, conductor.crochet / 4000, null, true);

			switch(sCount){
				case 3:{
					gradient.y = FlxG.height - gradient.height;
					logo.visible = true;
				}
			}

			sCount++;
		}, 4);

	}

	override function beatHit(){
		super.beatHit();

		logo.scale.set(1.2, 1.2);

		if(!toStart){toStart = true; skipIntro();}

		if(inIntro){
			switch(curBeat){
				case 44:{FlxTween.tween(gradient, {y: FlxG.height - gradient.height}, (conductor.crochet / 1000) * 6, {ease: FlxEase.quadInOut});}
				case 96:{skipIntro();}
			}
		}else{
			var sSize:Int = FlxG.random.int(20, 80);

			var square:FlxSprite = otherStuff.recycle(FlxSprite);
			square.setPosition(FlxG.random.float(0, FlxG.width) + 20, FlxG.height + 10);
			square.makeGraphic(sSize, sSize, FlxColor.fromRGB(0, 255, 195));
			FlxTween.tween(square, {x: FlxG.random.float(square.x - 10, square.x), y: FlxG.random.float(0, FlxG.height / 2), alpha: 0}, FlxG.random.float(1, 3));
			add(square);
		}
	}
}
