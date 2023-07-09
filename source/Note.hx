package;

import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxShader;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import states.MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;

import Song.SwagSection;
import Song.SwagStrum;
import Script;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;
using SavedFiles;

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

    public var note_size:FlxPoint = new FlxPoint(60, 60);

    public var note_path:String = "";

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

        note_path = Paths.note(image, style, type);
        frames = note_path.getAtlas();
        var getJSON:Note_Graphic_Data = SavedFiles.getDataStaticNote(noteData, noteKeys, type);
        if((this is Note)){getJSON = SavedFiles.getDataNote(noteData, noteKeys, type);}
        
        if(!lockColor){playColor = getJSON.color != null ? getJSON.color : "0xffffff";}        
        antialiasing = getJSON.antialiasing && !style.contains("pxl-");
        singAnimation = getJSON.sing_animation;

        if(frames == null || getJSON.animations == null || getJSON.animations.length <= 0){return;}

        for(anim in getJSON.animations){
            if(anim.indices != null && anim.indices.length > 0){animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);}
            else{animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);}
        }

        shader = ColorFilterShader.getColorShader(note_path.getColorNote(), FlxColor.fromString(playColor));
        
        playAnim(sAnim);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if((shader is ColorFilterShader)){(cast (shader, ColorFilterShader)).setAlpha(alpha);}

        if(animation != null && animation.curAnim != null && animation.finished && animation.curAnim.name != "static" && autoStatic){playAnim('static');}
	}

    public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);
        setGraphicSize(Std.int(note_size.x), Std.int(note_size.y));
	}

    override public function setGraphicSize(Width:Int = 0, Height:Int = 0):Void {
        super.setGraphicSize(Width,Height);
        this.updateHitbox();
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
    var isExternal:Bool;
    var isBroken:Bool;
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
            if(i.contains(".")){continue;}
            toReturn.push(i.split("/").pop());
        }

        return toReturn;
    }
    public static function getNotePressets():Array<String> {
        var toReturn:Array<String> = ["Default"];
        for(i in Paths.readDirectory('assets/notes')){
            if(!i.endsWith(".json")){continue;}
            toReturn.push(i.split("/").pop().replace(".json", ""));
        }

        return toReturn;
    }
    public static function getNoteEvents(isNote:Bool = false, ?stage:String):Array<String> {
        var toReturn:Array<String> = [];

        for(i in Paths.readDirectory('assets/data/events')){
            if(!i.endsWith(".hx")){continue;}
            toReturn.push(i.split("/").pop().replace(".hx",""));
        }
        
        if(isNote){
            for(i in Paths.readDirectory('assets/data/note_events')){
                if(!i.endsWith(".hx")){continue;}
                toReturn.push(i.split("/").pop().replace(".hx",""));
            }
        }

        if(stage != null){
            for(i in Paths.readDirectory('assets/stages/${stage}/events')){
                if(!i.endsWith(".hx")){continue;}
                toReturn.push(i.split("/").pop().replace(".hx", ""));
            }
        }        

        return toReturn;
    }

    public static function set_note(n1:Array<Dynamic>, n2:Array<Dynamic>):Void {
        if(!(n1 is Array) || !(n2 is Array)){return;}
        for(i in 0...n2.length){
            if(n1.length <= i){
                n1.push(n2[i]);
            }else{
                n1[i] = n2[i];
            }
        }
    }
    
    public static function convNoteData(data:NoteData):Array<Dynamic> {
        if(data == null){return null;}
        return [data.strumTime, data.keyData, data.sustainLength, data.multiHits, data.canMerge, data.presset, data.eventData, data.otherStuff];
    }
    public static function convEventData(data:EventData):Array<Dynamic> {
        if(data == null){return null;}
        return [data.strumTime, data.eventData, data.condition, data.isExternal, data.isBroken];
    }
    
    public static function getNoteData(?note:Array<Dynamic>):NoteData {
        var toReturn:NoteData = {
            strumTime: -100,
            keyData: 0,
            sustainLength: 0,
            multiHits: 0,
            canMerge: false,
            presset: "Default",
            eventData: [],
            otherStuff: []
        }

        if(note == null){return toReturn;}

        if(note.length >= 0 && Std.isOfType(note[0], Float)){toReturn.strumTime = note[0];}
        if(note.length >= 1 && Std.isOfType(note[1], Int)){toReturn.keyData = note[1];}    
        if(note.length >= 2 && Std.isOfType(note[2], Float)){toReturn.sustainLength = note[2];}      
        if(note.length >= 3 && Std.isOfType(note[3], Int)){toReturn.multiHits = note[3];}
        if(note.length >= 4 && note[4]){toReturn.canMerge = true;}
        if(note.length >= 5 && Std.isOfType(note[5], String)){toReturn.presset = note[5];}
        if(note.length >= 6 && Std.isOfType(note[6], Array)){toReturn.eventData = note[6];}
        if(note.length >= 7 && Std.isOfType(note[7], Array)){toReturn.otherStuff = note[7];}
        
        return toReturn;
    }

    public static function getEventData(?event:Array<Dynamic>):EventData {
        var toReturn:EventData = {
            strumTime: -1,
            eventData: [],
            condition: "OnHit",
            isExternal: false,
            isBroken: false
        }

        if(event == null){return toReturn;}

        if(event.length >= 0 && Std.isOfType(event[0], Float)){toReturn.strumTime = event[0];}
        if(event.length >= 1 && Std.isOfType(event[1], Array)){toReturn.eventData = event[1];}
        if(event.length >= 2 && Std.isOfType(event[2], String)){toReturn.condition = event[2];}
        if(event.length >= 3 && event[3]){toReturn.isExternal = true;}
        if(event.length >= 4 && event[4]){toReturn.isBroken = true;}

        return toReturn;
    }
    
    public static var defaultHitHealth:Float = 0.023;
    public static var defaultMissHealth:Float = 0.0475;

    //General Variables
    public var nextNote:Note = null;

    public var prevStrumTime:Float = 0;
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
    
	//PreSettings Variables
	public var pre_TypeScroll:String = PreSettings.getPreSetting("Type Scroll", "Visual Settings");
    
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

        var json_path:String = Paths.getPath('${presset}.json', TEXT, 'notes');
        if(presset != "" && Paths.exists(json_path)){
            var eventList:Dynamic = json_path.getJson();
            otherData = eventList.Events;
        }
        
        for(event in otherData){
            if(event[2] != "OnCreate"){continue;}
            
            var curScript:Script = Script.getScript(event[0]);
            if(curScript == null){MusicBeatState.state.pushTempScript(event[0]);}
            curScript = Script.getScript(event[0]);
            if(curScript == null){return;}

            curScript.setVariable("_note", this);
            curScript.exFunction("execute", event[1]);
        }
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        switch(this.typeNote){
            case "Normal":{playAnim("static");}
            case "Sustain":{
                if(this.nextNote != null){playAnim("sustain");}
                else{playAnim("end");}
                if(pre_TypeScroll == "DownScroll"){flipY = true;}
            }
            case "Switch":{playAnim("sustain"); angle = 270;}
            case "Merge":{playAnim("merge");}
        }
	}

    override public function playAnim(anim:String, force:Bool = false){
		animation.play(anim, force);
        if(typeNote == "Sustain"){
            if(pre_TypeScroll == "DownScroll"){
                if(nextNote != null){
                    nextNote.setGraphicSize(Std.int(nextNote.note_size.x), Std.int(this.y - nextNote.y));
                }else{
                    setGraphicSize(Std.int(note_size.x), Std.int(note_size.y));
                }
            }else{
                if(nextNote != null){
                    setGraphicSize(Std.int(note_size.x), Std.int(nextNote.y - this.y));
                }else{
                    setGraphicSize(Std.int(note_size.x), Std.int(note_size.y / 4));
                }
            }
        }else{
            setGraphicSize(Std.int(note_size.x), Std.int(note_size.y));
        }
	}
}

