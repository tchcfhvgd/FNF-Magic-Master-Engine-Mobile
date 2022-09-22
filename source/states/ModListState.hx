package states;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.interfaces.IResizable;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxStringUtil;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxGradient;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import haxe.DynamicAccess;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;


import flixel.addons.ui.*;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
import sys.FileSystem;
import sys.io.File;
#end

import FlxCustom.FlxUICustomButton;
import ModSupport.Mod;

using StringTools;

class ModListState extends MusicBeatState {
    private var ModsList:FlxTypedGroup<ItemMod>;
    private var index:Int = 0;

    private var btnToggleAll:FlxUIButton;
    private var btnEnableAll:FlxUIButton;
    private var btnDisableAll:FlxUIButton;

	override public function create():Void{        
		var gradGround:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.fromRGB(0, 255, 187), FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.fromRGB(0, 255, 187)]);
        gradGround.scrollFactor.set();
		add(gradGround);

        ModsList = new FlxTypedGroup<ItemMod>();
        var i:Int = 0;
        for(mod in ModSupport.MODS){
            var modCard:ItemMod = new ItemMod(mod);
            modCard.onButton = function(){changeIndex();}
            modCard.ID = i; modCard.x = 10;

            ModsList.add(modCard);
            i++;
        }
        add(ModsList);

        changeIndex();

        btnToggleAll = new FlxUICustomButton(0, 0, 150, null, "Toggle All", [Paths.image("custom_button_3"), true, 19, 19], null, function(){for(i in ModsList.members){i.setToggleEnableMod();}});
        btnToggleAll.setPosition((FlxG.width / 2) - 245, FlxG.height - btnToggleAll.height - 20);
        add(btnToggleAll);
        
        btnEnableAll = new FlxUICustomButton(0, 0, 150, null, "Enable All", [Paths.image("custom_button_3"), true, 19, 19], FlxColor.fromRGB(46, 255, 70), function(){for(i in ModsList.members){i.setToggleEnableMod(true);}}); add(btnEnableAll);
        btnEnableAll.setPosition(btnToggleAll.x + btnToggleAll.width + 20, FlxG.height - btnEnableAll.height - 20);
        
        btnDisableAll = new FlxUICustomButton(0, 0, 150, null, "Disable All", [Paths.image("custom_button_3"), true, 19, 19], FlxColor.fromRGB(255, 43, 43), function(){for(i in ModsList.members){i.setToggleEnableMod(false);}}); add(btnDisableAll);
        btnDisableAll.label.color = FlxColor.WHITE;
        btnDisableAll.setPosition(btnEnableAll.x + btnEnableAll.width + 20, FlxG.height - btnDisableAll.height - 20);

        var lblModList = new FlxText(0, 10, FlxG.width, "Mods List", 16, true);
		lblModList.setFormat(Paths.font("nexarust"), 40, FlxColor.WHITE, CENTER);
        lblModList.bold = true; lblModList.antialiasing = true;
        add(lblModList);
        
		super.create();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

        if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){
            Paths.savedMap.clear();
            ModSupport.reloadScripts();
        }

        if(FlxG.keys.justPressed.UP){changeIndex(-1);}
        if(FlxG.keys.justPressed.DOWN){changeIndex(1);}
        if(FlxG.mouse.wheel > 0){changeIndex(-1);}
        if(FlxG.mouse.wheel < 0){changeIndex(1);}

        if(FlxG.mouse.justPressedRight){for(c in ModsList){if(FlxG.mouse.overlaps(c) && c.ID != index){index = c.ID; changeIndex();}}}

        var selectedCard = ModsList.members[index];
        MagicStuff.sortMembersByY(cast ModsList, (FlxG.height / 2) - (selectedCard.height / 2), index, 10, 0.5);
        #if desktop MagicStuff.setWindowTitle('Checking Mods > ${selectedCard.refMod.name} [${selectedCard.refMod.enabled ? "O" : "X"}] <'); DiscordClient.changePresence('> ${selectedCard.refMod.name} [${selectedCard.refMod.enabled ? "✓": "X"}] <', '[Checking Mods]'); #end
	}

    public function changeIndex(change:Int = 0){
        rePositionItems();

        index += change;

        if(index < 0){index = ModsList.length - 1;}
        if(index >= ModsList.length){index = 0;}

        for(i in 0...ModsList.length){
            var modCard:ItemMod = ModsList.members[i];

            modCard._selected = false;
            modCard.showTabId("4ModUnSelected");
        }
        ModsList.members[index]._selected = true;
        ModsList.members[index].showTabId("1ModName");
    }
    
    public function rePositionItems():Void{
        for(i in 0...ModSupport.MODS.length){
            if(ModsList.members[i].refMod != ModSupport.MODS[i]){
                for(ii in 0...ModsList.members.length){
                    if(ModsList.members[ii].refMod == ModSupport.MODS[i]){
                        ModsList.members[i].ID = ii;
                        ModsList.members[ii].ID = i;
                        break;
                    }
                }
            }
        }

        ModsList.members.sort((a, b) -> Std.int(a.ID - b.ID));
    }
}

