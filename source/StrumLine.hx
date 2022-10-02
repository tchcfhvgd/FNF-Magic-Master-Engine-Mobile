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
import openfl.utils.Assets;
import flixel.math.FlxMath;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

import Note.Note_Animation_Data;
import Note.Note_Graphic_Data;
import states.MusicBeatState;
import Section.SwagSection;
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
    public var keyNum:Int = 4;
    
    public var statics:Array<StrumNote> = [];
    public var splash:NoteSplash;

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
                
        changeKeyNumber(keyNum, genWidth, true, false);
        
        splash = new NoteSplash();
        add(splash);
    }
    
    public function playById(id:Int, anim:String, force:Bool = false, doSplash:Bool = false){
        var curStrum:StrumNote = statics[id];
        if(curStrum == null){return;}

        curStrum.playAnim(anim, force);
        if(doSplash){curStrum.summonSplash(splash);}
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

class StrumLine extends StaticNotes {
    // STRUMLINE VARIABLES
    public var typeStrum:String = "BotPlay"; //BotPlay, Playing, Charting
        
    public var notes:Array<Note> = [];

    // NOTE EVENTS
    public var onHIT:Note->Void = null;
    public var onMISS:Note->Void = null;

    // STATS VARIABLES    
    public var TOTALNOTES:Int = 0;
    public var HITS:Int = 0;
    public var MISSES:Int = 0;
    public static var P_STAT:Array<Dynamic> = [
        [0, "PERFECT"],
        [5, "SICK"],
        [10, "GOOD"],
        [15, "BAD"],
        [10, "._."]
    ];
    
    public var SCORE:Float = 0;
    public var PERCENT:Float = 0;
    public var STATS:Map<String, Int> = [];    

    public var RATE:String = "MASTER COMBO";
    public static var RATING:Array<Dynamic> = [
        [0.2, ".____."],
        [0.4, '.-.'],
        [0.5, 'Meh'],
        [0.6, 'Good'],
        [0.7, 'Cool'],
        [0.8, 'Great'],
        [0.9, 'Sick!!'],
        [1, 'Perfect!']
	];

    public var COMBO:Int = 0;
    public var MAXCOMBO:Int = 0;

    // SONG VARIABLES
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
        super(X, Y, _keys, _size, _image, _style, _type);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

        changeTypeStrum(typeStrum);
    }

    public function changeTypeStrum(_type:String):Void{
        typeStrum = _type;

        switch(typeStrum){
            case 'BotPlay':{for(c in statics){c.autoStatic = true;}}
            case 'Playing':{for(c in statics){c.autoStatic = false;}}
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
        var key:Int = controls.getNoteDataFromKey(eventKey, keyNum);
    
        if(key < 0 || disableArray[key]){return;}

        if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)){
            playById(key, "pressed", true);
            pressArray[key] = true;
        }

        holdArray[key] = true;
        keyShit();
        pressArray[key] = false;
    }

    private function onKeyRelease(event:KeyboardEvent):Void {
        if(typeStrum != "Playing"){return;}
        
        var eventKey:FlxKey = event.keyCode;
        var key:Int = controls.getNoteDataFromKey(eventKey, keyNum);
    
        if(key < 0 || disableArray[key]){return;}
        
        if(FlxG.keys.checkStatus(eventKey, JUST_RELEASED)){
            playById(key, "static", true);
            releaseArray[key] = true;
        }

        holdArray[key] = false;
        keyShit();
        releaseArray[key] = false;
    }

    public function getStrumSize():Int {return Std.int(genWidth / keyNum);}
    public function getSustainHeight():Int {return Std.int(getScrollSpeed() * getStrumSize() / (bpm * 2.3 / 150));}

    override public function setGraphicToNotes(?_image:String, ?_style:String, ?_type:String){
        super.setGraphicToNotes(_image, _style, _type);
        for(n in notes){n.loadNote(image, style, type);}
    }

    override public function changeKeyNumber(_keys:Int, ?_size:Int, ?force:Bool = false, ?skip:Bool = false){
        super.changeKeyNumber(_keys, _size, force, skip);

        disableArray.resize(this.keyNum);
        pressArray.resize(this.keyNum);
        releaseArray.resize(this.keyNum);
        holdArray.resize(this.keyNum);
    }

    public function loadStrumNotes(swagStrum:SwagStrum){
        var pre_TypeNotes:String = PreSettings.getPreSetting("Note Skin", "Visual Settings");
        this.swagStrum = swagStrum;

        notes = [];
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
                        
                notes.push(swagNote);
        
                if(note.sustainLength <= 0 || note.multiHits > 0){continue;}

                var cSusNote = Math.floor(note.sustainLength / (strumConductor.stepCrochet * 0.25)) + 2;
        
                var prevSustain:Note = swagNote;
                for(sNote in 0...Math.floor(note.sustainLength / (strumConductor.stepCrochet * 0.25)) + 2){
                    var sStrumTime = note.strumTime + (strumConductor.stepCrochet / 2) + ((strumConductor.stepCrochet * 0.25) * sNote);
                    var nSData:NoteData = Note.getNoteData(Note.convNoteData(note));
                    nSData.strumTime = sStrumTime;
        
                    var nSustain:Note = new Note(nSData, keyNum, image, style, type);
                    nSustain.setGraphicSize(getStrumSize(), getSustainHeight());
                    nSustain.updateHitbox();
        
                    nSustain.typeNote = "Sustain";
                    nSustain.typeHit = "Hold";
                    prevSustain.nextNote = nSustain;
                    
                    if(cSusNote == 1 && nSData.canMerge){mergedGroup.push(nSustain);}        
                    notes.push(nSustain);
        
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
                        var ndSustain1:NoteData = Note.getNoteData([n.strumTime, n.noteData]); var nSustain1:Note = new Note(ndSustain1, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain1.nextNote = n; nSustain1.typeNote = "Sustain"; nSustain1.typeHit = "Hold"; nSustain1.setGraphicSize(getStrumSize(), getSustainHeight()); notes.push(nSustain1); nSustain1.alpha = n.alpha;
                        var ndSustain2:NoteData = Note.getNoteData([n.strumTime + (strumConductor.stepCrochet*0.25), n.noteData]); var nSustain2:Note = new Note(ndSustain2, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain2.nextNote = n; nSustain2.typeNote = "Sustain"; nSustain2.typeHit = "Hold"; nSustain2.setGraphicSize(getStrumSize(), getSustainHeight()); notes.push(nSustain2); nSustain2.alpha = n.alpha;
                    }
                    curGroup.push(n);
                }
                if(changeCurrent){
                    curMerge.typeNote = "Merge";
                    if(curMerge.noteLength > 0 && curMerge.nextNote == null){
                        curMerge.loadNote(); curMerge.setGraphicSize(getStrumSize()); curMerge.typeHit = "Release";
                        var ndSustain1:NoteData = Note.getNoteData([curMerge.strumTime, curMerge.noteData]); var nSustain1:Note = new Note(ndSustain1, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain1.nextNote = curMerge; nSustain1.typeNote = "Sustain"; nSustain1.typeHit = "Hold"; nSustain1.setGraphicSize(getStrumSize(), getSustainHeight()); notes.push(nSustain1); nSustain1.alpha = curMerge.alpha;
                        var ndSustain2:NoteData = Note.getNoteData([curMerge.strumTime + (strumConductor.stepCrochet*0.25), curMerge.noteData]); var nSustain2:Note = new Note(ndSustain2, Song.getStrumKeys(cSection, curSection), image, style, type); nSustain2.nextNote = curMerge; nSustain2.typeNote = "Sustain"; nSustain2.typeHit = "Hold"; nSustain2.setGraphicSize(getStrumSize(), getSustainHeight()); notes.push(nSustain2); nSustain2.alpha = curMerge.alpha;
                    }
                }
            
                curGroup.sort((a, b) -> (a.noteData - b.noteData));
                for(ii in 0...curGroup.length){
                    if(curGroup[ii+1] == null){continue;}
                    var currentNote:Note = curGroup[ii]; var nextedNote:Note = curGroup[ii+1]; mergedGroup.remove(currentNote);
                    for(i in currentNote.noteData...(nextedNote.noteData + 1)){
                        if(i > currentNote.noteData){
                            var ndSwitch1:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, -2]); var nSwitcher1:Note = new Note(ndSwitch1, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher1.setGraphicSize(getStrumSize()); nSwitcher1.typeNote = "Switch"; nSwitcher1.typeHit = "Ghost"; notes.push(nSwitcher1); nSwitcher1.alpha = 0.5;
                            var ndSwitch2:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, -1]); var nSwitcher2:Note = new Note(ndSwitch2, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher2.setGraphicSize(getStrumSize()); nSwitcher2.typeNote = "Switch"; nSwitcher2.typeHit = "Ghost"; notes.push(nSwitcher2); nSwitcher2.alpha = 0.5;
                        }
                        if(i < nextedNote.noteData){
                            var ndSwitch1:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, 0]); var nSwitcher1:Note = new Note(ndSwitch1, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher1.setGraphicSize(getStrumSize()); nSwitcher1.typeNote = "Switch"; nSwitcher1.typeHit = "Ghost"; notes.push(nSwitcher1); nSwitcher1.alpha = 0.5;
                            var ndSwitch2:NoteData = Note.getNoteData([currentNote.strumTime, i, 0, 1]); var nSwitcher2:Note = new Note(ndSwitch2, Song.getStrumKeys(cSection, curSection), image, style, type); nSwitcher2.setGraphicSize(getStrumSize()); nSwitcher2.typeNote = "Switch"; nSwitcher2.typeHit = "Ghost"; notes.push(nSwitcher2); nSwitcher2.alpha = 0.5;
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

        if(COMBO > MAXCOMBO){MAXCOMBO = COMBO;}

        if(notes[0] != null){
            if(notes[0].strumTime - strumConductor.songPosition < 3500){
                var nNote:Note = notes[0];
                add(nNote);

                var index:Int = notes.indexOf(nNote);
				notes.splice(index, 1);
            }
        }

        if(!strumGenerated){return;}

        if(swagStrum.notes[curSection] != null){
            var curSec = swagStrum.notes[curSection];

            var nKeys:Int = swagStrum.keys;
            if(curSec.changeKeys){nKeys = curSec.keys;}

            changeKeyNumber(nKeys, genWidth, false, true);
        }

        forEachAlive(function(obj:Dynamic){
            if(!(obj is Note)){return;}
            var daNote:Note = cast obj;

            if(daNote.strumTime > strumConductor.songPosition - Conductor.safeZoneOffset && daNote.strumTime < strumConductor.songPosition + (Conductor.safeZoneOffset * 0.5)){daNote.noteStatus = "CanBeHit";}
            if(strumConductor.songPosition > daNote.strumTime + (Conductor.safeZoneOffset * 0.5) && daNote.noteStatus != "Pressed"){daNote.noteStatus = "Late";}

            var pre_TypeScroll:String = PreSettings.getPreSetting("Typec Scroll", "Visual Settings");
            
            var yStuff:Float = getScroll(daNote);

            daNote.visible = false;
            var noteStrum:StrumNote = statics[daNote.noteData];
            if(noteStrum == null){return;}
            switch(pre_TypeScroll){
                default:{daNote.y = noteStrum.y - yStuff;}
                case "DownScroll":{daNote.y = noteStrum.y + yStuff;}
            }

            daNote.visible = noteStrum.visible;

            if(daNote.typeNote == "Switch"){
                daNote.x = noteStrum.x + ((getStrumSize() * 0.25) * (daNote.noteHits+2));
                daNote.alpha = 0.8;
            }else{
                daNote.x = noteStrum.x;
                daNote.alpha = 1; daNote.angle = noteStrum.angle;
                if(daNote.typeNote == "Sustain" || daNote.typeNote == "SustainEnd"){daNote.alpha = 0.5; daNote.angle = 0;}
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
            forEachAlive(function(obj:Dynamic){
                if(!(obj is Note)){return;}
                var daNote:Note = cast obj;

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
            forEachAlive(function(obj:Dynamic){
                if(!(obj is Note)){return;}
                var daNote:Note = cast obj;

                if(daNote.strumTime <= strumConductor.songPosition && !daNote.hitMiss){hitNOTE(daNote);}
            });
        }
    }

    public function hitNOTE(daNote:Note) {
        daNote.noteStatus = "Pressed";

        if((pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums") && daNote.typeHit != "Ghost"){
            playById(daNote.noteData, "confirm");
            if(daNote.typeHit != "Hold"){statics[daNote.noteData].summonSplash(splash);}
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
            TOTALNOTES ++;
            HITS++;
            SCORE += 20;
            COMBO++;

            rankNote(daNote);
            if(onHIT != null){onHIT(daNote);}
        }
    }

    public function missNOTE(daNote:Note) {
        daNote.kill();
        remove(daNote, true);
        daNote.destroy();

        if(daNote.noteHits > 0){daNote.missHealth *= daNote.noteHits + 1;}
        
        for(event in daNote.otherData){
            if(event[2] != "OnMiss"){continue;} var curScript:Script = Script.getScript(event[0]);
            curScript.setVariable("_note", daNote); curScript.exFunction("execute", event[1]);
        }
        
        if(daNote.ignoreMiss && !daNote.hitMiss){return;}

        TOTALNOTES ++;
        MISSES += 1 + daNote.noteHits;
        SCORE -= 10;
        COMBO = 0;

        if(onMISS != null){onMISS(daNote);}
    }

    public function rankNote(daNote:Note){
        var nDist:Float = Math.abs(daNote.strumTime - strumConductor.songPosition);

        //for(k in P_STAT.keys()){
        //    if(nDist <= k){
        //        if(!STATS.exists(P_STAT.get(k))){STATS.set(P_STAT.get(k), 0);}
        //        STATS.set(P_STAT.get(k), STATS.get(P_STAT.get(k)) + 1);
        //    }
        //}
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