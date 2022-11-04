package substates;

import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;

import flixel.addons.ui.*;

class OptionsSubState extends MusicBeatSubstate {
	private var gpOptions:FlxTypedGroup<Alphabet>;

	private var curOption:Int = 0;

	public function new(?onClose:Void->Void){
		FlxG.mouse.visible = true;
		super(onClose);
		curCamera.alpha = 0;

		gpOptions = new FlxTypedGroup<Alphabet>();
		gpOptions.cameras = [curCamera];
		
		var optsList:Array<String> = ['Controls', 'Key Controls'];
		for(i in PreSettings.CURRENT_SETTINGS.keys()){optsList.push(i);}

		for(i in 0...optsList.length){
			var _cat:Alphabet = new Alphabet(10,0,'> ${optsList[i]}');
			gpOptions.add(_cat);

			switch(optsList[i]){
				case "Controls":{
					for(control in Controls.STATIC_ACTIONS.keys()){
						var _control_opt:ControlOption = new ControlOption(control, principal_controls, this);
						gpOptions.add(_control_opt);
					}					
				}
				case "Key Controls":{
					for(key in Controls.STATIC_STRUMCONTROLS.keys()){
						var _control_opt:ControlStrumOption = new ControlStrumOption(key, principal_controls, this);
						gpOptions.add(_control_opt);
					}
				}
				default:{
					for(setting in PreSettings.CURRENT_SETTINGS.get(optsList[i]).keys()){
						var _presetting_opt:PreSettingOption = new PreSettingOption(setting, optsList[i], principal_controls);
						gpOptions.add(_presetting_opt);
					}
				}
			}
		}

		add(gpOptions);

		changeValue();
		FlxTween.tween(curCamera, {alpha: 1}, 1, {onComplete: function(twn){canControlle = true;}});
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		MagicStuff.sortMembersByY(cast gpOptions, FlxG.height / 2, curOption);

		if(canControlle){
			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeValue(-1);}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeValue(1);}

			if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){
				Controls.saveControls();
				PreSettings.saveSettings();
				PlayerSettings.init();

				doClose();
			}
		}
	}

	public function changeValue(change:Int = 0):Void {
		curOption += change;
	
		if(curOption < 0){curOption = gpOptions.members.length - 1;}
		if(curOption >= gpOptions.members.length){curOption = 0;}

		for(c in gpOptions.members){c.ID = 0; c.alpha = 0.5;}
		gpOptions.members[curOption].alpha = 1;
		gpOptions.members[curOption].ID = 1;
	}

	public function doClose(){
		canControlle = false;
		FlxTween.tween(curCamera, {alpha: 0}, 1, {onComplete: function(twn){close();}});
	}
}

class ControlOption extends Alphabet {
	public var control:String = null;
	private var controls:Controls = null;
	public var state:MusicBeatSubstate = null;
	
	private var unChanged:Bool = false;
	private var isChanging:Bool = false;

	private var curKey:Int = 0;

	public var isGamepad:Bool = false;

	public function new(_control:String, _controls:Controls, _state:MusicBeatSubstate){
		this.controls = _controls;
		this.control = _control;
		this.state = _state;
		super(0,0,null);
		loadText();
	}

	override public function loadText():Void {
		cur_data = [{scale:0.5, text:'\t${Paths.getFileName(control)}: [ '}];

		var i:Int = 0;
		for(key in Controls.CURRENT_ACTIONS[control][isGamepad ? 1 : 0]){
			cur_data.push({scale:0.5, bold:i == curKey, text: (i == curKey && isChanging) ? '??? ' : '${cast(key,FlxKey).toString()} '});			
			i++;
		}
		cur_data.push({scale:0.5, text:']'});	
		if(unChanged){cur_data.push({scale:0.5, text:' Unchanged Key'});}

		super.loadText();
	}

