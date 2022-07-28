package;

import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.DynamicAccess;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

import flixel.math.FlxMath;

import flixel.group.FlxGroup;

import Section.SwagSection;
import Song.SwagStrum;

using StringTools;

typedef StrumLineNoteJSON = {
    var staticNotes:Array<NoteJSON>;
    var gameplayNotes:Array<NoteJSON>;
    var noteSplash:String;
}

typedef NoteJSON = {
    var colorHEX:String;
    var arrayAnims:Array<NoteAnimJSON>;
    var chAnim:String;

    var alpha:Float;
    var scale:Int;
    var antialiasing:Bool;
}

typedef NoteAnimJSON = {
    var anim:String;
    var symbol:String;
    var indices:Array<Int>;

    var fps:Int;
    var loop:Bool;
}

class StrumLine extends FlxGroup{
    public var onHIT:Note->Void = null;
    public var onMISS:Note->Void = null;

    // STATS VARIABLES
    public var HEALTH:Float = 1;
    public var MAXHEALTH:Float = 2;

    public var nSTATS:Map<String, Int> = [];
    
    public var HITS:Int = 0;
    public var MISSES:Int = 0;
    
    public var SCORE:Float = 0;
    public var PERCENT:Int = 0;

    public var COMBO:Int = 0;
    public var MAXCOMBO:Int = 0;
    // ===============

    public var swagStrum:SwagStrum = null;
    public var strumConductor:Conductor = null;

    private var splashGroup:FlxTypedGroup<NoteSplash>;
    public var staticNotes:StrumStaticNotes;

    public var notes:FlxTypedGroup<Note>;
    public var unNotes:Array<Note> = [];

    public var scrollSpeed:Float = 1;
    public var bpm:Float = 150;

    public var health:Float = 1;
    public var maxHealth:Float = 2;

    public var typeStrum:String = "BotPlay"; //BotPlay, Playing, Charting

    public var strumSize:Int = 110;

    public var JSONSTRUM:StrumLineNoteJSON;
    public var image:String = "NOTE_assets";
    public var noteType:String = "Default";

    public var keys:Int = 0;
    public var controls:Controls;

    public function new(x:Float, y:Float, keys:Int, size:Int){
        this.strumSize = size;
        this.keys = keys;
        super();

        JSONSTRUM = cast Json.parse(Paths.getText(Paths.getStrumJSON(keys)));

        staticNotes = new StrumStaticNotes(x, y, keys, strumSize);
        add(staticNotes);

        notes = new FlxTypedGroup<Note>();
        add(notes);

        splashGroup = new FlxTypedGroup<NoteSplash>();
        splashGroup.add(new NoteSplash());
        add(splashGroup);
    }

    public function getStrumSize():Int {return Std.int(strumSize / keys);}
    public function getSustainHeight():Int {return Std.int(getScrollSpeed() * getStrumSize() / (bpm * 2.3 / 150));}

    public function changeGraphic(newImage:String, newType:String){
        if(image != newImage){image = newImage;}
        if(noteType != newType){noteType = newType;}

        changeKeyNumber(keys, strumSize, true);
    }

    public function changeKeyNumber(keys:Int, size:Int, ?force:Bool = false){
        this.keys = keys;

        JSONSTRUM = cast Json.parse(Paths.getText(Paths.getStrumJSON(keys)));
        
        staticNotes.size = size;
        staticNotes.changeKeys(keys, force);

        if(size != strumSize || force){setNotes(swagStrum);}

        this.strumSize = size;
    }

    public function setNotes(swagStrum:SwagStrum){
        var pre_TypeNotes:String = PreSettings.getFromArraySetting("TypeNotes");

        this.swagStrum = swagStrum;

        notes.clear();
        unNotes = [];

        for(sSection in swagStrum.notes){
            for(note in sSection.sectionNotes){
                addNote(note);
            }
        }
    }

