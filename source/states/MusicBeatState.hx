package states;

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

	private var camGame:FlxCamera = new FlxCamera();
	private var camFGame:FlxCamera = new FlxCamera();
	private var camBHUD:FlxCamera = new FlxCamera();
	private var camHUD:FlxCamera = new FlxCamera();
	private var camFHUD:FlxCamera = new FlxCamera();
	private var camSubStates:FlxCamera = new FlxCamera();

	public function new(?onConfirm:FlxState, ?onBack:FlxState){
		this.onBack = onBack;
		this.onConfirm = onConfirm;

		super();
	}

	override function create(){
		if(transIn != null){trace('reg ' + transIn.region);}

		camFGame.bgColor.alpha = 0;
		camBHUD.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camFHUD.bgColor.alpha = 0;
		camSubStates.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camFGame);
		FlxG.cameras.add(camBHUD);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camFHUD);
		FlxG.cameras.add(camSubStates);

		FlxCamera.defaultCameras = [camGame];

		super.create();

		canControlle = true;
	}

	override function update(elapsed:Float){
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if(oldStep != curStep && curStep > 0){stepHit();}

		if(onBack != null && principal_controls.checkAction("Menu_Back", JUST_PRESSED)){FlxG.switchState(onBack);}
		if(onConfirm != null && principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){FlxG.switchState(onConfirm);}

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
		if (curStep % 4 == 0){beatHit();}
	}

	public function beatHit():Void {
		//do literally nothing dumbass
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
			trace(' | $t');
		}
	}
	
	override public function onFocus():Void{}
	override public function onFocusLost():Void{}
}
