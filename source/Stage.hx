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
    var offsets:Array<Int>;
    var indices:Array<Int>;

    var fps:Int;
    var loop:Bool;
}

class Stage extends FlxTypedGroup<Dynamic>{
    public var curStage:String = "Stage";

    public var directory:String = "Stage";
    public var zoom:Float = 0.7;
    public var chrome:Float = 0;

    private var initChar:Int = 0;

    public var data:StageData = null;
    public var charData:FlxTypedGroup<Character>;
    public var stageData:FlxTypedGroup<StageSprite>;

    var charArray:Array<Dynamic> = [];

    public var onEdit:Bool = false;

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
        setChars(chars);
    }

    override function update(elapsed:Float){
		super.update(elapsed);
    }

    public function loadStage(name:String):Void{
        var newSTAGE:StageData = cast Json.parse(Assets.getText(Paths.StageJSON(name)));
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

        stageData.clear();
        charData.clear();
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

            for(i in 0...charArray.length){
                var char:Array<Dynamic> = charArray[i];
                if(char[6] + initChar == numCont){
                    //["Girlfriend",[400,130],1,true,"Default","GF",0]
                    var newChar:Character = new Character(char[1][0], char[1][1], char[0], char[4], char[5], char[3], char[2]);
                    newChar.x += newChar.positionArray[0];
                    newChar.y += newChar.positionArray[1];

                    newChar.scrollFactor.set(data.StageData[numCont].scrollFactor[0], data.StageData[numCont].scrollFactor[1]);

                    newChar.ID = i;

                    trace("Character: " + char[0] + " | OnRight?: " + char[3]);
                    
                    charData.add(newChar);
                    add(newChar);
                }
            }
            numCont++;
        }
    }

    public function setChars(chars:Array<Dynamic>){
        charArray = chars;

        reload();
    }

    public function getChars():Array<Dynamic>{
        return charArray;
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
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var animArray:Array<StageAnim> = [];

    //Edit Stats
    public var defScale:Float = 1;
    public var defAlpha:Float = 1;

    public var data:StagePart;
    
    public function new(X:Float = 0, Y:Float = 0){
        super(X, Y);

        #if (haxe >= "4.0.0") animOffsets = new Map(); #else animOffsets = new Map<String, Array<Dynamic>>(); #end
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

    public function setGraphicScale(scale:Float = 1){
        defScale = scale;
        setGraphicSize(Std.int(width * defScale));
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
    
                if(anim.offsets != null && anim.offsets.length > 1){
                    animOffsets[anim.anim] = [anim.offsets[0], anim.offsets[1]];
                }
            }

            playAnim("idle");
        }else{
            loadGraphic(Paths.image('${directory}/${part.image}', 'stages'));
        }

        if(part.antialiasing){antialiasing = PreSettings.getPreSetting("Antialiasing");}
        scrollFactor.x = part.scrollFactor[0];
        scrollFactor.y = part.scrollFactor[1];
        angle = part.angle;
        alpha = part.alpha;
        flipX = part.dflipX;
        flipY = part.dflipY;
        setGraphicScale(part.size);
        updateHitbox();
    }
}