    var prevNote:Note = null;
    private function addNote(note:Array<Dynamic>, ?merge:Bool = false){
        var pre_Offset:Float = PreSettings.getPreSetting("NoteOffset");

        var daStrumTime:Float = note[0] + pre_Offset;
        var daNoteData:Int = Std.int(note[1]);
        var daLength:Float = note[2];
        var daHits:Int = note[3];
        var daHasMerge:Dynamic = note[4];
        var daOtherData:Map<String, Array<Dynamic>> = note[5];
    
        //noteJSON:NoteJSON, typeCheck:String, strumTime:Float, noteData:Int, ?specialType:Int = 0, ?otherData:Array<NoteData>
        var swagNote:Note = new Note(daStrumTime, daNoteData, daLength, daHits, daOtherData);
        swagNote.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);
        swagNote.setGraphicSize(getStrumSize());

        if(merge){swagNote.typeNote = "Merge";
            var fData:Note = prevNote;
            var sData:Note = swagNote;
            var lDatas:Int = swagNote.noteData - prevNote.noteData;
            if(swagNote.noteData <  prevNote.noteData){
                fData = swagNote;
                sData = prevNote;
                lDatas = prevNote.noteData - swagNote.noteData;
            }

            if(fData.noteData != sData.noteData){   var cData:Int = 0;
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, JSONSTRUM.gameplayNotes[fData.noteData])); cData++;
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, JSONSTRUM.gameplayNotes[fData.noteData])); cData++;
                for(i in 1...lDatas){for(ii in 0...4){unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, JSONSTRUM.gameplayNotes[fData.noteData + i])); cData++;}}
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, JSONSTRUM.gameplayNotes[sData.noteData])); cData++;
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, JSONSTRUM.gameplayNotes[sData.noteData])); cData++;
            }
        }else{prevNote = null;}

        unNotes.push(swagNote);

        if(daLength > 0 && daHits == 0){
            var cSusNote = Math.floor(daLength / (strumConductor.stepCrochet * 0.25)) + 2;

            var prevSustain:Note = swagNote;
            for(sNote in 0...Math.floor(daLength / (strumConductor.stepCrochet * 0.25)) + 2){
                var sStrumTime = daStrumTime + (strumConductor.stepCrochet / 2) + ((strumConductor.stepCrochet * 0.25) * sNote);

                var nSustain:Note = new Note(sStrumTime, daNoteData, daLength, daHits, daOtherData);
                nSustain.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);
                nSustain.setGraphicSize(getStrumSize(), getSustainHeight());

                nSustain.typeNote = "Sustain";
                nSustain.typeHit = "Hold";
                prevSustain.nextNote = nSustain;

                nSustain.updateHitbox();

                if(cSusNote <= 1 && daHasMerge != null){
                    nSustain.scale.y = 0.75;
                        
                    var nMerge:Note = new Note(sStrumTime, daNoteData, 0, 0, daOtherData);
                    nMerge.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);
                    nMerge.setGraphicSize(getStrumSize());
                    nMerge.typeNote = "Merge";
                    nMerge.typeHit = "Release";

                    prevNote = nMerge;
                    nSustain.nextNote = nMerge;

                    unNotes.push(nMerge);
                        
                    daHasMerge[0] = sStrumTime;
                    nMerge.nextNote = addNote(daHasMerge, true);
                }

                unNotes.push(nSustain);

                prevSustain = nSustain;
                cSusNote--;
            }  
        }
        return swagNote;
    }

    function setSwitcher(i:Int, daStrumTime:Float, noteData:Int, JSON:NoteJSON):Note {
        var nSwitcher:Note = new Note(daStrumTime, noteData, 0, i, null);
        nSwitcher.loadGraphicNote(JSON);
        nSwitcher.setGraphicSize(getStrumSize());
        nSwitcher.typeNote = "Switch";
        nSwitcher.typeHit = "Ghost";

        return nSwitcher;
    }

    var pre_TypeStrums:String = PreSettings.getFromArraySetting("TypeLightStrums");
    override function update(elapsed:Float){
		super.update(elapsed);

        if(COMBO > MAXCOMBO){MAXCOMBO = COMBO;}

        if(unNotes[0] != null){
            if(unNotes[0].strumTime - strumConductor.songPosition < 3500){
                var nNote:Note = unNotes[0];
                notes.add(nNote);

                var index:Int = unNotes.indexOf(nNote);
				unNotes.splice(index, 1);
            }
        }

        if(swagStrum.notes[Std.int(strumConductor.getCurStep() / 16)] != null){
            var curSec = swagStrum.notes[Std.int(strumConductor.getCurStep() / 16)];

            var nKeys:Int = swagStrum.keys;
            if(curSec.changeKeys){nKeys = curSec.keys;}

            changeKeyNumber(nKeys, strumSize);
        }

        notes.forEachAlive(function(daNote:Note){            
            if(daNote.strumTime > strumConductor.songPosition - Conductor.safeZoneOffset && daNote.strumTime < strumConductor.songPosition + (Conductor.safeZoneOffset * 0.5)){daNote.noteStatus = "CanBeHit";}
            if(strumConductor.songPosition > daNote.strumTime + (Conductor.safeZoneOffset * 0.5) && daNote.noteStatus != "Pressed"){daNote.noteStatus = "Late";}

            var pre_TypeScroll:String = PreSettings.getFromArraySetting("TypeScroll");
            
            var curScrollspeed:Float = getScrollSpeed();

            //var yStuff:Float = 0.45 * (strumConductor.songPosition - daNote.strumTime) * curScrollspeed;
            var yStuff:Float = 0.45 * (strumConductor.songPosition - daNote.strumTime) * curScrollspeed;
            if(daNote.prevStrumTime != null){yStuff = (0.005 * Math.pow(strumConductor.songPosition - daNote.strumTime, 2) + (3 * (strumConductor.songPosition - daNote.strumTime)));}

            if(staticNotes.members[daNote.noteData] != null){
                if(pre_TypeScroll == "DownScroll"){
                    daNote.y = staticNotes.members[daNote.noteData].y + yStuff;
                }else if(pre_TypeScroll == "UpScroll"){
                    daNote.y = staticNotes.members[daNote.noteData].y - yStuff;
                }

                daNote.visible = staticNotes.members[daNote.noteData].visible;

                if(daNote.typeNote == "Switch"){
                    daNote.x = staticNotes.members[daNote.noteData].x + ((getStrumSize() / 4) * daNote.noteHits);
                    daNote.alpha = staticNotes.members[daNote.noteData].alpha * (daNote._alpha / 2) / 1;
                    daNote.angle = 270;
                }else{
                    daNote.x = staticNotes.members[daNote.noteData].x;
                    if(daNote.typeNote == "Sustain" || daNote.typeNote == "SustainEnd"){
                        daNote.alpha = staticNotes.members[daNote.noteData].alpha * (daNote._alpha / 2) / 1;
                    }else{
                        daNote.alpha = staticNotes.members[daNote.noteData].alpha * daNote._alpha / 1;
                        daNote.angle = staticNotes.members[daNote.noteData].angle;
                    }
                } 
            }else{
                daNote.visible = false;
            }
            
            //if(daNote.noteStatus == "Late"){missNOTE(daNote);}
        });

        keyShit();
	}

    private function keyShit():Void{
        if(typeStrum == "Playing"){
            var jPressArray:Array<Bool> = controls.getStrumCheckers(keys, JUST_PRESSED);
            var holdArray:Array<Bool> = controls.getStrumCheckers(keys, PRESSED);
            var releaseArray:Array<Bool> = controls.getStrumCheckers(keys, JUST_RELEASED);

            staticNotes.forEach(function(staticStrum:StrumNote){
                if(staticStrum.animation.curAnim.name == "static" && holdArray[staticStrum.ID]){
                    staticStrum.playAnim("pressed");
                }

                if(releaseArray[staticStrum.ID]){
                    staticStrum.playAnim("static");
                }
            });
    
            notes.forEachAlive(function(daNote:Note){
                if(daNote.noteStatus == "CanBeHit" &&
                    (
                        (daNote.typeHit == "Press" && jPressArray[daNote.noteData]) ||
                        (daNote.typeHit == "Hold" && holdArray[daNote.noteData]) ||
                        (daNote.typeHit == "Release" && releaseArray[daNote.noteData]) ||
                        (daNote.typeHit == "Always" || daNote.typeHit == "Ghost")
                    )
                ){
                    hitNOTE(daNote);
                }
            });
        }else if(typeStrum == "BotPlay"){
            staticNotes.forEach(function(staticStrum:StrumNote){
                if(staticStrum.animation.curAnim.name == "confirm" && staticStrum.animation.finished){
                    staticStrum.playAnim("static");
                }
            });

            notes.forEachAlive(function(daNote:Note){
                if(daNote.strumTime <= strumConductor.songPosition){hitNOTE(daNote);}
            });
        }
    }

    public function hitNOTE(daNote:Note) {
        if((pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums") && daNote.typeHit != "Ghost"){staticNotes.playById(daNote.noteData, "confirm");}
        
        daNote.noteStatus = "Pressed";


        if(daNote.noteHits > 0 && daNote.noteLength > 20){
            daNote.noteStatus = "MultiTap";

            daNote.prevStrumTime = daNote.strumTime;
            daNote.strumTime += daNote.noteLength;
            
            daNote.noteHits--;
        }else{
            daNote.kill();
            notes.remove(daNote, true);
            daNote.destroy();
        }

        if(daNote.typeHit != "Ghost"){
            HITS++;
            SCORE += 20;
            COMBO++;

            if(staticNotes.members[daNote.noteData] != null){
                var strum:StrumNote = staticNotes.members[daNote.noteData];
            
                var splash:NoteSplash = splashGroup.recycle(NoteSplash);
                splash.setup(strum.x, strum.y,daNote);
                splashGroup.add(splash);
            }

            if(onHIT != null){onHIT(daNote);}
        }
    }

    public function missNOTE(daNote:Note) {
        daNote.kill();
        notes.remove(daNote, true);
        daNote.destroy();

        MISSES += 1 + daNote.noteHits;
        SCORE -= 10;
        COMBO = 0;

        if(onMISS != null){onMISS(daNote);}
    }

    public function getScrollSpeed():Float{
        var pre_TypeScrollSpeed:String = PreSettings.getFromArraySetting("ScrollSpeedType");
        var pre_ScrollSpeed:Float = PreSettings.getPreSetting("ScrollSpeed");

        switch(pre_TypeScrollSpeed){
            case "Scale":{return scrollSpeed * pre_ScrollSpeed;}
            case "Force":{return pre_ScrollSpeed;}
            default:{return scrollSpeed;}
        }
    }
}

class StrumStaticNotes extends FlxTypedGroup<StrumNote> {
    public var x:Float = 0;
    public var y:Float = 0;

    public var size:Int = 110;
    public var keys:Int = 0;
    public var JSON:Array<NoteJSON>;

    public function new(x:Float, y:Float, keys:Int = 4, ?size:Int = 110){
        this.x = x;
        this.y = y;
        this.size = size;
        super();
        
        changeKeys(keys, true, true, size);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        this.forEach(function(daStrum:StrumNote){
            if(daStrum.animation.finished){
                daStrum.playAnim("static");
            }
        });
	}

    public function playById(id:Int, anim:String, force:Bool = false){
        if(this.members[id] != null){
            this.members[id].playAnim(anim, force);
        }
    }

    public function changeKeys(nKeys:Int, ?force:Bool = false, ?skip:Bool = false, ?SIZE:Int = 0){
        if((this.keys != nKeys && nKeys > 0) || force){
            this.keys = nKeys;
            if(SIZE != 0){size = SIZE;}
            var nSize:Int = Math.floor(size / keys);
            
            var newJSON:StrumLineNoteJSON = cast Json.parse(Paths.getText(Paths.getStrumJSON(keys)));
            JSON = newJSON.staticNotes;

            if(skip){
                this.clear();

                for(i in 0...keys){
                    var strum:StrumNote = new StrumNote(JSON[i]);
                    strum.setPosition(this.x + (nSize * i), y);
                    strum.ID = i;
                    strum.setGraphicSize(nSize);
                    add(strum);
                }
            }else{
                if(this.members.length > 0){
                    for(i in 0...this.members.length){
                        var strum = this.members[i];
                        strum.onDebug = true;
    
                        FlxTween.tween(strum, {alpha: 0, y: strum.y + (strum.height / 2)}, (0.5 * (i + 1) / this.members.length), {
                            ease: FlxEase.quadInOut,
                            onComplete: function(twn:FlxTween){
                                this.members.remove(strum);
                            }
                        });
                    }
                }
                
                for(i in 0...keys){
                    var strum:StrumNote = new StrumNote(JSON[i]);
                    strum.setPosition(this.x + (nSize * i), y - (nSize / 2));
                    strum.ID = i;
                    strum.alpha = 0;
                    strum.setGraphicSize(nSize);
                    add(strum);
    
                    FlxTween.tween(strum, {alpha: strum._alpha, y: y}, (0.5 * (i + 1) / keys), {ease: FlxEase.quadInOut});
                }
            }
        }
    }
}

class StrumNote extends FlxSprite{
    public static var IMAGE_DEFAULT:String = "NOTE_assets";

    public var nColor:String = "0xffffff";
    public var _alpha:Float = 1;

    public var onDebug:Bool = false;

	public function new(JSON:NoteJSON = null, newTypeNote:String = "Default", typeImage:String = null){
        super();

        if(JSON != null){
            loadGraphicNote(JSON, newTypeNote, typeImage);
            playAnim("static");
        }
	}

    public function loadGraphicNote(newJSON:NoteJSON, newTypeNote:String = "Default", newImage:String = null){
        if(newImage == null){newImage = IMAGE_DEFAULT;}

        frames = Paths.getNoteAtlas(newImage, newTypeNote);

        var anims = newJSON.arrayAnims;
        for(anim in anims){
            if(anim.indices != null && anim.indices.length > 0){
                animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
            }else{
                animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
            }
        }
        
        if(newJSON.colorHEX != null){nColor = newJSON.colorHEX;}
        antialiasing = newJSON.antialiasing && PreSettings.getPreSetting("Antialiasing");
        _alpha = newJSON.alpha;

    }

    public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);

        if(anim != "static"){
            this.color = FlxColor.fromString(nColor);
        }else{
            this.color = 0xffffff;
        }
	}

    override function update(elapsed:Float){
        this.updateHitbox();
		super.update(elapsed);
	}

    override public function setGraphicSize(Width:Int = 0, Height:Int = 0):Void{
        super.setGraphicSize(Width, Height);
    }
}

