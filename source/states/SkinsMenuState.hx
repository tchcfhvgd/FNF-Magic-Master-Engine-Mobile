package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIButton;
import flixel.input.mouse.FlxMouse;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import io.newgrounds.NG;
import flixel.FlxCamera;
import flixel.FlxG;

import Song.ItemWeek;
import Song.SwagSong;
import Character.Skins;
import Song.SongStuffManager;
import FlxCustom.FlxCustomButton;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomButton;
import states.PlayState.SongListData;
import FlxCustom.FlxUICustomNumericStepper;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class SkinsMenuState extends MusicBeatState {
	public var character:Character;

	public var character_list:Array<String> = [];
	
	public var curCharacter:Int = 0;
	public var curSkin:String = "Default";
	
	public var canChange:Bool = false;

	var alpCharacterName:Alphabet;
	var alpReloadCharacter:Alphabet;
	var alpSkinName:Alphabet;

	var arrowsgroup:FlxTypedGroup<FlxSprite>;

	override function create(){
		FlxG.mouse.visible = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a Skin", null);
		MagicStuff.setWindowTitle('Selecting a Skin');
		#end

		character_list = Character.getCharacters();
		
		var background = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.scrollFactor.set(0, 0);
        background.color = 0xffffd98c;
		background.screenCenter();
		add(background);
		
		character = new Character(-25, 100);
		character.scale.set(0,0);
		character.cameras = [camFGame];
		add(character);
		
        var shape_1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 80, FlxColor.BLACK);
        add(shape_1);

        var shape_2:FlxSprite = new FlxSprite(0, 85).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
        add(shape_2);
		
        var shape_3:FlxSprite = new FlxSprite(0, FlxG.height - 90).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
        add(shape_3);

        var shape_4:FlxSprite = new FlxSprite(0, FlxG.height - 80).makeGraphic(FlxG.width, 80, FlxColor.BLACK);
        add(shape_4);
		
        var shape_5:FlxSprite = new FlxSprite(FlxG.width - 460, 0).makeGraphic(5, FlxG.height, FlxColor.BLACK);
		shape_5.alpha = 0.5;
        add(shape_5);

        var shape_6:FlxSprite = new FlxSprite(FlxG.width - 450, 0).makeGraphic(450, FlxG.height, FlxColor.BLACK);
		shape_6.alpha = 0.5;
        add(shape_6);
		
		var alpSkin = new Alphabet(1050, 95, [{scale:0.35, text:"Skin:"}]);
		add(alpSkin);

		alpCharacterName = new Alphabet(300, 120, [{scale: 0.5, bold: true, text: "Boyfriend"}]);
		alpCharacterName.x = 400 - (alpCharacterName.width / 2);
		add(alpCharacterName);

		alpReloadCharacter = new Alphabet(250, 300, LangSupport.getText("skins_info_1"));
		alpReloadCharacter.y = FlxG.height - alpReloadCharacter.height;
		alpReloadCharacter.screenCenter(X);
		alpReloadCharacter.visible = false;
		alpReloadCharacter.alpha = 0.5;
		add(alpReloadCharacter);

		alpSkinName = new Alphabet(0, 120, [{scale: 0.5, bold: true, text: "Default"}]);
		alpSkinName.x = 1070 - (alpSkinName.width / 2);
		add(alpSkinName);

		arrowsgroup = new FlxTypedGroup<FlxSprite>();
		
		for(i in 0...4){
            var arrow_1:FlxSprite = new FlxSprite();
            arrow_1.frames = Paths.getAtlas(Paths.image('arrows', null, true));
            arrow_1.animation.addByPrefix('idle', 'Arrow Idle');
            arrow_1.animation.addByPrefix('over', 'Arrow Over', false);
            arrow_1.animation.addByPrefix('hit', 'Arrow Hit', false);
            arrow_1.scale.set(0.1, 0.1);
            arrow_1.updateHitbox();
            
            switch(i){
				case 0:{
					arrow_1.angle = 90;
					arrow_1.setPosition(alpCharacterName.x + (alpCharacterName.width / 2) - (arrow_1.width / 2), alpCharacterName.y - arrow_1.height);
				}
                case 1:{
					arrow_1.angle = 270;
					arrow_1.setPosition(alpCharacterName.x + (alpCharacterName.width / 2) - (arrow_1.width / 2), alpCharacterName.y + alpCharacterName.height);
				}
                case 2:{
					arrow_1.setPosition(alpSkinName.x - arrow_1.width, alpSkinName.y + (alpSkinName.height / 2) - (arrow_1.height / 2));
				}
                case 3:{
					arrow_1.flipX = true;
					arrow_1.setPosition(alpSkinName.x + alpSkinName.width, alpSkinName.y + (alpSkinName.height / 2) - (arrow_1.height / 2));
				}
            }

            arrowsgroup.add(arrow_1);
            arrow_1.ID = i;
        }
		
		add(arrowsgroup);

		changeCharacter();

		super.create();

		camFGame.zoom = 0.5;
	}

	override function update(elapsed:Float){		
		super.update(elapsed);

		if(principal_controls.checkAction("Menu_Back", JUST_PRESSED)){character.scale.set(0,0);}
		
		if(canControlle){
			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeCharacter(-1);}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeCharacter(1);}
			
			if(principal_controls.checkAction("Menu_Left", JUST_PRESSED)){changeSkin(-1);}
			if(principal_controls.checkAction("Menu_Right", JUST_PRESSED)){changeSkin(1);}
			
			if(FlxG.keys.justPressed.SPACE && canChange){updateCharacter();}
		}
	}

	function changeCharacter(value:Int = 0, force:Bool = false):Void {
		curCharacter += value; if(force){curCharacter = value;}

		if(curCharacter >= character_list.length){curCharacter = 0;}
		if(curCharacter < 0){curCharacter = character_list.length - 1;}

		alpCharacterName.cur_data = [{scale: 0.5, bold: true, text: Paths.getFileName(character_list[curCharacter])}];
		alpCharacterName.loadText();
		alpCharacterName.x = 400 - (alpCharacterName.width / 2);
		
		curSkin = Skins.getSkin(character_list[curCharacter]);

		changeSkin();
	}

	function changeSkin(value:Int = 0, force:Bool = false):Void {
		var cur_skin:Int = 0;
		var cur_character_skins:Array<Dynamic> = Skins.getSkinList(character_list[curCharacter]);

		for(i in 0...cur_character_skins.length){
			var cur_skin_item:Dynamic = cur_character_skins[i];

			if(cur_skin_item.name == curSkin){
				cur_skin = i;
				break;
			}
		}

		cur_skin += value; if(force){cur_skin = value;}

		if(cur_skin >= cur_character_skins.length){cur_skin = 0;}
		if(cur_skin < 0){cur_skin = cur_character_skins.length - 1;}

		curSkin = cur_character_skins[cur_skin].name;
		if(!cur_character_skins[cur_skin].locked){Skins.setSkin(character_list[curCharacter], curSkin);}

		var display_name:String = Paths.getFileName(curSkin);		
		if(Skins.checkLocked(character_list[curCharacter], curSkin)){
			var arr_display:Array<String> = display_name.split("");
			display_name = "";
			for(i in arr_display){display_name += "?";}
		}

		alpSkinName.cur_data = [{scale: 0.5, bold: true, text: display_name}];
		alpSkinName.loadText();
		alpSkinName.x = 1070 - (alpSkinName.width / 2);

		arrowsgroup.members[2].setPosition(alpSkinName.x - arrowsgroup.members[0].width - 5, alpSkinName.y + (alpSkinName.height / 2) - (arrowsgroup.members[0].height / 2));
		arrowsgroup.members[3].setPosition(alpSkinName.x + alpSkinName.width + 5, alpSkinName.y + (alpSkinName.height / 2) - (arrowsgroup.members[1].height / 2));

		alpReloadCharacter.visible = true;
		canChange = true;
	}

	function updateCharacter():Void {
		character.color = 0xffffff;
		character.setupByName(character_list[curCharacter], curSkin);
		if(Skins.checkLocked(character_list[curCharacter], curSkin)){character.color = FlxColor.BLACK;}

		alpReloadCharacter.visible = false;
		canChange = false;
	}
}