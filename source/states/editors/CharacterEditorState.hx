package states.editors;

import flixel.addons.ui.FlxUIGroup;
import flixel.tweens.FlxEase;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.input.FlxInput;
import io.newgrounds.swf.common.Button;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import haxe.DynamicAccess;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import lime.ui.FileDialog;

import Character.CharacterFile;

using StringTools;

class CharacterEditorState extends MusicBeatState{
    public static var _character:CharacterFile;
    var character:Character;

    var backStage:Stage;

    var _file:FileReference;

    //Cameras
    var camBack:FlxCamera;
    var camGeneral:FlxCamera;
	var camHUD:FlxCamera;
    
    var camFollow:FlxObject;

    //
    var MENU:FlxUITabMenu;

    public static function editCharacter(character:CharacterFile = null){
        if(character != null){
            _character = character;
        }else{
            _character = cast Json.parse(Assets.getText(Paths.getCharacterJSON("Boyfrined", "Default", "Default")));
        }

        FlxG.sound.music.stop();
        FlxG.switchState(new CharacterEditorState());
    }

    override function create(){
        FlxG.mouse.visible = true;

        camBack = new FlxCamera();
        camGeneral = new FlxCamera();
		camGeneral.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camBack);
		FlxG.cameras.add(camGeneral);
        FlxG.cameras.add(camHUD);

        backStage = new Stage("Stage", [["Boyfriend",[410,130],1,false,"Default","NORMAL",0]]);
        backStage.cameras = [camGeneral];
        add(backStage);

        character = backStage.getCharacterById(0);
        reloadCharacter();

        var menuTabs = [
            {name: "1Character", label: 'Character'},
        ];
        MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(300, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        MENU.camera = camHUD;

        add(MENU);

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.cameras = [camGeneral];
        camFollow.screenCenter();
		add(camFollow);

		camGeneral.follow(camFollow, LOCKON);
		camGeneral.focusOn(camFollow.getPosition());

        super.create();
    }

    override function update(elapsed:Float){
        character = backStage.getCharacterById(0);

        var canControlle = true;

        if(canControlle){
            if(FlxG.keys.justPressed.ESCAPE){FlxG.switchState(new MainMenuState());}
    
            if(!FlxG.keys.pressed.SHIFT){
                
            }else{
                
            }
        }

        camFollow.setPosition(character.getGraphicMidpoint().x, character.getGraphicMidpoint().y);

        super.update(elapsed);
    }

    private function reloadCharacter() {
        character.setupByCharacterFile(_character);
    }
}