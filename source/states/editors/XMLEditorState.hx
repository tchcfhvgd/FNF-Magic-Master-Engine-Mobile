package states.editors;

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
import flixel.math.FlxPoint;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;

import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUINumericStepperCustom;
import FlxCustom.FlxUIValueChanger;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class XMLEditorState extends MusicBeatState {
    private static var _XML:Xml;
    private static var _IMG:BitmapData;

    var tabFILE:FlxUITabMenu;
    var tabFRAMES:FlxUITabMenu;
    
    var point:FlxSprite;
    var bSprite:FlxSprite;
    var eSprite_b:FlxSprite;
    var eSprite:FlxSprite;
    var eSprite_f:FlxSprite;
    var imgIcon:FlxSprite;

    public static function editXML(?onConfirm:FlxState, ?onBack:FlxState){
        FlxG.sound.music.stop();
        FlxG.switchState(new XMLEditorState(onConfirm, onBack));
    }

    override function create(){
        FlxG.mouse.visible = true;

        var bg = new FlxSprite().loadGraphic(Paths.image('menuBG', 'preload'));
        bg.camera = camGame;
        add(bg);

        //SPRITES
        bSprite = new FlxSprite();
        bSprite.alpha = 0.3;
        bSprite.color = FlxColor.GRAY;
        bSprite.cameras = [camFGame];

        eSprite_b = new FlxSprite();
        eSprite_b.alpha = 0.3;
        eSprite_b.color = FlxColor.BLUE;
        eSprite_b.cameras = [camFGame];
        
        eSprite = new FlxSprite();
        eSprite.cameras = [camFGame];

        eSprite_f = new FlxSprite();
        eSprite_f.alpha = 0.3;
        eSprite_f.color = FlxColor.GREEN;
        eSprite_f.cameras = [camFGame];

        imgIcon = new FlxSprite(5, 5);
        imgIcon.cameras = [camHUD];

        add(eSprite_b);
        add(eSprite);
        add(eSprite_f);
        add(bSprite);

        add(imgIcon);

        point = new FlxSprite(100, 50).makeGraphic(5, 5, FlxColor.BLACK);
        point.cameras = [camFGame];
        add(point);

        tabFILE = new FlxUITabMenu(null, [{name: "General", label: 'General'}], true);
        tabFILE.resize(250, 140);
		tabFILE.x = FlxG.width - tabFILE.width;
        tabFILE.camera = camHUD;
        addFILETABS();

        tabFRAMES = new FlxUITabMenu(null, [{name: "Frames", label: 'Frames'}], true);
        tabFRAMES.resize(250, FlxG.height - tabFILE.height);
        tabFRAMES.y = tabFILE.height;
		tabFRAMES.x = FlxG.width - tabFRAMES.width;
        tabFRAMES.camera = camHUD;
        addFRAMESTABS();

        add(tabFILE);
        add(tabFRAMES);

        super.create();
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        bSprite.setPosition(point.x, point.y);
        eSprite_b.setPosition(point.x, point.y);
        eSprite.setPosition(point.x, point.y);
        eSprite_f.setPosition(point.x, point.y);

        if(FlxG.keys.justPressed.R){rSprites();}
        if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){save();}
        if(FlxG.keys.pressed.SHIFT){
            if(FlxG.keys.pressed.A){point.x -= 5;}
            if(FlxG.keys.pressed.S){point.y += 5;}
            if(FlxG.keys.pressed.W){point.y -= 5;}
            if(FlxG.keys.pressed.D){point.x += 5;}
            if(FlxG.keys.pressed.Q){camFGame.zoom -= 0.5;}
            if(FlxG.keys.pressed.E){camFGame.zoom += 0.5;}
        }else{
            if(FlxG.keys.pressed.A){point.x -= 10;}
            if(FlxG.keys.pressed.S){point.y += 10;}
            if(FlxG.keys.pressed.W){point.y -= 10;}
            if(FlxG.keys.pressed.D){point.x += 10;}
            if(FlxG.keys.pressed.Q){camFGame.zoom -= 0.1;}
            if(FlxG.keys.pressed.E){camFGame.zoom += 0.1;}
        }
    }

    private function getFile(_file:FlxUIInputText):Void{
        var fDialog = new FileDialog();
        fDialog.onSelect.add(function(str){_file.text = str;});
        fDialog.browse();
	}
    
    private function impSprite(fXML:String):Void{
        #if desktop
            _XML = Xml.parse(sys.io.File.getContent(fXML));
            rSprites(false);
        #end
    }

    private function rSprites(force:Bool = true){
        var cFrame:Int = Std.int(stpFCurFrame.value);

        #if desktop
            _IMG = BitmapData.fromFile(txtIMAGE.text);
        #end

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
        
        bSprite.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());
        eSprite_b.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());
        eSprite.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());
        eSprite_f.frames = FlxAtlasFrames.fromSparrow(_IMG, _XML.toString());

        imgIcon.loadGraphic(_IMG);
        imgIcon.setGraphicSize(Std.int(15 * FlxG.width / 100), Std.int(15 * FlxG.height / 100));
        imgIcon.updateHitbox();

        var animArr = getNamesArray(new Access(_XML.firstElement()).elements);

        for(anim in animArr){
            bSprite.animation.addByPrefix(anim, anim);
            eSprite_b.animation.addByPrefix(anim, anim);
            eSprite.animation.addByPrefix(anim, anim);
            eSprite_f.animation.addByPrefix(anim, anim);
        }

        clCurAnim.setData(animArr);
        clGCurAnim.setData(animArr);

        if(force){
            stpFCurFrame.value = cFrame;
            playAnim(clCurAnim.getSelectedLabel(), Std.int(stpFCurFrame.value));
        }
    }

    

    private function getNamesArray(arr:Iterator<Access>):Array<String>{
        var toReturn:Array<String> = new Array<String>();

        for(chr in arr){
            var toDel:String = "";
            for(i in 0...chr.att.name.length){if(i >= chr.att.name.length - 4){toDel = toDel + chr.att.name.charAt(i);}}
            var nChar = chr.att.name.replace(toDel, ""); trace(nChar);
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
    //stpFCurFrame:FlxUINumericStepperCustom;
    //stpGCurFrame:FlxUINumericStepperCustom;
    public function playAnim(AnimName:String, Frame:Int):Void{
        eSprite.animation.play(AnimName, true, false, Frame);
        eSprite.animation.stop();

        if(Frame - 1 > 0){
            eSprite_b.visible = true;
            eSprite_b.animation.play(AnimName, true, false, Frame - 1);
            eSprite_b.animation.stop();
        }else{
            eSprite_b.visible = false;
        }
        if(Frame + 1 < eSprite.animation.curAnim.frames.length - 1){
            eSprite_f.visible = true;
            eSprite_f.animation.play(AnimName, true, false, Frame + 1);
            eSprite_f.animation.stop();
        }else{
            eSprite_f.visible = false;
        }

        var sTexture:Access = getSubTexture(getSubName(AnimName, Frame));
        if(sTexture != null){
            if(sTexture.att.x != null){stpFX.value = Std.parseInt(sTexture.att.x);}else{stpFX.value = 0;}
            if(sTexture.att.y != null){stpFY.value = Std.parseInt(sTexture.att.y);}else{stpFY.value = 0;}
            if(sTexture.att.width != null){stpFWidth.value = Std.parseInt(sTexture.att.width);}else{stpFWidth.value = 0;}
            if(sTexture.att.height != null){stpFHeight.value = Std.parseInt(sTexture.att.height);}else{stpFHeight.value = 0;}
            if(sTexture.att.frameX != null){stpFFrameX.value = Std.parseInt(sTexture.att.frameX);}else{stpFFrameX.value = 0;}
            if(sTexture.att.frameY != null){stpFFrameY.value = Std.parseInt(sTexture.att.frameY);}else{stpFFrameY.value = 0;}
            if(sTexture.att.frameWidth != null){stpFFrameWidth.value = Std.parseInt(sTexture.att.frameWidth);}else{stpFFrameWidth.value = 0;}
            if(sTexture.att.frameHeight != null){stpFFrameHeight.value = Std.parseInt(sTexture.att.frameHeight);}else{stpFFrameHeight.value = 0;}
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
        uiFile.name = "General";

        var ttlFiles = new FlxText(5, 10, Std.int(tabFILE.width - 10), "| FILES |", 12); uiFile.add(ttlFiles);
        ttlFiles.alignment = CENTER;

        var lblIMAGE = new FlxText(ttlFiles.x, ttlFiles.y + ttlFiles.height + 10, 0, "IMAGE (File):", 8); uiFile.add(lblIMAGE);
        txtIMAGE = new FlxUIInputText(lblIMAGE.x + lblIMAGE.width + 5, lblIMAGE.y, Std.int(tabFILE.width - lblIMAGE.width - 50), "", 8); uiFile.add(txtIMAGE);
        txtIMAGE.name = "FILE_IMAGE";
        var btnImage:FlxButton = new FlxButton(txtIMAGE.x + txtIMAGE.width + 5, txtIMAGE.y - 3, "GET", function(){getFile(txtIMAGE);}); uiFile.add(btnImage);
        btnImage.setSize(30, Std.int(btnImage.height));
        btnImage.setGraphicSize(30, Std.int(btnImage.height));
        btnImage.centerOffsets();
        btnImage.label.fieldWidth = btnImage.width;

        var lblXML = new FlxText(lblIMAGE.x, lblIMAGE.y + txtIMAGE.height + 10, 0, "XML (File):", 8); uiFile.add(lblXML);
        txtXML = new FlxUIInputText(lblXML.x + lblXML.width + 5, lblXML.y, Std.int(tabFILE.width - lblXML.width - 50), "", 8); uiFile.add(txtXML);
        txtXML.name = "FILE_XML";
        var btnXML:FlxButton = new FlxButton(txtXML.x + txtXML.width + 5, txtXML.y - 3, "GET", function(){getFile(txtXML);}); uiFile.add(btnXML);
        btnXML.setSize(30, Std.int(btnXML.height));
        btnXML.setGraphicSize(30, Std.int(btnXML.height));
        btnXML.centerOffsets();
        btnXML.label.fieldWidth = btnXML.width;

        var btnImport:FlxButton = new FlxButton(lblXML.x, btnXML.y + btnXML.height + 10, "IMPORT", function(){impSprite(txtXML.text);}); uiFile.add(btnImport);
        btnImport.setSize(Std.int(tabFILE.width - 10), Std.int(btnImport.height));
        btnImport.setGraphicSize(Std.int(tabFILE.width - 10), Std.int(btnImport.height));
        btnImport.centerOffsets();
        btnImport.label.fieldWidth = btnImport.width;


        tabFILE.addGroup(uiFile);
        tabFILE.scrollFactor.set();
        tabFILE.showTabId("General");
    }

    var clCurAnim:FlxUICustomList;
    var clGCurAnim:FlxUICustomList;
    var stpFX:FlxUINumericStepper;
    var stpFY:FlxUINumericStepper;
    var stpFFrameX:FlxUINumericStepper;
    var stpFFrameY:FlxUINumericStepper;
    var stpFWidth:FlxUINumericStepper;
    var stpFHeight:FlxUINumericStepper;
    var stpFFrameWidth:FlxUINumericStepper;
    var stpFFrameHeight:FlxUINumericStepper;
    var stpFCurFrame:FlxUINumericStepper;
    var stpGCurFrame:FlxUINumericStepper;

    var vchAX:FlxUIValueChanger;
    var vchAY:FlxUIValueChanger;
    var vchAWidth:FlxUIValueChanger;
    var vchAHeight:FlxUIValueChanger;
    var vchAFrameX:FlxUIValueChanger;
    var vchAFrameY:FlxUIValueChanger;
    var vchAFrameWidth:FlxUIValueChanger;
    var vchAFrameHeight:FlxUIValueChanger;
    private function addFRAMESTABS():Void{
        var uiBase = new FlxUI(null, tabFRAMES);
        uiBase.name = "Frames";

        var ttAnimFrames = new FlxText(5, 10, Std.int(tabFRAMES.width - 10), "| ANIMATION FRAMES |", 12); uiBase.add(ttAnimFrames);
        ttAnimFrames.alignment = CENTER;

        var lblSCurAnim = new FlxText(ttAnimFrames.x, ttAnimFrames.y + ttAnimFrames.height + 15, Std.int(tabFRAMES.width - 10), "[Current Animation]", 8); uiBase.add(lblSCurAnim);
        lblSCurAnim.alignment = CENTER;
        clCurAnim = new FlxUICustomList(lblSCurAnim.x, lblSCurAnim.y + lblSCurAnim.height + 7, Std.int(tabFRAMES.width - 10)); uiBase.add(clCurAnim);
        clCurAnim.name = "BASE_CHANGE";

        var lblbFCurFrame = new FlxText(clCurAnim.x, clCurAnim.y + clCurAnim.height + 15, 0, "[Current Frame]:", 8); uiBase.add(lblbFCurFrame);
        stpFCurFrame = new FlxUINumericStepperCustom(lblbFCurFrame.x + lblbFCurFrame.width, lblbFCurFrame.y, 120, 1, 0, 0, 999); uiBase.add(stpFCurFrame);
        stpFCurFrame.name = "FRAME_INDEX";

        var lblFX = new FlxText(lblbFCurFrame.x, lblbFCurFrame.y + lblbFCurFrame.height + 15, 0, "[X]:", 8); uiBase.add(lblFX);
        stpFX = new FlxUINumericStepper(lblFX.x + lblFX.width, lblFX.y, 1, 0, -99999, 99999); uiBase.add(stpFX);
        stpFX.name = "FRAME_X";
        var lblFY = new FlxText(stpFX.x + stpFX.width + 10, stpFX.y, 0, "[Y]:", 8); uiBase.add(lblFY);
        stpFY = new FlxUINumericStepper(lblFY.x + lblFY.width, lblFY.y, 1, 0, -99999, 99999); uiBase.add(stpFY);
        stpFY.name = "FRAME_Y";

        var lblFWidth = new FlxText(lblFX.x, lblFX.y + lblFX.height + 15, 0, "[Width]:", 8); uiBase.add(lblFWidth);
        stpFWidth = new FlxUINumericStepper(lblFWidth.x + lblFWidth.width, lblFWidth.y, 1, 0, -99999, 99999); uiBase.add(stpFWidth);
        stpFWidth.name = "FRAME_WIDTH";
        var lblFHeight = new FlxText(stpFWidth.x + stpFWidth.width + 10, stpFWidth.y, 0, "[Height]:", 8); uiBase.add(lblFHeight);
        stpFHeight = new FlxUINumericStepper(lblFHeight.x + lblFHeight.width, lblFHeight.y, 1, 0, -99999, 99999); uiBase.add(stpFHeight);
        stpFHeight.name = "FRAME_HEIGHT";

        var lblFFrameX = new FlxText(lblFWidth.x, lblFWidth.y + lblFWidth.height + 15, 0, "[FrameX]:", 8); uiBase.add(lblFFrameX);
        stpFFrameX = new FlxUINumericStepper(lblFFrameX.x + lblFFrameX.width, lblFFrameX.y, 1, 0, -99999, 99999); uiBase.add(stpFFrameX);
        stpFFrameX.name = "FRAME_FrameX";
        var lblFFrameY = new FlxText(stpFFrameX.x + stpFFrameX.width + 10, stpFFrameX.y, 0, "[FrameY]:", 8); uiBase.add(lblFFrameY);
        stpFFrameY = new FlxUINumericStepper(lblFFrameY.x + lblFFrameY.width, lblFFrameY.y, 1, 0, -99999, 99999); uiBase.add(stpFFrameY);
        stpFFrameY.name = "FRAME_FrameY";

        var lblFFrameWidth = new FlxText(lblFFrameX.x, lblFFrameX.y + lblFFrameX.height + 15, 0, "[F_Width]:", 8); uiBase.add(lblFFrameWidth);
        stpFFrameWidth = new FlxUINumericStepper(lblFFrameWidth.x + lblFFrameWidth.width, lblFFrameWidth.y, 1, 0, -99999, 99999); uiBase.add(stpFFrameWidth);
        stpFFrameWidth.name = "FRAME_FrameWIDTH";
        var lblFFrameHeight = new FlxText(stpFFrameWidth.x + stpFFrameWidth.width + 10, stpFFrameWidth.y, 0, "[F_Height]:", 8); uiBase.add(lblFFrameHeight);
        stpFFrameHeight = new FlxUINumericStepper(lblFFrameHeight.x + lblFFrameHeight.width, lblFFrameHeight.y, 1, 0, -99999, 99999); uiBase.add(stpFFrameHeight);
        stpFFrameHeight.name = "FRAME_FrameHEIGHT";

        var ttAnims = new FlxText(5, lblFFrameWidth.y + lblFFrameWidth.height + 20, Std.int(tabFRAMES.width - 10), "| ANIMATION ALL |", 12); uiBase.add(ttAnims);
        ttAnims.alignment = CENTER;

        var lblAX = new FlxText(ttAnims.x, ttAnims.y + ttAnims.height + 15, 0, "[X]:", 8); uiBase.add(lblAX);
        vchAX = new FlxUIValueChanger(lblAX.x + lblAX.width, lblAX.y, Std.int((tabFRAMES.width / 2) - (lblAX.width + 5)) - 10); uiBase.add(vchAX);
        vchAX.name = "FRAME_ALL_X";
        var lblAY = new FlxText(vchAX.x + vchAX.width + 10, vchAX.y, 0, "[Y]:", 8); uiBase.add(lblAY);
        vchAY = new FlxUIValueChanger(lblAY.x + lblAY.width, lblAY.y, Std.int((tabFRAMES.width / 2) - (lblAY.width + 5)) - 10); uiBase.add(vchAY);
        vchAY.name = "FRAME_ALL_Y";

        var lblAWidth = new FlxText(lblAX.x, lblAX.y + lblAX.height + 15, 0, "[Width]:", 8); uiBase.add(lblAWidth);
        vchAWidth = new FlxUIValueChanger(lblAWidth.x + lblAWidth.width, lblAWidth.y, Std.int((tabFRAMES.width / 2) - (lblAWidth.width + 5)) - 10); uiBase.add(vchAWidth);
        vchAWidth.name = "FRAME_ALL_WIDTH";
        var lblAHeight = new FlxText(vchAWidth.x + vchAWidth.width + 10, vchAWidth.y, 0, "[Height]:", 8); uiBase.add(lblAHeight);
        vchAHeight = new FlxUIValueChanger(lblAHeight.x + lblAHeight.width, lblAHeight.y, Std.int((tabFRAMES.width / 2) - (lblAHeight.width + 5)) - 10); uiBase.add(vchAHeight);
        vchAHeight.name = "FRAME_ALL_HEIGHT";

        var lblAFrameX = new FlxText(lblAWidth.x, lblAWidth.y + lblAWidth.height + 15, 0, "[FrameX]:", 8); uiBase.add(lblAFrameX);
        vchAFrameX = new FlxUIValueChanger(lblAFrameX.x + lblAFrameX.width, lblAFrameX.y, Std.int((tabFRAMES.width / 2) - (lblAHeight.width + 5)) - 10); uiBase.add(vchAFrameX);
        vchAFrameX.name = "FRAME_ALL_FrameX";
        var lblAFrameY = new FlxText(vchAFrameX.x + vchAFrameX.width + 10, vchAFrameX.y, 0, "[FrameY]:", 8); uiBase.add(lblAFrameY);
        vchAFrameY = new FlxUIValueChanger(lblAFrameY.x + lblAFrameY.width, lblAFrameY.y, Std.int((tabFRAMES.width / 2) - (lblAHeight.width + 5)) - 10); uiBase.add(vchAFrameY);
        vchAFrameY.name = "FRAME_ALL_FrameY";

        var lblAFrameWidth = new FlxText(lblAFrameX.x, lblAFrameX.y + lblAFrameX.height + 15, 0, "[F_Width]:", 8); uiBase.add(lblAFrameWidth);
        vchAFrameWidth = new FlxUIValueChanger(lblAFrameWidth.x + lblAFrameWidth.width, lblAFrameWidth.y, Std.int((tabFRAMES.width / 2) - (lblAHeight.width + 5)) - 10); uiBase.add(vchAFrameWidth);
        vchAFrameWidth.name = "FRAME_ALL_FrameWIDTH";
        var lblAFrameHeight = new FlxText(vchAFrameWidth.x + vchAFrameWidth.width + 10, vchAFrameWidth.y, 0, "[F_Height]:", 8); uiBase.add(lblAFrameHeight);
        vchAFrameHeight = new FlxUIValueChanger(lblAFrameHeight.x + lblAFrameHeight.width, lblAFrameHeight.y, Std.int((tabFRAMES.width / 2) - (lblAHeight.width + 5)) - 10); uiBase.add(vchAFrameHeight);
        vchAFrameHeight.name = "FRAME_ALL_FrameHEIGHT";

        var btnASetFrameSize = new FlxButton(5, lblAFrameWidth.y + lblAFrameWidth.height + 15, "Set FrameSize", function(){
            for(i in 0...eSprite.animation.curAnim.frames.length){
                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedLabel(), i));

                sTexture.att.frameWidth = sTexture.att.width; trace(sTexture.att.frameWidth);
                sTexture.att.frameHeight = sTexture.att.height; trace(sTexture.att.frameHeight);
            }
            rSprites();
        }); uiBase.add(btnASetFrameSize);
        btnASetFrameSize.setSize(Std.int(tabFRAMES.width - 10), Std.int(btnASetFrameSize.height));
        btnASetFrameSize.setGraphicSize(Std.int(tabFRAMES.width - 10), Std.int(btnASetFrameSize.height));
        btnASetFrameSize.centerOffsets();
        btnASetFrameSize.label.fieldWidth = btnASetFrameSize.width;

        var ttGhost = new FlxText(5, btnASetFrameSize.y + btnASetFrameSize.height + 20, Std.int(tabFRAMES.width - 10), "| Ghost |", 12); uiBase.add(ttGhost);
        ttGhost.alignment = CENTER;

        var lblGCurAnim = new FlxText(ttGhost.x, ttGhost.y + ttGhost.height + 10, Std.int(tabFRAMES.width - 10), "[Current Animation]", 8); uiBase.add(lblGCurAnim);
        lblGCurAnim.alignment = CENTER;
        clGCurAnim = new FlxUICustomList(lblGCurAnim.x, lblGCurAnim.y + lblGCurAnim.height + 7, Std.int(tabFRAMES.width - 10)); uiBase.add(clGCurAnim);
        clGCurAnim.name = "GHOST_CHANGE";

        var lblbGCurFrame = new FlxText(clGCurAnim.x, clGCurAnim.y + clGCurAnim.height + 15, 0, "[Current Frame]:", 8); uiBase.add(lblbGCurFrame);
        stpGCurFrame = new FlxUINumericStepperCustom(lblbGCurFrame.x + lblbGCurFrame.width, lblbGCurFrame.y, 120, 1, 0, 0, 999); uiBase.add(stpGCurFrame);
        stpGCurFrame.name = "GHOST_INDEX";


        tabFRAMES.addGroup(uiBase);

        tabFRAMES.scrollFactor.set();
        tabFRAMES.showTabId("Frames");
    }
    
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if((sender is FlxUICheckBox)){
            var check:FlxUICheckBox = cast sender;
            var label = check.getLabel().text;

            switch(id){
                case FlxUICheckBox.CLICK_EVENT:{
                    switch(label){
                        default:{trace("[FlxUICheckBox]: Works!");}
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
                            stpGCurFrame.value = 0;
                            playGhost(nums.getSelectedLabel(), Std.int(stpGCurFrame.value));
                        }
                    }
                }
            }
        }
    }
}