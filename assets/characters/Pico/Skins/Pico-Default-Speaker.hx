import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxG", "FlxG");
import("SavedFiles");
import("Paths");

var c:FlxSprite;

var gf_idle:FlxSprite;
var gf_demon_1:FlxSprite;
var gf_demon_2:FlxSprite;
var pico_arrives_1:FlxSprite;
var pico_arrives_2:FlxSprite;
var pico_arrives_3:FlxSprite;

function addToLoad(list:Array<Dynamic>){
    list.push({type: "IMAGE", instance: Paths.character("Girlfriend", "gfTankmen")});
    list.push({type: "IMAGE", instance: Paths.character("Pico", "Gf_Demon_1")});
    list.push({type: "IMAGE", instance: Paths.character("Pico", "Gf_Demon_2")});
    list.push({type: "IMAGE", instance: Paths.character("Pico", "Pico_Arrives_1")});
    list.push({type: "IMAGE", instance: Paths.character("Pico", "Pico_Arrives_2")});
    list.push({type: "IMAGE", instance: Paths.character("Pico", "Pico_Arrives_3")});
}

function load_before_char(){}

function load_after_char(){
    c = instance.c;
    var c_pos = instance.positionArray;

    gf_idle = new FlxSprite(-250, 85);
    gf_idle.frames = SavedFiles.getAtlas(Paths.character("Girlfriend", "gfTankmen"));
    gf_idle.animation.addByPrefix("play", "GF Dancing at Gunpoint", 24, false);
    gf_idle.animation.play("play");
    gf_idle.visible = false;
    instance.add(gf_idle);

    gf_demon_1 = new FlxSprite(c_pos[0], c_pos[1]);
    gf_demon_1.frames = SavedFiles.getAtlas(Paths.character("Pico", "Gf_Demon_1"));
    gf_demon_1.animation.addByPrefix("play", "GF STARTS TO TURN PART 1", 24, false);
    gf_demon_1.animation.play("play");
    gf_demon_1.visible = false;
    instance.add(gf_demon_1);
    
    gf_demon_2 = new FlxSprite(c_pos[0], c_pos[1]);
    gf_demon_2.frames = SavedFiles.getAtlas(Paths.character("Pico", "Gf_Demon_2"));
    gf_demon_2.animation.addByPrefix("play", "GF STARTS TO TURN PART 2", 24, false);
    gf_demon_2.animation.play("play");
    gf_demon_2.visible = false;
    instance.add(gf_demon_2);
    
    pico_arrives_1 = new FlxSprite(c_pos[0], c_pos[1]);
    pico_arrives_1.frames = SavedFiles.getAtlas(Paths.character("Pico", "Pico_Arrives_1"));
    pico_arrives_1.animation.addByPrefix("play", "PICO ARRIVES PART 1", 24, false);
    pico_arrives_1.animation.play("play");
    pico_arrives_1.visible = false;
    instance.add(pico_arrives_1);
    
    pico_arrives_2 = new FlxSprite(c_pos[0], c_pos[1]);
    pico_arrives_2.frames = SavedFiles.getAtlas(Paths.character("Pico", "Pico_Arrives_2"));
    pico_arrives_2.animation.addByPrefix("play", "PICO ARRIVES PART 2", 24, false);
    pico_arrives_2.animation.play("play");
    pico_arrives_2.visible = false;
    instance.add(pico_arrives_2);
    
    pico_arrives_3 = new FlxSprite(c_pos[0], c_pos[1]);
    pico_arrives_3.frames = SavedFiles.getAtlas(Paths.character("Pico", "Pico_Arrives_3"));
    pico_arrives_3.animation.addByPrefix("play", "PICO ARRIVES PART 3", 24, false);
    pico_arrives_3.animation.play("play");
    pico_arrives_3.visible = false;
    instance.add(pico_arrives_3);
}

function turnLook(toRight:Bool){
    var look:Bool = c.flipX;

    gf_idle.flipX = look;
    gf_demon_1.flipX = look;
    gf_demon_2.flipX = look;
    pico_arrives_1.flipX = look;
    pico_arrives_2.flipX = look;
    pico_arrives_3.flipX = look;
}

function playAnim(AnimName:String, Force:Bool, Reversed:Bool, Frame:Int){
    gf_idle.visible = false;
    gf_demon_1.visible = false;
    gf_demon_2.visible = false;
    pico_arrives_1.visible = false;
    pico_arrives_2.visible = false;
    pico_arrives_3.visible = false;
    c.visible = true;

    var cur_sprite = null;
    if(AnimName == "gf_idle"){cur_sprite = gf_idle;} else
    if(AnimName == "demon_1"){cur_sprite = gf_demon_1;} else
    if(AnimName == "demon_2"){cur_sprite = gf_demon_2;} else
    if(AnimName == "pico_1"){cur_sprite = pico_arrives_1;} else
    if(AnimName == "pico_2"){cur_sprite = pico_arrives_2;} else
    if(AnimName == "pico_3"){cur_sprite = pico_arrives_3;}

    if(cur_sprite != null){
        cur_sprite.visible = true;
        c.visible = false;
        cur_sprite.animation.play("play", Force, Reversed, Frame);
        instance.holdTimer = ((cur_sprite.animation.curAnim.frames.length - Frame) / cur_sprite.animation.curAnim.frameRate);
        return true;
    }

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