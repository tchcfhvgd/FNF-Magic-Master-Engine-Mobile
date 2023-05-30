package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

import Character.Skins;

import openfl.Lib;

class MagicStuff {
	public static final version:String = "0.9.1";

    public static function reload_data():Void {
        Paths.savedTempMap.clear();
        Paths.savedGlobMap.clear();
        
        PreSettings.init();
        Controls.init();
        ModSupport.reload_mods();

        for(s in ModSupport.modDataScripts){s.exFunction("load");}
        
		PlayerSettings.init();
        PreSettings.loadSettings();
		LangSupport.init();
		Skins.init();
        
        for(s in ModSupport.modDataScripts){s.exFunction("onLoaded");}
    }
    
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

    public static function doToMember(grp:FlxTypedGroup<FlxSprite>, index:Int, selFun:FlxSprite->Void, odFun:FlxSprite->Void):Void {
        if(grp == null || grp.length <= 0){return;}

        for(i in 0...grp.members.length){
            if(i == index){selFun(grp.members[i]);}
            else{odFun(grp.members[i]);}
        }
    }

    public static function lerpX(obj:Dynamic, dest:Float, ?radio:Float = 0.1):Void {obj.x = FlxMath.lerp(obj.x, dest, radio);}
    public static function lerpY(obj:Dynamic, dest:Float, ?radio:Float = 0.1):Void {obj.y = FlxMath.lerp(obj.y, dest, radio);}

    public static function browserLoad(site:String){#if linux Sys.command('/usr/bin/xdg-open', [site, "&"]); #else FlxG.openURL(site); #end}
}

enum TransitionType {
    transIn;
    transOut;
}