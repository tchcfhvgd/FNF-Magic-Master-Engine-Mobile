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
import haxe.DynamicAccess;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import io.newgrounds.NG;
import flixel.FlxCamera;
import flixel.FlxG;
import haxe.Json;

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

class CreditsState extends MusicBeatState {
    var credits_stuff:Map<String, Array<Dynamic>> = [];

	var alphaGroup:FlxTypedGroup<Alphabet>;

	var curCredit:Int = 0;

	override function create(){
		FlxG.mouse.visible = false;

        for(file in Paths.readFile('assets/data/credits.json')){
            var file_content:DynamicAccess<Dynamic> = Json.parse(Paths.getText(file));
            for(key in file_content.keys()){
				if(credits_stuff.exists(key)){
					for(i in cast(file_content.get(key), Array<Dynamic>)){
						credits_stuff.get(key).push(i);
					}
				}else{
					credits_stuff.set(key, file_content.get(key));
				}
			}
        }

        trace(credits_stuff);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the credits", null);
		MagicStuff.setWindowTitle('In the credits');
		#end
		
		var background = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.scrollFactor.set(0, 0);
        background.color = 0xfffffd75;
		background.screenCenter();
		add(background);

		alphaGroup = new FlxTypedGroup<Alphabet>();

		var cur_height:Float = 0;
		for(cat in credits_stuff.keys()){
			var alpha_cat:Alphabet = new Alphabet(0, cur_height, [{bold: true, scale: 0.7, text: cat}]);
			alpha_cat.screenCenter(X);
			alphaGroup.add(alpha_cat);

			cur_height += alpha_cat.height + 10;

			for(credit in credits_stuff[cat]){
				var cur_credit_alp:Alphabet = new Alphabet(0, cur_height, [{color: 0x000000, scale: 0.7, text: '${credit.Name} '}, {image: 'credits/${credit.Icon}'}]);
				cur_credit_alp.screenCenter(X);
				alphaGroup.add(cur_credit_alp);

				cur_height += cur_credit_alp.height + 5;
			}
		}

		add(alphaGroup);
		
        var shape_1:FlxSprite = new FlxSprite(0, FlxG.height - 60).makeGraphic(FlxG.width, 5, FlxColor.BLACK); add(shape_1);
        var shape_2:FlxSprite = new FlxSprite(0, FlxG.height - 50).makeGraphic(FlxG.width, 50, FlxColor.BLACK); add(shape_2);

		super.create();
	}

	override function update(elapsed:Float):Void {
		MagicStuff.sortMembersByY(cast alphaGroup, (FlxG.height / 2) - (alphaGroup.members[curCredit].height / 2), curCredit, 50);

		if(canControlle){
			if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeCredit(-1);}
			if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeCredit(1);}
		}
		
        super.update(elapsed);
	}

	function changeCredit(value:Int = 0, force:Bool = false):Void {
		curCredit += value; if(force){curCredit = value;}

		if(curCredit >= alphaGroup.length){curCredit = 0;}
		if(curCredit < 0){curCredit = alphaGroup.length - 1;}
	}
}