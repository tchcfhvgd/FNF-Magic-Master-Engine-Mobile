package substates;

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
	private var gpCategory:FlxTypedGroup<Alphabet>;
	private var gpOptions:FlxTypedGroup<OptionItem>;

	private var curCategory:Int = 0;
	private var curOption:Int = 0;
	private var choosedCat:Bool = false;

	public function new(){
		FlxG.mouse.visible = true;
		super();
		curCamera.alpha = 0;

		gpCategory = new FlxTypedGroup<Alphabet>();
		gpCategory.cameras = [curCamera];

		gpOptions = new FlxTypedGroup<OptionItem>();
		gpOptions.cameras = [curCamera];

		var optsList:Array<String> = ['Controls', 'Key Controls'];
		for(i in PreSettings.CURRENT_SETTINGS.keys()){optsList.push(i);}

		for(i in optsList){
			var _cat:Alphabet = new Alphabet(10,0,i);
			gpCategory.add(_cat);
		}

		add(gpOptions);
		add(gpCategory);

		changeValue();
		FlxTween.tween(curCamera, {alpha: 1}, 1, {onComplete: function(twn){
			canControlle = true;
		}});
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(!choosedCat){
			for(o in gpCategory.members){MagicStuff.lerpX(o, (FlxG.width / 2) - (o.width / 2));}
		}else{
			for(o in gpCategory.members){MagicStuff.lerpX(o, 10);}

			for(o in gpOptions.members){MagicStuff.lerpX(o, FlxG.width - o.width - 20);}
			MagicStuff.sortMembersByY(cast gpOptions, FlxG.height / 2, curOption);
		}
		MagicStuff.sortMembersByY(cast gpCategory, FlxG.height / 2, curCategory);

		if(canControlle){
			if(principal_controls.checkAction("Menu_Left", JUST_PRESSED)){changeOption(-1);}
			if(principal_controls.checkAction("Menu_Right", JUST_PRESSED)){changeOption(1);}

			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeValue(-1);}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeValue(1);}

			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
				if(!choosedCat){selCat(true);}
			}

			if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){
				if(choosedCat){selCat(false);}else{doClose();}
			}
		}
	}

	public function changeOption(change:Int = 0):Void {
		if(!choosedCat){return;}

		var cur_category:String = gpCategory.members[curCategory].text;
		var cur_option_item:OptionItem = gpOptions.members[curOption];
		var cur_option:String = cur_option_item.setting;
		var pre_Current:Dynamic = null;
		switch(cur_category){
			case "KeysControls":{

			}
			case "Controls":{

			}
			default:{
				pre_Current = PreSettings.CURRENT_SETTINGS.get(cur_category).get(cur_option);
				if((pre_Current is Bool)){PreSettings.CURRENT_SETTINGS.get(cur_category).set(cur_option, !(cast(pre_Current,Bool)));}
				else if((pre_Current is Int) || (pre_Current is Float)){
					pre_Current += change;
					PreSettings.CURRENT_SETTINGS.get(cur_category).set(cur_option, pre_Current);
				}
				else if((pre_Current is Array)){
					pre_Current[0] += change;
					var _opts:Array<Dynamic> = pre_Current[1].copy();
					if(pre_Current[0] < 0){pre_Current[0] = _opts.length - 1;}
					if(pre_Current[0] >= _opts.length){pre_Current[0] = 0;}
					PreSettings.CURRENT_SETTINGS.get(cur_category).set(cur_option, pre_Current);
				}
			}
		}

		cur_option_item.text = pre_Current;
		cur_option_item.loadText();

		changeValue();
	}

	public function changeValue(change:Int = 0):Void {
		if(choosedCat){
			curOption += change;
	
			if(curOption < 0){curOption = gpOptions.members.length - 1;}
			if(curOption >= gpOptions.members.length){curOption = 0;}
	
			for(c in gpOptions.members){c.alpha = 0.5;}
			gpOptions.members[curOption].alpha = 1;
		}else{
			curCategory += change;
	
			if(curCategory < 0){curCategory = gpCategory.members.length - 1;}
			if(curCategory >= gpCategory.members.length){curCategory = 0;}
	
			for(c in gpCategory.members){c.alpha = 0.5;}
			gpCategory.members[curCategory].alpha = 1;
		}
	}

	public function selCat(val:Bool):Void {
		choosedCat = val;

		if(choosedCat){
			curOption = 0;			
			var curCat:String = gpCategory.members[curCategory].text;
			switch(curCat){
				case "Controls":{
					for(i in Controls.STATIC_ACTIONS.keys()){
						var _opt:OptionItem = new OptionItem(i,curCat,"Controls");
						gpOptions.add(_opt);
					}
				}
				case "Key Controls":{
					for(i in Controls.STATIC_STRUMCONTROLS.keys()){
						var _opt:OptionItem = new OptionItem('$i',curCat,"KeyControls");
						gpOptions.add(_opt);
					}
				}
				default:{
					for(i in PreSettings.CURRENT_SETTINGS.get(curCat).keys()){
						var _opt:OptionItem = new OptionItem(i,curCat,"PreSettings");
						gpOptions.add(_opt);
					}
				}
			}
			changeValue();
		}else{gpOptions.clear();}
	}

	public function doClose(){
		canControlle = false;
		FlxTween.tween(curCamera, {alpha: 0}, 1, {onComplete: function(twn){close();}});
	}
}

class OptionItem extends Alphabet {
	public var type:String = "PreSetting";
	public var setting:String = "";
	public var category:String = "";

	public function new(_setting:String, _category:String, _type:String){
		this.type = _type;
		this.setting = _setting;
		this.category = _category;
		super(FlxG.width+10,FlxG.height/2,'');
		loadText();
	}

	override public function loadText():Void {
		switch(type){
			case "Controls":{text = '${setting}: < ${getControlsList(Controls.STATIC_ACTIONS.get(setting))} >';}
			case "KeyControls":{text = '${setting}: < ${Controls.STATIC_STRUMCONTROLS.get(Std.parseInt(setting))} >';}
			default:{
				var _cur_settings:Any = PreSettings.getPreSetting(setting,category);
				text = '${setting}: < ${_cur_settings} >';
			}
		}
		super.loadText();
	}

	public function getControlsList(list:Array<Dynamic>):String {
		var toReturn:String = '[';
		for(i in 0...list.length){
			var _i = list[i];

			if((_i is Int)){
				switch(i){
					case 0:{toReturn +=  '${cast(_i,FlxKey).toString()},';}
					case 1:{toReturn +=  '${cast(_i,FlxGamepadInputID).toString()},';}
				}
			}else if((_i is Array)){
				toReturn += getControlsList(cast(_i));
			}
		}
		toReturn += ']';
		
		return toReturn;
	}
}