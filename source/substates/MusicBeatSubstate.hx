package substates;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxCamera;

class MusicBeatSubstate extends FlxSubState{
	private var conductor:Conductor = new Conductor();

	public var camSubStates:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	
	private var principal_controls(get, never):Controls;
	inline function get_principal_controls():Controls{return PlayerSettings.getPlayer(0).controls;}

	private function getOtherControls(ID:Int):Controls{return PlayerSettings.getPlayer(ID).controls;}

	private var canControlle:Bool = false;

	public function new(){
		super();

		canControlle = true;
	}

	override function update(elapsed:Float){
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateCurStep():Void{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for(i in 0...conductor.bpmChangeMap.length){
			if(conductor.songPosition > conductor.bpmChangeMap[i].songTime){lastChange = conductor.bpmChangeMap[i];}
		}

		curStep = lastChange.stepTime + Math.floor((conductor.songPosition - lastChange.songTime) / conductor.stepCrochet);
	}

	public function stepHit():Void{
		if(curStep % 4 == 0){beatHit();}
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
