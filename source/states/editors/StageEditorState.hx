package states.editors;

import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUITabMenu;
import openfl.filters.ShaderFilter;
import flixel.system.FlxSoundGroup;
import openfl.events.IOErrorEvent;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxArrayUtil;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUI;
import flixel.system.FlxSound;
import openfl.utils.ByteArray;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import openfl.events.Event;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import openfl.media.Sound;
import lime.ui.FileDialog;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import haxe.xml.Access;
import flixel.FlxG;
import haxe.Json;

import Character.AnimArray;
import Character.CharacterFile;
import FlxCustom.FlxCustomShader;
import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomNumericStepper;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class StageEditorState extends MusicBeatState{
    public static var SCRIPT_SOURCE:StageScripManager;
    
    public var stage:Stage;

    var MENU:FlxUITabMenu;
    var LAYERS:FlxUITabMenu;

    var arrayFocus:Array<FlxUIInputText> = [];

    var camObjects:FlxCamera;
    var camFollow:FlxObject;

    override function create(){
        if(SCRIPT_SOURCE == null){SCRIPT_SOURCE = getStageTemplate();}

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Editing Stage', '[Stage Editor]');
		MagicStuff.setWindowTitle('Editing...', 1);
		#end
        
        FlxG.mouse.visible = true;
        
        var bgGrid:FlxSprite = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height, true, 0xff4d4d4d, 0xff333333);
        bgGrid.cameras = [camGame];
        add(bgGrid);

        stage = new Stage("Stage", []);
        stage.loadStageByScriptSource(SCRIPT_SOURCE.buildSource());
        stage.cameras = [camFGame];
        add(stage);
        
        LAYERS = new FlxUITabMenu(null, [{name: "1Layers", label: 'Object List'}], true);
        LAYERS.resize(50, Std.int(FlxG.height));
		LAYERS.x = FlxG.width - LAYERS.width;
        LAYERS.camera = camHUD;
        add(LAYERS);
        LAYERS.showTabId("1Layers");
        
        var menuTabs = [
            {name: "1Layers", label: 'Object Settings'},
            {name: "2Stage", label: 'Stage'},
        ];
        MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(250, Std.int(FlxG.height));
		MENU.x = FlxG.width - LAYERS.width - MENU.width;
        MENU.camera = camHUD;
        addMENUTABS();
        add(MENU);
        
        super.create();

        camObjects = new FlxCamera(Std.int(LAYERS.x + 10), Std.int(LAYERS.y + 30), Std.int(LAYERS.width - 20), Std.int(LAYERS.height - 40));
		camObjects.bgColor.alpha = 0;
		FlxG.cameras.add(camObjects);

        var adw:FlxSprite = new FlxSprite().makeGraphic(30, 30, FlxColor.WHITE);
        adw.cameras = [camObjects];
        add(adw);

		camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.screenCenter();
        camFGame.follow(camFollow, LOCKON);
		add(camFollow);        
    }

    private function getStageTemplate():StageScripManager {
        var toReturn:StageScripManager = new StageScripManager();

        toReturn.packages.set("FlxPoint", "flixel.math.FlxPoint");
        toReturn.packages.set("FlxSprite", "flixel.FlxSprite");

        toReturn.packages.set("Paths", "Paths");
        toReturn.packages.set("PreSettings", "PreSettings");

        toReturn.variables.push({id: "addToLoad", value:"function(list:Array<Dynamic>){}", isPresset: true, type:null});
        toReturn.variables.push({id: "initChar", value:"1", isPresset: true, type:null});
        toReturn.variables.push({id: "zoom", value:"0.9", isPresset: true, type:null});
        toReturn.variables.push({id: "camP_1", value:"new FlxPoint(400, 250)", isPresset: true, type:null});
        toReturn.variables.push({id: "camP_2", value:"new FlxPoint(900, 600)", isPresset: true, type:null});

        var sdaw:StageObjectScript = new StageObjectScript("sin");
        sdaw.parseTemplate(Paths.txt("stage_editor_objects/sprite_object"));
        toReturn.addTemplate(sdaw);
    
        return toReturn;
    }

    var pos = [[], []];
    override function update(elapsed:Float){
        var pMouse = FlxG.mouse.getPositionInCameraView(camFGame);

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){    
            if(FlxG.mouse.justPressedRight){pos = [[camFollow.x, camFollow.y],[pMouse.x, pMouse.y]];}
            if(FlxG.mouse.pressedRight){camFollow.setPosition(pos[0][0] + ((pos[1][0] - pMouse.x) * 1.0), pos[0][1] + ((pos[1][1] - pMouse.y) * 1.0));}

            if(FlxG.keys.pressed.SHIFT){
                if(FlxG.mouse.wheel != 0){
                    if(FlxG.mouse.overlaps(LAYERS)){
                        camObjects.scroll.y += FlxG.mouse.wheel * 2;
                    }else{
                        camFGame.zoom += (FlxG.mouse.wheel * 0.1);
                    }
                }
            }else{
                if(FlxG.mouse.overlaps(LAYERS)){
                    camObjects.scroll.y += FlxG.mouse.wheel * 2;
                }else{
                    camFGame.zoom += (FlxG.mouse.wheel * 0.01);
                }
            }

            if(FlxG.mouse.justPressedMiddle){camFollow.screenCenter();}
        }

        if(camObjects.scroll.y < 0){camObjects.scroll.y = 0;}
        
        super.update(elapsed);
    
    }

    var txtSong:FlxUIInputText;
    private function addMENUTABS(){
        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "2Stage";

        var lblStage = new FlxText(5, 15, 0, "STAGE:", 8); tabMENU.add(lblStage);
        txtSong = new FlxUIInputText(lblStage.x + lblStage.width + 5, lblStage.y, Std.int(MENU.width - lblStage.width - 20), 'Stage', 8); tabMENU.add(txtSong);
        arrayFocus.push(txtSong);
        txtSong.name = "STAGE_NAME";

        var btnSaveStage:FlxButton = new FlxCustomButton(lblStage.x, lblStage.y + lblStage.height + 5, Std.int((MENU.width / 2) - 10), null, "Save Stage", null, null, function(){
            
        }); tabMENU.add(btnSaveStage);
        var btnSaveStageAs:FlxButton = new FlxCustomButton(btnSaveStage.x + btnSaveStage.width + 10, btnSaveStage.y, Std.int((MENU.width / 2) - 10), null, "Save Song As", null, null, function(){
            
        }); tabMENU.add(btnSaveStageAs);

        var btnLoad:FlxButton = new FlxCustomButton(btnSaveStage.x, btnSaveStage.y + btnSaveStage.height + 5, Std.int((MENU.width / 2) - 10), null, "Load Stage", null, null, function(){

        }); tabMENU.add(btnLoad);
        var btnImport:FlxButton = new FlxCustomButton(btnLoad.x + btnLoad.width + 10, btnLoad.y, Std.int((MENU.width / 2) - 10), null, "Import Stage", null, null, function(){
                
        }); tabMENU.add(btnImport);

        var line0 = new FlxSprite(5, btnLoad.y + btnLoad.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line0);

        var ttlGeneralVariables:FlxText = new FlxText(0, line0.y + 5, MENU.width, "GLOBAL STAGE VALUES", 16); ttlGeneralVariables.alignment = CENTER; tabMENU.add(ttlGeneralVariables);

        ////////////////////////////////////////////////////////////
        MENU.addGroup(tabMENU);
        ////////////////////////////////////////////////////////////



        MENU.showTabId("2Stage");
    }
    
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch(label){
                default:{trace('$label WORKS!');}
			}
		}else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;
            switch(wname){
                default:{trace('$wname WORKS!');}
            }
        }else if(id == FlxUIDropDownMenu.CLICK_EVENT && (sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;
            switch(wname){
                default:{trace('$wname WORKS!');}
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
            switch(wname){
                default:{trace('$wname WORKS!');}
            }
        }else if(id == FlxUICustomList.CHANGE_EVENT && (sender is FlxUICustomList)){
            var list:FlxUICustomList = cast sender;
			var wname = list.name;
            switch(wname){
                default:{trace('$wname WORKS!');}
            }
        }
    }
}

