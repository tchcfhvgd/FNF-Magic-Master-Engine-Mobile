package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class Controls {
    public static var curKeyBinds:Array<Dynamic> = [];
    public static var defaultKeyBinds:Array<Dynamic> = [
        ["Menu_Accept", [SPACE, ENTER]],
        ["Menu_Back", [BACKSPACE, ESCAPE]],
        ["Menu_Left", [LEFT]],
        ["Menu_Up", [UP]],
        ["Menu_Down", [DOWN]],
        ["Menu_Right", [RIGHT]],

        ["Game_Accept", [SPACE, ENTER]],
        ["Game_Back", [BACKSPACE, ESCAPE]],
        ["Game_Pause", [ESCAPE, ENTER]],
        ["Game_Reset", [R]],
        ["Game_Left", [LEFT]],
        ["Game_Up", [UP]],
        ["Game_Down", [DOWN]],
        ["Game_Right", [RIGHT]]
    ];

    public static var curStrumBinds:Array<Dynamic> = [];
    public static var defaultStrumBinds:Array<Dynamic> = [
        ["1K", [[SPACE]]],
        ["2K", [[LEFT, A], [RIGHT, D]]],
        ["3K", [[LEFT, A], [SPACE, DOWN, UP, S, W], [RIGHT, D]]],
        ["4K", [[LEFT, A], [DOWN, S], [UP, W], [RIGHT, D]]],
        ["5K", [[LEFT, A], [DOWN, S], [SPACE], [UP, W], [RIGHT, D]]],
        ["6K", [[A], [S], [D], [J], [K], [L]]],
        ["7K", [[A], [S], [D], [SPACE], [J], [K], [L]]],
        ["8K", [[A], [S], [D], [F], [H], [J], [K], [L]]],
        ["9K", [[A], [S], [D], [F], [SPACE], [H], [J], [K], [L]]],
        ["10K", [[A], [S], [D], [F], [V], [B], [H], [J], [K], [L]]],
    ];

    public static function loadBinds(){
        var sKeyBinds:FlxSave = new FlxSave();
		sKeyBinds.bind('controls', 'ninjamuffin99');
        if(sKeyBinds != null){
            if(sKeyBinds.data.binds != null){
                reloadBinds(sKeyBinds.data.binds);
            }else{
                reloadBinds(defaultKeyBinds);
            }

            if(sKeyBinds.data.strums != null){
                reloadStrums(sKeyBinds.data.strums);
            }else{
                reloadStrums(defaultStrumBinds);
            }   
		}
    }

    public static function saveBinds(){
        var sKeyBinds:FlxSave = new FlxSave();
		sKeyBinds.bind('controls', 'ninjamuffin99');
        sKeyBinds.data.binds = curKeyBinds;
        sKeyBinds.data.strums = curStrumBinds;
		sKeyBinds.flush();
		FlxG.log.add("PreSettings Saved Successfully!");
    }

    public static function getBind(bind:String, type:String):Bool{
        var keyArray:Array<FlxKey> = [];
        var toReturn:Bool = false;
        
        for(toBind in curKeyBinds){
            if(toBind[0] == bind){
                keyArray = toBind[1];
            }
        }

        switch(type){
            case "PRESSED":{toReturn = FlxG.keys.anyPressed(keyArray);}
            case "JUST_PRESSED":{toReturn = FlxG.keys.anyJustPressed(keyArray);}
            case "JUST_RELEASED":{toReturn = FlxG.keys.anyJustReleased(keyArray);}
        }

        return toReturn;
    }

    public static function getStrumBind(keys:String, type:String):Array<Bool>{
        var keyArray:Array<Dynamic> = [];
        var toReturn:Array<Bool> = [];

        for(strum in curStrumBinds){
            if(strum[0] == keys){
                keyArray = strum[1];
            }
        }

        toReturn.resize(keyArray.length);

        for(i in 0...toReturn.length){
            switch(type){
                case "PRESSED":{toReturn[i] = FlxG.keys.anyPressed(keyArray[i]);}
                case "JUST_PRESSED":{toReturn[i] = FlxG.keys.anyJustPressed(keyArray[i]);}
                case "JUST_RELEASED":{toReturn[i] = FlxG.keys.anyJustReleased(keyArray[i]);}
            }
        }
        
        return toReturn;
    }
    
    static function reloadBinds(newBinds:Array<Dynamic>){
        curKeyBinds = newBinds;
        for(nBind in curKeyBinds){hasDefBind(nBind[0]);}
        for(dBind in defaultKeyBinds){dAddBind(dBind[0], dBind[1]);}
    }

    static function reloadStrums(newBinds:Array<Dynamic>){
        curStrumBinds = newBinds;
        for(nBind in curStrumBinds){hasDefStrum(nBind[0]);}
        for(dBind in defaultStrumBinds){dAddStrum(dBind[0], dBind[1]);}
    }

    static function hasDefStrum(bind:String){
        var hasBind = false;
        for(dbind in defaultStrumBinds){
            if(dbind[0] == bind){
                hasBind = true;
            }
        }
        if(!hasBind){
            removeStrum(bind);
        }
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

    static function dAddBind(bind:String, toSet){
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

    static function dAddStrum(bind:String, toSet){
        var hasSet = false;
        for(set in curStrumBinds){
            if(set[0] == bind){
                hasSet = true;
            }
        }
        if(!hasSet){
            curStrumBinds.push([bind, toSet]);
        }
    }

    static function removeBind(bind:String){
        for(binds in curKeyBinds){
            if(binds[0] == bind){
                curKeyBinds.remove(binds);
            }
        }
    }

    static function removeStrum(bind:String){
        for(strum in curStrumBinds){
            if(strum[0] == bind){
                curStrumBinds.remove(strum);
            }
        }
    }
}