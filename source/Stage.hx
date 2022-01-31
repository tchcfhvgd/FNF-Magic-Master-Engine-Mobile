package;

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

class Stage extends FlxGroup{
    public var CamZoom:Float = 0.7;
    public var Chrome:Float = 0;

    public var characters:FlxTypedGroup<Character>;
    public var specialData:FlxTypedGroup<Dynamic>;

    public function new(?stage:String = "Stage", ?chars:Array<Dynamic>){
        if(chars == null){chars = [];}
        super();

        characters = new FlxTypedGroup<Character>();
        specialData = new FlxTypedGroup<Dynamic>();

        var JSON:StageData = cast Json.parse(Assets.getText(Paths.StageJSON(stage)));

        for(char in chars){
            if(char[6] == null || char[6] < 0){
                char[6] = JSON.StageData.length - 1;
            }
        }

        CamZoom = JSON.CamZoom;
        Chrome = JSON.Chrome;

        var numCont:Int = 0;
        for(sprite in JSON.StageData){
            var stagePart:StageSprite;
            if(sprite.stageAnims != null && sprite.stageAnims.length > 0){
                stagePart = new StageSprite(sprite.position[0], sprite.position[1]);
                stagePart.frames = Paths.getStageAtlas(sprite.image, JSON.Directory);
                stagePart.scrollFactor.set(sprite.scrollFactor[0], sprite.scrollFactor[1]);
                if(sprite.antialiasing){stagePart.antialiasing = PreSettings.getPreSetting("Antialiasing");}

                var anims = sprite.stageAnims;
                for(anim in anims){
                    if(anim.indices != null && anim.indices.length > 0){
                        stagePart.animation.addByIndices(anim.anim, anim.symbol, anim.indices, "", anim.fps, anim.loop);
                    }else{
                        stagePart.animation.addByPrefix(anim.anim, anim.symbol, anim.fps, anim.loop);
                    }
        
                    if(anim.offsets != null && anim.offsets.length > 1){
                        stagePart.animOffsets[anim.anim] = [anim.offsets[0], anim.offsets[1]];
                    }
                }

                stagePart.setGraphicSize(Std.int(stagePart.width * sprite.size));
                stagePart.updateHitbox();

                stagePart.playAnim("idle");
            }else{
                stagePart = new StageSprite(sprite.position[0], sprite.position[1]);
                stagePart.loadGraphic(Paths.image('${JSON.Directory}/${sprite.image}', 'stages'));
                if(sprite.antialiasing){stagePart.antialiasing = PreSettings.getPreSetting("Antialiasing");}
                stagePart.scrollFactor.set(sprite.scrollFactor[0], sprite.scrollFactor[1]);
                stagePart.setGraphicSize(Std.int(stagePart.width * sprite.size));
                stagePart.updateHitbox();
            }

            add(stagePart);

            for(char in chars){
                if(char[6] == numCont){
                    //["Girlfriend", [140, 210], false, "Default", "GF", 3]
                    var newChar:Character = new Character(char[1][0], char[1][1], char[0], char[4], char[5], char[3]);
                    newChar.x += newChar.positionArray[0];
                    newChar.y += newChar.positionArray[1];

                    newChar.setGraphicScale(char[2]);

                    newChar.scrollFactor.set(stagePart.scrollFactor.x, stagePart.scrollFactor.y);

                    characters.add(newChar);
                    add(newChar);
                }
            }

            numCont++;
        }
    }
}

class StageSprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Dynamic>>;
    
    public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Null<FlxGraphicAsset>){
        super(X, Y, SimpleGraphic);

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
}