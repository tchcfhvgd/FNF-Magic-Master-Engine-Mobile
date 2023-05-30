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
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUIButton;
import openfl.filters.ShaderFilter;
import flixel.system.FlxSoundGroup;
import flixel.addons.ui.FlxUIGroup;
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
import flash.geom.Rectangle;
import flixel.text.FlxText;
import openfl.events.Event;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import openfl.media.Sound;
import lime.ui.FileDialog;
import haxe.DynamicAccess;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import haxe.xml.Access;
import flixel.FlxG;
import haxe.Json;

import Song.SaverMaster;
import Character.AnimArray;
import Character.CharacterFile;
import FlxCustom.FlxCustomShader;
import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomNumericStepper;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class StageEditorState extends MusicBeatState {
    public static var SCRIPT_SOURCE:StageScripManager;
    
    public var stage:Stage;
    public var canReload:Bool = false;
    private var reload:FlxText;

    var template_list:FlxUIGroup;
    var stage_objects_list:FlxUIGroup;
    var global_variable_gp:FlxUIGroup;
    var object_settings_gp:FlxUI;
    var current_object:StageObjectScript;

    var OBJECTS:FlxUITabMenu;
    var MENU:FlxUITabMenu;
    var LAYERS:FlxUITabMenu;

    var camera_sprite:FlxSprite;

    var arrayFocus:Array<FlxUIInputText> = [];

    var camFollow:FlxObject;

    override function create(){
        if(SCRIPT_SOURCE == null){SCRIPT_SOURCE = new StageScripManager();}
        if(FlxG.sound.music != null){FlxG.sound.music.stop();}

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Editing Stage', '[Stage Editor]');
		MagicStuff.setWindowTitle('Editing...', 1);
		#end
        
        FlxG.mouse.visible = true;
        
        var bgGrid:FlxSprite = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height, true, 0xff4d4d4d, 0xff333333);
        bgGrid.cameras = [camGame];
        add(bgGrid);

        stage = new Stage("Stage", [
            ["Girlfriend", [540, 50], 1, false, "Default", "GF", 0],
            ["Daddy_Dearest", [100, 100], 1, true, "Default", "NORMAL", 0],
            ["Boyfriend", [770, 100], 1, false, "Default", "NORMAL", 0]
        ]);
        stage.loadStageByScriptSource(SCRIPT_SOURCE.buildSource());
        stage.showCamPoints = true;
        stage.cameras = [camFGame];
        add(stage);
        
        for(char in stage.characterData){char.alpha = 0.5;}

        OBJECTS = new FlxUITabMenu(null, [{name: "1Objects", label: ''}], true);
        OBJECTS.resize(35, Std.int(FlxG.height));
        OBJECTS.camera = camHUD;
        addOBJECTSTABS();
        add(OBJECTS);
        
        LAYERS = new FlxUITabMenu(null, [{name: "1Layers", label: ''}], true);
        LAYERS.resize(50, Std.int(FlxG.height));
		LAYERS.x = FlxG.width - LAYERS.width;
        LAYERS.camera = camHUD;
        addLAYERSTABS();
        add(LAYERS);
        
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

        camera_sprite = new FlxSprite().loadGraphic(Paths.image("camera_border"));
        camera_sprite.scrollFactor.set(0,0);
        camera_sprite.cameras = [camFGame];
        camera_sprite.antialiasing = false;
        camera_sprite.alpha = 0.5;
        add(camera_sprite);

        reload = new FlxText(0,0,0,"You can Reload! [SPACE]", 16);
        reload.cameras = [camFHUD];
        reload.alpha = 0;
        add(reload);
        
        super.create();
        
		camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.screenCenter();
        camFGame.follow(camFollow, LOCKON);
		add(camFollow);        
    }

    var pos = [[], []];
    override function update(elapsed:Float){
        var pMouse = FlxG.mouse.getPositionInCameraView(camFGame);

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){    
            if(FlxG.mouse.justPressedRight){pos = [[camFollow.x, camFollow.y],[pMouse.x, pMouse.y]];}
            if(FlxG.mouse.pressedRight){camFollow.setPosition(pos[0][0] + ((pos[1][0] - pMouse.x) * 1.0), pos[0][1] + ((pos[1][1] - pMouse.y) * 1.0));}

            if(FlxG.mouse.overlaps(OBJECTS)){
                if((FlxG.mouse.wheel > 0 && template_list.y < FlxG.height - 40) || (FlxG.mouse.wheel < 0 && template_list.y + template_list.height > 45)){
                    template_list.y += FlxG.mouse.wheel * 5;
                }
            }else if(FlxG.mouse.overlaps(LAYERS)){
                if((FlxG.mouse.wheel > 0 && stage_objects_list.y < FlxG.height - 40) || (FlxG.mouse.wheel < 0 && stage_objects_list.y + stage_objects_list.height > 45)){
                    stage_objects_list.y += FlxG.mouse.wheel * 5;
                }
            }else if(FlxG.mouse.overlaps(MENU)){
                if((FlxG.mouse.wheel > 0 && object_settings_gp.y < FlxG.height - 40) || (FlxG.mouse.wheel < 0 && object_settings_gp.y + object_settings_gp.height > 45)){
                    object_settings_gp.y += FlxG.mouse.wheel * 5;
                }
            }else{
                if(FlxG.keys.pressed.SHIFT){
                    if(FlxG.mouse.justPressedMiddle){camFGame.zoom = stage.zoom;}
                    if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.1);}
                }else{
                    if(FlxG.mouse.justPressedMiddle){camFollow.screenCenter();}
                    if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.01);}
                }
            }

            if(canReload && FlxG.keys.justPressed.SPACE){reloadStage();}
        }

        if(canReload){
            reload.setPosition(FlxG.mouse.screenX - (reload.width / 2), FlxG.mouse.screenY - reload.height);
            reload.alpha = canReload ? 1 : 0;
        }        
        
        super.update(elapsed);
    
    }

    public function reloadStage():Void {
        stage.loadStageByScriptSource(SCRIPT_SOURCE.buildSource());
        canReload = false;
        reload.alpha = 0;

        camera_sprite.scale.x = camera_sprite.scale.y = camHUD.zoom / stage.zoom;
        camera_sprite.screenCenter();
    }

    public function reload_templates():Void {
        template_list.clear();

        var last_height:Float = 0;
        for(i in Paths.readDirectory('assets/data/stage_editor_objects')){
            if('$i'.contains(".")){continue;}
            var object_name:String = '$i';
            var template_obj:FlxUIButton = new FlxUICustomButton(0, last_height,Std.int(OBJECTS.width - 10), Std.int(OBJECTS.width - 10), "", Paths.image('stage_editor_objects/${object_name}', null, true), null, function(){
                SCRIPT_SOURCE.addTemplate(new StageObjectScript(object_name));
                reload_stage_objects();
                canReload = true;
            });
            template_list.add(template_obj);

            last_height += template_obj.height + 5;
        }
    }

    public function reload_stage_objects():Void {
        stage_objects_list.clear();

        SCRIPT_SOURCE.objects.sort((a, b) -> (a.ID - b.ID));

        var last_height:Float = 0;
        for(tmp in SCRIPT_SOURCE.objects){
            var template_obj:FlxUIButton = new FlxUICustomButton(0,last_height, Std.int(LAYERS.width - 10), Std.int(LAYERS.width - 10), "", Paths.image('stage_editor_objects/${tmp.name}', null, true), null, function(){loadObjectSettings(tmp);});
            stage_objects_list.add(template_obj);

            last_height += template_obj.height + 5;
        }
    }

    public function loadVariableSettings():Void {
        global_variable_gp.clear();

        var last_height:Float = 0;
        for(i in 0...SCRIPT_SOURCE.variables.length){
            var vari:Dynamic = SCRIPT_SOURCE.variables[i];

            var txtVariableName = new FlxUIInputText(0, last_height, Std.int(MENU.width - 30), vari.id, 8, 0x000000);
            txtVariableName.name = 'global_variable:${i}:id';
            arrayFocus.push(txtVariableName);
            global_variable_gp.add(txtVariableName);

            var btnDeleteVariable = new FlxUICustomButton(txtVariableName.width, last_height, 20, 15, "-", 0xff3d3d, function(){
                SCRIPT_SOURCE.variables.remove(SCRIPT_SOURCE.variables[i]);
                loadVariableSettings();
                canReload = true;
            }); global_variable_gp.add(btnDeleteVariable);

            last_height += txtVariableName.height;

            switch(vari.type){
                default:{
                    var chkCurrent_Variable = new FlxUICheckBox(0, last_height, null, null, vari.id);
                    chkCurrent_Variable.checked = vari.value == "true";
                    chkCurrent_Variable.name = 'global_variable:${i}';
                    global_variable_gp.add(chkCurrent_Variable);
                    last_height += chkCurrent_Variable.height + 5;
                }
                case 'Float':{
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(0, last_height, Std.int(MENU.width - 10), 0.1, Std.parseFloat(vari.value), -999, 999, 3);
                    stpCurrent_Variable.name = 'global_variable:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    global_variable_gp.add(stpCurrent_Variable);
                    last_height += stpCurrent_Variable.height + 5;
                }
                case 'Int':{
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(0, last_height, Std.int(MENU.width - 10), 1, Std.parseInt(vari.value));
                    stpCurrent_Variable.name = 'global_variable:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    global_variable_gp.add(stpCurrent_Variable);
                    last_height += stpCurrent_Variable.height + 5;
                }
                case 'String':{
                    var data:String = ''; try{data = Json.stringify(vari.value);}catch(e){trace(e); data = '""';}
                    var txtCurrent_Variable = new FlxUIInputText(0, last_height, Std.int(MENU.width - 10), Std.string(vari.value), 8);
                    txtCurrent_Variable.name = 'global_variable:${i}:string';
                    arrayFocus.push(txtCurrent_Variable);
                    global_variable_gp.add(txtCurrent_Variable); 
                    last_height += txtCurrent_Variable.height + 5;
                }
                case 'Array':{
                    var data:String = ""; try{data = Json.stringify(Json.parse('{ "Events": ${vari.value}}').Events);}catch(e){trace(e); data = "[]";}
                    var txtCurrent_Variable = new FlxUIInputText(0, last_height, Std.int(MENU.width - 10), data, 8);
                    txtCurrent_Variable.name = 'global_variable:${i}:array';
                    arrayFocus.push(txtCurrent_Variable);
                    global_variable_gp.add(txtCurrent_Variable);
                    last_height += txtCurrent_Variable.height + 5;
                }
            }
        }
    }

    function loadObjectSettings(tmp:StageObjectScript):Void {
        current_object = tmp;
        object_settings_gp.clear();
        var last_menu_height:Float = 10;

        var lblTtlObject = new FlxText(5, last_menu_height, Std.int(MENU.width - 10), Paths.getFileName(tmp.name), 16); object_settings_gp.add(lblTtlObject); lblTtlObject.alignment = CENTER; last_menu_height += lblTtlObject.height + 10;

        var btnDeleteObject = new FlxUICustomButton(5, last_menu_height, Std.int(MENU.width - 10), null, "Delete Object", 0xf0ff4a4a, function(){
            SCRIPT_SOURCE.objects.remove(tmp);
            reload_stage_objects();
            canReload = true;
        }); object_settings_gp.add(btnDeleteObject); last_menu_height += btnDeleteObject.height + 10;

        var btnMoveUp = new FlxUICustomButton(5, last_menu_height, Std.int((MENU.width - 10) / 2), null, "Move up", null, function(){
            var new_id:Int = tmp.ID - 1; if(new_id < 0){new_id = SCRIPT_SOURCE.objects.length - 1;}
            
            SCRIPT_SOURCE.objects[new_id].ID = tmp.ID;
            tmp.ID = new_id;
            
            reload_stage_objects();

            canReload = true;
        }); object_settings_gp.add(btnMoveUp);

        var btnMoveDown = new FlxUICustomButton(5 + btnMoveUp.width + 3, last_menu_height, Std.int((MENU.width - 10) / 2), null, "Move Down", null, function(){
            var new_id:Int = tmp.ID + 1; if(new_id >= SCRIPT_SOURCE.objects.length){new_id = 0;}
            
            SCRIPT_SOURCE.objects[new_id].ID = tmp.ID;
            tmp.ID = new_id;
            
            reload_stage_objects();
            
            canReload = true;
        }); object_settings_gp.add(btnMoveDown); last_menu_height += btnMoveUp.height + 10;

        var clAttList = new FlxUICustomList(5, last_menu_height, Std.int(MENU.width - 55), tmp.possible_attributes); object_settings_gp.add(clAttList);
        var btnAddAtt = new FlxUICustomButton(5 + clAttList.width + 5, last_menu_height, 20, null, "+", null, 0x93ff79, function(){tmp.addAttribute(clAttList.getSelectedLabel()); loadObjectSettings(tmp); canReload = true;}); object_settings_gp.add(btnAddAtt);
        var btnDelAtt = new FlxUICustomButton(10 + clAttList.width + btnAddAtt.width, last_menu_height, 20, null, "-", null, 0xff4747, function(){tmp.removeAttribute(clAttList.getSelectedLabel()); loadObjectSettings(tmp); canReload = true;}); object_settings_gp.add(btnDelAtt);
        last_menu_height += clAttList.height + 10;

        for(vari in tmp.getValueTypeList()){                    
            switch(tmp.getValueType(vari)){
                default:{
                    var check_bool:Bool = tmp.getVariableValue(vari);
                    var chkCurrent_Variable = new FlxUICheckBox(5, last_menu_height, null, null, Paths.getFileName(vari));
                    chkCurrent_Variable.checked = tmp.getVariableValue(vari);
                    chkCurrent_Variable.name = 'current_variable:${vari}';
                    object_settings_gp.add(chkCurrent_Variable); last_menu_height += chkCurrent_Variable.height + 5;
                }
                case 'float':{
                    var lblName_Object = new FlxText(5, last_menu_height, Std.int(MENU.width - 10), '${Paths.getFileName(vari)}: ', 10); lblName_Object.alignment = CENTER; object_settings_gp.add(lblName_Object); last_menu_height += lblName_Object.height + 5;
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(5, last_menu_height, Std.int(MENU.width - 10), 0.1, tmp.getVariableValue(vari), -999, 999, 3);
                    stpCurrent_Variable.name = 'current_variable:${vari}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    object_settings_gp.add(stpCurrent_Variable); last_menu_height += stpCurrent_Variable.height + 5;
                }
                case 'int':{
                    var lblName_Object = new FlxText(5, last_menu_height, Std.int(MENU.width - 10), '${Paths.getFileName(vari)}: ', 10); lblName_Object.alignment = CENTER; object_settings_gp.add(lblName_Object); last_menu_height += lblName_Object.height + 5;
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(5, last_menu_height, Std.int(MENU.width - 10), 1, tmp.getVariableValue(vari));
                    stpCurrent_Variable.name = 'current_variable:${vari}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    object_settings_gp.add(stpCurrent_Variable); last_menu_height += stpCurrent_Variable.height + 5;
                }
                case 'string':{
                    var lblName_Object = new FlxText(5, last_menu_height, Std.int(MENU.width - 10), '${Paths.getFileName(vari)}: ', 10); lblName_Object.alignment = CENTER; object_settings_gp.add(lblName_Object); last_menu_height += lblName_Object.height + 5;
                    var txtCurrent_Variable = new FlxUIInputText(5, last_menu_height, Std.int(MENU.width - 10), tmp.getVariableValue(vari), 10);
                    txtCurrent_Variable.name = 'current_variable:${vari}:string';
                    arrayFocus.push(txtCurrent_Variable);
                    object_settings_gp.add(txtCurrent_Variable); last_menu_height += txtCurrent_Variable.height + 5;
                }
                case 'array':{
                    var lblName_Object = new FlxText(5, last_menu_height, Std.int(MENU.width - 10), '${Paths.getFileName(vari)}: ', 10); lblName_Object.alignment = CENTER; object_settings_gp.add(lblName_Object); last_menu_height += lblName_Object.height + 5;
                    var txtCurrent_Variable = new FlxUIInputText(5, last_menu_height, Std.int(MENU.width - 10), Json.stringify(tmp.getVariableValue(vari)), 10);
                    txtCurrent_Variable.name = 'current_variable:${vari}:array';
                    arrayFocus.push(txtCurrent_Variable);
                    object_settings_gp.add(txtCurrent_Variable); last_menu_height += txtCurrent_Variable.height + 5;
                }
            }
        }

        MENU.showTabId("1Layers");
    }

    private function addOBJECTSTABS(){
        var tabStage = new FlxUI(null, OBJECTS);
        tabStage.name = "1Objects";

        template_list = new FlxUIGroup(5, 10);
        reload_templates();
        tabStage.add(template_list);
        
        ////////////////////////////////////////////////////////////
        OBJECTS.addGroup(tabStage);
        ////////////////////////////////////////////////////////////



        OBJECTS.showTabId("1Objects");
    }

    var txtStage:FlxUIInputText;
    var clTypeValue:FlxUICustomList;
    private function addMENUTABS(){
        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "2Stage";

        var lblStage = new FlxText(5, 15, 0, "STAGE:", 8); tabMENU.add(lblStage);
        txtStage = new FlxUIInputText(lblStage.x + lblStage.width + 5, lblStage.y, Std.int(MENU.width - lblStage.width - 20), 'Stage', 8); tabMENU.add(txtStage);
        arrayFocus.push(txtStage);
        txtStage.name = "STAGE_NAME";

        var btnExportStage:FlxButton = new FlxCustomButton(5, txtStage.y + txtStage.height + 5, Std.int((MENU.width) - 10), null, "Export Stage (.hx)", null, null, function(){
            if(!canControlle){return;}
            canControlle = false;
            var stage_file = new SaverMaster([{name:'${txtStage.text}.hx', data: SCRIPT_SOURCE.buildSource()}], {destroyOnComplete: true, onComplete: function(){canControlle = true;}});
            stage_file.saveFile();
        }); tabMENU.add(btnExportStage);

        var btnLoad:FlxButton = new FlxCustomButton(btnExportStage.x, btnExportStage.y + btnExportStage.height + 5, Std.int((MENU.width / 2) - 10), null, "Load Stage", null, null, function(){
            SCRIPT_SOURCE = new StageScripManager(Paths.getText(Paths.stage(txtStage.text)));
            reload_stage_objects();
            loadVariableSettings();
            reloadStage();
        }); tabMENU.add(btnLoad);
        var btnImport:FlxButton = new FlxCustomButton(btnLoad.x + btnLoad.width + 10, btnLoad.y, Std.int((MENU.width / 2) - 10), null, "Import Stage", null, null, function(){
                getFile(function(str){
                    SCRIPT_SOURCE = new StageScripManager(Paths.getText(str));
                    reload_stage_objects();
                    loadVariableSettings();
                    reloadStage();
                });
        }); tabMENU.add(btnImport);

        var line0 = new FlxSprite(5, btnLoad.y + btnLoad.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line0);

        var ttlGeneralVariables:FlxText = new FlxText(0, line0.y + 5, MENU.width, "GLOBAL STAGE VALUES", 16); ttlGeneralVariables.alignment = CENTER; tabMENU.add(ttlGeneralVariables);

        var btnPressetVariable = new FlxCustomButton(5, ttlGeneralVariables.y + ttlGeneralVariables.height + 5, Std.int((MENU.width / 2) - 10), null, "Presset Variable", null, null, function(){
            var vari_value:String = 'false';
            switch(clTypeValue.getSelectedLabel()){
                case 'Float', 'Int':{vari_value = "0";}
                case 'String':{vari_value = '""';}
                case 'Array':{vari_value = "[]";}
            }
            
            SCRIPT_SOURCE.variables.push({id:"PlaceHolder", value:vari_value, type: clTypeValue.getSelectedLabel(), isPresset:true});
            loadVariableSettings();
            canReload = true;
        }); tabMENU.add(btnPressetVariable);

        var btnAddVariable = new FlxCustomButton(5 + btnPressetVariable.width + 10, btnPressetVariable.y, Std.int((MENU.width / 2) - 10), null, "Add Variable", null, null, function(){
            var vari_value:String = 'false';
            switch(clTypeValue.getSelectedLabel()){
                case 'Float', 'Int':{vari_value = "0";}
                case 'String':{vari_value = '""';}
                case 'Array':{vari_value = "[]";}
            }
            
            SCRIPT_SOURCE.variables.push({id:"PlaceHolder", value:vari_value, type: clTypeValue.getSelectedLabel(), isPresset:false});
            loadVariableSettings();
            canReload = true;
        }); tabMENU.add(btnAddVariable);

        clTypeValue = new FlxUICustomList(5, btnPressetVariable.y + btnPressetVariable.height, Std.int(MENU.width - 10), ["Bool", "String", "Int", "Float", "Array"]);
        clTypeValue.setPrefix("Type: ");
        tabMENU.add(clTypeValue);
        
        global_variable_gp = new FlxUIGroup(5, clTypeValue.y + clTypeValue.height + 5);
        tabMENU.add(global_variable_gp);
        loadVariableSettings();

        ////////////////////////////////////////////////////////////
        MENU.addGroup(tabMENU);
        ////////////////////////////////////////////////////////////

        object_settings_gp = new FlxUI(null, MENU);
        object_settings_gp.name = "1Layers";

        ////////////////////////////////////////////////////////////
        MENU.addGroup(object_settings_gp);

        var lblPlaceHolder = new FlxText(5, 10, Std.int(MENU.width - 10), "Click on an Object to view its Properties", 16);
        object_settings_gp.add(lblPlaceHolder);
        ////////////////////////////////////////////////////////////

        MENU.showTabId("2Stage");
    }

    private function addLAYERSTABS():Void {
        var tabLAYER = new FlxUI(null, LAYERS);
        tabLAYER.name = "1Layers";

        stage_objects_list = new FlxUIGroup(5, 10);
        reload_stage_objects();
        tabLAYER.add(stage_objects_list);
        
        ////////////////////////////////////////////////////////////
        LAYERS.addGroup(tabLAYER);
        ////////////////////////////////////////////////////////////

        LAYERS.showTabId("1Layers");
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;
            if(wname.contains("current_variable")){
                var object_variable:String = wname.split(":")[1];
                var type_variable:String = wname.split(":")[2];

                switch(type_variable){
                    default:{
                        current_object.setValueToVariable(object_variable, input.text);
                    }
                    case "array":{
                        var data:Array<Dynamic> = [];
                        try{data = (cast Json.parse('{ "Events": ${input.text} }')).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}
                        
                        current_object.setValueToVariable(object_variable, data);
                    }
                }

                canReload = true;
            }else if(wname.contains("global_variable")){
                var object_variable:Int = Std.parseInt(wname.split(":")[1]);
                var type_variable:String = wname.split(":")[2];

                switch(type_variable){
                    default:{SCRIPT_SOURCE.variables[object_variable].value = input.text;}
                    case "array":{
                        var data:Array<Dynamic> = [];
                        try{data = (cast Json.parse('{ "Events": ${input.text} }')).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}
                        
                        SCRIPT_SOURCE.variables[object_variable].value = data;
                    }
                    case "id":{SCRIPT_SOURCE.variables[object_variable].id = input.text;}
                }

                canReload = true;
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            if(wname.contains("current_variable")){
                var object_variable:String = wname.split(":")[1];
                current_object.setValueToVariable(object_variable, nums.value);
                
                canReload = true;
            }else if(wname.contains("global_variable")){
                var object_variable:Int = Std.parseInt(wname.split(":")[1]);

                SCRIPT_SOURCE.variables[object_variable].value = nums.value;

                canReload = true;
            }
        }else if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
            var wname = check.name;
            if(wname.contains("current_variable")){
                var object_variable:String = wname.split(":")[1];
                current_object.setValueToVariable(object_variable, check.checked);

                canReload = true;
            }else if(wname.contains("global_variable")){
                var object_variable:Int = Std.parseInt(wname.split(":")[1]);
                                
                SCRIPT_SOURCE.variables[object_variable].value = check.checked;

                canReload = true;
            }
        }
    }
    
    var onReload:Bool = false;
    private function getFile(_onSelect:String->Void):Void {
        if(onReload){return;} onReload = true;

        var fDialog = new FileDialog();
        fDialog.onSelect.add(function(str){onReload = false; _onSelect(str);});
        fDialog.browse();
	}
}