class ItemMod extends FlxUITabMenu {
    public var refMod:Mod;
    public var mScript:Script;

    public var _selected:Bool = false;

    public var _btnToggle:FlxUIButton;
    public var _btnMoveUp:FlxUIButton;
    public var _btnMoveDown:FlxUIButton;

    public var openSize:FlxPoint;
    public var closedSize:FlxPoint;
    public var delay:Float = 0.3;

    public var onButton:Void -> Void = function(){};
    
    public function new(mod:Mod){
        this.refMod = mod;

        mScript = new Script();
        mScript.setVariable("getInstance", function(){return this;});
        mScript.exScript(Paths.getText('${refMod.path}/itemMod.hx'));

        var tab_names_and_labels_ = [{name: "1ModName", label: refMod.prefix}];
        var back_ = new FlxUI9SliceSprite(0, 0, Paths.image("custom_chrome_flat"), new Rectangle(0, 0, 50, 50), [10, 10, 40, 40], FlxUI9SliceSprite.TILE_BOTH); back_.antialiasing = true;

        super(back_, null, tab_names_and_labels_);
        resize(Std.int(FlxG.width - 20), 300);

        openSize = new FlxPoint(FlxG.width - 20, 300);
        closedSize = new FlxPoint(FlxG.width - 20, 75);
        
        for(tab in this._tabs){
            tab.autoResizeLabel = false;

            var graphic_names:Array<FlxGraphic> = [
                Paths.image("custom_tab_back"),
                Paths.image("custom_tab_back"),
                Paths.image("custom_tab_back"),
                Paths.image("custom_tab"),
                Paths.image("custom_tab"),
                Paths.image("custom_tab")
            ];
            var slice9tab:Array<Int> = FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_TAB);
            var slice9_names:Array<Array<Int>> = [slice9tab, slice9tab, slice9tab, slice9tab, slice9tab, slice9tab];
            tab.loadGraphicSlice9(graphic_names, 0, 0, slice9_names, FlxUI9SliceSprite.TILE_BOTH, -1, true);
        }

        mScript.exFunction("create");

        _btnToggle = new FlxUICustomButton(0,0, 100, null, "...", [Paths.image("custom_button"), true, 18, 18], null, function(){setToggleEnableMod(); onButton();});
        _btnToggle.x = width - _btnToggle.width;
        add(_btnToggle);
        
        _btnMoveUp = new FlxUICustomButton(0,0, 20, null, "/\\", [Paths.image("custom_button_2"), true, 150, 150], null, function(){ModSupport.moveMod(this.ID, true); onButton();});
        _btnMoveUp.x = _btnToggle.x - _btnMoveUp.width;
        add(_btnMoveUp);
        
        _btnMoveDown = new FlxUICustomButton(0,0, 20, null, "\\/", [Paths.image("custom_button_2"), true, 150, 150], null, function(){ModSupport.moveMod(this.ID, false); onButton();});
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

        var curSize:FlxPoint = closedSize;
        if(_selected){for(tab in this._tabs){if(!tab.alive){tab.revive();}} curSize = openSize;}else{if(this.selected_tab_id != "4ModUnSelected"){this.showTabId("4ModUnSelected");}}
        if(this.width != curSize.x || this.height != curSize.y){resize(FlxMath.lerp(this.width, curSize.x, delay), FlxMath.lerp(this.height, curSize.y, delay));}
	}

    override public function replaceBack(newBack:FlxSprite):Void {
        var i:Int = members.indexOf(_back);
        if(i != -1){
            var oldBack = _back;
            if((newBack is IResizable)){
                var ir:IResizable = cast newBack;
                ir.resize(oldBack.width, oldBack.height);
            }
            newBack.x = oldBack.x;
            newBack.y = oldBack.y;
            members[i] = newBack;
            _back = newBack;
            oldBack.destroy();
        }
    }
}