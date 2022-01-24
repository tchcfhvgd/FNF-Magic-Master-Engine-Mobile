package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class PreSettings {
    public static var PRESETTINGS:Array<Dynamic> = [];
    public static var DEFAULTSETTINGS:Array<Dynamic> = [
        //Game Settings
        ["GhostTapping", true],
        //Visual Settings
        ["NoteSyle", [0, ["Arrows", "Circles", "Rhombuses", "Bars"]]],
        ["TypeHUD", [0, ["MagicHUD", "Original", "Minimized", "OnlyNotes"]]],
        ["TypeScroll", [0, ["UpScroll", "DownScroll"]]],
        ["ForceMiddleScroll", false],
        ["TypeCamera", [1, ["Static", "MoveToSing"]]],
        ["TypeLightStrums", [0, ["All", "OnlyMyStrum", "OnlyOtherStrums", "None"]]],
        //Graphic Settings
        ["ShowFPS", false],
        ["TypeGraphic", [3,
            [
                ["Custom", [

                ]],
                ["Low", [
                    ["FrameRate", 30],
                    ["Antialiasing", false],
                    ["BackgroundAnimated", false],
                    ["AmbientEffects", false],
                    ["HUDEffects", false],
                    ["SplashOnSick", false],
                    ["AllowLUA", false],
                    ["OnlyNotes", false]
                ]],
                ["Medium", [
                    ["FrameRate", 60],
                    ["Antialiasing", true],
                    ["BackgroundAnimated", true],
                    ["AmbientEffects", false],
                    ["HUDEffects", false],
                    ["SplashOnSick", false],
                    ["AllowLUA", true],
                    ["OnlyNotes", false]
                ]],
                ["High", [
                    ["FrameRate", 120],
                    ["Antialiasing", true],
                    ["BackgroundAnimated", true],
                    ["AmbientEffects", true],
                    ["HUDEffects", true],
                    ["SplashOnSick", true],
                    ["AllowLUA", true],
                    ["OnlyNotes", false]
                ]]
            ]
        ]],
        ["FrameRate", 60],
        ["Antialiasing", true],
        ["BackgroundAnimated", true],
        ["AmbientEffects", true],
        ["HUDEffects", true],
        ["SplashOnSick", true],
        ["AllowLUA", true],
        ["OnlyNotes", false],
        //Control Settings
        ["NoteOffset", 0],
        //Other Settings
        ["AllowFlashingLights", true],
        ["AllowViolence", true],
        ["AllowGore", true],
        ["AllowNoSafeForWork", true],
        //Cheating Settings
        ["BotPlay", false],
        ["PracticeMode", false],
        ["DamageMultiplier", 1],
        ["HealingMultiplier", 1],
        ["TypeNotes", [0, ["All", "OnlyShouldPressed", "OnlyNormal", "DisableBads", "DisableGoods", "OnlySpecials"]]],
    ];

    public static var curKeyBinds:Array<Dynamic> = [];
    public static var defaultKeyBinds:Array<Dynamic> = [
        ["Menu_Accept", [SPACE, ENTER]],
        ["Menu_Back", [BACKSPACE, ESCAPE]],
        ["Menu_Left", [LEFT]],
        ["Menu_Up", [UP]],
        ["Menu_Down", [DOWN]],
        ["Menu_Right", [RIGHT]],

        ["GamePlay_Accept", [SPACE, ENTER]],
        ["GamePlay_Back", [BACKSPACE, ESCAPE]],
        ["GamePlay_Pause", [ESCAPE, ENTER]],
        ["GamePlay_Left", [A, LEFT]],
        ["GamePlay_Up", [W, UP]],
        ["GamePlay_Down", [S, DOWN]],
        ["GamePlay_Right", [D, RIGHT]]
    ];

    public static function loadSettings(){
        PRESETTINGS = FlxG.save.data.PRESETTINGS;

        if(PRESETTINGS != null){
            for(pSetting in PRESETTINGS){hasDefault(pSetting[0]);}
            removeList();
            for(dSetting in DEFAULTSETTINGS){addPreSetting(dSetting[0], dSetting[1]);}
            trace("Settings Loaded!");
            trace(PRESETTINGS);
        }else{
            FlxG.save.data.PRESETTINGS = DEFAULTSETTINGS;
            trace("Settings Default!");
            loadSettings();
        }

        var sKeyBinds:FlxSave = new FlxSave();
		sKeyBinds.bind('controls', 'ninjamuffin99');
        if(sKeyBinds != null && sKeyBinds.data.controls != null) {
			reloadBinds(sKeyBinds.data.controls);
		}else{
            reloadBinds(defaultKeyBinds);
        }
    }

    public static function saveSettings(){
        FlxG.save.data.PRESETTINGS = PRESETTINGS;
        var sKeyBinds:FlxSave = new FlxSave();
		sKeyBinds.bind('controls', 'ninjamuffin99');
        sKeyBinds.data.controls = curKeyBinds;
		sKeyBinds.flush();
		FlxG.log.add("PreSettings Saved Successfully!");
    }

    public static function resetSettings(){
        FlxG.save.data.PRESETTINGS = DEFAULTSETTINGS;
        loadSettings();
    }


    public static function getPreSetting(setting:String):Dynamic{
        var toReturn:Dynamic = null;
        for(set in PRESETTINGS){
            if(set[0] == setting){
                toReturn = set[1];
            }
        }
        return toReturn;
    }

    public static function getArraySetting(setting:Array<Dynamic>){
        return setting[1][setting[0]];
    }

    public static function setPreSetting(setting:String, toSet){
        for(set in PRESETTINGS){
            if(set[0] == setting){
                set[1] = toSet;
            }
        }
    }

    static function removePreSetting(setting:String){
        for(set in PRESETTINGS){
            if(set[0] == setting){
                PRESETTINGS.remove(set);
            }
        }
    }

    static function addPreSetting(setting:String, toSet){
        var hasSet = false;
        for(set in PRESETTINGS){
            if(set[0] == setting){
                hasSet = true;
            }
        }
        if(!hasSet){
            PRESETTINGS.push([setting, toSet]);
        }
    }

    static var toRemove:Array<String> = [];
    static function hasDefault(setting:String){
        var hasSet = false;
        for(set in DEFAULTSETTINGS){
            if(set[0] == setting){
                hasSet = true;
            }
        }
        if(!hasSet){
            toRemove.push(setting);
        }
    }

    static function removeList(){
        for(set in toRemove){
            removePreSetting(set);
        }
    }

    static function reloadBinds(newBinds:Array<Dynamic>){
        curKeyBinds = newBinds;
        for(nBind in curKeyBinds){hasDefBind(nBind[0]);}
        for(dBind in defaultKeyBinds){addBind(dBind[0], dBind[1]);}
    }

    static function hasDefBind(bind:String){
        var hasBind = false;
        for(dbind in defaultKeyBinds){
            if(dbind[0] == bind){
                hasBind = true;
            }
        }
        if(!hasBind){
            removeBind(bind);
        }
    }

    static function addBind(bind:String, toSet){
        var hasSet = false;
        for(set in curKeyBinds){
            if(set[0] == bind){
                hasSet = true;
            }
        }
        if(!hasSet){
            curKeyBinds.push([bind, toSet]);
        }
    }

    static function removeBind(bind:String){
        for(i in 0...curKeyBinds.length){
            if(curKeyBinds[i][0] == bind){
                curKeyBinds.remove(i);
            }
        }
    }
}