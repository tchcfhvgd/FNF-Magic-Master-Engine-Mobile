package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.geom.Rectangle;

import flixel.addons.ui.*;

class OptionsSubState extends MusicBeatSubstate {	
	//Cameras
	var camHUD:FlxCamera;

	public function new(isPause:Bool = false){
		super();

		FlxG.mouse.visible = true;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;

		FlxG.cameras.add(camHUD);
		
		var ttlOptions:FlxSprite = new FlxSprite();

		FlxTween.tween(camHUD, {alpha: 1}, 0.5);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){
			FlxTween.tween(camHUD, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween){
				camHUD.alpha = 0;
				close();
			}});
		}

		//TextButtom.setValue("Menu_Options", TABOPTIONS.curTAB);
		//TextButtom.INPUTS.forEach(function(buttom:TextButtom){
		//	switch(buttom.type){
		//		case "Radio":{
		//			if(buttom.pressed){
		//				if(buttom.tag == "Menu_Options"){TABOPTIONS.curTAB = buttom.name;}
		//			}
		//		}
		//		case "Buttom":{
		//			if(buttom.pressed){
		//				switch(buttom.name){
		//					case "GoTo-StageEditor":{StageEditorState.editStage();}
		//					case "GoTo-ChartEditor":{ChartEditorState.editChart();}
		//				}
		//			}
		//		}
		//	}
		//});
	}
}