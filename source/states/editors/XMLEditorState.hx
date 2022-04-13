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
    
    var camBAC:FlxCamera;
    var camGEN:FlxCamera;
    var camHUD:FlxCamera;

    var point:FlxSprite;
    var bSprite:FlxSprite;
    var eSprite_b:FlxSprite;
    var eSprite:FlxSprite;
    var eSprite_f:FlxSprite;
    var imgIcon:FlxSprite;

    public static function editXML(){
        FlxG.sound.music.stop();
        FlxG.switchState(new XMLEditorState());
    }

    override function create(){
        FlxG.mouse.visible = true;

		if(!FlxG.sound.music.playing){FlxG.sound.playMusic(Paths.music('freakyMenu'));}

        camBAC = new FlxCamera();
        camGEN = new FlxCamera();
        camGEN.bgColor.alpha = 0;
        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camBAC);
        FlxG.cameras.add(camGEN);
		FlxG.cameras.add(camHUD);

        var bg = new FlxSprite().loadGraphic(Paths.image('menuBG', 'preload'));
        bg.camera = camBAC;
        add(bg);

        //SPRITES
        bSprite = new FlxSprite();
        bSprite.alpha = 0.3;
        bSprite.color = FlxColor.GRAY;
        bSprite.cameras = [camGEN];

        eSprite_b = new FlxSprite();
        eSprite_b.alpha = 0.3;
        eSprite_b.color = FlxColor.BLUE;
        eSprite_b.cameras = [camGEN];
        
        eSprite = new FlxSprite();
        eSprite.cameras = [camGEN];

        eSprite_f = new FlxSprite();
        eSprite_f.alpha = 0.3;
        eSprite_f.color = FlxColor.GREEN;
        eSprite_f.cameras = [camGEN];

        imgIcon = new FlxSprite(5, 5);
        imgIcon.cameras = [camHUD];

        add(eSprite_b);
        add(eSprite);
        add(eSprite_f);
        add(bSprite);

        add(imgIcon);

        point = new FlxSprite(100, 50).makeGraphic(5, 5, FlxColor.BLACK);
        point.cameras = [camGEN];
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

        if(FlxG.keys.justPressed.ESCAPE){FlxG.switchState(new MainMenuState());}
        if(FlxG.keys.justPressed.R){rSprites();}
        if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){save();}
        if(FlxG.keys.pressed.SHIFT){
            if(FlxG.keys.pressed.A){point.x -= 5;}
            if(FlxG.keys.pressed.S){point.y += 5;}
            if(FlxG.keys.pressed.W){point.y -= 5;}
            if(FlxG.keys.pressed.D){point.x += 5;}
            if(FlxG.keys.pressed.Q){camGEN.zoom -= 0.5;}
            if(FlxG.keys.pressed.E){camGEN.zoom += 0.5;}
        }else{
            if(FlxG.keys.pressed.A){point.x -= 10;}
            if(FlxG.keys.pressed.S){point.y += 10;}
            if(FlxG.keys.pressed.W){point.y -= 10;}
            if(FlxG.keys.pressed.D){point.x += 10;}
            if(FlxG.keys.pressed.Q){camGEN.zoom -= 0.1;}
            if(FlxG.keys.pressed.E){camGEN.zoom += 0.1;}
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
            playAnim(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value));
        }
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
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.x = Std.string(nums.value);
                            trace(sTexture.att.x);
                            rSprites();
                        }
                        case "FRAME_Y":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.y = Std.string(nums.value);
                            trace(sTexture.att.y);
                            rSprites();
                        }
                        case "FRAME_WIDTH":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.width = Std.string(nums.value);
                            trace(sTexture.att.width);
                            rSprites();
                        }
                        case "FRAME_HEIGHT":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.height = Std.string(nums.value);
                            trace(sTexture.att.height);
                            rSprites();
                        }
                        case "FRAME_FrameX":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameX = Std.string(nums.value);
                            trace(sTexture.att.frameX);
                            rSprites();
                        }
                        case "FRAME_FrameY":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameY = Std.string(nums.value);
                            trace(sTexture.att.frameY);
                            rSprites();
                        }
                        case "FRAME_FrameWIDTH":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameWidth = Std.string(nums.value);
                            trace(sTexture.att.frameWidth);
                            rSprites();
                        }
                        case "FRAME_FrameHEIGHT":{
                            var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), Std.int(stpFCurFrame.value)));
                            sTexture.att.frameHeight = Std.string(nums.value);
                            trace(sTexture.att.frameHeight);
                            rSprites();
                        }
                    }
                }
            }        
        }else if((sender is FlxUINumericStepperCustom)){
            var nums:FlxUINumericStepperCustom = cast sender;
            var wname = nums.name;
                
            switch(id){
                case FlxUINumericStepperCustom.CHANGE_EVENT:{
                    switch(wname){
                        case "FRAME_INDEX":{
                            if(Std.int(nums.value) >= eSprite.animation.curAnim.frames.length){nums.value = 0;}
                            playAnim(clCurAnim.getSelectedIndex(), Std.int(nums.value));
                        }
                        case "GHOST_INDEX":{
                            if(Std.int(nums.value) >= bSprite.animation.curAnim.frames.length){nums.value = 0;}
                            playGhost(clGCurAnim.getSelectedIndex(), Std.int(nums.value));
                        }
                    }
                }
                case FlxUINumericStepperCustom.CLICK_MINUS:{
                    switch(wname){
                        case "FRAME_ALL_X":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.x = Std.string(Std.parseInt(sTexture.att.x) - Std.int(nums.value));
                                trace(sTexture.att.x);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_Y":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.y = Std.string(Std.parseInt(sTexture.att.y) - Std.int(nums.value));
                                trace(sTexture.att.y);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_WIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.width = Std.string(Std.parseInt(sTexture.att.width) - Std.int(nums.value));
                                trace(sTexture.att.width);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_HEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.height = Std.string(Std.parseInt(sTexture.att.height) - Std.int(nums.value));
                                trace(sTexture.att.height);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameX":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameX = Std.string(Std.parseInt(sTexture.att.frameX) - Std.int(nums.value));
                                trace(sTexture.att.frameX);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameY":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameY = Std.string(Std.parseInt(sTexture.att.frameY) - Std.int(nums.value));
                                trace(sTexture.att.frameY);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameWIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameWidth = Std.string(Std.parseInt(sTexture.att.frameWidth) - Std.int(nums.value));
                                trace(sTexture.att.frameWidth);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameHEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameHeight = Std.string(Std.parseInt(sTexture.att.frameHeight) - Std.int(nums.value));
                                trace(sTexture.att.frameHeight);
                            
                            }
                            rSprites();
                        }
                    }
                }
                case FlxUINumericStepperCustom.CLICK_PLUS:{
                    switch(wname){
                        case "FRAME_ALL_X":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.x = Std.string(Std.parseInt(sTexture.att.x) + Std.int(nums.value));
                                trace(sTexture.att.x);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_Y":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.y = Std.string(Std.parseInt(sTexture.att.y) + Std.int(nums.value));
                                trace(sTexture.att.y);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_WIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.width = Std.string(Std.parseInt(sTexture.att.width) + Std.int(nums.value));
                                trace(sTexture.att.width);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_HEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.height = Std.string(Std.parseInt(sTexture.att.height) + Std.int(nums.value));
                                trace(sTexture.att.height);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameX":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameX = Std.string(Std.parseInt(sTexture.att.frameX) + Std.int(nums.value));
                                trace(sTexture.att.frameX);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameY":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameY = Std.string(Std.parseInt(sTexture.att.frameY) + Std.int(nums.value));
                                trace(sTexture.att.frameY);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameWIDTH":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
                                sTexture.att.frameWidth = Std.string(Std.parseInt(sTexture.att.frameWidth) + Std.int(nums.value));
                                trace(sTexture.att.frameWidth);
                            
                            }
                            rSprites();
                        }
                        case "FRAME_ALL_FrameHEIGHT":{
                            for(i in 0...eSprite.animation.curAnim.frames.length){
                                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));
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
                            playAnim(nums.getSelectedIndex(), Std.int(stpFCurFrame.value));
                        }
                        case "GHOST_CHANGE":{
                            stpGCurFrame.value = 0;
                            playGhost(nums.getSelectedIndex(), Std.int(stpGCurFrame.value));
                        }
                    }
                }
            }
        }
    }

    private function getNamesArray(arr:Iterator<Access>):Array<String>{
        var toReturn:Array<String> = new Array<String>();

        for(chr in arr){
            var nChar = chr.att.name.replace("0", "").replace("1", "").replace("2", "").replace("3", "").replace("4", "").replace("5", "").replace("6", "").replace("7", "").replace("8", "").replace("9", "");
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
        stpFX.value = Std.parseInt(sTexture.att.x);
        stpFY.value = Std.parseInt(sTexture.att.y);
        stpFWidth.value = Std.parseInt(sTexture.att.width);
        stpFHeight.value = Std.parseInt(sTexture.att.height);
        if(sTexture.att.frameX != null){stpFFrameX.value = Std.parseInt(sTexture.att.frameX);}else{stpFFrameX.value = 0;}
        if(sTexture.att.frameY != null){stpFFrameY.value = Std.parseInt(sTexture.att.frameY);}else{stpFFrameY.value = 0;}
        if(sTexture.att.frameWidth != null){stpFFrameWidth.value = Std.parseInt(sTexture.att.frameWidth);}else{stpFFrameWidth.value = 0;}
        if(sTexture.att.frameHeight != null){stpFFrameHeight.value = Std.parseInt(sTexture.att.frameHeight);}else{stpFFrameHeight.value = 0;}

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
    var stpFCurFrame:FlxUINumericStepperCustom;
    var stpGCurFrame:FlxUINumericStepperCustom;

    var stpAX:FlxUINumericStepperCustom;
    var stpAY:FlxUINumericStepperCustom;
    var stpAWidth:FlxUINumericStepperCustom;
    var stpAHeight:FlxUINumericStepperCustom;
    var stpAFrameX:FlxUINumericStepperCustom;
    var stpAFrameY:FlxUINumericStepperCustom;
    var stpAFrameWidth:FlxUINumericStepperCustom;
    var stpAFrameHeight:FlxUINumericStepperCustom;
    private function addFRAMESTABS():Void{
        var uiBase = new FlxUI(null, tabFRAMES);
        uiBase.name = "Frames";

        var ttAnimFrames = new FlxText(5, 10, Std.int(tabFRAMES.width - 10), "| ANIMATION FRAMES |", 12); uiBase.add(ttAnimFrames);
        ttAnimFrames.alignment = CENTER;

        var lblSCurAnim = new FlxText(ttAnimFrames.x, ttAnimFrames.y + ttAnimFrames.height + 15, Std.int(tabFRAMES.width - 10), "[Current Animation]", 8); uiBase.add(lblSCurAnim);
        lblSCurAnim.alignment = CENTER;
        clCurAnim = new FlxUICustomList(lblSCurAnim.x, lblSCurAnim.y + lblSCurAnim.height + 7); uiBase.add(clCurAnim);
        clCurAnim.name = "BASE_CHANGE";
        clCurAnim.setWidth(tabFRAMES.width - 10);

        var lblbFCurFrame = new FlxText(clCurAnim.x, clCurAnim.y + clCurAnim.height + 15, 0, "[Current Frame]:", 8); uiBase.add(lblbFCurFrame);
        stpFCurFrame = new FlxUINumericStepperCustom(lblbFCurFrame.x + lblbFCurFrame.width, lblbFCurFrame.y, 1, 0, 0, 999); uiBase.add(stpFCurFrame);
        stpFCurFrame.name = "FRAME_INDEX";
        stpFCurFrame.setWidth(120);

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
        stpAX = new FlxUINumericStepperCustom(lblAX.x + lblAX.width, lblAX.y, 0, 0, -99999, 99999); uiBase.add(stpAX);
        stpAX.name = "FRAME_ALL_X";
        var lblAY = new FlxText(stpAX.x + stpAX.width + 10, stpAX.y, 0, "[Y]:", 8); uiBase.add(lblAY);
        stpAY = new FlxUINumericStepperCustom(lblAY.x + lblAY.width, lblAY.y, 0, 0, -99999, 99999); uiBase.add(stpAY);
        stpAY.name = "FRAME_ALL_Y";

        var lblAWidth = new FlxText(lblAX.x, lblAX.y + lblAX.height + 15, 0, "[Width]:", 8); uiBase.add(lblAWidth);
        stpAWidth = new FlxUINumericStepperCustom(lblAWidth.x + lblAWidth.width, lblAWidth.y, 0, 0, -99999, 99999); uiBase.add(stpAWidth);
        stpAWidth.name = "FRAME_ALL_WIDTH";
        var lblAHeight = new FlxText(stpAWidth.x + stpAWidth.width + 10, stpAWidth.y, 0, "[Height]:", 8); uiBase.add(lblAHeight);
        stpAHeight = new FlxUINumericStepperCustom(lblAHeight.x + lblAHeight.width, lblAHeight.y, 0, 0, -99999, 99999); uiBase.add(stpAHeight);
        stpAHeight.name = "FRAME_ALL_HEIGHT";

        var lblAFrameX = new FlxText(lblAWidth.x, lblAWidth.y + lblAWidth.height + 15, 0, "[FrameX]:", 8); uiBase.add(lblAFrameX);
        stpAFrameX = new FlxUINumericStepperCustom(lblAFrameX.x + lblAFrameX.width, lblAFrameX.y, 0, 0, -99999, 99999); uiBase.add(stpAFrameX);
        stpAFrameX.name = "FRAME_ALL_FrameX";
        var lblAFrameY = new FlxText(stpAFrameX.x + stpAFrameX.width + 10, stpAFrameX.y, 0, "[FrameY]:", 8); uiBase.add(lblAFrameY);
        stpAFrameY = new FlxUINumericStepperCustom(lblAFrameY.x + lblAFrameY.width, lblAFrameY.y, 0, 0, -99999, 99999); uiBase.add(stpAFrameY);
        stpAFrameY.name = "FRAME_ALL_FrameY";

        var lblAFrameWidth = new FlxText(lblAFrameX.x, lblAFrameX.y + lblAFrameX.height + 15, 0, "[F_Width]:", 8); uiBase.add(lblAFrameWidth);
        stpAFrameWidth = new FlxUINumericStepperCustom(lblAFrameWidth.x + lblAFrameWidth.width, lblAFrameWidth.y, 0, 0, -99999, 99999); uiBase.add(stpAFrameWidth);
        stpAFrameWidth.name = "FRAME_ALL_FrameWIDTH";
        var lblAFrameHeight = new FlxText(stpAFrameWidth.x + stpAFrameWidth.width + 10, stpAFrameWidth.y, 0, "[F_Height]:", 8); uiBase.add(lblAFrameHeight);
        stpAFrameHeight = new FlxUINumericStepperCustom(lblAFrameHeight.x + lblAFrameHeight.width, lblAFrameHeight.y, 0, 0, -99999, 99999); uiBase.add(stpAFrameHeight);
        stpAFrameHeight.name = "FRAME_ALL_FrameHEIGHT";

        var btnASetFrameSize = new FlxButton(5, lblAFrameWidth.y + lblAFrameWidth.height + 15, "Set FrameSize", function(){
            for(i in 0...eSprite.animation.curAnim.frames.length){
                var sTexture:Access = getSubTexture(getSubName(clCurAnim.getSelectedIndex(), i));

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
        clGCurAnim = new FlxUICustomList(lblGCurAnim.x, lblGCurAnim.y + lblGCurAnim.height + 7); uiBase.add(clGCurAnim);
        clGCurAnim.name = "GHOST_CHANGE";
        clGCurAnim.setWidth(tabFRAMES.width - 10);

        var lblbGCurFrame = new FlxText(clGCurAnim.x, clGCurAnim.y + clGCurAnim.height + 15, 0, "[Current Frame]:", 8); uiBase.add(lblbGCurFrame);
        stpGCurFrame = new FlxUINumericStepperCustom(lblbGCurFrame.x + lblbGCurFrame.width, lblbGCurFrame.y, 1, 0, 0, 999); uiBase.add(stpGCurFrame);
        stpGCurFrame.name = "GHOST_INDEX";
        stpGCurFrame.setWidth(120);


        tabFRAMES.addGroup(uiBase);

        tabFRAMES.scrollFactor.set();
        tabFRAMES.showTabId("Frames");
    }
}