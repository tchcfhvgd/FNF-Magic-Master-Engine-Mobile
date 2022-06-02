package;

import states.ModListState;
import FlxCustom.FlxUICustomButton;
import flixel.addons.ui.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import haxe.DynamicAccess;
import haxe.Json;

import ModSupport.Mod;

class ItemMod extends FlxUITabMenu {
    public var refMod:Mod;

    public var _selected:Bool = false;
    public var _isSimpleMod:Bool = false;

    public var _btnToggle:FlxUIButton;
    public var _btnMoveUp:FlxUIButton;
    public var _btnMoveDown:FlxUIButton;
    
    public function new(mod:Mod){
        this.refMod = mod;

        var modPrefix:String = "Unknown Mod";
        var modTitle:String = "Unknown Mod";
        var modDescription:String = "Unknown Description";

        modPrefix = mod.prefix;
        modTitle = mod.name;
        modDescription = mod.description;

        var cInfoTabs = [
            {name: "2ModDetails", label: 'Mod Details'},
        ];
        cInfoTabs.push({name: "1ModName", label: modPrefix});

        super(null, null, cInfoTabs);
        resize(Std.int(FlxG.width - 20), 300);

        for(tab in this._tabs){tab.autoResizeLabel = false;}

        // Adding General Tabs
        var tabMod = new FlxUI(null, this);
        tabMod.name = "1ModName";

        var lblName = new FlxText(5, 5, 0, modTitle, 16);
        tabMod.add(lblName);

        var lblDesc = new FlxText(lblName.x, lblName.y + lblName.height + 5, 0, modDescription, 8);
        tabMod.add(lblDesc);

        this.addGroup(tabMod);

        // UNSELECTED TAB
        var tabUnSelect = new FlxUI(null, this);
        tabUnSelect.name = "ModUnSelected";

        var lblName = new FlxText(5, 5, 0, modTitle, 16);
        tabUnSelect.add(lblName);

        this.addGroup(tabUnSelect);

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

        if(_selected && !_isSimpleMod){
            for(tab in this._tabs){if(!tab.alive){tab.revive();}}

            var cHeight = 300;
            if(this.height != cHeight){resize(Std.int(FlxG.width - 20), FlxMath.lerp(this.height, cHeight, 0.1));}
        }else{
            for(tab in this._tabs){if(tab.alive){tab.kill();}}
            getTab('1ModName', 2).revive();
            
            var cHeight = 75;
            if(this.height != cHeight){resize(Std.int(FlxG.width - 20), FlxMath.lerp(this.height, cHeight, 0.1));}
            
            showTabId("ModUnSelected");
        }
	}
}