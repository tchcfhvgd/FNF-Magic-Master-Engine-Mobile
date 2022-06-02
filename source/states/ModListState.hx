package states;

import flixel.math.FlxMath;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.addons.ui.*;
import haxe.DynamicAccess;
import openfl.Assets;
import haxe.Json;

#if (desktop && sys)
import sys.FileSystem;
import sys.io.File;
#end

import FlxCustom.FlxUICustomButton;

using StringTools;

class ModListState extends MusicBeatState {
    private static var ModsList:FlxTypedGroup<ItemMod> = new FlxTypedGroup<ItemMod>();
    private static var index:Int = 0;

    private var btnToggleAll:FlxUIButton;
    private var btnEnableAll:FlxUIButton;
    private var btnDisableAll:FlxUIButton;

	override public function create():Void {
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = true;
		add(bg);

        add(ModsList);

        ModsList.clear();
        var i:Int = 0;
        for(mod in ModSupport.MODS){            
            var modCard:ItemMod = new ItemMod(mod);
            modCard.ID = i;

            ModsList.add(modCard);
            i++;
        }

        changeIndex();

        btnToggleAll = new FlxUICustomButton(0, 0, 150, null, "Toggle All", function(){for(i in ModsList.members){i.setToggleEnableMod();}}); add(btnToggleAll);
        btnToggleAll.setPosition((FlxG.width / 2) - 245, FlxG.height - btnToggleAll.height - 20);
        
        btnEnableAll = new FlxUICustomButton(0, 0, 150, null, "Enable All", FlxColor.fromRGB(46, 255, 70), function(){for(i in ModsList.members){i.setToggleEnableMod(true);}}); add(btnEnableAll);
        btnEnableAll.setPosition(btnToggleAll.x + btnToggleAll.width + 20, FlxG.height - btnEnableAll.height - 20);
        
        btnDisableAll = new FlxUICustomButton(0, 0, 150, null, "Disable All", FlxColor.fromRGB(255, 43, 43), function(){for(i in ModsList.members){i.setToggleEnableMod(false);}}); add(btnDisableAll);
        btnDisableAll.label.color = FlxColor.WHITE;
        btnDisableAll.setPosition(btnEnableAll.x + btnEnableAll.width + 20, FlxG.height - btnDisableAll.height - 20);
        
		super.create();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

        if(FlxG.keys.justPressed.UP){changeIndex(-1);}
        if(FlxG.keys.justPressed.DOWN){changeIndex(1);}
        if(FlxG.mouse.wheel > 0){changeIndex(-1);}
        if(FlxG.mouse.wheel < 0){changeIndex(1);}

        if(FlxG.mouse.justPressedRight){for(c in ModsList){if(FlxG.mouse.overlaps(c) && c.ID != index){index = c.ID; changeIndex();}}}

        var selectedCard:ItemMod = ModsList.members[index];
        for(i in 0...ModsList.length){
            var modCard:ItemMod = ModsList.members[i];

            modCard.x = 10;
            if(i < index){modCard.y = FlxMath.lerp(modCard.y, (selectedCard.y - modCard.height - 10) + ((modCard.height + 10) * ((i + 1) - index)), 0.3);}
            if(i == index){modCard.y = FlxMath.lerp(modCard.y, ((FlxG.height / 2) - (modCard.height / 2)) + ((modCard.height + 10) * (i - index)), 0.1);}
            if(i > index){modCard.y = FlxMath.lerp(modCard.y, (selectedCard.y + selectedCard.height + 10) + ((modCard.height + 10) * ((i - 1) - index)), 0.3);}
        }
	}

    public static function changeIndex(change:Int = 0){
        index += change;

        if(index < 0){index = ModsList.length - 1;}
        if(index >= ModsList.length){index = 0;}
        
        for(i in 0...ModsList.length){
            var modCard:ItemMod = ModsList.members[i];

            if(i == index){
                modCard._selected = true;

                modCard.showTabId("1ModName");
            }else{
                modCard._selected = false;

                modCard.showTabId("4ModUnSelected");
            }
        }
    }
    
    public static function rePositionItems():Void{
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

        changeIndex();
    }
}