package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import haxe.io.Bytes;
import flixel.FlxG;
import haxe.Timer;

using StringTools;

class DialogueBox extends FlxSpriteGroup {
	public var dialogue_box:FlxSprite;
	public var dialogue_text:Alphabet;
	
	public var dialogue_data:Array<Dynamic> = [];
	public var cur_dialogue:Int = 0;

	public var finishFunc:Void->Void = function(){};
	
	public var script:Script;

	public var controls:Controls;
	public var can_controlle:Bool = false;

	public function new(_data:Array<Dynamic>, ?_script:String){
		this.dialogue_data = data;
		this.controls = MusicBeatState.state.principal_controls;
		super();

		dialogue_box = new FlxSprite();
		loadDialogueBox();
		dialogue_box.alpha = 0;
		add(dialogue_box);

		dialogue_text = new Alphabet(20, 20, []);
		add(dialogue_text);

		if(_script != null){
			script = new Script();
			script.Name = "Dialogue_Script";
			script.exScript(_script);
		}

		FlxTween.tween(dialogue_box, {alpha: 1}, 1, {onComplete: function(){can_controlle = true; nextDialogue();}});
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if(can_controlle){
			if(controls.checkAction("Menu_Accept", JUST_PRESSED)){nextDialogue(1);}
		}
	}

	public function nextDialogue(value:Int = 0, force:Bool = false):Void {
		cur_dialogue += value; if(force){cur_dialogue = value;}

		if(cur_dialogue >= dialogue_data.length){finishFunc(); destroy(); return;}

		if(script != null){script.exFunction("toChangeDialogue", [cur_dialogue]);}
		
		dialogue_text.cur_data = dialogue_data[cur_dialogue];
		dialogue_text.startText();

		if(script != null){script.exFunction("onDialogueChanged", [cur_dialogue]);}
	}

	public function loadDialogueBox(sprite_box:String = "Default_Box"):Void {
		var box_path:String = Paths.image('dialogue_boxes/${sprite_box}', null, true);
		var box_xml_path:String = box_path.replace(".png", ".xml");

		dialogue_box.frames = Paths.getAtlas(box_path);
		
		if(!Paths.exists(box_xml_path)){return;}

		var xml = Xml.parse(Paths.getText(box_xml_path));
		var animSymbols:Array<String> = XMLEditorState.getNamesArray(new Access(xml.firstElement()).elements);

		for(symbol in animSymbols){dialogue_box.animation.addByPrefix(symbol, symbol);}
	}
}