class Note extends StrumNote {
    //Static Methods
    public static function getNoteDynamicData(note:Array<Dynamic> = null, details:Bool = false):Array<Dynamic> {
        var strumTime:Float = 0;
        var noteData:Int = 0;
        var noteLenght:Float = 0;
        var noteHits:Float = 0;
        var nextNote:Dynamic = null;
        var otherData:Map<String, Array<Dynamic>> = [];

        if(note != null){
            if(note[0] != null){strumTime = note[0];}
            if(note[1] != null){noteData = note[1];}    
            if(note[2] != null){noteLenght = note[2];}      
            if(note[3] != null){noteHits = note[3];}  
            if(note[4] != null && ((details && note[4].lenght >= 6) || (!details))){nextNote = getNoteDynamicData(note[4], true);}
            if(note[5] != null){otherData = note[5];}
        }
        
        return [strumTime, noteData, noteLenght, noteHits, nextNote, otherData];
    }

    public static function getEventDynamicData(event:Array<Dynamic> = null):Array<Dynamic> {
        var strumTime:Float = 0;
        var eventlist:Map<String, Array<Dynamic>> = [];

        if(event != null){
            if(event[0] != null && (event[0] is Float)){strumTime = event[0];}
            if(event[1] != null){
                eventlist = event[1];

                for(e in eventlist.keys()){
                    var eFunc:String = e;
                    var eArgs:Array<Dynamic> = [];
                    if(eventlist.exists(eFunc) && (eventlist.get(eFunc) is Array<Dynamic>)){eArgs = eventlist.get(eFunc);}

                    eventlist.set(eFunc, eArgs);
                }

                event[1] = eventlist;
            }
        }

        return [strumTime, eventlist];
    }

