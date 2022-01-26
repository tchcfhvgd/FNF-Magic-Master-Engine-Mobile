package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.math.FlxMath;

import flixel.group.FlxGroup;

import Section.SwagSection;

using StringTools;

typedef StrumLineNoteJSON = {
    var image:String;
    var staticNotes:Array<NoteJSON>;
    var gameplayNotes:Array<NoteJSON>;
    var noteSplash:String;
}

typedef NoteJSON = {
    var colorHUE:Array<Float>;
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
    var staticNotes:StrumStaticNotes;
    var notes:FlxTypedGroup<Note>;

    public var scrollSpeed:Float = 1;

    public var playing:Bool = false;

    public var strumSize:Float = 110;

    public var JSONSTRUM:StrumLineNoteJSON;
    public var noteStyle:String = "Default";
    public var keys:Int = 0;

    public function new(x:Float, y:Float, keys:Int, size:Float, noteStyle:String, ?isPlayer:Bool = false){
        strumSize = size;
        playing = isPlayer;
        this.noteStyle = noteStyle;
        this.keys = keys;
        super();

        JSONSTRUM = cast Json.parse(Assets.getText(Paths.strumline(keys)));

        staticNotes = new StrumStaticNotes(x, y, keys, noteStyle, Std.int(size / keys));
        add(staticNotes);

        notes = new FlxTypedGroup<Note>();
        add(notes);
    }

    public function changeStaticKeyNumber(keys:Int, size:Float, ?force:Bool = false){
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
                    var swagNote:Note = new Note(JSONSTRUM.gameplayNotes[daNoteData], noteStyle, daStrumTime, daNoteData, daLength, daHits, daSpecialData, daOtherData);
                    notes.add(swagNote);
                }
            }
        }
    }

    override function update(elapsed:Float){
        if(!playing){
            staticNotes.forEach(function(staticStrum:StrumNote){
                if(staticStrum.animation.curAnim.name == "confirm" && staticStrum.animation.finished){
                    staticStrum.playAnim("static");
                }
        
            });
        }        

		super.update(elapsed);

        notes.forEachAlive(function(daNote:Note){
            var pre_TypeScrollSpeed:String = PreSettings.getArraySetting(PreSettings.getPreSetting("ScrollSpeedType"));
            var pre_TypeScroll:String = PreSettings.getArraySetting(PreSettings.getPreSetting("TypeScroll"));
            var pre_ScrollSpeed:Float = PreSettings.getPreSetting("ScrollSpeed");
            
            if(daNote.noteStatus == "late"){
                daNote.active = false;
                daNote.visible = false;
            }else{
                daNote.visible = true;
                daNote.active = true;
            }

            var curScrollspeed:Float = 1;
            switch(pre_TypeScrollSpeed){
                case "Scale":{curScrollspeed = scrollSpeed * pre_ScrollSpeed;}
                case "Force":{curScrollspeed = pre_ScrollSpeed;}
                case "Disabled":{curScrollspeed = scrollSpeed;}
            }

            daNote.setNoteSize(staticNotes.noteSize);
            var ySuff:Float = 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(curScrollspeed, 2);
            if(staticNotes.members[daNote.noteData].exists){
                if(pre_TypeScroll == "DownScroll"){
                    daNote.y = (staticNotes.members[daNote.noteData].y + ySuff);
                }else if(pre_TypeScroll == "UpScroll"){
                    daNote.y = (staticNotes.members[daNote.noteData].y - ySuff);
                }

                daNote.visible = staticNotes.members[daNote.noteData].visible;
                daNote.x = staticNotes.members[daNote.noteData].x;
                daNote.angle = staticNotes.members[daNote.noteData].angle;
                daNote.alpha = staticNotes.members[daNote.noteData].alpha;
            }else{
                daNote.visible = false;
            }

            if(!playing && daNote.noteStatus == "canBeHit"){
                daNote.noteStatus = "Pressed";
            }

            if(daNote.noteStatus == "Pressed"){
                staticNotes.animNote(daNote.noteData, "confirm");

                if(daNote.noteHits > 0 && daNote.noteLength > 20){
                    daNote.noteStatus = "MultiTap";
                    daNote.strumTime += daNote.noteLength;
                    daNote.noteHits--;
                }else{
                    daNote.active = false;

                    daNote.kill();
                    notes.remove(daNote, true);
                    daNote.destroy();
                }
            }
        });
	}
}

class StrumStaticNotes extends FlxTypedGroup<StrumNote> {
    public var x:Float = 0;
    public var y:Float = 0;

    public var curKeys:Int = 4;
    public var noteSize:Int = 110;

    public function new(x:Float, y:Float, keys:Int = 4, typeCheck:String, ?size:Int){
        this.x = x;
        this.y = y;
        if(size != null){noteSize = size;}
        super();
        
        changeKeys(curKeys, true);
    }

    public function animNote(noteId:Int, anim:String){
        this.members[noteId].playAnim(anim, true);
    }

    public function setNoteGraphic(noteId:Int, ?newGraphic:String, ?newJSON:NoteJSON, ?newTypeCheck:String){
        this.members[noteId].loadGraphicStrum(newGraphic, newJSON, newTypeCheck);
    }

    public function changeKeys(keys:Int, ?force:Bool = false){
        if(curKeys != keys || force){
            curKeys = keys;

            var strumJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumline(curKeys)));
    
            if(this.members.length > 0){
                for(strum in this.members){
                    FlxTween.tween(strum, {alpha: 0, y: strum.y + (strum.height / 2)}, (0.5 * (strum.noteData + 1) / this.members.length), {
                        ease: FlxEase.quadInOut,
                        onComplete: function(twn:FlxTween){
                            this.members.remove(strum);
                        }
                    });
                }
            }
            
