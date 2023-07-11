package substates;

import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;

import flixel.addons.ui.*;

class OptionsSubState extends MusicBeatSubstate {
	private var backgrad:FlxSprite;

	private var category_list:Array<{text:String, display:Dynamic}> = [];
	private var gpCategorys:FlxTypedGroup<Alphabet>;
	private var gpOptions:FlxTypedGroup<Alphabet>;

	private var onOptions:Bool = false;
	public var curCategory:Int = 0;
	public var curOption:Int = 0;
	
	public function new(?onClose:Void->Void){
		FlxG.mouse.visible = true;
		super(onClose);
		curCamera.alpha = 0;
		
		//---------------------------------------------------------------------------------------------------------//
		for(i in PreSettings.CURRENT_SETTINGS.keys()){category_list.push({text:i, display:LangSupport.getText('opt_${Paths.getFileName(i.toLowerCase(), true)}')});}
		category_list.push({text:'Controls', display:LangSupport.getText('opt_controls')}); category_list.push({text:'Key Controls', display:LangSupport.getText('opt_key_controls')});
		//---------------------------------------------------------------------------------------------------------//

		backgrad = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff000000, 0x00000000], 1, 0);
		backgrad.cameras = [curCamera];
		add(backgrad);

		gpCategorys = new FlxTypedGroup<Alphabet>();
		gpCategorys.cameras = [curCamera];

		gpOptions = new FlxTypedGroup<Alphabet>();
		gpOptions.cameras = [curCamera];
		
		for(i in 0...category_list.length){
			var _cat:Alphabet = new Alphabet(10, 0, category_list[i].display);
			_cat.ID = i;
			gpCategorys.add(_cat);
		}

		add(gpCategorys);
		add(gpOptions);

		changeCategory();
		FlxTween.tween(curCamera, {alpha: 1}, 1, {onComplete: function(twn){canControlle = true;}});
	}

	override function update(elapsed:Float){
		super.update(elapsed);


		if(canControlle){
			if(onOptions){
				MagicStuff.sortMembersByY(cast gpOptions, FlxG.height / 2, curOption, 10);
				for(o in gpCategorys.members){
					if(o.ID == curCategory){
						o.alpha = FlxMath.lerp(o.alpha, 1, 0.1);
						o.x = FlxMath.lerp(o.x, (FlxG.width/2)-(o.width/2), 0.1);
						o.y = FlxMath.lerp(o.y, 10, 0.1);
					}else{
						o.alpha = FlxMath.lerp(o.alpha, 0, 0.1);
					}
				}

				if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeOption(-1);}
				if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeOption(1);}

				if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){backOption();}
			}else{
				MagicStuff.sortMembersByY(cast gpCategorys, FlxG.height / 2, curCategory, 50);
				for(o in gpCategorys.members){
					if(o.ID == curCategory){
						o.x = FlxMath.lerp(o.x, 30, 0.1);
					}else{
						o.x = FlxMath.lerp(o.x, 10, 0.1);
					}
				}

				if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeCategory(-1);}
				if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeCategory(1);}
				
				if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){chooseCategory();}

				if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){
					Controls.saveControls();
					PreSettings.saveSettings();
					PlayerSettings.init();
	
					doClose();
				}
			}
		}
	}

	public function chooseCategory():Void {
		onOptions = true;
		curOption = 0;
		gpOptions.clear();

		switch(category_list[curCategory].text){
			case "Controls":{
				var _i:Int = 0;
				var control_list:Array<String> = [for(key in Controls.STATIC_ACTIONS.keys()) key];
				control_list.sort(function(a:String, b:String):Int {
					a = a.toUpperCase();
					b = b.toUpperCase();
				  
					if(a < b){return -1;}
					else if(a > b){return 1;}
					else{return 0;}
				});
				for(control in control_list){
					var _control_opt:ControlOption = new ControlOption(control, principal_controls, this);
					gpOptions.add(_control_opt);

					_control_opt.ID = _i;

					_i++;
				}
			}
			case "Key Controls":{
				var _i:Int = 0;
				var control_list:Array<Int> = [for(key in Controls.STATIC_STRUMCONTROLS.keys()) key];
				control_list.sort(function(a:Int, b:Int):Int {
					if(a < b){return -1;}
					else if(a > b){return 1;}
					else{return 0;}
				});
				for(key in control_list){
					var _control_opt:ControlStrumOption = new ControlStrumOption(key, principal_controls, this);
					gpOptions.add(_control_opt);

					_control_opt.ID = _i;

					_i++;
				}
			}
			default:{
				var _i:Int = 0;
				for(setting in PreSettings.CURRENT_SETTINGS.get(category_list[curCategory].text).keys()){
					var _presetting_opt:PreSettingOption = new PreSettingOption(setting, category_list[curCategory].text, principal_controls, this);
					gpOptions.add(_presetting_opt);

					_presetting_opt.ID = _i;

					_i++;
				}
			}
		}

		changeOption();
	}
	
	public function backOption():Void {
		onOptions = false;
		
		gpOptions.clear();

		changeCategory();
	}

	public function changeCategory(change:Int = 0):Void {
		curCategory += change;
	
		if(curCategory < 0){curCategory = gpCategorys.members.length - 1;}
		if(curCategory >= gpCategorys.members.length){curCategory = 0;}
		
		for(c in gpCategorys.members){c.alpha = 0.5;}
		gpCategorys.members[curCategory].alpha = 1;
	}

	public function changeOption(change:Int = 0):Void {
		curOption += change;
	
		if(curOption < 0){curOption = gpOptions.members.length - 1;}
		if(curOption >= gpOptions.members.length){curOption = 0;}

		for(c in gpOptions.members){c.alpha = 0.5;}
		gpOptions.members[curOption].alpha = 1;
	}

	public function doClose(){
		canControlle = false;
		FlxTween.tween(curCamera, {alpha: 0}, 1, {onComplete: function(twn){close();}});
	}
}

class ControlOption extends Alphabet {
	public var control:String = null;
	private var controls:Controls = null;
	public var state:OptionsSubState = null;
	
	private var unChanged:Bool = false;
	private var isChanging:Bool = false;

	private var curKey:Int = 0;

	public var isGamepad:Bool = false;

	public function new(_control:String, _controls:Controls, _state:OptionsSubState){
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
		if(ID == state.curOption){
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
	public var state:OptionsSubState = null;
	
	private var unChanged:Bool = false;
	private var isChanging:Bool = false;

	private var curKey:Int = 0;

	public var isGamepad:Bool = false;

	public function new(_keys:Int, _controls:Controls, _state:OptionsSubState){
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

		if(ID == state.curOption){
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
	public var state:OptionsSubState = null;

	public var unChanged:Bool = false;

	public function new(_setting:String, _category:String, _controls:Controls, _state:OptionsSubState){
		this.setting = _setting;
		this.category = _category;
		this.controls = _controls;
		this.state = _state;
		super(0,0,null);
		loadText();
	}

	override public function loadText():Void {
		cur_data = [{scale:0.5, text:'\t${LangSupport.getText('set_${Paths.getFileName(setting.toLowerCase(), true)}')}: '}];
		var setting_data:Dynamic = PreSettings.getPreSetting(setting, category);
		
		if(!(setting_data is Int) && !(setting_data is Float)){setting_data = LangSupport.getText(setting_data);}
		cur_data.push({scale:0.5, bold:true, text: '> ${setting_data} <'});

		super.loadText();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(ID == state.curOption){
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