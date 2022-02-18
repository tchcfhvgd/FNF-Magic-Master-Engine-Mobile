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

typedef StageData = {
    var Directory:String;

    var CamZoom:Float;
    var Chrome:Float;

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

    public var data:StageData = null;
    public var charData:FlxTypedGroup<Character>;

    public function new(?stage:String = "Stage", ?chars:Array<Dynamic>, ?edit:Bool = false){
        if(chars == null){chars = [];}
        super();

        charData = new FlxTypedGroup<Character>();

        var JSON:StageData = cast Json.parse(Assets.getText(Paths.StageJSON(stage)));

        loadStage(JSON);
        loadChars(chars);
    }

    override function update(elapsed:Float){
		super.update(elapsed);
    }

    public function loadStage(stage:StageData){
        data = stage;

        directory = stage.Directory;
        zoom = stage.CamZoom;
        chrome = stage.Chrome;

        clear();
        for(sprite in stage.StageData){
            var stagePart:StageSprite;
            stagePart = new StageSprite(sprite.position[0], sprite.position[1]);
            stagePart.loadPart(sprite, directory);

            add(stagePart);
        }
    }

    public function loadChars(chars:Array<Dynamic>){
        charData.clear();
        
        for(char in chars){
            if(char[6] == null || char[6] < 0){
                char[6] = this.length - 1;
            }
        }

        var numCont:Int = 0;
        for(char in chars){
            if(char[6] == numCont){
                //["Girlfriend", [140, 210], false, "Default", "GF", 3]
                var newChar:Character = new Character(char[1][0], char[1][1], char[0], char[4], char[5], char[3]);
                newChar.x += newChar.positionArray[0];
                newChar.y += newChar.positionArray[1];

                newChar.setGraphicScale(char[2]);

                newChar.scrollFactor.set(data.StageData[numCont].scrollFactor[0], data.StageData[numCont].scrollFactor[1]);
                
                charData.add(newChar);
                insert(numCont, newChar);
            }

            numCont++;
        }
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