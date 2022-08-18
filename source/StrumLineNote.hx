package;

import states.MusicBeatState;
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

import Script;

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
    
    public var TNOTES:Int = 0;
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
    public var disArray:Array<Bool> = [];
    public var jPressArray:Array<Bool> = [];
    public var holdArray:Array<Bool> = [];
    public var releaseArray:Array<Bool> = [];

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
                addNote(Note.getNoteDynamicData(note));
            }
        }
    }

    var prevNote:Note = null;
    private function addNote(note:Array<Dynamic>, ?merge:Bool = false){
        var pre_Offset:Float = PreSettings.getPreSetting("NoteOffset");

        var daStrumTime:Float = note[0] + pre_Offset;
        var daNoteData:Int = note[1];
        var daLength:Float = note[2];
        var daHits:Int = note[3];
        var daPresset:String = note[4];
        var daHasMerge:Dynamic = note[5];
        var daOtherData:Array<Dynamic> = note[6];
    
        //strumTime, noteData, noteLength, noteHits, notePresset, otherData
        var swagNote:Note = new Note(daStrumTime, daNoteData, daLength, daHits, daPresset, daOtherData);
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
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, daPresset, JSONSTRUM.gameplayNotes[fData.noteData])); cData++;
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, daPresset, JSONSTRUM.gameplayNotes[fData.noteData])); cData++;
                for(i in 1...lDatas){for(ii in 0...4){unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, daPresset, JSONSTRUM.gameplayNotes[fData.noteData + i])); cData++;}}
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, daPresset, JSONSTRUM.gameplayNotes[sData.noteData])); cData++;
                unNotes.push(setSwitcher(cData, daStrumTime, fData.noteData, daPresset, JSONSTRUM.gameplayNotes[sData.noteData])); cData++;
            }
        }else{prevNote = null;}

        unNotes.push(swagNote);

        if(daLength > 0 && daHits == 0){
            var cSusNote = Math.floor(daLength / (strumConductor.stepCrochet * 0.25)) + 2;

            var prevSustain:Note = swagNote;
            for(sNote in 0...Math.floor(daLength / (strumConductor.stepCrochet * 0.25)) + 2){
                var sStrumTime = daStrumTime + (strumConductor.stepCrochet / 2) + ((strumConductor.stepCrochet * 0.25) * sNote);

                var nSustain:Note = new Note(sStrumTime, daNoteData, daLength, daHits, daPresset, daOtherData);
                nSustain.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);
                nSustain.setGraphicSize(getStrumSize(), getSustainHeight());

                nSustain.typeNote = "Sustain";
                nSustain.typeHit = "Hold";
                prevSustain.nextNote = nSustain;

                nSustain.updateHitbox();

                if(cSusNote <= 1 && daHasMerge != null){
                    nSustain.scale.y = 0.75;
                        
                    var nMerge:Note = new Note(sStrumTime, daNoteData, 0, 0, daPresset, daOtherData);
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

    function setSwitcher(i:Int, daStrumTime:Float, noteData:Int, notePresset:String, JSON:NoteJSON):Note {
        var nSwitcher:Note = new Note(daStrumTime, noteData, 0, i, notePresset, null);
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
            
            if(daNote.noteStatus == "Late"){missNOTE(daNote);}
        });

        keyShit();

    
        //PERCENT = Math.min(1, Math.max(0, TNOTES / HITS));
        //for(k in RATING.keys()){if(PERCENT <= k){RATE = RATING.get(k);}}
	}

    private function keyShit():Void{
        if(typeStrum == "Playing"){
            jPressArray = controls.getStrumCheckers(keys, JUST_PRESSED);
            holdArray = controls.getStrumCheckers(keys, PRESSED);
            releaseArray = controls.getStrumCheckers(keys, JUST_RELEASED);

            for(i in 0...disArray.length){
                if(disArray[i]){
                    jPressArray[i] = false;
                    holdArray[i] = false;
                    releaseArray[i] = false;
                }
            }

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
                if(daNote.strumTime <= strumConductor.songPosition && !daNote.hitMiss){hitNOTE(daNote);}
            });
        }
    }

    public function hitNOTE(daNote:Note) {
        daNote.noteStatus = "Pressed";

        if((pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums") && daNote.typeHit != "Ghost"){staticNotes.playById(daNote.noteData, "confirm");}
        
        for(event in daNote.otherData){
            if(!daNote.exFuncts.contains(event) && event[2] == "OnHit"){
                daNote.exFuncts.push(event);

                var args:Array<Dynamic> = event[1]; args.insert(0, daNote);
                MusicBeatState.state.tempScripts.get(event[0]).exFunction("execute", cast args);
            }
        }

        if(daNote.noteHits > 0 && daNote.noteLength > 20){
            daNote.prevStrumTime = daNote.strumTime;
            daNote.strumTime += daNote.noteLength;
            
            daNote.noteHits--;
            
            daNote.noteStatus = "MultiTap";
        }else{
            daNote.kill();
            notes.remove(daNote, true);
            daNote.destroy();
        }

        if(daNote.typeHit != "Ghost"){
            TNOTES ++;
            HITS++;
            SCORE += 20;
            COMBO++;

            if(staticNotes.members[daNote.noteData] != null){
                var strum:StrumNote = staticNotes.members[daNote.noteData];
            
                var splash:NoteSplash = splashGroup.recycle(NoteSplash);
                splash.setup(strum.x, strum.y,daNote);
                splashGroup.add(splash);
            }

            rankNote(daNote);
            if(onHIT != null){onHIT(daNote);}
        }
    }

    public function missNOTE(daNote:Note) {
        daNote.kill();
        notes.remove(daNote, true);
        daNote.destroy();

        if(daNote.noteHits > 0){daNote.missHealth *= daNote.noteHits + 1;}
        
        for(event in daNote.otherData){
            if(!daNote.exFuncts.contains(event) && event[2] == "OnMiss"){
                daNote.exFuncts.push(event);

                var args:Array<Dynamic> = event[1]; args.insert(0, daNote);
                MusicBeatState.state.tempScripts.get(event[0]).exFunction("execute", cast args);
            }
        }

        TNOTES ++;
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
    public var _image:String = "NOTE_assets";
    public var _imageSplash:String = null;

    public var changeColor:Bool = true;
    public var nColor:String = "0xffffff";
    public var _alpha:Float = 1;

    public var onDebug:Bool = false;

	public function new(JSON:NoteJSON = null, newTypeNote:String = "Default", typeImage:String = null, typeSplash:String = null){
        if(typeImage != null){_image = typeImage;}
        if(typeSplash != null){_imageSplash = typeSplash;}
        super();

        if(JSON != null){
            loadGraphicNote(JSON, newTypeNote, typeImage);
            playAnim("static");
        }
	}

    public function loadGraphicNote(newJSON:NoteJSON, newTypeNote:String = "Default", newImage:String = null){
        if(newImage != null){_image = newImage;}

        frames = Paths.getAtlas(Paths.note(_image, newTypeNote));

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
    public static function getNoteDynamicData(note:Array<Dynamic> = null):Array<Dynamic> {
        var strumTime:Float = 0;
        var noteData:Int = 0;
        var noteLenght:Float = 0;
        var noteHits:Float = 0;
        var notePresset:String = "Default";
        var nextNote:Dynamic = null;
        var otherData:Array<Dynamic> = [];

        if(note == null){note = [];}
        if(note[0] != null && (note[0] is Float)){strumTime = cast note[0];}
        if(note[1] != null && (note[1] is Int)){noteData = cast note[1];}    
        if(note[2] != null && (note[2] is Float)){noteLenght = cast note[2];}      
        if(note[3] != null && (note[3] is Int)){noteHits = cast note[3];}
        if(note[4] != null && (note[4] is String)){notePresset = cast note[4];}
        if(note[5] != null && (note[5] is Array)){nextNote = getNoteDynamicData(note[5]);}
        if(note[6] != null && (note[6] is Array)){
            otherData = cast note[5]; if(otherData == null){otherData = [];}

            if(otherData.length > 0){
                for(e in otherData){
                    var ee:Array<Dynamic> = e;
                    if(ee == null){ee = [];}

                    var eFunc:String = ee[0];
                    var eArgs:Array<Dynamic> = ee[1];
                    var eCond:String = ee[2];
                    
                    if(eFunc == null){eFunc = "NAH";}
                    if(eArgs == null){eArgs = [];}
                    if(eCond == null){eCond = "OnHit";}

                    e = [eFunc, eArgs, eCond];
                }
            }
        }
        
        return [strumTime, noteData, noteLenght, noteHits, notePresset, nextNote, otherData];
    }

    public static function getEventDynamicData(event:Array<Dynamic> = null):Array<Dynamic> {
        var strumTime:Float = 0;
        var eventlist:Array<Dynamic> = [];
        var eventCond:String = "OnHit";

        if(event != null){
            if(event[0] != null && (event[0] is Float)){strumTime = event[0];}
            if(event[1] != null){
                eventlist = event[1];

                for(e in eventlist){
                    var eFunc:String = e[0];
                    var eArgs:Array<Dynamic> = e[1];
                    if(eArgs == null){eArgs = [];}

                    e = [eFunc, eArgs];
                }
            }
            if(event[2] != null){eventCond = event[2];}
        }

        return [strumTime, eventlist, eventCond];
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

    public static function getPressets():Array<String>{
        var arrPresset = ["Default"];

        for(i in Paths.readDirectory('assets/notes')){
            var cPresset:String = i;
            if(cPresset.endsWith(".json")){arrPresset.push(cPresset.replace(".json", ""));}
        }

        return arrPresset;
    }
    
    //General Variables
    public var nextNote:Note = null;

    public var prevStrumTime:Null<Float> = null;
    public var strumTime:Float = 1;

	public var noteData:Int = 0;
    public var noteLength:Float = 0;
    public var noteHits:Int = 0; // Determinate if MultiTap o Sustain

    public var typeNote:String = "Normal"; // [Normal, Sustain, Merge] CurNormal Types
    public var typeHit:String = "Press"; // [Press | Normal Hits] [Hold | Hold Hits] [Release | Release Hits] [Always | Just Hit] [Ghost | Just Hit Withowt Strum Anim] [None | Can't Hit]
    public var hitMiss:Bool = false;
    public var ignoreMiss:Bool = false;

	public var otherData:Array<Dynamic> = [];
    public var exFuncts:Array<Dynamic> = [];

    public var chAnim:String = null;

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap
    public var hitHealth:Float = 0.023;
    public var missHealth:Float = 0.0475;

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

	public function new(strumTime:Float, noteData:Int, noteLength:Float = 0, noteHits:Int = 0, notePresset:String = "", otherData:Array<Dynamic> = null){
        this.strumTime = strumTime;
		this.noteData = noteData;
        this.noteLength = noteLength;
        this.noteHits = noteHits;
        if(otherData != null){this.otherData = otherData;}

        var nImg:String = null;
        var nImgSplash:String = null;
        if(notePresset != "" && notePresset.length > 0){
            if(Paths.exists(Paths.notePresset(notePresset))){
                var gPresset:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText(Paths.notePresset(notePresset)));
                
                if(gPresset.exists("Image")){nImg = cast gPresset.get("Image");}
                if(gPresset.exists("ImageSplash")){nImgSplash = cast gPresset.get("ImageSplash");}
                if(gPresset.exists("TypeHit")){typeHit = cast gPresset.get("TypeHit");}
                if(gPresset.exists("HitHealth")){hitHealth = cast gPresset.get("HitHealth");}
                if(gPresset.exists("MissHealth")){missHealth = cast gPresset.get("MissHealth");}
                if(gPresset.exists("Events")){this.otherData = cast gPresset.get("Events");}
                if(gPresset.exists("ChangeColor")){changeColor = cast gPresset.get("ChangeColor");}
                if(gPresset.exists("HitMiss")){hitMiss = cast gPresset.get("HitMiss");}
                if(gPresset.exists("IgnoreMiss")){ignoreMiss = cast gPresset.get("IgnoreMiss");}
            }
        }

        if(this.otherData != null && this.otherData.length > 0){
            for(i in this.otherData){
                if(!MusicBeatState.state.tempScripts.exists(i[0]) && Paths.exists(Paths.event(i[0]))){
                    var nScript = new Script(); nScript.Name = i[0];
                    nScript.exScript(Paths.getText(Paths.event(i[0])));
    
                    MusicBeatState.state.tempScripts.set(i[0], nScript);
                }
            }
        }

        super(null, null, nImg, nImgSplash);
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

        super.loadGraphicNote(newJSON, newTypeNote, newImage);
    }

    override public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);

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
        if(image == null && note != null){image = note._imageSplash;}
        if(image == null){image = IMAGE_DEFAULT;}

        this.setPosition(X, Y);

        if(note != null){}

        frames = Paths.getAtlas(Paths.note(image));
        animation.addByPrefix("Splash", "Splash", 30, false);

        playAnim("Splash");
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