package;

import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import Sprite_Input;
import Sprite_UI_MENU.Sprite_UI_MENU_TAB;
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
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState{
	var _file:FileReference;

	public var playClaps:Array<Bool> = [false];

	public var snap:Int = 1;

	var curSection:Int = 0;
	var curStrum:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var bgbpmTxt:FlxSprite;

	var camFollow:FlxObject;
	var strumLine:FlxSprite;
	var spriteLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var writingNotesText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var gridGroup:FlxTypedGroup<FlxSprite>;
	var gridGroupBlackLine:FlxTypedGroup<FlxSprite>;

	var backGrid:FlxTypedGroup<FlxSprite>;
	var gridBG:FlxSprite;

	var TABMENU:Sprite_UI_MENU;
	var TABSTRUM:Sprite_UI_MENU;

	var song_title:FlxInputText;
	var song_diff_title:FlxInputText;
	var song_cat_title:FlxInputText;

	var stepperLength:FlxUINumericStepper;
	var stepperSectionBPM:FlxUINumericStepper;
	var stepperFocusToStrumm:FlxUINumericStepper;
	var stepperCharToFocus:FlxUINumericStepper;
	var stchr_ChangeBPM:Sprite_Input;
	var stchr_AltAnim:Sprite_Input;
	var stchr_ChangeSing:Sprite_Input;

	var gridStuffGroup:FlxTypedGroup<FlxTypedGroup<Dynamic>>;
	var btn_AddStrum:Sprite_Input;
	var btn_DelStrum:Sprite_Input;

	var copiedStrum:Array<Dynamic> = [];

	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var vocals:FlxSound;

	override function create()
	{
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				difficulty: 'Hard',
				category: 'Normal',

				bpm: 150,
				speed: 1,

				needsVoices: true,
				singleVoices: false,

				validScore: false,

				strumToPlay: 0,

				uiStyle: "Normal",

				stage: 'stage',
				characters: [
					["Girlfriend", [140, 210], false, "Default", "GF"],
					["Fliqpy", [140, 210], true, "Default", "NORMAL"],
					["Boyfriend", [140, 210], false, "Default", "NORMAL"]
				],
				
				generalSection: [
					{
						bpm: 150,
						changeBPM: false,

						lengthInSteps: 16,

						strumToFocus: 0,
						charToFocus: 0
					}
				],
				sectionStrums: [
					{
						keys: 4,
						noteStyle: "Default",
						charToSing: [0],
						notes: [
							{
								charToSing: [0],
								changeSing: false,

								keys: 4,
								changeKeys: false,

								altAnim: false,

								sectionNotes: []
							}
						]
					}
				]
			};
		}

		var background:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('UI_Assets/Land-Cute'));
		background.setGraphicSize(Std.int(FlxG.width));
		background.antialiasing = true;
		background.scrollFactor.set();
		background.screenCenter();
		add(background);

		var blackBorder:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		blackBorder.scrollFactor.set();
		blackBorder.alpha = 0.3;
		add(blackBorder);

		Sprite_Input.INPUTS = new FlxTypedGroup<Sprite_Input>();

		TABMENU = new Sprite_UI_MENU(40, 0, 160, FlxG.height);
		TABMENU.scrollFactor.set();

		TABSTRUM = new Sprite_UI_MENU(FlxG.width - 160, 0, 160, FlxG.height);
		TABSTRUM.scrollFactor.set();
		TABSTRUM.curTAB = "TAB_CurSection";

		backGrid = new FlxTypedGroup<FlxSprite>();
		add(backGrid);

		gridStuffGroup = new FlxTypedGroup<FlxTypedGroup<Dynamic>>();
		add(gridStuffGroup);

		gridGroup = new FlxTypedGroup<FlxSprite>();
		add(gridGroup);

		gridGroupBlackLine = new FlxTypedGroup<FlxSprite>();
		add(gridGroupBlackLine);

		for(i in 0..._song.sectionStrums.length){
			playClaps.resize(_song.sectionStrums.length);

			var newGroupButtoms = new FlxTypedGroup<Dynamic>();

			var newGrid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
			newGrid.x += (GRID_SIZE * 4) * i;
			newGrid.ID = i;

			var nerBackGrid = new FlxSprite((0 - GRID_SIZE) + (i * newGrid.width), 0).makeGraphic(GRID_SIZE * 6,FlxG.height,FlxColor.BLACK);
			nerBackGrid.scrollFactor.set(1, 0);
			backGrid.add(nerBackGrid);

			var btn_StrumToFocus = new Sprite_Input(newGrid.x + (GRID_SIZE * 1.5), newGrid.y + newGrid.height, "TOOL_FocusStrum-" + i, "Radio", "FOCUS");
			btn_StrumToFocus.loadGraphic(Paths.image('UI_Assets/delStrum'));
			btn_StrumToFocus.setGraphicSize(GRID_SIZE);
			btn_StrumToFocus.updateHitbox();
			newGroupButtoms.add(btn_StrumToFocus);

			var btn_Claps = new Sprite_Input(newGrid.x + (GRID_SIZE / 2), newGrid.y + newGrid.height, "TOOL_StrumClaps-" + i, "Switcher");
			btn_Claps.loadGraphic(Paths.image('UI_Assets/delStrum'));
			btn_Claps.setGraphicSize(Std.int(GRID_SIZE / 2));
			btn_Claps.updateHitbox();
			btn_Claps.pressed = playClaps[i];
			newGroupButtoms.add(btn_Claps);

			gridStuffGroup.add(newGroupButtoms);
			gridGroup.add(newGrid);

			var gridBlackLine = new FlxSprite(newGrid.x + newGrid.width - 1).makeGraphic(2, Std.int(newGrid.height), FlxColor.BLACK);
			gridGroupBlackLine.add(gridBlackLine);
		}

		if(curStrum >= gridGroup.length){curStrum = gridGroup.length - 1;}
		gridBG = gridGroup.members[curStrum];

		spriteLine = new FlxSprite(0, 50).makeGraphic(Std.int(gridBG.width * _song.sectionStrums.length), 4);
		add(spriteLine);

		btn_AddStrum = new Sprite_Input(0, 0, "TOOL_AddStrum", "Buttom");
		btn_AddStrum.loadGraphic(Paths.image('UI_Assets/addStrum'));
		btn_AddStrum.setGraphicSize(GRID_SIZE);
		btn_AddStrum.updateHitbox();
		add(btn_AddStrum);

		btn_DelStrum = new Sprite_Input(FlxG.width / 2 - (GRID_SIZE * 3), 0 - GRID_SIZE, "TOOL_DelStrum", "Buttom");
		btn_DelStrum.loadGraphic(Paths.image('UI_Assets/delStrum'));
		btn_DelStrum.scrollFactor.set(0, 1);
		btn_DelStrum.setGraphicSize(GRID_SIZE);
		btn_DelStrum.updateHitbox();
		add(btn_DelStrum);

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
		strumLine.visible = false;
		add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camFollow);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		bpmTxt = new FlxText(0, 0, 0, "", 16);
		bpmTxt.alignment = CENTER;
		bpmTxt.scrollFactor.set();		

		bgbpmTxt = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), FlxColor.BLACK);
		bgbpmTxt.scrollFactor.set();		

		add(TABMENU);
		add(TABMENU.TABS);

		add(TABSTRUM);
		add(TABSTRUM.TABS);

		add(bgbpmTxt);
		add(bpmTxt);

		addUI();

		loadSong(song_title.text, song_cat_title.text);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		super.create();
	}

	function addUI(){
		var blackSprite = new FlxSprite(0,0).makeGraphic(GRID_SIZE, Std.int(FlxG.height), FlxColor.BLACK);
		blackSprite.scrollFactor.set();
		add(blackSprite);

		var up_buttons_Array:Array<Dynamic> = [
			["SONG_Save", Paths.image('UI_Assets/delStrum'), "Buttom", false],
			["", "", "", false],
			["TAB_General", Paths.image('UI_Assets/delStrum'), "Radio", true],
			["TAB_SecGeneral", Paths.image('UI_Assets/delStrum'), "Radio", true],
			["", "", "", false],
			["TAB_Assets", Paths.image('UI_Assets/delStrum'), "Radio", true]
		];

		var down_buttons_Array:Array<Dynamic> = [
			["TOOL_MuteInst", Paths.image('UI_Assets/delStrum'), "Switcher", false]
		];

		for(i in 0...up_buttons_Array.length){
			var buttom = new Sprite_Input(2.5, 2.5 + GRID_SIZE * i, up_buttons_Array[i][0], up_buttons_Array[i][2], up_buttons_Array[i][2] == "Radio" ? "TABS" : "NONE");
			buttom.loadGraphic(up_buttons_Array[i][1]);
			buttom.setGraphicSize(GRID_SIZE - 5);
			buttom.updateHitbox();
			buttom.scrollFactor.set();

			if(up_buttons_Array[i][0] == ""){buttom.isVisible = false;}

			if(up_buttons_Array[i][3]){
				addUiTAB(up_buttons_Array[i][0]);
			}

			add(buttom);
		}

		for(i in 0...down_buttons_Array.length){
			var buttom = new Sprite_Input(2.5, FlxG.height - 2.5 - GRID_SIZE - (GRID_SIZE * i), down_buttons_Array[i][0], down_buttons_Array[i][2], up_buttons_Array[i][2] == "Radio" ? "TABS" : "NONE");
			buttom.loadGraphic(down_buttons_Array[i][1]);
			buttom.setGraphicSize(GRID_SIZE - 5);
			buttom.updateHitbox();
			buttom.scrollFactor.set();

			if(down_buttons_Array[i][0] == ""){buttom.isVisible = false;}

			add(buttom);
		}

		addUiTAB("TAB_CurSection");
	}

	function addUiTAB(TAB:String){
		var newTAB = new Sprite_UI_MENU_TAB(TAB);

		switch(TAB){
			case "TAB_General":{
				var tab_title = new FlxText(0, 0, TABMENU.width, "GENERAL", 16);
				tab_title.alignment = CENTER;
				newTAB.add(tab_title);

				//Song Name
				var song_text = new FlxText(0, 35, TABMENU.width, "Song:", 12);
				newTAB.add(song_text);

				song_title = new FlxInputText(5, Std.int(song_text.y + 20), Std.int(TABMENU.width - 10), _song.song, 8);
				newTAB.add(song_title);

				var song_diff_text = new FlxText(0, Std.int(song_title.y + 25), TABMENU.width, "Difficulty:", 12);
				newTAB.add(song_diff_text);

				song_diff_title = new FlxInputText(5, Std.int(song_diff_text.y + 20), Std.int(TABMENU.width - 10), _song.difficulty, 8);
				newTAB.add(song_diff_title);

				var song_cat_text = new FlxText(0, Std.int(song_diff_title.y + 25), TABMENU.width, "Category:", 12);
				newTAB.add(song_cat_text);

				song_cat_title = new FlxInputText(5, Std.int(song_cat_text.y + 20), Std.int(TABMENU.width - 10), _song.category, 8);
				newTAB.add(song_cat_title);
				
				//Reload JSON
				var btn_ReloadJSON:FlxButton = new FlxButton(5, song_cat_title.y + 25, "Reload JSON", function(){
					loadJson(song_title.text, song_diff_title.text, song_cat_title.text);
				});
				newTAB.add(btn_ReloadJSON);

				//Reload Audio
				var btn_ReloadAudio:FlxButton = new FlxButton(5, btn_ReloadJSON.y + 25, "Reload Audio", function(){
					loadSong(song_title.text , song_cat_title.text);
				});
				newTAB.add(btn_ReloadAudio);
				
				//Has Voice
				var btn_CheckVoices = new Sprite_Input(5, btn_ReloadAudio.y + 30, "SONG_HasVoices", "Switcher");
				btn_CheckVoices.loadGraphic(Paths.image('UI_Assets/delStrum'));
				btn_CheckVoices.setGraphicSize(Std.int(GRID_SIZE / 2));
				btn_CheckVoices.updateHitbox();
				btn_CheckVoices.pressed = _song.needsVoices;
				newTAB.add(btn_CheckVoices);

				var txt_CheckVoices = new FlxText(btn_CheckVoices.x + btn_CheckVoices.width + 5, btn_CheckVoices.y, 0, "Has Voices", 8);
				newTAB.add(txt_CheckVoices);

				//Has Single
				var btn_CheckSingle = new Sprite_Input(5, btn_CheckVoices.y + 25, "SONG_HasSingle", "Switcher");
				btn_CheckSingle.loadGraphic(Paths.image('UI_Assets/delStrum'));
				btn_CheckSingle.setGraphicSize(Std.int(GRID_SIZE / 2));
				btn_CheckSingle.updateHitbox();
				btn_CheckSingle.pressed = _song.singleVoices;
				newTAB.add(btn_CheckSingle);

				var txt_CheckSingle = new FlxText(btn_CheckSingle.x + btn_CheckSingle.width + 5, btn_CheckSingle.y, 0, "Has Single Voices", 8);
				newTAB.add(txt_CheckSingle);

				//Player
				var stepperPLAYER:FlxUINumericStepper = new FlxUINumericStepper(5, btn_CheckSingle.y + 35, 1, 0, 0, 99999, 1);
				stepperPLAYER.value = _song.strumToPlay;
				stepperPLAYER.name = 'song_player';
				newTAB.add(stepperPLAYER);	
				var txt_PLAYER = new FlxText(stepperPLAYER.x + stepperPLAYER.width + 5, stepperPLAYER.y, 'Strum to Play');
				newTAB.add(txt_PLAYER);

				//BPM
				var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(5, stepperPLAYER.y + 35, 0.1, 1, 1.0, 5000.0, 1);
				stepperBPM.value = Conductor.bpm;
				stepperBPM.name = 'song_bpm';
				newTAB.add(stepperBPM);	
				var txt_BPM = new FlxText(stepperBPM.x + stepperBPM.width + 5, stepperBPM.y, 'BPM');
				newTAB.add(txt_BPM);

				//Speed
				var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(5, stepperBPM.y + 25, 0.1, 1, 0.1, 10, 1);
				stepperSpeed.value = _song.speed;
				stepperSpeed.name = 'song_speed';
				newTAB.add(stepperSpeed);
				var stepperSpeedLabel = new FlxText(stepperSpeed.x + stepperSpeed.width + 5, stepperSpeed.y, 'Scroll Speed');
				newTAB.add(stepperSpeedLabel);

				//ShiftNotes
				var txt_ShiftNotes = new FlxText(stepperSpeed.x, stepperSpeed.y + 35, 'Shift Notes by: ');
				newTAB.add(txt_ShiftNotes);

				var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(5, txt_ShiftNotes.y + 17, 1, 0, -1000, 1000, 0);
				newTAB.add(stepperShiftNoteDial);
				var txt_ShiftSection = new FlxText(stepperShiftNoteDial.x + stepperShiftNoteDial.width + 5, stepperShiftNoteDial.y, '(Section)');
				newTAB.add(txt_ShiftSection);

				var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(5, stepperShiftNoteDial.y + 17, 1, 0, -1000, 1000, 0);
				newTAB.add(stepperShiftNoteDialstep);
				var txt_ShiftStep = new FlxText(stepperShiftNoteDialstep.x + stepperShiftNoteDialstep.width + 5, stepperShiftNoteDialstep.y, '(Step)');
				newTAB.add(txt_ShiftStep);

				var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(5, stepperShiftNoteDialstep.y + 17, 1, 0, -1000, 1000, 2);
				newTAB.add(stepperShiftNoteDialms);
				var txt_ShiftMS = new FlxText(stepperShiftNoteDialms.x + stepperShiftNoteDialms.width + 5, stepperShiftNoteDialms.y, '(MS)');
				newTAB.add(txt_ShiftMS);

				var btn_ShiftNotes:FlxButton = new FlxButton(5 , stepperShiftNoteDialms.y + 18, 'Shift Notes', function(){
					shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value));
				});
				newTAB.add(btn_ShiftNotes);

				var stepperSwapAll:FlxUINumericStepper = new FlxUINumericStepper(5, btn_ShiftNotes.y + 35, 1, 0, -1000, 1000, 2);
				stepperSwapAll.name = 'strum_all';
				newTAB.add(stepperSwapAll);
				var txt_SwapAll = new FlxText(stepperSwapAll.x + stepperSwapAll.width + 5, stepperSwapAll.y, 'All Strum to Swap');
				newTAB.add(txt_SwapAll);

				var btn_SwapStrum:FlxButton = new FlxButton(5, stepperSwapAll.y + 18, "Swap Strum", function(){
					var strum1 = _song.sectionStrums[curStrum];
					var strum2 = _song.sectionStrums[Std.int(stepperSwapAll.value)];

					_song.sectionStrums[curStrum] = strum2;
					_song.sectionStrums[Std.int(stepperSwapAll.value)] = strum1;

					updateGrid();
				});
				newTAB.add(btn_SwapStrum);

				//Clear Notes
				var btn_ClearNotes:FlxButton = new FlxButton(5, btn_SwapStrum.y + 35, "Clear Notes", function(){
					for(i in _song.sectionStrums){
						for(ii in i.notes){
							ii.sectionNotes = [];
						}
					}
					updateGrid();
				});
				newTAB.add(btn_ClearNotes);

				var btn_ClearStrumNotes:FlxButton = new FlxButton(5, btn_ClearNotes.y + 18, "Clear Strum", function(){
					for(ii in _song.sectionStrums[curStrum].notes){
						ii.sectionNotes = [];
					}
					updateGrid();
				});
				newTAB.add(btn_ClearStrumNotes);

				//Load AutoSave
				var btn_LoadAutoSave:FlxButton = new FlxButton(5 , btn_ClearStrumNotes.y + 35, 'Load AutoSave', loadAutosave);
				newTAB.add(btn_LoadAutoSave);


				TABMENU.add(newTAB);
			}

			case "TAB_SecGeneral":{
				var tab_title = new FlxText(0, 0, TABMENU.width, "General Section", 15);
				tab_title.alignment = CENTER;
				newTAB.add(tab_title);

				//Section Length
				var txt_SectionLength = new FlxText(5, 35, 'Section Length (In Steps)');
				newTAB.add(txt_SectionLength);
				stepperLength = new FlxUINumericStepper(5, txt_SectionLength.y + 17, 4, 0, 0, 999, 0);
				stepperLength.value = _song.generalSection[curSection].lengthInSteps;
				stepperLength.name = 'section_length';
				newTAB.add(stepperLength);

				//BPM
				stepperSectionBPM = new FlxUINumericStepper(5, stepperLength.y + 35, 1, Conductor.bpm, 0, 999, 0);
				stepperSectionBPM.value = Conductor.bpm;
				stepperSectionBPM.name = 'section_bpm';
				newTAB.add(stepperSectionBPM);
				var txt_BPM = new FlxText(stepperSectionBPM.x + stepperSectionBPM.width + 5, stepperSectionBPM.y, 'BPM');
				newTAB.add(txt_BPM);

				//Change BPM
				stchr_ChangeBPM = new Sprite_Input(5, stepperSectionBPM.y + 17, "Section_CHBPM", "Switcher");
				stchr_ChangeBPM.loadGraphic(Paths.image('UI_Assets/delStrum'));
				stchr_ChangeBPM.setGraphicSize(Std.int(GRID_SIZE / 2));
				stchr_ChangeBPM.updateHitbox();
				stchr_ChangeBPM.pressed = _song.generalSection[curSection].changeBPM;
				newTAB.add(stchr_ChangeBPM);
				var txt_ChangeBPM = new FlxText(stchr_ChangeBPM.x + stchr_ChangeBPM.width + 5, stchr_ChangeBPM.y, 0, "Change BPM", 8);
				newTAB.add(txt_ChangeBPM);

				//Focus Strum
				stepperFocusToStrumm = new FlxUINumericStepper(5, stchr_ChangeBPM.y + 35, 1, 0, 0, 999, 0);
				stepperFocusToStrumm.value = _song.generalSection[curSection].strumToFocus;
				stepperFocusToStrumm.name = 'strum_focus';
				newTAB.add(stepperFocusToStrumm);
				var txt_BPM = new FlxText(stepperFocusToStrumm.x + stepperFocusToStrumm.width + 5, stepperFocusToStrumm.y, 'Strum to Focus');
				newTAB.add(txt_BPM);

				//Character to Focus
				stepperCharToFocus = new FlxUINumericStepper(5, stepperFocusToStrumm.y + 35, 1, 0, 0, 999, 0);
				stepperCharToFocus.value = _song.generalSection[curSection].charToFocus;
				stepperCharToFocus.name = 'char_focus';
				newTAB.add(stepperCharToFocus);
				var txt_BPM = new FlxText(stepperCharToFocus.x + stepperCharToFocus.width + 5, stepperCharToFocus.y, 'Char to Focus');
				newTAB.add(txt_BPM);

				//Copy / Paste / Cut / Swap / Clear - Tools
				var btn_ClearSection:FlxButton = new FlxButton(5, stepperCharToFocus.y + 30, "Clear Section", clearSection);
				newTAB.add(btn_ClearSection);

				var btn_ClearStrum:FlxButton = new FlxButton(5, btn_ClearSection.y + 25, "Clear Strum", function(){
					_song.sectionStrums[curStrum].notes[curSection].sectionNotes = [];
					updateGrid();
				});
				newTAB.add(btn_ClearStrum);

				var stepperSwapSection:FlxUINumericStepper = new FlxUINumericStepper(5, btn_ClearStrum.y + 35, 1, 0, -1000, 1000, 2);
				stepperSwapSection.name = 'strum_all';
				newTAB.add(stepperSwapSection);
				var txt_SwapStrum = new FlxText(stepperSwapSection.x + stepperSwapSection.width + 5, stepperSwapSection.y, 'Section to Swap');
				newTAB.add(txt_SwapStrum);

				var btn_SwapStrum:FlxButton = new FlxButton(5, stepperSwapSection.y + 18, "Swap Strum", function(){
					var sec1 = _song.sectionStrums[curStrum].notes[curSection].sectionNotes;
					var sec2 = _song.sectionStrums[Std.int(stepperSwapSection.value)].notes[curSection].sectionNotes;

					_song.sectionStrums[curStrum].notes[curSection].sectionNotes = sec2;
					_song.sectionStrums[Std.int(stepperSwapSection.value)].notes[curSection].sectionNotes = sec1;
					updateGrid();
				});
				newTAB.add(btn_SwapStrum);

				var btn_CopyStrum:FlxButton = new FlxButton(5, btn_SwapStrum.y + 35, "Copy Strum", function(){
					copiedStrum = [[curSection, _song.sectionStrums[curStrum].notes[curSection].sectionNotes]];
				});
				newTAB.add(btn_CopyStrum);

				var btn_CopySection:FlxButton = new FlxButton(5, btn_CopyStrum.y + 18, "Copy Section", function(){
					copiedStrum = [];
					for(strum in _song.sectionStrums){
						copiedStrum.push([curSection, strum.notes[curSection].sectionNotes]);
					}
				});
				newTAB.add(btn_CopySection);

				var btn_CutStrum:FlxButton = new FlxButton(5, btn_CopySection.y + 35, "Cut Strum", function(){
					copiedStrum = [[curSection, _song.sectionStrums[curStrum].notes[curSection].sectionNotes]];
					_song.sectionStrums[curStrum].notes[curSection].sectionNotes = [];
					updateGrid();
				});
				newTAB.add(btn_CutStrum);

				var btn_CutSection:FlxButton = new FlxButton(5, btn_CutStrum.y + 18, "Cut Section", function(){
					copiedStrum = [];
					for(strum in _song.sectionStrums){
						copiedStrum.push([curSection, strum.notes[curSection].sectionNotes]);
						strum.notes[curSection].sectionNotes = [];
					}
					updateGrid();
				});
				newTAB.add(btn_CutSection);

				var stepperLastSection:FlxUINumericStepper = new FlxUINumericStepper(5, btn_CutSection.y + 35, 1, 0, -1000, 1000, 2);
				newTAB.add(stepperLastSection);
				var txt_SwapStrum = new FlxText(stepperLastSection.x + stepperLastSection.width + 5, stepperLastSection.y, 'Sections back');
				newTAB.add(txt_SwapStrum);

				var btn_SetLast:FlxButton = new FlxButton(5, stepperLastSection.y + 18, "Set Last", function(){
					stepperLastSection.value = curSection - copiedStrum[0][0];
				});
				newTAB.add(btn_SetLast);

				var btn_PasteLast:FlxButton = new FlxButton(5, btn_SetLast.y + 35, "Paste Last", function(){
					pasteLastSection(Std.int(stepperLastSection.value));
				});
				newTAB.add(btn_PasteLast);

				var btn_PasteSection:FlxButton = new FlxButton(5, btn_PasteLast.y + 25, "Paste Section", function(){
					pasteArraySection();
				});
				newTAB.add(btn_PasteSection);

				var btn_PasteStrum:FlxButton = new FlxButton(5, btn_PasteSection.y + 18, "Paste Strum", function(){
					pasteArrayStrum(curStrum);
				});
				newTAB.add(btn_PasteStrum);


				TABMENU.add(newTAB);
			}

			case "TAB_Assets":{
				var tab_title = new FlxText(0, 0, TABMENU.width, "ASSETS", 16);
				tab_title.alignment = CENTER;
				newTAB.add(tab_title);

				var noteStyles:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteStyleList'));

				var btn_CharactersEdit:FlxButton = new FlxButton(5, 35, "Characters", function(){
					
				});
				newTAB.add(btn_CharactersEdit);

				var btn_ChangeStage:FlxButton = new FlxButton(5, btn_CharactersEdit.y + 25, "Change Stage", function(){
					
				});
				newTAB.add(btn_ChangeStage);

				var txt_UIStyle = new FlxText(5, btn_ChangeStage.y + 35, 'Note Style:');
				newTAB.add(txt_UIStyle);
				var noteUIDropDown = new FlxUIDropDownMenu(5, txt_UIStyle.y + 17, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String){
					_song.uiStyle = noteStyles[Std.parseInt(noteStyle)];
					updateGrid();
				});
				noteUIDropDown.selectedLabel = "Default";
				
				newTAB.add(noteUIDropDown);
				newTAB.add(txt_UIStyle);

				
				TABMENU.add(newTAB);
			}

			case "TAB_CurSection":{
				var tab_title = new FlxText(0, 0, TABMENU.width, "STRUM GENERAL", 16);
				tab_title.alignment = CENTER;
				newTAB.add(tab_title);

				var btn_CharToSing:FlxButton = new FlxButton(5, tab_title.y + 25, "Chars to Sing", function(){
					
				});
				btn_CharToSing.width = Std.int(TABMENU.width - 10);
				newTAB.add(btn_CharToSing);

				var tab_strum = new FlxText(0, btn_CharToSing.y + 35, TABMENU.width, "STRUM SECTION", 16);
				tab_strum.alignment = CENTER;
				newTAB.add(tab_strum);

				stchr_AltAnim = new Sprite_Input(5, tab_strum.y + 25, "STRUM_AltAnim", "Switcher");
				stchr_AltAnim.loadGraphic(Paths.image('UI_Assets/delStrum'));
				stchr_AltAnim.setGraphicSize(Std.int(GRID_SIZE / 2));
				stchr_AltAnim.updateHitbox();
				stchr_AltAnim.pressed = _song.singleVoices;
				newTAB.add(stchr_AltAnim);
				var txt_AltAnim = new FlxText(stchr_AltAnim.x + stchr_AltAnim.width + 5, stchr_AltAnim.y, 0, "is Alt Anim", 8);
				newTAB.add(txt_AltAnim);

				var btn_StrnCharToSing:FlxButton = new FlxButton(5, stchr_AltAnim.y + 25, "Chars to Sing", function(){
					
				});
				btn_StrnCharToSing.width = Std.int(TABMENU.width - 10);
				newTAB.add(btn_StrnCharToSing);

				stchr_ChangeSing = new Sprite_Input(5, btn_StrnCharToSing.y + 25, "STRUM_ChangeSing", "Switcher");
				stchr_ChangeSing.loadGraphic(Paths.image('UI_Assets/delStrum'));
				stchr_ChangeSing.setGraphicSize(Std.int(GRID_SIZE / 2));
				stchr_ChangeSing.updateHitbox();
				stchr_ChangeSing.pressed = _song.sectionStrums[curStrum].notes[curSection].changeSing;
				newTAB.add(stchr_ChangeSing);
				var txt_AltAnim = new FlxText(stchr_ChangeSing.x + stchr_ChangeSing.width + 5, stchr_ChangeSing.y, 0, "Change Characters to Sing", 8);
				newTAB.add(txt_AltAnim);

				var tab_NoteData = new FlxText(0, stchr_ChangeSing.y + 35, TABMENU.width, "NOTE DATA", 16);
				tab_NoteData.alignment = CENTER;
				newTAB.add(tab_NoteData);

				var stp_SusNote = new Sprite_Input(5, tab_NoteData.y + 25, "NOTE_SUSDATA", "Stepper");
				stp_SusNote.loadGraphic(Paths.image('UI_Assets/delStrum'));
				stp_SusNote.setGraphicSize(Std.int(GRID_SIZE / 2));
				stp_SusNote.updateHitbox();
				newTAB.add(stp_SusNote);
				var txt_SusNote = new FlxText(stp_SusNote.x + stp_SusNote.width + 5, stp_SusNote.y, 'Note Sustain');
				newTAB.add(txt_SusNote);

				var stp_SpecialData = new Sprite_Input(5, stp_SusNote.y + 30, "NOTE_SPECIALDATA", "Stepper");
				stp_SpecialData.loadGraphic(Paths.image('UI_Assets/delStrum'));
				stp_SpecialData.setGraphicSize(Std.int(GRID_SIZE / 2));
				stp_SpecialData.updateHitbox();
				newTAB.add(stp_SpecialData);
				var txt_SpecialData = new FlxText(stp_SpecialData.x + stp_SpecialData.width + 5, stp_SpecialData.y, 'Note Special Data');
				newTAB.add(txt_SpecialData);

				var btn_NoteCharToSing:FlxButton = new FlxButton(5, stp_SpecialData.y + 25, "Chars to Sing", function(){
					
				});
				btn_NoteCharToSing.scrollFactor.set();
				newTAB.add(btn_NoteCharToSing);


				TABSTRUM.add(newTAB);
			}
		}
	}

	function loadSong(daSong:String, cat:String):Void{
		if (FlxG.sound.music != null){
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong, cat), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong, cat));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Change BPM':
					_song.generalSection[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.generalSection[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if(wname == 'song_player'){
				if(nums.value >= _song.sectionStrums.length){
					nums.value = _song.sectionStrums.length - 1;
				}
				if(nums.value < 0){
					nums.value = 0;
				}

				_song.strumToPlay = Std.int(nums.value);
			}
			else if (wname == 'strum_all'){
				if(nums.value >= _song.sectionStrums.length){
					nums.value = _song.sectionStrums.length - 1;
				}
				if(nums.value < 0){
					nums.value = 0;
				}
			}
			else if (wname == 'strum_focus'){
				if(nums.value >= _song.sectionStrums.length){
					nums.value = _song.sectionStrums.length - 1;
				}
				if(nums.value < 0){
					nums.value = 0;
				}

				_song.generalSection[curSection].strumToFocus = Std.int(nums.value);
			}
			else if (wname == 'char_focus'){
				if(nums.value >= _song.characters.length){
					nums.value = _song.characters.length - 1;
				}
				if(nums.value < 0){
					nums.value = 0;
				}

				_song.generalSection[curSection].charToFocus = Std.int(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.generalSection[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
			else if(wname == 'section_focus'){
				_song.generalSection[curSection].strumToFocus = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection){
			if (_song.generalSection[i].changeBPM){
				daBPM = _song.generalSection[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	override function update(elapsed:Float){
		curStep = recalculateSteps();

		/*if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.RIGHT)
			snap = snap * 2;
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.LEFT)
			snap = Math.round(snap / 2);
		if (snap >= 192)
			snap = 192;
		if (snap <= 1)
			snap = 1;*/

		if(FlxG.keys.pressed.SHIFT){
			doSnapShit = false;
		}else{
			doSnapShit = true;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = song_title.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps));
		
		/*curRenderedNotes.forEach(function(note:Note) {
			if (strumLine.overlaps(note) && strumLine.y == note.y) // yandere dev type shit
			{
				if (_song.notes[curSection].mustHitSection)
					{
						trace('must hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player1.playAnim('singUP', true);
								case 3:
									player1.playAnim('singRIGHT', true);
								case 1:
									player1.playAnim('singDOWN', true);
								case 0:
									player1.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player2.playAnim('singUP', true);
								case 7:
									player2.playAnim('singRIGHT', true);
								case 5:
									player2.playAnim('singDOWN', true);
								case 4:
									player2.playAnim('singLEFT', true);
							}
						}
					}
					else
					{
						trace('hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player2.playAnim('singUP', true);
								case 3:
									player2.playAnim('singRIGHT', true);
								case 1:
									player2.playAnim('singDOWN', true);
								case 0:
									player2.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player1.playAnim('singUP', true);
								case 7:
									player1.playAnim('singRIGHT', true);
								case 5:
									player1.playAnim('singDOWN', true);
								case 4:
									player1.playAnim('singLEFT', true);
							}
						}
					}
			}
		});*/

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.generalSection[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.generalSection[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if(FlxG.mouse.justPressedRight){
			gridGroup.forEach(function(grid:FlxSprite){
				if(FlxG.mouse.overlaps(grid)){
					curStrum = grid.ID;
					updateGrid();
				}
			});
		}

		Sprite_Input.setValue("FOCUS", "TOOL_FocusStrum-" + _song.generalSection[curSection].strumToFocus);

		Sprite_Input.INPUTS.forEach(function(buttom:Sprite_Input){
			switch(buttom.type){
				case "Switcher":{
					if(buttom.name.contains("TOOL_StrumClaps-")){
						var setSplit = buttom.name.split("-");
						playClaps[Std.parseInt(setSplit[1])] = buttom.pressed;
					}

					switch(buttom.name){
						case "SONG_HasVoices":{
							_song.needsVoices = buttom.pressed;
						}
						case "SONG_HasSingle":{
							_song.singleVoices = buttom.pressed;
						}
						case "Section_CHBPM":{
							_song.generalSection[curSection].changeBPM = buttom.pressed;
						}
						case "TOOL_MuteInst":{
							if(buttom.pressed){
								FlxG.sound.music.volume = 0;
							}else{
								FlxG.sound.music.volume = 1;
							}
						}
						case "STRUM_ChangeSing":{
							_song.sectionStrums[curStrum].notes[curSection].changeSing = buttom.pressed;
						}
					}
				}

				case "Radio":{
					if(buttom.pressed){
						if(buttom.name.contains("TAB_")){
							if(TABMENU.curTAB == buttom.name){
								TABMENU.curTAB = "";
								for(i in Sprite_Input.INPUT_VALUES){
									if(i[0] == "Radio" && i[1] == buttom.tag){
										i[2] = "";
									}
								}
							}else{
								TABMENU.curTAB = buttom.name;
							}
						}else if(buttom.name.contains("TOOL_FocusStrum-")){
							var setSplit = buttom.name.split("-");
							_song.generalSection[curSection].strumToFocus = Std.parseInt(setSplit[1]);
						}
					}
				}

				case "Buttom":{
					if(buttom.pressed){
						switch(buttom.name){
							case "TOOL_AddStrum":{
								addStrum();
								updateGrid();
							}
							case "TOOL_DelStrum":{
								delStrum(curStrum);
								updateGrid();
							}
							case "SONG_Save":{
								saveLevel();
							}
							case "TOOL_RESETCHART":{
								for(i in 0..._song.sectionStrums.length){
									for(ii in 0..._song.sectionStrums[i].notes.length){
										for(iii in 0..._song.sectionStrums[i].notes[ii].sectionNotes.length){
											_song.sectionStrums[i].notes[ii].sectionNotes = [];
										}
									}
								}
								resetSection(true);
							}
						}
					}
				}
			}
		});

		if(FlxG.mouse.justPressed){
			if(FlxG.mouse.x > gridBG.x
				&& FlxG.mouse.x < gridBG.x + gridBG.width
				&& FlxG.mouse.y > gridBG.y
				&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.generalSection[curSection].lengthInSteps))
			{
				FlxG.log.add('added note');
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.generalSection[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}
		
		if (!song_title.hasFocus){
			if (FlxG.keys.pressed.CONTROL){
				
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.CONTROL){
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}	
			if (FlxG.keys.justPressed.SPACE){
				if (FlxG.sound.music.playing){
					FlxG.sound.music.pause();
					vocals.pause();
				}else{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R){
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			
			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.mouse.wheel != 0){
				FlxG.sound.music.pause();
				vocals.pause();

				var stepMs = curStep * Conductor.stepCrochet;


				trace(Conductor.stepCrochet / snap);

				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				trace(stepMs + " + " + Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT){
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S){
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W){
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}else{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S){
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W){
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) + " | Section: " + curSection  + " | CurStep: " + curStep;
		bpmTxt.setPosition(GRID_SIZE, FlxG.height - bpmTxt.height);

		bgbpmTxt.setPosition(bpmTxt.x, bpmTxt.y);

		gridGroup.forEach(function(grid:FlxSprite){
			if(vocals.playing){
				grid.alpha = 1;
			}else{
				if(grid.ID == curStrum){
					grid.alpha = 1;
				}else{
					grid.alpha = 0.3;
				}
			}
		});

		spriteLine.setPosition(strumLine.x, strumLine.y);

		btn_AddStrum.setPosition(gridGroup.members[gridGroup.length - 1].x + gridBG.width, gridBG.y - GRID_SIZE);
		if(_song.sectionStrums.length > 1){btn_DelStrum.canUse = true;}else{btn_DelStrum.canUse = false;}

		camFollow.setPosition(FlxMath.lerp(camFollow.x, gridBG.x + (gridBG.width / 2), 0.50), strumLine.y);

		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}
		updateGrid();
	}

	override function beatHit() 
	{
		trace('beat');

		super.beatHit();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void{
		trace('changing section' + sec);

		if (_song.generalSection[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('bro wtf I AM NULL');
	}

	function pasteLastSection(?sectionNum:Int = 1){
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.sectionStrums[curStrum].notes[daSec - sectionNum].sectionNotes){
			var strum = note[0] + Conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.sectionStrums[curStrum].notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function pasteArraySection(){
		for(i in 0..._song.sectionStrums.length){
			if(copiedStrum.length > i){
				_song.sectionStrums[i].notes[curSection].sectionNotes = copiedStrum[i][1];
			}
		}

		updateGrid();
	}

	function pasteArrayStrum(strum:Int){
		if(copiedStrum.length > strum){
			_song.sectionStrums[strum].notes[curSection].sectionNotes = copiedStrum[strum][1];
		}else{
			if(copiedStrum.length > 0){
				_song.sectionStrums[strum].notes[curSection].sectionNotes = copiedStrum[0][1];
			}
		}

		updateGrid();
	}

	function updateSectionUI():Void{
		var sec = _song.generalSection[curSection];
	
		stepperLength.value = sec.lengthInSteps;
		stepperFocusToStrumm.value = sec.strumToFocus;
		stepperCharToFocus.value = sec.charToFocus;
		stchr_ChangeBPM.pressed = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateSectionStrumUI();
	}

	function updateSectionStrumUI():Void{
		var strm = _song.sectionStrums[curStrum].notes[curSection];

		stchr_AltAnim.pressed = strm.altAnim;
		stchr_ChangeSing.pressed = strm.changeSing;
	}

	function updateGrid():Void{
		remove(spriteLine);
		backGrid.clear();
		gridGroup.clear();
		gridGroupBlackLine.clear();
		gridStuffGroup.clear();

		playClaps.resize(_song.sectionStrums.length);
		for(i in 0..._song.sectionStrums.length){
			var newGroupButtoms = new FlxTypedGroup<Dynamic>();

			var newGrid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
			newGrid.x += (GRID_SIZE * 4) * i;
			newGrid.ID = i;

			var nerBackGrid = new FlxSprite((0 - GRID_SIZE) + (i * newGrid.width), 0).makeGraphic(GRID_SIZE * 6,FlxG.height,FlxColor.BLACK);
			nerBackGrid.scrollFactor.set(1, 0);
			backGrid.add(nerBackGrid);

			var btn_StrumToFocus = new Sprite_Input(newGrid.x + (GRID_SIZE * 1.5), newGrid.y + newGrid.height, "TOOL_FocusStrum-" + i, "Radio", "FOCUS");
			btn_StrumToFocus.loadGraphic(Paths.image('UI_Assets/delStrum'));
			btn_StrumToFocus.setGraphicSize(GRID_SIZE);
			btn_StrumToFocus.updateHitbox();
			newGroupButtoms.add(btn_StrumToFocus);

			var btn_Claps = new Sprite_Input(newGrid.x + (GRID_SIZE / 2), newGrid.y + newGrid.height, "TOOL_StrumClaps-" + i, "Switcher");
			btn_Claps.loadGraphic(Paths.image('UI_Assets/delStrum'));
			btn_Claps.setGraphicSize(Std.int(GRID_SIZE / 2));
			btn_Claps.updateHitbox();
			btn_Claps.pressed = playClaps[i];
			newGroupButtoms.add(btn_Claps);

			gridStuffGroup.add(newGroupButtoms);
			gridGroup.add(newGrid);

			var gridBlackLine = new FlxSprite(newGrid.x + newGrid.width - 1).makeGraphic(2, Std.int(newGrid.height), FlxColor.BLACK);
			gridGroupBlackLine.add(gridBlackLine);
		}

		spriteLine = new FlxSprite(0, 50).makeGraphic(Std.int(gridBG.width * _song.sectionStrums.length), 4);
		add(spriteLine);

		if(curStrum >= gridGroup.length){curStrum = gridGroup.length - 1;}
		gridBG = gridGroup.members[curStrum];

		if (_song.generalSection[curSection].changeBPM && _song.generalSection[curSection].bpm > 0){
			Conductor.changeBPM(_song.generalSection[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}else{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.generalSection[i].changeBPM)
					daBPM = _song.generalSection[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var genSec:SwagGeneralSection = {
			bpm: _song.bpm,
			changeBPM: false,

			lengthInSteps: lengthInSteps,

			strumToFocus: 0,
			charToFocus: 0
		};

		var sec:SwagSection = {
			charToSing: [0],
			changeSing: false,

			keys: 4,
			changeKeys: false,

			altAnim: false,

			sectionNotes: [],
		};

		for(i in 0..._song.sectionStrums.length){
			_song.sectionStrums[i].notes.push(sec);
		}
		_song.generalSection.push(genSec);
	}

	function clearSection():Void{
		for(i in 0..._song.sectionStrums.length){
			_song.sectionStrums[i].notes[curSection].sectionNotes = [];
		}

		updateGrid();
	}

	function clearSong():Void{
		for(i in 0..._song.sectionStrums.length){
			for(ii in 0..._song.sectionStrums[i].notes.length){
				_song.sectionStrums[i].notes[ii].sectionNotes = [];
			}
		}

		updateGrid();
	}

	private function newSecStrum(charToSing:Array<Int>):SwagStrum {
		var sec:SwagStrum = {
			keys: 4,
			noteStyle: "Default",
			charToSing: charToSing,

			notes: []
		};

		return sec;
	}

	private function newSection(charToSing:Array<Int>, changeSing:Bool = false, altAnim:Bool = true):SwagSection {
		var sec:SwagSection = {
			charToSing: charToSing,
			changeSing: changeSing,

			keys: 4,
			changeKeys: false,
			
			altAnim: altAnim,

			sectionNotes: []
		};

		return sec;
	}

	private function newGenSection(lengthInSteps:Int = 16, strumToFocus:Int = 0, charToFocus:Int = 0):SwagGeneralSection {
		var sec:SwagGeneralSection = {
			bpm: _song.bpm,
			changeBPM: false,

			lengthInSteps: lengthInSteps,
			
			strumToFocus: strumToFocus,
			charToFocus: charToFocus
		};

		return sec;
	}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void {
		var newSong = [];
		var newGeneral = [];
			
		var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
		var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
		trace(millisecadd,totaladdsection);

		if(millisecadd > 0){
			for(i in 0...totaladdsection){
				newGeneral.unshift(newGenSection());
			}
		}

		for(daSection1 in 0..._song.generalSection.length){
			newGeneral.push(newGenSection(16, _song.generalSection[daSection1].strumToFocus, _song.generalSection[daSection1].charToFocus));
		}

		for(daSection in 0..._song.generalSection.length){
			var aimtosetsection = daSection+Std.int((totaladdsection));
			if(aimtosetsection<0) aimtosetsection = 0;
			newGeneral[aimtosetsection].strumToFocus = _song.generalSection[daSection].strumToFocus;
		}

		for(i in 0..._song.sectionStrums.length){
			newSong.push(newSecStrum(_song.sectionStrums[i].charToSing));

			if(millisecadd > 0){
				for(i in 0...totaladdsection){
					newSong[i].notes.unshift(newSection([0]));
				}
			}

			for(daSection1 in 0..._song.sectionStrums[i].notes.length){
				newSong[i].notes.push(newSection(_song.sectionStrums[i].notes[daSection1].charToSing, _song.sectionStrums[i].notes[daSection1].changeSing, _song.sectionStrums[i].notes[daSection1].altAnim));
			}

			for(daSection in 0..._song.sectionStrums[i].notes.length){
				var aimtosetsection = daSection+Std.int((totaladdsection));
				if(aimtosetsection<0) aimtosetsection = 0;
				newGeneral[aimtosetsection].strumToFocus = _song.generalSection[daSection].strumToFocus;
				newSong[i].notes[aimtosetsection].altAnim = _song.sectionStrums[i].notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.sectionStrums[i].notes[daSection].sectionNotes.length)){	
					var newtiming = _song.sectionStrums[i].notes[daSection].sectionNotes[daNote][0]+millisecadd;
					if(newtiming<0){
						newtiming = 0;
					}
					var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
					_song.sectionStrums[i].notes[daSection].sectionNotes[daNote][0] = newtiming;
					newSong[i].notes[futureSection].sectionNotes.push(_song.sectionStrums[i].notes[daSection].sectionNotes[daNote]);
					//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
				}
			}
		}

		//trace("DONE BITCH");
		_song.sectionStrums = newSong;
		_song.generalSection = newGeneral;
		updateGrid();
		updateSectionUI();
	}

	private function delStrum(strum:Int){
		var delStrum = _song.sectionStrums[strum];

		_song.sectionStrums.remove(delStrum);
	}

	private function addStrum(){
		var newStrum = newSecStrum([0]);

		for(i in 0..._song.generalSection.length){
			var newSec = newSection([0], false, false);

			newStrum.notes.push(newSec);
		}

		_song.sectionStrums.push(newStrum);
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void{
		trace(_song.sectionStrums);
	}

	function getNotes():Array<Dynamic>{
		var noteData:Array<Dynamic> = [];

		for(i in 0..._song.sectionStrums.length){
			for (ii in _song.sectionStrums[i].notes){
				noteData.push(ii.sectionNotes);
			}
		}		

		return noteData;
	}

	function loadJson(song:String, diff:String, cat:String):Void
	{
		var poop:String = Highscore.formatSong(song, diff, cat);
		PlayState.SONG = Song.loadFromJson(poop, song);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, song_title.text + "-" + song_cat_title.text + "-" + song_diff_title.text + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
