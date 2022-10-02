package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.geom.Rectangle;

import flixel.addons.ui.*;

class OptionsSubState extends MusicBeatSubstate {
	private var gpCategory:FlxTypedGroup<Alphabet>;
	private var gpOptions:FlxTypedGroup<OptionItem>;

	private var curCategory:Int = 0;
	private var choosedCat:Bool = false;

	private var curOption:Int = 0;

	public function new(_backGround:Bool = true){
		FlxG.mouse.visible = true;
		super();
		canControlle = false;
		
		if(!_backGround){curCamera.bgColor.alpha = 0;}
		curCamera.alpha = 0;

		gpCategory = new FlxTypedGroup<Alphabet>();
		gpCategory.cameras = [curCamera];

		gpOptions = new FlxTypedGroup<OptionItem>();
		gpOptions.cameras = [curCamera];

		var optsList:Array<String> = ['Controls', 'Key Controls'];
		for(i in PreSettings.CURRENT_SETTINGS.keys()){optsList.push(i);}

		for(i in optsList){
			var _cat:Alphabet = new Alphabet(10,0,new FlxPoint(0.5,0.5),i,true,false);
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
			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeValue(-1);}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeValue(1);}
			
			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
				selCat(true);
			}

			if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){
				if(choosedCat){selCat(false);}else{doClose();}
			}
		}
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
			for(obj in gpCategory){obj.curScale.set(0.3, 0.3); obj.setText();}
			
			var curCat:String = gpCategory.members[curCategory].curText;
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
		}else{
			gpOptions.clear();

			for(obj in gpCategory){obj.curScale.set(0.5, 0.5); obj.setText();}
		}
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
		super(FlxG.width+10,FlxG.height/2,new FlxPoint(0.5,0.5),'',true,false);
		setText();
	}

	override public function setText():Void {
		switch(type){
			case "Controls":{curText = '${setting}: < ${Controls.STATIC_ACTIONS.get(setting)} >';}
			case "KeyControls":{curText = '${setting}: < ${Controls.STATIC_STRUMCONTROLS.get(Std.parseInt(setting))} >';}
			default:{curText = '${setting}: < ${PreSettings.getPreSetting(setting,category)} >';}
		}

		super.setText();
	}
}