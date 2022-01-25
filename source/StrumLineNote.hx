package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

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

class StrumLineNote extends FlxTypedGroup<StrumNote> {
    public var curKeys:Int = 4;
    public var noteSize:Int = 110;

    public function new(x:Float, y:Float, keys:Int = 4, typeCheck:String, ?size:Int){
        curKeys = keys;
        if(size != null){noteSize = size;}
        super();
        
        var strumJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumline(keys)));
        
        for(i in 0...keys){
            var strum:StrumNote = new StrumNote(x + (noteSize * i), y, i, strumJSON.image, strumJSON.staticNotes[i]);
            strum.setNoteScale(noteSize);
            strum.playAnim('static');
            add(strum);
        }
    }

    public function animNote(noteId:Int, anim:String){
        this.members[noteId].playAnim(anim, true);
    }

    public function setNoteGraphic(noteId:Int, ?newGraphic:String, ?newJSON:NoteJSON, ?newTypeCheck:String){
        this.members[noteId].loadGraphicStrum(newGraphic, newJSON, newTypeCheck);
    }
}

class StrumNote extends FlxSprite{
	private var noteData:Int = 0;

    public var JSON:NoteJSON;
    public var image:String;

    public var scaleNote:Int;

    public var typeCheck:String = "Default";

	public var animOffsets:Map<String, Array<Dynamic>>;

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
		updateHitbox();

        loadGraphicStrum();

        if(JSON.antialiasing){
            antialiasing = PreSettings.getPreSetting("Antialiasing");
        }else{
            antialiasing = false;
        }
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
        updateHitbox();
		scrollFactor.set();
    }

    public function setNoteScale(scale:Int){
        setGraphicSize(scale * scaleNote);
    }

    override function update(elapsed:Float){
        if(animation.curAnim.name == "confirm" && animation.finished){
            playAnim("static");
        }

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
    public var strumTime:Float = 0;

	public var noteData:Int = 0;
    public var specialData:Int = 0;
	public var otherData:Array<NoteData> = [];

    public var daLenght:Float; //To sustain notes
    public var daStrumTimeArray:Array<Float> = []; //To MultiTap Notes

    //Other Variables
    public var noteStatus:String = "notSpawned"; //status: notSpawned, spawned, canBeHit, Pressed, late

	public function new(noteJSON:NoteJSON, graphic:String, strumTime:Float, noteData:Int, ?specialType:Int = 0, ?otherData:Array<NoteData>){
		super();

	}

	override function update(elapsed:Float){
		super.update(elapsed);

	}
}