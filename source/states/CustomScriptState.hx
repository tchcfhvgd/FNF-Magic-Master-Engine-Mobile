package states;

import states.editors.CharacterEditorState;
import states.editors.XMLEditorState;
import flixel.input.mouse.FlxMouse;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.FlxState;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class CustomScriptState extends MusicBeatState {
    public var SCRIPT:Script = null;

	override function get_script():Script {return SCRIPT;}

    public function new(nScript:Script = null, ?onConfirm:Class<FlxState>, ?onBack:Class<FlxState>):Void {
        if(nScript != null){SCRIPT = nScript;}
        super(onConfirm, onBack);
    }
}
