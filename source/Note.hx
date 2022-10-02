package;

import states.MusicBeatState;
import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxShader;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import haxe.Json;

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

typedef Note_Graphic_Data = {
    var animations:Array<Note_Animation_Data>;
    var antialiasing:Bool;
    var sing_animation:String;
    var color:String;
}

typedef Note_Animation_Data = {
    var anim:String;
    var symbol:String;
    var indices:Array<Int>;

    var fps:Int;
    var loop:Bool;
}

class StrumNote extends FlxSprite{
    public static var IMAGE_DEFAULT:String = "NOTE_assets";
    public static var STYLE_DEFAULT:String = "Default";

    public static var TYPE_DEFAULT(get, never):String;
	inline static function get_TYPE_DEFAULT():String {return PreSettings.getPreSetting("Note Skin", "Visual Settings");}

    public var splashImage:String = NoteSplash.IMAGE_DEFAULT;
    public var image:String = IMAGE_DEFAULT;
    public var style:String = STYLE_DEFAULT;
    public var type:String = TYPE_DEFAULT;

    public var noteData:Int = 0;
    public var noteKeys:Int = 4;
    
    public var lockColor:Bool = false;
    public var playColor:String;

    public var singAnimation:String = null;

    public var onDebug:Bool = false;
    public var autoStatic:Bool = false;

	public function new(_data:Int = 0, _keys:Int = 4, ?_image:String, ?_style:String, ?_type:String){
        if(_image != null){image = _image;}
        if(_style != null){style = _style;}
        if(_type != null){type = _type;}
        this.noteData = _data;
        this.noteKeys = _keys;
        super();

        loadNote();
	}

    public function setupData(_data:Int, ?_keys:Int){
        if(_keys != null){noteKeys = _keys;}
        noteData = _data;
        loadNote();
    }

    public function loadNote(?_image:String, ?_style:String, ?_type:String){
        var sAnim:String = this.animation != null && this.animation.curAnim != null ? this.animation.curAnim.name : "static";
        if(_image != null){image = _image;} if(_style != null){style = _style;} if(_type != null){type = _type;}

        frames = Paths.getAtlas(Paths.note(image, style, type));
        var getJSON:Note_Graphic_Data = Paths.strum_json(noteData, noteKeys, type);
        if((this is Note)){getJSON = Paths.note_json(noteData, noteKeys, type);}
        
        if(!lockColor){playColor = getJSON.color != null ? getJSON.color : "0xffffff";}        
        antialiasing = getJSON.antialiasing && PreSettings.getPreSetting("Antialiasing", "Graphic Settings") && !style.contains("pxl-");
        singAnimation = getJSON.sing_animation;

        if(frames == null || getJSON.animations == null || getJSON.animations.length <= 0){return;}

        animation.addByPrefix("SizeBase", "SizeBase");
        for(anim in getJSON.animations){
            if(anim.indices != null && anim.indices.length > 0){animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);}
            else{animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);}
        }

        shader = new ColorFilterShader(Paths.colorNote(Paths.note(image, style, type)), FlxColor.fromString(playColor));
        
        playAnim(sAnim);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if((shader is ColorFilterShader)){(cast (shader, ColorFilterShader)).setAlpha(alpha);}

        if(animation != null && animation.finished && animation.curAnim.name != "static" && autoStatic){playAnim('static');}
	}

    public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);
	}

    override function setGraphicSize(Width:Int = 0, Height:Int = 0):Void {
        var sAnim:String = this.animation != null && this.animation.curAnim != null ? this.animation.curAnim.name : "static";
        playAnim("SizeBase");
        super.setGraphicSize(Width, Height);
        playAnim(sAnim);
        updateHitbox();
    }
    
    public function summonSplash(splash:NoteSplash){
        splash.playColor = this.playColor;
        splash.setup(this.x, this.y, splashImage, style, type);
        splash.setGraphicSize(Std.int(this.width), Std.int(this.height));
        return splash;
    }
}

