package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.FlxG;

import openfl.Lib;

class MagicStuff {
	public static final version:String = "0.6";
    
    inline public static function setWindowTitle(title:String, type:Int = 0){
        switch(type){
            default:{Lib.application.window.title = '[FNF] Magic Master Engine (${version}): ${title}';}
            case 1:{Lib.application.window.title = '[MME ${version}]: ${title}';}
            case 2:{Lib.application.window.title = '${title}';}
        }
    }
    
    public static var transitionTypes:Map<String, TransitionData> = [];
    inline public static function setGlobalTransition(key:String, transition:TransitionData, type:TransitionType = null){
        if(type == transIn){transitionTypes.set('$key-In', transition);}
        else if(type == transOut){transitionTypes.set('$key-Out', transition);}
        else{
            transitionTypes.set('$key-In', transition);
            transitionTypes.set('$key-Out', transition);
        }
    }

    inline public static function changeTransitionType(key:String, type:TransitionType = null){
		if(type == transIn){
			if(transitionTypes.exists('$key-In')){FlxTransitionableState.defaultTransIn = transitionTypes.get('$key-In');}
		}else if(type == transOut){
			if(transitionTypes.exists('$key-Out')){FlxTransitionableState.defaultTransOut = transitionTypes.get('$key-Out');}
		}else{
			if(transitionTypes.exists('$key-In')){FlxTransitionableState.defaultTransIn = transitionTypes.get('$key-In');}
			if(transitionTypes.exists('$key-Out')){FlxTransitionableState.defaultTransOut = transitionTypes.get('$key-Out');}
        }
    }

    public static function sortMembersByX(group:FlxTypedGroup<FlxObject>, selectedX:Float, selected:Int = 0, offset:Int = 10, delay:Float = 0.3):Void {
        if(group == null || group.members.length <= 0 || group.members[selected] == null){return;}

        var selObj:FlxObject = group.members[selected];
        var upWidth:Float = selectedX;
        var downWidth:Float = selectedX + selObj.width + offset;

        var current:Int = selected;
        while(current >= 0){
            var curObj:FlxObject = group.members[current];

            curObj.x = FlxMath.lerp(curObj.x, upWidth, delay);
            upWidth -= curObj.width + offset;
            current--;
        }

        current = selected + 1;
        while(current < group.length){
            var curObj:FlxObject = group.members[current];

            curObj.x = FlxMath.lerp(curObj.x, downWidth, delay);
            downWidth += curObj.width + offset;
            current++;
        }
    }

    public static function sortMembersByY(group:FlxTypedGroup<FlxObject>, selectedY:Float, selected:Int = 0, offset:Int = 10, delay:Float = 0.3):Void {
        if(group == null || group.members.length <= 0 || group.members[selected] == null){return;}

        var selObj:FlxObject = group.members[selected];
        var upHeight:Float = selectedY;
        var downHeight:Float = selectedY;

        var current:Int = selected;
        while(current < group.length){
            var curObj:FlxObject = group.members[current];

            curObj.y = FlxMath.lerp(curObj.y, downHeight, delay);
            downHeight += curObj.height + offset;
            current++;
        }
        
        current = selected - 1;
        while(current >= 0){
            var curObj:FlxObject = group.members[current];

            upHeight -= curObj.height + offset;
            curObj.y = FlxMath.lerp(curObj.y, upHeight, delay);
            current--;
        }
        
    }
}

enum TransitionType {
    transIn;
    transOut;
}