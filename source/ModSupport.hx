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

using SavedFiles;
using StringTools;

class ModSupport {
    public static var savedMODS:Array<{name:String, enabled:Bool}> = [];
    public static var MODS:Array<Mod> = [];

    public static var modDataScripts:Map<String, Script> = [];
    public static var staticScripts:Map<String, Script> = [];
    public static var exScripts:Array<String> = [
        "states.ModListState",
        "states.PreLoaderState"
    ];

    public static var hideVanillaWeeks(get, null):Bool = false;
    static function get_hideVanillaWeeks() {
        for(mod in MODS){if(!mod.enabled){continue;} if(mod.hV_Weeks){return true;} if(mod.onlyThis){break;}}
        return false;
    };
    public static var hideVanillaSongs(get, null):Bool = false;
    static function get_hideVanillaSongs() {
        for(mod in MODS){if(!mod.enabled){continue;} if(mod.hV_Songs){return true;} if(mod.onlyThis){break;}}
        return false;
    };

    public static function init():Void {
        //Loading Saved Mods
        if(FlxG.save.data.saved_mods != null){savedMODS = FlxG.save.data.saved_mods;}

        //Adding Mods from Archives
        #if (desktop && sys)
        if(FileSystem.exists('mods')){
            var _i:Int = 0;
            
            for(modFolder in FileSystem.readDirectory('mods')){
                var mod_path:String = FileSystem.absolutePath('mods/$modFolder');

                if(!FileSystem.isDirectory(mod_path)){continue;}

                var newMod = new Mod(mod_path);  
                newMod.id = _i;  
                MODS.push(newMod);
                _i++;
            }
        }
        #end

        var curSavedMods:Array<{name:String, enabled:Bool}> = savedMODS.copy();
        while(curSavedMods.length > 0){
            var curMod:{name:String, enabled:Bool} = curSavedMods.pop();
            for(c_mod in MODS){
                if(c_mod.name != curMod.name){continue;}
                var curr_mod:Mod = c_mod;
                curr_mod.enabled = curMod.enabled;
                MODS.remove(curr_mod);
                MODS.insert(0, curr_mod);
                break;
            }
        }
    }

    public static function is_same():Bool {
        if(MODS.length <= 0){return true;}
        if(savedMODS.length != MODS.length){return false;}
        for(i in 0...MODS.length){if(MODS[i].name == savedMODS[i].name){continue;} return false;}
        return true;
    }

    public static function reload_mods():Void {
        modDataScripts.clear();
        staticScripts.clear();

        savedMODS = []; for(m in MODS){savedMODS.push({name: m.name, enabled: m.enabled});}
        FlxG.save.data.saved_mods = savedMODS; FlxG.save.flush();

        for(mod in MODS){
            if(!mod.enabled){continue;}
            checkToScript('${mod.path}/scripts', true, mod.name);
            if(mod.onlyThis){break;}
        }

        trace(MODS);
        trace(modDataScripts);
        trace(staticScripts);
    }

    #if sys
    static var toRemove:String = "";
    public static function checkToScript(file:String, first:Bool = false, name:String){
        var aFile = FileSystem.absolutePath(file);

        if(!FileSystem.exists(aFile)){return;}

        if(first){toRemove = file.replace("/", ".");}
        for(i in FileSystem.readDirectory(aFile)){
            if(FileSystem.isDirectory('$aFile/$i')){checkToScript('${file}/${i}', false, name);}else{
                var id:String = '${file}/${i.replace(".hx", "")}'; id = id.replace("/", ".").replace('$toRemove.', "");

                if(id == 'ModData'){
                    var nScript = new Script(); nScript.Name = name; nScript.Mod = name;
                    nScript.exScript('$file/$i'.getText());
                    modDataScripts.set(name, nScript);
                    continue;
                }

                if(!staticScripts.exists(id) && !exScripts.contains(id)){
                    var nScript = new Script(); nScript.Name = id; nScript.Mod = name;
                    nScript.exScript('$file/$i'.getText());
                    staticScripts.set(id, nScript);
                }
            }
        }
    }
    #end

    public static function moveMod(index:Int, toUp:Bool = false){
        var mod_1:Mod = MODS[index];
        var mod_2:Mod = toUp ? MODS[index - 1] : MODS[index + 1];

        if(mod_1 != null && mod_2 != null){
            MODS[index] = mod_2;
            if(toUp){MODS[index - 1] = mod_1;}else{MODS[index + 1] = mod_1;}
        }
    }
}

class Mod {
    public var savefix:String = "FNFSAVE";
    public var name:String = "Friday Night Funkin' Mod";
    public var prefix:String = "FNF' Mod";
    public var description:String = "A Friday Night Funkin' Mod.";

    public var id:Int = 0;

    public var enabled:Bool = false;

    public var onlyThis:Bool = false;

    public var hV_Weeks:Bool = false;
    public var hV_Songs:Bool = false;

    public var path:String;

    public function new(folder:String) {
        this.path = folder;

        var identifierJSON:DynamicAccess<Dynamic> = cast {};

        var mod_info_path = '$path/mod.json';
        if(Paths.exists(mod_info_path)){ identifierJSON = cast mod_info_path.getJson(); }

        savefix = identifierJSON.exists('save_prefix') ? identifierJSON.get('save_prefix') : "plh-";

        name = identifierJSON.exists('name') ? identifierJSON.get('name') : 'Magic Master PlaceHolder Mod - ${MagicStuff.version}';
        prefix = identifierJSON.exists('prefix') ? identifierJSON.get('prefix') : "Mod";
        description = identifierJSON.exists('description') ? identifierJSON.get('description') : folder.split('/').pop();

        onlyThis = identifierJSON.exists('onlyThis') ? identifierJSON.get('onlyThis') : false;
        
        hV_Weeks = identifierJSON.exists('hideVanilla_Weeks') ? identifierJSON.get('hideVanilla_Weeks') : false;
        hV_Songs = identifierJSON.exists('hideVanilla_Songs') ? identifierJSON.get('hideVanilla_Songs') : false;
    }
}