	override function update(elapsed:Float){
		if(ID == 1){
			if(!isChanging){
				if(controls.checkAction("Menu_Left", JUST_PRESSED)){changeKey(-1);}
				if(controls.checkAction("Menu_Right", JUST_PRESSED)){changeKey(1);}
				
				if(controls.checkAction("Menu_Accept", JUST_PRESSED)){
					state.canControlle = false;
					isChanging = true;
					loadText();
				}
			}else{
				if(FlxG.keys.firstJustPressed() != -1){
					Controls.CURRENT_ACTIONS[control][isGamepad ? 1 : 0][curKey] = FlxG.keys.firstJustPressed();
					isChanging = false;
					unChanged = true;
					loadText();
					state.canControlle = true;
				}
			}
		}
		
		super.update(elapsed);
	}

	function changeKey(value:Int = 0, force:Bool = false):Void {
		curKey += value; if(force){curKey = value;}

		if(curKey < 0){curKey = Controls.CURRENT_ACTIONS[control][isGamepad ? 1 : 0].length - 1;}
		if(curKey >= Controls.CURRENT_ACTIONS[control][isGamepad ? 1 : 0].length){curKey = 0;}

		loadText();
	}
}

class ControlStrumOption extends Alphabet {
	public var keys:Int = 0;
	private var controls:Controls = null;
	public var state:MusicBeatSubstate = null;
	
	private var unChanged:Bool = false;
	private var isChanging:Bool = false;

	private var curKey:Int = 0;

	public var isGamepad:Bool = false;

	public function new(_keys:Int, _controls:Controls, _state:MusicBeatSubstate){
		this.controls = _controls;
		this.state = _state;
		this.keys = _keys;
		super(0,0,null);
		loadText();
	}

	override public function loadText():Void {
		cur_data = [{scale:0.5, text:'\t${keys} keys: [ '}];

		var i:Int = 0;
		for(key in Controls.CURRENT_STRUMCONTROLS[keys]){
			cur_data.push({scale:0.5, bold:i == curKey, text: (i == curKey && isChanging) ? '??? ' : '${cast(key[isGamepad ? 1 : 0][0],FlxKey).toString()} '});			
			i++;
		}
		cur_data.push({scale:0.5, text:']'});
		if(unChanged){cur_data.push({scale:0.5, text:' Unchanged Key'});}

		super.loadText();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(ID == 1){
			if(!isChanging){
				if(controls.checkAction("Menu_Left", JUST_PRESSED)){changeKey(-1);}
				if(controls.checkAction("Menu_Right", JUST_PRESSED)){changeKey(1);}
				
				if(controls.checkAction("Menu_Accept", JUST_PRESSED)){
					state.canControlle = false;
					isChanging = true;
					loadText();
				}
			}else{
				if(FlxG.keys.firstJustPressed() != -1){
					Controls.CURRENT_STRUMCONTROLS[keys][curKey][0][0] = FlxG.keys.firstJustPressed();
					isChanging = false;
					unChanged = true;
					loadText();
					state.canControlle = true;
				}
			}
		}
	}

	function changeKey(value:Int = 0, force:Bool = false):Void {
		curKey += value; if(force){curKey = value;}

		if(curKey < 0){curKey = Controls.CURRENT_STRUMCONTROLS[keys].length - 1;}
		if(curKey >= Controls.CURRENT_STRUMCONTROLS[keys].length){curKey = 0;}

		loadText();
	}
}

class PreSettingOption extends Alphabet {
	public var setting:String = "";
	public var category:String = "";
	private var controls:Controls = null;

	public var unChanged:Bool = false;

	public function new(_setting:String, _category:String, _controls:Controls){
		this.setting = _setting;
		this.category = _category;
		this.controls = _controls;
		super(0,0,null);
		loadText();
	}

	override public function loadText():Void {
		cur_data = [{scale:0.5, text:'\t${Paths.getFileName(setting)}: '}];
		var setting_data:Dynamic = PreSettings.getPreSetting(setting, category);
		
		cur_data.push({scale:0.5, bold:true, text: '> ${setting_data} <'});

		super.loadText();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(ID == 1){
			if(controls.checkAction("Menu_Left", JUST_PRESSED)){changeSetting(-1);}
			if(controls.checkAction("Menu_Right", JUST_PRESSED)){changeSetting(1);}

			if(controls.checkAction("Menu_Accept", JUST_PRESSED)){changeSetting(1);}
		}
	}

	function changeSetting(value:Int = 0):Void {
		PreSettings.changePreSetting(setting, category, value);
		loadText();
	}
}