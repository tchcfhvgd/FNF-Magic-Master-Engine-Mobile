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

class ModSupport {
    public static var savedMODS:Array<{name:String, enabled:Bool}> = [];
    public static var MODS:Array<Mod> = [];

    public static var modDataScripts:Map<String, Script> = [];
    public static var staticScripts:Map<String, Script> = [];
    public static var exScripts:Array<String> = [
        "states.ModListState",
        "states.PreLoaderState"
    ];

    public static function init():Void {
        //Loading Saved Mods
        if(FlxG.save.data.saved_mods != null){savedMODS = FlxG.save.data.saved_mods;}

        //Adding Mods from Archives
        #if (desktop && sys)
        if(FileSystem.exists('mods')){
            for(modFolder in FileSystem.readDirectory('mods')){
                var newMod = new Mod(FileSystem.absolutePath('mods/$modFolder'));    
                MODS.push(newMod);
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

    public static function reload_mods():Void{
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
                var id:String = '${file}/${i.replace(".hx", "")}'; var id = id.replace("/", ".").replace('$toRemove.', "");

                if(id == 'ModData'){
                    var nScript = new Script(); nScript.Name = name; nScript.Mod = name;
                    nScript.exScript(Paths.getText('$file/$i'));
                    modDataScripts.set(name, nScript);
                    continue;
                }

                if(!staticScripts.exists(id) && !exScripts.contains(id)){
                    var nScript = new Script(); nScript.Name = id; nScript.Mod = name;
                    nScript.exScript(Paths.getText('$file/$i'));
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
    public var name:String = "Friday Night Funkin' Mod";
    public var prefix:String = "FNF' Mod";
    public var description:String = "A Friday Night Funkin' Mod.";

    public var enabled:Bool = true;
    public var onlyThis:Bool = false;
    public var hideVanilla:Bool = false;

    public var path:String;

    public function new(folder:String, enabled:Bool = true) {
        this.path = folder;
        this.enabled = enabled;

        #if (desktop && sys)
            var identifierJSON:DynamicAccess<Dynamic> = cast Json.parse(File.getContent('$path/mod.json').trim());
            if(identifierJSON != null){
                name = identifierJSON.get('name');
                prefix = identifierJSON.get('prefix');
                description = identifierJSON.get('description');

                onlyThis = identifierJSON.get('onlyThis');
                hideVanilla = identifierJSON.get('hideVanilla');
            }
        #end
    }
}