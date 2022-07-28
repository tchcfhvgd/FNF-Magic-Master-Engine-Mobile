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
    public var chrome:Float = 0;

    private var initChar:Int = 0;

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

    public function loadStage(name:String):Void{
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
        chrome = script.getVariable("chrome");

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
}