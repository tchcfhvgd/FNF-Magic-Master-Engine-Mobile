package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class OptionsSubState extends MusicBeatSubstate {
	var tabsArray:Array<String> = ["General", "Visual", "Graphics", "Other", "Cheats", "Debug"];


	var camHUD:FlxCamera;

	//var TABOPTIONS:SpriteUIMENU;

	public function new(){
		super();

		FlxG.mouse.visible = true;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;

		FlxG.cameras.add(camHUD);
		
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


		//TABOPTIONS = new SpriteUIMENU(border2.x, border2.y, 0, 0);
		//TABOPTIONS.cameras = [camHUD];
		//TABOPTIONS.TABS.cameras = [camHUD];
		//add(TABOPTIONS);
		//TABOPTIONS.curTAB = "General";

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

	function changeTab(next:Bool = true){
		var curSelected = "HA";
		var curTab = 0;
		for(i in 0...tabsArray.length){
			if(tabsArray[i] == curSelected){curTab = i;}
		}

		if(next){curTab++;}else{curTab--;}
		if(curTab < 0){curTab = tabsArray.length - 1;}
		if(curTab >= tabsArray.length){curTab = 0;}

		//TABOPTIONS.curTAB = tabsArray[curTab];
	}

	//function addUITAB(TAB:String){
	//	var newTAB = new SpriteUIMENU_TAB(TAB);
	//	newTAB.tabName = TAB;
//
	//	//["General", "Visual", "Graphics", "Other", "Cheats"]
	//	switch(TAB){
	//		case "General":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "General Settings", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtLanguage = new FlxText(5, 40, 0, "Language: < English >", 40);
	//			txtLanguage.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtLanguage.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtLanguage);
//
	//			var rndLine1 = new FlxSprite(0, txtLanguage.y + 70).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine1);
//
	//			var txtGhostTapping = new FlxText(5, rndLine1.y, 0, "GhostTapping: True", 40);
	//			txtGhostTapping.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtGhostTapping.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtGhostTapping);
//
	//			var txtNoteOffset = new FlxText(5, txtGhostTapping.y + txtGhostTapping.height, 0, "Note Offset: [0]", 40);
	//			txtNoteOffset.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtNoteOffset.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtNoteOffset);
//
	//			var rndLine2 = new FlxSprite(0, txtNoteOffset.y + 70).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine2);
//
	//			var txtScrollType = new FlxText(5, rndLine2.y, 0, "ScrollType: < Scale >", 40);
	//			txtScrollType.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtScrollType.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtScrollType);
//
	//			var txtScrollSpeed = new FlxText(5, txtScrollType.y + txtScrollType.height, 0, "Scroll Speed: [1]", 40);
	//			txtScrollSpeed.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtScrollSpeed.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtScrollSpeed);
	//		}
	//		case "Visual":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "Visual Settings", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtHUDType = new FlxText(5, 40, 0, "HUD Style: < Magic >", 40);
	//			txtHUDType.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtHUDType.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtHUDType);
//
	//			var txtNoteStyle = new FlxText(5, txtHUDType.y + txtHUDType.height, 0, "Note Style: < Arrows >", 40);
	//			txtNoteStyle.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtNoteStyle.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtNoteStyle);
//
	//			var rndLine1 = new FlxSprite(0, txtNoteStyle.y + 70).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine1);
//
	//			var txtScrollType = new FlxText(5, rndLine1.y, 0, "Scroll Type: < UpScroll >", 40);
	//			txtScrollType.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtScrollType.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtScrollType);
//
	//			var txtMiddleScroll = new FlxText(5, txtScrollType.y + txtScrollType.height, 0, "Force MiddleScroll: False", 40);
	//			txtMiddleScroll.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtMiddleScroll.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtMiddleScroll);
//
	//			var rndLine2 = new FlxSprite(0, txtMiddleScroll.y + 70).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine2);
//
	//			var txtTypeCamera = new FlxText(5, rndLine2.y, 0, "Type Camera: < MoveToSing >", 40);
	//			txtTypeCamera.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtTypeCamera.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtTypeCamera);
//
	//			var txtTypeLightStrums = new FlxText(5, txtTypeCamera.y + txtTypeCamera.height, 0, "Strum Light: All", 40);
	//			txtTypeLightStrums.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtTypeLightStrums.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtTypeLightStrums);
//
	//		}
	//		case "Graphics":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "Graphics Settings", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtTypeGraphic = new FlxText(5, 38, 0, "Graphics: [Custom] [Low] [Medium] [High]", 40);
	//			txtTypeGraphic.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtTypeGraphic.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtTypeGraphic);
//
	//			var rndLine1 = new FlxSprite(0, txtTypeGraphic.y + 60).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine1);
//
	//			var txtFramerate = new FlxText(5, rndLine1.y - 2, 0, "FrameRate: [60]", 40);
	//			txtFramerate.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtFramerate.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtFramerate);
//
	//			var txtAntialiasing = new FlxText(5, txtFramerate.y + txtFramerate.height, 0, "Antialiasing: True", 40);
	//			txtAntialiasing.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAntialiasing.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAntialiasing);
//
	//			var rndLine2 = new FlxSprite(0, txtAntialiasing.y + 65).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine2);
//
	//			var txtBackgroundAnimated = new FlxText(5, rndLine2.y - 2, 0, "Animated Background: True", 40);
	//			txtBackgroundAnimated.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtBackgroundAnimated.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtBackgroundAnimated);
//
	//			var txtAmbientEffects = new FlxText(5, txtBackgroundAnimated.y + txtBackgroundAnimated.height, 0, "HUD Effects: True", 40);
	//			txtAmbientEffects.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAmbientEffects.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAmbientEffects);
//
	//			var rndLine3 = new FlxSprite(0, txtAmbientEffects.y + 62).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine3);
//
	//			var txtSplashOnSick = new FlxText(5, rndLine3.y - 2, 0, "Splash on Sicks: True", 40);
	//			txtSplashOnSick.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtSplashOnSick.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtSplashOnSick);
//
	//			var rndLine4 = new FlxSprite(0, txtSplashOnSick.y + 65).makeGraphic(FlxG.width - 250, 2, FlxColor.BLACK);
	//			newTAB.add(rndLine4);
//
	//			var txtOnlyNotes = new FlxText(5, rndLine4.y - 2, 0, "Only Notes: False", 40);
	//			txtOnlyNotes.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtOnlyNotes.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtOnlyNotes);
//
	//		}
	//		case "Other":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "Other Settings", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtAlFlash = new FlxText(5, 40, 0, "Allow Flashing Lights: True", 40);
	//			txtAlFlash.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlFlash.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAlFlash);
//
	//			var txtAlViolence = new FlxText(5, txtAlFlash.y + txtAlFlash.height, 0, "Allow Violence: True", 40);
	//			txtAlViolence.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlViolence.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAlViolence);
//
	//			var txtAlGore = new FlxText(5, txtAlViolence.y + txtAlViolence.height, 0, "Allow Gore: True", 40);
	//			txtAlGore.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlGore.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAlGore);
//
	//			var txtAlNSFW = new FlxText(5, txtAlGore.y + txtAlGore.height, 0, "Allow Not Safe For Work: True", 40);
	//			txtAlNSFW.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlNSFW.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAlNSFW);
//
	//			var txtAlLUA = new FlxText(5, txtAlNSFW.y + txtAlNSFW.height, 0, "Allow LUA: True", 40);
	//			txtAlLUA.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlLUA.font = Paths.font("Countryhouse.ttf");
	//			//newTAB.add(txtAlLUA);
//
	//		}
	//		case "Cheats":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "Cheats", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtBotPlay = new FlxText(5, 40, 0, "Botplay: True", 40);
	//			txtBotPlay.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtBotPlay.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtBotPlay);
//
	//			var txtPracticeMode = new FlxText(5, txtBotPlay.y + txtBotPlay.height, 0, "Practice Mode: True", 40);
	//			txtPracticeMode.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtPracticeMode.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtPracticeMode);
//
	//			var txtDamageMult = new FlxText(5, txtPracticeMode.y + txtPracticeMode.height, 0, "Damage Multiplier: [1]", 40);
	//			txtDamageMult.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtDamageMult.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtDamageMult);
//
	//			var txtAlHealingMult = new FlxText(5, txtDamageMult.y + txtDamageMult.height, 0, "HealingEn Multiplier: [1]", 40);
	//			txtAlHealingMult.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtAlHealingMult.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtAlHealingMult);
//
	//			var txtTypeNotes = new FlxText(5, txtAlHealingMult.y + txtAlHealingMult.height, 0, "Type Notes: < All >", 40);
	//			txtTypeNotes.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtTypeNotes.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtTypeNotes);
//
	//		}
	//		case "Debug":{
	//			var title = new FlxText(0, 0, FlxG.width - 210, "Debug Menus", 25);
	//			title.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			title.font = Paths.font("Countryhouse.ttf");
	//			title.alignment = CENTER;
	//			newTAB.add(title);
//
	//			var txtChartingState = new TextButtom(5, 40, 0, "Chart Editor", 40, false, "GoTo-ChartEditor");
	//			txtChartingState.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtChartingState.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtChartingState);
//
	//			var txtCharEditor = new TextButtom(5, txtChartingState.y + txtChartingState.height, 0, "Character Editor", 40, false, "GoTo-CharacterEditor");
	//			txtCharEditor.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtCharEditor.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtCharEditor);
//
	//			var txtStageEditor = new TextButtom(5, txtCharEditor.y + txtCharEditor.height, 0, "Stage Editor", 40, false, "GoTo-StageEditor");
	//			txtStageEditor.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtStageEditor.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtStageEditor);
//
	//			var txtStrumEditor = new TextButtom(5, txtStageEditor.y + txtStageEditor.height, 0, "Strumline Editor", 40, false, "GoTo-StrumLineEditor");
	//			txtStrumEditor.antialiasing =  PreSettings.getPreSetting("Antialiasing");
	//			txtStrumEditor.font = Paths.font("Countryhouse.ttf");
	//			newTAB.add(txtStrumEditor);
//
	//		}
	//	}
//
	//	TABOPTIONS.add(newTAB);
	//}
}