            for(i in 0...curKeys){
                var strum:StrumNote = new StrumNote(x + (i * noteSize), y - (noteSize / 2), i, strumJSON.image, strumJSON.staticNotes[i]);
                strum.alpha = 0;
                strum.setNoteScale(noteSize);
                add(strum);
    
                FlxTween.tween(strum, {alpha: strum.JSON.alpha, y: y}, (0.5 * (strum.noteData + 1) / curKeys), {ease: FlxEase.quadInOut});
            }
        }
    }
}

class StrumNote extends FlxSprite{
	public var noteData:Int = 0;

    public var animOffsets:Map<String, Array<Dynamic>>;
    public var JSON:NoteJSON;
    public var image:String;

    public var scaleNote:Int;

    public var typeCheck:String = "Default";

	public function new(x:Float, y:Float, leData:Int, image:String, JSON:NoteJSON, ?typeCheck = "Default"){
		noteData = leData;
        this.image = image;
        this.JSON = JSON;
        this.typeCheck = typeCheck;
        super(x, y);

        #if (haxe >= "4.0.0")
		    animOffsets = new Map();
		#else
		    animOffsets = new Map<String, Array<Dynamic>>();
		#end

        alpha = JSON.alpha;

		scaleNote = JSON.scale;

        loadGraphicStrum();

        if(JSON.antialiasing){
            antialiasing = PreSettings.getPreSetting("Antialiasing");
        }else{
            antialiasing = false;
        }

        playAnim('static');
	}

    public function loadGraphicStrum(?newGraphic:String, ?newJSON:NoteJSON, ?newTypeCheck:String){
        var curImage:String = newGraphic;
        if(curImage == null){curImage = image;}

        var curJSON:NoteJSON = newJSON;
        if(curJSON == null){curJSON = JSON;}

        var curTypeCheck:String = newTypeCheck;
        if(curTypeCheck == null){curTypeCheck = typeCheck;}

        animOffsets.clear();

        frames = Paths.getNoteAtlas(curImage, curTypeCheck);

        var anims = curJSON.arrayAnims;
        for(anim in anims){
            if(anim.indices != null && anim.indices.length > 0){
                animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
            }else{
                animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
            }

            if(anim.offsets != null && anim.offsets.length > 1){
                animOffsets[anim.anim] = [anim.offsets[0], anim.offsets[1]];
            }
        }
    }

    public function setNoteScale(scale:Int){
        setGraphicSize(scale * scaleNote);
    }

    override function update(elapsed:Float){
		super.update(elapsed);
	}

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        var daOffset = animOffsets.get(anim);
        if(animOffsets.exists(anim)){
            offset.set(daOffset[0], daOffset[1]);
        }else{
            offset.set(0, 0);
        }
	}
}

class Note extends FlxSprite {
    //General Variables
    public var strumTime:Float = 1;

    public var noteLength:Float = 0;
    public var noteHits:Float = 0;// Determinate if MultiTap o Sustain

	public var noteData:Int = 0;
    public var specialData:Int = 0;
	public var otherData:Array<NoteData> = [];

    //Image Variables
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var JSON:NoteJSON;
    public var image:String = "NOTE_assets";
    public var typeCheck:String;

    public var scaleNote:Int;

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap

	public function new(noteJSON:NoteJSON, typeCheck:String, strumTime:Float, noteData:Int, noteLength:Float, noteHits:Int, ?specialType:Int = 0, ?otherData:Array<NoteData>){
        this.strumTime = strumTime;
		this.noteData = noteData;
        this.noteLength = noteLength;
        this.noteHits = noteHits;
        this.JSON = noteJSON;
        this.typeCheck = typeCheck;
        super();

        #if (haxe >= "4.0.0")
		    animOffsets = new Map();
		#else
		    animOffsets = new Map<String, Array<Dynamic>>();
		#end

        alpha = JSON.alpha;

		scaleNote = JSON.scale;

        loadGraphicNote();


        if(JSON.antialiasing){
            antialiasing = PreSettings.getPreSetting("Antialiasing");
        }else{
            antialiasing = false;
        }
        
        playAnim('static');
	}

    public function loadGraphicNote(?newGraphic:String, ?newJSON:NoteJSON, ?newTypeCheck:String){
        var curImage:String = newGraphic;
        if(curImage == null){curImage = image;}

        var curJSON:NoteJSON = newJSON;
        if(curJSON == null){curJSON = JSON;}

        var curTypeCheck:String = newTypeCheck;
        if(curTypeCheck == null){curTypeCheck = typeCheck;}

        animOffsets.clear();

        frames = Paths.getNoteAtlas(curImage, curTypeCheck);

        var anims = curJSON.arrayAnims;
        for(anim in anims){
            if(anim.indices != null && anim.indices.length > 0){
                animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
            }else{
                animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
            }

            if(anim.offsets != null && anim.offsets.length > 1){
                animOffsets[anim.anim] = [anim.offsets[0], anim.offsets[1]];
            }
        }
    }

	public function setNoteSize(size:Int){
        setGraphicSize(size * scaleNote);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(strumTime <= Conductor.songPosition){
            noteStatus = "canBeHit";
        }
	}

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        var daOffset = animOffsets.get(anim);
        if(animOffsets.exists(anim)){
            offset.set(daOffset[0], daOffset[1]);
        }else{
            offset.set(0, 0);
        }
	}
}