package;

import flixel.FlxObject;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Sprite_UI_MENU extends FlxSprite{
    public var TABS:FlxTypedGroup<Sprite_UI_MENU_TAB>;
    public var curTAB:String = "";
    public var tDelay:Float = 5;

    public var dWidth:Int;
    public var dHeight:Int;

    public function new(x:Float, y:Float, width:Int, height:Int){
        dWidth = width;
        dHeight = height;
        super(x, y);

        TABS = new FlxTypedGroup<Sprite_UI_MENU_TAB>();

        makeGraphic(width, height, FlxColor.BLACK);
        alpha = 0.5;

        scrollFactor.set();
    }

    override function update(elapsed:Float){
        if(curTAB == ""){
            TABS.kill();
            alpha = 0;
        }else{
            TABS.revive();
            alpha = 0.5;

            TABS.forEach(function(TAB:Sprite_UI_MENU_TAB){
                if(TAB.tabName == curTAB){
                    TAB.revive();
                }else{
                    TAB.kill();
                }
            });
        }

        super.update(elapsed);
	}

    public function add(TAB:Sprite_UI_MENU_TAB){
        TAB.forEach(function(obj:FlxObject){
            obj.x = this.x + obj.x;
            obj.y = this.y + obj.y;

            obj.scrollFactor.set();
        });

        TABS.add(TAB);
    }
}

class Sprite_UI_MENU_TAB extends FlxTypedGroup<Dynamic>{
    public var tabName:String = "";

    public function new(name:String){
        tabName = name;
        super();
    }

    override function kill(){
        this.forEach(function(obj:Dynamic){
            obj.kill();
        });
    }

    override function revive(){
        this.forEach(function(obj:Dynamic){
            obj.revive();
        });
    }
}