package states.editors;

import Stage.StagePart;
import flixel.input.mouse.FlxMouse;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUINumericStepperCustom;
import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import Stage.StageData;
import Stage.StageSprite;
import Stage.StageAnim;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIInputText;
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

class StageEditorState extends MusicBeatState {
    public static var _stage:StageData;
    var curStage:Stage;
    
    public static var curObj:Int = 0;
    var curObject:StagePart;

    //TABS
    var MENU:FlxUITabMenu;

    //Cameras
    var camBack:FlxCamera;
    var camGeneral:FlxCamera;
	var camHUD:FlxCamera;

    var CAMERA:FlxSprite;
    var camFollow:FlxObject;
    var mPoint:FlxPoint;

    var arrayFocus:Array<FlxUIInputText> = [];

    public static function editStage(stage:StageData = null){
        if(stage != null){
            _stage = stage;
        }else{
            _stage = cast Json.parse(Assets.getText(Paths.StageJSON("Stage")));
        }

        FlxG.switchState(new StageEditorState());
    }

    override function create(){
        FlxG.mouse.visible = true;

        camBack = new FlxCamera();
        camGeneral = new FlxCamera();
		camGeneral.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camBack);
		FlxG.cameras.add(camGeneral);
        FlxG.cameras.add(camHUD);

        mPoint = new FlxPoint(0, 0);

        curStage = new Stage(null, null, true);

