package;

import flixel.FlxG;
import states.ModListState;
import haxe.DynamicAccess;
import lime.tools.AssetType;
import hscript.Interp;
import haxe.Json;

#if (desktop && sys)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LangSupport {
    public static var Language:String = "English";
    private static var LANG:DynamicAccess<Dynamic>;

    public static function init():Void {
        var savedLang:String = PreSettings.getFromArraySetting("Language");
        if(savedLang == null){savedLang = Language;}

        changeLang(savedLang);
    }

    public static function setLang():Void {
        var nLang:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText(Paths.getPath('lang_${Language}.json', TEXT, 'lang')));        

        for(mod in ModSupport.MODS){
			if(mod.enabled && Paths.exists('${mod.path}/assets/lang/lang_${Language}')){
                var path:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText('${mod.path}/assets/lang/lang_${Language}.json'));
                for(key in path.keys()){if(!nLang.exists(key)){nLang.set(key, path.get(key));}}
            }
		}

        if(Paths.exists('lang:assets/lang/lang_${Language}')){
            var path:DynamicAccess<Dynamic> = cast Json.parse(Paths.getText('lang:assets/lang/lang_${Language}.json'));
            for(key in path.keys()){if(!nLang.exists(key)){nLang.set(key, path.get(key));}}
        }

        LANG = nLang;

        FlxG.save.data.language = Language;
    }

    public static function changeLang(lang:String):Void {
        Language = lang;
        setLang();
    }

    public static function getText(key:String){return LANG.get(key);}
}