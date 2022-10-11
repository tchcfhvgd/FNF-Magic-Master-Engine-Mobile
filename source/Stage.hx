package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxBaseAnimation;
import flixel.system.FlxAssets;
import flixel.tweens.FlxTween;
import haxe.format.JsonParser;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import Song.SwagSection;
import openfl.utils.Assets;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import haxe.Json;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

import ModSupport;

using StringTools;

class Stage extends FlxTypedGroup<Dynamic>{
    public static function getStages():Array<String>{
        var stageArray:Array<String> = [];

        for(i in Paths.readDirectory('assets/stages')){
            var aStage:String = i;
            if(aStage.contains(".hx")){stageArray.push(aStage.replace(".hx",""));}
        }

        return stageArray;
    }

    public var stageData:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
    public var characterData:Array<Character> = [];

    public var curStage:String = "Stage";

    public var script:Script = null;
    public var zoom:Float = 0.7;
    public var camP_1:FlxPoint;
    public var camP_2:FlxPoint;

    private var initChar:Int = 0;

    public var showCamPoints:Bool = false;

    public var character_Length(get, never):Int;
	inline function get_character_Length():Int {
        var cLenght:Int = 0;
        for(i in this){if((i is Character)){cLenght++;}}
        return cLenght;
    }

    public function new(?stage:String = "Stage", ?chars:Array<Dynamic>){
        if(chars == null){chars = [];}
        super();

        loadStage(stage);
        setCharacters(chars);
    }

    override function update(elapsed:Float){
		super.update(elapsed);
    }

    public function loadStage(name:String):Void {
        curStage = name;

        if(script != null){script.destroy();}

        script = new Script();
        script.Name = name;

        script.setVariable("instance", stageData);
        script.setVariable("stage", this);

        script.exScript(Paths.getText(Paths.stage(name)));
        reload();
    }

    public function reload(){
        zoom = script.getVariable("zoom");

        camP_1 = script.getVariable("camP_1");
        camP_2 = script.getVariable("camP_2");

        initChar = script.getVariable("initChar");

        clear();
        stageData.clear();

        script.exFunction("create");
        
        var numCont:Int = 0;
        for(sPart in stageData){
            add(sPart);
            for(char in characterData){
                var cLyr:Int = Std.int(initChar + char.curLayer);
                if(cLyr < 0){cLyr = 0;}
                if(cLyr >= stageData.members.length){cLyr = stageData.members.length - 1;}

                if(cLyr == numCont){
                    char.scrollFactor.set(sPart.scrollFactor.x, sPart.scrollFactor.y);
                    add(char);
                }
            }

            numCont++;
        }

        if(showCamPoints){
            if(camP_1 != null){add(new FlxSprite(camP_1.x, camP_1.y).makeGraphic(5,5));}
            if(camP_2 != null){add(new FlxSprite(camP_2.x, camP_2.y).makeGraphic(5,5));}
        }
    }

    public function setCharacters(chars:Array<Dynamic>){
        characterData = [];

        var i:Int = 0;
        for(c in chars){
            var nChar = new Character(c[1][0], c[1][1], c[0], c[4], c[5]);
            nChar.x += nChar.positionArray[0];
            nChar.y += nChar.positionArray[1];

            nChar.scale.set(c[2], c[2]);
            nChar.turnLook(c[3]);

            nChar.ID = i;

            nChar.curLayer = c[6];

            characterData.push(nChar);

            i++;
        }

        reload();
    }

    public function getCharacterById(id:Int):Character {
        for(char in characterData){if(char.ID == id){return char;}}
        return null;
    }

    public function getCharacterByName(name:String):Character {
        for(char in characterData){if(char.curCharacter == name){return char;}}
        return null;
    }

    public function getCharacterByType(type:String):Character {
        for(char in characterData){if(char.curType == type){return char;}}
        return null;
    }

    override function destroy():Void {
        if(script != null){script.destroy();}
        super.destroy();
    }
}