class StrumEvent extends StrumNote {
    public var conductor:Conductor = null;
    public var strumTime:Float = 0;
    public var isExternal:Bool = false;
    public var isBroke:Bool = false;

    public function new(_strumtime:Float, _conductor:Conductor = null, _isExternal:Bool = false, _isBroke:Bool = false){
        this.strumTime = _strumtime;
        this.conductor = _conductor;
        this.isExternal = _isExternal;
        this.isBroke = _isBroke;
        super(-1, 4, isExternal ? "Laptop" : "EventIcon");
        playAnim("BeEvent");
	}

    override public function loadNote(?_image:String, ?_style:String, ?_type:String){
        var sAnim:String = this.animation != null && this.animation.curAnim != null ? this.animation.curAnim.name : "static";
        if(_image != null){image = _image;} if(_style != null){style = _style;} if(_type != null){type = _type;}

        note_path = Paths.note(image, style, type);
        frames = note_path.getAtlas();
            
        antialiasing = !style.contains("pxl-");
        if(frames == null){return;}

        animation.addByPrefix("BeEvent", "BeEvent", 30, false);
        animation.addByPrefix("AfEvent", "AfEvent", 30, false);
        animation.addByPrefix("OffEvent", "OffEvent", 30, false);
        
        playAnim(sAnim);
    }

