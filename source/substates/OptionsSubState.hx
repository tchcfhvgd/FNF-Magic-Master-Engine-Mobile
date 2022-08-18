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
	public function new(){
		FlxG.mouse.visible = true;
		super();

		var menuTabs = [
            {name: "1Settings", label: 'Settings'},
            {name: "2Note", label: 'Note/Event'},
            {name: "3Section/Strum", label: 'Section/Strum'},
            {name: "4Song", label: 'Song'}
        ];
        var MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(Std.int(FlxG.width) - 200, Std.int(FlxG.height) - 200);
		MENU.setPosition(100, 100);
        //addMENUTABS();        
        add(MENU);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){close();}
	}

	public function doClose(){
		//FlxTween.tween(camSubStates, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween){camSubStates.alpha = 1; close();}});
	}
}