package;

import flixel.addons.plugin.taskManager.FlxTask;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.ui.FlxInputText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Sprite_Input extends FlxSprite{
    public static var INPUT_VALUES:Array<Dynamic> = [];
    public static var INPUTS:FlxTypedGroup<Sprite_Input>;

    public var type:String = "Buttom";

    public var tag:String = "NONE";
    public var name:String = "";

    public var canUse:Bool = true;
    public var isVisible:Bool = true;

    public var isRight:Bool = false;

    public var pressed:Bool = false;
    
	var holdTime:Float = 0;

    public function new(x:Float, y:Float, name:String, type:String = "Buttom", ?tag:String = "NONE"){
        this.tag = tag;
        this.type = type;
        this.name = name;
        super(x, y);

        antialiasing = true;

        switch(type){
            case "Radio":{
                var hasValue = false;
                for(value in INPUT_VALUES){
                    if(value[0] == "Radio" && value[1] == tag){
                        hasValue = true;
                    }
                }

                if(!hasValue){
                    INPUT_VALUES.push(["Radio", tag, name]);
                }                
            }
        }

        INPUTS.add(this);
    }

    override function update(elapsed:Float){
        if(canUse){
            switch(type){
                default:{
                    if(pressed){
                        alpha = 1;
                    }else{
                        if(FlxG.mouse.overlaps(this)){
                            alpha = 0.8;
                        }else{
                            alpha = 0.4;
                        }
                    }
                }
                case "Radio":{
                    for(value in INPUT_VALUES){
                        if(value[0] == "Radio" && value[1] == tag){
                            if(value[2] == name){
                                alpha = 1;
                            }else{
                                if(FlxG.mouse.overlaps(this)){
                                    alpha = 0.8;
                                }else{
                                    alpha = 0.4;
                                }
                            }
                        }
                    }
                }
            }
        }else{
            alpha = 0.2;
        }

		super.update(elapsed);

        INPUTS.forEach(function(buttom:Sprite_Input){
            switch(buttom.type){
                case "Buttom":{
                    buttom.pressed = (FlxG.mouse.overlaps(buttom) && buttom.canUse && (FlxG.mouse.justPressed && !buttom.isRight || FlxG.mouse.justPressedRight && buttom.isRight));
                }
    
                case "Switcher":{
                    if(FlxG.mouse.overlaps(buttom) && buttom.canUse && (FlxG.mouse.justPressed && !buttom.isRight || FlxG.mouse.justPressedRight && buttom.isRight)){
                        if(buttom.pressed){
                            var timer = new FlxTimer().start(0.1, function(tmr:FlxTimer){buttom.pressed = false;});
                        }else if(!buttom.pressed){
                            var timer = new FlxTimer().start(0.1, function(tmr:FlxTimer){buttom.pressed = true;});
                        }
                    }
                }
    
                case "Radio":{
                    buttom.pressed = (FlxG.mouse.overlaps(buttom) && buttom.canUse && (FlxG.mouse.justPressed && !buttom.isRight || FlxG.mouse.justPressedRight && buttom.isRight));

                    if(buttom.pressed){
                        for(value in INPUT_VALUES){
                            if(value[0] == "Radio" && value[1] == buttom.tag){
                                value[2] = buttom.name;
                            }
                        }
                    }
                }
            }
        });
	}

    public static function setValue(getTag:String, valueToSet:String){
        for(value in INPUT_VALUES){
            if(value[1] == getTag){
                value[2] = valueToSet;
            }
        }
    }
}