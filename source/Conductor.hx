package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public var bpm:Float = 100;
	public var crochet:Float = 0; // beats in milliseconds
	public var stepCrochet:Float = 0; // steps in milliseconds
	public var songPosition:Float;
	public var lastSongPos:Float;
	public var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new(bpm:Int = 100){
		this.bpm = bpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public function mapBPMChanges(song:SwagSong){
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.generalSection.length){
			if(song.generalSection[i].changeBPM && song.generalSection[i].bpm != curBPM){
				curBPM = song.generalSection[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.generalSection[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public function changeBPM(newBpm:Float){
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public function getCurStep():Int {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		
		for(i in 0...bpmChangeMap.length){
			if(songPosition >= bpmChangeMap[i].songTime){lastChange = bpmChangeMap[i];}
		}

		return lastChange.stepTime + Math.floor((songPosition - lastChange.songTime) / stepCrochet);
	}
}