typedef NoteData = {
    var strumTime:Float;
    var keyData:Int;
    var sustainLength:Float;
    var multiHits:Int;
    var canMerge:Bool;
    var presset:String;
    var eventData:Array<Dynamic>;
    var otherStuff:Array<Dynamic>;
}
typedef EventData = {
    var strumTime:Float;
    var eventData:Array<Dynamic>;
    var condition:String;
}

class Note extends StrumNote {
    //Static Methods
    public static function compNotes(n1:Dynamic, n2:Dynamic, checkData:Bool = true, specific:Bool = false):Bool {
        if((n1 != null && n2 != null) && (((n1.strumTime >= n2.strumTime - 5 && n1.strumTime <= n2.strumTime + 5) && (!checkData || (checkData && (n1.keyData == n2.keyData)))) || (specific && (n1 == n2)))){return true;}
        return false;
    }

    public static function getNoteStyles(?type:String):Array<String> {
        if(type == null){type = PreSettings.getPreSetting("Note Skin", "Visual Settings");}

        var toReturn:Array<String> = [];
        for(i in Paths.readDirectory('assets/notes/$type')){
            var curFile:String = i;
            if(!curFile.contains(".")){toReturn.push(curFile);}
        }

        return toReturn;
    }
    public static function getNotePressets():Array<String> {
        var toReturn:Array<String> = ["Default"];
        for(i in Paths.readDirectory('assets/notes')){
            var curFile:String = i;
            if(curFile.endsWith(".json")){toReturn.push(curFile.replace(".json", ""));}
        }

        return toReturn;
    }
    public static function getNoteEvents(isNote:Bool = false, ?stage:String):Array<String> {
        var toReturn:Array<String> = [];

        for(i in Paths.readDirectory('assets/data/events')){
            var curEvent:String = i;
            if(curEvent.endsWith(".hx")){toReturn.push(curEvent.replace(".hx", ""));}
        }
        
        if(isNote){
            for(i in Paths.readDirectory('assets/data/note_events')){
                var curEvent:String = i;
                if(curEvent.endsWith(".hx")){toReturn.push(curEvent.replace(".hx", ""));}
            }
        }

        if(stage != null){
            for(i in Paths.readDirectory('assets/stages/${stage}/events')){
                var curEvent:String = i;
                if(curEvent.endsWith(".hx")){toReturn.push(curEvent.replace(".hx", ""));}
            }
        }        

        return toReturn;
    }

    public static function convNoteData(data:NoteData):Array<Dynamic> {if(data == null){return null;} return [data.strumTime, data.keyData, data.sustainLength, data.multiHits, data.canMerge, data.presset, data.eventData, data.otherStuff];}
    public static function convEventData(data:EventData):Array<Dynamic> {if(data == null){return null;} return [data.strumTime, data.eventData, data.condition];}
    
    public static function getNoteData(?note:Array<Dynamic>):NoteData {
        var toReturn:NoteData = {
            strumTime: 0,
            keyData: 0,
            sustainLength: 0,
            multiHits: 0,
            canMerge: false,
            presset: "Default",
            eventData: [],
            otherStuff: []
        }

        if(note == null){return toReturn;}
        note.resize(8);

        if(note[0] != null && Std.isOfType(note[0], Float)){toReturn.strumTime = note[0];}
        if(note[1] != null && Std.isOfType(note[1], Int)){toReturn.keyData = note[1];}    
        if(note[2] != null && Std.isOfType(note[2], Float)){toReturn.sustainLength = note[2];}      
        if(note[3] != null && Std.isOfType(note[3], Int)){toReturn.multiHits = note[3];}
        if(note[4]){toReturn.canMerge = true;}
        if(note[5] != null && Std.isOfType(note[5], String)){toReturn.presset = note[5];}
        if(note[6] != null && Std.isOfType(note[6], Array)){toReturn.eventData = note[6];}
        if(note[7] != null && Std.isOfType(note[7], Array)){toReturn.otherStuff = note[7];}
        
        return toReturn;
    }