class StageScripManager {
    public var packages:Map<String, Dynamic> = [];
    public var variables:Array<{id:String, value:Dynamic, type:String, isPresset:Bool}> = [];
    public var objects:Array<StageObjectScript> = [];

    public function new(?src:String):Void {
        
        if(src == null){return;}

        var current_object:StageObjectScript = null;
        var current_attribute:StageObjectScript = null;
        
        for(line in src.split("\n")){
            //trace(line);

            if(line.contains("//-<") && line.contains(">-//")){
                var object_name:String = line.split("//-<")[1].split(">-//")[0];
                //trace('Created: ${object_name}');
                current_object = new StageObjectScript(object_name);
            }
            if(line.contains("//->") && line.contains("<-//")){
                //trace('Pushed: ${current_object.name}');
                objects.push(current_object);
                current_object = null;
            }
            if(line.contains("//-{") && line.contains("}-//")){
                if(current_object == null){trace("Parsing Error [Null Object]");}
                var att_name:String = line.split("//-{")[1].split("}-//")[0];
                current_object.addAttribute(att_name);
                current_attribute = current_object.attributes.get(att_name);
                //trace('Created Attribute: ${att_name}');
            }
            if(line.contains("//-[") && line.contains("]-//")){
                if(current_attribute == null){trace("Parsing Error [Null Attribute]");}
                current_object.attributes.set(current_attribute.name, current_attribute);
                //trace('Pushed Attribute: ${current_object.name}');
                current_attribute = null;
            }

            if(line.contains("/*") && line.contains("*/")){
                var parsed_line:String = '{ ${line.split("/*")[1].split("*/")[0]} }';
                var cur_value:Dynamic = cast Json.parse(parsed_line);

                if(current_attribute != null){
                    if(cur_value.Packages != null){
                        var cur_packs:DynamicAccess<Dynamic> = cur_value.Packages;
                        for(key in cur_packs.keys()){current_object.packages.set(key, cur_packs[key]);}
                    }
                    if(cur_value.Variables != null){
                        var cur_vars:DynamicAccess<Dynamic> = cur_value.Variables;
                        for(key in cur_vars.keys()){current_object.variables.set(key, cur_vars[key]);}
                    }
                    //trace("Added Variables to Attribute");
                }else if(current_object != null){
                    if(cur_value.Packages != null){
                        var cur_packs:DynamicAccess<Dynamic> = cur_value.Packages;
                        for(key in cur_packs.keys()){current_object.packages.set(key, cur_packs[key]);}
                    }
                    if(cur_value.Variables != null){
                        var cur_vars:DynamicAccess<Dynamic> = cur_value.Variables;
                        for(key in cur_vars.keys()){current_object.variables.set(key, cur_vars[key]);}
                    }
                    //trace("Added Variables to Object");
                }else{
                    if(cur_value.Packages != null){
                        var cur_packs:DynamicAccess<Dynamic> = cur_value.Packages;
                        for(key in cur_packs.keys()){this.packages.set(key, cur_packs[key]);}
                    }
                    if(cur_value.Variables != null){
                        this.variables = cur_value.Variables;
                    }
                    //trace("Added Variables to Global");
                }
            }
        }
    }
    
