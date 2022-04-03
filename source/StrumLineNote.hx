package;

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

    var alpha:Float;
    var scale:Int;
    var antialiasing:Bool;
}

typedef NoteAnimJSON = {
    var anim:String;
    var symbol:String;
    var offsets:Array<Int>;
    var indices:Array<Int>;

    var fps:Int;
    var loop:Bool;
}

typedef NoteData = {
	var type:String;
	var values:Array<Dynamic>;
}

class StrumLine extends FlxGroup{
    public var staticNotes:StrumStaticNotes;
    public var notes:FlxTypedGroup<Note>;

    public var scrollSpeed:Float = 1;
    public var bpm:Float = 150;

    public var typeStrum:String = "BotPlay"; //BotPlay, Playing

    public var strumSize:Float = 110;

    public var JSONSTRUM:StrumLineNoteJSON;
    public var image:String = "NOTE_assets";
    public var noteType:String = "Default";

    public var keys:Int = 0;

    private var back:FlxSprite;

    public function new(x:Float, y:Float, keys:Int, size:Float){
        this.strumSize = size;
        this.keys = keys;
        super();

        back = new FlxSprite(x, y).makeGraphic(Std.int(size), 50, FlxColor.WHITE);
        add(back);

        JSONSTRUM = cast Json.parse(Assets.getText(Paths.strumJSON(keys)));

        staticNotes = new StrumStaticNotes(x, y, keys, Std.int(size / keys));
        add(staticNotes);

        notes = new FlxTypedGroup<Note>();
        add(notes);
    }

    public function changeGraphic(newImage:String, newType:String){
        if(image != newImage){image = newImage;}
        if(noteType != newType){noteType = newType;}

        changeKeyNumber(keys, strumSize, true);
    }