    public static function getEvents(?stage:String){
        var events = [];

        #if sys 
            for(i in Paths.readDirectory('assets/data/events')){
                var cEvent:String = i;
                if(cEvent.endsWith(".hx")){events.push(cEvent.replace(".hx", ""));}
            }
            
            if(stage != null){
                for(i in Paths.readDirectory('assets/stages/${stage}/events')){
                    var cEvent:String = i;
                    if(cEvent.endsWith(".hx")){events.push(cEvent.replace(".hx", ""));}
                }
            }
        #end

        return events;
    }
    
    //General Variables
    public var nextNote:Note = null;

    public var prevStrumTime:Null<Float> = null;
    public var strumTime:Float = 1;

    public var noteLength:Float = 0;
    public var noteHits:Int = 0; // Determinate if MultiTap o Sustain

    public var typeNote:String = "Normal"; // [Normal, Sustain, Merge] CurNormal Types
    public var typeHit:String = "Press"; // [Press | Normal Hits] [Hold | Hold Hits] [Release | Release Hits] [Always | Just Hit] [Ghost | Just Hit Withowt Strum Anim] [None | Can't Hit]

	public var noteData:Int = 0;
	public var otherData:Map<String, Array<Dynamic>> = [];

    public var chAnim:String = null;

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap

    public static function getStyles():Array<String>{
        var styleArray:Array<String> = [];

        #if sys
            for(i in FileSystem.readDirectory(FileSystem.absolutePath('assets/notes/${PreSettings.getFromArraySetting("NoteSyle")}'))){
                if(!i.endsWith(".json")){
                    styleArray.push(i);
                }
            }
        #else
            styleArray = [
                "Default",
                "Pixel",
                "Angry",
                "White"
            ];
        #end

        return styleArray;
    }

	public function new(strumTime:Float, noteData:Int, noteLength:Float = 0, noteHits:Int = 0, otherData:Map<String, Array<Dynamic>> = null){
        this.strumTime = strumTime;
		this.noteData = noteData;
        this.noteLength = noteLength;
        this.noteHits = noteHits;
        if(otherData != null){this.otherData = otherData;}

        super();
	}

    override function update(elapsed:Float){
		super.update(elapsed);

        switch(this.typeNote){
            case "Normal":{playAnim("static");}
            case "Sustain":{
                if(this.nextNote != null){
                    playAnim("sustain");
                }else{
                    playAnim("end");
                }
            }
            case "Merge":{playAnim("merge");}
            case "Switch":{playAnim("switch");}
        }
	}

    override public function loadGraphicNote(newJSON:NoteJSON, newTypeNote:String = "Default", newImage:String = null){
        if(newJSON != null){chAnim = newJSON.chAnim;}

        if(newImage == null && otherData.exists("New_Image")){newImage = otherData.get("New_Image")[0];}

        super.loadGraphicNote(newJSON, newTypeNote, newImage);
    }