    public static function getEventData(?event:Array<Dynamic>):EventData {
        var toReturn:EventData = {
            strumTime: 0,
            eventData: [],
            condition: "OnHit"
        }

        if(event == null){return toReturn;}

        if(event[0] != null && Std.isOfType(event[0], Float)){toReturn.strumTime = event[0];}
        if(event[1] != null && Std.isOfType(event[1], Array)){toReturn.eventData = event[1];}
        if(event[2] != null && Std.isOfType(event[2], String)){toReturn.condition = event[2];}

        return toReturn;
    }
    
    //General Variables
    public var nextNote:Note = null;

    public var strumTime:Float = 0;
    //public var noteData:Int = 0; //Now on StrumNote
    public var noteLength:Float = 0;
    public var noteHits:Int = 0; // Determinate if MultiTap o Sustain

    public var typeNote:String = "Normal"; // [Normal, Sustain, Merge] CurNormal Types
    public var typeHit:String = "Press"; // [Press | Normal Hits] [Hold | Hold Hits] [Release | Release Hits] [Always | Just Hit] [Ghost | Just Hit Withowt Strum Anim] [None | Can't Hit]
    public var hitMiss:Bool = false;
    public var ignoreMiss:Bool = false;

	public var otherData:Array<Dynamic> = [];

    //Other Variables
    public var noteStatus:String = "Spawned"; //status: Spawned, CanBeHit, Pressed, Late, MultiTap
    public var hitHealth:Float = 0.023;
    public var missHealth:Float = 0.0475;

    public var singCharacters:Array<Int> = null;
    
	public function new(data:NoteData, noteKeys:Int, ?_image:String, ?_style:String, ?_type:String){
        this.strumTime = data.strumTime;
        this.noteLength = data.sustainLength;
        this.noteHits = data.multiHits;
        if(data.eventData != null){this.otherData = data.eventData;}

        super(data.keyData, noteKeys, _image, _style, _type);

        loadPresset(data.presset);
	}

    public function loadPresset(presset:String, onCreate:Bool = true):Void {
        if(!onCreate && presset == "Default"){otherData = []; loadNote(StrumNote.IMAGE_DEFAULT); return;}

        if(presset != "" && Paths.exists(Paths.notePresset(presset))){
            var eventList:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText(Paths.notePresset(presset)));
            otherData = eventList.get("Events");
        }
        
        for(i in this.otherData){MusicBeatState.state.pushTempScript(i[0], i[1]);}

        for(event in otherData){
            if(event[2] != "OnCreate"){continue;} var curScript:Script = Script.getScript(event[0]);
            curScript.setVariable("_note", this); curScript.exFunction("execute", event[1]);
        }
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        switch(this.typeNote){
            case "Normal":{playAnim("static");}
            case "Sustain":{
                if(this.nextNote != null){playAnim("sustain");}
                else{playAnim("end");}
            }
            case "Switch":{playAnim("sustain"); angle = 270;}
            case "Merge":{playAnim("merge");}
        }
	}
}

class StrumEvent extends StrumNote {
    public var conductor:Conductor = null;
    public var strumTime:Float = 0;

    public function new(_strumtime:Float, _conductor:Conductor = null){
        this.strumTime = _strumtime;
        this.conductor = _conductor;
        super(-1, 4, "EventIcon");
        playAnim("BeEvent");
	}

    override public function loadNote(?_image:String, ?_style:String, ?_type:String){
        var sAnim:String = this.animation != null && this.animation.curAnim != null ? this.animation.curAnim.name : "static";
        if(_image != null){image = _image;} if(_style != null){style = _style;} if(_type != null){type = _type;}

        frames = Paths.getAtlas(Paths.note(image, style, type));
            
        antialiasing = PreSettings.getPreSetting("Antialiasing", "Graphic Settings") && !style.contains("pxl-");
        if(frames == null){return;}

        animation.addByPrefix("SizeBase", "SizeBase");
        animation.addByIndices("BeEvent", "Event", [0], "", 0, false, false, false);
        animation.addByIndices("AfEvent", "Event", [1], "", 0, false, false, false);
        
        playAnim(sAnim);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(conductor != null && strumTime < conductor.songPosition){playAnim("AfEvent");}else{playAnim("BeEvent");}
	}
}

