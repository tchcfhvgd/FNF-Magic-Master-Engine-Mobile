package;

import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;

import flixel.addons.ui.interfaces.IResizable;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.addons.ui.FlxUIGroup;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.FlxObject;
import flixel.FlxG;
import haxe.Json;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

import Alphabet.PopUpScore;
import Note.Note_Animation_Data;
import Note.Note_Graphic_Data;
import states.MusicBeatState;
import Song.SwagSection;
import Note.NoteSplash;
import Note.StrumNote;
import Song.SwagStrum;
import Note.NoteData;
import Note.Note;
import Controls;
import Script;

using StringTools;

class StaticNotes extends FlxUIGroup {
    public var genWidth:Int = 160;
    public var genHeight(get, never):Int;
	inline function get_genHeight():Int{return Std.int(genWidth / keyNum);}

    public var keyNum:Int = 4;
    
    public var statics:Array<StrumNote> = [];

    public var image:String = StrumNote.IMAGE_DEFAULT;
    public var style:String = StrumNote.STYLE_DEFAULT;
    public var type:String = StrumNote.TYPE_DEFAULT;

    public function new(X:Float, Y:Float, ?_keys:Int, ?_size:Int, ?_image:String, ?_style:String, ?_type:String){
        if(_image != null){this.image = _image;}
        if(_style != null){this.style = _style;}
        if(_type != null){this.type = _type;}
        if(_keys != null){this.keyNum = _keys;}
        if(_size != null){this.genWidth = _size;}
        super(X, Y);
                        
        changeKeyNumber(keyNum, genWidth, true, true);
    }
    
    public function playById(id:Int, anim:String, force:Bool = false, doSplash:Bool = false){
        var curStrum:StrumNote = statics[id];
        if(curStrum == null){return;}
        curStrum.playAnim(anim, force);
    }

    public function setGraphicToNotes(?_image:String, ?_style:String, ?_type:String){
        if(_image != null){image = _image;} if(_style != null){style = _style;} if(_type != null){type = _type;}

        for(key in statics){key.loadNote(image, style, type);}
    }

    public function changeKeyNumber(_keys:Int, ?_size:Int, ?force:Bool = false, ?skip:Bool = false){
        if((this.keyNum == _keys || _keys <= 0) && !force){return;}
        this.keyNum = _keys;
        
        if(_size != null){this.genWidth = _size;}
        var strumSize:Int = Std.int(genWidth / keyNum);
        
        if(skip){
            while(statics.length > 0){this.remove(statics.shift());}

            for(i in 0...keyNum){
                var strum:StrumNote = new StrumNote(i, keyNum, image, style, type);
                strum.setGraphicSize(strumSize);
                strum.x += strumSize * i;
                strum.ID = i;
                add(strum);
                statics.push(strum);
            }
        }else{
            if(statics.length > 0){
                for(i in 0...statics.length){
                    var strum:StrumNote = statics[i];
                    strum.onDebug = true;

                    FlxTween.tween(strum, {alpha: 0, y: strum.y + (strum.height / 2)}, (0.5 * (i + 1) / statics.length), {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){this.members.remove(strum);}});
                }
            }
            
            for(i in 0...keyNum){
                var strum:StrumNote = new StrumNote(i, keyNum, image, style, type);
                strum.setGraphicSize(strumSize);
                strum.x += strumSize * i;
                strum.y -= strumSize / 2;
                strum.alpha = 0;
                strum.ID = i;

                add(strum);
                statics.push(strum);

                FlxTween.tween(strum, {alpha: 1, y: 0}, (0.5 * (i + 1) / keyNum), {ease: FlxEase.quadInOut});
            }
        }
    }
}

typedef StrumLine_Graphic_Data = {
    var static_notes:Strums_Data;
    var gameplay_notes:Strums_Data;
}
typedef Strums_Data = {
    var general_animations:Array<Note_Animation_Data>;
    var notes:Array<Note_Graphic_Data>;
}

class StrumLine extends FlxTypedGroup<Dynamic> {
    public static var GLOBAL_VARIABLES:Map<String, Dynamic> = [
        "Player" => null,
        "Enemy" => null
    ];
    public var LOCAL_VARIABLES:Map<String, Dynamic> = [
        "Player" => null
    ];

    // STRUM OBJECTS
    public var staticnotes:StaticNotes;

