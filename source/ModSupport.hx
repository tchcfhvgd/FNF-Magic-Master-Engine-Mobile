package;

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
    public static var MODS:Array<Mod> = [];

    public static var staticScripts:Map<String, Script> = [];
    public static var exScripts:Array<String> = [
        "states.ModListState.hx",
        "states.PreLoaderState.hx"
    ];

    public static function init():Void {
        //Adding Mods from Archives
        #if (desktop && sys)
        if(FileSystem.exists('mods')){
            for(modFolder in FileSystem.readDirectory('mods')){
                var modPath:String = FileSystem.absolutePath('mods/$modFolder');
                
                var newMod = new Mod(modFolder);
    
                MODS.push(newMod);
            }
        }
        #end
    }

    #if sys
    public static function reloadScripts():Void{
        staticScripts.clear();

        for(mod in MODS){
            if(!mod.enabled){continue;}
            checkToScript('${mod.path}/scripts', true);
            if(mod.onlyThis){break;}
        }

        trace(staticScripts);
    }

    static var toRemove:String = "";
    public static function checkToScript(file:String, first:Bool = false){
        var aFile = FileSystem.absolutePath(file);

        if(!FileSystem.exists(aFile)){return;}

        if(first){toRemove = file.replace("/", ".");}
        for(i in FileSystem.readDirectory(aFile)){
            if(FileSystem.isDirectory('$aFile/$i')){checkToScript('${file}/${i}');}else{
                var id:String = '${file}/${i.replace(".hx", "")}'; var id = id.replace("/", ".").replace('$toRemove.', "");
                if(!staticScripts.exists(id) && !exScripts.contains(id)){
                    var nScript = new Script(); nScript.Name = id;
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
        this.path = 'mods/${folder}';
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