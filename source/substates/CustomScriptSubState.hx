package substates;

import Script;

class CustomScriptSubState extends MusicBeatSubstate {
    public var custom_script:Script;

	override function get_script():Script {return custom_script;}

    public function new(new_script:Script, onClose:Void->Void = null):Void {
        custom_script = new_script;
        super(onClose);
    }
}
