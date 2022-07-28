package;

import flixel.FlxBasic;
import hscript.Interp;
import openfl.Lib;

using StringTools;

class Script extends FlxBasic {
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
        
        setVariable("pushGlobal", function(){ModSupport.tempScripts.set(Name, this);});
        setVariable("quitGlobal", function(){ModSupport.tempScripts.remove(Name);});
        
		setVariable('getState', function():Class<Dynamic>{return null;});

        setVariable("import", function(imp:String, ?val:String){
            var toSet:Bool = true;

            if(imp == null){toSet = false;}
            if(Type.resolveClass(imp) == null){Lib.application.window.alert('This Lib Class [${imp}] is Null', "Null Import"); trace('Null Lib [${imp}]'); toSet = false;}

            if(toSet){setVariable(val != null ? val : imp, Type.resolveClass(imp));}
		});
    }
    
    public function execute():Void{if(program != null){interp.execute(program);}}
    public function exFunction(name:String, ?args:Array<Any>):Dynamic {
        if(program == null){trace("Null Script"); return null;}
        if(!interp.variables.exists(name)){trace('Null Function [${name}]'); return null;}

        var FUNCT = interp.variables.get(name);
        var toReturn = null;
        if(args != null){
            try{
                toReturn = Reflect.callMethod(null, FUNCT, args);
            }catch(e){
                trace('[Function Error](${name}): ${e}');
            }
        }else{
            try{
                toReturn = FUNCT();
            }catch(e){
                trace('[Function Error](${name}): ${e}');
            }
        }

        return null;
    }
    
    public function exScript(script:String):Void{
        loadScript(script);
        execute();
    }

    public override function destroy(){
        ModSupport.tempScripts.remove(Name);
        program = null;
        super.destroy();
    }
}