    public function buildSource():String {
        reloadObjectVariables();

        var toReturn:String = "";

        toReturn += '/* "Packages": ${Json.stringify(packages)} */\n';
        toReturn += '/* "Variables": ${Json.stringify(variables)} */\n';
        toReturn += "\n";

        for(key in packages.keys()){toReturn += 'import("${packages[key]}", "${key}");\n';}
        toReturn += '\n';
        
        toReturn += 'function addToLoad(temp){\n';
        for(obj in objects){toReturn += 'temp.push(${obj.buildPreload()});\n';}
        toReturn += '}\n\n';

        for(v in variables){
            if(v.type == "Array"){
                var data:String = "[]";
                try{data = Json.stringify(v.value);}catch(e){trace(e); data = "[]";}

                toReturn += '${v.isPresset ? ('presset("${v.id}", ${data});') : ('var ${v.id}${v.type != null ? ':${v.type}' : ''} = ${data};')}\n';
            }else{
                toReturn += '${v.isPresset ? ('presset("${v.id}", ${v.value});') : ('var ${v.id}${v.type != null ? ':${v.type}' : ''} = ${v.value};')}\n';
            }
        }
        toReturn += '\n';
        toReturn += 'function create(){\n';
        for(obj in objects){toReturn += '${obj.buildSource()}';}
        toReturn += '}';

        return toReturn;
    }

