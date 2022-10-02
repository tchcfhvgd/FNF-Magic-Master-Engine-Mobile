package states.editors;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import lime.app.Application;
import openfl.Assets;
import Character;

using StringTools;

class StageBuilder extends MusicBeatState
{
    var stage:Stage;

    public static var defaultCamZoom:Float = 0.80;

    var camText:FlxText;
	var offText:FlxText;

	var posText:FlxText;
	var camFollow:FlxObject;

    /////////////////////////////////////////////////// 
	public static var daStage:String = '';
	public static var char:Array<Dynamic> = [];
	/////////////////////////////////////////////////// 

	var charCam:Int = 0;

	/////////////////////////////////////////////////// 

	var mousePos:FlxPoint;
    
	override public function create():Void
	{
		super.create();
        
		#if DISCORD_RPC
		Discord.changePresence('STAGE BUILDER', 'Sugar Take');
		#end

		stage = new Stage(daStage, char);
		defaultCamZoom = stage.zoom;

		FlxG.camera.zoom = defaultCamZoom;

        add(stage);

        camText = new FlxText(0, 30, FlxG.width, '', 17);
		camText.setFormat(Paths.font('pixel.otf'), 17, FlxColor.WHITE, LEFT);
        camText.scrollFactor.set();
        add(camText);

		offText = new FlxText(0, 110, FlxG.width, '', 17);
		offText.setFormat(Paths.font('pixel.otf'), 17, FlxColor.WHITE, LEFT);
        offText.scrollFactor.set();
        add(offText);

		posText = new FlxText(0, 0, FlxG.width, '+', 40);
		posText.setFormat(Paths.font('pixel.otf'), 40, FlxColor.WHITE, LEFT);
        add(posText);

        camText.cameras = [camHUD];
		offText.cameras = [camHUD];
		
		camFollow = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON);
		add(camFollow);
		camFollow.maxVelocity.x = 1000;
		camFollow.maxVelocity.y = 1000;

		mousePos = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);

		setChar();
	}

    function updateText() {
		camText.text = 'DefaultCamZoom: ' +  FlxMath.roundDecimal(defaultCamZoom, 2) + 
		'\n' + 'Girlfriend: ' + stage.characterData[0].x + ' , ' + stage.characterData[0].y +
		'\n' + 'Dad: ' + stage.characterData[1].x + ' , ' + stage.characterData[1].y +
		'\n' + 'Boyfriend: ' + stage.characterData[2].x + ' , ' + stage.characterData[2].y;

		offText.text = '\n' + 'Camera Offset: ' + FlxMath.roundDecimal(camFollow.x, 1) + 
		' , ' + FlxMath.roundDecimal(camFollow.y, 1);
    }

	function setChar(charId:Int = 0) {
		var _char = stage.getCharacterById(charId);
		camFollow.setPosition(_char.getGraphicMidpoint().x, _char.getGraphicMidpoint().y);
		posText.setPosition(_char.x + 230, _char.y - 100);
		mousePos.set(_char.getGraphicMidpoint().x, _char.getGraphicMidpoint().y);	
	}

	override function update(elapsed:Float)
	{
        if(FlxG.mouse.wheel != 0){
            if (FlxG.keys.pressed.SHIFT) defaultCamZoom += (FlxG.mouse.wheel / 100);
			else defaultCamZoom += (FlxG.mouse.wheel / 10);
			FlxG.camera.zoom = defaultCamZoom;
        }

		updateText();

        if(FlxG.keys.justPressed.R) FlxG.resetState();
		if(principal_controls.checkAction('Menu_Back', JUST_PRESSED)) {
			MusicBeatState.switchState(new PlayState());
		}

		if(FlxG.keys.pressed.W){
			camFollow.velocity.y -= 300;
		}
		else if(FlxG.keys.pressed.S){
			camFollow.velocity.y += 300;
		}
		else camFollow.velocity.y = 0;

		if(FlxG.keys.pressed.A){
			camFollow.velocity.x -= 300;
		}
		else if(FlxG.keys.pressed.D){
			camFollow.velocity.x += 300;
		}
		else camFollow.velocity.x = 0;

		if(FlxG.mouse.justPressedRight){
			charCam ++;
			if (charCam == 3) charCam = 0;
			setChar(charCam);
		}

		if (defaultCamZoom <= 0.1) {
			defaultCamZoom = 0.1;
		}
        
		super.update(elapsed);
	}
}
