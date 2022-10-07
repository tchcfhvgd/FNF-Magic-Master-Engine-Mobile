package substates;

import Conductor.BPMChangeEvent;
import states.MusicBeatState;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.FlxG;

class MusicBeatSubstate extends FlxSubState{
	public var conductor:Conductor = MusicBeatState.state.conductor;

	public var onClose:Void->Void = function(){};

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curCamera:FlxCamera = new FlxCamera();
	
	public var principal_controls(get, never):Controls;
	inline function get_principal_controls():Controls{return PlayerSettings.getPlayer(0).controls;}
	private function getOtherControls(ID:Int):Controls{return PlayerSettings.getPlayer(ID).controls;}
	public var canControlle:Bool = false;

	public function new(onClose:Void->Void = null){
		if(onClose != null){this.onClose = onClose;}
		curCamera.bgColor = FlxColor.BLACK;
		curCamera.bgColor.alpha = 100;
		FlxG.cameras.add(curCamera);
		super();
	}

	override function update(elapsed:Float){
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if(oldStep != curStep && curStep > 0){stepHit();}


		super.update(elapsed);
	}

	private function updateCurStep():Void{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for(i in 0...conductor.bpmChangeMap.length){if(conductor.songPosition > conductor.bpmChangeMap[i].songTime){lastChange = conductor.bpmChangeMap[i];}}
		curStep = lastChange.stepTime + Math.floor((conductor.songPosition - lastChange.songTime) / conductor.stepCrochet);
	}

	public function stepHit():Void{if(curStep % 4 == 0){beatHit();}}

	public function beatHit():Void{
		//do literally nothing dumbass
	}

	override function close():Void {
		onClose();
		FlxG.cameras.remove(curCamera);
		curCamera.destroy();
		super.close();
	}

	override function destroy(){		
		super.destroy();
	}
}
