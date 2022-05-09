package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class PreSettings {
    public static var PRESETTINGS:Map<String, Dynamic> = [];
    public static var DEFAULTSETTINGS:Map<String, Dynamic> = [
        // Game Settings
        "Language" => [0, ["English", "Spanish", "Portuguese"]],
        "GhostTapping" => true,
        "NoteOffset" => 0,
        "ScrollSpeedType" => [0, ["Scale", "Force", "Disabled"]],
        "ScrollSpeed" => 1,
        //Visual Settings
        "TypeHUD" => [0, ["MagicHUD", "Original", "Minimized", "OnlyNotes"]],
        "NoteSyle" => [0, ["Arrows", "Circles", "Rhombuses", "Bars"]],
        "TypeScroll" => [0, ["UpScroll", "DownScroll"]],
        "ForceMiddleScroll" => false,
        "TypeCamera" => [1, ["Static", "MoveToSing"]],
        "TypeLightStrums" => [0, ["All", "OnlyMyStrum", "OnlyOtherStrums", "None"]],
        "TypeSplash" => [0, "OnSick", "TransparencyOnRate", "None"],
        // Graphic Settings
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
        "BackgroundAnimated" => true,
        "AmbientEffects" => true,
        "HUDEffects" => true,
        "OnlyNotes" => false,
        // Other Settings
        "AllowFlashingLights" => true,
        "AllowViolence" => true,
        "AllowGore" => true,
        "AllowNotSafeForWork" => true,
        "AllowLUA" => true,
        // Cheating Settings
        "BotPlay" => false,
        "PracticeMode" => false,
        "DamageMultiplier" => 1,
        "HealingMultiplier" => 1,
        "TypeNotes" => [0, ["All", "OnlyNormal", "OnlySpecials", "DisableBads", "DisableGoods"]],
    ];

    public static function loadSettings(){
        PRESETTINGS = FlxG.save.data.PRESETTINGS;

        if(PRESETTINGS != null){
            for(key in DEFAULTSETTINGS.keys()){
                if(!PRESETTINGS.exists(key)){
                    PRESETTINGS.set(key, DEFAULTSETTINGS.get(key));
                }
            }

            trace("||= Reading Settings =||");
            for(key in PRESETTINGS.keys()){trace("[" + key + ": " + PRESETTINGS.get(key) + "]");}
            trace("||= Settings Loaded Successfully! =||");
        }else{
            FlxG.save.data.PRESETTINGS = DEFAULTSETTINGS;
            trace("Null Options. Loading by Default");
            loadSettings();
        }
    }

    public static function saveSettings(){
        FlxG.save.data.PRESETTINGS = PRESETTINGS;
		trace("PreSettings Saved Successfully!");
    }

    public static function resetSettings(){
        FlxG.save.data.PRESETTINGS = DEFAULTSETTINGS;
        loadSettings();
        trace("Options Reset Successfully!");
    }

    public static function getPreSetting(setting:String):Dynamic{
        return PRESETTINGS.get(setting);
    }

    public static function getFromArraySetting(setting:String){
        var pre:Array<Dynamic> = PRESETTINGS.get(setting);
        return pre[1][pre[0]];
    }

    public static function setPreSetting(setting:String, toSet){
        for(set in PRESETTINGS){
            if(set[0] == setting){
                set[1] = toSet;
            }
        }
    }

    static function removePreSetting(setting:String){
        PRESETTINGS.remove(setting);
    }

    static function addPreSetting(setting:String, toSet:Dynamic){
        if(!PRESETTINGS.exists(setting)){
            PRESETTINGS.set(setting, toSet);
        }
    }
}