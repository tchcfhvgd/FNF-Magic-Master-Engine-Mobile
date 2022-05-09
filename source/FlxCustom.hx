
package;

import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.addons.ui.FlxUI.NamedFloat;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxDestroyUtil;
import flixel.system.FlxSound;

class FlxUINumericStepperCustom extends FlxUIGroup implements IFlxUIWidget implements IFlxUIClickable implements IHasParams
{
	private var button_plus:FlxUITypedButton<FlxSprite>;
	private var button_minus:FlxUITypedButton<FlxSprite>;
	private var text_field:FlxText;

	public var stepSize:Float = 0;
	public var decimals(default, set):Int = 0; // Number of decimals
	public var min(default, set):Float = 0;
	public var max(default, set):Float = 10;
	public var value(default, set):Float = 0;
	public var stack(default, set):Int = STACK_HORIZONTAL;
	public var isPercent(default, set):Bool = false;

	public static inline var STACK_VERTICAL:Int = 0;
	public static inline var STACK_HORIZONTAL:Int = 1;

	public static inline var CLICK_EVENT:String = "click_numeric_stepper_custom"; // click a numeric stepper button
	public static inline var EDIT_EVENT:String = "edit_numeric_stepper_custom"; // edit the numeric stepper text field
	public static inline var CHANGE_EVENT:String = "change_numeric_stepper_custom"; // do either of the above
    public static inline var CLICK_MINUS:String = "click_numeric_minus_custom";
    public static inline var CLICK_PLUS:String = "click_numeric_plus_custom";

