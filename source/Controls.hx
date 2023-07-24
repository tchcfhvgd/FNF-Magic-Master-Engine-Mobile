package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

using StringTools;

enum Device {
	KeyBoard;
	Gamepad(id:Int);
}

enum KeyboardScheme {
	Solo;
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet {
	public static var controls_save:FlxSave;

	public static function init():Void {
		controls_save = new FlxSave();
		controls_save.bind('controls', 'Yirius125');

		STATIC_ACTIONS = DEFAULT_STATIC_ACTIONS.copy();
		STATIC_STRUMCONTROLS = DEFAULT_STATIC_STRUMCONTROLS.copy();
	}

	public function getNoteDataFromKey(cur_key:FlxKey, game_keys:Int):Int {
		var cont:Array<Dynamic> = CURRENT_STRUMCONTROLS.get(game_keys);
		for(i in 0...cont.length){if(cont[i][0].contains(cur_key)){return i;}}
		return -1;
	}

	public static var CURRENT_ACTIONS:Map<String, Array<Array<Int>>> = [];
	public static var STATIC_ACTIONS:Map<String, Array<Array<Int>>> = [];
    public static final DEFAULT_STATIC_ACTIONS:Map<String, Array<Array<Int>>> = [
		//Menu General Movement Actions
        "Menu_Up" => [// Action Name
			[FlxKey.UP], // KeyBoard Inputs
			[FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.DPAD_UP] // Gamepad Inputs
		],
        "Menu_Left" => [
			[FlxKey.LEFT],
			[FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.DPAD_LEFT]
		],
        "Menu_Down" => [
			[FlxKey.DOWN],
			[FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN, FlxGamepadInputID.DPAD_DOWN]
		],
        "Menu_Right" => [
			[FlxKey.RIGHT],
			[FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxGamepadInputID.DPAD_RIGHT]
		],
        //Menu General Actions
        "Menu_Accept" => [
			[FlxKey.ENTER],
			[FlxGamepadInputID.START, FlxGamepadInputID.A]
		],
        "Menu_Back" => [
			[FlxKey.ESCAPE],
			[FlxGamepadInputID.B, FlxGamepadInputID.BACK]
		],
        "Pause_Game" => [
			[FlxKey.ENTER, FlxKey.ESCAPE],
			[FlxGamepadInputID.START, FlxGamepadInputID.BACK]
		]
        //Character General Movement Actions
        //"Player_Left" => [[FlxKey.LEFT]],
        //"Player_Down" => [[FlxKey.DOWN]],
        //"Player_Right" => [[FlxKey.RIGHT]],
        //"Player_Up" => [[FlxKey.UP]],
        //"Player_Run" => [[FlxKey.SHIFT]],
        //"Player_Interact" => [[FlxKey.C]]
    ];

	public static var CURRENT_STRUMCONTROLS:Map<Int, Array<Array<Array<Int>>>> = [];
	public static var STATIC_STRUMCONTROLS:Map<Int, Array<Array<Array<Int>>>> = [];
	public static final DEFAULT_STATIC_STRUMCONTROLS:Map<Int, Array<Array<Array<Int>>>> = [
        1 => [ //Inputs for 1K
			[// Input Data 0
				[FlxKey.SPACE], //KeyBoard
				[FlxGamepadInputID.A] //GamePad
			]
		],
		2 => [ //Inputs for 2K
			[
				[FlxKey.A, FlxKey.LEFT],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.D, FlxKey.RIGHT],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			]
		],
		3 => [ //Inputs for 3K
			[
				[FlxKey.A, FlxKey.LEFT],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.SPACE],
				[FlxGamepadInputID.A]
			],
			[
				[FlxKey.D, FlxKey.RIGHT],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			]
		],
		4 => [ //Inputs for 4K
			[
				[FlxKey.A, FlxKey.LEFT],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S, FlxKey.DOWN],
				[FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.W, FlxKey.UP],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.D, FlxKey.RIGHT],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			]
		],
		5 => [ //Inputs for 5K
			[
				[FlxKey.D, FlxKey.LEFT],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.F, FlxKey.DOWN],
				[FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.SPACE],
				[FlxGamepadInputID.A]
			],
			[
				[FlxKey.J, FlxKey.UP],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.K, FlxKey.RIGHT],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			]
		],
		6 => [ //Inputs for 6K
			[
				[FlxKey.A],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S, FlxKey.W],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.D],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT]
			],
			[
				[FlxKey.J],
				[FlxGamepadInputID.X, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.K, FlxKey.I],
				[FlxGamepadInputID.A, FlxGamepadInputID.Y, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.L],
				[FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			],
		],
		7 => [ //Inputs for 7K
			[
				[FlxKey.A],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S, FlxKey.W],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.D],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT]
			],
			[
				[FlxKey.SPACE],
				[FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.RIGHT_SHOULDER]
			],
			[
				[FlxKey.J],
				[FlxGamepadInputID.X, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.K, FlxKey.I],
				[FlxGamepadInputID.A, FlxGamepadInputID.Y, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.L],
				[FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			],
		],
		8 => [ //Inputs for 8K
			[
				[FlxKey.A],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S],
				[FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.D],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.F],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT]
			],
			[
				[FlxKey.H],
				[FlxGamepadInputID.X, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.J],
				[FlxGamepadInputID.A, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.K],
				[FlxGamepadInputID.Y, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.L],
				[FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			],
		],
		9 => [ //Inputs for 9K
			[
				[FlxKey.A],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S],
				[FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.D],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.F],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT]
			],
			[
				[FlxKey.SPACE],
				[FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.RIGHT_SHOULDER]
			],
			[
				[FlxKey.H],
				[FlxGamepadInputID.X, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.J],
				[FlxGamepadInputID.A, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.K],
				[FlxGamepadInputID.Y, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.L],
				[FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			],
		],
		10 => [ //Inputs for 10K
			[
				[FlxKey.A],
				[FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.S],
				[FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.D],
				[FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.F],
				[FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT]
			],
			[
				[FlxKey.V],
				[FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.LEFT_SHOULDER]
			],
			[
				[FlxKey.B],
				[FlxGamepadInputID.RIGHT_TRIGGER_BUTTON, FlxGamepadInputID.RIGHT_SHOULDER]
			],
			[
				[FlxKey.H],
				[FlxGamepadInputID.X, FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT]
			],
			[
				[FlxKey.J],
				[FlxGamepadInputID.A, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN]
			],
			[
				[FlxKey.K],
				[FlxGamepadInputID.Y, FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP]
			],
			[
				[FlxKey.L],
				[FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT]
			],
		],
    ];

    public var ACTIONS:Map<String, FlxActionDigital> = [];

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public function new(name, scheme = None){
        super(name);

        for(action in STATIC_ACTIONS.keys()){
            ACTIONS['${action}'] = new FlxActionDigital('${action}');
            ACTIONS['${action}_r'] = new FlxActionDigital('${action}_h');
            ACTIONS['${action}_h'] = new FlxActionDigital('${action}_r');

            add(ACTIONS['${action}']);
            add(ACTIONS['${action}_r']);
            add(ACTIONS['${action}_h']);
        }

		for(action in STATIC_STRUMCONTROLS.keys()){
			var binds:Array<Dynamic> = STATIC_STRUMCONTROLS[action];

			for(i in 0...binds.length){
				ACTIONS['${action}keys_${i}'] = new FlxActionDigital('${action}keys_${i}');
				ACTIONS['${action}keys_${i}_h'] = new FlxActionDigital('${action}keys_${i}_h');
				ACTIONS['${action}keys_${i}_r'] = new FlxActionDigital('${action}keys_${i}_r');

				add(ACTIONS['${action}keys_${i}']);
				add(ACTIONS['${action}keys_${i}_h']);
				add(ACTIONS['${action}keys_${i}_r']);
			}
        }
        
        setKeyboardScheme(scheme, false);
    }

	override function update(){
		super.update();
	}

    private function getBind(name:String, state:FlxInputState){
        switch(state){
            default:{}
            case JUST_RELEASED:{name += "_r";}
            case PRESSED:{name += "_h";}
        }
        
        #if debug
		if (!ACTIONS.exists(name))
			throw 'Invalid name: $name';
		#end
		return ACTIONS[name];
    }

    private function getBindState(name:String):FlxInputState{
        if(name.contains("_r")){return JUST_RELEASED;}
        if(name.contains("_h")){return PRESSED;}
        return JUST_PRESSED;
    }

	public function getStrumCheckers(keys:Int, state:FlxInputState):Array<Bool>{
		var toReturn:Array<Bool> = [];
		var tag:String = '${keys}keys_';

		for(i in 0...keys){toReturn.push(checkAction('${tag}${i}', state));}

		return toReturn;
    }

    public function checkAction(name:String, state:FlxInputState):Bool {
		var bind = getBind(name, state);
		if(bind == null){return false;}
		return bind.check();
    }

	public function replaceBinding(device:Device, bind:String, ?toAdd:Int, ?toRemove:Int){
		if(toAdd == toRemove){return;}

		switch(device){
			case KeyBoard:{
                if(toRemove != null){unbindKeys(bind, [toRemove]);}
				if(toAdd != null){bindKeys(bind, [toAdd]);}
            }
			case Gamepad(id):{
                if(toRemove != null){unbindButtons(id, bind, [toRemove]);}
				if(toAdd != null){bindButtons(id, bind, [toAdd]);}
            }
		}
	}

	public function copyFrom(controls:Controls, ?device:Device){
		for(name => action in controls.ACTIONS){
			for(input in action.inputs){
				if(device == null || isDevice(input, device)){
                    ACTIONS[name].add(cast input);
                }
			}
		}

		switch (device){
			case null:{
                // add all
				#if (haxe >= "4.0.0")
				for(gamepad in controls.gamepadsAdded){
                    if(!gamepadsAdded.contains(gamepad)){
                        gamepadsAdded.push(gamepad);
                    }
                }
				#else
				for(gamepad in controls.gamepadsAdded){
                    if(gamepadsAdded.indexOf(gamepad) == -1){
                        gamepadsAdded.push(gamepad);
                    }
                }
				#end

				mergeKeyboardScheme(controls.keyboardScheme);
            }
			case Gamepad(id):{
				gamepadsAdded.push(id);
            }
			case KeyBoard:{
				mergeKeyboardScheme(controls.keyboardScheme);
            }
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device){
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void{
		if(scheme != None){
			switch(keyboardScheme){
				case None:{keyboardScheme = scheme;}
				default:{keyboardScheme = Custom;}
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(bind:String, keys:Array<FlxKey>){
		//trace('Bind [${bind}] | Keys: ${keys}');

        for(key in keys){
			ACTIONS['${bind}'].addKey(key, JUST_PRESSED);
			ACTIONS['${bind}_h'].addKey(key, PRESSED);
			ACTIONS['${bind}_r'].addKey(key, JUST_RELEASED);
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(bind:String, keys:Array<FlxKey>){
		unBindAction(ACTIONS['${bind}'], keys);
		unBindAction(ACTIONS['${bind}_h'], keys);
		unBindAction(ACTIONS['${bind}_r'], keys);
	}

	private function unBindAction(bind:FlxActionDigital, keys:Array<FlxKey>){
		var i = bind.inputs.length;
		while (i-- > 0){
			var input = bind.inputs[i];
			if(input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1){bind.remove(input);}
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true){
		keyboardScheme = scheme;
		loadBinds();

		switch(scheme){
			case Solo:{
				var KEY_ACTIONS:Map<String, Array<FlxKey>> = [];
		
				for(key in CURRENT_ACTIONS.keys()){
					KEY_ACTIONS[key] = CURRENT_ACTIONS[key][0];
				}

				for(key in CURRENT_STRUMCONTROLS.keys()){
					for(i in 0...CURRENT_STRUMCONTROLS[key].length){
						KEY_ACTIONS['${key}keys_${i}'] = CURRENT_STRUMCONTROLS[key][i][0];
					}
				}
		
				for(key in CURRENT_ACTIONS.keys()){bindKeys(key, KEY_ACTIONS[key]);}
				for(key in CURRENT_STRUMCONTROLS.keys()){
					for(i in 0...CURRENT_STRUMCONTROLS[key].length){
						bindKeys('${key}keys_${i}', KEY_ACTIONS['${key}keys_${i}']);
					}
				}
			}
			case Custom:{}
			case None:{}
		}
		
	}

	public function loadBinds(){
        CURRENT_ACTIONS = controls_save.data.keyBinds;
		CURRENT_STRUMCONTROLS = controls_save.data.strumBinds;
				
		if(CURRENT_ACTIONS == null || CURRENT_STRUMCONTROLS == null){
			controls_save.data.keyBinds = STATIC_ACTIONS;
			controls_save.data.strumBinds = STATIC_STRUMCONTROLS;
			loadBinds();
			return;
		}

		for(key in STATIC_ACTIONS.keys()){if(!CURRENT_ACTIONS.exists(key)){CURRENT_ACTIONS.set(key, STATIC_ACTIONS.get(key));}}
		for(key in CURRENT_ACTIONS.keys()){if(!STATIC_ACTIONS.exists(key)){CURRENT_ACTIONS.remove(key);}}
		
		for(key in STATIC_STRUMCONTROLS.keys()){if(!CURRENT_STRUMCONTROLS.exists(key)){CURRENT_STRUMCONTROLS.set(key, STATIC_STRUMCONTROLS.get(key));}}
		for(key in CURRENT_STRUMCONTROLS.keys()){if(!STATIC_STRUMCONTROLS.exists(key)){CURRENT_STRUMCONTROLS.remove(key);}}

		removeActions();
	}

	public static function saveControls(){
		controls_save.data.keyBinds = CURRENT_ACTIONS;
		controls_save.data.strumBinds = CURRENT_STRUMCONTROLS;
		controls_save.flush();
		trace("Controls Saved");
	}

	function removeActions(){
		for(name in ACTIONS.keys()){ACTIONS[name].removeAll();}
	}	

	public function addGamepad(id:Int):Void{
		gamepadsAdded.push(id);

		var GAMEPAD_ACTIONS:Map<String, Array<FlxGamepadInputID>> = [];
		for(key in CURRENT_ACTIONS.keys()){GAMEPAD_ACTIONS[key] = CURRENT_ACTIONS[key][1];}
		for(key in CURRENT_STRUMCONTROLS.keys()){
			for(i in 0...CURRENT_STRUMCONTROLS[key].length){
				GAMEPAD_ACTIONS['${key}keys_${i}'] = CURRENT_STRUMCONTROLS[key][i][1];
			}
		}

		for(key in CURRENT_ACTIONS.keys()){bindButtons(id, key, GAMEPAD_ACTIONS[key]);}
		for(key in CURRENT_STRUMCONTROLS.keys()){
			for(i in 0...CURRENT_STRUMCONTROLS[key].length){
				bindButtons(id, '${key}keys_${i}', GAMEPAD_ACTIONS['${key}keys_${i}']);
			}
		}
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void {
		for(action in ACTIONS.keys()){
			var i = ACTIONS[action].inputs.length;
			while (i-- > 0){
				var input = ACTIONS[action].inputs[i];
				if(input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID)){ACTIONS[action].remove(input);}
			}
		}
	
		gamepadsAdded.remove(deviceID);
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(id:Int, bind:String, keys:Array<FlxGamepadInputID>){
		//trace('Button Bind [${bind}] | Keys: ${keys}');
		for(key in keys){
			ACTIONS['${bind}'].addGamepad(key, JUST_PRESSED, id);
			ACTIONS['${bind}_h'].addGamepad(key, PRESSED, id);
			ACTIONS['${bind}_r'].addGamepad(key, JUST_RELEASED, id);
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(id:Int, bind:String, keys:Array<FlxGamepadInputID>){
		unbindActionButtons(id, ACTIONS['${bind}'], keys);
		unbindActionButtons(id, ACTIONS['${bind}_h'], keys);
		unbindActionButtons(id, ACTIONS['${bind}_r'], keys);
	}

	private function unbindActionButtons(id:Int, bind:FlxActionDigital, keys:Array<FlxGamepadInputID>){
		var i = bind.inputs.length;
		while(i-- > 0){
			var input = bind.inputs[i];
			if(isGamepad(input, id) && keys.indexOf(cast input.inputID) != -1){bind.remove(input);}
		}
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0){
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function removeDevice(device:Device){
		switch (device){
			case KeyBoard:{setKeyboardScheme(None);}
			case Gamepad(id):{removeGamepad(id);}
		}
	}

	static function isDevice(input:FlxActionInput, device:Device){
		return switch device{
			case KeyBoard:{input.device == KEYBOARD;}
			case Gamepad(id):{isGamepad(input, id);}
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int){
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
