package;

import states.MusicBeatState;
import flixel.FlxBasic;
import hscript.Interp;
import openfl.Lib;

using StringTools;

class Script extends FlxBasic {
    public static function getScript(key:String){
        if(MusicBeatState.state.tempScripts.exists(key)){return MusicBeatState.state.tempScripts.get(key);}
        return ModSupport.staticScripts.get(key);
    }

    public static var parser = new hscript.Parser();
    var interp = new hscript.Interp();
    var program = null;

    public var Name:String;

    public override function new(){
        parser.allowTypes = true;
        super();

        preVariables();
    }

    public function loadScript(script:String):Void{
        try{
            this.program = parser.parseString(script);
        }catch(e){
            trace('[Script Error]: ${e.message}');
            Lib.application.window.alert(e.message, "Script Error!");
        }
    }

    public function getVariable(name:String):Dynamic{return interp.variables.get(name);}
    public function setVariable(name:String, toSet:Dynamic){interp.variables.set(name, toSet);}
    public function preVariables():Void{
        var nFunc = function(){};

        setVariable('create', nFunc);

        setVariable('update', function(elapsed:Float) {});
        setVariable('beatHit', function(curBeat:Int) {});
        setVariable('stepHit', function(curStep:Int) {});

        setVariable("presset", function(name:String, func:Any){setVariable(name, func);});
        setVariable('destroy', function(){this.program = null; this.destroy();});
        
        setVariable("pushGlobal", function(){states.MusicBeatState.state.tempScripts.set(this.Name, this);});
        
        setVariable('this', this);
		setVariable('getState', function(){return states.MusicBeatState.state;});
        setVariable('getScript', function(key:String):Script{return getScript(key);});

        setVariable("import", function(imp:String, ?val:String){
            var cl = Type.resolveClass(imp);
            var en = Type.resolveEnum(imp);
            if(cl == null && en == null){Lib.application.window.alert('This Lib Class/Enum [${imp}] is Null', "Null Import"); return;}
            if(en != null){
                var nEnum = {}; for(c in en.getConstructors()){Reflect.setField(nEnum, c, en.createByName(c));}
                setVariable(val != null ? val : imp, nEnum);
            }
            if(cl != null){setVariable(val != null ? val : imp, cl);}
        });
    }
    
    public function execute():Void{if(program != null){interp.execute(program);}}
    public function exFunction(name:String, ?args:Array<Any>):Dynamic {
        if(program == null){trace('{${Name}}: Null Script'); return null;}
        if(!interp.variables.exists(name)){trace('{${Name}}: Null Function [${name}]'); return null;}

        var FUNCT = interp.variables.get(name);
        var toReturn = null;
        if(args != null){
            try{
                toReturn = Reflect.callMethod(null, FUNCT, args);
            }catch(e){
                trace('{${Name}}: [Function Error](${name}): ${e}');
            }
        }else{
            try{
                toReturn = FUNCT();
            }catch(e){
                trace('{${Name}}: [Function Error](${name}): ${e}');
            }
        }

        return null;
    }
    
    public function exScript(script:String):Void{
        loadScript(script);
        execute();
    }

    public override function destroy(){
        states.MusicBeatState.state.tempScripts.remove(Name);
        program = null;
        super.destroy();
    }
}