    public var x(get, set):Float;
    inline public function get_x(){return staticnotes.x;}
    inline public function set_x(x){return staticnotes.x = x;}

    public var y(get, set):Float;
    inline public function get_y(){return staticnotes.y;}
    inline public function set_y(y){return staticnotes.y = y;}

    public var alpha(get, set):Float;
    inline public function get_alpha(){return staticnotes.alpha;}
    inline public function set_alpha(alpha){return staticnotes.alpha = alpha;}

    public var key_number(get, never):Int; inline function get_key_number():Int{return staticnotes.keyNum;}
    public var genWidth(get, never):Int; inline function get_genWidth():Int{return staticnotes.genWidth;}
    public var genHeight(get, never):Int; inline function get_genHeight():Int{return staticnotes.genHeight;}
    public var image(get, never):String; inline function get_image():String{return staticnotes.image;}
    public var style(get, never):String; inline function get_style():String{return staticnotes.style;}
    public var type(get, never):String; inline function get_type():String{return staticnotes.type;}

    public var notes:FlxTypedGroup<Note>;
    public var recycleGrp:FlxTypedGroup<Dynamic>;
    
	public var healthBar:FlxBar;
	public var leftIcon:HealthIcon;
	public var rightIcon:HealthIcon;
	public var sprite_healthBar:FlxSprite;
	public var lblStats:FlxText;

    // STRUMLINE VARIABLES
    public var player:Int = 0;

    public var typeStrum:String = "BotPlay"; //BotPlay, Playing, Charting
    public var notelist:Array<Note> = [];

    // NOTE EVENTS
    public var onHIT:Note->Void = null;
    public var onMISS:Note->Void = null;
    public var onGAME_OVER:Void->Void = null;
    public var update_hud:Void->Void = function(){};

    // STATS VARIABLES    
    public static var P_STAT:Array<Dynamic> = [
        {rank:"PERFECT", popup:"perfect", score:400, diff:0},
        {rank:"SICK", popup:"sick", score:350, diff:45},
        {rank:"GOOD", popup:"good", score:200, diff:90},
        {rank:"BAD", popup:"bad", score:100, diff:135},
        {rank:"._.", popup:"shit", score:50, diff:200},
    ];
    
    public var STATS:Map<String, Dynamic> = [
        "TotalNotes" => 0,
		"Record" => 0,
		"Score" => 0,
		"Combo" => 0,
		"MaxCombo" => 0,
		"Hits" => 0,
		"Misses" => 0,
        "Percent" => 0,
		"Rating" => "MAGIC"
	];

    public static var RATING:Array<Dynamic> = [
        {percent: 1.0, rate:"MAGIC!!"},
        {percent: 0.9, rate:"Sick!!"},
        {percent: 0.8, rate:"Great"},
        {percent: 0.7, rate:"Cool"},
        {percent: 0.6, rate:"Good"},
        {percent: 0.5, rate:"Bad"},
        {percent: 0.4, rate:"Shit"},
        {percent: 0.3, rate:"._."}
	];

    // SONG VARIABLES
    public var ui_style:String = "Default";
    public var swagStrum:SwagStrum = null;
    public var strumConductor:Conductor = null;
    public var curSection(get, never):Int;
	inline function get_curSection():Int{return Std.int(strumConductor.getCurStep() / 16);}

    public var scrollSpeed:Float = 1;
    public var bpm:Float = 150;

    public var HEALTH:Float = 1;
    public var MAXHEALTH:Float = 2;

    public var strumGenerated:Bool = false;

    // CONTROLS VARIABLES
    public var controls:Controls;
    public var disableArray:Array<Bool> = [];
    public var pressArray:Array<Bool> = [];
    public var releaseArray:Array<Bool> = [];
    public var holdArray:Array<Bool> = [];

    public function new(X:Float, Y:Float, ?_keys:Int, ?_size:Int, ?_controls:Controls, ?_image:String, ?_style:String, ?_type:String){
        this.controls = _controls;
        super();

        recycleGrp = new FlxTypedGroup<Dynamic>();
        recycleGrp.add(new NoteSplash());
        recycleGrp.add(new FlxSprite());
        recycleGrp.add(new PopUpScore());

        staticnotes = new StaticNotes(X, Y, _keys, _size, _image, _style, _type);
        add(staticnotes);

        notes = new FlxTypedGroup<Note>();
        add(notes);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

        changeTypeStrum(typeStrum);
    }

