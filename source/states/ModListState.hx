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
import openfl.utils.AssetType;
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
import flixel.FlxState;
import flixel.FlxG;
import haxe.Json;

import flixel.addons.ui.*;
import states.LoadingState;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

import FlxCustom.FlxCustomShader;
import FlxCustom.FlxUICustomButton;
import ModSupport.Mod;

using StringTools;

class PopModState extends MusicBeatState {
    override public function create():Void{
        TitleState.loadedMods = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height)); bg.screenCenter();
        bg.color = 0xff77ffd6;
        add(bg);
        
        var lblAdvice_1:Alphabet = new Alphabet(0,0,LangSupport.getText('ModAdv_1')); add(lblAdvice_1);
        lblAdvice_1.screenCenter(); lblAdvice_1.y -= 120;
        
        var btnNo = new FlxUICustomButton(0, 0, 80, 80, "", [Paths.getAtlas(Paths.image("tach", null, true)), [["normal", "Idle"], ["highlight", "Over"], ["pressed", "Hit"]]], null, function(){MagicStuff.reload_data(); MusicBeatState.switchState(new LoadingState(new TitleState(), []));});
        btnNo.antialiasing = true;
        btnNo.screenCenter(); btnNo.y += 25; btnNo.x -= btnNo.width; add(btnNo);

        var btnYes = new FlxUICustomButton(0, 0, 100, 100, "", [Paths.getAtlas(Paths.image("like", null, true)), [["normal", "Idle"], ["highlight", "Over"], ["pressed", "Hit"]]], null, function(){MusicBeatState.switchState(new states.ModListState(TitleState));});
        btnYes.antialiasing = true;
        btnYes.screenCenter(); btnYes.y += 25; btnYes.x += btnYes.width; add(btnYes);

        super.create();
    }
}

class ModListState extends MusicBeatState {
    private var ModsList:FlxTypedGroup<ItemMod>;
    private var index:Int = 0;

    private var btnToggleAll:FlxUIButton;
    private var btnEnableAll:FlxUIButton;
    private var btnDisableAll:FlxUIButton;
    private var btnReady:FlxUIButton;

    private var toNext:Class<FlxState>;

	override public function create():Void{
        if(FlxG.sound.music != null){FlxG.sound.music.stop();}
        FlxG.mouse.visible = true;

        if(onConfirm != null){toNext = onConfirm; onConfirm = null;}

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height)); bg.screenCenter();
        bg.color = 0xff77ffd6;
        add(bg);

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
        
        var hud_up:FlxSprite = new FlxSprite(0,-5).loadGraphic(Paths.image("upBar")); add(hud_up);
        var hud_down:FlxSprite = new FlxSprite().loadGraphic(Paths.image("downBar")); hud_down.y = FlxG.height - hud_down.height; add(hud_down);

        btnToggleAll = new FlxUICustomButton(100, 620, 100, 100, '', [Paths.getAtlas(Paths.image("toggle_button", null, true)), [["normal", "Idle"], ["highlight", "Over"], ["pressed", "Hit"]]], null, function(){for(i in ModsList.members){i.setToggleEnableMod();}}); 
        btnToggleAll.antialiasing = true;
        add(btnToggleAll);

        btnEnableAll = new FlxUICustomButton(400, 620, 100, 100, '', [Paths.getAtlas(Paths.image("on_button", null, true)), [["normal", "idle"], ["highlight", "over"], ["pressed", "hit"]]], null, function(){for(i in ModsList.members){i.setToggleEnableMod(true);}}); 
        btnEnableAll.antialiasing = true;
        add(btnEnableAll);

        btnDisableAll = new FlxUICustomButton(700, 620, 100, 100, '', [Paths.getAtlas(Paths.image("off_button", null, true)), [["normal", "idle"], ["highlight", "over"], ["pressed", "hit"]]], null, function(){for(i in ModsList.members){i.setToggleEnableMod(false);}});
        btnDisableAll.antialiasing = true;
        add(btnDisableAll);
        
        btnReady = new FlxUICustomButton(1050, 560, 170, 170, '', [Paths.getAtlas(Paths.image("accept_button", null, true)), [["normal", "idle"], ["highlight", "over"], ["pressed", "hit"]]], null, ready);
        btnReady.antialiasing = true;
        add(btnReady);
        
        var lblModList = new Alphabet(10,20,LangSupport.getText("ModList")); add(lblModList);

		super.create();
	}

	override function update(elapsed:Float){        
        super.update(elapsed);

        if(FlxG.keys.justPressed.UP){changeIndex(-1);}
        if(FlxG.keys.justPressed.DOWN){changeIndex(1);}
        if(FlxG.mouse.wheel > 0){changeIndex(-1);}
        if(FlxG.mouse.wheel < 0){changeIndex(1);}

        if(FlxG.mouse.justPressedRight){for(c in ModsList){if(FlxG.mouse.overlaps(c) && c.ID != index){index = c.ID; changeIndex();}}}

        var selectedCard = ModsList.members[index];
        MagicStuff.sortMembersByY(cast ModsList, (FlxG.height / 2) - (selectedCard.height / 2), index, 10, 0.5);
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
        
        #if desktop MagicStuff.setWindowTitle('Checking Mods > ${ModsList.members[index].refMod.name} [${ModsList.members[index].refMod.enabled ? "O" : "X"}] <'); DiscordClient.changePresence('> ${ModsList.members[index].refMod.name} [${ModsList.members[index].refMod.enabled ? "✓": "X"}] <', '[Checking Mods]'); #end
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

    public function ready():Void {
        MagicStuff.reload_data();

        LoadingState.isGlobal = true;
        var toLoad:Array<Dynamic> = [
            {type:IMAGE,instance:Paths.image("alphabet",null,true)},
            {type:IMAGE,instance:Paths.image("icons/icon-face",null,true)},
            {type:MUSIC,instance:Paths.music("freakyMenu",null,true)},
            {type:SOUND,instance:Paths.sound("cancelMenu",null,true)},
            {type:SOUND,instance:Paths.sound("confirmMenu",null,true)},
            {type:SOUND,instance:Paths.sound("scrollMenu",null,true)},
        ];

        MusicBeatState.switchState(new LoadingState(cast Type.createInstance(toNext, []), toLoad));
    }
}

