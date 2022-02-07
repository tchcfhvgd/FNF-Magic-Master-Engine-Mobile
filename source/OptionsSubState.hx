package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import SpriteInput;
import SpriteInput.TextButtom;
import Sprite_UI_MENU.Sprite_UI_MENU_TAB;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class OptionsSubState extends MusicBeatSubstate {
	var tabsArray:Array<String> = ["General", "Visual", "Graphics", "Other", "Cheats"];

	var grpTabTexts:FlxTypedGroup<TextButtom>;

	var camHUD:FlxCamera;

	var TABOPTIONS:Sprite_UI_MENU;

	var grpOptions:FlxTypedGroup<Dynamic>;
	var options:Array<Dynamic> = [
		[
			[0, "Language", 62],
        	["GhostTapping", true],
        	["NoteOffset", 0],
        	["ScrollSpeedType", [1, ["Scale", "Force", "Disabled"]]],
        	["ScrollSpeed", 0.5]
		],
		[],
		[],
		[],
		[]
	];

	public function new(){
		super();

		FlxG.mouse.visible = true;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;

		FlxG.cameras.add(camHUD);

		SpriteInput.INPUTS = new FlxTypedGroup<SpriteInput>();
		TextButtom.INPUTS = new FlxTypedGroup<TextButtom>();
		
		var backBlack = new FlxSprite(50 , 50).makeGraphic(FlxG.width - 100, FlxG.height - 100, FlxColor.BLACK);
		backBlack.cameras = [camHUD];
		backBlack.alpha = 0.5;
		add(backBlack);

		var title:FlxText = new FlxText(60, 40, 0, "Options", 60);
		title.antialiasing = PreSettings.getPreSetting("Antialiasing");
		title.font = Paths.font("Countryhouse.ttf");
		title.color = FlxColor.WHITE;
		title.cameras = [camHUD];
		title.bold = true;
		add(title);

		var border1:FlxSprite = new FlxSprite(50, 110).makeGraphic(FlxG.width - 100, 2, FlxColor.BLACK);
		border1.cameras = [camHUD];
		add(border1);

		var border2:FlxSprite = new FlxSprite(200, 110).makeGraphic(2, FlxG.height - 160, FlxColor.BLACK);
		border2.cameras = [camHUD];
		add(border2);

		grpTabTexts = new FlxTypedGroup<TextButtom>();
		add(grpTabTexts);


		TABOPTIONS = new Sprite_UI_MENU(border2.x, border2.y, 0, 0);
		TABOPTIONS.cameras = [camHUD];
		TABOPTIONS.TABS.cameras = [camHUD];
		add(TABOPTIONS);
		add(TABOPTIONS.TABS);

		for(i in 0...tabsArray.length){
			var option:TextButtom = new TextButtom(50, 120 + (45 * i), 150, tabsArray[i], 32, false, tabsArray[i], "Radio", "Menu_Options");
			option.setFormat(Paths.font("Countryhouse.ttf"), 32, FlxColor.WHITE, CENTER);
			option.antialiasing = PreSettings.getPreSetting("Antialiasing");
			option.cameras = [camHUD];
			addUITAB(tabsArray[i]);
			option.ID = i;
			if(tabsArray[i] == "Cheats"){option.y += 40;}
			grpTabTexts.add(option);
		}
		TABOPTIONS.curTAB = "General";

		var line1 = new FlxSprite(border2.x, border1.y + 40).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
		line1.cameras = [camHUD];
		add(line1);

		FlxTween.tween(camHUD, {alpha: 1}, 0.5);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(Controls.getBind("Menu_Tab", "JUST_PRESSED")){changeTab();}
			if(Controls.getBind("Menu_Tab", "PRESSED")){
				if(Controls.getBind("Menu_Up", "JUST_PRESSED")){changeTab(false);}
				if(Controls.getBind("Menu_Down", "JUST_PRESSED")){changeTab();}
			}

		if(Controls.getBind("Menu_Back", "JUST_PRESSED")){
			FlxTween.tween(camHUD, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween){
				camHUD.alpha = 0;
				close();
			}});
		}

		TextButtom.setValue("Menu_Options", TABOPTIONS.curTAB);
		TextButtom.INPUTS.forEach(function(buttom:TextButtom){
			switch(buttom.type){
				case "Radio":{
					if(buttom.pressed){
						if(buttom.tag == "Menu_Options"){TABOPTIONS.curTAB = buttom.name;}
					}
				}
			}
		});
	}

	function changeTab(next:Bool = true){
		var curSelected = TABOPTIONS.curTAB;
		var curTab = 0;
		for(i in 0...tabsArray.length){
			if(tabsArray[i] == curSelected){curTab = i;}
		}

		if(next){curTab++;}else{curTab--;}
		if(curTab < 0){curTab = tabsArray.length - 1;}
		if(curTab >= tabsArray.length){curTab = 0;}

		TABOPTIONS.curTAB = tabsArray[curTab];
	}

	function addUITAB(TAB:String){
		var newTAB = new Sprite_UI_MENU_TAB(TAB);
		newTAB.tabName = TAB;

		//["General", "Visual", "Graphics", "Other", "Cheats"]
		switch(TAB){
			case "General":{
				var title = new FlxText(0, 0, FlxG.width - 210, "General Settings", 25);
				title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				title.font = Paths.font("Countryhouse.ttf");
				title.alignment = CENTER;
				newTAB.add(title);

				var txtLanguage = new FlxText(5, 40, 0, "Language: ", 40);
				txtLanguage.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				txtLanguage.font = Paths.font("Countryhouse.ttf");
				newTAB.add(txtLanguage);
			}
			case "Visual":{
				var title = new FlxText(0, 0, FlxG.width - 210, "Visual Settings", 25);
				title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				title.font = Paths.font("Countryhouse.ttf");
				title.alignment = CENTER;
				newTAB.add(title);

			}
			case "Graphics":{
				var title = new FlxText(0, 0, FlxG.width - 210, "Graphics Settings", 25);
				title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				title.font = Paths.font("Countryhouse.ttf");
				title.alignment = CENTER;
				newTAB.add(title);

			}
			case "Other":{
				var title = new FlxText(0, 0, FlxG.width - 210, "Other Settings", 25);
				title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				title.font = Paths.font("Countryhouse.ttf");
				title.alignment = CENTER;
				newTAB.add(title);

			}
			case "Cheats":{
				var title = new FlxText(0, 0, FlxG.width - 210, "Cheats", 25);
				title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
				title.font = Paths.font("Countryhouse.ttf");
				title.alignment = CENTER;
				newTAB.add(title);

			}
		}

		TABOPTIONS.add(newTAB);
	}
}