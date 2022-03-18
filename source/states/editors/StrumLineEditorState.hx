package states.editors;

import StrumLineNote;

import flixel.input.mouse.FlxMouse;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class StrumLineEditorState extends MusicBeatState {
    public static var _strum:StrumLineNoteJSON = null;
    var _file:FileReference = null;

    var strumline:StrumLine = null;
    var image:String = "NOTE_assets";
    var type:String = "Arrows";

    var backStage:Stage = null;

    public static function editStrumLine(strum:StrumLineNoteJSON = null, image:String = null, type:String = null){
        if(strum != null){
            _strum = strum;
        }else{
            _strum = cast Json.parse(Assets.getText(Paths.strumJSON(4)));
        }

        FlxG.switchState(new StrumLineEditorState());
    }

    override function create(){
        FlxG.mouse.visible = true;

        backStage = new Stage();
        add(backStage);

        strumline = new StrumLine(FlxG.width / 6, FlxG.height / 3, 4, FlxG.width / 2);
        strumline.changeGraphic(image, type);
        add(strumline);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        strumline.staticNotes.forEach(function(daStrum:StrumNote){
            if(FlxG.mouse.overlaps(daStrum)){
                if(daStrum.animation.curAnim.name != "confirm"){daStrum.playAnim("pressed");}
                if(FlxG.mouse.justPressed && daStrum.animation.curAnim.name != "confirm"){daStrum.playAnim("confirm");}
            }else{
                daStrum.playAnim("static");
            }
        });
    }
}