class ItemMod extends FlxUITabMenu {
    public var refMod:Mod;
    public var mScript:Script;

    public var _selected:Bool = false;

    public var _btnToggle:FlxUICustomButton;
    public var _btnMoveUp:FlxUICustomButton;
    public var _btnMoveDown:FlxUICustomButton;

    public var openSize:FlxPoint;
    public var closedSize:FlxPoint;
    public var delay:Float = 0.3;

    public var onButton:Void -> Void = function(){};
    
    public function new(mod:Mod){
        this.refMod = mod;

        mScript = new Script();
        mScript.setVariable("getInstance", function(){return this;});
        mScript.setVariable("mod_name", refMod.name);
        mScript.exScript(Paths.getText('${refMod.path}/itemMod.hx'));

        var back_ = new FlxUI9SliceSprite(0, 0, Paths.image("custom_default_chrome_flat", null, false, refMod.name), new Rectangle(0, 0, 100, 100), [20, 20, 78, 78], FlxUI9SliceSprite.TILE_BOTH);
        back_.antialiasing = true;

        super(back_, null, []);
        resize(Std.int(FlxG.width - 20), 300);

        openSize = new FlxPoint(FlxG.width - 20, 300);
        closedSize = new FlxPoint(FlxG.width - 20, 75);
              
        mScript.exFunction("create");

        _btnToggle = new FlxUICustomButton(0,0,80,20,"", [Paths.getAtlas(Paths.image(!refMod.enabled ? "disable_button" : "enabled_button", null, true, refMod.name)), [["normal", "Idle"], ["highlight", "Idle"], ["pressed", "Hit"]]], null, function(){setToggleEnableMod(); onButton();});
        _btnToggle.setPosition(this.width - _btnToggle.width - 5, -(_btnToggle.height));
        _btnToggle.antialiasing = true;
        add(_btnToggle);
        
        _btnMoveUp = new FlxUICustomButton(0,5,30,15,"", [Paths.getAtlas(Paths.image("up_button", null, true, refMod.name)), [["normal", "Idle"], ["highlight", "Idle"], ["pressed", "Hit"]]], null, function(){ModSupport.moveMod(this.ID, true); onButton();});
        _btnMoveUp.setPosition(_btnToggle.x - _btnMoveUp.width, -(_btnMoveUp.height));
        _btnMoveUp.antialiasing = true;
        add(_btnMoveUp);
        
        _btnMoveDown = new FlxUICustomButton(0,5,30,15,"", [Paths.getAtlas(Paths.image("down_button", null, true, refMod.name)), [["normal", "Idle"], ["highlight", "Idle"], ["pressed", "Hit"]]], null, function(){ModSupport.moveMod(this.ID, false); onButton();});
        _btnMoveDown.x = _btnMoveUp.x - _btnMoveDown.width;
        _btnMoveDown.antialiasing = true;
        add(_btnMoveDown);

        setToggleEnableMod(refMod.enabled);

        calcBounds();
    }

    public function setToggleEnableMod(?set:Bool){
        if(set == null){set = !refMod.enabled;}

        refMod.enabled = set;

        _btnToggle.setCustomFrames([Paths.getAtlas(Paths.image(!refMod.enabled ? "disable_button" : "enabled_button", null, true, refMod.name)), [["normal", "Idle"], ["pressed", "Hit"]]]);
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        var curSize:FlxPoint = closedSize;
        if(_selected){
            for(tab in this._tabs){if(!tab.alive){tab.revive();}} curSize = openSize;
        }else if(this.selected_tab_id != "4ModUnSelected"){
            this.showTabId("4ModUnSelected");
        }
        if((this.width < curSize.x - 5 || this.width > curSize.x + 5) || (this.height < curSize.y - 5 || this.height > curSize.y + 5)){resize(FlxMath.lerp(this.width, curSize.x, delay), FlxMath.lerp(this.height, curSize.y, delay));}
	
        mScript.exFunction("update", [elapsed]);
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