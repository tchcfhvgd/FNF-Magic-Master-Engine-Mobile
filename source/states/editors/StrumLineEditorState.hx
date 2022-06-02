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

    private static var image:String = "NOTE_assets";
    private static var typeStrum:String = "Arrows";
    private static var typeNote:String = "Default";
    private static var size:Int = 110;

    var MENU:FlxUITabMenu;

    var baseStrums:StrumStaticNotes;
    var editStrums:StrumStaticNotes;

    var backStage:Stage;

    public static function editStrumLine(strum:StrumLineNoteJSON = null, image:String = null, type:String = null){
        if(strum != null){
            _strum = strum;
        }else{
            _strum = cast Json.parse(Assets.getText(Paths.getStrumJSON(4, typeStrum)));
        }

        FlxG.switchState(new StrumLineEditorState());
    }

    override function create(){
        size = Std.int(FlxG.width / 2);

        FlxG.mouse.visible = true;

        backStage = new Stage();
        add(backStage);

        MENU = new FlxUITabMenu(null, [{name: "General", label: 'General'},{name: "Animation", label: 'Animation'}], true);
        MENU.resize(250, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        addMENUTABS();

        baseStrums = new StrumStaticNotes((((FlxG.width - MENU.width) / 2) - (size / 2)), 150, 4, size);
        editStrums = new StrumStaticNotes((((FlxG.width - MENU.width) / 2) - (size / 2)), 150, 4, size);

        add(baseStrums);
        add(editStrums);

        add(MENU);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        baseStrums.forEach(function(daNote:StrumNote){daNote.alpha = 0.5;});

        if(FlxG.keys.justPressed.ESCAPE){FlxG.switchState(new MainMenuState());}
    }

    public function changeStrumNotes(keys:Int) {
        baseStrums.changeKeys(keys);
        editStrums.changeKeys(keys);
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

        var lblImage = new FlxText(lblKeys.x, lblKeys.y + lblKeys.height + 10, 0, "Image"); tabGENERAL.add(lblImage);
        var ddlImage = new FlxUIDropDownMenu(lblImage.x, lblImage.y + lblImage.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(["NONE"], true)); tabGENERAL.add(ddlImage);
        ddlImage.setSize(500, 30);
        ddlImage.name = "Image";

        var lblTypeImage = new FlxText(ddlImage.x, ddlImage.y + ddlImage.height + 10, 0, "Type Image"); tabGENERAL.add(lblTypeImage);
        var ddlTypeImage = new FlxUIDropDownMenu(lblTypeImage.x, lblTypeImage.y + lblTypeImage.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(["Arrows"], true)); tabGENERAL.add(ddlTypeImage);
        ddlTypeImage.name = "TypeImage";

        var lblTypeNote = new FlxText(ddlTypeImage.x, ddlTypeImage.y + ddlTypeImage.height + 10, 0, "Type Arrow"); tabGENERAL.add(lblTypeNote);
        var ddlTypeNote = new FlxUIDropDownMenu(lblTypeNote.x, lblTypeNote.y + lblTypeNote.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(["Default"], true)); tabGENERAL.add(ddlTypeNote);
        ddlTypeNote.name = "TypeNote";


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