    var _lastAnim:String = "";
    override function update(elapsed:Float){
		super.update(elapsed);

        if(isExternal && isBroke){
            if(_lastAnim != "OffEvent"){playAnim("OffEvent"); _lastAnim = "OffEvent";}
        }else if(conductor != null && strumTime < conductor.songPosition){
            if(_lastAnim != "AfEvent"){playAnim("AfEvent"); _lastAnim = "AfEvent";}
        }else{
            if(_lastAnim != "BeEvent"){playAnim("BeEvent"); _lastAnim = "BeEvent";}
        }
	}
}

class NoteSplash extends FlxSprite {
    public static var IMAGE_DEFAULT(get, never):String;
    public static function get_IMAGE_DEFAULT(){return Paths.getFileName(PreSettings.getPreSetting("Splash Skin", "Visual Settings"), true);}

    public var onSplashed:Void->Void = function(){};

    public var playColor:String = "0xffffff";

    public var note_path:String = "";

    public var splash_anims:Array<String> = [];

    public function new(){super();}

    override function update(elapsed:Float){
		super.update(elapsed);

        if(animation.finished){onSplashed();}
	}

    public function setup(X:Float = 0, Y:Float = 0, ?image:String, ?style:String, ?type:String){
        splash_anims = [];

        if(image == null){image = IMAGE_DEFAULT;}
        if(style == null){style = StrumNote.STYLE_DEFAULT;}
        if(type == null){type = StrumNote.TYPE_DEFAULT;}

        this.setPosition(X, Y);

        note_path = Paths.note(image, style, type);
        frames = note_path.getAtlas();
        
        var json_path:String = note_path.replace('${IMAGE_DEFAULT}.png', 'Splash_Anims.json');
        if(Paths.exists(json_path)){
            var anim_list:Array<String> = cast Reflect.getProperty(json_path.getJson(), IMAGE_DEFAULT);
            for(a in anim_list){
                animation.addByPrefix(a, a, 30, false);
                splash_anims.push(a);
            }
        }else{
            animation.addByPrefix("Splash", "Splash", 30, false);
            splash_anims.push("Splash");
        }

        playAnim(splash_anims[FlxG.random.int(0, splash_anims.length - 1)]);
    }

