package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIButton;
import flixel.input.mouse.FlxMouse;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
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

using SavedFiles;
using StringTools;

class StoryMenuState extends MusicBeatState {
    public static var curOption:Int = 1;
	public static var curWeek:Int = 0;
	public var curDiff:String = "Normal";
	public var curCat:String = "Normal";

    public var week_image:FlxSprite;
    public var weeks:Array<ItemWeek> = [];

    public var grpWeeks:FlxTypedGroup<FlxSprite>;
    public var grpArrows:FlxTypedGroup<FlxSprite>;

    public var difficulty:FlxSprite;
    public var category:FlxSprite;
    
	var infoAlpha:Alphabet;
    var titleAlpha:Alphabet;
    var scoreAlpha:Alphabet;

	override function create(){
		FlxG.mouse.visible = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a Week", null);
		MagicStuff.setWindowTitle('Selecting a Week');
		#end

        weeks = SongStuffManager.getWeekList();

        var bg = new FlxSprite().loadGraphic(Paths.image('menuBG').getGraphic());
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.color = FlxColor.GRAY;
		bg.screenCenter();
		add(bg);

        var shape_1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 60, FlxColor.BLACK);
        add(shape_1);

        week_image = new FlxSprite(0, 60);
        add(week_image);

        titleAlpha = new Alphabet(0, 0, [{text:"PlaceHolder"}]);
        add(titleAlpha);

        scoreAlpha = new Alphabet(0, 0, [{text:"PlaceHolder"}]);
        add(scoreAlpha);

        var shape_2:FlxSprite = new FlxSprite(0, 65).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
        add(shape_2);

        var shape_3:FlxSprite = new FlxSprite(0, FlxG.height - 230).makeGraphic(FlxG.width, 5, FlxColor.BLACK);
        add(shape_3);

        var shape_4:FlxSprite = new FlxSprite(0, FlxG.height - 220).makeGraphic(FlxG.width, 220, FlxColor.BLACK);
        add(shape_4);
		
		super.create();

        var camWeeks:FlxCamera = new FlxCamera(0, FlxG.height - 220, FlxG.width, 220);
		camWeeks.bgColor.alpha = 0;
        camWeeks.focusOn(FlxPoint.get((FlxG.width / 2), (FlxG.height - 110)));
		FlxG.cameras.add(camWeeks);

        grpWeeks = new FlxTypedGroup<FlxSprite>();
        for(week in weeks){
            var spr_week:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weeks/${week.name}').getGraphic());
            spr_week.screenCenter(X);
            grpWeeks.add(spr_week);
        }
        grpWeeks.cameras = [camWeeks];
        add(grpWeeks);

        difficulty = new FlxSprite();
        difficulty.cameras = [camWeeks];
        add(difficulty);

        category = new FlxSprite();
        category.cameras = [camWeeks];
        add(category);
        