	public var params(default, set):Array<Dynamic>;

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}

	public var skipButtonUpdate(default, set):Bool;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		button_plus.skipButtonUpdate = b;
		button_minus.skipButtonUpdate = b;
		// TODO: Handle input text
		return b;
	}

	private override function set_color(Value:Int):Int
	{
		color = Value;
		button_plus.color = Value;
		button_minus.color = Value;
		if ((text_field is FlxInputText))
		{
			var fit:FlxInputText = cast text_field;
			fit.backgroundColor = Value;
		}
		else
		{
			text_field.color = Value;
		}
		return Value;
	}

	private function set_min(f:Float):Float
	{
		min = f;
		if (value < min)
		{
			value = min;
		}
		return min;
	}

	private function set_max(f:Float):Float
	{
		max = f;
		if (value > max)
		{
			value = max;
		}
		return max;
	}

	private function set_value(f:Float):Float
	{
		value = f;
		if (value < min)
		{
			value = min;
		}
		if (value > max)
		{
			value = max;
		}
		if (text_field != null)
		{
			var displayValue:Float = value;
			if (isPercent)
			{
				displayValue *= 100;
				text_field.text = Std.string(decimalize(displayValue, decimals)) + "%";
			}
			else
			{
				text_field.text = decimalize(displayValue, decimals);
			}
		}
		return value;
	}

	private function set_decimals(i:Int):Int
	{
		decimals = i;
		if (i < 0)
		{
			decimals = 0;
		}
		value = value;
		return decimals;
	}

	private function set_isPercent(b:Bool):Bool
	{
		isPercent = b;
		value = value;
		return isPercent;
	}

	private function set_stack(s:Int):Int
	{
		stack = s;
		var btnSize:Int = 10;
		var offsetX:Int = 0;
		var offsetY:Int = 0;
		if ((text_field is FlxUIInputText))
		{
			offsetX = 1;
			offsetY = 1; // border for input text
		}
		switch (stack)
		{
			case STACK_HORIZONTAL:
				btnSize = 2 + cast text_field.height;
				if (button_plus.height != btnSize)
				{
					button_plus.resize(btnSize, btnSize);
				}
				if (button_minus.height != btnSize)
				{
					button_minus.resize(btnSize, btnSize);
				}
				button_plus.x = offsetX + text_field.x + text_field.width;
				button_plus.y = -offsetY + text_field.y;
				button_minus.x = button_plus.x + button_plus.width;
				button_minus.y = button_plus.y;
			case STACK_VERTICAL:
				btnSize = 1 + cast text_field.height / 2;
				if (button_plus.height != btnSize)
				{
					button_plus.resize(btnSize, btnSize);
				}
				if (button_minus.height != btnSize)
				{
					button_minus.resize(btnSize, btnSize);
				}
				button_plus.x = offsetX + text_field.x + text_field.width;
				button_plus.y = -offsetY + text_field.y;
				button_minus.x = offsetX + text_field.x + text_field.width;
				button_minus.y = offsetY + text_field.y + (text_field.height - button_minus.height);
		}
		return stack;
	}

	private inline function decimalize(f:Float, digits:Int):String
	{
		var tens:Float = Math.pow(10, digits);
		return Std.string(Math.round(f * tens) / tens);
	}

	/**
	 * This creates a new dropdown menu.
	 *
	 * @param	X					x position of the dropdown menu
	 * @param	Y					y position of the dropdown menu
	 * @param	StepSize			How big is the step
	 * @param	DefaultValue		Optional default numerical value for the stepper to display
	 * @param	Min					Optional Minimum values for the stepper
	 * @param	Max					Optional Maximum and Minimum values for the stepper
	 * @param	Decimals			Optional # of decimal places
	 * @param	Stack				Stacking method
	 * @param	TextField			Optional text field
	 * @param	ButtonPlus			Optional button to use for plus
	 * @param	ButtonMinus			Optional button to use for minus
	 * @param	IsPercent			Whether to portray the number as a percentage
	 */
	public function new(X:Float = 0, Y:Float = 0, StepSize:Float = 1, DefaultValue:Float = 0, Min:Float = -999, Max:Float = 999, Decimals:Int = 0,
			Stack:Int = STACK_HORIZONTAL, ?TextField:FlxText, ?ButtonPlus:FlxUITypedButton<FlxSprite>, ?ButtonMinus:FlxUITypedButton<FlxSprite>,
			IsPercent:Bool = false)
	{
		super(X, Y);

		if (TextField == null)
		{
			TextField = new FlxUIInputText(0, 0, 25);
		}
		TextField.x = 0;
		TextField.y = 0;
		text_field = TextField;
		text_field.text = Std.string(DefaultValue);

		if ((text_field is FlxUIInputText))
		{
			var fuit:FlxUIInputText = cast text_field;
			fuit.lines = 1;
			fuit.callback = _onInputTextEvent; // internal communication only
			fuit.broadcastToFlxUI = false;
		}

		stepSize = StepSize;
		decimals = Decimals;
		min = Min;
		max = Max;
		value = DefaultValue;
		isPercent = IsPercent;

		var btnSize:Int = 1 + cast TextField.height;

		if (ButtonPlus == null)
		{
			ButtonPlus = new FlxUITypedButton<FlxSprite>(0, 0);
			ButtonPlus.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], btnSize, btnSize, [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_THIN)],
				FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
			ButtonPlus.label = new FlxSprite(0, 0, FlxUIAssets.IMG_PLUS);
		}
		if (ButtonMinus == null)
		{
			ButtonMinus = new FlxUITypedButton<FlxSprite>(0, 0);
			ButtonMinus.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], btnSize, btnSize, [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_THIN)],
				FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
			ButtonMinus.label = new FlxSprite(0, 0, FlxUIAssets.IMG_MINUS);
		}

		button_plus = ButtonPlus;
		button_minus = ButtonMinus;

		add(text_field);
		add(button_plus);
		add(button_minus);

		button_plus.onUp.callback = _onPlus;
		button_plus.broadcastToFlxUI = false;

		button_minus.onUp.callback = _onMinus;
		button_minus.broadcastToFlxUI = false;

		stack = Stack;
	}

	private function _onInputTextEvent(text:String, action:String):Void
	{
		if (text == "")
		{
			text = Std.string(min);
		}

		var numDecimals:Int = 0;
		for (i in 0...text.length)
		{
			var char = text.charAt(i);
			if (char == ".")
			{
				numDecimals++;
			}
		}

		var justAddedDecimal = (numDecimals == 1 && text.indexOf(".") == text.length - 1);

		// if I just added a decimal don't treat that as having changed the value just yet
		if (!justAddedDecimal)
		{
			value = Std.parseFloat(text);
			_doCallback(EDIT_EVENT);
			_doCallback(CHANGE_EVENT);
		}
	}

	private function _onPlus():Void
	{
		value += stepSize;
		_doCallback(CLICK_EVENT);
		_doCallback(CHANGE_EVENT);
        _doCallback(CLICK_PLUS);
	}

	private function _onMinus():Void
	{
		value -= stepSize;
		_doCallback(CLICK_EVENT);
		_doCallback(CHANGE_EVENT);
        _doCallback(CLICK_MINUS);
	}

	private function _doCallback(event_name:String):Void
	{
		if (broadcastToFlxUI)
		{
			FlxUI.event(event_name, this, value, params);
		}
	}

    public function setWidth(width:Int){
        text_field.width = width;
        text_field.fieldWidth = width;
        set_stack(stack);
    }
}

