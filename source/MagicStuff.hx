package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSave;
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
}

enum TransitionType {
    transIn;
    transOut;
}