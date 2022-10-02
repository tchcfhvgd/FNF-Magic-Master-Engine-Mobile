package;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.interfaces.IResizable;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxStringUtil;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxGradient;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;

#if (desktop && sys)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LangSupport {
    public static function getLangs():Array<String> {
        var toReturn:Array<String> = [];
        for(i in Paths.readDirectory('assets/lang/')){var curFile:String = i;if(curFile.endsWith(".json")){toReturn.push(curFile.replace("lang_", "").replace(".json", ""));}}
        return toReturn;
    }

    public static var Language:String = "English";
    private static var LANG:DynamicAccess<Dynamic>;

    public static function init():Void {
        var savedLang:String = PreSettings.getPreSetting("Language", "Graphic Settings");
        if(savedLang == null){savedLang = Language;}

        setLang(savedLang);
    }

    public static function setLang(_lang:String):Void {
        Language = _lang;

        var nLang:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText(Paths.getPath('lang_${Language}.json', TEXT, 'lang')));        

        for(langFile in Paths.readFileToArray('assets/lang/lang_${Language}.json')){
            var path:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText(langFile));
            for(key in path.keys()){if(!nLang.exists(key)){nLang.set(key, path.get(key));}}
        }

        LANG = nLang;
        FlxG.save.data.language = Language;
    }

    public static function getText(key:String){return LANG.get(key);}
}

class PopLangState extends states.MusicBeatState {
    var langGroup:FlxTypedGroup<FlxText>;

    public static var curLang:Int = 0;

    override public function create():Void{
        FlxG.save.data.inLang = true;
        FlxG.save.flush();

        langGroup = new FlxTypedGroup<FlxText>();
        for(l in LangSupport.getLangs()){
            var nLang:FlxText = new FlxText(0,-100,0, l);
            nLang.setFormat('Calibri', 64, 0xFFFFFFFF, CENTER);
            nLang.screenCenter(X);
            langGroup.add(nLang);
        }
        add(langGroup);

        
        var lblAdvice:FlxText = new FlxText(0, 20, 0, 'Choose Your Language', 32); add(lblAdvice);
        lblAdvice.setFormat('Calibri', 32, 0xFFFFFFFF, CENTER); lblAdvice.screenCenter(X);

        super.create();
    }

    override function update(elapsed:Float){        
        super.update(elapsed);
        
        MagicStuff.sortMembersByY(cast langGroup, FlxG.height / 2, curLang);

        if(FlxG.mouse.wheel < 0){changeLang(1);}
        if(FlxG.mouse.wheel > 0){changeLang(-1);}

		if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){chooseLang();}
	}
    
	public function changeLang(change:Int = 0, force:Bool = false):Void {
		curLang += change; if(force){curLang = change;}

		if(curLang < 0){curLang = langGroup.length - 1;}
		if(curLang >= langGroup.length){curLang = 0;}

		for(i in 0...langGroup.members.length){
			langGroup.members[i].alpha = 0.5;
			if(i == curLang){langGroup.members[i].alpha = 1;}
		}
	}

    public function chooseLang():Void {
        LangSupport.setLang(langGroup.members[curLang].text);
        states.MusicBeatState.switchState(new states.TitleState());
    }
}