package states;

import haxe.rtti.CType.Abstractdef;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.FlxObject;

class MusicBeatState extends FlxUIState {
	private var conductor:Conductor = new Conductor();

	public var onBack:FlxState;
	public var onConfirm:FlxState;
	
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var principal_controls(get, never):Controls;
	inline function get_principal_controls():Controls{return PlayerSettings.getPlayer(0).controls;}

	private function getOtherControls(ID:Int):Controls{return PlayerSettings.getPlayer(ID).controls;}
	private var canControlle:Bool = false;

	private var script(get, never):Script;
	inline function get_script():Script{
		if(ModSupport.exScripts.contains(Type.getClassName(Type.getClass(this)))){return null;}
		return ModSupport.StScripts.get(Type.getClassName(Type.getClass(this)));
	}

	private var camGame:FlxCamera = new FlxCamera();
	private var camFGame:FlxCamera = new FlxCamera();
	private var camBHUD:FlxCamera = new FlxCamera();
	private var camHUD:FlxCamera = new FlxCamera();
	private var camFHUD:FlxCamera = new FlxCamera();
	
	public function new(?onConfirm:FlxState, ?onBack:FlxState){
		this.onBack = onBack;
		this.onConfirm = onConfirm;

		for(spt in ModSupport.tempScripts){spt.setVariable('getState', function(){return this;});}
		if(script != null){
			script.setVariable('getState', function(){return this;});
			script.execute();
		}

		super();
	}

	override function create(){
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

		if(script != null){script.exFunction('create');}
		super.create();

		canControlle = true;
	}

	override function update(elapsed:Float){
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if(oldStep != curStep && curStep > 0){stepHit();}
		
		if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED) && onConfirm != null){FlxG.switchState(onConfirm);}
		if(principal_controls.checkAction("Menu_Back", JUST_PRESSED) && onBack != null){FlxG.switchState(onBack);}
		
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.P){trace("Assets Reset"); Paths.savedMap.clear();}

		if(script != null){script.exFunction('update', [elapsed]);}
		for(spt in ModSupport.tempScripts){spt.exFunction('update', [elapsed]);}
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

		if(script != null){script.exFunction('stepHit', [curStep]);}
		for(spt in ModSupport.tempScripts){spt.exFunction('stepHit', [curStep]);}
	}

	public function beatHit():Void {
		//do literally nothing dumbass

		if(script != null){script.exFunction('beatHit', [curBeat]);}
		for(spt in ModSupport.tempScripts){spt.exFunction('beatHit', [curBeat]);}
	}

	override function openSubState(SubState:FlxSubState){
		canControlle = false;	
		super.openSubState(SubState);
	}

	override function closeSubState(){
		canControlle = true;	
		super.closeSubState();
	}

	public function trace(toTrace:String){
		var arrToTrace:Array<String> = toTrace.split("\n");
		for(t in arrToTrace){
			trace('[${Type.getClassName(Type.getClass(this))}]: $t');
		}
	}
	
	override public function onFocus():Void{
		if(script != null){script.exFunction('onFocus');}
		for(spt in ModSupport.tempScripts){spt.exFunction('onFocus');}
	}
	override public function onFocusLost():Void{
		if(script != null){script.exFunction('onFocusLost');}
		for(spt in ModSupport.tempScripts){spt.exFunction('onFocusLost');}
	}
}