    public function addTemplate(tmp:StageObjectScript){
        objects.push(tmp);
        tmp.ID = objects.length - 1;
    }

    public function reloadObjectVariables():Void {
        this.packages.clear();

        for(obj in objects){
            obj.reloadVariables();            
            for(key in obj.packages.keys()){this.packages.set(key, obj.packages[key]);}
        }

    }
}

class StageObjectScript {
    public var value_types:Map<String, String> = [];

    public var possible_attributes:Array<String> = [];

    public var packages:Map<String, Dynamic> = [];
    public var variables:Map<String, Dynamic> = [];
    public var attributes:Map<String, StageObjectScript> = [];
    private var source:String = '';
    private var preload:String = '';

    public var name:String = "";
    public var ID:Int = 0;

    public function new(_name:String, ?_source:String){
        this.name = _name;
        if(_source == null){_source = Paths.txt('stage_editor_objects/${_name}/${_name}');}

        parseTemplate(_source);

        for(i in Paths.readDirectory('assets/data/stage_editor_objects/${_name}')){
            var _i:String = i; _i = _i.replace("att-", "").replace(".txt", "");
            if(_i == name || _i == "Preload"){continue;}
            possible_attributes.push(_i);
        }

        var preload_path:String = Paths.setPath('assets/data/stage_editor_objects/${_name}/Preload.txt');
        if(Paths.exists(preload_path)){preload = Paths.getText(preload_path);}
    }

