package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class PreSettings {
    public static var PRESETTINGS:Map<String, Map<String, Dynamic>> = [];
    public static var DEFAULTSETTINGS:Map<String, Map<String, Dynamic>> = [
        "Game Settings" => [
            "Language" => [0, ["English", "Spanish", "Portuguese"]],
            "Ghost Tapping" => true,
            "Note Offset" => 0,
            "Scroll Speed Type" => [0, ["Scale", "Force", "Disabled"]],
            "ScrollSpeed" => 1
        ],
        "Visual Settings" => [
            "Type HUD" => [0, ["MagicHUD", "Original", "Minimized", "OnlyNotes"]],
            "Note Skin" => [0, ["Arrows", "Circles", "Rhombuses", "Bars"]],
            "Typec Scroll" => [0, ["UpScroll", "DownScroll"]],
            "Default Strum Position" => [0, ["Middle", "Right", "Left"]],
            "Type Middle Scroll" => [0, ["None", "OnlyPlayer", "FadeOthers"]],
            "Type Camera" => [1, ["Static", "MoveToSing"]],
            "Type Light Strums" => [0, ["All", "OnlyMyStrum", "OnlyOtherStrums", "None"]],
            "Type Splash" => [0, "OnSick", "TransparencyOnRate", "None"]
        ],
        "Graphic Settings" => [
            "Presets" => [
                "Low" => [
                    "FrameRate" => 30
                ],
                "Medium" => [
                    "FrameRate" => 30
                ]
            ],
            "FrameRate" => 60,
            "Antialiasing" => true,
            "Background Animated" => true,
            "Ambient Effects" => true,
            "HUD Effects" => true,
            "Only Notes" => false
        ],
        "Other Settings" => [
            "Allow FlashingLights" => true,
            "Allow Violence" => true,
            "Allow Gore" => true,
            "Allow NotSafeForWork" => true
        ],
        "Cheating Settings" => [
            "BotPlay" => false,
            "Practice Mode" => false,
            "Damage Multiplier" => 1,
            "Healing Multiplier" => 1,
            "Type Notes" => [0, ["All", "OnlyNormal", "OnlySpecials", "DisableBads", "DisableGoods"]]
        ]
    ];

    public static var CURRENT_SETTINGS:Map<String, Map<String, Dynamic>> = [];
    public static function init():Void {
        PRESETTINGS = DEFAULTSETTINGS.copy();
    }

    public static function loadSettings(){
        CURRENT_SETTINGS = FlxG.save.data.PRESETTINGS;
        if(CURRENT_SETTINGS == null){
            FlxG.save.data.PRESETTINGS = PRESETTINGS;
            trace("Null Options. Loading by Default");
            loadSettings();
            return;
        }
        
        for(key in PRESETTINGS.keys()){
            if(!CURRENT_SETTINGS.exists(key)){CURRENT_SETTINGS.set(key, PRESETTINGS.get(key));}else{
                for(ikey in PRESETTINGS.get(key).keys()){
                    if(!CURRENT_SETTINGS.get(key).exists(ikey)){
                        CURRENT_SETTINGS.get(key).set(ikey, PRESETTINGS.get(key).get(ikey));
                    }
                }
            }
        }

        for(key in CURRENT_SETTINGS.keys()){
            if(!PRESETTINGS.exists(key)){CURRENT_SETTINGS.remove(key);}else{
                for(ikey in CURRENT_SETTINGS.get(key).keys()){
                    if(!PRESETTINGS.get(key).exists(ikey)){
                        CURRENT_SETTINGS.get(key).remove(ikey);
                    }
                }
            }
        }
    }

    public static function saveSettings(){
        FlxG.save.data.PRESETTINGS = CURRENT_SETTINGS;
		trace("PreSettings Saved Successfully!");
    }

    public static function resetSettings(){
        FlxG.save.data.PRESETTINGS = PRESETTINGS;
        loadSettings();
        trace("Options Reset Successfully!");
    }

    public static function getPreSetting(setting:String, category:String):Dynamic{
        var toReturn = CURRENT_SETTINGS.get(category).get(setting);
        if((toReturn is Array)){return toReturn[1][toReturn[0]];}
        return toReturn;
    }

    public static function setPreSetting(setting:String, category:String, toSet){
        CURRENT_SETTINGS.get(category).set(setting, toSet);
    }

    static function removePreSetting(setting:String, category:String){
        CURRENT_SETTINGS.get(category).remove(setting);
    }

    public static function addCategory(setting:String, options:Map<String, Dynamic>){
        PRESETTINGS.set(setting, options);
    }
}