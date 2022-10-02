package states.editors;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
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
import lime.app.Application;
import openfl.Assets;
import Character;

using StringTools;

class StageBuilder extends MusicBeatState
{
    var stage:Stage;

    public static var curStage = 'stage';
    public static var defaultCamZoom:Float = 0.80;

    var camText:FlxText;
    var curSelected:Int = 0;
    /////////////////////////////////////////////////// 
	/*YIRIUS TE VOY A CAASTRAR COOMO QUE NO PUEDO HAGARRAR LOS PERSONAJES DE FORMA DINAMICA*/
	public static var daStage:String = '';
	public static var char:Array<Dynamic> = [];
    
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

        camText = new FlxText(0, 30, FlxG.width, '', 25);
		camText.setFormat(Paths.font('pixel.otf'), 25, FlxColor.WHITE, LEFT);
        camText.scrollFactor.set();
        add(camText);

        camText.cameras = [camHUD];
		
	}

    function updateText() {
		camText.text = 'DefaultCamZoom: ' + defaultCamZoom + 
		'\n' + 'Girlfriend: ' + stage.characterData[0].x + ' , ' + stage.characterData[0].y +
		'\n' + 'Dad: ' + stage.characterData[1].x + ' , ' + stage.characterData[1].y +
		'\n' + 'Boyfriend: ' + stage.characterData[2].x + ' , ' + stage.characterData[2].y;
    }

    /*function setStage(curStage:String = '') {
        stage.loadStage(curStage);

		defaultCamZoom = stage.zoom;
		FlxG.camera.zoom = defaultCamZoom;
    }*/

	override function update(elapsed:Float)
	{
        if(FlxG.mouse.wheel != 0){
            if (FlxG.keys.pressed.SHIFT) defaultCamZoom += (FlxG.mouse.wheel / 100);
			else defaultCamZoom += (FlxG.mouse.wheel / 10);
			FlxG.camera.zoom = defaultCamZoom;
        }

        /*if (FlxG.keys.justPressed.LEFT){
            curSelected --;
            if (curSelected <= 0) curSelected = stages.length;
            setStage(stages[curSelected]);
        }
		else if (FlxG.keys.justPressed.RIGHT)
		{
			curSelected++;
			if (curSelected > stages.length)
				curSelected = 0;
			setStage(stages[curSelected]);
		}*/
        
		updateText();

        if(FlxG.keys.justPressed.R) FlxG.resetState();
        
		super.update(elapsed);
	}
}