    public function parseTemplate(_src:String):Void {
        variables.clear();
        source = '';

        var src:String = Std.string(_src);

        var tag_data:String = '';
        var current_tag:String = '';

        for(c in src.split("")){
            switch(c){
                default:{
                    if(current_tag == '' || current_tag == '#'){source += c;}
                    if(current_tag != ''){tag_data += c;}
                }
                case "$":{
                    if(current_tag == ''){current_tag = '$'; continue;}
                    if(current_tag != '$'){trace('Parsing Error [Unexpected $c on $]'); return;}
                    current_tag = '';
                    var package_data:Array<String> = tag_data.split(",");
                    packages.set(package_data[1], package_data[0]);
                    tag_data = '';
                }
                case "%":{
                    if(current_tag == ''){current_tag = '%'; continue;}
                    if(current_tag != '%'){trace('Parsing Error [Unexpected $c on %]'); return;}
                    current_tag = '';
                    var variable_data:Array<String> = tag_data.split(":");
                    value_types.set(variable_data[0], variable_data[2]);

                    switch(variable_data[2]){
                        default:{variables.set(variable_data[0], variable_data[1] == 'true');}
                        case 'float':{variables.set(variable_data[0], Std.parseFloat(variable_data[1]));}
                        case 'int':{variables.set(variable_data[0], Std.parseInt(variable_data[1]));}
                        case 'string':{variables.set(variable_data[0], variable_data[1]);}
                        case 'array':{
                            var data:Array<Dynamic> = [];
                            try{data = (cast Json.parse('{ "Events": ${variable_data[1]} }')).Events;}catch(e){trace('Parsing Error [Can\'t parse Array value] ($e)'); return;}
                            variables.set(variable_data[0], data);
                        }
                    }

                    tag_data = '';
                }
            }
        }

        var source_spaces:Array<String> = source.split('\n');
        var ignore_lines:Int = 0;
        while(ignore_lines < source_spaces.length){
            var remove_line:Bool = true;
            for(c in source_spaces[0].split("")){if(c != "\n" && c != " " && c != "\t" && c != "\r"){remove_line = false; break;}}
            if(remove_line){source_spaces.shift();}else{ignore_lines++;}
        }

        source = '';
        for(line in source_spaces){source += '${line}\n';}
    }