    public function load_solo_ui():Void {
		var cont:Array<Bool> = []; for(s in MusicBeatState.state.scripts){cont.push(s.exFunction('load_solo_${player}_ui'));}
		if(cont.contains(true)){return; trace("RETURN");}

        if(healthBar == null){
			healthBar = new FlxBar(330, 663, RIGHT_TO_LEFT, Std.int(FlxG.width / 2) - 20, 16, this, 'HEALTH', 0, MAXHEALTH);
			healthBar.numDivisions = 500;
			//healthBar.cameras = [camHUD];
			add(healthBar);
		}

		if(sprite_healthBar == null){
			sprite_healthBar = new FlxSprite(326, 655).loadGraphic(Paths.styleImage("single_healthBar", ui_style, "shared"));
			sprite_healthBar.scale.set(0.7,0.7); sprite_healthBar.updateHitbox();
			//sprite_healthBar.cameras = [camHUD];
			add(sprite_healthBar);
		}

		if(leftIcon == null){
			leftIcon = new HealthIcon('tankman');
			leftIcon.setPosition(healthBar.x-(leftIcon.width/2),healthBar.y-(leftIcon.height/2));
			//leftIcon.camera = camHUD;
			add(leftIcon);
		}

        if(lblStats == null){
			lblStats = new FlxText(0,0,0,"|| ...Starting Song... ||");
			lblStats.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			lblStats.screenCenter(X);
			lblStats.y = FlxG.height - lblStats.height - 5;
			//lblStats.cameras = [camHUD];
			add(lblStats);
		}
    }

