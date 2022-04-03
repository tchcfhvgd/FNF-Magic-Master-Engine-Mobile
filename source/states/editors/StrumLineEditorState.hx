package states.editors;

import FlxCustom.FlxUINumericStepperCustom;

import Section.SwagSection;
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

    var strums:StrumLine = null;

    public static var image:String = "NOTE_assets";
    public static var typeStrum:String = "Arrows";
    public static var typeNote:String = "Default";

    public var curStrum:Int = 0;
    public var curAnim:String = "static";

    var MENU:FlxUITabMenu;

    var backStage:Stage = null;

    public static function editStrumLine(strum:StrumLineNoteJSON = null, image:String = null, type:String = null){
        if(strum != null){
            _strum = strum;
        }else{
            _strum = cast Json.parse(Assets.getText(Paths.strumJSON(4, typeStrum)));
        }

        FlxG.switchState(new StrumLineEditorState());
    }

    var testNote:StrumNote;
    var back:FlxSprite;
    override function create(){
        Conductor.songPosition = 0;

        FlxG.mouse.visible = true;

        backStage = new Stage();
        add(backStage);

        MENU = new FlxUITabMenu(null, [{name: "General", label: 'General'}], true);
        MENU.resize(250, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        addMENUTABS();

        strums = new StrumLine((((FlxG.width - MENU.width) / 2) - (FlxG.width / 4)), 50, 4, (FlxG.width / 2));
        strums.typeStrum = "Playing";
        //add(strums);

        testNote = new StrumNote(_strum.staticNotes[0]); testNote.setPosition(100, 100);
        back = new FlxSprite(testNote.x, testNote.y).makeGraphic(Std.int(testNote.width), Std.int(testNote.height));

        add(back);
        add(testNote);

        changeStrumNotes(4);

        add(MENU);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        strums.staticNotes.forEach(function (daStrum:StrumNote) {
            daStrum.alpha = 0.2;
            if(daStrum.ID == curStrum){
                daStrum.alpha += 0.3;

                if(daStrum.animation.curAnim.name == curAnim){
                    daStrum.alpha += 0.3;
                }
            }
        });

        if(testNote.animation.finished && testNote.animation.curAnim.name != "static"){
            testNote.playAnim("static");
        }

        if(FlxG.keys.pressed.SHIFT){
            if(FlxG.keys.justPressed.SPACE){testNote.playAnim("confirm");}
        }else{
            if(FlxG.keys.justPressed.SPACE){testNote.playAnim("pressed");}
        }
        
        if(FlxG.keys.pressed.E){testNote.setGraphicSize(Std.int(testNote.width += 5), Std.int(testNote.height += 5));}
        if(FlxG.keys.pressed.Q){testNote.setGraphicSize(Std.int(testNote.width -= 5), Std.int(testNote.height -= 5));}

        if(Controls.getBind("Menu_Back", "JUST_PRESSED")){FlxG.switchState(new MainMenuState());}
    }

    public function changeStrumNotes(keys:Int) {
        //strums.changeKeyNumber(keys, (FlxG.width / 2));
    }

    var stpKeys:FlxUINumericStepperCustom;
    function addMENUTABS():Void{
        var tabGENERAL = new FlxUI(null, MENU);
        tabGENERAL.name = "General";

        var lblGeneral = new FlxText(5, 5, MENU.width - 10, "General Options"); tabGENERAL.add(lblGeneral);
        lblGeneral.alignment = CENTER;

        var lblKeys = new FlxText(lblGeneral.x, lblGeneral.y + lblGeneral.height + 10, 0, "KEYS: ", 8); tabGENERAL.add(lblKeys);
        stpKeys = new FlxUINumericStepperCustom(lblKeys.x + lblKeys.width, lblKeys.y, 1, 4, 1, 10); tabGENERAL.add(stpKeys);
        stpKeys.name = "STRUMSEC_KEYS";

        MENU.addGroup(tabGENERAL);

        MENU.scrollFactor.set();
        MENU.showTabId("General");
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch(label){
				
			}
		}else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;
            switch(wname){
                
            }
        }else if(id == FlxUIDropDownMenu.CLICK_EVENT && (sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;
            switch(wname){
                
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
            switch(wname){
                case "STRUMSEC_KEYS":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value > 10){nums.value = 10;}

                    changeStrumNotes(Std.int(nums.value));
                }
            }
        }
    }
}