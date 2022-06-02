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
    public static var exSOURCE:Array<Class<Dynamic>> = [
        ModSupport,
    ];

    public static var MODS:Array<Mod> = [];

    public static function init():Void {
        //Adding Mods from Archives
        #if (desktop && sys)
        var i:Int = 0;
		for(modFolder in FileSystem.readDirectory('mods')){
            var modPath:String = FileSystem.absolutePath('mods/$modFolder');
            
            var newMod = new Mod(modFolder);

            MODS.push(newMod);

            i++;
        }
        #end

    }

    public static function moveMod(index:Int, toUp:Bool = false){
        var mod_1:Mod = MODS[index];
        var mod_2:Mod = toUp ? MODS[index - 1] : MODS[index + 1];

        if(mod_1 != null && mod_2 != null){
            MODS[index] = mod_2;
            if(toUp){MODS[index - 1] = mod_1;}else{MODS[index + 1] = mod_1;}
        }

        ModListState.rePositionItems();
    }
}

class Mod {
    public var name:String = "Friday Night Funkin' Mod";
    public var prefix:String = "FNF' Mod";
    public var description:String = "A Friday Night Funkin' Mod.";

    public var enabled:Bool = true;

    public var source:Array<Class<Dynamic>> = [];
    public var scripts:Array<Interp> = [];

    public var path:String;

    public function new(folder:String, enabled:Bool = true) {
        this.path = 'mods/${folder}';
        this.enabled = enabled;

        #if (desktop && sys)
            var identifierJSON:DynamicAccess<Dynamic> = cast Json.parse(sys.io.File.getContent('$path/mod.json').trim());
            if(identifierJSON != null){
                name = identifierJSON.get('name');
                prefix = identifierJSON.get('prefix');
                description = identifierJSON.get('description');
            }
        #end
    }
}