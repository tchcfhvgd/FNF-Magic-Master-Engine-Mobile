import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxG", "FlxG");
import("SavedFiles");
import("Paths");

var c:FlxSprite;

function addToLoad(list:Array<Dynamic>){}
function load_before_char(){}
function load_after_char(){
    c = instance.c;
}

function turnLook(toRight:Bool){}

function playAnim(AnimName:String, Force:Bool, Reversed:Bool, Frame:Int){
    if(AnimName == "singLEFT"){
        var cur_random:Int = FlxG.random.int(1,2);
        c.animation.play("left"+cur_random);
        instance.playAnim("left"+cur_random, true);
        return true;
    }else if(AnimName == "singRIGHT"){
        var cur_random:Int = FlxG.random.int(1,2);
        instance.playAnim("right"+cur_random, true);
        return true;
    }
}

function dance(){return true;}
function update(elapsed:Float){}