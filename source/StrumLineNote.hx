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

#if windows
import sys.FileSystem;
import sys.io.File;
#end

import flixel.math.FlxMath;

import flixel.group.FlxGroup;

import Section.SwagSection;

using StringTools;

typedef StrumLineNoteJSON = {
    var staticNotes:Array<NoteJSON>;
    var gameplayNotes:Array<NoteJSON>;
    var noteSplash:String;
}

typedef NoteJSON = {
    var colorHSL:Array<Int>;
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

typedef NoteData = {
	var type:String;
	var values:Array<Dynamic>;
}

class StrumLine extends FlxGroup{
    public static inline var HIT_EVENT:String = "StrumLine_OnHit"; 
    public static inline var MISS_EVENT:String = "StrumLine_OnMiss"; 

    public var staticNotes:StrumStaticNotes;
    public var notes:FlxTypedGroup<Note>;

    public var scrollSpeed:Float = 1;
    public var bpm:Float = 150;

    public var typeStrum:String = "BotPlay"; //BotPlay, Playing, Charting

    public var strumSize:Int = 110;

    public var JSONSTRUM:StrumLineNoteJSON;
    public var image:String = "NOTE_assets";
    public var noteType:String = "Default";

    public var keys:Int = 0;

    public function new(x:Float, y:Float, keys:Int, size:Int){
        this.strumSize = size;
        this.keys = keys;
        super();

        JSONSTRUM = cast Json.parse(Assets.getText(Paths.strumJSON(keys)));

        staticNotes = new StrumStaticNotes(x, y, keys, strumSize);
        add(staticNotes);

        notes = new FlxTypedGroup<Note>();
        add(notes);
    }

    public function changeGraphic(newImage:String, newType:String){
        if(image != newImage){image = newImage;}
        if(noteType != newType){noteType = newType;}

        changeKeyNumber(keys, strumSize, true);
    }

    public function changeKeyNumber(keys:Int, size:Int, ?force:Bool = false){
        this.strumSize = size;
        this.keys = keys;

        JSONSTRUM = cast Json.parse(Assets.getText(Paths.strumJSON(keys)));
        
        staticNotes.size = strumSize;
        staticNotes.changeKeys(keys, force);
    }

    public function setNotes(swagNotes:Array<SwagSection>){
        var pre_Offset:Float = PreSettings.getPreSetting("NoteOffset");
        var pre_TypeNotes:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeNotes"));

        notes.clear();

        for(section in swagNotes){
            for(strumNotes in section.sectionNotes){
                var daSpecialData:Int = Std.int(strumNotes[4]);
                if(pre_TypeNotes == "All" || (pre_TypeNotes == "OnlyNormal" && daSpecialData == 0) || (pre_TypeNotes == "OnlySpecials" && daSpecialData != 0) || (pre_TypeNotes == "DisableBads" && daSpecialData <= 0) || (pre_TypeNotes == "DisableGoods" && daSpecialData >= 0)){
                    var daStrumTime:Float = strumNotes[0] + pre_Offset;
                    var daNoteData:Int = Std.int(strumNotes[1]);
                    var daLength:Float = strumNotes[2];
                    var daHits:Int = strumNotes[3];

                    var daOtherData:Array<NoteData> = strumNotes[5];
    
                    //noteJSON:NoteJSON, typeCheck:String, strumTime:Float, noteData:Int, ?specialType:Int = 0, ?otherData:Array<NoteData>
                    var swagNote:Note = new Note(daStrumTime, daNoteData, daLength, daHits, daSpecialData, daOtherData);
                    swagNote.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);
                    swagNote.setGraphicSize(Std.int(staticNotes.size / keys));
                    swagNote.updateHitbox();
                    notes.add(swagNote);

                    if(daLength > 0 && daHits == 0){
                        var cSusNote = Math.floor(daLength / (Conductor.stepCrochet * 0.25)) + 2;
                        for(sNote in 0...Math.floor(daLength / (Conductor.stepCrochet * 0.25)) + 2){
                            var sStrumTime = daStrumTime + (Conductor.stepCrochet / 2) + ((Conductor.stepCrochet * 0.25) * sNote);

                            var nSustain:Note = new Note(sStrumTime, daNoteData, daLength, daHits, daSpecialData, daOtherData);
                            nSustain.loadGraphicNote(JSONSTRUM.gameplayNotes[daNoteData]);

                            if(cSusNote > 1){nSustain.typeNote = "Sustain";}
                            else{nSustain.typeNote = "SustainEnd";}

                            var nHeight:Int = Std.int(getScrollSpeed() * staticNotes.size / (bpm * 2.3 / 150));
                            nSustain.setGraphicSize(Std.int(staticNotes.size / keys), nHeight);
                            nSustain.updateHitbox();

                            notes.add(nSustain);
                            cSusNote--;
                        }  
                    }
                }
            }
        }
    }

    var pre_TypeStrums:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeLightStrums"));
    override function update(elapsed:Float){
		super.update(elapsed);

        keyShit();

        notes.forEachAlive(function(daNote:Note){
            var pre_TypeScroll:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeScroll"));
            
            if(daNote.noteStatus == "late"){
                daNote.active = false;
                daNote.visible = false;
            }else{
                daNote.visible = true;
                daNote.active = true;
            }

            var curScrollspeed:Float = getScrollSpeed();

            daNote.updateHitbox();
            var yStuff:Float = 0.45 * (Conductor.songPosition - daNote.strumTime) * curScrollspeed;
            if(staticNotes.members[daNote.noteData].exists){
                if(pre_TypeScroll == "DownScroll"){
                    daNote.y = (staticNotes.members[daNote.noteData].y + yStuff);
                }else if(pre_TypeScroll == "UpScroll"){
                    daNote.y = (staticNotes.members[daNote.noteData].y - yStuff);
                }

                daNote.visible = staticNotes.members[daNote.noteData].visible;
                if(daNote.typeNote == "Sustain" || daNote.typeNote == "SustainEnd"){
                    daNote.alpha = staticNotes.members[daNote.noteData].alpha * (daNote._alpha / 2) / 1;
                    daNote.x = staticNotes.members[daNote.noteData].x;
                }else{
                    daNote.alpha = staticNotes.members[daNote.noteData].alpha * daNote._alpha / 1;
                    daNote.x = staticNotes.members[daNote.noteData].x;
                    daNote.angle = staticNotes.members[daNote.noteData].angle;
                }   
            }else{
                daNote.visible = false;
            }

            if(daNote.noteStatus == "Pressed"){
                if(pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums"){
                    staticNotes.members[daNote.noteData].playAnim("confirm");
                }

                if(daNote.noteHits > 0 && daNote.noteLength > 20){
                    daNote.noteStatus = "MultiTap";
                    daNote.strumTime += daNote.noteLength;
                    daNote.noteHits--;
                }else{
                    daNote.active = false;

                    daNote.kill();
                }
            }
        });
	}

    private function keyShit():Void{
        if(typeStrum == "Playing"){
            var jPressArray:Array<Bool> = Controls.getStrumBind(keys + "K", "JUST_PRESSED");
            var holdArray:Array<Bool> = Controls.getStrumBind(keys + "K", "PRESSED");
            var releaseArray:Array<Bool> = Controls.getStrumBind(keys + "K", "JUST_RELEASED");

            staticNotes.forEach(function(staticStrum:StrumNote){
                if(staticStrum.animation.curAnim.name == "static" && holdArray[staticStrum.ID]){
                    staticStrum.playAnim("pressed");
                }

                if(releaseArray[staticStrum.ID]){
                    staticStrum.playAnim("static");
                }
            });
    
            notes.forEachAlive(function(daNote:Note){
                if(daNote.noteStatus == "CanBeHit" && ((jPressArray[daNote.noteData] && daNote.typeNote == "Normal") || (holdArray[daNote.noteData] && (daNote.typeNote == "Sustain" || daNote.typeNote == "SustainEnd")))){
                    if(pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums"){
                        staticNotes.members[daNote.noteData].playAnim("confirm");
                    }
    
                    daNote.noteStatus = "Pressed";
                }
            });
        }else if(typeStrum == "BotPlay"){
            staticNotes.forEach(function(staticStrum:StrumNote){
                if(staticStrum.animation.curAnim.name == "confirm" && staticStrum.animation.finished){
                    staticStrum.playAnim("static");
                }
            });

            notes.forEachAlive(function(daNote:Note){
                if(daNote.strumTime <= Conductor.songPosition){
                    if(pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums"){
                        staticNotes.members[daNote.noteData].playAnim("confirm");
                    }
    
                    daNote.noteStatus = "Pressed";
                }
            });
        }else if(typeStrum == "Charting"){
            notes.forEachAlive(function(daNote:Note){
                if(daNote.noteStatus == "CanBeHit"){
                    staticNotes.members[daNote.noteData].playAnim("confirm");
                }
            });
        }
    }

    public function getScrollSpeed():Float{
        var pre_TypeScrollSpeed:String = PreSettings.getArraySetting(PreSettings.getPreSetting("ScrollSpeedType"));
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
        
        changeKeys(keys);
    }

    public function changeKeys(nKeys:Int, ?force:Bool = false, ?ns:Int = 0){
        if((this.keys != nKeys && nKeys > 0) || force){
            this.keys = nKeys;
            if(ns != 0){size = ns;}
            var nSize:Int = Math.floor(size / keys);
            
            var newJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumJSON(keys)));
            JSON = newJSON.staticNotes;
    
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

class StrumNote extends FlxSprite{
    public var nColor:Array<Int> = [0xffffff, 1, 1];
    public var _alpha:Float = 1;

    public var onDebug:Bool = false;

	public function new(JSON:NoteJSON = null, newTypeNote:String = "Default", typeImage:String = "NOTE_assets"){
        super();

        loadGraphicNote(JSON, newTypeNote, typeImage);
        playAnim("static");
	}

    public function loadGraphicNote(newJSON:NoteJSON = null, newTypeNote:String = "Default", newImage:String = "NOTE_assets"){
        if(newJSON == null){
            var cJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumJSON(4)));
            newJSON = cJSON.staticNotes[0];
        }

        frames = Paths.getNoteAtlas(newImage, newTypeNote);

        var anims = newJSON.arrayAnims;
        for(anim in anims){
            if(anim.indices != null && anim.indices.length > 0){
                animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
            }else{
                animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
            }
        }
        
        if(newJSON.colorHSL != null){nColor = newJSON.colorHSL;}
        antialiasing = newJSON.antialiasing && PreSettings.getPreSetting("Antialiasing");
        _alpha = newJSON.alpha;

    }

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        if(anim != "static"){
            this.color = FlxColor.fromHSL(nColor[0], nColor[1], nColor[2]);
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
    //General Variables
    public var strumTime:Float = 1;

    public var canMerge:Bool = false; // Determinate if the note Can be Merge with surrounding notes
    public var noteLength:Float = 0;
    public var noteHits:Int = 0; // Determinate if MultiTap o Sustain

    public var typeNote:String = "Normal"; // CurNormal Types

	public var noteData:Int = 0;
    public var specialData:Int = 0;
	public var otherData:Array<NoteData> = [];

    public var chAnim:String = null;

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap

    public static function getStyles():Array<String>{
        var styleArray:Array<String> = [];

        #if windows
            for(i in FileSystem.readDirectory(FileSystem.absolutePath('assets/notes/${PreSettings.getArraySetting(PreSettings.getPreSetting("NoteSyle"))}'))){
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

	public function new(strumTime:Float, noteData:Int, ?noteLength:Float = 0, ?noteHits:Int = 0, ?specialType:Int = 0, ?otherData:Array<NoteData>){
        this.strumTime = strumTime;
		this.noteData = noteData;
        this.noteLength = noteLength;
        this.noteHits = noteHits;
        this.specialData = specialType;
        this.otherData = otherData;
        super();
	}

    override function update(elapsed:Float){
		super.update(elapsed);

        switch(typeNote){
            case "Normal":{playAnim("static");}
            case "Sustain":{playAnim("sustain");}
            case "SustainEnd":{playAnim("end");}
        }

        if(strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)){
            noteStatus = "CanBeHit";
        }

        if(strumTime < Conductor.songPosition - Conductor.safeZoneOffset && noteStatus != "Pressed"){
            noteStatus = "Late";
        }
	}

    override public function loadGraphicNote(newJSON:NoteJSON = null, newTypeNote:String = "Default", newImage:String = "NOTE_assets"){
        if(newJSON != null){chAnim = newJSON.chAnim;}

        super.loadGraphicNote(newJSON, newTypeNote, newImage);
    }

    override public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        this.color = FlxColor.fromHSL(nColor[0], nColor[1], nColor[2]);
	}
}