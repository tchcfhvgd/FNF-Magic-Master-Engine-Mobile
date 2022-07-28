package states.editors;

import FlxCustom.FlxUICustomButton;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.*;
import flixel.ui.*;
import flixel.addons.ui.*;
import openfl.display.*;

import haxe.xml.Access;
import flixel.util.FlxColor;
import lime.ui.FileDialog;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxPoint;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;

import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomNumericStepper;
import FlxCustom.FlxUIValueChanger;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class XMLEditorState extends MusicBeatState {
    private static var _XML:Xml;
    private static var _IMG:FlxGraphic;

    var tabFILE:FlxUITabMenu;
    var tabGHOST:FlxUITabMenu;
    var tabSPRITE:FlxUITabMenu;
    
    var point:FlxSprite;

    var imgIcon:FlxSprite;
    var bSprite:FlxSprite;
    var eSprite:FlxSprite;
    
    var arrayFocus:Array<FlxUIInputText> = [];

    var camFollow:FlxObject;

    public static function editXML(?onConfirm:FlxState, ?onBack:FlxState){
        FlxG.sound.music.stop();
        FlxG.switchState(new XMLEditorState(onConfirm, onBack));
    }

    override function create(){
        FlxG.mouse.visible = true;

        var bgGrid:FlxSprite = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height, true, 0xff4d4d4d, 0xff333333);
        bgGrid.cameras = [camGame];
        add(bgGrid);

        //SPRITES
        bSprite = new FlxSprite();
        bSprite.alpha = 0.3;
        bSprite.color = FlxColor.GRAY;
        bSprite.cameras = [camFGame];
        
        eSprite = new FlxSprite();
        eSprite.cameras = [camFGame];

        imgIcon = new FlxSprite(5, 5);
        imgIcon.cameras = [camHUD];

        add(eSprite);
        add(bSprite);

        add(imgIcon);

        point = new FlxSprite(100, 50).makeGraphic(5, 5, FlxColor.WHITE);
        point.cameras = [camFGame];
        add(point);

        tabFILE = new FlxUITabMenu(null, [{name: "Files", label: 'Files'}], true);
        tabFILE.resize(250, 100);
		tabFILE.x = FlxG.width - tabFILE.width;
        tabFILE.camera = camHUD;
        addFILETABS();
        
        tabGHOST = new FlxUITabMenu(null, [{name: "Ghost", label: 'Ghost'}], true);
        tabGHOST.resize(250, 100);
		tabGHOST.y = tabFILE.height;
		tabGHOST.x = tabFILE.x;
        tabGHOST.camera = camHUD;
        addGHOSTTABS();

        tabSPRITE = new FlxUITabMenu(null, [{name: "General", label: 'General'}], true);
        tabSPRITE.resize(250, FlxG.height - tabFILE.height - tabGHOST.height);
        tabSPRITE.y = tabGHOST.y + tabGHOST.height;
		tabSPRITE.x = tabFILE.x;
        tabSPRITE.camera = camHUD;
        addFRAMESTABS();

        add(tabFILE);
        add(tabGHOST);
        add(tabSPRITE);
        
		camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.screenCenter();
        camFGame.follow(camFollow, LOCKON);
		add(camFollow); 

        super.create();
    }

    var pos = [[], []];
    override function update(elapsed:Float){
        var pMouse = FlxG.mouse.getPositionInCameraView(camFGame);

        bSprite.setPosition(point.x, point.y);
        eSprite.setPosition(point.x, point.y);

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){    
            if(FlxG.mouse.justPressedRight){pos = [[camFollow.x, camFollow.y],[pMouse.x, pMouse.y]];}
            if(FlxG.mouse.pressedRight){camFollow.setPosition(pos[0][0] + ((pos[1][0] - pMouse.x) * 1.0), pos[0][1] + ((pos[1][1] - pMouse.y) * 1.0));}

            //if(FlxG.keys.justPressed.SPACE){chrStage.playAnim(clAnims.getSelectedLabel(), true);}

            if(FlxG.keys.pressed.SHIFT){
                if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.1);} 
            }else{
                if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.01);}
            }

            if(FlxG.mouse.justPressedMiddle){camFollow.screenCenter();}
        }
        
		super.update(elapsed);
    }

    private function getFile(_file:FlxUIInputText):Void{
        var fDialog = new FileDialog();
        fDialog.onSelect.add(function(str){_file.text = str;});
        fDialog.browse();
	}
    
    private function loadArchives():Void{
        #if desktop
            if(txtIMAGE.text.length > 0){_IMG = FlxGraphic.fromBitmapData(BitmapData.fromFile(txtIMAGE.text)); _IMG.persist = true;}
            if(txtXML.text.length > 0){_XML = Xml.parse(sys.io.File.getContent(txtXML.text));}
        #end
    }

    private function loadGhostSprites():Void {
        if(_IMG != null && _XML != null){
            bSprite.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());

            var animArr = getNamesArray(new Access(_XML.firstElement()).elements);
            for(anim in animArr){bSprite.animation.addByPrefix(anim, anim);}
            clGCurAnim.setData(animArr);

            stpGCurFrame.value = 0;
        }
    }
    private function loadNormalSprites():Void {
        if(_IMG != null && _XML != null){eSprite.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());}
        
        imgIcon.loadGraphic(_IMG);
        imgIcon.setGraphicSize(Std.int(15 * FlxG.height / 100), Std.int(15 * FlxG.height / 100));
        imgIcon.updateHitbox();
    }

    private function rSprites(force:Bool = true){
        var cFrame:Int = Std.int(stpFCurFrame.value);

        for(i in new Access(_XML.firstElement()).elements){
            if(!i.has.x){i.att.x = "0";}
            if(!i.has.y){i.att.y = "0";}
            if(!i.has.width){i.att.width = "0";}
            if(!i.has.height){i.att.height = "0";}
            if(!i.has.frameX){i.att.frameX = "0";}
            if(!i.has.frameY){i.att.frameY = "0";}
            if(!i.has.frameWidth){i.att.frameWidth = i.att.width;}
            if(!i.has.frameHeight){i.att.frameHeight = i.att.height;}
        }

        //trace(_XML.toString());
        //trace(_IMG != null);
        
        eSprite.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());

        imgIcon.loadGraphic(_IMG);
        imgIcon.setGraphicSize(Std.int(15 * FlxG.height / 100), Std.int(15 * FlxG.height / 100));
        imgIcon.updateHitbox();

        var animArr = getNamesArray(new Access(_XML.firstElement()).elements);

        for(anim in animArr){
            bSprite.animation.addByPrefix(anim, anim);
            eSprite.animation.addByPrefix(anim, anim);
        }

        clCurAnim.setData(animArr);
        clGCurAnim.setData(animArr);

        if(force){
            stpFCurFrame.value = cFrame;
            playAnim(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value));
        }
    }

    public static function getNamesArray(arr:Iterator<Access>):Array<String>{
        var toReturn:Array<String> = new Array<String>();

        for(chr in arr){
            var toDel:String = "";
            for(i in 0...chr.att.name.length){if(i >= chr.att.name.length - 4){toDel = toDel + chr.att.name.charAt(i);}}
            var nChar = chr.att.name.replace(toDel, "");
            if(!toReturn.contains(nChar)){toReturn.push(nChar);}
        }

        return toReturn;
    }
    private function getSubName(AnimName:String, Frame:Int):String{
        var nFrames:String = Std.string(Frame);
        while(nFrames.length < 4){nFrames = "0" + nFrames;}
        trace(AnimName + nFrames);

        return AnimName + nFrames;
    }
    private function getSubTexture(Name:String):Access{
        for(i in new Access(_XML.firstElement()).elements){
            if(i.att.name == Name){
                return i;
            }
        }
        return null;
    }

    //stpFX:FlxUINumericStepper;
    //stpFY:FlxUINumericStepper;
    //stpFFrameX:FlxUINumericStepper;
    //stpFFrameY:FlxUINumericStepper;
    //stpFWidth:FlxUINumericStepper;
    //stpFHeight:FlxUINumericStepper;
    //stpFFrameWidth:FlxUINumericStepper;
    //stpFFrameHeight:FlxUINumericStepper;
    //stpFCurFrame:FlxUICustomNumericStepper;
    //stpGCurFrame:FlxUICustomNumericStepper;
    public function playAnim(AnimName:String, Frame:Int):Void{
        eSprite.animation.play(AnimName, true, false, Frame);
        eSprite.animation.stop();

        var sTexture:Access = getSubTexture(getSubName(AnimName, Frame));
        if(sTexture != null){
            //if(sTexture.att.x != null){stpFX.value = Std.parseInt(sTexture.att.x);}else{stpFX.value = 0;}
            //if(sTexture.att.y != null){stpFY.value = Std.parseInt(sTexture.att.y);}else{stpFY.value = 0;}
            //if(sTexture.att.width != null){stpFWidth.value = Std.parseInt(sTexture.att.width);}else{stpFWidth.value = 0;}
            //if(sTexture.att.height != null){stpFHeight.value = Std.parseInt(sTexture.att.height);}else{stpFHeight.value = 0;}
            //if(sTexture.att.frameX != null){stpFFrameX.value = Std.parseInt(sTexture.att.frameX);}else{stpFFrameX.value = 0;}
            //if(sTexture.att.frameY != null){stpFFrameY.value = Std.parseInt(sTexture.att.frameY);}else{stpFFrameY.value = 0;}
            //if(sTexture.att.frameWidth != null){stpFFrameWidth.value = Std.parseInt(sTexture.att.frameWidth);}else{stpFFrameWidth.value = 0;}
            //if(sTexture.att.frameHeight != null){stpFFrameHeight.value = Std.parseInt(sTexture.att.frameHeight);}else{stpFFrameHeight.value = 0;}
        }

    }
    public function playGhost(AnimName:String, Frame:Int):Void{
        bSprite.animation.play(AnimName, true, false, Frame);
        bSprite.animation.stop();
    }

    var _file:FileReference;
    private function save(){
		var data:String = _XML.toString();

		if((data != null) && (data.length > 0)){
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "test.xml");
		}
	}

	function onSaveComplete(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

    var txtIMAGE:FlxUIInputText;
    var txtXML:FlxUIInputText;
    function addFILETABS():Void{
        var uiFile = new FlxUI(null, tabFILE);
        uiFile.name = "Files";

        var lblIMAGE = new FlxText(5, 5, 0, "IMAGE (File):", 8); uiFile.add(lblIMAGE);
        txtIMAGE = new FlxUIInputText(lblIMAGE.x + lblIMAGE.width + 5, lblIMAGE.y, Std.int(tabFILE.width - lblIMAGE.width - 50), "", 8); uiFile.add(txtIMAGE);
        txtIMAGE.name = "FILE_IMAGE";
        var btnImage:FlxButton = new FlxCustomButton(txtIMAGE.x + txtIMAGE.width + 5, txtIMAGE.y - 3, 30, null, "GET", null, function(){getFile(txtIMAGE);}); uiFile.add(btnImage);

        var lblXML = new FlxText(lblIMAGE.x, lblIMAGE.y + txtIMAGE.height + 10, 0, "XML (File):", 8); uiFile.add(lblXML);
        txtXML = new FlxUIInputText(lblXML.x + lblXML.width + 5, lblXML.y, Std.int(tabFILE.width - lblXML.width - 50), "", 8); uiFile.add(txtXML);
        txtXML.name = "FILE_XML";        
        var btnXML:FlxButton = new FlxCustomButton(txtXML.x + txtXML.width + 5, txtXML.y - 3, 30, null, "GET", null, function(){getFile(txtXML);}); uiFile.add(btnXML);

        var btnImport:FlxButton = new FlxCustomButton(lblXML.x, btnXML.y + btnXML.height + 5, Std.int(tabFILE.width / 2) - 7, null, "IMPORT", null, function(){loadArchives(); loadNormalSprites();}); uiFile.add(btnImport);
        var btnGhostImport:FlxButton = new FlxCustomButton(btnImport.x + btnImport.width + 5, btnImport.y, Std.int(tabFILE.width / 2) - 7, null, "IMPORT GHOST", null, function(){loadArchives(); loadGhostSprites();}); uiFile.add(btnGhostImport);


        tabFILE.addGroup(uiFile);
        tabFILE.scrollFactor.set();
        tabFILE.showTabId("Files");
    }

    var clGCurAnim:FlxUICustomList;
    var stpGCurFrame:FlxUINumericStepper = new FlxUINumericStepper();
    var chkGFlipX:FlxUICheckBox;
    var chkGFlipY:FlxUICheckBox;
    function addGHOSTTABS():Void {
        var uiGhost = new FlxUI(null, tabGHOST);
        uiGhost.name = "Ghost";

        clGCurAnim = new FlxUICustomList(5, 5, Std.int(tabGHOST.width - 10), [], function(lst:FlxUICustomList){
            stpGCurFrame.value = 0;
            playGhost(lst.getSelectedLabel(), Std.int(stpGCurFrame.value));
        }); uiGhost.add(clGCurAnim);

        var lblbGCurFrame = new FlxText(clGCurAnim.x, clGCurAnim.y + clGCurAnim.height + 7, 0, "[Current Frame]: ", 8); uiGhost.add(lblbGCurFrame);
        stpGCurFrame = new FlxUICustomNumericStepper(lblbGCurFrame.x + lblbGCurFrame.width, lblbGCurFrame.y, Std.int(tabGHOST.width - lblbGCurFrame.width) - 10, 1, 0, 0, 999); uiGhost.add(stpGCurFrame);
        stpGCurFrame.name = "GHOST_INDEX";

        chkGFlipX = new FlxUICheckBox(5, lblbGCurFrame.y + lblbGCurFrame.height + 7, null, null, "FlipX Ghost Image"); uiGhost.add(chkGFlipX);
        chkGFlipY = new FlxUICheckBox(chkGFlipX.x + chkGFlipX.width + 5, chkGFlipX.y, null, null, "FlipY Ghost Image"); uiGhost.add(chkGFlipY);

        tabGHOST.addGroup(uiGhost);
        tabGHOST.scrollFactor.set();
        tabGHOST.showTabId("Ghost");
    }

    var clCurAnim:FlxUICustomList;
    var stpFCurFrame:FlxUINumericStepper;
    var chkFlipX:FlxUICheckBox;
    var chkFlipY:FlxUICheckBox;

    var chkSetToAllFrames:FlxUICheckBox;

    var lblCurX:FlxText;
    var lblCurY:FlxText;
    var lblCurWidth:FlxText;
    var lblCurHeight:FlxText;
    var lblCurFrameX:FlxText;
    var lblCurFrameY:FlxText;
    var lblCurFrameWidth:FlxText;
    var lblCurFrameHeight:FlxText;
    private function addFRAMESTABS():Void{
        var uiBase = new FlxUI(null, tabSPRITE);
        uiBase.name = "General";

        clCurAnim = new FlxUICustomList(5, 5, Std.int(tabSPRITE.width - 10)); uiBase.add(clCurAnim);
        clCurAnim.name = "BASE_CHANGE";

        var lblbFCurFrame = new FlxText(clCurAnim.x, clCurAnim.y + clCurAnim.height + 7, 0, "[Current Frame]: ", 8); uiBase.add(lblbFCurFrame);
        stpFCurFrame = new FlxUICustomNumericStepper(lblbFCurFrame.x + lblbFCurFrame.width, lblbFCurFrame.y, Std.int(tabSPRITE.width - lblbFCurFrame.width) - 10, 1, 0, 0, 999); uiBase.add(stpFCurFrame);
        stpFCurFrame.name = "FRAME_INDEX";

        chkFlipX = new FlxUICheckBox(5, lblbFCurFrame.y + lblbFCurFrame.height + 5, null, null, "FlipX Image"); uiBase.add(chkFlipX);
        chkFlipY = new FlxUICheckBox(chkFlipX.x + chkFlipX.width + 5, chkFlipX.y, null, null, "FlipY Image"); uiBase.add(chkFlipY);

        chkSetToAllFrames = new FlxUICheckBox(chkFlipX.x, chkFlipX.y + chkFlipX.height + 10, null, null, "Change on All Frames", Std.int(tabSPRITE.width) - 10); uiBase.add(chkSetToAllFrames);

        lblCurX = new FlxText(chkSetToAllFrames.x, chkSetToAllFrames.y + chkSetToAllFrames.height + 7, 0, "X: [0]"); uiBase.add(lblCurX);
        var vchCurX = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurX.y - 1, 100, function(value:Float){}); uiBase.add(vchCurX);
        lblCurY = new FlxText(lblCurX.x, lblCurX.y + lblCurX.height + 3, 0, "Y: [0]"); uiBase.add(lblCurY);
        var vchCurY = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurY.y - 1, 100, function(value:Float){}); uiBase.add(vchCurY);
        
        lblCurWidth = new FlxText(lblCurY.x, lblCurY.y + lblCurY.height + 7, 0, "Width: [0]"); uiBase.add(lblCurWidth);
        var vchCurWidth = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurWidth.y - 1, 100, function(value:Float){}); uiBase.add(vchCurWidth);
        lblCurHeight = new FlxText(lblCurWidth.x, lblCurWidth.y + lblCurWidth.height + 3, 0, "Height: [0]"); uiBase.add(lblCurHeight);
        var vchCurHeight = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurHeight.y - 1, 100, function(value:Float){}); uiBase.add(vchCurHeight);
        
        lblCurFrameX = new FlxText(lblCurHeight.x, lblCurHeight.y + lblCurHeight.height + 7, 0, "FrameX: [0]"); uiBase.add(lblCurFrameX);
        var vchCurFrameX = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurFrameX.y - 1, 100, function(value:Float){}); uiBase.add(vchCurFrameX);
        lblCurFrameY = new FlxText(lblCurFrameX.x, lblCurFrameX.y + lblCurFrameX.height + 3, 0, "FrameY: [0]"); uiBase.add(lblCurFrameY);
        var vchCurFrameY = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurFrameY.y - 1, 100, function(value:Float){}); uiBase.add(vchCurFrameY);
        
        lblCurFrameWidth = new FlxText(lblCurFrameY.x, lblCurFrameY.y + lblCurFrameY.height + 7, 0, "FrameWidth: [0]"); uiBase.add(lblCurFrameWidth);
        var vchCurFrameWidth = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurFrameWidth.y - 1, 100, function(value:Float){}); uiBase.add(vchCurFrameWidth);
        lblCurFrameHeight = new FlxText(lblCurFrameWidth.x, lblCurFrameWidth.y + lblCurFrameWidth.height + 3, 0, "FrameHeight: [0]"); uiBase.add(lblCurFrameHeight);
        var vchCurFrameHeight = new FlxUIValueChanger(tabSPRITE.width - 105, lblCurFrameHeight.y - 1, 100, function(value:Float){}); uiBase.add(vchCurFrameHeight);

        var lblFrameName = new FlxText(5, lblCurFrameHeight.y + lblCurFrameHeight.height + 10, Std.int(tabSPRITE.width) - 10, "[Frame Name]"); uiBase.add(lblFrameName);
        lblFrameName.alignment = CENTER;
        var txtFrameName = new FlxUIInputText(5, lblFrameName.y + lblFrameName.height, Std.int(tabSPRITE.width) - 10, ""); uiBase.add(txtFrameName);
        var btnAddFrame = new FlxUICustomButton(5, txtFrameName.y + txtFrameName.height + 3, Std.int(tabSPRITE.width / 2) - 7, null, "Create Frame", FlxColor.fromRGB(94, 255, 99), function(){
            
        }); uiBase.add(btnAddFrame);
        var btnDelFrame = new FlxUICustomButton(btnAddFrame.x + btnAddFrame.width + 5, btnAddFrame.y, Std.int(tabSPRITE.width / 2) - 7, null, "Delete Frame", FlxColor.fromRGB(255, 94, 94), function(){
            
        }); uiBase.add(btnDelFrame);


        tabSPRITE.addGroup(uiBase);
        tabSPRITE.scrollFactor.set();
        tabSPRITE.showTabId("General");
    }
    
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if((sender is FlxUICheckBox)){
            var check:FlxUICheckBox = cast sender;
            var label = check.getLabel().text;

            switch(id){
                case FlxUICheckBox.CLICK_EVENT:{
                    switch(label){
                        default:{trace("[FlxUICheckBox]: Works!");}
                        case "FlipX Ghost Image":{bSprite.flipX = check.checked;}
                        case "FlipY Ghost Image":{bSprite.flipY = check.checked;}
                    }
                }
            }
        }else if((sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;

            switch(id){
                case FlxUIInputText.CHANGE_EVENT:{
                    switch(wname){
                        default:{trace("[FlxUIInputText]: Works!");}
                    }
                }
            }
        }else if((sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;

            switch(id){
                case FlxUIDropDownMenu.CLICK_EVENT:{
                    switch(wname){
                        default:{trace("[FlxUIDropDownMenu]: Works!");}
                    }
                }
            }
        }else if((sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;

            switch(id){
                case FlxUINumericStepper.CHANGE_EVENT:{
                    switch(wname){
                        default:{trace("[FlxUINumericStepper]: Works!");}
                        case "FRAME_X":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.x = Std.string(nums.value);
                            trace(sTexture.att.x);
                            rSprites();
                        }
                        case "FRAME_Y":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.y = Std.string(nums.value);
                            trace(sTexture.att.y);
                            rSprites();
                        }
                        case "FRAME_WIDTH":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.width = Std.string(nums.value);
                            trace(sTexture.att.width);
                            rSprites();
                        }
                        case "FRAME_HEIGHT":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.height = Std.string(nums.value);
                            trace(sTexture.att.height);
                            rSprites();
                        }
                        case "FRAME_FrameX":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameX = Std.string(nums.value);
                            trace(sTexture.att.frameX);
                            rSprites();
                        }
                        case "FRAME_FrameY":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameY = Std.string(nums.value);
                            trace(sTexture.att.frameY);
                            rSprites();
                        }
                        case "FRAME_FrameWIDTH":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameWidth = Std.string(nums.value);
                            trace(sTexture.att.frameWidth);
                            rSprites();
                        }
                        case "FRAME_FrameHEIGHT":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameHeight = Std.string(nums.value);
                            trace(sTexture.att.frameHeight);
                            rSprites();
                        }
                        case "FRAME_INDEX":{
                            if(Std.int(nums.value) >= eSprite.animation.curAnim.frames.length){nums.value = 0;}
                            playAnim(clCurAnim.getSelectedLabel(), Std.int(nums.value));
                        }
                        case "GHOST_INDEX":{
                            if(bSprite == null || bSprite.animation.curAnim == null){return;}
                            if(Std.int(nums.value) < 0){nums.value = bSprite.animation.curAnim.frames.length - 1;}
                            if(Std.int(nums.value) >= bSprite.animation.curAnim.frames.length){nums.value = 0;}
                            playGhost(clGCurAnim.getSelectedLabel(), Std.int(nums.value));
                        }
                    }
                }
            }        
        }else if((sender is FlxUIValueChanger)){
            var nums:FlxUIValueChanger = cast sender;
            var wname = nums.name;
                
            switch(id){
                case FlxUIValueChanger.CLICK_MINUS:{
                    switch(wname){
                        case "FRAME_ALL_X":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.x = Std.string(Std.parseInt(sTexture.att.x) - Std.int(nums.value));
                                trace(sTexture.att.x);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_Y":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.y = Std.string(Std.parseInt(sTexture.att.y) - Std.int(nums.value));
                                trace(sTexture.att.y);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_WIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.width = Std.string(Std.parseInt(sTexture.att.width) - Std.int(nums.value));
                                trace(sTexture.att.width);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_HEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.height = Std.string(Std.parseInt(sTexture.att.height) - Std.int(nums.value));
                                trace(sTexture.att.height);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameX":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameX = Std.string(Std.parseInt(sTexture.att.frameX) - Std.int(nums.value));
                                trace(sTexture.att.frameX);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameY":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameY = Std.string(Std.parseInt(sTexture.att.frameY) - Std.int(nums.value));
                                trace(sTexture.att.frameY);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameWIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameWidth = Std.string(Std.parseInt(sTexture.att.frameWidth) - Std.int(nums.value));
                                trace(sTexture.att.frameWidth);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameHEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameHeight = Std.string(Std.parseInt(sTexture.att.frameHeight) - Std.int(nums.value));
                                trace(sTexture.att.frameHeight);
                            
                            }
                            rSprites();
                        }
                    }
                }
                case FlxUIValueChanger.CLICK_PLUS:{
                    switch(wname){
                        case "FRAME_ALL_X":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.x = Std.string(Std.parseInt(sTexture.att.x) + Std.int(nums.value));
                                trace(sTexture.att.x);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_Y":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.y = Std.string(Std.parseInt(sTexture.att.y) + Std.int(nums.value));
                                trace(sTexture.att.y);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_WIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.width = Std.string(Std.parseInt(sTexture.att.width) + Std.int(nums.value));
                                trace(sTexture.att.width);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_HEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.height = Std.string(Std.parseInt(sTexture.att.height) + Std.int(nums.value));
                                trace(sTexture.att.height);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameX":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameX = Std.string(Std.parseInt(sTexture.att.frameX) + Std.int(nums.value));
                                trace(sTexture.att.frameX);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameY":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameY = Std.string(Std.parseInt(sTexture.att.frameY) + Std.int(nums.value));
                                trace(sTexture.att.frameY);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameWIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameWidth = Std.string(Std.parseInt(sTexture.att.frameWidth) + Std.int(nums.value));
                                trace(sTexture.att.frameWidth);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameHEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));
                                sTexture.att.frameHeight = Std.string(Std.parseInt(sTexture.att.frameHeight) + Std.int(nums.value));
                                trace(sTexture.att.frameHeight);
                            
                            }
                            rSprites();
                        }
                    }
                }
            }
        }else if((sender is FlxUICustomList)){
            var nums:FlxUICustomList = cast sender;
            var wname = nums.name;
            
            switch(id){
                case FlxUICustomList.CHANGE_EVENT:{
                    switch(wname){
                        default:{trace("[FlxUICustomList]: Works!");}
                        case "BASE_CHANGE":{
                            stpFCurFrame.value = 0;
                            playAnim(nums.getSelectedLabel(), Std.int(stpFCurFrame.value));
                        }
                        case "GHOST_CHANGE":{
                        }
                    }
                }
            }
        }
    }
}