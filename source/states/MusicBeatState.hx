package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import haxe.rtti.CType.Abstractdef;
import substates.MusicBeatSubstate;
import Conductor.BPMChangeEvent;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxRect;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;

import FlxCustom.FlxCustomShader;

using StringTools;

class MusicBeatState extends FlxUIState {
	public static var state:MusicBeatState;
	public static var popList:Array<String> = [];

	public var conductor:Conductor = new Conductor();

	public var onBack:Class<FlxState>;
	public var onConfirm:Class<FlxState>;
	
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	public var principal_controls(get, never):Controls;
	inline function get_principal_controls():Controls{return PlayerSettings.getPlayer(0).controls;}

	private function getOtherControls(ID:Int):Controls{return PlayerSettings.getPlayer(ID).controls;}
	public var canControlle:Bool = false;

    public var tempScripts:Map<String, Script> = [];
	public function pushTempScript(key:String, ?pre:Dynamic):Void {
		if(pre == null){pre = [];}

		if(tempScripts.exists(key) || ModSupport.staticScripts.exists(key)){
			if(tempScripts.exists(key)){
				var preCharge:Array<Dynamic> = tempScripts.get(key).getVariable("prefunctions");
				preCharge.push(pre);
				tempScripts.get(key).setVariable("prefunctions", preCharge);
			}
			if(ModSupport.staticScripts.exists(key)){
				var preCharge:Array<Dynamic> = ModSupport.staticScripts.get(key).getVariable("prefunctions");
				preCharge.push(pre);
				ModSupport.staticScripts.get(key).setVariable("prefunctions", preCharge);
			}
			
			return;
		}
		var nScript = new Script(); nScript.Name = key;
		nScript.setVariable("prefunctions", [pre]);
		nScript.exScript(Paths.getText(Paths.event(key)));
		tempScripts.set(key, nScript);
	}

	private var script(get, never):Script;
	function get_script():Script {
		if(ModSupport.exScripts.contains(Type.getClassName(Type.getClass(this)))){return null;}

		var stateScript = null;
		if(ModSupport.staticScripts.exists(Type.getClassName(Type.getClass(this)))){stateScript = ModSupport.staticScripts.get(Type.getClassName(Type.getClass(this)));}

		return stateScript;
	}
	public var scripts(get, never):Array<Script>;
	function get_scripts():Array<Script> {
		var toReturn:Array<Script> = [];
		if(script != null){toReturn.push(script);}
		for(sc in tempScripts.keys()){toReturn.push(tempScripts.get(sc));}
		for(sc in ModSupport.staticScripts.keys()){if(!sc.contains(".")){toReturn.push(ModSupport.staticScripts.get(sc));}}
		for(sc in ModSupport.modDataScripts.keys()){toReturn.push(ModSupport.modDataScripts.get(sc));}
		return toReturn;
	}

	public var camGame:FlxCamera = new FlxCamera();
	public var camFGame:FlxCamera = new FlxCamera();
	public var camBHUD:FlxCamera = new FlxCamera();
	public var camHUD:FlxCamera = new FlxCamera();
	public var camFHUD:FlxCamera = new FlxCamera();
	
	public function new(?onConfirm:Class<FlxState>, ?onBack:Class<FlxState>){
		this.onBack = onBack;
		this.onConfirm = onConfirm;

		super();
	}

	override function create(){
		state = this;
		if(transIn != null){trace('reg ' + transIn.region);}

		camFGame.bgColor.alpha = 0;
		camBHUD.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camFHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camFGame);
		FlxG.cameras.add(camBHUD);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camFHUD);

		FlxCamera.defaultCameras = [camGame];

		for(s in scripts){s.exFunction('create');}
		super.create();

		FlxTween.tween(camFGame, {alpha: 1}, 0.5);
		FlxTween.tween(camBHUD, {alpha: 1}, 0.5);
		FlxTween.tween(camHUD, {alpha: 1}, 0.5);
		FlxTween.tween(camFHUD, {alpha: 1}, 0.5);

		canControlle = true;
	}

	override function update(elapsed:Float){
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if(oldStep != curStep && curStep > 0){stepHit();}

		if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED) && onConfirm != null){MusicBeatState.switchState(Type.createInstance(onConfirm, []));}
		if(principal_controls.checkAction("Menu_Back", JUST_PRESSED) && onBack != null){MusicBeatState.switchState(Type.createInstance(onBack, []));}

		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.P){trace("Assets Reset"); Paths.savedTempMap.clear();}
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.L){trace("Static Scripts Reset"); ModSupport.reload_mods();}
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.M){trace("[Scripts]"); for(s in scripts){trace(s.Name);} trace("[End]");}

		for(s in scripts){s.exFunction('update', [elapsed]);}
		for(shader in FlxCustomShader.shaders){
			if(shader == null){FlxCustomShader.shaders.remove(shader); continue;}
			shader.update(elapsed);
		}

		super.update(elapsed);
	}

	private function updateBeat():Void{curBeat = Math.floor(curStep / 4);}

	private function updateCurStep():Void{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...conductor.bpmChangeMap.length){
			if(conductor.songPosition >= conductor.bpmChangeMap[i].songTime){lastChange = conductor.bpmChangeMap[i];}
		}

		curStep = lastChange.stepTime + Math.floor((conductor.songPosition - lastChange.songTime) / conductor.stepCrochet);
	}

	public function stepHit():Void {
		if(curStep % 4 == 0){beatHit();}

		for(s in scripts){s.exFunction('stepHit', [curStep]);}
	}

	public function beatHit():Void {
		//do literally nothing dumbass

		for(s in scripts){s.exFunction('beatHit', [curBeat]);}
	}

	public function trace(toTrace:String){
		var arrToTrace:Array<String> = toTrace.split("\n");
		for(t in arrToTrace){
			trace('[${Type.getClassName(Type.getClass(this))}]: $t');
		}
	}
	
	override public function onFocus():Void{
		for(s in scripts){s.exFunction('onFocus');}
	}
	override public function onFocusLost():Void{
		for(s in scripts){s.exFunction('onFocusLost');}
	}

	override function openSubState(SubState:FlxSubState){
		for(s in scripts){s.exFunction('openSubState');}

		super.openSubState(SubState);
	}

	override function closeSubState(){
		for(s in scripts){s.exFunction('closeSubState');}

		super.closeSubState();
	}

	public static function switchToCustomState(state:String):Void {
		var nScript = ModSupport.staticScripts.get(state);
		if(nScript != null && nScript.getVariable('CustomState')){FlxG.switchState(new CustomScriptState(nScript));}
	}

	public static function switchState(nextState:FlxState):Void {
		var toSwitch:FlxState = nextState;
		var nScript = ModSupport.staticScripts.get(Type.getClassName(Type.getClass(nextState))); trace(Type.getClassName(Type.getClass(nextState)));
		if(nScript != null && nScript.getVariable('CustomState')){toSwitch = new CustomScriptState(nScript);}
		
		FlxG.switchState(toSwitch);
	}
}
