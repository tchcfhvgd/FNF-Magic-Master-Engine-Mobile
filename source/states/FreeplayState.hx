package states;

import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxG;
import haxe.Json;

import FlxCustom.FlxUICustomNumericStepper;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomList;
import Song.SongStuffManager;
import Song.SongsData;
import Song.ItemSong;
import Song.SwagSong;
import MagicStuff;

import states.PlayState.SongListData;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using SavedFiles;
using StringTools;

class FreeplayState extends MusicBeatState {
	public static var curSong:Int = 0;
	public static var curDiff:String = "Normal";
	public static var curCat:String = "Normal";

	public var onSelect:SwagSong->Void = null;

	var songList:Array<ItemSong> = [];

	var background:FlxSprite;

	var grpSongs:FlxTypedGroup<Alphabet>;
    var grpArrows:FlxTypedGroup<FlxSprite>;
	
	var infoAlpha:Alphabet;
    var scoreAlpha:Alphabet;
	
    var difficulty:FlxSprite;
    var category:FlxSprite;

    var curOption:Int = 1;

	public function new(?onConfirm:String, ?onBack:String, ?_onSelect:SwagSong->Void){
		this.onSelect = _onSelect;
		super(onConfirm, onBack);
	}

	override function create(){
		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)){FlxG.sound.playMusic(Paths.music('freakyMenu').getSound());}
		if(onSelect == null){onSelect = chooseSong;}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Selecting', '[Freeplay]');
		MagicStuff.setWindowTitle('Freeplay', 1);
		#end

		songList = SongStuffManager.getSongList();
		
		background = new FlxSprite().loadGraphic(Paths.image('menuBG').getGraphic());
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.scrollFactor.set(0, 0);
        background.color = 0xfffffd75;
		background.screenCenter();
		add(background);
		
		var back_1:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 100, [FlxColor.BLACK, FlxColor.BLACK, 0x00000000]);
		add(back_1);
		
		var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 100, [0x00000000, FlxColor.BLACK, 0x00000000]);
		gradient.y = (FlxG.height / 2) - (gradient.height / 2);
		add(gradient);
		
		grpSongs = new FlxTypedGroup<Alphabet>();
		for(i in 0...songList.length){
			var songText:Alphabet = new Alphabet(0, 0, [{bold: true, text: Paths.getFileName(songList[i].song)}]);

			if(Highscore.checkLock(songList[i].keyLock)){
				var cText:String = "";
				while(cText.length < songText.text.length){cText = '${cText}?';}
				songText.text = cText; songText.loadText();
			}

			songText.screenCenter(X);
			songText.ID = i;
			
			grpSongs.add(songText);
		}
		add(grpSongs);
		
        difficulty = new FlxSprite(FlxG.width + 1000, 0);
        add(difficulty);

        category = new FlxSprite(-1000, 0);
        add(category);
		
        //Adding Arrows
        grpArrows = new FlxTypedGroup<FlxSprite>();
        for(i in 0...2){
            var arrow_1:FlxSprite = new FlxSprite();
            arrow_1.frames = Paths.image('arrows').getAtlas();
            arrow_1.animation.addByPrefix('idle', 'Arrow Idle');
            arrow_1.animation.addByPrefix('over', 'Arrow Over', false);
            arrow_1.animation.addByPrefix('hit', 'Arrow Hit', false);
            arrow_1.scale.set(0.3, 0.3);
            arrow_1.updateHitbox();
            
            switch(i){
                case 0:{arrow_1.angle = 90;}
                case 1:{arrow_1.angle = 270;}
            }

			arrow_1.screenCenter(X);

            grpArrows.add(arrow_1);
            arrow_1.ID = i;
        }
        add(grpArrows);
		
        infoAlpha = new Alphabet(0, 30, LangSupport.getText("freeplay_info_1"));
        add(infoAlpha);
		
        scoreAlpha = new Alphabet(0, 0, [{text:"PlaceHolder"}]);
        add(scoreAlpha);

		changeSong();
		
		super.create();
	}

	override function update(elapsed:Float){
		MagicStuff.sortMembersByY(cast grpSongs, (FlxG.height / 2) - (grpSongs.members[curSong].height / 2), curSong, 25);

		if(canControlle){
			if(principal_controls.checkAction("Menu_Left", JUST_PRESSED)){changeOption(-1);}
			if(principal_controls.checkAction("Menu_Right", JUST_PRESSED)){changeOption(1);}

			switch(curOption){
				case 0:{
					if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeCateg(-1);}
					if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeCateg(1);}
	
					for(a in grpArrows.members){MagicStuff.lerpX(cast a, category.x+(category.width/2)-(a.width/2));}	
					grpArrows.members[0].y = category.y - grpArrows.members[0].height - 5;
					grpArrows.members[1].y = category.y + category.height + 5;

					MagicStuff.lerpX(cast difficulty, FlxG.width + 10);
					MagicStuff.lerpX(cast category, 250 - (category.width / 2));
					for(s in grpSongs){s.x = FlxMath.lerp(s.x, FlxG.width - s.width - 5, 0.1);}
				}
				case 1:{
					if(principal_controls.checkAction("Menu_Up", JUST_PRESSED) || FlxG.mouse.wheel > 0){changeSong(-1);}
					if(principal_controls.checkAction("Menu_Down", JUST_PRESSED) || FlxG.mouse.wheel < 0){changeSong(1);}
					if(FlxG.mouse.justPressed){for(btn in grpSongs){if(FlxG.mouse.overlaps(btn)){changeSong(btn.ID, true); break;}}}
	
					for(a in grpArrows.members){MagicStuff.lerpX(cast a, (FlxG.width / 2) - (a.width / 2));}
					grpArrows.members[0].y = (FlxG.height / 2) - (grpSongs.members[curSong].height / 2) - grpArrows.members[0].height - 5;
					grpArrows.members[1].y = (FlxG.height / 2) + (grpSongs.members[curSong].height / 2) + 5;
					
					MagicStuff.lerpX(cast difficulty, FlxG.width - (difficulty.width / 2));
					MagicStuff.lerpX(cast category, -(category.width / 2));
					for(s in grpSongs){s.x = FlxMath.lerp(s.x, (FlxG.width / 2) - (s.width / 2), 0.1);}
				}
				case 2:{
					if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeDiff(-1);}
					if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeDiff(1);}
					
					for(a in grpArrows.members){MagicStuff.lerpX(cast a, difficulty.x+(difficulty.width/2)-(a.width/2));}	
					grpArrows.members[0].y = difficulty.y - grpArrows.members[0].height - 5;
					grpArrows.members[1].y = difficulty.y + difficulty.height + 5;
					
					MagicStuff.lerpX(cast difficulty, (FlxG.width - 250) - (difficulty.width / 2));
					MagicStuff.lerpX(cast category, -category.width - 10);
					for(s in grpSongs){s.x = FlxMath.lerp(s.x, 5, 0.1);}
				}
			}

			if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){selectSong();}
		}
		
		super.update(elapsed);		
	}
	
    function changeOption(value:Int = 0, force:Bool = false):Void {
		curOption += value; if(force){curOption = value;}

        if(curOption > 2){curOption = 0;}
        if(curOption < 0){curOption = 2;}
	}
	
	var cur_tween_color:FlxTween;
	public function changeSong(change:Int = 0, force:Bool = false):Void {
		curSong += change; if(force){curSong = change;}

		if(curSong < 0){curSong = songList.length - 1;}
		if(curSong >= songList.length){curSong = 0;}

		for(s in grpSongs){s.alpha = 0.5;}
		grpSongs.members[curSong].alpha = 1;

		if(cur_tween_color != null){cur_tween_color.cancel();}
		cur_tween_color = FlxTween.color(background, 0.5, background.color, FlxColor.fromString(songList[curSong].color), {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){cur_tween_color = null;}});

		changeCateg();
	}
	
    function changeCateg(value:Int = 0, force:Bool = false):Void {
        var cat_arr:Array<Dynamic> = songList[curSong].categories;
        var cur_categ:Int = 0; for(i in 0...cat_arr.length){if(cat_arr[i].category == curCat){cur_categ = i;}}

		cur_categ += value; if(force){cur_categ = value;}

		if(cur_categ < 0){cur_categ = cat_arr.length - 1;}
		if(cur_categ >= cat_arr.length){cur_categ = 0;}

        curCat = cat_arr[cur_categ].category;

        category.loadGraphic(Paths.image('categories/${Paths.getFileName(curCat.toLowerCase(), true)}').getGraphic());
        category.y = (FlxG.height / 2) - (category.height / 2);
        
        changeDiff();
    }

    function changeDiff(value:Int = 0, force:Bool = false):Void {
        var cur_categ:Int = 0; for(i in 0...songList[curSong].categories.length){if(songList[curSong].categories[i].category == curCat){cur_categ = i;}}
        var cat_diffs:Array<Dynamic> = songList[curSong].categories[cur_categ].difficults;
        var cur_diff:Int = 0; for(i in 0...cat_diffs.length){if(cat_diffs[i] == curDiff){cur_diff = i;}}

		cur_diff += value; if(force){cur_diff = value;}

		if(cur_diff < 0){cur_diff = cat_diffs.length - 1;}
		if(cur_diff >= cat_diffs.length){cur_diff = 0;}

        curDiff = cat_diffs[cur_diff];

        difficulty.loadGraphic(Paths.image('difficulties/${Paths.getFileName(curDiff.toLowerCase(), true)}').getGraphic());
        difficulty.y = (FlxG.height / 2) - (difficulty.height / 2);
		
		var song_score:Float = Highscore.getScore(Paths.getFileName(songList[curSong].song, true), curDiff, curCat);
        scoreAlpha.cur_data = [{scale:0.3, bold:true, text:'${LangSupport.getText('gmp_score')}: ${song_score}'}];
        scoreAlpha.loadText(); scoreAlpha.screenCenter(X);
		
		FlxG.sound.play(Paths.sound("scrollMenu").getSound());
    }

	function selectSong():Void {
		FlxG.sound.play(Paths.sound("confirmMenu").getSound());
		
		var songInput:String = Song.fileSong(songList[curSong].song, curCat, curDiff);
		var songdata:SwagSong = Song.loadFromJson(songInput);
		onSelect(songdata);
	}
	function chooseSong(_song:SwagSong):Void {
		SongListData.loadAndPlaySong(_song, FlxG.keys.pressed.SHIFT);
	}
}