class FlxUICustomList extends FlxUIGroup implements IFlxUIWidget implements IFlxUIClickable implements IHasParams {
    private var _OnChange:Void->Void = null;
	
	private var _btnBack:FlxUIButton;
    private var _lblCuItem:FlxUIText;
    private var _btnFront:FlxUIButton;

    private var list:Array<String>;
    private var index:Int = 0;

    public static inline var CLICK_BACK:String = "click_back_list";
    public static inline var CLICK_FRONT:String = "click_front_list";
    public static inline var CHANGE_EVENT:String = "change_list";

    public var params(default, set):Array<Dynamic>;
	private function set_params(p:Array<Dynamic>):Array<Dynamic>{return params = p;}

    public var skipButtonUpdate(default, set):Bool;
    private function set_skipButtonUpdate(b:Bool):Bool{
        skipButtonUpdate = b;
        return b;
    }

    public function new(X:Float = 0, Y:Float = 0, ?DataList:Array<String>, ?OnChange:Void->Void){
        super(X, Y);

        if(DataList != null){
            list = DataList;
        }else{
            list = ["NONE"];
        }

        _btnBack = new FlxUIButton(0, 0, "<", function(){c_Index(-1);});
        _btnBack.setSize(Std.int(20), Std.int(_btnBack.height));
        _btnBack.setGraphicSize(Std.int(20), Std.int(_btnBack.height));
        _btnBack.centerOffsets();
        _btnBack.label.fieldWidth = _btnBack.width;

        _lblCuItem = new FlxUIText(_btnBack.x + _btnBack.width, _btnBack.y + 3, 100, "|None|", 8);
        _lblCuItem.color = FlxColor.WHITE;
        _lblCuItem.alignment = CENTER;

        _btnFront = new FlxUIButton(_lblCuItem.x + _lblCuItem.width, _lblCuItem.y - 3, ">", function(){c_Index(1);});
        _btnFront.setSize(Std.int(20), Std.int(_btnFront.height));
        _btnFront.setGraphicSize(Std.int(20), Std.int(_btnFront.height));
        _btnFront.centerOffsets();
        _btnFront.label.fieldWidth = _btnFront.width;

        add(_btnBack);
        add(_lblCuItem);
        add(_btnFront);

        calcBounds();
        c_Index();
    }

    private function c_Index(change:Int = 0):Void{
        index += change;
        if(index >= list.length){index = 0;}
        if(index < 0){index = list.length - 1;}

        _lblCuItem.text = list[index];

		if(_OnChange != null){_OnChange();}

        if(change > 0){_doCallback(CLICK_BACK);}
        if(change < 0){_doCallback(CLICK_FRONT);}
        _doCallback(CHANGE_EVENT);
    }

    public function setData(DataList:Array<String>):Void{
        list = DataList;
        c_Index();
    }

    public function setWidth(Width:Float) {
        if(Width < 45){Width = 40;}
        
        super.setSize(Width, this.height);

        _lblCuItem.width = Width - 40;
        _lblCuItem.fieldWidth = Width - 40;

        _btnFront.x = _lblCuItem.x + _lblCuItem.width;
    }

    public function getSelectedLabel():String{
        return list[index];
    }

	public function getSelectedIndex():Int{
        return index;
    }


    private function _doCallback(event_name:String):Void{
        if(broadcastToFlxUI){
            FlxUI.event(event_name, this, getSelectedIndex(), params);
        }
    }
}