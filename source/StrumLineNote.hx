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
    var staticNotes:Array<StaticNoteJSON>;
    var gameplayNotes:Array<NoteAnimJSON>;
    var noteSplash:String;
}

typedef StaticNoteJSON = {
    var colorHUE:Array<Float>;
    var arrayAnims:Array<NoteAnimJSON>;

    var alpha:Float;
    var scale:Float;
    var antialiasing:Bool;
}

typedef NoteJSON = {
    var colorHUE:Array<Float>;
    var noteAnim:NoteAnimJSON;
    
    var alpha:Float;
    var scale:Float;
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
    public var noteSize:Int = 40;

    public function new(x:Float, y:Float, keys:Int = 4, typeCheck:String, size:Int = 40){
        curKeys = keys;
        noteSize = size;
        super();
        
        var strumJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumline(keys)));
        
        for(i in 0...keys){
            var strum:StrumNote = new StrumNote(x + (noteSize * i), y, i, strumJSON.image, strumJSON.staticNotes[i]);
            add(strum);
        }
    }

    public function animNote(noteId:Int, anim:String){
        this.members[noteId].playAnim(anim, true);
    }

    public function setNoteGraphic(noteId:Int, ?newGraphic:String, ?newJSON:StaticNoteJSON, ?newTypeCheck:String){
        this.members[noteId].loadGraphicStrum(newGraphic, newJSON, newTypeCheck);
    }
}

class StrumNote extends FlxSprite{
	private var noteData:Int = 0;

    public var JSON:StaticNoteJSON;
    public var image:String;

    public var typeCheck:String = "Default";

	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float, y:Float, leData:Int, image:String, JSON:StaticNoteJSON, ?typeCheck = "Default"){
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

		setGraphicSize(Std.int(width * JSON.scale));
		updateHitbox();

        loadGraphicStrum();

        if(JSON.antialiasing){
            antialiasing = PreSettings.getPreSetting("Antialiasing");
        }else{
            antialiasing = false;
        }
	}

    public function loadGraphicStrum(?newGraphic:String, ?newJSON:StaticNoteJSON, ?newTypeCheck:String){
        var curImage:String = newGraphic;
        if(curImage == null){curImage = image;}

        var curJSON:StaticNoteJSON = newJSON;
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

    override function update(elapsed:Float) {
        if(animation.finished && animation.curAnim.name == 'confirm'){playAnim("static");}

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
	public var strumTime:Float = 0;

	public var noteData:Int = 0;
	public var typeData:String = "Default";
    public var specialData:Int = 0;
	public var otherData:Array<NoteData> = [];

    //TypeDataVariables
    public var daLenght:Float;
    

    //status: notSpawned, spawned, canBeHit, Pressed, late
    public var noteStatus:String = "notSpawned";
	
	public var strumToPlay:Int = 0;

	public function new(noteJSON:NoteJSON, graphic:String, strumTime:Float, noteData:Int, noteType:String, ?specialNote:Int = 0, ?otherData:Array<NoteData>){
		super();

	}

	override function update(elapsed:Float){
		super.update(elapsed);

	}
}