    override public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);

        if(!otherData.exists("Change_Color") || otherData.get("Change_Color")[0]){this.color = FlxColor.fromString(nColor);}
	}
}

class NoteSplash extends FlxSprite {
    public static var IMAGE_DEFAULT:String = "NOTE_splash_comic";

    public var onSplashed:Void->Void = null;

    public var nColor:String = "0xffffff";

    public function new(X:Int = 0, Y:Int = 0, note:Note = null, image:String = null){
        super();

        onSplashed = function(){this.kill();};

        setup(X, Y, note, image);
    } 

    override function update(elapsed:Float){
		super.update(elapsed);

        if(animation.finished){onSplashed();}
	}

    public function setup(X:Float = 0, Y:Float = 0, note:Note = null, image:String = null){
        if(image == null){image = IMAGE_DEFAULT;}

        this.setPosition(X, Y);

        if(note != null){
            if(!note.otherData.exists("Change_Color") || note.otherData.get("Change_Color")[0]){nColor = note.nColor;}
        }

        frames = Paths.getNoteAtlas(image);

        animation.addByPrefix("Idle", "Idle", 30, false);

        playAnim("Idle");
    }

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        if(anim != "static"){
            this.color = FlxColor.fromString(nColor);
        }else{
            this.color = 0xffffff;
        }
	}
}