    public function load_global_ui():Void {
		var cont:Array<Bool> = []; for(s in MusicBeatState.state.scripts){cont.push(s.exFunction('load_global_ui'));}
		if(cont.contains(true)){return; trace("RETURN");}

		if(healthBar == null){
			healthBar = new FlxBar(330, 663, RIGHT_TO_LEFT, Std.int(FlxG.width / 2) - 20, 16, this, 'HEALTH', 0, MAXHEALTH);
			healthBar.numDivisions = 500;
			//healthBar.cameras = [camHUD];
			add(healthBar);
		}

		if(sprite_healthBar == null){
			sprite_healthBar = new FlxSprite(326, 655).loadGraphic(Paths.styleImage("HealthBar", ui_style, "shared"));
			sprite_healthBar.scale.set(0.7,0.7); sprite_healthBar.updateHitbox();
			//sprite_healthBar.cameras = [camHUD];
			add(sprite_healthBar);
		}

		if(leftIcon == null){
			leftIcon = new HealthIcon('tankman');
			leftIcon.setPosition(healthBar.x-(leftIcon.width/2),healthBar.y-(leftIcon.height/2));
			//leftIcon.camera = camHUD;
			add(leftIcon);
		}
		
		if(rightIcon == null){
			rightIcon = new HealthIcon('bf', true);
			rightIcon.setPosition(healthBar.x+healthBar.width-(rightIcon.width/2),healthBar.y-(rightIcon.height/2));
			//rightIcon.camera = camHUD;
			add(rightIcon);
		}

		if(lblStats == null){
			lblStats = new FlxText(0,0,0,"|| ...Starting Song... ||");
			lblStats.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			lblStats.screenCenter(X);
			lblStats.y = FlxG.height - lblStats.height - 5;
			//lblStats.cameras = [camHUD];
			add(lblStats);
		}

        update_hud = function(){
            if(healthBar != null){
                var _player:Character = LOCAL_VARIABLES["Player"];
                if(_player != null){
                    healthBar.flipX = _player.onRight;

                    if(leftIcon != null){
                        var _char_left:Character = (_player.onRight ? GLOBAL_VARIABLES["Player"] : GLOBAL_VARIABLES["Enemy"]);
                        if(_char_left != null && leftIcon.curIcon != _char_left.healthIcon){leftIcon.setIcon(_char_left.healthIcon);}
        
                        if(_player.onRight){
                            MagicStuff.lerpX(leftIcon, healthBar.x + (healthBar.width - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))) - leftIcon.width);
                        }else{
                            MagicStuff.lerpX(leftIcon, healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - leftIcon.width);
                        }
                        
                        leftIcon.playAnim(HEALTH < 0.8 ? 'default' : 'losing');		
                    }

                    if(rightIcon != null){
                        var _char_right:Character = (_player.onRight ? GLOBAL_VARIABLES["Enemy"] : GLOBAL_VARIABLES["Player"]);
                        if(_char_right != null && rightIcon.curIcon != _char_right.healthIcon){rightIcon.setIcon(_char_right.healthIcon);}
    
                        if(_player.onRight){
                            MagicStuff.lerpX(rightIcon, healthBar.x + (healthBar.width - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))));
                        }else{
                            MagicStuff.lerpX(rightIcon, healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)));
                        }

                        rightIcon.playAnim(HEALTH > 0.2 ? 'default' : 'losing');
                    }
                }
            }
    
            if(lblStats != null){
                switch(PreSettings.getPreSetting("Type HUD", "Visual Settings")){
                    case "MagicHUD":{
                        lblStats.text = '||'+
                            ' ${LangSupport.getText('Gmp_Score')}: ${STATS['Score']} |' +
                            //' ${LangSupport.getText('Gmp_Record')}: ${STATS['Record']} |' +
                            ' ${LangSupport.getText('Gmp_Combo')}: ${STATS['Combo']} |' +
                            //' ${LangSupport.getText('Gmp_MaxCombo')}: ${STATS['MaxCombo']} |' +
                            ' ${LangSupport.getText('Gmp_Misses')}: ${STATS['Misses']} |' +
                            //' ${LangSupport.getText('Gmp_Hits')}: ${STATS['Hits']} |' +
                            ' ${LangSupport.getText('Gmp_Rating')}: ${STATS['Rating']} ' +
                        '||';
                    }
                    case "Original":{
                        lblStats.text = '||'+
                            ' ${LangSupport.getText('Gmp_Score')}: ${STATS['Score']} |' +
                            ' ${LangSupport.getText('Gmp_Misses')}: ${STATS['Misses']} ' +
                        '||';
                    }
                    case "Minimized":{
                        lblStats.text = '||'+
                            ' ${LangSupport.getText('Gmp_Score')}: ${STATS['Score']} ' +
                        '||';
                    }
                    case "OnlyNotes":{
                        lblStats.text = '';
                    }
                }
                
                lblStats.screenCenter(X);
            }
        }
	}

    public function changeTypeStrum(_type:String):Void {
        typeStrum = _type;

        switch(typeStrum){
            case 'BotPlay':{for(c in staticnotes.statics){c.autoStatic = true;}}
            case 'Playing':{for(c in staticnotes.statics){c.autoStatic = false;}}
        }
    }

    override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		super.destroy();
	}

    private function onKeyPress(event:KeyboardEvent):Void {
        if(typeStrum != "Playing"){return;}

        var eventKey:FlxKey = event.keyCode;
        var key:Int = controls.getNoteDataFromKey(eventKey, key_number);
    
        if(key < 0 || disableArray[key]){return;}

        if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)){
            staticnotes.playById(key, "pressed", true);
            pressArray[key] = true;
        }

        holdArray[key] = true;
        keyShit();
        pressArray[key] = false;
    }

    private function onKeyRelease(event:KeyboardEvent):Void {
        if(typeStrum != "Playing"){return;}
        
        var eventKey:FlxKey = event.keyCode;
        var key:Int = controls.getNoteDataFromKey(eventKey, key_number);
    
        if(key < 0 || disableArray[key]){return;}
        
        if(FlxG.keys.checkStatus(eventKey, JUST_RELEASED)){
            staticnotes.playById(key, "static", true);
            releaseArray[key] = true;
        }

        holdArray[key] = false;
        keyShit();
        releaseArray[key] = false;
    }

    public function getStrumSize():Int {return Std.int(genWidth / key_number);}
    public function getSustainHeight():Int {return Std.int(getScrollSpeed() * getStrumSize() / (bpm * 2.3 / 150));}

    public function setGraphicToNotes(?_image:String, ?_style:String, ?_type:String){
        staticnotes.setGraphicToNotes(_image, _style, _type);
        for(n in notelist){n.loadNote(image, style, type);}
    }

    public function changeKeyNumber(_keys:Int, ?_size:Int, ?force:Bool = false, ?skip:Bool = false){
        staticnotes.changeKeyNumber(_keys, _size, force, skip);

        disableArray.resize(key_number);
        pressArray.resize(key_number);
        releaseArray.resize(key_number);
        holdArray.resize(key_number);
    }

    public function loadStrumNotes(swagStrum:SwagStrum){
        var pre_TypeNotes:String = PreSettings.getPreSetting("Note Skin", "Visual Settings");
        this.swagStrum = swagStrum;

        notelist = [];
        for(curSection in 0...swagStrum.notes.length){
            var sectionInfo:Array<Dynamic> = swagStrum.notes[curSection].sectionNotes.copy();
            for(n in sectionInfo){if(n[1] < 0 || n[1] >= Song.getStrumKeys(swagStrum, curSection)){sectionInfo.remove(n);}}
            
            var cSection = swagStrum;
            var mergedGroup:Array<Note> = [];
            for(n in sectionInfo){
                var note:NoteData = Note.getNoteData(n);
        
                var swagNote:Note = new Note(note, Song.getStrumKeys(cSection, curSection), image, style, type);
                swagNote.setGraphicSize(getStrumSize());

                if(note.canMerge){mergedGroup.push(swagNote);}
                        
                notelist.push(swagNote);
        
                if(note.sustainLength <= 0 || note.multiHits > 0){continue;}

                var cSusNote = Math.floor(note.sustainLength / (strumConductor.stepCrochet * 0.25)) + 2;
        
                var prevSustain:Note = swagNote;
                for(sNote in 0...Math.floor(note.sustainLength / (strumConductor.stepCrochet * 0.25)) + 2){
                    var sStrumTime = note.strumTime + (strumConductor.stepCrochet / 2) + ((strumConductor.stepCrochet * 0.25) * sNote);
                    var nSData:NoteData = Note.getNoteData(Note.convNoteData(note));
                    nSData.strumTime = sStrumTime;
        
                    var nSustain:Note = new Note(nSData, key_number, image, style, type);
                    nSustain.setGraphicSize(getStrumSize(), getSustainHeight());
                    nSustain.updateHitbox();
        
                    nSustain.typeNote = "Sustain";
                    nSustain.typeHit = "Hold";
                    prevSustain.nextNote = nSustain;
                    
                    if(cSusNote == 1 && nSData.canMerge){mergedGroup.push(nSustain);}        
                    notelist.push(nSustain);
        
                    prevSustain = nSustain;
                    cSusNote--;
                }  
            }

            while(mergedGroup.length > 0){
                var curMerge = mergedGroup.shift();
                var curGroup:Array<Note> = [curMerge];

                var changeCurrent:Bool = false;
                for(n in mergedGroup){
                    if(!Note.compNotes(Note.getNoteData([curMerge.strumTime]), Note.getNoteData([n.strumTime]))){continue;}
                    changeCurrent = true;
                    n.typeNote = "Merge";
                    if(n.noteLength > 0 && n.nextNote == null){
                        n.loadNote(); n.setGraphicSize(getStrumSize()); n.typeHit = "Release";
                        var ndSustain1:NoteData = Note.getNoteData([n.strumTime, n.noteData]); var nSustain1:Note = new Note(ndSustain1, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain1.nextNote = n; nSustain1.typeNote = "Sustain"; nSustain1.typeHit = "Hold"; nSustain1.setGraphicSize(getStrumSize(), getSustainHeight()); notelist.push(nSustain1); nSustain1.alpha = n.alpha;
                        var ndSustain2:NoteData = Note.getNoteData([n.strumTime + (strumConductor.stepCrochet*0.25), n.noteData]); var nSustain2:Note = new Note(ndSustain2, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain2.nextNote = n; nSustain2.typeNote = "Sustain"; nSustain2.typeHit = "Hold"; nSustain2.setGraphicSize(getStrumSize(), getSustainHeight()); notelist.push(nSustain2); nSustain2.alpha = n.alpha;
                    }
                    curGroup.push(n);
                }
                if(changeCurrent){
                    curMerge.typeNote = "Merge";
                    if(curMerge.noteLength > 0 && curMerge.nextNote == null){
                        curMerge.loadNote(); curMerge.setGraphicSize(getStrumSize()); curMerge.typeHit = "Release";
                        var ndSustain1:NoteData = Note.getNoteData([curMerge.strumTime, curMerge.noteData]); var nSustain1:Note = new Note(ndSustain1, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain1.nextNote = curMerge; nSustain1.typeNote = "Sustain"; nSustain1.typeHit = "Hold"; nSustain1.setGraphicSize(getStrumSize(), getSustainHeight()); notelist.push(nSustain1); nSustain1.alpha = curMerge.alpha;
                        var ndSustain2:NoteData = Note.getNoteData([curMerge.strumTime + (strumConductor.stepCrochet*0.25), curMerge.noteData]); var nSustain2:Note = new Note(ndSustain2, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain2.nextNote = curMerge; nSustain2.typeNote = "Sustain"; nSustain2.typeHit = "Hold"; nSustain2.setGraphicSize(getStrumSize(), getSustainHeight()); notelist.push(nSustain2); nSustain2.alpha = curMerge.alpha;
                    }
                }
            
                curGroup.sort((a, b) -> (a.noteData - b.noteData));
                for(ii in 0...curGroup.length){
                    if(curGroup[ii+1] == null){continue;}
                    var currentNote:Note = curGroup[ii]; var nextedNote:Note = curGroup[ii+1]; mergedGroup.remove(currentNote);
                    for(i in currentNote.noteData...(nextedNote.noteData + 1)){
                        if(i > currentNote.noteData){
                            var ndSwitch1:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, -2]); var nSwitcher1:Note = new Note(ndSwitch1, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher1.setGraphicSize(getStrumSize()); nSwitcher1.typeNote = "Switch"; nSwitcher1.typeHit = "Ghost"; notelist.push(nSwitcher1); nSwitcher1.alpha = 0.5;
                            var ndSwitch2:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, -1]); var nSwitcher2:Note = new Note(ndSwitch2, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher2.setGraphicSize(getStrumSize()); nSwitcher2.typeNote = "Switch"; nSwitcher2.typeHit = "Ghost"; notelist.push(nSwitcher2); nSwitcher2.alpha = 0.5;
                        }
                        if(i < nextedNote.noteData){
                            var ndSwitch1:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, 0]); var nSwitcher1:Note = new Note(ndSwitch1, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher1.setGraphicSize(getStrumSize()); nSwitcher1.typeNote = "Switch"; nSwitcher1.typeHit = "Ghost"; notelist.push(nSwitcher1); nSwitcher1.alpha = 0.5;
                            var ndSwitch2:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, 1]); var nSwitcher2:Note = new Note(ndSwitch2, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher2.setGraphicSize(getStrumSize()); nSwitcher2.typeNote = "Switch"; nSwitcher2.typeHit = "Ghost"; notelist.push(nSwitcher2); nSwitcher2.alpha = 0.5;
                        }
                    }
                }
            }
        }

        strumGenerated = true;
    }

    var pre_TypeStrums:String = PreSettings.getPreSetting("Type Light Strums", "Visual Settings");
    override function update(elapsed:Float){
		super.update(elapsed);
        
        if(update_hud != null){update_hud();}

        if(HEALTH <= 0){
        
            if(onGAME_OVER != null){onGAME_OVER();}
        }

		if(HEALTH > MAXHEALTH){HEALTH = MAXHEALTH;}

        if(STATS["Combo"] > STATS["MaxCombo"]){STATS["MaxCombo"] = STATS["Combo"];}
        if(STATS["Score"] > STATS["Record"]){STATS["Record"] = STATS["Score"];}

        if(notelist[0] != null){
            if(notelist[0].strumTime - strumConductor.songPosition < 3500){
                var nNote:Note = notelist[0];
                notes.add(nNote);

                var index:Int = notelist.indexOf(nNote);
				notelist.splice(index, 1);
            }
        }

        if(!strumGenerated){return;}

        if(swagStrum.notes[curSection] != null){
            var curSec = swagStrum.notes[curSection];

            var nKeys:Int = swagStrum.keys;
            if(curSec.changeKeys){nKeys = curSec.keys;}

            changeKeyNumber(nKeys, genWidth, false, true);
        }

        notes.forEachAlive(function(daNote:Note){
            if(daNote.strumTime > strumConductor.songPosition - Conductor.safeZoneOffset && daNote.strumTime < strumConductor.songPosition + (Conductor.safeZoneOffset * 0.5)){daNote.noteStatus = "CanBeHit";}
            if(strumConductor.songPosition > daNote.strumTime + (Conductor.safeZoneOffset * 0.5) && daNote.noteStatus != "Pressed"){daNote.noteStatus = "Late";}

            var pre_TypeScroll:String = PreSettings.getPreSetting("Typec Scroll", "Visual Settings");
            
            var yStuff:Float = getScroll(daNote);

            daNote.visible = false;
            var noteStrum:StrumNote = staticnotes.statics[daNote.noteData];
            if(noteStrum == null){return;}

            switch(pre_TypeScroll){
                default:{daNote.y = noteStrum.y - yStuff;}
                case "DownScroll":{daNote.y = noteStrum.y + yStuff;}
            }

            daNote.visible = noteStrum.visible;
            daNote.alpha = noteStrum.alpha;

            if(daNote.typeNote == "Switch"){
                daNote.x = noteStrum.x + ((getStrumSize() * 0.25) * (daNote.noteHits+2));
                daNote.alpha = noteStrum.alpha * 0.8;
            }else{
                daNote.x = noteStrum.x;
                daNote.alpha = noteStrum.alpha;
                daNote.angle = noteStrum.angle;
                if(daNote.typeNote == "Sustain" || daNote.typeNote == "SustainEnd"){
                    daNote.alpha = noteStrum.alpha * 0.5;
                    daNote.angle = 0;
                }
            }
            
            if(daNote.noteStatus == "Late"){missNOTE(daNote);}
        });

        keyShit();
    
        //PERCENT = Math.min(1, Math.max(0, TNOTES / HITS));
        //for(k in RATING.keys()){if(PERCENT <= k){RATE = RATING.get(k);}}
	}

    public function getScroll(daNote:Note):Float {
        switch(daNote.noteStatus){
            default:{return 0.45 * (strumConductor.songPosition - daNote.strumTime) * getScrollSpeed();}
            case "MultiTap":{
                var x_1:Float = (strumConductor.songPosition - daNote.strumTime);
                var x_2:Float = daNote.noteLength;
                var x_3:Float = 0;

                return 0.0045*(Math.pow(x_1, 2) - (x_2 - x_3) * x_1 - x_2 * x_3);
            }
        }
    }

    private function keyShit():Void{
        if(typeStrum == "Playing"){    
            notes.forEachAlive(function(daNote:Note){
                if(daNote.noteStatus == "CanBeHit" &&
                    (
                        (daNote.typeHit == "Press" && pressArray[daNote.noteData]) ||
                        (daNote.typeHit == "Hold" && holdArray[daNote.noteData]) ||
                        (daNote.typeHit == "Release" && releaseArray[daNote.noteData]) ||
                        (daNote.typeHit == "Always" || daNote.typeHit == "Ghost")
                    )
                ){
                    hitNOTE(daNote);
                }
            });
        }else if(typeStrum == "BotPlay"){
            notes.forEachAlive(function(daNote:Note){
                if(daNote.strumTime <= strumConductor.songPosition && !daNote.hitMiss){hitNOTE(daNote);}
            });
        }
    }

    public function hitNOTE(daNote:Note) {
        daNote.noteStatus = "Pressed";

        if((pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums") && daNote.typeHit != "Ghost"){
            staticnotes.playById(daNote.noteData, "confirm", true, daNote.typeHit != "Hold");
        }

        for(event in daNote.otherData){
            if(event[2] != "OnHit"){continue;}
            var curScript:Script = Script.getScript(event[0]);
            curScript.setVariable("_note", daNote);
            curScript.exFunction("execute", event[1]);
        }
        
        if(daNote.hitMiss){missNOTE(daNote); return;}

        if(daNote.noteHits > 0){
            daNote.noteStatus = "MultiTap";
            daNote.strumTime = daNote.strumTime + daNote.noteLength;            
            daNote.noteHits--;
        }else{
            daNote.kill();
            remove(daNote, true);
            daNote.destroy();
        }

        if(daNote.typeHit != "Ghost"){
            rankNote(daNote);
            if(onHIT != null){onHIT(daNote);}
        }
    }

    public function missNOTE(daNote:Note) {
        daNote.kill();
        remove(daNote, true);
        daNote.destroy();

        if(daNote.typeNote == "Sustain"){daNote.missHealth *= 0.25;}
        if(daNote.noteHits > 0){daNote.missHealth *= daNote.noteHits + 1;}
        
        for(event in daNote.otherData){
            if(event[2] != "OnMiss"){continue;} var curScript:Script = Script.getScript(event[0]);
            curScript.setVariable("_note", daNote); curScript.exFunction("execute", event[1]);
        }
        
        if(daNote.ignoreMiss && !daNote.hitMiss){return;}

        HEALTH -= daNote.missHealth;

        STATS["TotalNotes"]++;
        STATS["Misses"] += 1 + daNote.noteHits;
        STATS["Score"] -= 100;
        STATS["Combo"] = 0;

        if(onMISS != null){onMISS(daNote);}
    }

    public function rankNote(daNote:Note){
        if(typeStrum == 'BotPlay' || daNote.typeNote == "Sustain"){return;}
        
        if(daNote.typeNote == "Sustain"){daNote.hitHealth *= 0.25;}
        HEALTH += daNote.hitHealth;

        STATS["TotalNotes"]++;
        STATS["Hits"]++;
        STATS["Combo"]++;

        var diff_rate:Float = Math.abs(daNote.strumTime - strumConductor.songPosition);
        
        var _rate:String = "MAGIC!!!";
        var _popImage:String = "Magic";
        var _score:Int = 0;

        for(r in P_STAT){
            if(diff_rate > r.diff){continue;}
            _popImage = r.popup;
            _score = r.score;
            _rate = r.rank;
            break;
        }

        STATS["Percent"] = STATS["Hits"] / STATS["TotalNotes"];
        for(rt in RATING){
            if(rt.percent > STATS["Percent"]){continue;}
            STATS["Rating"] = rt.rate;
            break;
        }

        STATS["Score"] += _score;

        var stuff_x:Float = staticnotes.x + genWidth + 5;
        if(LOCAL_VARIABLES["Player"] != null && !LOCAL_VARIABLES["Player"].onRight){stuff_x = staticnotes.x - 250;}

        var popRank:FlxSprite = recycleGrp.recycle(FlxSprite);
        popRank.loadGraphic(Paths.styleImage(_popImage, ui_style));
        popRank.scale.set(0.7, 0.7); popRank.updateHitbox();
        popRank.setPosition(stuff_x, staticnotes.y);
        popRank.alpha = 1;
        add(popRank);
        FlxTween.tween(popRank, {y: popRank.y - 25, alpha: 0}, 0.5, {ease:FlxEase.quadOut, onComplete:function(twn){remove(popRank);}});
        
        var ppScore:PopUpScore = recycleGrp.recycle(PopUpScore);
        ppScore.setPosition(popRank.x, popRank.y + (popRank.height / 2));
        ppScore.popup(STATS["Score"]);
        add(ppScore);
        new FlxTimer().start(0.5 + (0.2 * ('${STATS["Score"]}'.length - 1)), function(tmr){remove(ppScore);});

        var sprt_combo:FlxSprite = recycleGrp.recycle(FlxSprite);
        sprt_combo.loadGraphic(Paths.styleImage("combo", ui_style));
        sprt_combo.scale.set(0.5, 0.5); sprt_combo.updateHitbox();
        sprt_combo.setPosition(popRank.x, popRank.y + popRank.height + 5);
        sprt_combo.alpha = 1;
        add(sprt_combo);
        FlxTween.tween(sprt_combo, {y: sprt_combo.y - 25, alpha: 0}, 0.5, {ease:FlxEase.quadOut, onComplete:function(twn){remove(popRank);}});

        var ppCombo:PopUpScore = recycleGrp.recycle(PopUpScore);
        ppCombo.setPosition(sprt_combo.x, sprt_combo.y + (sprt_combo.height / 2));
        ppCombo.popup(STATS["Combo"]);
        add(ppCombo);
        new FlxTimer().start(0.5 + (0.2 * ('${STATS["Combo"]}'.length - 1)), function(tmr){remove(ppCombo);});
    }

    public function getScrollSpeed():Float{
        var pre_TypeScrollSpeed:String = PreSettings.getPreSetting("Scroll Speed Type", "Game Settings");
        var pre_ScrollSpeed:Float = PreSettings.getPreSetting("ScrollSpeed", "Game Settings");

        switch(pre_TypeScrollSpeed){
            case "Scale":{return scrollSpeed * pre_ScrollSpeed;}
            case "Force":{return pre_ScrollSpeed;}
            default:{return scrollSpeed;}
        }
    }
}