class StageScripManager {
    public var packages:Map<String, Dynamic> = [];
    public var variables:Array<{id:String, value:String, type:String, isPresset:Bool}> = [];
    public var objects:Array<StageObjectScript> = [];

    public function new():Void {}
    
    public function buildSource():String {
        var toReturn:String = "";

        for(key in packages.keys()){toReturn += 'import("${packages[key]}", "${key}");\n';}
        toReturn += '\n';
        for(v in variables){toReturn += '${v.isPresset ? ('presset("${v.id}", ${v.value});') : ('var ${v.id}${v.type != null ? ':${v.type}' : ''} = ${v.value}')}\n';}
        toReturn += '\n';
        toReturn += 'function create(){\n';
        for(obj in objects){toReturn += '${obj.buildSource()}\n';}
        toReturn += '\n}';
        toReturn += '\n';


        trace('\n$toReturn');
        return toReturn;
    }

    public function addTemplate(tmp:StageObjectScript){
        for(p in tmp.packages.keys()){packages.set(p, tmp.packages[p]);}
        
        objects.push(tmp);
    }
}

class StageObjectScript {
    public var value_types:Map<String, String> = [];

    public var packages:Map<String, Dynamic> = [];
    private var variables:Map<String, Dynamic> = [];
    private var source:String = '';

    public var name:String = "";

    public function new(name:String){
        this.name = name;
    }

    public function parseTemplate(_src:String):Void {
        variables.clear();
        source = '';

        var src:String = cast(_src, String);
        src.replace('a', 'JAJAJAJA');
        trace(src);
    }

    public function buildSource():String {
        var toReturn:String = '\n//-<${name}>-//\n${source}\n//->${name}<-//';
        for(v in variables.keys()){toReturn.replace('#${v}#', variables[v]);}
        trace(toReturn);
        return toReturn;
    }

    public function getVariableValue(key:String):Dynamic {
        if(variables.exists(key)){return variables[key];}
        trace('($key) Variable not Parsed');
        return null;
    };

    public function setValueToVariable(key:String, value:Dynamic):Void {
        if(variables.exists(key)){variables[key] = value; return;}
        
        trace("($key) Variable not Parsed");
    };
}