        var shape_5:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 110, [FlxColor.BLACK, 0x00000000]);
        shape_5.setPosition(0, FlxG.height - 220);
        shape_5.cameras = [camWeeks];
        add(shape_5);
        
        var shape_6:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 110, [0x00000000, FlxColor.BLACK]);
        shape_6.setPosition(0, FlxG.height - 110);
        shape_6.cameras = [camWeeks];
        add(shape_6);

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

            grpArrows.add(arrow_1);
            arrow_1.ID = i;
        }
        grpArrows.cameras = [camWeeks];
        add(grpArrows);

        infoAlpha = new Alphabet(0, 0, LangSupport.getText("story_info_1"));
        infoAlpha.cameras = [camWeeks];
        infoAlpha.y = FlxG.height - 220;
        add(infoAlpha);
        
		changeWeek();
	}

	override function update(elapsed:Float){		
		super.update(elapsed);

        if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED)){chooseWeek();}

        if(principal_controls.checkAction("Menu_Left", JUST_PRESSED)){changeOption(-1);}
        if(principal_controls.checkAction("Menu_Right", JUST_PRESSED)){changeOption(1);}

		MagicStuff.sortMembersByY(cast grpWeeks, (FlxG.height - 110) - (grpWeeks.members[curWeek].height / 2), curWeek);

        switch(curOption){
            case 0:{
                if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeCateg(-1);}
                if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeCateg(1);}

                for(a in grpArrows.members){MagicStuff.lerpX(cast a, 250);}

                grpArrows.members[0].y = category.y - grpArrows.members[0].height - 5;
                grpArrows.members[1].y = category.y + category.height + 5;
            }
            case 1:{
                if(principal_controls.checkAction("Menu_Up", JUST_PRESSED) || FlxG.mouse.wheel > 0){changeWeek(-1);}
                if(principal_controls.checkAction("Menu_Down", JUST_PRESSED) || FlxG.mouse.wheel < 0){changeWeek(1);}

                for(a in grpArrows.members){MagicStuff.lerpX(cast a, (FlxG.width / 2));}
                grpArrows.members[0].y = grpWeeks.members[curWeek].y - grpArrows.members[0].height - 5;
                grpArrows.members[1].y = grpWeeks.members[curWeek].y + grpWeeks.members[curWeek].height + 5;
            }
            case 2:{
                if(principal_controls.checkAction("Menu_Up", JUST_PRESSED)){changeDiff(-1);}
                if(principal_controls.checkAction("Menu_Down", JUST_PRESSED)){changeDiff(1);}

                for(a in grpArrows.members){MagicStuff.lerpX(cast a, (FlxG.width - 250));}

                grpArrows.members[0].y = difficulty.y - grpArrows.members[0].height - 5;
                grpArrows.members[1].y = difficulty.y + difficulty.height + 5;
            }
        }
	}

    function changeOption(value:Int = 0, force:Bool = false):Void {
		curOption += value; if(force){curOption = value;}

        if(curOption > 2){curOption = 0;}
        if(curOption < 0){curOption = 2;}
	}

	function changeWeek(value:Int = 0, force:Bool = false):Void {
		curWeek += value; if(force){curWeek = value;}

		if(curWeek < 0){curWeek = grpWeeks.members.length - 1;}
		if(curWeek >= grpWeeks.members.length){curWeek = 0;}

        for(w in grpWeeks.members){w.alpha = 0.5;}
        grpWeeks.members[curWeek].alpha = 1;

        titleAlpha.cur_data = [{scale:0.6, bold:true, text:weeks[curWeek].title}];
        titleAlpha.loadText();
        titleAlpha.screenCenter(X);

        week_image.loadGraphic(Paths.image('story_menu/${weeks[curWeek].image}'));
        week_image.setGraphicSize(FlxG.width);
        week_image.screenCenter(X);

        changeCateg();
	}
    
    function changeCateg(value:Int = 0, force:Bool = false):Void {
        var cat_arr:Array<Dynamic> = weeks[curWeek].categories;
        var cur_categ:Int = 0; for(i in 0...cat_arr.length){if(cat_arr[i].category == curCat){cur_categ = i;}}

		cur_categ += value; if(force){cur_categ = value;}

		if(cur_categ < 0){cur_categ = cat_arr.length - 1;}
		if(cur_categ >= cat_arr.length){cur_categ = 0;}

        curCat = cat_arr[cur_categ].category;

        category.loadGraphic(Paths.image('categories/${Paths.getFileName(curCat.toLowerCase(), true)}').getGraphic());
        category.setPosition(250 - (category.width / 2), (FlxG.height - 110) - (category.height / 2));
        
        changeDiff();
    }

    function changeDiff(value:Int = 0, force:Bool = false):Void {
        var cur_categ:Int = 0; for(i in 0...weeks[curWeek].categories.length){if(weeks[curWeek].categories[i].category == curCat){cur_categ = i;}}
        var cat_diffs:Array<Dynamic> = weeks[curWeek].categories[cur_categ].difficults;
        var cur_diff:Int = 0; for(i in 0...cat_diffs.length){if(cat_diffs[i] == curDiff){cur_diff = i;}}

		cur_diff += value; if(force){cur_diff = value;}

		if(cur_diff < 0){cur_diff = cat_diffs.length - 1;}
		if(cur_diff >= cat_diffs.length){cur_diff = 0;}

        curDiff = cat_diffs[cur_diff];

        difficulty.loadGraphic(Paths.image('difficulties/${Paths.getFileName(curDiff.toLowerCase(), true)}').getGraphic());
        difficulty.setPosition((FlxG.width - 250) - (difficulty.width / 2), (FlxG.height - 110) - (difficulty.height / 2));
        
        scoreAlpha.cur_data = [{scale:0.4, bold:true, text:'${LangSupport.getText('gmp_score')}: ${Highscore.getWeekScore(weeks[curWeek].name, curDiff, curCat)}'}];
        scoreAlpha.loadText();
    }

    function chooseWeek():Void {
        SongListData.resetVariables();
        SongListData.loadWeek(weeks[curWeek], curCat, curDiff);
        SongListData.playSong();
    }
}
