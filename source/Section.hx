package;

typedef SwagSection = {
	var charToSing:Array<Int>;
	var changeSing:Bool;


	var altAnim:Bool;

	var sectionNotes:Array<Dynamic>;
}

typedef SwagGeneralSection = {
	var bpm:Float;
	var changeBPM:Bool;
	
	var lengthInSteps:Int;

	var strumToFocus:Int;
	var charToFocus:Int;
}