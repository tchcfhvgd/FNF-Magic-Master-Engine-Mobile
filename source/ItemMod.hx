package;

import states.ModListState;
import FlxCustom.FlxUICustomButton;
import flixel.addons.ui.*;
import flash.geom.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import haxe.DynamicAccess;
import haxe.Json;

import flixel.addons.ui.interfaces.IFlxUIButton;

import ModSupport.Mod;

class ItemMod extends FlxUITabMenu {
    public var refMod:Mod;
    public var mScript:Script;

    public var _selected:Bool = false;

    public var _btnToggle:FlxUIButton;
    public var _btnMoveUp:FlxUIButton;
    public var _btnMoveDown:FlxUIButton;
    
    public function new(mod:Mod){
        this.refMod = mod;

        mScript = new Script();
        mScript.setVariable("instance", this);
        mScript.setVariable("refMod", refMod);
        mScript.exScript(Paths.getText('${refMod.path}/itemMod.hx'));

        var back_:FlxSprite = mScript.getVariable("back_");
        var tabs_:Array<IFlxUIButton> = mScript.getVariable("tabs_");
        var tab_names_and_labels_:Array<{name:String, label:String}> = mScript.getVariable("tab_names_and_labels_");
        var tab_offset:FlxPoint = mScript.getVariable("tab_offset");
        var stretch_tabs:Bool = mScript.getVariable("stretch_tabs");
        var tab_spacing:Null<Float> = mScript.getVariable("tab_spacing");
        var tab_stacking:Array<String> = mScript.getVariable("tab_stacking");

        if(tab_names_and_labels_ == null){
            tab_names_and_labels_ = [
                {name: "1ModName", label: refMod.prefix}
            ];
        }

        super(back_, tabs_, tab_names_and_labels_, tab_offset, stretch_tabs, tab_spacing, tab_stacking);
        resize(Std.int(FlxG.width - 20), 300);

        mScript.exFunction("create");

        for(tab in this._tabs){tab.autoResizeLabel = false;}

        _btnToggle = new FlxUICustomButton(0,0, 100, null, "...", null, function(){setToggleEnableMod();});
        _btnToggle.x = width - _btnToggle.width;
        add(_btnToggle);
        
        _btnMoveUp = new FlxUICustomButton(0,0, 20, null, "/\\", null, function(){ModSupport.moveMod(this.ID, true);});
        _btnMoveUp.x = _btnToggle.x - _btnMoveUp.width;
        add(_btnMoveUp);
        
        _btnMoveDown = new FlxUICustomButton(0,0, 20, null, "\\/", null, function(){ModSupport.moveMod(this.ID, false);});
        _btnMoveDown.x = _btnMoveUp.x - _btnMoveDown.width;
        add(_btnMoveDown);

        setToggleEnableMod(refMod.enabled);
    }

    public function setToggleEnableMod(?set:Bool){
        if(set == null){set = !refMod.enabled;}

        refMod.enabled = set;

        _btnToggle.label.text = "Enabled";
        _btnToggle.label.color = FlxColor.BLACK;
        _btnToggle.color = FlxColor.fromRGB(46, 255, 70);
        if(!refMod.enabled){
            _btnToggle.label.text = "Disabled";
            _btnToggle.label.color = FlxColor.WHITE;
            _btnToggle.color = FlxColor.fromRGB(255, 43, 43);
        }
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        mScript.exFunction("update", [elapsed]);

        if(_selected){
            for(tab in this._tabs){if(!tab.alive){tab.revive();}}

            var cHeight = 300;
            if(this.height != cHeight){resize(Std.int(FlxG.width - 20), FlxMath.lerp(this.height, cHeight, 0.1));}
        }else{            
            var cHeight = 75;
            if(this.height != cHeight){resize(Std.int(FlxG.width - 20), FlxMath.lerp(this.height, cHeight, 0.1));}
        }
	}
}