    public function changeKeyNumber(keys:Int, size:Float, ?force:Bool = false){
        this.strumSize = size;
        this.keys = keys;

        back.makeGraphic(Std.int(size), 50, FlxColor.WHITE);

        JSONSTRUM = cast Json.parse(Assets.getText(Paths.strumJSON(keys)));
        
        staticNotes.noteSize = Std.int(size / keys);
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
                    var swagNote:Note = new Note(JSONSTRUM.gameplayNotes[daNoteData], daStrumTime, daNoteData, daLength, daHits, daSpecialData, daOtherData);
                    swagNote.setGraphicSize(staticNotes.noteSize, staticNotes.noteSize);
                    swagNote.updateHitbox();
                    notes.add(swagNote);

                    if(daLength > 0 && daHits == 0){
                        var cSusNote = Math.floor(daLength / (Conductor.stepCrochet * 0.25)) + 2;
                        for(sNote in 0...Math.floor(daLength / (Conductor.stepCrochet * 0.25)) + 2){
                            var sStrumTime = daStrumTime + (Conductor.stepCrochet / 2) + ((Conductor.stepCrochet * 0.25) * sNote);

                            var nSustain:Note = new Note(JSONSTRUM.gameplayNotes[daNoteData], sStrumTime, daNoteData, daLength, daHits, daSpecialData, daOtherData);

                            if(cSusNote > 1){nSustain.typeNote = "Sustain";}
                            else{nSustain.typeNote = "SustainEnd";}

                            var nHeight:Int = Std.int(getScrollSpeed() * staticNotes.noteSize / (bpm * 2.3 / 150));
                            nSustain.setGraphicSize(staticNotes.noteSize, nHeight);
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
                    daNote.x = staticNotes.members[daNote.noteData].x + daNote.width;
                    daNote.alpha = staticNotes.members[daNote.noteData].alpha / 2;
                }else{
                    daNote.x = staticNotes.members[daNote.noteData].x;
                    daNote.angle = staticNotes.members[daNote.noteData].angle;
                    daNote.alpha = staticNotes.members[daNote.noteData].alpha;
                }   
            }else{
                daNote.visible = false;
            }

            if(daNote.noteStatus == "Pressed"){
                if(pre_TypeStrums == "All" || pre_TypeStrums == "OnlyOtherStrums"){
                    staticNotes.animNote(daNote.noteData, "confirm");
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
                        staticNotes.animNote(daNote.noteData, "confirm");
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
                        staticNotes.animNote(daNote.noteData, "confirm");
                    }
    
                    daNote.noteStatus = "Pressed";
                }
            });
        }else if(typeStrum == "Charting"){
            notes.forEachAlive(function(daNote:Note){
                if(daNote.noteStatus == "CanBeHit"){
                    staticNotes.animNote(daNote.noteData, "confirm");
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

    public var curKeys:Int = 4;
    public var noteSize:Int = 110;

    public var JSON:Array<NoteJSON>;

    public function new(x:Float, y:Float, keys:Int = 4, ?size:Int){
        this.x = x;
        this.y = y;
        if(size != null){noteSize = size;}
        super();
        
        changeKeys(curKeys, true);
    }

    public function animNote(noteId:Int, anim:String){
        this.members[noteId].playAnim(anim, true);
    }

    public function setNoteGraphic(noteId:Int, specialId:Int = 0, ?newJSON:NoteJSON, ?newTypeCheck:String){
        var curJSON:NoteJSON = newJSON;
        if(curJSON == null){curJSON = JSON[noteId];}

        var curType:String = newTypeCheck;

        this.members[noteId].loadGraphicNote(curJSON, curType);
    }

    public function changeKeys(keys:Int, ?force:Bool = false){
        if(curKeys != keys || force){
            curKeys = keys;
            
            var newJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumJSON(curKeys)));
            JSON = newJSON.staticNotes;
    
            if(this.members.length > 0){
                for(i in 0...this.members.length){
                    var strum = this.members[i];

                    FlxTween.tween(strum, {alpha: 0, y: strum.y + (strum.height / 2)}, (0.5 * (i + 1) / this.members.length), {
                        ease: FlxEase.quadInOut,
                        onComplete: function(twn:FlxTween){
                            this.members.remove(strum);
                        }
                    });
                }
            }
            
            for(i in 0...curKeys){
                var strum:StrumNote = new StrumNote(JSON[i]);
                strum.setPosition(this.x + (noteSize * i), y - (noteSize / 2));
                strum.ID = i;
                strum.alpha = 0;
                strum.setGraphicSize(noteSize);
                add(strum);

                FlxTween.tween(strum, {alpha: 1, y: y}, (0.5 * (i + 1) / curKeys), {ease: FlxEase.quadInOut});
            }
        }
    }
}

class StrumNote extends FlxSprite{
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var nColor:Array<Int> = [0xffffff, 1, 1];

	public function new(JSON:NoteJSON, ?typeImage:String = "NOTE_assets", ?newTypeNote:String = "Default"){
        super();

        #if (haxe >= "4.0.0")
		    animOffsets = new Map();
		#else
		    animOffsets = new Map<String, Array<Dynamic>>();
		#end

        alpha = JSON.alpha;

        loadGraphicNote(JSON, typeImage, newTypeNote);

        if(JSON.antialiasing){
            antialiasing = PreSettings.getPreSetting("Antialiasing");
        }else{
            antialiasing = false;
        }

        playAnim("static");
	}

    public function loadGraphicNote(newJSON:NoteJSON, ?newImage:String = "NOTE_assets", ?newTypeNote:String = "Default"){
        animOffsets.clear();

        frames = Paths.getNoteAtlas(newImage, newTypeNote);

        var anims = newJSON.arrayAnims;
        for(anim in anims){
            if(anim.indices != null && anim.indices.length > 0){
                animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
            }else{
                animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
            }

            if(anim.offsets != null && anim.offsets.length > 1){
                animOffsets[anim.anim] = [anim.offsets[0], anim.offsets[1]];
                trace("Offsetting: " + anim.offsets[0] + ", " + anim.offsets[1]);
            }
        }
        
        if(newJSON.colorHSL != null){nColor = newJSON.colorHSL;}
    }

    override function update(elapsed:Float){
		super.update(elapsed);
	}

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        updateHitbox();

        var daOffset = animOffsets.get(anim);
        if(animOffsets.exists(anim)){
            offset.set(daOffset[0], daOffset[1]);
        }else{
            offset.set(0, 0);
        }

        trace(daOffset[0], daOffset[1]);

        if(anim != "static"){
            this.color = FlxColor.fromHSL(nColor[0], nColor[1], nColor[2]);
        }else{
            this.color = 0xffffff;
        }
	}

    override public function setGraphicSize(Width:Int = 0, Height:Int = 0) {
        super.setGraphicSize(Width, Height);

        updateHitbox();
    }
}

class Note extends StrumNote {
    //General Variables
    public var strumTime:Float = 1;

    public var noteLength:Float = 0;
    public var noteHits:Int = 0; // Determinate if MultiTap o Sustain

    public var typeNote:String = "Normal"; // CurNormal Types

	public var noteData:Int = 0;
    public var specialData:Int = 0;
	public var otherData:Array<NoteData> = [];

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap

    //Debug Variables
    public var onEdit:Bool = false;

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

	public function new(newJSON:NoteJSON, strumTime:Float, noteData:Int, ?noteLength:Float = 0, ?noteHits:Int = 0, ?specialType:Int = 0, ?otherData:Array<NoteData>){
        this.strumTime = strumTime;
		this.noteData = noteData;
        this.noteLength = noteLength;
        this.noteHits = noteHits;
        this.specialData = specialType;
        this.otherData = otherData;
        super(newJSON);

        #if (haxe >= "4.0.0")
		    animOffsets = new Map();
		#else
		    animOffsets = new Map<String, Array<Dynamic>>();
		#end

        loadGraphicNote(newJSON);
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
}