    public function reloadVariables():Void {
        for(att_object in this.attributes){
            for(key in this.variables.keys()){att_object.variables.set(key, this.variables[key]);}
            att_object.reloadVariables();
            for(key in att_object.packages.keys()){this.packages.set(key, att_object.packages[key]);}
        }
    }

    public function addAttribute(att_name:String):Void {
        var att_path:String = Paths.getPath('data/stage_editor_objects/${this.name}/att-${att_name}.txt', TEXT, null);
        if(!Paths.exists(att_path)){trace('Atribute Null'); return;}
        var att_object:StageObjectScript = new StageObjectScript(att_name, Paths.getText(att_path));
        attributes.set(att_name, att_object);
    }

    public function removeAttribute(att_name:String):Void {
        attributes.remove(att_name);
    }

    public function buildSource(isAttribute:Bool = false):String {
        var toReturn:String = '';

        if(!isAttribute){toReturn += '//-<${name}>-//\n';}else{toReturn += '//-{${name}}-//\n';}
        toReturn += '/* "Packages": ${Json.stringify(packages)} */\n';
        toReturn += '/* "Variables": ${Json.stringify(variables)} */\n';
        toReturn += "\n";

        var current_tag:String = '';
        var current_variable:String = '';

        for(c in source.split("")){
            switch(c){
                default:{
                    if(current_tag == ''){toReturn += c; continue;}
                    current_variable += c;
                }
                case "#":{
                    if(current_tag == ''){current_tag = '#'; continue;}
                    if(current_tag != '#'){trace('Building Error [Unexpected $c on #]'); return '';}
                    if(!variables.exists(current_variable)){trace('Building Error [UnLoaded Variable ${current_variable}]'); return '';}
                    if(value_types.get(current_variable) == "array"){
                        toReturn += Json.stringify(variables.get(current_variable));
                    }else{
                        toReturn += variables.get(current_variable);
                    }
                    current_variable = '';
                    current_tag = '';
                }
            }
        }

        for(att in attributes){toReturn += att.buildSource(true);}
        
        if(!isAttribute){toReturn += '//->${name}<-//\n';}else{toReturn += '//-[${name}]-//\n';}

        return toReturn;
    }

