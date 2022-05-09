package;

import lime.utils.Assets;
import haxe.DynamicAccess;
import haxe.Json;

using StringTools;

class CoolUtil{
	public static function getLangText(key:String, lang:String = null):String{
		if(lang == null){lang = PreSettings.getFromArraySetting("Language");}
		var path:String = 'lang/lang_${lang}.json';

		var langData:DynamicAccess<Dynamic> = cast Json.parse(Assets.getText(Paths.getPath(path, TEXT, "preload")));
		if(langData.exists(key)){
			return langData.get(key);
		}else{
			return "NONE";
		}
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
