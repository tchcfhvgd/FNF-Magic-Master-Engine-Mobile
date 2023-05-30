import("flixel.util.FlxTimer", "FlxTimer");
import("flixel.FlxSprite", "FlxSprite");
import("Paths", "Paths");

var character_sprite:FlxSprite;

var ughCinematic:FlxSprite;
var gunsCinematic:FlxSprite;
var stressCinematic1:FlxSprite;
var stressCinematic2:FlxSprite;

function addToLoad(list:Array<Dynamic>){
    list.push({type: "ATLAS", instance: Paths.character("Tankman", "ugh")});
    list.push({type: "ATLAS", instance: Paths.character("Tankman", "guns")});
    list.push({type: "ATLAS", instance: Paths.character("Tankman", "stress")});
    list.push({type: "ATLAS", instance: Paths.character("Tankman", "stress2")});
}

function load_before_char(){}

function load_after_char(){
    character_sprite = instance.character_sprite;
    var c_pos = instance.positionArray;

    ughCinematic = new FlxSprite(c_pos[0], c_pos[1]);
    ughCinematic.frames = Paths.getAtlas(Paths.character("Tankman", "ugh"));
    ughCinematic.animation.addByPrefix("play_1", "TANK TALK 1 P1", 24, false);
    ughCinematic.animation.addByPrefix("play_2", "TANK TALK 1 P2", 24, false);
    ughCinematic.visible = false;
    instance.add(ughCinematic);
    
    gunsCinematic = new FlxSprite(c_pos[0], c_pos[1]);
    gunsCinematic.frames = Paths.getAtlas(Paths.character("Tankman", "guns"));
    gunsCinematic.animation.addByPrefix("play", "TANK TALK 2", 24, false);
    gunsCinematic.visible = false;
    instance.add(gunsCinematic);
    
    stressCinematic1 = new FlxSprite(c_pos[0], c_pos[1]);
    stressCinematic1.frames = Paths.getAtlas(Paths.character("Tankman", "stress"));
    stressCinematic1.animation.addByPrefix("play", "TANK TALK 3 P1 UNCUT", 24, false);
    stressCinematic1.visible = false;
    instance.add(stressCinematic1);
    
    stressCinematic2 = new FlxSprite(c_pos[0], c_pos[1]);
    stressCinematic2.frames = Paths.getAtlas(Paths.character("Tankman", "stress2"));
    stressCinematic2.animation.addByPrefix("play", "TANK TALK 3 P2 UNCUT", 24, false);
    stressCinematic2.visible = false;
    instance.add(stressCinematic2);
}

function update(elapsed:Float){
    if(
        ughCinematic.animation.finished ||
        gunsCinematic.animation.finished ||
        stressCinematic1.animation.finished ||
        stressCinematic2.animation.finished
    ){
        instance.specialAnim = false;
    }
}

function turnLook(toRight:Bool){
    var look:Bool = !character_sprite.flipX;

    ughCinematic.flipX = look;
    gunsCinematic.flipX = look;
    stressCinematic1.flipX = look;
    stressCinematic2.flipX = look;
}

function playAnim(AnimName:String, Force:Bool, Reversed:Bool, Frame:Int){
    switch(AnimName){
        default:{
            character_sprite.visible = true;
            ughCinematic.visible = false;
            gunsCinematic.visible = false;
            stressCinematic1.visible = false;
            stressCinematic2.visible = false;
        }
        case "Cinematic_UGH_1":{
            instance.specialAnim = true;

            character_sprite.visible = false;
            ughCinematic.visible = true;
            gunsCinematic.visible = false;
            stressCinematic1.visible = false;
            stressCinematic2.visible = false;

            ughCinematic.animation.play("play_1", Force, Reversed, Frame);
            instance.holdTimer = ((ughCinematic.animation.getByName("play_1").frames.length - Frame) / ughCinematic.animation.getByName("play_1").frameRate);
        }
        case "Cinematic_UGH_2":{
            instance.specialAnim = true;

            character_sprite.visible = false;
            ughCinematic.visible = true;
            gunsCinematic.visible = false;
            stressCinematic1.visible = false;
            stressCinematic2.visible = false;

            ughCinematic.animation.play("play_2", Force, Reversed, Frame);
            instance.holdTimer = ((ughCinematic.animation.getByName("play_2").frames.length - Frame) / ughCinematic.animation.getByName("play_2").frameRate);
        }
        case "Cinematic_GUNS":{
            instance.specialAnim = true;

            character_sprite.visible = false;
            ughCinematic.visible = false;
            gunsCinematic.visible = true;
            stressCinematic1.visible = false;
            stressCinematic2.visible = false;

            gunsCinematic.animation.play("play", Force, Reversed, Frame);
            instance.holdTimer = ((gunsCinematic.animation.getByName("play").frames.length - Frame) / gunsCinematic.animation.getByName("play").frameRate);
        }
        case "Cinematic_STRESS_1":{
            instance.specialAnim = true;

            character_sprite.visible = false;
            ughCinematic.visible = false;
            gunsCinematic.visible = false;
            stressCinematic1.visible = true;
            stressCinematic2.visible = false;

            stressCinematic1.animation.play("play", Force, Reversed, Frame);
            instance.holdTimer = ((stressCinematic1.animation.getByName("play").frames.length - Frame) / stressCinematic1.animation.getByName("play").frameRate);
        }
        case "Cinematic_STRESS_2":{
            instance.specialAnim = true;

            character_sprite.visible = false;
            ughCinematic.visible = false;
            gunsCinematic.visible = false;
            stressCinematic1.visible = false;
            stressCinematic2.visible = true;

            stressCinematic2.animation.play("play", Force, Reversed, Frame);
            instance.holdTimer = ((stressCinematic2.animation.getByName("play").frames.length - Frame) / stressCinematic2.animation.getByName("play").frameRate);
        }
    }
}
function dance(){}