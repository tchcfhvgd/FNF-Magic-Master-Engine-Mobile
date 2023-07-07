import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxSprite", "FlxSprite");
import("SavedFiles");
import("Paths");

var c:FlxSprite;

var ughCinematic:FlxSprite;
var gunsCinematic:FlxSprite;
var stressCinematic1:FlxSprite;
var stressCinematic2:FlxSprite;

function addToLoad(list:Array<Dynamic>){
    list.push({type: "IMAGE", instance: Paths.character("Tankman", "ugh")});
    list.push({type: "IMAGE", instance: Paths.character("Tankman", "guns")});
    list.push({type: "IMAGE", instance: Paths.character("Tankman", "stress")});
    list.push({type: "IMAGE", instance: Paths.character("Tankman", "stress2")});
}

function load_before_char(){}
function update(elapsed:Float){}
function dance(){return false;}

function load_after_char(){
    c = instance.c;
    var c_pos = instance.positionArray;

    ughCinematic = new FlxSprite(c_pos[0], c_pos[1]);
    ughCinematic.frames = SavedFiles.getAtlas(Paths.character("Tankman", "ugh"));
    ughCinematic.animation.addByPrefix("play_1", "TANK TALK 1 P1", 24, false);
    ughCinematic.animation.addByPrefix("play_2", "TANK TALK 1 P2", 24, false);
    ughCinematic.animation.play("play_1");
    ughCinematic.animation.play("play_2");
    ughCinematic.visible = false;
    instance.add(ughCinematic);
    
    gunsCinematic = new FlxSprite(c_pos[0], c_pos[1]);
    gunsCinematic.frames = SavedFiles.getAtlas(Paths.character("Tankman", "guns"));
    gunsCinematic.animation.addByPrefix("play", "TANK TALK 2", 24, false);
    gunsCinematic.animation.play("play");
    gunsCinematic.visible = false;
    instance.add(gunsCinematic);
    
    stressCinematic1 = new FlxSprite(c_pos[0], c_pos[1]);
    stressCinematic1.frames = SavedFiles.getAtlas(Paths.character("Tankman", "stress"));
    stressCinematic1.animation.addByPrefix("play", "TANK TALK 3 P1 UNCUT", 24, false);
    stressCinematic1.animation.play("play");
    stressCinematic1.visible = false;
    instance.add(stressCinematic1);
    
    stressCinematic2 = new FlxSprite(c_pos[0], c_pos[1]);
    stressCinematic2.frames = SavedFiles.getAtlas(Paths.character("Tankman", "stress2"));
    stressCinematic2.animation.addByPrefix("play", "TANK TALK 3 P2 UNCUT", 24, false);
    stressCinematic2.animation.play("play");
    stressCinematic2.visible = false;
    instance.add(stressCinematic2);
}

function turnLook(toRight:Bool){
    var look:Bool = !c.flipX;

    ughCinematic.flipX = look;
    gunsCinematic.flipX = look;
    stressCinematic1.flipX = look;
    stressCinematic2.flipX = look;
}

function playAnim(AnimName:String, Force:Bool, Reversed:Bool, Frame:Int){
    ughCinematic.visible = false;
    gunsCinematic.visible = false;
    stressCinematic1.visible = false;
    stressCinematic2.visible = false;
    c.visible = true;

    var cur_sprite = null;
    var cur_anim:String = "play";
    if(AnimName == "Cinematic_UGH_1"){cur_sprite = ughCinematic; cur_anim = "play_1";} else
    if(AnimName == "Cinematic_UGH_2"){cur_sprite = ughCinematic; cur_anim = "play_2";} else
    if(AnimName == "Cinematic_GUNS"){cur_sprite = gunsCinematic;} else
    if(AnimName == "Cinematic_STRESS_1"){cur_sprite = stressCinematic1;} else
    if(AnimName == "Cinematic_STRESS_2"){cur_sprite = stressCinematic2;}

    if(cur_sprite != null){
        cur_sprite.visible = true;
        c.visible = false;
        cur_sprite.animation.play(cur_anim, Force, Reversed, Frame);
        instance.holdTimer = ((cur_sprite.animation.curAnim.frames.length - Frame) / cur_sprite.animation.curAnim.frameRate);

        return true;
    }

    return false;
}