package states.editors;

import flixel.*;
import flixel.ui.*;
import flixel.addons.ui.*;
import openfl.display.*;

import flixel.graphics.tile.FlxGraphicsShader;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;
import openfl.net.FileReference;
import flixel.util.FlxColor;
import flash.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import openfl.events.Event;
import lime.ui.FileDialog;
import flixel.FlxSprite;
import haxe.xml.Access;

import Script;

import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomNumericStepper;
import FlxCustom.FlxUIValueChanger;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class SpriteTestState extends MusicBeatState {
    var curSprite:Note;
    var backSprite:FlxSprite;
    
    var arrayFocus:Array<FlxUIInputText> = [];

    var camFollow:FlxObject;

    override function create(){
        FlxG.mouse.visible = true;

        var bgGrid:FlxSprite = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height, true, 0xff4d4d4d, 0xff333333);
        bgGrid.cameras = [camGame];
        add(bgGrid);

        //SPRITES
        curSprite = new Note(Note.getNoteData(), 4);
        curSprite.cameras = [camFGame];

        backSprite = new FlxSprite().makeGraphic(Std.int(curSprite.width), Std.int(curSprite.height));
        backSprite.cameras = [camFGame];

        add(backSprite);
        add(curSprite);

        super.create();
        
		camFollow = new FlxObject(curSprite.getGraphicMidpoint().x, curSprite.getGraphicMidpoint().y, 1, 1);
        camFGame.follow(camFollow, LOCKON);
		add(camFollow); 
    }

    var pos = [[], []];
    override function update(elapsed:Float){
        var pMouse = FlxG.mouse.getPositionInCameraView(camFGame);

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){               
            if(FlxG.mouse.justPressedRight){pos = [[camFollow.x, camFollow.y],[pMouse.x, pMouse.y]];}
            if(FlxG.mouse.pressedRight){camFollow.setPosition(pos[0][0] + ((pos[1][0] - pMouse.x) * 1.0), pos[0][1] + ((pos[1][1] - pMouse.y) * 1.0));}

            if(FlxG.keys.justPressed.ONE){curSprite.typeNote = "Normal";}
            if(FlxG.keys.justPressed.TWO){curSprite.typeNote = "Sustain";}
            if(FlxG.keys.justPressed.THREE){curSprite.typeNote = "Merge";}

            if(FlxG.keys.pressed.V){curSprite.setGraphicSize(Std.int(curSprite.width - 2));}
            if(FlxG.keys.pressed.B){curSprite.setGraphicSize(Std.int(curSprite.width + 2));}

            if(FlxG.keys.justPressed.R){curSprite.angle = 0;}
            if(FlxG.keys.justPressed.C){curSprite.scale.set(1,1);}
            if(FlxG.keys.pressed.SHIFT){
                if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.1);} 
                
                if(FlxG.keys.pressed.Q){curSprite.angle -= 1;}
                if(FlxG.keys.pressed.E){curSprite.angle += 1;}
                
                if(FlxG.keys.pressed.Z){curSprite.scale.x -= 0.1; curSprite.scale.y -= 0.1;}
                if(FlxG.keys.pressed.X){curSprite.scale.x += 0.1; curSprite.scale.y += 0.1;}                
            }else{
                if(FlxG.mouse.wheel != 0){camFGame.zoom += (FlxG.mouse.wheel * 0.01);}

                if(FlxG.keys.pressed.Q){curSprite.angle -= 0.5;}
                if(FlxG.keys.pressed.E){curSprite.angle += 0.5;}
                
                if(FlxG.keys.pressed.Z){curSprite.scale.x -= 0.05; curSprite.scale.y -= 0.05;}
                if(FlxG.keys.pressed.X){curSprite.scale.x += 0.05; curSprite.scale.y += 0.05;}
            }

            if(FlxG.mouse.justPressedMiddle){camFollow.setPosition(curSprite.getGraphicMidpoint().x, curSprite.getGraphicMidpoint().y);}
        }
        if(backSprite.width != curSprite.width || backSprite.height != curSprite.height){backSprite.makeGraphic(Std.int(curSprite.width), Std.int(curSprite.height));}
        
		super.update(elapsed);
    }
}