class NoteSplash extends FlxSprite {
    public static var IMAGE_DEFAULT:String = "NOTE_splash_comic";

    public var onSplashed:Void->Void = function(){};

    public var playColor:String = "0xffffff";

    public function new(){
        super();
        setup();
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(animation.finished){onSplashed();}
	}

    public function setup(X:Float = 0, Y:Float = 0, ?image:String, ?style:String, ?type:String){
        if(image == null){image = IMAGE_DEFAULT;}
        if(style == null){style = StrumNote.STYLE_DEFAULT;}
        if(type == null){type = StrumNote.TYPE_DEFAULT;}

        this.setPosition(X, Y);

        frames = Paths.getAtlas(Paths.note(image, style, type));
        animation.addByPrefix("SizeBase", "SizeBase");
        animation.addByPrefix("Splash", "Splash", 30, false);

        playAnim("Splash");
    }

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);

        updateHitbox();
	}

    override function setGraphicSize(Width:Int = 0, Height:Int = 0):Void {
        var sAnim:String = this.animation != null && this.animation.curAnim != null ? this.animation.curAnim.name : "static";
        playAnim("SizeBase");
        super.setGraphicSize(Width, Height);
        playAnim(sAnim);
    }
}

class ColorFilterShader extends FlxShader {
    #if openfl
    @:glFragmentSource('
		#pragma header
            uniform float cjk_alpha;
		    uniform int checkColor;
		    uniform vec3 replaceColor;
		    uniform bool active;

		    /**
		    * Helper method that normalizes an RGB value (in the 0-255 range) to a value between 0-1.
		    */
		    vec3 normalizeColor(vec3 color){return vec3(color[0] / 255.0, color[1] / 255.0, color[2] / 255.0);}

		   void main(){
			    vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);

			    if(!active){gl_FragColor = pixel; return;}

                vec3 normRepColor = normalizeColor(replaceColor);

                switch(checkColor){
                    default:{gl_FragColor = vec4(pixel.r, pixel.g, pixel.b, pixel.a * cjk_alpha); return;}
                    case 0:{
                        float diff = pixel.r - ((pixel.b + pixel.g) / 2.0);
                        gl_FragColor = vec4((((pixel.b + pixel.g) / 2.0) + (normRepColor.r * diff)) * cjk_alpha, (pixel.g + (normRepColor.g * diff)) * cjk_alpha, (pixel.b + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                        return;
                    }
                    case 1:{
                        float diff = pixel.g - ((pixel.r + pixel.b) / 2.0);
                        gl_FragColor = vec4((pixel.r + (normRepColor.r * diff)) * cjk_alpha, (((pixel.r + pixel.b) / 2.0) + (normRepColor.g * diff)) * cjk_alpha, (pixel.b + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                        return;
                    }
                    case 2:{
                        float diff = pixel.b - ((pixel.r + pixel.g) / 2.0);
                        gl_FragColor = vec4((pixel.r + (normRepColor.r * diff)) * cjk_alpha, (pixel.g + (normRepColor.g * diff)) * cjk_alpha, (((pixel.r + pixel.g) / 2.0) + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                        return;
                    }
                }
		    }
    ')
    #end

    public function new(checkColor:String = "None", replaceColor:FlxColor = FlxColor.GREEN){
        super();

        setReplaceColor(replaceColor);
        setCheckColor(checkColor);

        this.active.value = [true];
        this.cjk_alpha.value = [1];
    }

    public function setReplaceColor(color:FlxColor):Void {this.replaceColor.value = [color.red, color.green, color.blue];}
    public function setCheckColor(checkColor:String):Void {
        switch(checkColor){
            default:{this.checkColor.value = [-1];}
            case "Red":{this.checkColor.value = [0];}
            case "Green":{this.checkColor.value = [1];}
            case "Blue":{this.checkColor.value = [2];}
        }
    }
    public function setAlpha(value:Float = 1){this.cjk_alpha.value = [value];}
}