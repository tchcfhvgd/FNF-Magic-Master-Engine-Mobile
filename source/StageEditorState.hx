package;

import Stage.StagePart;
import flixel.input.mouse.FlxMouse;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import SpriteInput;
import SpriteInput.TextButtom;
import SpriteUIMENU.SpriteUIMENU_TAB;
import Stage.StageData;
import Stage.StageSprite;
import Stage.StageAnim;
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

class StageEditorState extends MusicBeatState {
    public static var _stage:StageData;
    var curStage:Stage;
    
    var curObj:Int = 0;
    var curObject:StagePart;

    //TABS
    var TABPROP:SpriteUIMENU;
    var TABDETT:SpriteUIMENU;
    var TABTOOLS:SpriteUIMENU;

    //Cameras
    var camBack:FlxCamera;
    var camGeneral:FlxCamera;
	var camHUD:FlxCamera;

    var CAMERA:FlxSprite;
    var camFollow:FlxObject;
    var mPoint:FlxPoint;

    public static function editStage(stage:StageData = null){
        if(stage != null){_stage = stage;
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

        curStage = new Stage();

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

        TABDETT = new SpriteUIMENU(FlxG.width - 160, 0, 160, FlxG.height);
		TABDETT.cameras = [camHUD];
        TABDETT.TABS.cameras = [camHUD]; 
		TABDETT.curTAB = "TAB_Details";
        add(TABDETT);
		add(TABDETT.TABS);

        TABTOOLS = new SpriteUIMENU(0, 0, FlxG.width - 160, 25);
		TABTOOLS.cameras = [camHUD];
        TABTOOLS.TABS.cameras = [camHUD];
		TABTOOLS.curTAB = "TAB_Tools";
        add(TABTOOLS);
		add(TABTOOLS.TABS);

        TABPROP = new SpriteUIMENU(0, FlxG.height - 100, FlxG.width - 160, 100);
		TABPROP.cameras = [camHUD];
        TABPROP.TABS.cameras = [camHUD];
		TABPROP.curTAB = "TAB_Properties";
        add(TABPROP);
		add(TABPROP.TABS);

        addPropTAB();
        addGenTAB();
        addToolsTAB();

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
        //

        if(canControl){
            if(FlxG.keys.justPressed.ESCAPE){
                FlxG.switchState(new MainMenuState());
            }

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

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
            var label = check.getLabel().text;
            switch(label){

            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            FlxG.log.add(wname);
            if(wname == 'posX'){curObject.position[0] = nums.value;}
            if(wname == 'posY'){curObject.position[1] = nums.value;}
            if(wname == 'scrollX'){curObject.scrollFactor[0] = nums.value;}
            if(wname == 'scrollY'){curObject.scrollFactor[1] = nums.value;}
            if(wname == 'angle'){curObject.angle = nums.value;}
            if(wname == 'alpha'){curObject.alpha = nums.value;}
            if(wname == 'scale'){curObject.size = nums.value;}
        }
    }

    //Menu Stats
    var sprPosX:FlxUINumericStepper;
    var sprPosY:FlxUINumericStepper;
    var sprScrollX:FlxUINumericStepper;
    var sprScrollY:FlxUINumericStepper;
    var sprAng:FlxUINumericStepper;
    var sprScl:FlxUINumericStepper;
    var sprAlp:FlxUINumericStepper;
    //Menu Animations
    var sprFrame:FlxUINumericStepper;
    var cbxLoop:FlxUICheckBox;
    var drpAnims:FlxUIDropDownMenu;
    var txtAnimName:FlxInputText;
    var txtAnimSymbol:FlxInputText;
    var txtAnimIndices:FlxInputText;
    //Part Properties
    var txtPartImage:FlxInputText;
    function addPropTAB(){
        var propTab = new SpriteUIMENU_TAB("TAB_Properties");

        var btnBack = new FlxTypedButton<FlxSprite>(5, 5, function(){curObj--;});
        btnBack.setGraphicSize(Std.int(20), Std.int(43));
        btnBack.updateHitbox();
        propTab.add(btnBack);

        var btnFront = new FlxTypedButton<FlxSprite>(5, btnBack.y + btnBack.height + 6, function(){curObj++;});
        btnFront.setGraphicSize(Std.int(20), Std.int(43));
        btnFront.updateHitbox();
        propTab.add(btnFront);

        //
        var sprLine1 = new FlxSprite(btnBack.x + btnBack.width + 5, 0).makeGraphic(2, Std.int(TABPROP.height), FlxColor.BLACK);
        propTab.add(sprLine1);
        //

        var lblPos = new FlxText(sprLine1.x + 5, 5, 0, "  Position", 8);
        propTab.add(lblPos);

        var btnResPos = new FlxTypedButton<FlxSprite>(lblPos.x + lblPos.width + 3, lblPos.y + 2, function(){
            curObject.position = [0, 0];
        });
        btnResPos.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResPos.setGraphicSize(Std.int(12));
        btnResPos.updateHitbox();
        propTab.add(btnResPos);

        var lblPosX = new FlxText(lblPos.x, lblPos.y + 17, 0, "X:", 8);propTab.add(lblPosX);
        sprPosX = new FlxUINumericStepper(lblPosX.x + lblPosX.width + 5, lblPosX.y, 0.1, 1, -99999, 99999, 1);
		sprPosX.name = 'posX';
		propTab.add(sprPosX);

        var lblPosY = new FlxText(lblPos.x, lblPosX.y + 17, 0, "Y:", 8);propTab.add(lblPosY);
        sprPosY = new FlxUINumericStepper(lblPosY.x + lblPosY.width + 5, lblPosY.y, 0.1, 1, -99999, 99999, 1);
		sprPosY.name = 'posY';
		propTab.add(sprPosY);

        var lblScroll = new FlxText(sprPosX.x + sprPosX.width + 10, lblPos.y, 0, "   Scroll", 8);
        propTab.add(lblScroll);

        var btnResScroll = new FlxTypedButton<FlxSprite>(lblScroll.x + lblScroll.width + 3, lblScroll.y + 2, function(){
            curObject.scrollFactor = [1, 1];
        });
        btnResScroll.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResScroll.setGraphicSize(Std.int(12));
        btnResScroll.updateHitbox();
        propTab.add(btnResScroll);

        var lblScrollX = new FlxText(lblScroll.x, lblScroll.y + 17, 0, "X:", 8);propTab.add(lblScrollX);
        sprScrollX = new FlxUINumericStepper(lblScrollX.x + lblScrollX.width + 5, lblScrollX.y, 0.1, 1, -100, 100, 1);
		sprScrollX.name = 'scrollX';
		propTab.add(sprScrollX);

        var lblScrollY = new FlxText(lblScrollX.x, lblScrollX.y + 17, 0, "Y:", 8);propTab.add(lblScrollY);
        sprScrollY = new FlxUINumericStepper(lblScrollY.x + lblScrollY.width + 5, lblScrollY.y, 0.1, 1, -100, 100, 1);
		sprScrollY.name = 'scrollY';
		propTab.add(sprScrollY);

        var lblFlip = new FlxText(sprScrollX.x + sprScrollX.width + 10, lblScroll.y, 0, "      Flip", 8);
        propTab.add(lblFlip);

        var btnResFlip = new FlxTypedButton<FlxSprite>(lblFlip.x + lblFlip.width + 3, lblFlip.y + 2, function(){
            curObject.dflipX = false;
            curObject.dflipY = false;
        });
        btnResFlip.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResFlip.setGraphicSize(Std.int(12));
        btnResFlip.updateHitbox();
        propTab.add(btnResFlip);

        var btnHoriz = new FlxButton(lblFlip.x, lblFlip.y + 17, "Horizontal", function(){
            curObject.dflipX = !curObject.dflipX;
        });
        propTab.add(btnHoriz);

        var btnVert = new FlxButton(lblFlip.x, btnHoriz.y + 17, "Vertical", function(){
            curObject.dflipY = !curObject.dflipY;
        });
        propTab.add(btnVert);

        var lblAngle = new FlxText(lblPos.x, sprPosY.y + 20, 0, " Angle", 8); propTab.add(lblAngle);
        sprAng = new FlxUINumericStepper(lblPos.x, lblAngle.y + 17, 1, 0, -99999, 99999, 1);
		sprAng.value = curStage.members[curObj].angle;
		sprAng.name = 'angle';
		propTab.add(sprAng);

        var lblScale = new FlxText(sprAng.x + sprAng.width + 10, lblAngle.y, 0, " Scale", 8); propTab.add(lblScale);
        sprScl = new FlxUINumericStepper(lblScale.x, lblScale.y + 17, 0.01, 1, 0, 999, 1);
		sprScl.value = curStage.members[curObj].defScale;
		sprScl.name = 'scale';
		propTab.add(sprScl);

        var lblAlpha = new FlxText(sprScl.x + sprScl.width + 10, lblScale.y, 0, " Alpha", 8); propTab.add(lblAlpha);
        sprAlp = new FlxUINumericStepper(lblAlpha.x, lblAlpha.y + 17, 0.1, 1, 0, 1, 1);
		sprAlp.value = curStage.members[curObj].alpha;
		sprAlp.name = 'alpha';
		propTab.add(sprAlp);

        var lblCenter = new FlxText(sprAlp.x + sprAlp.width + 10, lblAlpha.y, 0, "  Center", 8);
        propTab.add(lblCenter);

        var btnResCent = new FlxTypedButton<FlxSprite>(lblCenter.x - 5, sprAlp.y, function(){
            curStage.members[curObj].screenCenter();
            curObject.position = [curStage.members[curObj].x, curStage.members[curObj].y];
        });
        btnResCent.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResCent.setGraphicSize(Std.int(15));
        btnResCent.updateHitbox();
        propTab.add(btnResCent);

        var btnResCHor = new FlxTypedButton<FlxSprite>(btnResCent.x + btnResCent.width + 5, btnResCent.y, function(){
            curStage.members[curObj].screenCenter();
            curObject.position[0] = curStage.members[curObj].x;
        });
        btnResCHor.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResCHor.setGraphicSize(Std.int(15));
        btnResCHor.updateHitbox();
        propTab.add(btnResCHor);

        var btnResCVer = new FlxTypedButton<FlxSprite>(btnResCHor.x + btnResCHor.width + 5, btnResCHor.y, function(){
            curStage.members[curObj].screenCenter();
            curObject.position[1] = curStage.members[curObj].y;
        });
        btnResCVer.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnResCVer.setGraphicSize(Std.int(15));
        btnResCVer.updateHitbox();
        propTab.add(btnResCVer);

        //
        var sprLine2 = new FlxSprite(btnVert.x + btnVert.width + 5, 0).makeGraphic(2, Std.int(TABPROP.height), FlxColor.BLACK);
        propTab.add(sprLine2);
        //

        var lblAnimFrame = new FlxText(sprLine2.x + 5, lblPos.y, 0, "FrameRate: ", 8); propTab.add(lblAnimFrame);
        sprFrame = new FlxUINumericStepper(lblAnimFrame.x + 2, lblAnimFrame.y + 17, 1, 0, 1, 120, 1);
		sprFrame.value = 12;
		sprFrame.name = 'anim_framerate';
		propTab.add(sprFrame);

        cbxLoop = new FlxUICheckBox(lblAnimFrame.x + lblAnimFrame.width + 7, lblAnimFrame.y + 15, null, null, "Loop", 0);
		cbxLoop.checked = false;
        propTab.add(cbxLoop);

        var lblAnims = new FlxText(sprFrame.x, sprFrame.y + 18, 0, "Animations:", 8); propTab.add(lblAnims);
        drpAnims = new FlxUIDropDownMenu(lblAnims.x, lblAnims.y + 15, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(pressed:String) {
			var curAnim:Int = Std.parseInt(pressed);
			var anim:StageAnim = curObject.stageAnims[curAnim];

			txtAnimName.text = anim.anim;
			txtAnimSymbol.text = anim.symbol;
            txtAnimIndices.text = anim.indices.toString().substr(1, anim.indices.toString().length - 2);
			cbxLoop.checked = anim.loop;
			sprFrame.value = anim.fps;
		});
        drpAnims.width = lblAnimFrame.width + cbxLoop.width;
        propTab.add(drpAnims);

        var lblAnimName = new FlxText(drpAnims.x + drpAnims.width + 5, lblAnimFrame.y, 0,   " Animation Name:  ", 8); propTab.add(lblAnimName);
        txtAnimName = new FlxInputText(lblAnimName.x, lblAnimName.y + 15, Std.int(lblAnimName.width), "", 8);
		propTab.add(txtAnimName);

        var lblAnimSymbol = new FlxText(txtAnimName.x, txtAnimName.y + txtAnimName.height, 0,        " Animation Symbol:", 8); propTab.add(lblAnimSymbol);
        txtAnimSymbol = new FlxInputText(lblAnimSymbol.x, lblAnimSymbol.y + 15, Std.int(lblAnimSymbol.width), "", 8);
		propTab.add(txtAnimSymbol);

        var lblAnimIndices = new FlxText(txtAnimSymbol.x, txtAnimSymbol.y + txtAnimSymbol.height, 0, " Animation Indices:            ", 8); propTab.add(lblAnimIndices);
        txtAnimIndices = new FlxInputText(lblAnimIndices.x, lblAnimIndices.y + 15, Std.int(lblAnimIndices.width), "", 8);
		propTab.add(txtAnimIndices);

        var btnAnimUpdate = new FlxButton(txtAnimName.x + txtAnimName.width + 5, lblAnimFrame.y, "Update", function(){
            
        });
        btnAnimUpdate.setGraphicSize(Std.int(50), Std.int(btnAnimUpdate.height));
        btnAnimUpdate.updateHitbox();
        btnAnimUpdate.label.updateHitbox();
        for(p in btnAnimUpdate.labelOffsets){p.set(-17, 3);}
        propTab.add(btnAnimUpdate);

        var btnAnimAdd = new FlxButton(btnAnimUpdate.x, btnAnimUpdate.y + btnAnimUpdate.height + 2, "Add", function(){
            
        });
        btnAnimAdd.setGraphicSize(Std.int(50), Std.int(btnAnimAdd.height));
        btnAnimAdd.updateHitbox();
        btnAnimAdd.label.updateHitbox();
        for(p in btnAnimAdd.labelOffsets){p.set(-17, 3);}
        propTab.add(btnAnimAdd);

        var btnAnimDel = new FlxButton(btnAnimAdd.x, btnAnimAdd.y + btnAnimAdd.height + 7, "Delete", function(){
            
        });
        btnAnimDel.setGraphicSize(Std.int(50), Std.int(btnAnimDel.height));
        btnAnimDel.updateHitbox();
        btnAnimDel.label.updateHitbox();
        for(p in btnAnimDel.labelOffsets){p.set(-17, 3);}
        propTab.add(btnAnimDel);

        //
        var sprLine3 = new FlxSprite(btnAnimUpdate.x + btnAnimUpdate.width + 5, 0).makeGraphic(2, Std.int(TABPROP.height), FlxColor.BLACK);
        propTab.add(sprLine3);
        //

        var lblPartImage = new FlxText(sprLine3.x + 5, 5, 0, "Object Image:    ", 8); propTab.add(lblPartImage);
        txtPartImage = new FlxInputText(lblPartImage.x, lblPartImage.y + 15, Std.int(lblPartImage.width * 1.5), "", 8);
		propTab.add(txtPartImage);

        var btnImgAdd = new FlxButton(txtPartImage.x, txtPartImage.y + 20, "Add", function(){
            var newObj = new StageSprite(0, 0);
            //newObj.loadGraphic(Paths.image('${}/${}', 'stages'));
            newObj.loadGraphic(Paths.image('Stage/${txtPartImage.text}', 'stages'));

            curStage.insert(curObj, newObj);
        });
        btnImgAdd.setGraphicSize(Std.int(50), Std.int(btnImgAdd.height));
        btnImgAdd.updateHitbox();
        btnImgAdd.label.updateHitbox();
        for(p in btnImgAdd.labelOffsets){p.set(-17, 3);}
        propTab.add(btnImgAdd);

        var btnImgDel = new FlxButton(btnImgAdd.x, btnImgAdd.y + btnImgAdd.height + 2, "Delete", function(){
            var getObj = curObject;
            curObj++;
            curStage.remove(getObj, true);
        });
        btnImgDel.setGraphicSize(Std.int(50), Std.int(btnImgDel.height));
        btnImgDel.updateHitbox();
        btnImgDel.label.updateHitbox();
        for(p in btnImgDel.labelOffsets){p.set(-17, 3);}
        propTab.add(btnImgDel);

        var btnImgUpdate = new FlxButton(btnImgAdd.x + btnImgAdd.width + 5, btnImgAdd.y, "Update", function(){
            curObject.image = txtPartImage.text;
        });
        btnImgUpdate.setGraphicSize(Std.int(50), Std.int(btnImgUpdate.height));
        btnImgUpdate.updateHitbox();
        btnImgUpdate.label.updateHitbox();
        for(p in btnImgUpdate.labelOffsets){p.set(-17, 3);}
        propTab.add(btnImgUpdate);


        TABPROP.add(propTab);

        //Properties
    }

    //Menu General
    var txtStageName:FlxInputText;
    var txtStageDirect:FlxInputText;
    var sprStageZoom:FlxUINumericStepper;
    var sprStageChroma:FlxUINumericStepper;
    function addGenTAB(){
        var propTab = new SpriteUIMENU_TAB("TAB_Details");

        var lblTitleStage = new FlxText(0, 0, TABDETT.width, "Stage Editor:", 16);
        lblTitleStage.alignment = CENTER;
        propTab.add(lblTitleStage);

        //
        var sprLine1 = new FlxSprite(0, TABTOOLS.height - 2).makeGraphic(Std.int(TABDETT.width), 2, FlxColor.BLACK);
        propTab.add(sprLine1);
        //

        var lblStageName = new FlxText(lblTitleStage.x + 5, sprLine1.y + sprLine1.height + 5, TABDETT.width - 10, "Stage Name:", 8); propTab.add(lblStageName);
        txtStageName = new FlxInputText(lblStageName.x, lblStageName.y + 15, Std.int(lblStageName.width), curStage.curStage, 8); propTab.add(txtStageName);

        var btnStageSave = new FlxButton(txtStageName.x, txtStageName.y + txtStageName.height + 3, "Save", function(){
            saveStage(txtStageName.text);
        });
        btnStageSave.setGraphicSize(Std.int(txtStageName.width), Std.int(btnStageSave.height));
        btnStageSave.updateHitbox();
        for(p in btnStageSave.labelOffsets){p.set(30, 3);}
        propTab.add(btnStageSave);

        //
        var sprLine2 = new FlxSprite(0, btnStageSave.y + btnStageSave.height + 5).makeGraphic(Std.int(TABDETT.width), 2, FlxColor.BLACK);
        propTab.add(sprLine2);
        //

        var lblStageZoom = new FlxText(3, sprLine2.y + 5, 0, "Stage Zoom:", 8); propTab.add(lblStageZoom);
        sprStageZoom = new FlxUINumericStepper(lblStageZoom.x + 3, lblStageZoom.y + lblStageZoom.height + 2, 0.1, 1, 0, 1, 1);
        sprStageZoom.value = curStage.zoom;
		sprStageZoom.name = 'stageZoom';
		propTab.add(sprStageZoom);

        var lblStageChroma = new FlxText(lblStageZoom.x + lblStageZoom.width + 10, lblStageZoom.y, 0, "Stage Chroma:", 8); propTab.add(lblStageChroma);
        sprStageChroma = new FlxUINumericStepper(lblStageChroma.x + 3, lblStageChroma.y + lblStageChroma.height + 2, 0.1, 0, -1, 1, 1);
        sprStageChroma.value = curStage.chrome;
		sprStageChroma.name = 'stageChroma';
		propTab.add(sprStageChroma);

        var lblStageDirectory = new FlxText(5, sprStageChroma.y + sprStageChroma.height + 5, txtStageName.width, "Stage Directory:", 8); propTab.add(lblStageDirectory);
        txtStageDirect = new FlxInputText(lblStageDirectory.x, lblStageDirectory.y + 15, Std.int(lblStageDirectory.width), curStage.directory, 8); propTab.add(txtStageDirect);

        var btnStageUpdate = new FlxButton(txtStageDirect.x, txtStageDirect.y + txtStageDirect.height + 3, "Update", function(){
            _stage.Directory = txtStageDirect.text;
        });
        btnStageUpdate.setGraphicSize(Std.int(txtStageDirect.width), Std.int(btnStageUpdate.height));
        btnStageUpdate.updateHitbox();
        for(p in btnStageUpdate.labelOffsets){p.set(30, 3);}
        propTab.add(btnStageUpdate);

        //
        var sprLine3 = new FlxSprite(0, btnStageUpdate.y + btnStageUpdate.height + 5).makeGraphic(Std.int(TABDETT.width), 2, FlxColor.BLACK);
        propTab.add(sprLine3);
        //

        var btnStagePreview = new FlxButton(sprLine3.x + 5, sprLine3.y + sprLine3.height + 3, "Preview", function(){
            
        });
        btnStagePreview.setGraphicSize(Std.int(sprLine3.width - 10), Std.int(btnStagePreview.height));
        btnStagePreview.updateHitbox();
        for(p in btnStagePreview.labelOffsets){p.set(30, 3);}
        propTab.add(btnStagePreview);


        TABDETT.add(propTab);
    }

    function addToolsTAB(){
        var propTab = new SpriteUIMENU_TAB("TAB_Tools");

        //
        var sprLine1 = new FlxSprite(TABTOOLS.width, 0).makeGraphic(2, Std.int(TABTOOLS.height), FlxColor.BLACK);
        propTab.add(sprLine1);
        //

        
        TABTOOLS.add(propTab);
    }

    function reloadStage(){
        curStage.loadStage(_stage);
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