    public function buildPreload():String {
        var toReturn:String = '';

        var current_tag:String = '';
        var current_variable:String = '';

        for(c in preload.split("")){
            switch(c){
                default:{
                    if(current_tag == ''){toReturn += c; continue;}
                    current_variable += c;
                }
                case "#":{
                    if(current_tag == ''){current_tag = '#'; continue;}
                    if(current_tag != '#'){trace('Building Error [Unexpected $c on #]'); return '';}
                    if(!variables.exists(current_variable)){trace('Building Error [UnLoaded Variable ${current_variable}]'); return '';}
                    if(value_types.get(current_variable) == "array"){
                        toReturn += Json.stringify(variables.get(current_variable));
                    }else{
                        toReturn += variables.get(current_variable);
                    }
                    current_variable = '';
                    current_tag = '';
                }
            }
        }
        
        return toReturn;
    }

    public function getValueTypeList():Array<String> {
        var toReturn:Array<String> = [];
        for(key in this.value_types.keys()){toReturn.push(key);}
        for(att in this.attributes){for(key in att.getValueTypeList()){toReturn.push(key);}}
        return toReturn;
    }

    public function getVariableList():Array<String> {
        var toReturn:Array<String> = [];
        for(key in this.variables.keys()){toReturn.push(key);}
        for(att in this.attributes){for(key in att.getVariableList()){toReturn.push(key);}}
        return toReturn;
    }

    public function getVariableValue(key:String):Dynamic {
        if(key == null){return null;}
        if(this.variables.exists(key)){return this.variables[key];}
        for(att in this.attributes){if(att.variables.exists(key)){return att.variables[key];}}
        trace('($key) Variable not Parsed');
        return null;
    };
    public function setValueToVariable(key:String, value:Dynamic):Void {
        if(variables.exists(key)){variables[key] = value; return;}
        for(att in this.attributes){if(att.variables.exists(key)){att.variables[key] = value; return;}}
        trace('($key) Variable not Parsed');
    };

    public function getValueType(key:String){
        if(value_types.exists(key)){return value_types[key];}
        for(att in this.attributes){if(att.value_types.exists(key)){return att.value_types[key];}}
        trace('($key) Type not Parsed');
        return null;
    }
}