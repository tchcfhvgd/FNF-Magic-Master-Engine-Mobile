package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets;
import flixel.FlxBasic;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef StageData = {
    var Directory:String;

    var CamZoom:Float;
    var Chrome:Float;
    var initChar:Int;

    var StageData:Array<StagePart>;
}

typedef StagePart = {
    var image:String;

    var position:Array<Float>;
    var scrollFactor:Array<Float>;

    var size:Float;
    var alpha:Float;
    var angle:Float;

    var dflipX:Bool;
    var dflipY:Bool;

    var antialiasing:Bool;

    var stageAnims:Array<StageAnim>;
}

typedef StageAnim = {
    var anim:String;
    var symbol:String;
    var indices:Array<Int>;

    var fps:Int;
    var loop:Bool;
}

class Stage extends FlxTypedGroup<Dynamic>{
    public static function getArrayFromAnims(anims:Array<StageAnim>):Array<String>{
        var toReturn:Array<String> = [];
        if(anims != null && anims.length > 0){
            for(a in anims){toReturn.push(a.anim);}
        }
        return toReturn;
    }

    public var curStage:String = "Stage";

    public var directory:String = "Stage";
    public var zoom:Float = 0.7;
    public var chrome:Float = 0;

    private var initChar:Int = 0;

    public var data:StageData = null;
    public var charData:FlxTypedGroup<Character>;
    public var stageData:FlxTypedGroup<StageSprite>;

    public var onEdit:Bool = false;

    public var character_Length(get, never):Int;
	inline function get_character_Length():Int {return charData.length;}

    public static function getStages():Array<String>{
        var stageArray:Array<String> = [];

        #if windows
            for(i in FileSystem.readDirectory(FileSystem.absolutePath('assets/stages'))){
                if(i.endsWith(".json")){
                    var aStage:String = i.replace(".json","");
                    stageArray.push(aStage);
                }
            }
        #else
            stageArray = [
                "Stage",
                "Land-Cute",
                "Land-Cute-Afternoon",
                "Land-DeadBodys",
                "Land-Destroyed",
                "Land-Lol",
                "Jungle-Land",
                "Line-Land"
            ];
        #end

        return stageArray;
    }

    public function new(?stage:String = "Stage", ?chars:Array<Dynamic>, ?edit:Bool = false){
        if(chars == null){chars = [];}
        this.onEdit = edit;
        super();

        charData = new FlxTypedGroup<Character>();
        stageData = new FlxTypedGroup<StageSprite>();

        loadStage(stage);
        setCharacters(chars);
    }

    override function update(elapsed:Float){
		super.update(elapsed);
    }

    public function loadStage(name:String):Void{
        var newSTAGE:StageData = cast Json.parse(Paths.getText(Paths.getStageJSON(name)));
        if(newSTAGE != null){
            curStage = name;
            reload(newSTAGE);
        }
    }

    public function reload(?stage:StageData = null){
        if(stage != null){data = stage;}

        directory = data.Directory;
        zoom = data.CamZoom;
        chrome = data.Chrome;

        initChar = data.initChar;

        var charInstanced:Array<Character> = [];
        while(charData.members.length > 0){charInstanced.push(charData.members[0]); charData.remove(charData.members[0], true);}

        stageData.clear();
        clear();
        
        var numCont:Int = 0;
        for(sprite in data.StageData){
            var stagePart:StageSprite;
            stagePart = new StageSprite(sprite.position[0], sprite.position[1]);
            stagePart.loadPart(sprite, directory);

            if(onEdit && numCont != states.editors.StageEditorState.curObj){stagePart.alpha = stagePart.defAlpha * 0.5;}

            stageData.ID = numCont;

            stageData.add(stagePart);
            add(stagePart);

            for(i in 0...charInstanced.length){
                if(charInstanced[i].curLayer + initChar == numCont){
                    //["Girlfriend",[400,130],1,true,"Default","GF",0]
                    var newChar:Character = charInstanced[i];
                    newChar.scrollFactor.set(data.StageData[numCont].scrollFactor[0], data.StageData[numCont].scrollFactor[1]);
                    
                    charData.add(newChar);
                    add(newChar);
                }
            }
            numCont++;
        }
    }

    public function setCharacters(chars:Array<Dynamic>){
        charData.clear();

        for(i in 0...chars.length){
            var char:Array<Dynamic> = chars[i];
            
            var newChar:Character = new Character(char[1][0], char[1][1], char[0], char[4], char[5]);
            newChar.x += newChar.positionArray[0];
            newChar.y += newChar.positionArray[1];
            
		    newChar.scale.set(char[2], char[2]);
            newChar.curLayer = char[6];
		    newChar.turnLook(char[3]);

            newChar.ID = i;

            charData.add(newChar);
        }

        reload();
    }

    public function getCharacterById(id:Int):Character {
        if(id >= charData.members.length){id = charData.members.length - 1;}
        if(id <= 0){id = 0;}

        for(char in charData){
            if(char.ID == id){
                return char;
            }
        }

        return null;
    }

    public function getCharacterByName(name:String):Character {
        var toReturn = charData.members[0];

        charData.forEach(function(char:Character){
            if(char.curCharacter == name){
                toReturn = char;
            }
        });

        return toReturn;
    }
}

class StageSprite extends FlxSprite {
    public var animArray:Array<StageAnim> = [];

    //Edit Stats
    public var defScale:Float = 1;
    public var defAlpha:Float = 1;

    public var data:StagePart;
    
    public function new(X:Float = 0, Y:Float = 0){
        super(X, Y);
    }

    public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);
	}
    public function loadPart(part:StagePart, directory:String){
        data = part;

        this.setPosition(part.position[0], part.position[1]);
        if(part.stageAnims != null && part.stageAnims.length > 0){
            frames = Paths.getStageAtlas(part.image, directory);

            animArray = part.stageAnims;
            for(anim in animArray){
                if(anim.indices != null && anim.indices.length > 0){
                    animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
                }else{
                    animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
                }
            }

            playAnim("idle");
        }else{
            loadGraphic('stages:assets/stages/images/${directory}/${part.image}');
        }

        if(part.antialiasing){antialiasing = PreSettings.getPreSetting("Antialiasing");}
        scrollFactor.x = part.scrollFactor[0];
        scrollFactor.y = part.scrollFactor[1];
        angle = part.angle;
        alpha = part.alpha;
        flipX = part.dflipX;
        flipY = part.dflipY;
        scale.set(part.size, part.size);
        updateHitbox();
    }
}