        var backGrid = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height);
        backGrid.cameras = [camBack];
        add(backGrid);

        curStage.cameras = [camGeneral];
        add(curStage);

        CAMERA = new FlxSprite(0 - (FlxG.width / 2), 0 - (FlxG.height / 2)).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        CAMERA.screenCenter();
        CAMERA.cameras = [camGeneral];
        CAMERA.alpha = 0.2;
        add(CAMERA);

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.cameras = [camGeneral];
        camFollow.screenCenter();
		add(camFollow);

		camGeneral.follow(camFollow, LOCKON);
		camGeneral.focusOn(camFollow.getPosition());

        var menuTabs = [
            {name: "General", label: 'General'}
        ];
        MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(250, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        MENU.camera = camHUD;

        addMENUTAB();

        add(MENU);

        camGeneral.zoom = 0.5;

        super.create();
    }

    var canControl = true;
    var mouPos = [0.0, 0.0];
    var camPos = [0.0, 0.0];
    var objPos = [0.0, 0.0];
    var draggin = false;
    override function update(elapsed:Float){
		super.update(elapsed);

        mPoint = FlxG.mouse.getPositionInCameraView(camGeneral);

        reloadStage();
        if(curObj >= _stage.StageData.length){curObj = 0;}else if(curObj < 0){curObj = _stage.StageData.length - 1;}
        curObject = _stage.StageData[curObj];

        //Object Stats
        sprPosX.value = curObject.position[0];
        sprPosY.value = curObject.position[1];
        sprScrollX.value = curObject.scrollFactor[0];
        sprScrollY.value = curObject.scrollFactor[1];
        sprAng.value = curObject.angle;
        sprScl.value = curObject.size;
        sprAlp.value = curObject.alpha;

        clAnims.setData(Stage.getArrayFromAnims(curObject.stageAnims));

        txtPartImage.text = curObject.image;
        //

        
        var canControlle = true;
        for(item in arrayFocus){if(item.hasFocus){canControlle = false;}}

        if(canControl && canControlle){
            if(FlxG.keys.justPressed.ESCAPE){FlxG.switchState(new MainMenuState());}

            if(!draggin && (FlxG.mouse.justPressedRight || FlxG.mouse.justPressed)){
                mouPos[0] = mPoint.x;
                mouPos[1] = mPoint.y;
            }

            if(FlxG.mouse.justReleased){draggin = false;}
            if(FlxG.mouse.justPressed){
                objPos[0] = curObject.position[0];
                objPos[1] = curObject.position[1];
                draggin = true;
            }

            if(FlxG.keys.pressed.Q){curObject.angle--;}
            if(FlxG.keys.pressed.E){curObject.angle++;}
            if(FlxG.keys.justPressed.R){curObject.angle = 0;}

            if(FlxG.keys.pressed.Z){curObject.size -= 0.01;}
            if(FlxG.keys.pressed.X){curObject.size += 0.01;}
            if(FlxG.keys.justPressed.C){curObject.size = 1;}

            if(!draggin){
                if(FlxG.mouse.justPressedRight){
                    camPos[0] = camFollow.x;
                    camPos[1] = camFollow.y;
                }

                if(FlxG.keys.pressed.F){camFollow.screenCenter();}

                if(FlxG.keys.justPressed.UP){curObj--;}
                if(FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.TAB){curObj++;}

                if(FlxG.mouse.pressedRight){
                    camFollow.setPosition(camPos[0] + ((mouPos[0] - mPoint.x) * 1.0), camPos[1] + ((mouPos[1] - mPoint.y) * 1.0));
                }

                if(FlxG.keys.pressed.SHIFT){
                    camGeneral.zoom += (FlxG.mouse.wheel * 0.1);
                }else{
                    camGeneral.zoom += (FlxG.mouse.wheel * 0.01);
                }

                if(FlxG.keys.justPressed.T && curObj - 1 >= 0){
                    replaceStage(curObj, curObj - 1);
                    curObj--;
                }
                if(FlxG.keys.justPressed.G && curObj + 1 < curStage.length){
                    replaceStage(curObj, curObj + 1);
                    curObj++;
                }

                if(FlxG.keys.pressed.A){curObject.position[0]--;}
                if(FlxG.keys.pressed.W){curObject.position[1]--;}
                if(FlxG.keys.pressed.S){curObject.position[1]++;}
                if(FlxG.keys.pressed.D){curObject.position[0]++;}

                if(FlxG.keys.justPressed.V){
                    curStage.members[curObj].screenCenter();
                    curObject.position = [curStage.members[curObj].x, curStage.members[curObj].y];
                }
            }else{
                curObject.position[0] = objPos[0] - ((mouPos[0] - mPoint.x) * 1.0);
                curObject.position[1] = objPos[1] - ((mouPos[1] - mPoint.y) * 1.0);

                if(FlxG.keys.pressed.SHIFT){
                    curObject.angle += (FlxG.mouse.wheel * 2.5);
                }else{
                    curObject.angle += (FlxG.mouse.wheel * 5);
                }
            }
        }
    }

    //Menu General
    var txtStageName:FlxUIInputText;
    var txtStageDirect:FlxUIInputText;
    var sprStageZoom:FlxUINumericStepper;
    var sprStageChroma:FlxUINumericStepper;
    //Menu Stats
    var sprPosX:FlxUINumericStepperCustom;
    var sprPosY:FlxUINumericStepperCustom;
    var sprScrollX:FlxUINumericStepperCustom;
    var sprScrollY:FlxUINumericStepperCustom;
    var sprScl:FlxUINumericStepperCustom;
    var sprAng:FlxUINumericStepperCustom;
    var sprAlp:FlxUINumericStepperCustom;
    //Menu Animations
    var sprFrame:FlxUINumericStepper;
    var cbxLoop:FlxUICheckBox;
    var clAnims:FlxUICustomList;
    var txtAnimName:FlxUIInputText;
    var txtAnimSymbol:FlxUIInputText;
    var txtAnimIndices:FlxUIInputText;
    //Part Properties
    var txtPartImage:FlxUIInputText;
    function addMENUTAB(){
        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "General";

        var lblStageName = new FlxText(5, 20, MENU.width - 10, "Stage Name:", 8); tabMENU.add(lblStageName);
        txtStageName = new FlxUIInputText(lblStageName.x, lblStageName.y + 15, Std.int(lblStageName.width), curStage.curStage, 8); tabMENU.add(txtStageName);
        arrayFocus.push(txtStageName);

        var btnStageSave = new FlxButton(txtStageName.x, txtStageName.y + txtStageName.height + 3, "Save", function(){
            saveStage(txtStageName.text);
        }); tabMENU.add(btnStageSave);
        btnStageSave.setSize(Std.int((txtStageName.width)), Std.int(btnStageSave.height));
        btnStageSave.setGraphicSize(Std.int((txtStageName.width)), Std.int(btnStageSave.height));
        btnStageSave.centerOffsets();
        btnStageSave.label.fieldWidth = btnStageSave.width;

        var btnStageLoad = new FlxButton(btnStageSave.x, btnStageSave.y + btnStageSave.height + 3, "Load", function(){
            editStage(cast Json.parse(Assets.getText(Paths.StageJSON(txtStageName.text))));
        }); tabMENU.add(btnStageLoad);
        btnStageLoad.setSize(Std.int((txtStageName.width)), Std.int(btnStageLoad.height));
        btnStageLoad.setGraphicSize(Std.int((txtStageName.width)), Std.int(btnStageLoad.height));
        btnStageLoad.centerOffsets();
        btnStageLoad.label.fieldWidth = btnStageLoad.width;

        var line1 = new FlxSprite(5, btnStageLoad.y + btnStageLoad.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line1);

        var lblStageZoom = new FlxText(5, line1.y + 5, 0, "Stage Zoom:", 8); tabMENU.add(lblStageZoom);
        sprStageZoom = new FlxUINumericStepper(lblStageZoom.x + 3, lblStageZoom.y + lblStageZoom.height + 2, 0.1, 1, 0, 1, 1);
            @:privateAccess arrayFocus.push(cast sprStageZoom.text_field);
        sprStageZoom.value = curStage.zoom;
		sprStageZoom.name = 'stageZoom';
		tabMENU.add(sprStageZoom);

        var lblStageChroma = new FlxText(lblStageZoom.x + lblStageZoom.width + 10, lblStageZoom.y, 0, "Stage Chroma:", 8); tabMENU.add(lblStageChroma);
        sprStageChroma = new FlxUINumericStepper(lblStageChroma.x + 3, lblStageChroma.y + lblStageChroma.height + 2, 0.1, 0, -1, 1, 1);
            @:privateAccess arrayFocus.push(cast sprStageChroma.text_field);
        sprStageChroma.value = curStage.chrome;
		sprStageChroma.name = 'stageChroma';
		tabMENU.add(sprStageChroma);

        var lblStageDirectory = new FlxText(5, sprStageChroma.y + sprStageChroma.height + 5, txtStageName.width, "Stage Directory:", 8); tabMENU.add(lblStageDirectory);
        txtStageDirect = new FlxUIInputText(lblStageDirectory.x, lblStageDirectory.y + 15, Std.int(lblStageDirectory.width), curStage.directory, 8); tabMENU.add(txtStageDirect);
        txtStageDirect.name = "STAGE_DIRECTORY";
        arrayFocus.push(txtStageDirect);

        var line2 = new FlxSprite(5, txtStageDirect.y + txtStageDirect.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line2);

        var ttlChangeItem = new FlxText(5, line2.y + line2.height + 5, Std.int(MENU.width - 10), "Change Item", 8); tabMENU.add(ttlChangeItem);
        ttlChangeItem.alignment = CENTER;

        var btnBack = new FlxButton(5, ttlChangeItem.y + ttlChangeItem.height, "<", function(){curObj--;}); tabMENU.add(btnBack);
        btnBack.setSize(Std.int((ttlChangeItem.width / 2)), Std.int(btnBack.height));
        btnBack.setGraphicSize(Std.int((ttlChangeItem.width / 2)), Std.int(btnBack.height));
        btnBack.centerOffsets();
        btnBack.label.fieldWidth = btnBack.width;

        var btnFront = new FlxButton(btnBack.x + btnBack.width, btnBack.y, ">", function(){curObj++;}); tabMENU.add(btnFront);
        btnFront.setSize(Std.int((ttlChangeItem.width / 2)), Std.int(btnFront.height));
        btnFront.setGraphicSize(Std.int((ttlChangeItem.width / 2)), Std.int(btnFront.height));
        btnFront.centerOffsets();
        btnFront.label.fieldWidth = btnFront.width;

        var btnPushNew = new FlxButton(5, btnBack.y + btnBack.height + 7, "Push New Item Current", function(){
            var nStagePart:StagePart = {
                image: "",
                position: [0, 0],
                scrollFactor: [1, 1],
                size: 1,
                alpha: 1,

                stageAnims: null,
                dflipY: false,
                dflipX: false,

                angle: 0,

                antialiasing: true
            };

            _stage.StageData.insert(curObj - 1, nStagePart);
            reloadStage();
        }); tabMENU.add(btnPushNew);
        btnPushNew.setSize(Std.int((MENU.width) - 10), Std.int(btnPushNew.height));
        btnPushNew.setGraphicSize(Std.int((MENU.width) - 10), Std.int(btnPushNew.height));
        btnPushNew.centerOffsets();
        btnPushNew.label.fieldWidth = btnPushNew.width;

        var btnDelCur = new FlxButton(btnPushNew.x, btnPushNew.y + btnPushNew.height + 2, "Delete Current Item", function(){
            if(_stage.StageData.length > 1){
                _stage.StageData.remove(curObject);
                reloadStage();
            }
        }); tabMENU.add(btnDelCur);
        btnDelCur.setSize(Std.int((MENU.width) - 10), Std.int(btnDelCur.height));
        btnDelCur.setGraphicSize(Std.int((MENU.width) - 10), Std.int(btnDelCur.height));
        btnDelCur.centerOffsets();
        btnDelCur.label.fieldWidth = btnDelCur.width;

        //
        var line3 = new FlxSprite(5, btnDelCur.y + btnDelCur.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line3);
        //

        var ttlProperties = new FlxText(5, line3.y + line3.height + 3, Std.int(MENU.width - 10), "Properties", 8); tabMENU.add(ttlProperties);
        ttlProperties.alignment = CENTER;

        var lblPos = new FlxText(5, ttlProperties.y + ttlProperties.height + 5, 0, "                      Position", 8);
        tabMENU.add(lblPos);

        var btnResPos = new FlxTypedButton<FlxSprite>(lblPos.x + lblPos.width + 3, lblPos.y + 2, function(){curObject.position = [0, 0];});
        btnResPos.loadGraphic(Paths.image('UI_Assets/gear', 'shared'));
        btnResPos.setGraphicSize(Std.int(12));
        btnResPos.updateHitbox();
        tabMENU.add(btnResPos);

        var lblPosX = new FlxText(lblPos.x, lblPos.y + 17, 0, "X:", 8);tabMENU.add(lblPosX);
        sprPosX = new FlxUINumericStepperCustom(lblPosX.x + lblPosX.width + 5, lblPosX.y, 0.1, 1, -99999, 99999, 1);
            @:privateAccess arrayFocus.push(cast sprPosX.text_field);
		sprPosX.name = 'posX';
        sprPosX.setWidth(Std.int(MENU.width / 2) - 25);
		tabMENU.add(sprPosX);

        var lblPosY = new FlxText(lblPos.x, lblPosX.y + 17, 0, "Y:", 8);tabMENU.add(lblPosY);
        sprPosY = new FlxUINumericStepperCustom(lblPosY.x + lblPosY.width + 5, lblPosY.y, 0.1, 1, -99999, 99999, 1);
            @:privateAccess arrayFocus.push(cast sprPosY.text_field);
		sprPosY.name = 'posY';
        sprPosY.setWidth(Std.int(MENU.width / 2) - 25);
		tabMENU.add(sprPosY);

        var lblScroll = new FlxText(sprPosX.x + sprPosX.width + 10, lblPos.y, 0, "   Scroll", 8);
        tabMENU.add(lblScroll);

        var btnResScroll = new FlxTypedButton<FlxSprite>(lblScroll.x + lblScroll.width + 3, lblScroll.y + 2, function(){
            curObject.scrollFactor = [1, 1];
        });
        btnResScroll.loadGraphic(Paths.image('UI_Assets/gear', 'shared'));
        btnResScroll.setGraphicSize(Std.int(12));
        btnResScroll.updateHitbox();
        tabMENU.add(btnResScroll);

        var lblScrollX = new FlxText(lblScroll.x, lblScroll.y + 17, 0, "X:", 8);tabMENU.add(lblScrollX);
        sprScrollX = new FlxUINumericStepperCustom(lblScrollX.x + lblScrollX.width + 5, lblScrollX.y, 0.1, 1, -100, 100, 1);
            @:privateAccess arrayFocus.push(cast sprScrollX.text_field);
		sprScrollX.name = 'scrollX';
		tabMENU.add(sprScrollX);

        var lblScrollY = new FlxText(lblScrollX.x, lblScrollX.y + 17, 0, "Y:", 8);tabMENU.add(lblScrollY);
        sprScrollY = new FlxUINumericStepperCustom(lblScrollY.x + lblScrollY.width + 5, lblScrollY.y, 0.1, 1, -100, 100, 1);
            @:privateAccess arrayFocus.push(cast sprScrollY.text_field);
		sprScrollY.name = 'scrollY';
		tabMENU.add(sprScrollY);

        var lblAngle = new FlxText(lblPos.x, sprPosY.y + 20, 0, "   Angle", 8); tabMENU.add(lblAngle);
        sprAng = new FlxUINumericStepperCustom(lblPos.x, lblAngle.y + 17, 1, 0, -99999, 99999, 2);
            @:privateAccess arrayFocus.push(cast sprAng.text_field);
		sprAng.value = curStage.members[curObj].angle;
		sprAng.name = 'angle';
        sprAng.setWidth(40);
		tabMENU.add(sprAng);

        var lblScale = new FlxText(sprAng.x + sprAng.width + 10, lblAngle.y, 0, "   Scale", 8); tabMENU.add(lblScale);
        sprScl = new FlxUINumericStepperCustom(lblScale.x, lblScale.y + 17, 0.01, 1, 0, 999, 2);
            @:privateAccess arrayFocus.push(cast sprScl.text_field);
		sprScl.value = curStage.members[curObj].defScale;
		sprScl.name = 'scale';
        sprScl.setWidth(40);
		tabMENU.add(sprScl);

        var lblAlpha = new FlxText(sprScl.x + sprScl.width + 10, lblScale.y, 0, "   Alpha", 8); tabMENU.add(lblAlpha);
        sprAlp = new FlxUINumericStepperCustom(lblAlpha.x, lblAlpha.y + 17, 0.1, 1, 0, 1, 1);
            @:privateAccess arrayFocus.push(cast sprAlp.text_field);
		sprAlp.value = curStage.members[curObj].alpha;
		sprAlp.name = 'alpha';
        sprAlp.setWidth(40);
		tabMENU.add(sprAlp);

        var lblFlip = new FlxText(5, sprAlp.y + sprAlp.height + 5, 0, "                                Flip", 8);
        tabMENU.add(lblFlip);

        var btnResFlip = new FlxTypedButton<FlxSprite>(lblFlip.x + lblFlip.width + 3, lblFlip.y + 2, function(){
            curObject.dflipX = false;
            curObject.dflipY = false;
        });
        btnResFlip.loadGraphic(Paths.image('UI_Assets/gear', 'shared'));
        btnResFlip.setGraphicSize(Std.int(12));
        btnResFlip.updateHitbox();
        tabMENU.add(btnResFlip);

        var btnHoriz = new FlxButton(lblFlip.x, lblFlip.y + 17, "Horizontal", function(){
            curObject.dflipX = !curObject.dflipX;
        }); tabMENU.add(btnHoriz);
        btnHoriz.setSize(Std.int((MENU.width / 2) - 5), Std.int(btnHoriz.height));
        btnHoriz.setGraphicSize(Std.int((MENU.width / 2) - 5), Std.int(btnHoriz.height));
        btnHoriz.centerOffsets();
        btnHoriz.label.fieldWidth = btnHoriz.width;

        var btnVert = new FlxButton(lblFlip.x + btnHoriz.width, btnHoriz.y, "Vertical", function(){
            curObject.dflipY = !curObject.dflipY;
        }); tabMENU.add(btnVert);
        btnVert.setSize(Std.int((MENU.width / 2) - 5), Std.int(btnVert.height));
        btnVert.setGraphicSize(Std.int((MENU.width / 2) - 5), Std.int(btnVert.height));
        btnVert.centerOffsets();
        btnVert.label.fieldWidth = btnVert.width;

        //
        var line4 = new FlxSprite(5, btnHoriz.y + btnHoriz.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line4);
        //

        var lblAnimName = new FlxText(5, line4.y + 5, 0,   " Animation Name:  ", 8); tabMENU.add(lblAnimName);
        txtAnimName = new FlxUIInputText(lblAnimName.x, lblAnimName.y + 15, Std.int(MENU.width - 65), "", 8);
        arrayFocus.push(txtAnimName);
		tabMENU.add(txtAnimName);

        var lblAnimSymbol = new FlxText(txtAnimName.x, txtAnimName.y + txtAnimName.height, 0,        " Animation Symbol:", 8); tabMENU.add(lblAnimSymbol);
        txtAnimSymbol = new FlxUIInputText(lblAnimSymbol.x, lblAnimSymbol.y + 15, Std.int(MENU.width - 65), "", 8);
		arrayFocus.push(txtAnimSymbol);
        tabMENU.add(txtAnimSymbol);

        var lblAnimIndices = new FlxText(txtAnimSymbol.x, txtAnimSymbol.y + txtAnimSymbol.height, 0, " Animation Indices:", 8); tabMENU.add(lblAnimIndices);
        txtAnimIndices = new FlxUIInputText(lblAnimIndices.x, lblAnimIndices.y + 15, Std.int(MENU.width - 10), "", 8);
		arrayFocus.push(txtAnimIndices);
        tabMENU.add(txtAnimIndices);

        var btnAnimUpdate = new FlxButton(txtAnimName.x + txtAnimName.width + 5, lblAnimName.y, "Update", function(){
            if(curObject.stageAnims != null && curObject.stageAnims.length > 0){
                for(anim in curObject.stageAnims){
                    if(anim.anim == txtAnimName.text){
                        anim.fps = Std.int(sprFrame.value);
                        
                        var indices:Array<Int> = [];
                        var indicesStr:Array<String> = txtAnimIndices.text.trim().split(',');
                        if(indicesStr.length > 1) {
                            for (i in 0...indicesStr.length) {
                                var index:Int = Std.parseInt(indicesStr[i]);
                                if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1){indices.push(index);}
                            }
                        }
                        anim.indices = indices;

                        anim.loop = cbxLoop.checked;
                        anim.symbol = txtAnimSymbol.text;
                    }
                }
            }
            reloadStage();
        });
        btnAnimUpdate.setGraphicSize(Std.int(50), Std.int(btnAnimUpdate.height));
        btnAnimUpdate.updateHitbox();
        btnAnimUpdate.label.updateHitbox();
        for(p in btnAnimUpdate.labelOffsets){p.set(-17, 3);}
        tabMENU.add(btnAnimUpdate);

        var btnAnimAdd = new FlxButton(btnAnimUpdate.x, btnAnimUpdate.y + btnAnimUpdate.height + 2, "Add", function(){
            var indices:Array<Int> = [];
            var indicesStr:Array<String> = txtAnimIndices.text.trim().split(',');
            if(indicesStr.length > 1) {
                for (i in 0...indicesStr.length) {
                    var index:Int = Std.parseInt(indicesStr[i]);
                    if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1){indices.push(index);}
                }
            }

            var nStageAnim:StageAnim = {
                anim: txtAnimName.text,
                symbol: txtAnimSymbol.text,
                indices: indices,

                fps: Std.int(sprFrame.value),
                loop: cbxLoop.checked
            };
            
            curObject.stageAnims.push(nStageAnim);
            reloadStage();
        });
        btnAnimAdd.setGraphicSize(Std.int(50), Std.int(btnAnimAdd.height));
        btnAnimAdd.updateHitbox();
        btnAnimAdd.label.updateHitbox();
        for(p in btnAnimAdd.labelOffsets){p.set(-17, 3);}
        tabMENU.add(btnAnimAdd);

        var btnAnimDel = new FlxButton(btnAnimAdd.x, btnAnimAdd.y + btnAnimAdd.height + 7, "Delete", function(){
            if(curObject.stageAnims != null && curObject.stageAnims.length > 0){
                for(anim in curObject.stageAnims){
                    if(anim.anim == txtAnimName.text){
                        curObject.stageAnims.remove(anim);
                        break;
                    }
                }
            }
            reloadStage();
        });
        btnAnimDel.setGraphicSize(Std.int(50), Std.int(btnAnimDel.height));
        btnAnimDel.updateHitbox();
        btnAnimDel.label.updateHitbox();
        for(p in btnAnimDel.labelOffsets){p.set(-17, 3);}
        tabMENU.add(btnAnimDel);

        var lblAnimFrame = new FlxText(5, txtAnimIndices.y + txtAnimIndices.height + 5, 0, "FrameRate: ", 8); tabMENU.add(lblAnimFrame);
        sprFrame = new FlxUINumericStepper(lblAnimFrame.x + 2, lblAnimFrame.y + 17, 1, 0, 1, 120, 1);
            @:privateAccess arrayFocus.push(cast sprFrame.text_field);
		sprFrame.value = 12;
		sprFrame.name = 'anim_framerate';
		tabMENU.add(sprFrame);

        cbxLoop = new FlxUICheckBox(lblAnimFrame.x + lblAnimFrame.width + 7, lblAnimFrame.y + 15, null, null, "Loop", 0);
		cbxLoop.checked = false;
        tabMENU.add(cbxLoop);

        var lblAnims = new FlxText(sprFrame.x, sprFrame.y + 18, 0, "Animations:", 8); tabMENU.add(lblAnims);
        clAnims = new FlxUICustomList(lblAnims.x, lblAnims.y + 15, [''], function() {
            if(curObject.stageAnims != null && curObject.stageAnims.length > 0){
                var curAnim:Int = clAnims.getSelectedIndex();
                if(curObject.stageAnims.length >= curAnim){
                    var anim:StageAnim = curObject.stageAnims[curAnim];

                    txtAnimName.text = anim.anim;
                    txtAnimSymbol.text = anim.symbol;
                    txtAnimIndices.text = anim.indices.toString().substr(1, anim.indices.toString().length - 2);
                    cbxLoop.checked = anim.loop;
                    sprFrame.value = anim.fps;
                }
            }
		}); tabMENU.add(clAnims);
        clAnims.setWidth(Std.int(MENU.width - 10));

        //
        var line5 = new FlxSprite(5, clAnims.y + clAnims.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line5);
        //

        var lblPartImage = new FlxText(5, line5.y + 5, 0, "Object Image:    ", 8); tabMENU.add(lblPartImage);
        txtPartImage = new FlxUIInputText(lblPartImage.x, lblPartImage.y + 15, Std.int(lblPartImage.width * 1.5), "", 8);
        txtPartImage.name = "PART_IMAGE";
        arrayFocus.push(txtPartImage);
		tabMENU.add(txtPartImage);

        MENU.add(tabMENU);

        //Properties
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
                case
                "STAGE_DIRECTORY":{
                    _stage.Directory = input.text;
                    curStage.reload(_stage);
                }
                case 'PART_IMAGE':{
                    curObject.image = input.text;
                    curStage.reload(_stage);
                }
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            FlxG.log.add(wname);
            switch(wname){
                case 'stageZoom':{_stage.CamZoom = nums.value;}
                case 'stageChroma':{_stage.CamZoom = nums.value;}
            }
        }else if(id == FlxUINumericStepperCustom.CHANGE_EVENT && (sender is FlxUINumericStepperCustom)){
            var nums:FlxUINumericStepperCustom = cast sender;
            var wname = nums.name;
            FlxG.log.add(wname);
            switch(wname){
                case 'posX':{curObject.position[0] = nums.value;}
                case 'posY':{curObject.position[1] = nums.value;}
                case 'scrollX':{curObject.scrollFactor[0] = nums.value;}
                case 'scrollY':{curObject.scrollFactor[1] = nums.value;}
                case 'angle':{curObject.angle = nums.value;}
                case 'alpha':{curObject.alpha = nums.value;}
                case 'scale':{curObject.size = nums.value;}
            }
        }
    }

    function reloadStage(){
        curStage.reload(_stage);
    }

    function replaceStage(id1:Int, id2:Int){
        if(id1 < 0){id1 = 0;}else if(id1 >= _stage.StageData.length){id1 = _stage.StageData.length - 1;}
        if(id2 < 0){id2 = 0;}else if(id2 >= _stage.StageData.length){id2 = _stage.StageData.length - 1;}

        var part1 = _stage.StageData[id1];
        var part2 = _stage.StageData[id2];

        _stage.StageData[id1] = part2;
        _stage.StageData[id2] = part1;
    }

    var _file:FileReference;
    function saveStage(name:String){
        var data:String = Json.stringify(_stage);
    
        if((data != null) && (data.length > 0)){
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, name + ".json");
        }
    }

    function onSaveComplete(_):Void {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved STAGE DATA.");
    }
        
    function onSaveCancel(_):Void {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveError(_):Void{
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.error("Problem saving Stage data");
    }
}