    public function setupByNote(daNote:Note, strumNote:StrumNote):Void {
        splash_anims = [];

        this.setPosition(strumNote.x, strumNote.y);

        note_path = Paths.note(IMAGE_DEFAULT, daNote.style, daNote.type);

        frames = note_path.getAtlas();
        
        var json_path:String = note_path.replace('${IMAGE_DEFAULT}.png', 'Splash_Anims.json');
        if(Paths.exists(json_path)){
            var anim_list:Array<String> = cast Reflect.getProperty(json_path.getJson(), IMAGE_DEFAULT);
            for(a in anim_list){
                animation.addByPrefix(a, a, 30, false);
                splash_anims.push(a);
            }
        }else{
            animation.addByPrefix("Splash", "Splash", 30, false);
            splash_anims.push("Splash");
        }

        playColor = daNote.playColor;

        shader = ColorFilterShader.getColorShader(note_path.getColorNote(), FlxColor.fromString(playColor));

        playAnim(splash_anims[FlxG.random.int(0, splash_anims.length - 1)]);
    }

    public function playAnim(anim:String, ?force:Bool = false){
        animation.play(anim, force);
	}
}

class ColorFilterShader extends FlxShader {
    @:glFragmentSource('
		#pragma header
            uniform float cjk_alpha;
		    uniform int checkColor;
		    uniform vec3 replaceColor;
		    uniform bool isEnabled;

		    /**
		    * Helper method that normalizes an RGB value (in the 0-255 range) to a value between 0-1.
		    */
		    vec3 normalizeColor(vec3 color){return vec3(color[0] / 255.0, color[1] / 255.0, color[2] / 255.0);}

		   void main(){
			    vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);

			    if(!isEnabled){gl_FragColor = pixel; return;}

                vec3 normRepColor = normalizeColor(replaceColor);

                if(checkColor == 0){
                    float diff = pixel.r - ((pixel.b + pixel.g) / 2.0);
                    gl_FragColor = vec4((((pixel.b + pixel.g) / 2.0) + (normRepColor.r * diff)) * cjk_alpha, (pixel.g + (normRepColor.g * diff)) * cjk_alpha, (pixel.b + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                    return;
                }else if(checkColor == 1){
                    float diff = pixel.g - ((pixel.r + pixel.b) / 2.0);
                    gl_FragColor = vec4((pixel.r + (normRepColor.r * diff)) * cjk_alpha, (((pixel.r + pixel.b) / 2.0) + (normRepColor.g * diff)) * cjk_alpha, (pixel.b + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                    return;
                }else if(checkColor == 2){
                    float diff = pixel.b - ((pixel.r + pixel.g) / 2.0);
                    gl_FragColor = vec4((pixel.r + (normRepColor.r * diff)) * cjk_alpha, (pixel.g + (normRepColor.g * diff)) * cjk_alpha, (((pixel.r + pixel.g) / 2.0) + (normRepColor.b * diff)) * cjk_alpha, pixel.a * cjk_alpha);
                    return;
                }else{
                    gl_FragColor = vec4(pixel.r, pixel.g, pixel.b, pixel.a * cjk_alpha);
                    return;
                }
		    }
    ')

    public static var shader_list:Array<ColorFilterShader> = [];

    public var _toCheck:String;
    public var _toReplace:FlxColor;
    public static function getColorShader(checkColor:String = "None", replaceColor:FlxColor = FlxColor.GREEN) {
        for(sh in shader_list){
            if(sh._toCheck != checkColor){continue;}
            if(sh._toReplace != replaceColor){continue;}
            return sh;
        }
        return new ColorFilterShader(checkColor, replaceColor);
    }

    public function new(checkColor:String = "None", replaceColor:FlxColor = FlxColor.GREEN){
        super();

        setReplaceColor(replaceColor);
        setCheckColor(checkColor);

        this.isEnabled.value = [true];
        this.cjk_alpha.value = [1];

        shader_list.push(this);
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