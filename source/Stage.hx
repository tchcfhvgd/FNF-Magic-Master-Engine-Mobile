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
import ModSupport;
import haxe.Json;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using SavedFiles;
using StringTools;

class Stage extends FlxTypedGroup<Dynamic>{
    public static function getStageScript(name:String):Script {
        var toReturn:Script = new Script();
        toReturn.exScript(Paths.stage(name).getText());
        return toReturn;
    }
    
    public static function getStages():Array<String>{
        var stageArray:Array<String> = [];
        for(i in Paths.readDirectory('assets/stages')){if(i.contains(".hx")){stageArray.push(i.replace(".hx",""));}}
        return stageArray;
    }

    public var stageData:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
    public var characterData:Array<Character> = [];

    public var curStage:String = "Stage";

    public var script:Script = null;
    public var zoom:Float = 0.7;
    public var camP_1:Array<Int>;
    public var camP_2:Array<Int>;

    private var initChar:Int = 0;

    public var is_debug:Bool = false;
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

        script.exScript(Paths.stage(name).getText());
        reload();
    }

    public function loadStageByScriptSource(scr:String):Void {
        if(script != null){script.destroy();}

        script = new Script();

        script.setVariable("instance", stageData);
        script.setVariable("stage", this);

        script.exScript(scr);
        reload();
    }

    public function reload(){
        zoom = script.getVariable("zoom");

        camP_1 = script.getVariable("camP_1");
        camP_2 = script.getVariable("camP_2");

        initChar = script.getVariable("initChar");

        if(members != null && members.length > 0){
            for(m in members){
                remove(m);
                if(Reflect.hasField(m, "destroy")){m.destroy();}
            }
        }
        stageData.clear();

        script.exFunction("create");
        
        charge();
    }

    public function charge():Void {
        var current_layer:Int = 0;
        for(current_part in stageData){
            add(current_part);
            for(char in characterData){
                var char_layer:Int = Std.int(initChar + char.curLayer);
                if(char_layer < 0){char_layer = 0;} if(char_layer >= stageData.members.length){char_layer = stageData.members.length - 1;}

                if(char_layer == current_layer){
                    if(current_part.scrollFactor != null){char.scrollFactor.set(current_part.scrollFactor.x, current_part.scrollFactor.y);}
                    add(char);
                }
            }

            current_layer++;
        }

        if(showCamPoints){
            if(camP_1 != null){add(new FlxSprite(camP_1[0], camP_1[1]).makeGraphic(5,5));}
            if(camP_2 != null){add(new FlxSprite(camP_2[0], camP_2[1]).makeGraphic(5,5));}
        }
    }

    public function setCharacters(chars:Array<Dynamic>){
        characterData = [];

        var i:Int = 0;
        for(c in chars){
            var nChar = new Character(c[1][0], c[1][1], c[0], c[4], c[5]);

            nChar.scaleCharacter(c[2]);
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
        if(stageData.members != null && stageData.members.length > 0){for(m in stageData.members){stageData.remove(m); if(Reflect.hasField(m, "destroy")){m.destroy();}}}
        if(members != null && members.length > 0){for(m in members){remove(m); if(Reflect.hasField(m, "destroy")){m.destroy();}}}
        if(script != null){script.destroy();}
        super.destroy();
    }
}