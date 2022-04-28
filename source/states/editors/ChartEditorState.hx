package states.editors;

import flixel.tweens.FlxEase;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import FlxCustom.FlxUINumericStepperCustom;
import flixel.input.FlxInput;
import io.newgrounds.swf.common.Button;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
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

import flixel.addons.ui.FlxUI.NamedFloat;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import lime.ui.FileDialog;

import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import StrumLineNote;
import StrumLineNote.Note;
import StrumLineNote.StrumStaticNotes;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import Stage.StageData;
import states.PlayState.SongListData;

using StringTools;

class ChartEditorState extends MusicBeatState{
    public static var _song:SwagSong;
    var _file:FileReference;
    var backStage:Stage;

    var curStrum:Int = 0;
    var curSection:Int = 0;
    public static var lastSection:Int = 0;

    var strumLine:FlxSprite;
    var strumStatics:FlxTypedGroup<StrumStaticNotes>;

    var dArrow:Note;
    var curStrumJSON:StrumLineNoteJSON;

    var backGrid:FlxSprite;
    var stuffGroup:FlxTypedGroup<Dynamic>;
    var gridGroup:FlxTypedGroup<FlxSprite>;
    var curGrid:FlxSprite;

    var renderedNotes:FlxTypedGroup<FlxTypedGroup<Dynamic>>;
    var renderedSustains:FlxTypedGroup<FlxTypedGroup<Dynamic>>;
    var selNote:Array<Dynamic> = [0, [0, 0, 0, 0, null, []]];
    var renderedAll:Array<Array<Note>> = [];
    var pressedNotes:Array<Array<Note>> = [];

    var gridBLine:FlxSprite;

    //var tabsUI:FlxUIMenuCustom;

    //Cameras
    var camGENERAL:FlxCamera;
    var camBACK:FlxCamera;
    var camSTRUM:FlxCamera;

    var genFollow:FlxObject;
    var backFollow:FlxObject;
    //-------

    var voices:FlxSoundGroup;

    var KEYSIZE:Int = 60;

    var btnAddStrum:FlxTypedButton<FlxSprite>;
    var btnDelStrum:FlxTypedButton<FlxSprite>;

    var MENU:FlxUITabMenu;
    var DDLMENU:FlxUITabMenu;

    var copySection:Array<Dynamic> = null;

    var lblSongInfo:FlxText;

    public static function editChart(?chart:SwagSong = null){
        if(chart != null){
            _song = chart;
        }else{
            _song = Song.loadFromJson("Test-Normal-Normal", "Test");
        }

        FlxG.sound.music.stop();
        FlxG.switchState(new ChartEditorState());
    }

    override function create(){
        FlxG.mouse.visible = true;

        curSection = lastSection;

        camGENERAL = new FlxCamera();
        camBACK = new FlxCamera();
		camSTRUM = new FlxCamera();
		camSTRUM.bgColor.alpha = 0;

		FlxG.cameras.reset(camGENERAL);
		FlxG.cameras.add(camBACK);
        FlxG.cameras.add(camSTRUM);

        //camBACK.alpha = 0;
        camBACK.zoom = 0.5;

        backFollow = new FlxObject(0, 0, 1, 1);
        backFollow.screenCenter();
		camBACK.follow(backFollow, LOCKON, 0.3);

        genFollow = new FlxObject(0, 0, 1, 1);
        FlxG.camera.follow(genFollow, LOCKON);
        camSTRUM.follow(genFollow, LOCKON);
        
        backStage = new Stage(_song.stage, _song.characters);
        backStage.cameras = [camBACK];
        add(backStage);

        camBACK.zoom = backStage.zoom;

        backGrid = new FlxSprite(-1, 0).makeGraphic(0, FlxG.height, FlxColor.BLACK);
        backGrid.scrollFactor.set(1, 0);
        backGrid.alpha = 0.5;
        backGrid.cameras = [camSTRUM];
        add(backGrid);

        gridGroup = new FlxTypedGroup<FlxSprite>();
        add(gridGroup);

        stuffGroup = new FlxTypedGroup<Dynamic>();
        add(stuffGroup);

        strumStatics = new FlxTypedGroup<StrumStaticNotes>();
        strumStatics.cameras = [camSTRUM];
        add(strumStatics);

        renderedSustains = new FlxTypedGroup<FlxTypedGroup<Dynamic>>();
        renderedNotes = new FlxTypedGroup<FlxTypedGroup<Dynamic>>();

        add(renderedSustains);
        add(renderedNotes);

        stuffGroup.cameras = [camSTRUM];
        gridGroup.cameras = [camSTRUM];

        renderedNotes.cameras = [camSTRUM];
        renderedSustains.cameras = [camSTRUM];
        
        curStrumJSON = cast Json.parse(Assets.getText(Paths.strumJSON(getStrumKeys(curStrum))));
        dArrow = new Note(0, 0);
        dArrow.loadGraphicNote(curStrumJSON.gameplayNotes[0]);
        dArrow.setGraphicSize(KEYSIZE, KEYSIZE);
        dArrow.cameras = [camSTRUM];
        dArrow.onDebug = true;
        add(dArrow);

        strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
        strumLine.cameras = [camSTRUM];
		//strumLine.visible = false;
		add(strumLine);

        btnAddStrum = new FlxTypedButton<FlxSprite>(0, 0, function(){
            var nStrum:SwagStrum = {
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
            };

            _song.sectionStrums.push(nStrum);

            for(i in 0...curSection){
                addSection(_song.sectionStrums.length - 1, _song.generalSection[i].lengthInSteps);
            }

            updateSection();
        });
        btnAddStrum.cameras = [camSTRUM];
        btnAddStrum.loadGraphic(Paths.image('UI_Assets/addStrum', 'shared'));
        btnAddStrum.setSize(50, 50);
		btnAddStrum.setGraphicSize(50);
		btnAddStrum.centerOffsets();
        btnAddStrum.scrollFactor.set(1, 0);
        add(btnAddStrum);

        btnDelStrum = new FlxTypedButton<FlxSprite>(0, 0, function(){
            if(_song.sectionStrums.length > 1){
                _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            }
            updateSection();
        });
        btnDelStrum.cameras = [camSTRUM];
        btnDelStrum.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnDelStrum.setSize(50, 50);
		btnDelStrum.setGraphicSize(50);
		btnDelStrum.centerOffsets();
        btnDelStrum.scrollFactor.set(1, 0);
        add(btnDelStrum);

        gridBLine = new FlxSprite(-1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK);
		add(gridBLine);
        gridBLine.cameras = [camSTRUM];

        var menuTabs = [
            {name: "Settings", label: 'Settings'},
            {name: "Note", label: 'Note'},
            {name: "Section/Strum", label: 'Section/Strum'},
            {name: "Song", label: 'Song'}
        ];
        MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(300, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        MENU.camera = camSTRUM;
        addMENUTABS();
        
        var ddlTabs = [{name: "Stage", label: 'Stage'},{name: "Voices", label: 'Voices'},{name: "Characters", label: 'Characters'}];
        DDLMENU = new FlxUITabMenu(null, ddlTabs, true);
        DDLMENU.resize(130, FlxG.height);
		DDLMENU.x = FlxG.width - MENU.width - DDLMENU.width;
        DDLMENU.camera = camSTRUM;
        addDDLTABS();

        add(MENU);
        add(DDLMENU);

        lblSongInfo = new FlxText(0, 0, 300, "", 16);
        lblSongInfo.scrollFactor.set();
        lblSongInfo.camera = camSTRUM;
        add(lblSongInfo);

        updateSection();
        updateCharacterValues();

        voices = new FlxSoundGroup();
        loadAudio(_song.song, _song.category);
        Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

        super.create();
    }

    override function update(elapsed:Float){
        if(FlxG.sound.music.time < 0){FlxG.sound.music.time = 0;}

        curStep = recalculateSteps();
        Conductor.songPosition = FlxG.sound.music.time;

        strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps));
        for(strum in strumStatics){strum.setPosition(strum.x, strumLine.y);}

        if(curStrumJSON.gameplayNotes.length != getStrumKeys(curStrum)){curStrumJSON = cast Json.parse(Assets.getText(Paths.strumJSON(getStrumKeys(curStrum))));}

        if(_song.generalSection[curSection + 1] == null){addGenSection();}
        for(i in 0..._song.sectionStrums.length){if(_song.sectionStrums[i].notes[curSection + 1] == null){addSection(i, _song.generalSection[curSection].lengthInSteps, getStrumKeys(i));}}

        if(curStep >= (16 * (curSection + 1))){changeSection(curSection + 1, false);}
        if(curStep + 1 < (16 * curSection) && curSection > 0){changeSection(curSection - 1, false);}
    
        FlxG.watch.addQuick('daBeat', curBeat);
        FlxG.watch.addQuick('daStep', curStep);

        lblSongInfo.text = 
        "Time: " + Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) +
		"\n\nSection: " + curSection +
		"\nBeat: " + curBeat +
		"\nStep: " + curStep;

        if(!FlxG.sound.music.playing && (FlxG.mouse.x > curGrid.x && FlxG.mouse.x < curGrid.x + curGrid.width
		&& FlxG.mouse.y > curGrid.y && FlxG.mouse.y < curGrid.y + curGrid.height)){
			dArrow.x = (Math.floor(FlxG.mouse.x / KEYSIZE) * KEYSIZE) - ((dArrow.width - KEYSIZE) / 2);

			if(FlxG.keys.pressed.SHIFT){
                dArrow.y = FlxG.mouse.y - ((dArrow.width - KEYSIZE) / 2);
            }else{
                dArrow.y = Math.floor(FlxG.mouse.y / (KEYSIZE / 2)) * (KEYSIZE / 2) - ((dArrow.width - KEYSIZE) / 2);
            }

            var data:Int = (Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE)) % (getStrumKeys(curStrum));
            dArrow.loadGraphicNote(curStrumJSON.gameplayNotes[data]);

            if(FlxG.mouse.pressed){dArrow.alpha = 1;
            }else{dArrow.alpha = 0.5;}

            if(FlxG.mouse.justPressed){checkToHold();}
            if(FlxG.mouse.justReleased){checkToAdd();}
            if(FlxG.mouse.justPressedRight){checkSelNote();}
		}else{
            dArrow.alpha = 0;
        }

        var char:Character = null;
        if(chkFocusChar.checked){
            char = backStage.getCharacterById(Std.int(stpCharID.value));
        }else{
            if(FlxG.sound.music.playing){
                char = backStage.getCharacterById(Std.int(_song.sectionStrums[_song.generalSection[curSection].strumToFocus].charToSing[_song.generalSection[curSection].charToFocus]));
                if(char == null){char = backStage.getCharacterById(Std.int(_song.sectionStrums[_song.generalSection[curSection].strumToFocus].charToSing[_song.sectionStrums[_song.generalSection[curSection].strumToFocus].charToSing.length - 1]));}
            }else{
                char = backStage.getCharacterById(Std.int(_song.sectionStrums[curStrum].charToSing[_song.generalSection[curSection].charToFocus]));
                if(char == null){char = backStage.getCharacterById(Std.int(_song.sectionStrums[curStrum].charToSing[_song.sectionStrums[_song.generalSection[curSection].strumToFocus].charToSing.length - 1]));}
            }
        }

        if(char != null){
            backFollow.setPosition(char.getMidpoint().x, char.getMidpoint().y);
        }else{
            backFollow.screenCenter();
        }

        if(FlxG.sound.music.playing){
            backGrid.alpha = 0.3;
            curGrid.alpha = 0.5;

            for(i in 0..._song.sectionStrums.length){
                var renderStrum:Array<Note> = renderedAll[i];
                for(daNote in renderStrum){
                    if(daNote.strumTime < Conductor.songPosition && !checkPressedNote([daNote.strumTime, daNote.noteData], i)){
                        strumStatics.members[i].members[Std.int(daNote.noteData % getStrumKeys(i))].playAnim("confirm", true);
                        if(_song.sectionStrums[i] != null){
                            var char = _song.sectionStrums[i].charToSing;
                            if(_song.sectionStrums[i].notes[curSection].changeSing){char = _song.sectionStrums[i].notes[curSection].charToSing;}

                            for(c in char){
                                var char:Character = backStage.getCharacterById(c);

                                if(char != null){
                                    char.playAnim(false, daNote.chAnim, true);
                                    char.holdTimer = elapsed * 10;
                                }
                            }
                        }

                        pressedNotes[i].push(daNote);
                    }
                }
            }

            btnAddStrum.kill();
            btnDelStrum.kill();
        }else{
            pressedNotes = [];
            for(i in 0..._song.sectionStrums.length){
                pressedNotes.push([]);

                var renderStrum:Array<Note> = renderedAll[i];
                for(n in renderStrum){if(n.strumTime < Conductor.songPosition && !pressedNotes[i].contains(n)){pressedNotes[i].push(n);}}
            }

            backGrid.alpha = 0.5;
            curGrid.alpha = 1;

            btnAddStrum.revive();
            btnDelStrum.revive();
        }

        if(FlxG.keys.justPressed.SPACE){
            if(FlxG.sound.music.playing){
                FlxG.sound.music.pause();
                for(voice in voices.sounds){voice.pause();}
            }else{
                for(voice in voices.sounds){voice.play();}
                FlxG.sound.music.play();
            }
            for(voice in voices.sounds){voice.time = FlxG.sound.music.time;}

            updateSection();
        }

        if(FlxG.keys.anyJustPressed([UP, DOWN, W, S]) || FlxG.mouse.wheel != 0){
            FlxG.sound.music.pause();
            for(voice in voices.sounds){voice.pause();}
        }

        if(!FlxG.keys.pressed.SHIFT){
            if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.5);}

            if(FlxG.keys.justPressed.E){changeNoteSustain(Conductor.stepCrochet * 0.25);}
            if(FlxG.keys.justPressed.Q){changeNoteSustain(-Conductor.stepCrochet * 0.25);}

            if(!FlxG.sound.music.playing){
                if(FlxG.keys.anyPressed([UP, W])){
                    var daTime:Float = Conductor.stepCrochet * 0.1;
                    FlxG.sound.music.time -= daTime;
                }
                if(FlxG.keys.anyPressed([DOWN, S])){
                    var daTime:Float = Conductor.stepCrochet * 0.1;
                    FlxG.sound.music.time += daTime;
                }
            }

            if(FlxG.keys.justPressed.R){resetSection();}

            if(FlxG.keys.anyJustPressed([LEFT, A])){changeSection(curSection - 1);}
            if(FlxG.keys.anyJustPressed([RIGHT, D])){changeSection(curSection + 1);}
        }else{
            if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 1);}

            if(FlxG.keys.justPressed.E){changeNoteHits(1);}
            if(FlxG.keys.justPressed.Q){changeNoteHits(-1);}

            if(FlxG.keys.justPressed.C){trace(copySection);}
            if(FlxG.keys.justPressed.T){trace(pressedNotes);}

            if(!FlxG.sound.music.playing){
                if(FlxG.keys.anyPressed([UP, W])){
                    var daTime:Float = Conductor.stepCrochet * 0.05;
                    FlxG.sound.music.time -= daTime;
                }
                if(FlxG.keys.anyPressed([DOWN, S])){
                    var daTime:Float = Conductor.stepCrochet * 0.05;
                    FlxG.sound.music.time += daTime;
                }
            }

            if(FlxG.keys.justPressed.R){resetSection(true);}

            if(FlxG.keys.anyJustPressed([LEFT, A])){
                changeStrum(-1);
                updateSection();
            }
            if(FlxG.keys.anyJustPressed([RIGHT, D])){
                changeStrum(1);
                updateSection();
            }
        }

        if(FlxG.mouse.justPressedRight){
            if(FlxG.mouse.overlaps(gridGroup)){
                gridGroup.forEach(function(grid:FlxSprite){
                    if(FlxG.mouse.overlaps(grid) && grid.ID != curStrum){
                        curStrum = grid.ID;
                        updateStrumValues();
                        updateSection();
                    }
                });
            }            
        }

        strumLine.x = curGrid.x;

        genFollow.setPosition(FlxMath.lerp(genFollow.x, curGrid.x + 250, 0.50), strumLine.y);
        super.update(elapsed);
    }

    function checkPressedNote(n:Dynamic, strum:Int):Bool{
        var strumAll:Array<Note> = pressedNotes[strum];
        for(daNote in strumAll){if(compNotes([daNote.strumTime, daNote.noteData], n)){return true;}}

        return false;
    }

    override function beatHit(){
        trace('beat');
    
        super.beatHit();
    }

    function updateSection():Void {
        stuffGroup.clear();
        gridGroup.clear();
        strumStatics.clear();

        changeStrum();

        if(backStage.curStage != _song.stage){
            backStage.loadStage(_song.stage);
            camBACK.zoom = backStage.zoom;
        }

        //trace(_song.characters);

        var lastWidth:Float = 0;
        for(i in 0..._song.sectionStrums.length){
            var newGrid = FlxGridOverlay.create(KEYSIZE, KEYSIZE, KEYSIZE * getStrumKeys(i), KEYSIZE * (_song.generalSection[curSection].lengthInSteps), true, i == _song.generalSection[curSection].strumToFocus ? 0xfffffed6 : 0xffe7e6e6, i == _song.generalSection[curSection].strumToFocus ? 0xffe8e7b7 : 0xffd9d5d5);
            if(i != curStrum || FlxG.sound.music.playing){newGrid.alpha = 0.5;}
            newGrid.x += lastWidth;
            newGrid.ID = i;
            gridGroup.add(newGrid);

            lastWidth += newGrid.width;

            var newGridBLine = new FlxSprite(lastWidth - 1, 0).makeGraphic(2, Std.int(newGrid.height), FlxColor.BLACK);
		    stuffGroup.add(newGridBLine);

            var newStrumStatic = new StrumStaticNotes(newGrid.x, strumLine.y, getStrumKeys(i), Std.int(newGrid.width));
            strumStatics.add(newStrumStatic);
        }

        if(backGrid.width != Std.int(lastWidth)){backGrid.makeGraphic(Std.int(lastWidth + 2), FlxG.height, FlxColor.BLACK);}

        curGrid = gridGroup.members[curStrum];
        btnAddStrum.setPosition(lastWidth + 5, curGrid.y);
        btnDelStrum.setPosition(curGrid.x + curGrid.width + 5, curGrid.y + btnAddStrum.height + 10);

        if(strumLine.width != Std.int(curGrid.width)){strumLine.makeGraphic(Std.int(curGrid.width), 4);}
        gridBLine.makeGraphic(2, Std.int(curGrid.height), FlxColor.BLACK);

        if(FlxG.sound.music.playing){
            for(char in backStage.charData){char.alpha = 1;}
        }else{
            for(char in backStage.charData){if(char.ID == _song.generalSection[curSection].charToFocus){char.alpha = 1;}else{char.alpha = 0.5;}}
        }

		if(_song.generalSection[curSection].changeBPM && _song.generalSection[curSection].bpm > 0){
			Conductor.changeBPM(_song.generalSection[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
        }else{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for(i in 0...curSection){
                if(_song.generalSection[i].changeBPM){
                    daBPM = _song.generalSection[i].bpm;
                }
            }
			Conductor.changeBPM(daBPM);
		}

        renderedAll = [];
        renderedNotes.clear();
        renderedSustains.clear();
        for(ii in 0..._song.sectionStrums.length){
            renderedNotes.add(new FlxTypedGroup<Note>());
            renderedSustains.add(new FlxTypedGroup<Note>());
            renderedAll.push([]);

            var sectionInfo:Array<Dynamic> = _song.sectionStrums[ii].notes[curSection].sectionNotes;
            for(i in sectionInfo){pushNoteToGrid(i, ii);}
        }

        updateSectionValues();
        updateStrumValues();

        updateNoteValues();
    }

    var prevNote:Note = null;
    function pushNoteToGrid(i:Dynamic, strum:Int, ?merge:Bool = false):Note {
        var daStrumTime:Float = i[0];
        var daNoteData:Int = Std.int(i[1] % getStrumKeys(strum));
        var daLength:Float = i[2];
        var daHits:Int = i[3];
        var daHasMerge:Dynamic = i[4];
        var daOther:Map<String, Dynamic> = i[5];

        var daJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumJSON(getStrumKeys(strum))));

        var note:Note = newGridNote(strum, daStrumTime, daNoteData, daLength, daHits, daOther);
        note.loadGraphicNote(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[strum].noteStyle);

        if(merge){note.typeNote = "Merge";
            var fData:Note = prevNote;
            var sData:Note = note;
            var lDatas:Int = note.noteData - prevNote.noteData;
            if(note.noteData <  prevNote.noteData){
                fData = note;
                sData = prevNote;
                lDatas = prevNote.noteData - note.noteData;
            }

            if(fData.noteData != sData.noteData){   var cData:Int = 0;
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daJSON.gameplayNotes[fData.noteData]); cData++;
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daJSON.gameplayNotes[fData.noteData]); cData++;
                for(i in 1...lDatas){for(ii in 0...4){setSwitcher(cData, strum, daStrumTime, fData.noteData, daJSON.gameplayNotes[fData.noteData + i]); cData++;}}
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daJSON.gameplayNotes[sData.noteData]); cData++;
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daJSON.gameplayNotes[sData.noteData]); cData++;
            }
        }else{prevNote = null;}

        if(FlxG.sound.music.playing){
            note.alpha = note._alpha;
        }else{
            note.alpha = note._alpha * 0.3;
            if(strum == curStrum){
                note.alpha = note._alpha * 0.6;
    
                if(selNote[0] == strum && selNote[1][0] == note.strumTime && selNote[1][1] == note.noteData){note.alpha = note._alpha;}
            }   
        }
        
        renderedNotes.members[strum].add(note);
        renderedAll[strum].push(note);

        if(daLength > 0){
            if(daHits > 0){
                var totalHits:Int = daHits + 1;
                var hits:Int = daHits;
                var curHits:Int = 1;
                note.noteHits = 0;
                daHits = 0;
    
                while(hits > 0){
                    var newStrumTime = daStrumTime + (daLength * curHits);
    
                    var hitNote:Note = newGridNote(strum, newStrumTime, daNoteData, 0, curHits, daOther);
                    hitNote.loadGraphicNote(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[strum].noteStyle);
                    
                    if(FlxG.sound.music.playing){
                        hitNote.alpha = hitNote._alpha;
                    }else{
                        hitNote.alpha = hits * note.alpha / totalHits;
                    }

                    renderedNotes.members[strum].add(hitNote);
                    renderedAll[strum].push(hitNote);
    
                    hits--;
                    curHits++;
                }
            }else{
                var cSusNote = Math.floor(daLength / (Conductor.stepCrochet * 0.25) + 2);

                var prevSustain:Note = note;
                for(sNote in 0...Math.floor(daLength / (Conductor.stepCrochet * 0.25)) + 2){
                    var sStrumTime = daStrumTime + (Conductor.stepCrochet / 2) + ((Conductor.stepCrochet * 0.25) * sNote);
                            
                    var nSustain:Note = newGridNote(strum, sStrumTime, daNoteData, 0, 0, daOther);
                    nSustain.loadGraphicNote(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[strum].noteStyle);

                    if(FlxG.sound.music.playing){
                        nSustain.alpha = nSustain._alpha * 0.5;
                    }else{
                        nSustain.alpha = nSustain._alpha * 0.1;
                        if(strum == curStrum){
                            nSustain.alpha = nSustain._alpha * 0.3;

                            if(selNote[0] == strum && selNote[1][0] == note.strumTime && selNote[1][1] == note.noteData){nSustain.alpha = nSustain._alpha * 0.5;}
                        }
                    }

                    nSustain.typeNote = "Sustain";
                    prevSustain.nextNote = nSustain;

                    if(cSusNote <= 1 && daHasMerge != null){
                        nSustain.scale.y = 0.75;
                        
                        var nMerge:Note = newGridNote(strum, sStrumTime, daNoteData, 0, 0, daOther);
                        nMerge.loadGraphicNote(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[strum].noteStyle);
                        nMerge.typeNote = "Merge";

                        if(FlxG.sound.music.playing){
                            nMerge.alpha = nMerge._alpha;
                        }else{
                            nMerge.alpha = nMerge._alpha * 0.1;
                            if(strum == curStrum){
                                nMerge.alpha = nMerge._alpha * 0.5;
    
                                if(selNote[0] == strum && selNote[1][0] == note.strumTime && selNote[1][1] == note.noteData){nMerge.alpha = nMerge._alpha;}
                            }
                        }

                        prevNote = nMerge;
                        nSustain.nextNote = nMerge;

                        renderedNotes.members[strum].add(nMerge);
                        renderedAll[strum].push(nMerge);
                        
                        daHasMerge[0] = sStrumTime;
                        nMerge.nextNote = pushNoteToGrid(daHasMerge, strum, true);
                    }
                            
                    renderedSustains.members[strum].add(nSustain);
                    renderedAll[strum].push(nSustain);

                    prevSustain = nSustain;
                    cSusNote--;
                }
            }
        }

        return note;
    }

    function setSwitcher(i:Int, strum:Int, daStrumTime:Float, noteData:Int, JSON:NoteJSON){
        var nSustain:Note = newGridNote(strum, daStrumTime, noteData, 0, 0, []);
        nSustain.loadGraphicNote(JSON, _song.sectionStrums[strum].noteStyle);
        nSustain.typeNote = "Switch";
    
        if(FlxG.sound.music.playing){
            nSustain.alpha = nSustain._alpha * 0.5;
        }else{
            nSustain.alpha = nSustain._alpha * 0.1;
            if(strum == curStrum){nSustain.alpha = nSustain._alpha * 0.5;}
        }
    
        nSustain.angle = 270;
        nSustain.x += i * (KEYSIZE / 4);

        renderedSustains.members[strum].add(nSustain);   
    }

    function newGridNote(grid:Int, strumTime:Float, noteData:Int, ?noteLength:Float = 0, ?noteHits:Int = 0, ?otherData:Map<String, Dynamic>):Note{
        var note:Note = new Note(strumTime, noteData, noteLength, noteHits, otherData);
        note.onDebug = true;
        note.setGraphicSize(KEYSIZE, KEYSIZE);
        note.updateHitbox();
        note.x = gridGroup.members[grid].x + Math.floor(noteData * KEYSIZE);
        note.y = Math.floor(getYfromStrum((strumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps)));

        return note;
    }

    function changeStrum(value:Int = 0):Void{
        curStrum += value;

        if(curStrum >= _song.sectionStrums.length){curStrum = _song.sectionStrums.length - 1;}
        if(curStrum < 0){curStrum = 0;}

        updateStrumValues();
    }

    function updateCharacterValues():Void{
        if(stpCharID.value < 0){stpCharID.value = 0;}
        if(stpCharID.value >= _song.characters.length){stpCharID.value = _song.characters.length - 1;}

        if(_song.characters[Std.int(stpCharID.value)] != null){
            ddlCharacters.selectedLabel = _song.characters[Std.int(stpCharID.value)][0];
            txtAspect.text = _song.characters[Std.int(stpCharID.value)][4];
            chkLEFT.checked = _song.characters[Std.int(stpCharID.value)][3];
            stpCharX.value = _song.characters[Std.int(stpCharID.value)][1][0];
            stpCharY.value = _song.characters[Std.int(stpCharID.value)][1][1];
            stpCharSize.value = _song.characters[Std.int(stpCharID.value)][2];
            stpCharLayout.value = _song.characters[Std.int(stpCharID.value)][6];
        }else{
            txtAspect.text = "";
            chkLEFT.checked = false;
            stpCharX.value = 0;
            stpCharY.value = 0;
            stpCharSize.value = 0;
            stpCharLayout.value = 0;
        }
    }

    function updateStrumValues():Void{
        stpSrmKeys.value = _song.sectionStrums[curStrum].keys;

        chkALT.checked = _song.sectionStrums[curStrum].notes[curSection].altAnim;
        stpKeys.value = _song.sectionStrums[curStrum].notes[curSection].keys;
        chkKeys.checked = _song.sectionStrums[curStrum].notes[curSection].changeKeys;

        lblCharsToSing.text = "Characters to Sing: " + _song.sectionStrums[curStrum].charToSing;
        lblNoteStyle.text = _song.sectionStrums[curStrum].noteStyle;
        
    }

    function updateSectionValues():Void{
        stpSecBPM.value = _song.generalSection[curSection].bpm;
        chkBPM.checked = _song.generalSection[curSection].changeBPM;
        stpLength.value = _song.generalSection[curSection].lengthInSteps;
        stpSecStrum.value = _song.generalSection[curSection].strumToFocus;
        stpSecChar.value = _song.generalSection[curSection].charToFocus;

        chkSwitchChars.checked = _song.sectionStrums[curStrum].notes[curSection].changeSing;
        lblSecCharsToSing.text = "Characters to Sing: " + _song.sectionStrums[curStrum].notes[curSection].charToSing;
    }

    function updateNoteValues():Void{
        var note = getNote(selNote[1]);

        if(note != null){
            stpStrumLine.value = note[0];
            stpNoteData.value = note[1];
            stpNoteLength.value = note[2];
            stpNoteHits.value = note[3];

            //lblEventNote.text = "Note Events: " + 0 + "/" + (0 + note[5].lenght);
        }else{
            stpStrumLine.value = 0;
            stpNoteData.value = 0;
            stpNoteLength.value = 0;
            stpNoteHits.value = 0;

            lblEventNote.text = "Note Events: 0/0";
        }
    }

    function loadSong(daSong:String, cat:String, diff:String) {
        daSong = daSong.replace(" ", "_");

        _song = Song.loadFromJson(daSong + "-" + cat + "-" + diff, daSong);
        LoadingState.loadAndSwitchState(new ChartEditorState(), _song, false);
    }

    function loadAudio(daSong:String, cat:String):Void{
        daSong = daSong.replace(" ", "_");

		if(FlxG.sound.music != null){FlxG.sound.music.stop();}

		FlxG.sound.playMusic(Paths.inst(daSong, cat), 0.6);

        voices.sounds = [];
        if(_song.voices != null && _song.voices.length > 0){
            for(i in 0..._song.voices.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, _song.voices[i], daSong, cat));
                FlxG.sound.list.add(voice);
                voices.add(voice);
            }
        }else{
            var voice = new FlxSound();
            FlxG.sound.list.add(voice);
            voices.add(voice);
        }
        

		FlxG.sound.music.pause();
		voices.pause();

		FlxG.sound.music.onComplete = function(){
			voices.pause();
            for(voice in voices.sounds){voice.time = 0;}
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

    function recalculateSteps():Int{
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }

        for(i in 0...Conductor.bpmChangeMap.length){
            if(FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime){
                lastChange = Conductor.bpmChangeMap[i];
            }
        }
    
        curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
        updateBeat();
    
        return curStep;
    }

    function resetSection(songBeginning:Bool = false):Void{
        updateSection();
    
        FlxG.sound.music.pause();
        for(voice in voices.sounds){voice.pause();}
    
        // Basically old shit from changeSection???
        FlxG.sound.music.time = sectionStartTime();
    
        if(songBeginning){
            FlxG.sound.music.time = 0;
            curSection = 0;
        }
    
        for(voice in voices.sounds){voice.time = FlxG.sound.music.time;}
        updateCurStep();
    
        updateSection();
    }

    function changeNoteSustain(value:Float):Void{
        var n = getNote(selNote[1]);

        if(n != null){
            n[2] += value;
            n[2] = Math.max(n[2], 0);
    
            if(n[2] <= 0 && n[3] > 0){n[3] = 0;}
    
            //trace(n);
        }

        updateSection();
    }

    function changeNoteHits(value:Int):Void{
        var n = getNote(selNote[1]);

        if(n != null){
            if(n[2] <= 0){changeNoteSustain(Conductor.stepCrochet);}

            n[3] += value;
            n[3] = Math.max(n[3], 0);
        }
        
        updateSection();
    }

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void{
		trace("||- Changed Section " + (sec) + " -||");
        trace("CurStep: " + curStep);
        trace("Length: " + _song.generalSection[curSection].lengthInSteps);

		if(_song.generalSection[sec] != null){
			trace('Not Null');
			curSection = sec;

			updateSection();

			if(updateMusic){
				FlxG.sound.music.pause();
				voices.pause();

				FlxG.sound.music.time = sectionStartTime();
                for(voice in voices.sounds){voice.time = FlxG.sound.music.time;}
				updateCurStep();
			}

			updateSection();
		}else{
            trace('Null Section');
        }

        trace('||- DUMBSHIT -||');
	}

    private function addGenSection(lengthInSteps:Int = 16):Void{
        var genSec:SwagGeneralSection = {
            bpm: _song.bpm,
            changeBPM: false,
    
            lengthInSteps: lengthInSteps,
    
            strumToFocus: _song.generalSection[curSection].strumToFocus,
            charToFocus: _song.generalSection[curSection].charToFocus
        };

        _song.generalSection.push(genSec);
    }

    private function addSection(strum:Int = 0, lengthInSteps:Int = 16, keys:Int = 4):Void{
        var sec:SwagSection = {
            charToSing: _song.sectionStrums[strum].charToSing,
            changeSing: false,
    
            keys: keys,
            changeKeys: false,
    
            altAnim: false,
    
            sectionNotes: []
        };

        _song.sectionStrums[strum].notes.push(sec);
    }

    private function newNoteData(isSelected:Bool = false):Array<Dynamic>{
        var n:Array<Dynamic> = [0, 0, 0, 0, null, {}];

        n[0] = getStrumTime(dArrow.y) + sectionStartTime();
        n[1] = Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE) % getStrumKeys(curStrum);

        if(isSelected){
            n[2] = selNote[1][2];
            n[3] = selNote[1][3];
            n[4] = selNote[1][4];
        }

        return n;
    }

    private function compNotes(n1:Array<Dynamic>, n2:Array<Dynamic>, specific:Bool = false):Bool{
        if(((n1[0] >= n2[0] - 5 && n1[0] <= n2[0] + 5) && n1[1] == n2[1]) || (specific && (n1 == n2))){
            return true;
        }else{
            return false;
        }
    }

    private function getNote(n:Array<Dynamic>, ?strum:Int):Array<Dynamic>{
        if(strum == null){strum = curStrum;}
        
        for(i in _song.sectionStrums[strum].notes[curSection].sectionNotes){
            if(compNotes(i, n)){
                return i;
            }else{
                var last:Array<Dynamic> = i;
                var nM:Array<Dynamic> = i[4];
                while(nM != null){
                    nM[0] = last[0] + last[2];

                    last = nM;
                    if(compNotes(nM, n)){
                        return nM;
                    }
                    nM = nM[4];
                }
            }
        }

        return null;
    }

    var curLast:Array<Dynamic> = null;
    var holdingNote:Bool = false;
    private function checkToHold():Void{
        var nAdd = getNote(newNoteData(true));

        if(nAdd != null){
            holdingNote = true;
            trace("Note Exist - (Deleting)");

            selNote = [curStrum, nAdd];
            curLast = nAdd;

            _song.sectionStrums[curStrum].notes[curSection].sectionNotes.remove(nAdd);
        }

        updateSection();
    }

    private function checkToAdd():Void{
        var nAdd = newNoteData();
        if(holdingNote){nAdd = newNoteData(true);}

        if(holdingNote){
            if(getNote(nAdd) == null){
                if(!compNotes(nAdd, curLast)){
                    trace("Null Note - (Adding)");

                    _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(nAdd);
                    selNote = [curStrum, nAdd];
                }
            }else{
                trace("Note Exist - (Undo)");
                _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(curLast);
            }
        }else{
            if(getNote(nAdd) == null){
                trace("Null Note - (Adding)");
                _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(nAdd);
                selNote = [curStrum, nAdd];
            }
        }

        holdingNote = false;
        
        updateSection();
    }
    private function checkSelNote(?nAdd:Dynamic = null){
        if(nAdd == null){nAdd = newNoteData();}

        for(i in _song.sectionStrums[curStrum].notes[curSection].sectionNotes){
            trace("|= Start Comparing =|");
            if(compNotes(i, nAdd)){
                trace("Note TRUE");
                selNote = [curStrum, i];
                break;
            }else{
                trace("Note FALSE | Searching for Merge Notes");
                var pBreak:Bool = false;

                var last:Array<Dynamic> = i;
                var n:Array<Dynamic> = i[4];
                while(n != null){
                    n[0] = last[0] + last[2] + (Conductor.stepCrochet * 0.75);

                    trace("Compare: " + n + " | " + nAdd);

                    last = n;
                    if(compNotes(n, nAdd)){
                        trace("This Note True");
                        selNote = [curStrum, n];
                        pBreak = true;
                        break;
                    }else{trace("This Note False");}
                    n = n[4];
                }
                if(pBreak){break;}
            }
        }      

        updateSection();
    }

    private function saveSong(){
		var json = {"song": _song};

		var data:String = Json.stringify(json);

		if((data != null) && (data.length > 0)){
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.replace(" ", "_") + "-" + _song.category + "-" + _song.difficulty + ".json");
		}
	}

	function onSaveComplete(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

    function getYfromStrum(strumTime:Float):Float{
        return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, curGrid.y, curGrid.y + curGrid.height);
    }

    function getStrumTime(yPos:Float):Float{
        return FlxMath.remapToRange(yPos, curGrid.y, curGrid.y + curGrid.height, 0, 16 * Conductor.stepCrochet);
    }

    function sectionStartTime():Float{
        var daBPM:Float = _song.bpm;
        var daPos:Float = 0;
        for(i in 0...curSection){
            if(_song.generalSection[i].changeBPM){
                daBPM = _song.generalSection[i].bpm;
            }
            daPos += 4 * (1000 * 60 / daBPM);
        }

        return daPos;
    }

    function getStrumKeys(strum:Int):Int{
        if(_song.sectionStrums[strum].notes[curSection].changeKeys){
            return _song.sectionStrums[strum].notes[curSection].keys;
        }else{
            return _song.sectionStrums[strum].keys;
        }
    }

    function copyLastSection(?sectionNum:Int = 1, ?strum:Int = 0){
        var daSec = FlxMath.maxInt(curSection, sectionNum);
    
        for(note in _song.sectionStrums[strum].notes[daSec - sectionNum].sectionNotes){
            var strumtime = note[0] + Conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
    
            var copN = newNoteData();
            copN[0] = strumtime;
            copN[1] = note[1];
            copN[2] = note[2];
            copN[3] = note[3];
            copN[4] = note[4];
            copN[5] = note[5];

            if(getNote(copN, strum) == null){_song.sectionStrums[strum].notes[daSec].sectionNotes.push(copN);}
        }
    
        updateSection();
    }

    function copyLastStrum(?sectionNum:Int = 1, ?strum:Int = 0){
        var daSec = FlxMath.maxInt(curSection, sectionNum);
    
        for(note in _song.sectionStrums[strum].notes[daSec - sectionNum].sectionNotes){
            var strumtime = note[0] + Conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
    
            var copN = newNoteData();
            copN[0] = strumtime;
            copN[1] = note[1];
            copN[2] = note[2];
            copN[3] = note[3];
            copN[4] = note[4];
            copN[5] = note[5];

            if(getNote(copN) == null){_song.sectionStrums[curStrum].notes[daSec].sectionNotes.push(copN);}
        }
    
        updateSection();
    }

    function mirrorNotes(?strum:Int = null){
        if(strum == null){strum = curStrum;}

        var secNotes = _song.sectionStrums[strum].notes[curSection].sectionNotes;
        trace("");
        trace("(" + strum + ") Section Notes: " + secNotes);
        for(n in secNotes){n[1] = (getStrumKeys(0) - 1) - n[1];}
        trace("(" + strum + ") Section Notes: " + secNotes);
        trace("");
        updateSection();
    }

    function syncNotes(){
        var allSection:Array<Array<Dynamic>> = [];

        for(i in 0..._song.sectionStrums.length){
            allSection.push(_song.sectionStrums[i].notes[curSection].sectionNotes);
            _song.sectionStrums[i].notes[curSection].sectionNotes = [];
        }

        for(ii in 0...allSection.length){
            for(i in 0..._song.sectionStrums.length){
                for(n in allSection[ii]){
                    var newNote = [n[0], n[1], n[2], n[3], n[4], n[5]];
                    if(getNote(newNote, i) == null){
                        _song.sectionStrums[i].notes[curSection].sectionNotes.push(newNote);
                    }
                }
            }
        }

        updateSection();
    }

    private function getFile(_onSelect:String->Void):Void{
        var fDialog = new FileDialog();
        fDialog.onSelect.add(function(str){_onSelect(str);});
        fDialog.browse();
	}

    var txtSong:FlxUIInputText;
    var txtCat:FlxUIInputText;
    var txtDiff:FlxUIInputText;
    var txtAspect:FlxUIInputText;
    var stpBPM:FlxUINumericStepper;
    var stpSpeed:FlxUINumericStepper;
    var stpStrum:FlxUINumericStepper;
    var stpCharID:FlxUINumericStepper;
    var chkLEFT:FlxUICheckBox;
    var stpCharX:FlxUINumericStepperCustom;
    var stpCharY:FlxUINumericStepperCustom;
    var stpCharSize:FlxUINumericStepper;
    var stpCharLayout:FlxUINumericStepper;
    var stpSecBPM:FlxUINumericStepper;
    var stpLength:FlxUINumericStepper;
    var stpSecStrum:FlxUINumericStepper;
    var stpSecChar:FlxUINumericStepper;
    var stpKeys:FlxUINumericStepper;
    var stpLastSec:FlxUINumericStepper;
    var stpLastSec2:FlxUINumericStepper;
    var stpLastStrm:FlxUINumericStepper;
    var stpSwapSec:FlxUINumericStepper;
    var chkALT:FlxUICheckBox;
    var chkKeys:FlxUICheckBox;
    var chkBPM:FlxUICheckBox;
    var stpStrumLine:FlxUINumericStepperCustom;
    var stpNoteData:FlxUINumericStepper;
    var stpNoteLength:FlxUINumericStepperCustom;
    var stpNoteHits:FlxUINumericStepper;
    var ddlNoteEvent:FlxUIDropDownMenu;
    var txtEvent1:FlxUIInputText;
    var txtEvent2:FlxUIInputText;
    var lblEventNote:FlxText;
    var lblEventInfo:FlxText;
    var stpSrmKeys:FlxUINumericStepper;
    var txtNoteStyle:FlxUIInputText;
    var lblCharsToSing:FlxText;
    var lblSecCharsToSing:FlxText;
    var lblNoteStyle:FlxText;
    var chkSwitchChars:FlxUICheckBox;
    var chkFocusChar:FlxUICheckBox;
    function addMENUTABS():Void{
        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "Song";

        var btnPlaySong:FlxButton = new FlxButton(5, 5, "Play Song", function(){SongListData.playSong(_song);}); tabMENU.add(btnPlaySong);
        btnPlaySong.setSize(Std.int((MENU.width - 10)), Std.int(btnPlaySong.height * 1.1));
        btnPlaySong.setGraphicSize(Std.int((MENU.width - 10)), Std.int(btnPlaySong.height * 1.1));
        btnPlaySong.centerOffsets();
        btnPlaySong.label.fieldWidth = btnPlaySong.width;
        btnPlaySong.label.height = btnPlaySong.height;

        var line1 = new FlxSprite(5, btnPlaySong.y + btnPlaySong.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line1);

        var lblSong = new FlxText(5, line1.y + line1.height + 5, 0, "SONG:", 8); tabMENU.add(lblSong);
        txtSong = new FlxUIInputText(lblSong.x + lblSong.width + 5, lblSong.y, Std.int(MENU.width - lblSong.width - 15), _song.song, 8); tabMENU.add(txtSong);
        txtSong.name = "SONG_NAME";

        var lblCat = new FlxText(lblSong.x, txtSong.y + txtSong.height + 5, 0, "CATEGORY:", 8); tabMENU.add(lblCat);
        txtCat = new FlxUIInputText(lblCat.x + lblCat.width + 5, lblCat.y, Std.int(MENU.width - lblCat.width - 15), _song.category, 8); tabMENU.add(txtCat);
        txtCat.name = "SONG_CATEGORY";

        var lblDiff = new FlxText(lblCat.x, txtCat.y + txtCat.height + 5, 0, "DIFFICULTY:", 8); tabMENU.add(lblDiff);
        txtDiff = new FlxUIInputText(lblDiff.x + lblDiff.width + 5, lblDiff.y, Std.int(MENU.width - lblDiff.width - 15), _song.difficulty, 8); tabMENU.add(txtDiff);
        txtDiff.name = "SONG_DIFFICULTY";

        var btnSave:FlxButton = new FlxButton(lblDiff.x, lblDiff.y + lblDiff.height + 5, "Save Song", function(){saveSong();}); tabMENU.add(btnSave);
        btnSave.setSize(Std.int((MENU.width / 3) - 8), Std.int(btnSave.height));
        btnSave.setGraphicSize(Std.int((MENU.width / 3) - 8), Std.int(btnSave.height));
        btnSave.centerOffsets();
        btnSave.label.fieldWidth = btnSave.width;

        var btnLoad:FlxButton = new FlxButton(btnSave.x + btnSave.width + 5, btnSave.y, "Load Song", function(){
            loadSong(_song.song, _song.category, _song.difficulty);
        }); tabMENU.add(btnLoad);
        btnLoad.setSize(Std.int((MENU.width / 3) - 5), Std.int(btnLoad.height));
        btnLoad.setGraphicSize(Std.int((MENU.width / 3) - 5), Std.int(btnLoad.height));
        btnLoad.centerOffsets();
        btnLoad.label.fieldWidth = btnLoad.width;

        var btnImport:FlxButton = new FlxButton(btnLoad.x + btnLoad.width + 5, btnLoad.y, "Import Song", function(){
            getFile(function(str){

            });
        }); tabMENU.add(btnImport);
        btnImport.setSize(Std.int((MENU.width / 3) - 8), Std.int(btnImport.height));
        btnImport.setGraphicSize(Std.int((MENU.width / 3) - 8), Std.int(btnImport.height));
        btnImport.centerOffsets();
        btnImport.label.fieldWidth = btnImport.width;

        var line2 = new FlxSprite(btnSave.x, btnSave.y + btnSave.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line2);

        var lblStrum = new FlxText(line2.x, line2.y + 7, Std.int(MENU.width * 0.4), "Strum to Play: ", 8); tabMENU.add(lblStrum);
        stpStrum = new FlxUINumericStepper(lblStrum.x + lblStrum.width, lblStrum.y, 1, _song.strumToPlay, 0, _song.sectionStrums.length - 1); tabMENU.add(stpStrum);
        stpStrum.name = "SONG_Strm";

        var lblSpeed = new FlxText(lblStrum.x, lblStrum.y + lblStrum.height + 5, Std.int(MENU.width * 0.4), "Speed: ", 8); tabMENU.add(lblSpeed);
        stpSpeed = new FlxUINumericStepper(lblSpeed.x + lblSpeed.width, lblSpeed.y, 0.1, _song.speed, 0.1, 10, 1); tabMENU.add(stpSpeed);
        stpSpeed.name = "SONG_Speed";
        
        var lblBPM = new FlxText(lblSpeed.x, stpSpeed.y + stpSpeed.height + 5, Std.int(MENU.width * 0.4), "BPM: ", 8); tabMENU.add(lblBPM);
        stpBPM = new FlxUINumericStepper(lblBPM.x + lblBPM.width, lblBPM.y, 1, _song.bpm, 5, 999); tabMENU.add(stpBPM);
        stpBPM.name = "SONG_BPM";

        var btnChStage:FlxButton = new FlxButton(stpStrum.x + stpStrum.width + 5, stpStrum.y, "Change Stage", function(){
            if(DDLMENU.alive && DDLMENU.selected_tab_id == "Stage"){
                DDLMENU.kill();
            }else{
                DDLMENU.revive();
                DDLMENU.showTabId("Stage");
            }
        }); tabMENU.add(btnChStage);
        btnChStage.setSize(Std.int((MENU.width / 3) - 8), Std.int(stpStrum.height));
        btnChStage.setGraphicSize(Std.int((MENU.width / 3) - 8), Std.int(stpStrum.height));
        btnChStage.centerOffsets();
        btnChStage.label.fieldWidth = btnChStage.width;
        btnChStage.label.size = 7;

        var btnChVoices:FlxButton = new FlxButton(stpSpeed.x + stpSpeed.width + 5, stpSpeed.y, "Change Voices", function(){
            if(DDLMENU.alive && DDLMENU.selected_tab_id == "Voices"){
                DDLMENU.kill();
            }else{
                DDLMENU.revive();
                DDLMENU.showTabId("Voices");
            }
        }); tabMENU.add(btnChVoices);
        btnChVoices.setSize(Std.int((MENU.width / 3) - 8), Std.int(stpSpeed.height));
        btnChVoices.setGraphicSize(Std.int((MENU.width / 3) - 8), Std.int(stpSpeed.height));
        btnChVoices.centerOffsets();
        btnChVoices.label.fieldWidth = btnChVoices.width;
        btnChVoices.label.size = 7;

        var line3 = new FlxSprite(5, lblBPM.y + lblBPM.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line3);

        var lblCharacters = new FlxText(5, line3.y + line3.height + 3, Std.int(MENU.width - 10), "Characters", 8); tabMENU.add(lblCharacters);
        lblCharacters.alignment = CENTER;

        chkFocusChar = new FlxUICheckBox(lblCharacters.x, lblCharacters.y + lblCharacters.height, null, null, "Focus Character ID", 100); tabMENU.add(chkFocusChar);

        var btnAddChar:FlxButton = new FlxButton(chkFocusChar.x, chkFocusChar.y + chkFocusChar.height + 5, "Add Character", function(){
            _song.characters.push(["Boyfriend", [100, 100], 1, false, "Default", "NORMAL", 0]);
            updateSection();
            updateCharacterValues();
        }); tabMENU.add(btnAddChar);
        btnAddChar.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnAddChar.height));
        btnAddChar.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnAddChar.height));
        btnAddChar.centerOffsets();
        btnAddChar.label.fieldWidth = btnAddChar.width;
        btnAddChar.color = FlxColor.fromRGB(82, 255, 128);
        btnAddChar.label.color = FlxColor.WHITE;

        var btnDelChar:FlxButton = new FlxButton(btnAddChar.x + btnAddChar.width + 5, btnAddChar.y, "Del Cur Character", function(){
            _song.characters.remove(_song.characters[Std.int(stpCharID.value)]);
            updateSection();
            updateCharacterValues();
        }); tabMENU.add(btnDelChar);
        btnDelChar.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelChar.height));
        btnDelChar.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelChar.height));
        btnDelChar.centerOffsets();
        btnDelChar.label.fieldWidth = btnDelChar.width;
        btnDelChar.color = FlxColor.fromRGB(255, 94, 94);
        btnDelChar.label.color = FlxColor.WHITE;

        var lblCharID = new FlxText(btnAddChar.x, btnAddChar.y + btnAddChar.height + 5, 0, "ID", 8); tabMENU.add(lblCharID);
        stpCharID = new FlxUINumericStepper(lblCharID.x + lblCharID.width + 5, lblCharID.y, 1, 0, -999, 999); tabMENU.add(stpCharID);
        stpCharID.name = "CHARACTER_ID";

        var btnCharacters:FlxButton = new FlxButton(stpCharID.x + stpCharID.width + 5, stpCharID.y, "Change Character", function(){
            if(DDLMENU.alive && DDLMENU.selected_tab_id == "Characters"){
                DDLMENU.kill();
            }else{
                DDLMENU.revive();
                DDLMENU.showTabId("Characters");
            }
        }); tabMENU.add(btnCharacters);
        btnCharacters.setSize(Std.int((MENU.width * 0.6) - 8), Std.int(stpCharID.height));
        btnCharacters.setGraphicSize(Std.int((MENU.width * 0.6) - 8), Std.int(stpCharID.height));
        btnCharacters.centerOffsets();
        btnCharacters.label.fieldWidth = btnCharacters.width;
        btnCharacters.label.size = 7;

        var lblAspect = new FlxText(lblCharID.x, lblCharID.y + lblCharID.height + 5, 0, "Aspect:", 8); tabMENU.add(lblAspect);
        txtAspect = new FlxUIInputText(lblAspect.x + lblAspect.width + 5, lblAspect.y, Std.int(MENU.width * 0.3), "", 8); tabMENU.add(txtAspect);
        txtAspect.name = "CHARACTER_ASPECT";

        chkLEFT = new FlxUICheckBox(txtAspect.x + txtAspect.width + 5, txtAspect.y - 1, null, null, "onRight?", 100); tabMENU.add(chkLEFT);

        var lblCharX = new FlxText(lblAspect.x, lblAspect.y + lblAspect.height + 5, 0, "X:", 8); tabMENU.add(lblCharX);
        stpCharX = new FlxUINumericStepperCustom(lblCharX.x + lblCharX.width + 5, lblCharX.y, 1, 0, -99999, 99999, 1); tabMENU.add(stpCharX);
        stpCharX.name = "CHARACTER_X";
        stpCharX.setWidth(120);

        var lblCharSize = new FlxText(stpCharX.x + stpCharX.width + 5, stpCharX.y, 0, "Size:", 8); tabMENU.add(lblCharSize);
        stpCharSize = new FlxUINumericStepper(lblCharSize.x + lblCharSize.width + 10, lblCharSize.y, 0.1, 1, 0, 999, 1); tabMENU.add(stpCharSize);
        stpCharSize.name = "CHARACTER_SIZE";

        var lblCharY = new FlxText(lblCharX.x, lblCharX.y + lblCharX.height + 5, 0, "Y:", 8); tabMENU.add(lblCharY);
        stpCharY = new FlxUINumericStepperCustom(lblCharY.x + lblCharY.width + 5, lblCharY.y, 1, 0, -99999, 99999, 1); tabMENU.add(stpCharY);
        stpCharY.name = "CHARACTER_Y";
        stpCharY.setWidth(120);

        var lblCharLayout = new FlxText(stpCharY.x + stpCharY.width + 5, stpCharY.y, 0, "Layout:", 8); tabMENU.add(lblCharLayout);
        stpCharLayout = new FlxUINumericStepper(lblCharLayout.x + lblCharLayout.width + 5, lblCharLayout.y, 1, 0, -999, 999); tabMENU.add(stpCharLayout);
        stpCharLayout.name = "CHARACTER_LAYOUT";

        var line4 = new FlxSprite(5, lblCharY.y + lblCharY.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line4);

        var btnClearSong:FlxButton = new FlxButton(5, line4.y + line4.height + 5, "Clear Song Notes", function(){
            for(i in _song.sectionStrums){
                for(ii in i.notes){
                    ii.sectionNotes = [];
                }
            }
            updateSection();
        }); tabMENU.add(btnClearSong);
        btnClearSong.setSize(Std.int((MENU.width - 15)), Std.int(btnClearSong.height));
        btnClearSong.setGraphicSize(Std.int((MENU.width - 15)), Std.int(btnClearSong.height));
        btnClearSong.centerOffsets();
        btnClearSong.label.fieldWidth = btnClearSong.width;

        var stpCSongStrm = new FlxUINumericStepper(btnClearSong.x, btnClearSong.y + btnClearSong.height + 8, 1, 0, 0, 999); tabMENU.add(stpCSongStrm);
        stpCSongStrm.name = "Strums_Length";
        var btnClearSongStrum:FlxButton = new FlxButton(stpCSongStrm.x + stpCSongStrm.width + 5, stpCSongStrm.y - 3, "Clear Song Strum Notes", function(){
            if(_song.sectionStrums[Std.int(stpCSongStrm.value)] != null){
                for(i in _song.sectionStrums[Std.int(stpCSongStrm.value)].notes){
                    i.sectionNotes = [];
                }
            }

            updateSection();
        }); tabMENU.add(btnClearSongStrum);
        btnClearSongStrum.setSize(Std.int((MENU.width - 10) - stpCSongStrm.width), Std.int(btnClearSongStrum.height));
        btnClearSongStrum.setGraphicSize(Std.int((MENU.width - 10) - stpCSongStrm.width), Std.int(btnClearSongStrum.height));
        btnClearSongStrum.centerOffsets();
        btnClearSongStrum.label.fieldWidth = btnClearSongStrum.width;

        //

        var tabSTRUM = new FlxUI(null, MENU);
        tabSTRUM.name = "Section/Strum";

        var lblStrum = new FlxText(5, 5, MENU.width - 10, "Current Strum"); tabSTRUM.add(lblStrum);
        lblStrum.alignment = CENTER;

        var btnStrmToBack:FlxButton = new FlxButton(lblStrum.x, lblStrum.y + lblStrum.height + 5, "Send to Back", function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum - 1;
            if(index < 0){index = _song.sectionStrums.length - 1;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToBack);
        btnStrmToBack.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnStrmToBack.height));
        btnStrmToBack.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnStrmToBack.height));
        btnStrmToBack.centerOffsets();
        btnStrmToBack.label.fieldWidth = btnStrmToBack.width;
        btnStrmToBack.color = FlxColor.fromRGB(214, 212, 71);
        btnStrmToBack.label.color = FlxColor.WHITE;

        var btnStrmToFront:FlxButton = new FlxButton(btnStrmToBack.x + btnStrmToBack.width + 5, btnStrmToBack.y, "Send to Front", function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum + 1;
            if(index >= _song.sectionStrums.length){index = 0;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToFront);
        btnStrmToFront.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnStrmToFront.height));
        btnStrmToFront.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnStrmToFront.height));
        btnStrmToFront.centerOffsets();
        btnStrmToFront.label.fieldWidth = btnStrmToFront.width;
        btnStrmToFront.color = FlxColor.fromRGB(214, 212, 71);
        btnStrmToFront.label.color = FlxColor.WHITE;

        var lblKeys = new FlxText(btnStrmToBack.x, btnStrmToBack.y + btnStrmToBack.height + 5, 0, "KEYS: ", 8); tabSTRUM.add(lblKeys);
        stpSrmKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpSrmKeys);
        stpSrmKeys.name = "STRUM_KEYS";

        var lblStyle = new FlxText(stpSrmKeys.x + stpSrmKeys.width + 5, stpSrmKeys.y + 2, 0, "Style:", 8); tabSTRUM.add(lblStyle);
        var btnBackStyle:FlxButton = new FlxButton(lblStyle.x + lblStyle.width, lblStyle.y - 2, "<", function(){
            var styles = Note.getStyles();
            var id = 0;

            for(i in 0...styles.length){
                if(styles[i] == _song.sectionStrums[curStrum].noteStyle){id = i - 1;}
            }

            if(id < 0){id = styles.length - 1;}
            if(id >= styles.length){id = 0;}

            _song.sectionStrums[curStrum].noteStyle = styles[id];
            lblNoteStyle.text = _song.sectionStrums[curStrum].noteStyle;
            
            updateSection();
        }); tabSTRUM.add(btnBackStyle);
        btnBackStyle.setSize(20, Std.int(btnBackStyle.height));
        btnBackStyle.setGraphicSize(20, Std.int(btnBackStyle.height));
        btnBackStyle.centerOffsets();
        btnBackStyle.label.fieldWidth = btnBackStyle.width;

        var backText = new FlxSprite(btnBackStyle.x + btnBackStyle.width, btnBackStyle.y); tabSTRUM.add(backText);
        lblNoteStyle = new FlxText(backText.x , backText.y, 60, _song.sectionStrums[curStrum].noteStyle, 8); tabSTRUM.add(lblNoteStyle);
        lblNoteStyle.color = FlxColor.BLACK;
        lblNoteStyle.alignment = CENTER;
        lblNoteStyle.autoSize = false;
        lblNoteStyle.wordWrap = false;
        backText.setSize(Std.int(lblNoteStyle.fieldWidth), Std.int(btnBackStyle.height));
        backText.makeGraphic(Std.int(lblNoteStyle.fieldWidth), Std.int(btnBackStyle.height));

        var btnFrontStyle:FlxButton = new FlxButton(lblNoteStyle.x + lblNoteStyle.width, backText.y, ">", function(){
            var styles = Note.getStyles();
            var id = 0;

            for(i in 0...styles.length){
                if(styles[i] == _song.sectionStrums[curStrum].noteStyle){id = i + 1;}
            }

            if(id < 0){id = styles.length - 1;}
            if(id >= styles.length){id = 0;}

            _song.sectionStrums[curStrum].noteStyle = styles[id];
            lblNoteStyle.text = _song.sectionStrums[curStrum].noteStyle;
            
            updateSection();
        }); tabSTRUM.add(btnFrontStyle);
        btnFrontStyle.setSize(20, Std.int(btnFrontStyle.height));
        btnFrontStyle.setGraphicSize(20, Std.int(btnFrontStyle.height));
        btnFrontStyle.centerOffsets();
        btnFrontStyle.label.fieldWidth = btnFrontStyle.width;

        var lblAddChar = new FlxText(lblKeys.x, btnBackStyle.y + btnBackStyle.height + 7, 0, "Char ID: "); tabSTRUM.add(lblAddChar);
        var stpCharsID = new FlxUINumericStepper(lblAddChar.x + lblAddChar.width, lblAddChar.y, 1, 0, -999, 999); tabSTRUM.add(stpCharsID);
        stpCharsID.name = "Chars_Length";
        var btnAddCharToSing:FlxButton = new FlxButton(stpCharsID.x + stpCharsID.width + 5, stpCharsID.y - 3, "+", function(){
            if(!_song.sectionStrums[curStrum].charToSing.contains(Std.int(stpCharsID.value))){
                _song.sectionStrums[curStrum].charToSing.push(Std.int(stpCharsID.value));
            }
            
            updateStrumValues();
        }); tabSTRUM.add(btnAddCharToSing);
        btnAddCharToSing.setSize(20, Std.int(btnAddCharToSing.height));
        btnAddCharToSing.setGraphicSize(20, Std.int(btnAddCharToSing.height));
        btnAddCharToSing.centerOffsets();
        btnAddCharToSing.label.fieldWidth = btnAddCharToSing.width;
        btnAddCharToSing.color = FlxColor.fromRGB(94, 255, 99);

        var btnDelCharToSing:FlxButton = new FlxButton(btnAddCharToSing.x + btnAddCharToSing.width + 5, btnAddCharToSing.y, "-", function(){
            if(_song.sectionStrums[curStrum].charToSing.contains(Std.int(stpCharsID.value))){
                _song.sectionStrums[curStrum].charToSing.remove(Std.int(stpCharsID.value));
            }

            updateStrumValues();
        }); tabSTRUM.add(btnDelCharToSing);
        btnDelCharToSing.setSize(20, Std.int(btnDelCharToSing.height));
        btnDelCharToSing.setGraphicSize(20, Std.int(btnDelCharToSing.height));
        btnDelCharToSing.centerOffsets();
        btnDelCharToSing.label.fieldWidth = btnDelCharToSing.width;
        btnDelCharToSing.color = FlxColor.fromRGB(255, 94, 94);

        lblCharsToSing = new FlxText(lblAddChar.x, btnAddCharToSing.y + btnAddCharToSing.height + 5, 0, "Characters to Sing:"); tabSTRUM.add(lblCharsToSing);

        var line1 = new FlxSprite(lblCharsToSing.x, lblCharsToSing.y + (lblCharsToSing.height * 4) + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabSTRUM.add(line1);

        var lblGeneralSection = new FlxText(line1.x, line1.y + 5, MENU.width - 10, "General Section"); tabSTRUM.add(lblGeneralSection);
        lblGeneralSection.alignment = CENTER;

        var lblBPM = new FlxText(lblGeneralSection.x, lblGeneralSection.y + lblGeneralSection.height + 5, 0, "BPM: ", 8); tabSTRUM.add(lblBPM);
        stpSecBPM = new FlxUINumericStepper(lblBPM.x + lblBPM.width, lblBPM.y, 1, _song.bpm, 5, 999); tabSTRUM.add(stpSecBPM);
        stpSecBPM.name = "GENERALSEC_BPM";
        chkBPM = new FlxUICheckBox(stpSecBPM.x + stpSecBPM.width + 5, stpSecBPM.y - 1, null, null, "Change BPM", 100); tabSTRUM.add(chkBPM);
		chkBPM.checked = _song.generalSection[curSection].changeBPM;

        var lblLength = new FlxText(lblBPM.x, lblBPM.y + lblBPM.height + 10, 0, "Section Length (In steps): ", 8); tabSTRUM.add(lblLength);
        stpLength = new FlxUINumericStepper(lblLength.x + lblLength.width, lblLength.y, 4, _song.generalSection[curSection].lengthInSteps, 0, 999, 0); tabSTRUM.add(stpLength);
        stpLength.name = "GENERALSEC_LENGTH";

        var lblStrum = new FlxText(lblLength.x, lblLength.y + lblLength.height + 10, 0, "Strum to Focus: ", 8); tabSTRUM.add(lblStrum);
        stpSecStrum = new FlxUINumericStepper(lblStrum.x + lblStrum.width, lblStrum.y, 1, _song.generalSection[curSection].strumToFocus, 0, 999); tabSTRUM.add(stpSecStrum);
        stpSecStrum.name = "GENERALSEC_STRUMTOFOCUS";

        var lblChar = new FlxText(stpSecStrum.x + stpSecStrum.width + 5, stpSecStrum.y, 0, "Char ID: ", 8); tabSTRUM.add(lblChar);
        stpSecChar = new FlxUINumericStepper(lblChar.x + lblChar.width, lblChar.y, 1, _song.generalSection[curSection].charToFocus, 0, 999); tabSTRUM.add(stpSecChar);
        stpSecChar.name = "GENERALSEC_CHARTOFOCUS";

        var line2 = new FlxSprite(lblStrum.x, lblStrum.y + lblStrum.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabSTRUM.add(line2);

        var lblStrumlSection = new FlxText(line2.x, line2.y + 5, MENU.width - 10, "Current Strum Section"); tabSTRUM.add(lblStrumlSection);
        lblStrumlSection.alignment = CENTER;

        chkALT = new FlxUICheckBox(lblStrumlSection.x, lblStrumlSection.y + lblStrumlSection.height + 5, null, null, "Change ALT"); tabSTRUM.add(chkALT);
        chkALT.checked = _song.sectionStrums[curStrum].notes[curSection].altAnim;

        var lblKeys = new FlxText(chkALT.x, chkALT.y + chkALT.height + 10, 0, "KEYS: ", 8); tabSTRUM.add(lblKeys);
        stpKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpKeys);
        stpKeys.name = "STRUMSEC_KEYS";
        chkKeys = new FlxUICheckBox(stpKeys.x + stpKeys.width + 5, stpKeys.y - 1, null, null, "Change Keys"); tabSTRUM.add(chkKeys);
        chkKeys.checked = _song.sectionStrums[curStrum].notes[curSection].changeKeys;

        var btnDelAllSec:FlxButton = new FlxButton(lblKeys.x, lblKeys.y + lblKeys.height + 5, "Clear All Section", function(){
            for(strum in _song.sectionStrums){strum.notes[curSection].sectionNotes = [];}
            updateSection();
        }); tabSTRUM.add(btnDelAllSec);
        btnDelAllSec.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelAllSec.height));
        btnDelAllSec.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelAllSec.height));
        btnDelAllSec.centerOffsets();
        btnDelAllSec.label.fieldWidth = btnDelAllSec.width;
        btnDelAllSec.color = FlxColor.fromRGB(255, 94, 94);
        btnDelAllSec.label.color = FlxColor.WHITE;

        var btnDelStrSec:FlxButton = new FlxButton(btnDelAllSec.x + btnDelAllSec.width + 5, btnDelAllSec.y, "Clear Strum Section", function(){
            _song.sectionStrums[curStrum].notes[curSection].sectionNotes = [];
            updateSection();
        }); tabSTRUM.add(btnDelStrSec);
        btnDelStrSec.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelStrSec.height));
        btnDelStrSec.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnDelStrSec.height));
        btnDelStrSec.centerOffsets();
        btnDelStrSec.label.fieldWidth = btnDelStrSec.width;
        btnDelStrSec.color = FlxColor.fromRGB(255, 94, 94);
        btnDelStrSec.label.color = FlxColor.WHITE;

        var btnCopyAllSec:FlxButton = new FlxButton(btnDelAllSec.x, btnDelAllSec.y + btnDelAllSec.height + 5, "Copy Section", function(){
            copySection = [curSection, []];
            for(i in 0..._song.sectionStrums.length){
                copySection[1].push([]);
                for(n in _song.sectionStrums[i].notes[curSection].sectionNotes){                    
                    var s = newNoteData();
                    s[0] = n[0] - sectionStartTime();
                    s[1] = n[1];
                    s[2] = n[2];
                    s[3] = n[3];
                    s[4] = n[4];
                    s[5] = n[5];
                    
                    copySection[1][i].push(s);
                }
            }
        }); tabSTRUM.add(btnCopyAllSec);
        btnCopyAllSec.setSize(Std.int((MENU.width / 3) - 10), Std.int(btnCopyAllSec.height));
        btnCopyAllSec.setGraphicSize(Std.int((MENU.width / 3) - 10), Std.int(btnCopyAllSec.height));
        btnCopyAllSec.centerOffsets();
        btnCopyAllSec.label.fieldWidth = btnCopyAllSec.width;
        btnCopyAllSec.color = FlxColor.fromRGB(10, 25, 191);
        btnCopyAllSec.label.color = FlxColor.WHITE;

        var btnPasteAllSec:FlxButton = new FlxButton(btnCopyAllSec.x + btnCopyAllSec.width + 5, btnCopyAllSec.y, "Paste Section", function(){
            for(i in 0..._song.sectionStrums.length){
                if(copySection[1][i] != null){
                    var secNotes:Array<Dynamic> = copySection[1][i];
                    for(n in secNotes){
                        var s = newNoteData();
                        s[0] = n[0] + sectionStartTime();
                        s[1] = n[1];
                        s[2] = n[2];
                        s[3] = n[3];
                        s[4] = n[4];
                        s[5] = n[5];

                        if(getNote(s, i) == null){_song.sectionStrums[i].notes[curSection].sectionNotes.push(s);}
                    }
                }
            }
            updateSection();
        }); tabSTRUM.add(btnPasteAllSec);
        btnPasteAllSec.setSize(Std.int((MENU.width / 3) - 6), Std.int(btnPasteAllSec.height));
        btnPasteAllSec.setGraphicSize(Std.int((MENU.width / 3) - 6), Std.int(btnPasteAllSec.height));
        btnPasteAllSec.centerOffsets();
        btnPasteAllSec.label.fieldWidth = btnPasteAllSec.width;
        btnPasteAllSec.color = FlxColor.fromRGB(10, 25, 191);
        btnPasteAllSec.label.color = FlxColor.WHITE;

        var btnSetAllSec:FlxButton = new FlxButton(btnPasteAllSec.x + btnPasteAllSec.width + 5, btnPasteAllSec.y, "Set Last Section", function(){
            stpLastSec.value = curSection - copySection[0];
            stpLastSec2.value = curSection - copySection[0];
        }); tabSTRUM.add(btnSetAllSec);
        btnSetAllSec.setSize(Std.int((MENU.width / 3) - 3), Std.int(btnSetAllSec.height));
        btnSetAllSec.setGraphicSize(Std.int((MENU.width / 3) - 3), Std.int(btnSetAllSec.height));
        btnSetAllSec.centerOffsets();
        btnSetAllSec.label.fieldWidth = btnSetAllSec.width;
        btnSetAllSec.color = FlxColor.fromRGB(10, 25, 191);
        btnSetAllSec.label.color = FlxColor.WHITE;

        var btnCopLastAllSec:FlxButton = new FlxButton(btnCopyAllSec.x, btnCopyAllSec.y + btnCopyAllSec.height + 5, "Paste Last Section", function(){
            for(i in 0..._song.sectionStrums.length){copyLastSection(Std.int(stpLastSec.value), i);}
        }); tabSTRUM.add(btnCopLastAllSec);
        btnCopLastAllSec.setSize(Std.int((MENU.width / 2) - 20), Std.int(btnCopLastAllSec.height));
        btnCopLastAllSec.setGraphicSize(Std.int((MENU.width / 2) - 20), Std.int(btnCopLastAllSec.height));
        btnCopLastAllSec.centerOffsets();
        btnCopLastAllSec.label.fieldWidth = btnCopLastAllSec.width;
        btnCopLastAllSec.color = FlxColor.fromRGB(10, 25, 191);
        btnCopLastAllSec.label.color = FlxColor.WHITE;
        stpLastSec = new FlxUINumericStepper(btnCopLastAllSec.x + btnCopLastAllSec.width + 5, btnCopLastAllSec.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec);

        var btnCopLastStrum:FlxButton = new FlxButton(btnCopLastAllSec.x, btnCopLastAllSec.y + btnCopLastAllSec.height + 5, "Paste Last Strum", function(){
            copyLastStrum(Std.int(stpLastSec2.value), Std.int(stpLastStrm.value));
        }); tabSTRUM.add(btnCopLastStrum);
        btnCopLastStrum.setSize(Std.int((MENU.width / 2) - 20), Std.int(btnCopLastStrum.height));
        btnCopLastStrum.setGraphicSize(Std.int((MENU.width / 2) - 20), Std.int(btnCopLastStrum.height));
        btnCopLastStrum.centerOffsets();
        btnCopLastStrum.label.fieldWidth = btnCopLastStrum.width;
        btnCopLastStrum.color = FlxColor.fromRGB(10, 25, 191);
        btnCopLastStrum.label.color = FlxColor.WHITE;
        stpLastSec2 = new FlxUINumericStepper(btnCopLastStrum.x + btnCopLastStrum.width + 5, btnCopLastStrum.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec2);
        stpLastStrm = new FlxUINumericStepper(stpLastSec2.x + stpLastSec2.width + 5, stpLastSec2.y, 1, 0, 0, 999); tabSTRUM.add(stpLastStrm);

        var btnSwapStrum:FlxButton = new FlxButton(btnCopLastStrum.x, btnCopLastStrum.y + btnCopLastStrum.height + 5, "Swap Strum", function(){
            var sec1 = _song.sectionStrums[curStrum].notes[curSection].sectionNotes;
            var sec2 = _song.sectionStrums[Std.int(stpSwapSec.value)].notes[curSection].sectionNotes;

            _song.sectionStrums[curStrum].notes[curSection].sectionNotes = sec2;
            _song.sectionStrums[Std.int(stpSwapSec.value)].notes[curSection].sectionNotes = sec1;

            updateSection();
        }); tabSTRUM.add(btnSwapStrum);
        btnSwapStrum.setSize(Std.int((MENU.width / 2) - 3), Std.int(btnSwapStrum.height));
        btnSwapStrum.setGraphicSize(Std.int((MENU.width / 2) - 3), Std.int(btnSwapStrum.height));
        btnSwapStrum.centerOffsets();
        btnSwapStrum.label.fieldWidth = btnSwapStrum.width;
        btnSwapStrum.color = FlxColor.fromRGB(69, 214, 173);
        btnSwapStrum.label.color = FlxColor.WHITE;
        stpSwapSec = new FlxUINumericStepper(btnSwapStrum.x + btnSwapStrum.width + 5, btnSwapStrum.y + 3, 1, 0, 0, 999); tabSTRUM.add(stpSwapSec);
        stpSwapSec.name = "Strums_Length";

        var btnMirror:FlxButton = new FlxButton(btnSwapStrum.x, btnSwapStrum.y + btnSwapStrum.height + 5, "Mirror Strum", function(){
            trace("|-Strum Mirror-|");
            mirrorNotes();
            trace("|-Strum Mirror End-|");
        }); tabSTRUM.add(btnMirror);
        btnMirror.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnMirror.height));
        btnMirror.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnMirror.height));
        btnMirror.centerOffsets();
        btnMirror.label.fieldWidth = btnMirror.width;
        btnMirror.color = FlxColor.fromRGB(214, 212, 71);
        btnMirror.label.color = FlxColor.WHITE;

        var btnMirrorAll:FlxButton = new FlxButton(btnMirror.x + btnMirror.width + 5, btnMirror.y, "Mirror Section", function(){
            trace("|-Section Mirror-|");
            for(i in 0..._song.sectionStrums.length){mirrorNotes(i);}
            trace("|-Section Mirror End-|");
        }); tabSTRUM.add(btnMirrorAll);
        btnMirrorAll.setSize(Std.int((MENU.width / 2) - 8), Std.int(btnMirrorAll.height));
        btnMirrorAll.setGraphicSize(Std.int((MENU.width / 2) - 8), Std.int(btnMirrorAll.height));
        btnMirrorAll.centerOffsets();
        btnMirrorAll.label.fieldWidth = btnMirrorAll.width;
        btnMirrorAll.color = FlxColor.fromRGB(214, 212, 71);
        btnMirrorAll.label.color = FlxColor.WHITE;

        var btnSync:FlxButton = new FlxButton(btnMirror.x, btnMirror.y + btnMirror.height + 5, "Synchronize Notes", function(){
            syncNotes();
        }); tabSTRUM.add(btnSync);
        btnSync.setSize(Std.int((MENU.width) - 10), Std.int(btnSync.height));
        btnSync.setGraphicSize(Std.int((MENU.width) - 10), Std.int(btnSync.height));
        btnSync.centerOffsets();
        btnSync.label.fieldWidth = btnSync.width;
        btnSync.color = FlxColor.fromRGB(214, 212, 71);
        btnSync.label.color = FlxColor.WHITE;

        var btnMiguel:FlxButton = new FlxButton(btnSync.x, btnSync.y + btnSync.height + 5, "Miguel2", function(){}); tabSTRUM.add(btnMiguel);
        btnMiguel.setSize(Std.int((MENU.width) - 10), Std.int(btnMiguel.height));
        btnMiguel.setGraphicSize(Std.int((MENU.width) - 10), Std.int(btnMiguel.height));
        btnMiguel.centerOffsets();
        btnMiguel.label.fieldWidth = btnMiguel.width;
        btnMiguel.color = FlxColor.fromRGB(0, 0, 255);
        btnMiguel.label.color = FlxColor.WHITE;

        chkSwitchChars = new FlxUICheckBox(btnMiguel.x, btnMiguel.y + btnMiguel.height + 5, null, null, "Change Characters to Sing", 0); tabSTRUM.add(chkSwitchChars);

        var lblAddSecChar = new FlxText(chkSwitchChars.x, chkSwitchChars.y + chkSwitchChars.height + 5, 0, "Char ID: "); tabSTRUM.add(lblAddSecChar);
        var stpCharsSecID = new FlxUINumericStepper(lblAddSecChar.x + lblAddSecChar.width, lblAddSecChar.y, 1, 0, -999, 999); tabSTRUM.add(stpCharsSecID);
        stpCharsSecID.name = "Chars_Length";
        var btnAddSecCharToSing:FlxButton = new FlxButton(stpCharsSecID.x + stpCharsSecID.width + 5, stpCharsSecID.y - 3, "+", function(){
            if(!_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(Std.int(stpCharsSecID.value))){
                _song.sectionStrums[curStrum].notes[curSection].charToSing.push(Std.int(stpCharsSecID.value));
            }
            
            updateSectionValues();
        }); tabSTRUM.add(btnAddSecCharToSing);
        btnAddSecCharToSing.setSize(20, Std.int(btnAddSecCharToSing.height));
        btnAddSecCharToSing.setGraphicSize(20, Std.int(btnAddSecCharToSing.height));
        btnAddSecCharToSing.centerOffsets();
        btnAddSecCharToSing.label.fieldWidth = btnAddSecCharToSing.width;
        btnAddSecCharToSing.color = FlxColor.fromRGB(94, 255, 99);

        var btnDelSecCharToSing:FlxButton = new FlxButton(btnAddSecCharToSing.x + btnAddSecCharToSing.width + 5, btnAddSecCharToSing.y, "-", function(){
            if(_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(Std.int(stpCharsSecID.value))){
                _song.sectionStrums[curStrum].notes[curSection].charToSing.remove(Std.int(stpCharsSecID.value));
            }

            updateSectionValues();
        }); tabSTRUM.add(btnDelSecCharToSing);
        btnDelSecCharToSing.setSize(20, Std.int(btnDelSecCharToSing.height));
        btnDelSecCharToSing.setGraphicSize(20, Std.int(btnDelSecCharToSing.height));
        btnDelSecCharToSing.centerOffsets();
        btnDelSecCharToSing.label.fieldWidth = btnDelSecCharToSing.width;
        btnDelSecCharToSing.color = FlxColor.fromRGB(255, 94, 94);

        lblSecCharsToSing = new FlxText(lblAddSecChar.x, btnAddSecCharToSing.y + btnAddSecCharToSing.height + 5, 0, "Characters to Sing:"); tabSTRUM.add(lblSecCharsToSing);

        MENU.addGroup(tabSTRUM);

        //

        var tabNOTE = new FlxUI(null, MENU);
        tabNOTE.name = "Note";

        var lblNote = new FlxText(5, 5, MENU.width - 10, "Note"); tabNOTE.add(lblNote);
        lblNote.alignment = CENTER;

        var lblStrumLine = new FlxText(lblNote.x, lblNote.y + lblNote.height + 5, 0, "StrumTime: ", 8); tabNOTE.add(lblStrumLine);
        stpStrumLine = new FlxUINumericStepperCustom(lblStrumLine.x + lblStrumLine.width, lblStrumLine.y, Conductor.stepCrochet * 0.5, 0, 0, 999999, 10); tabNOTE.add(stpStrumLine);
        stpStrumLine.name = "NOTE_STRUMTIME";
        stpStrumLine.setWidth(120);

        var lblNoteData = new FlxText(lblStrumLine.x, lblStrumLine.y + lblStrumLine.height + 5, 0, "Note Data: ", 8); tabNOTE.add(lblNoteData);
        stpNoteData = new FlxUINumericStepper(lblNoteData.x + lblNoteData.width, lblNoteData.y, 1, 0, 0, 999); tabNOTE.add(stpNoteData);
        stpNoteData.name = "NOTE_DATA";

        var lblNoteLength = new FlxText(lblNoteData.x, lblNoteData.y + lblNoteData.height + 10, 0, "Note Length: ", 8); tabNOTE.add(lblNoteLength);
        stpNoteLength = new FlxUINumericStepperCustom(lblNoteLength.x + lblNoteLength.width, lblNoteLength.y, Conductor.stepCrochet * 0.5, 0, 0, 999999, 10); tabNOTE.add(stpNoteLength);
        stpNoteLength.name = "NOTE_LENGTH";
        stpNoteLength.setWidth(120);

        var lblNoteHits = new FlxText(lblNoteLength.x, lblNoteLength.y + lblNoteLength.height + 5, 0, "Note Hits: ", 8); tabNOTE.add(lblNoteHits);
        stpNoteHits = new FlxUINumericStepper(lblNoteHits.x + lblNoteHits.width, lblNoteHits.y, 1, 0, 0, 999); tabNOTE.add(stpNoteHits);
        stpNoteHits.name = "NOTE_HITS";

        var btnMerge:FlxButton = new FlxButton(lblNoteHits.x, lblNoteHits.y + lblNoteHits.height + 10, "Add Merge Note", function(){
            var note = getNote(selNote[1], curStrum);
            if(note != null){note[4] = newNoteData();}

            updateSection();
        }); tabNOTE.add(btnMerge);
        btnMerge.setSize(Std.int(MENU.width - 10), Std.int(btnMerge.height));
        btnMerge.setGraphicSize(Std.int(MENU.width - 10), Std.int(btnMerge.height));
        btnMerge.centerOffsets();
        btnMerge.label.fieldWidth = btnMerge.width;
        btnMerge.color = FlxColor.fromRGB(133, 233, 255);

        var lblEvent = new FlxText(btnMerge.x, btnMerge.y + btnMerge.height + 5, Std.int(MENU.width - 10), "Event Note", 8); tabNOTE.add(lblEvent);
        lblEvent.alignment = CENTER;

        lblEventNote = new FlxText(lblEvent.x, lblEvent.y + lblEvent.height + 5, Std.int(MENU.width - 10), "Note Events: 0/0", 8); tabNOTE.add(lblEventNote);
        lblEventNote.alignment = CENTER;

        txtEvent1 = new FlxUIInputText(lblEventNote.x, lblEventNote.y + lblEventNote.height + 5, Std.int((lblEventNote.width / 2) - 10), "", 8); tabNOTE.add(txtEvent1);
        txtEvent2 = new FlxUIInputText(txtEvent1.x + txtEvent1.width + 1, txtEvent1.y, Std.int((lblEventNote.width / 2) - 10), "", 8); tabNOTE.add(txtEvent2);
        var btnAdd:FlxButton = new FlxButton(txtEvent2.x + txtEvent2.width, txtEvent2.y - 2, "+", function(){}); tabNOTE.add(btnAdd);
        btnAdd.setSize(20, Std.int(txtEvent2.height + 4));
        btnAdd.setGraphicSize(20, Std.int(txtEvent2.height + 4));
        btnAdd.centerOffsets();
        btnAdd.label.fieldWidth = btnAdd.width;
        btnAdd.label.size = 6;
        btnAdd.color = FlxColor.fromRGB(102, 255, 166);

        ddlNoteEvent = new FlxUIDropDownMenu(txtEvent1.x, txtEvent1.y + txtEvent1.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(["NONE"], true)); tabNOTE.add(ddlNoteEvent);
        var btnDel:FlxButton = new FlxButton(ddlNoteEvent.x + ddlNoteEvent.width, ddlNoteEvent.y, "-", function(){}); tabNOTE.add(btnDel);
        btnDel.setSize(20, 20);
        btnDel.setGraphicSize(20, 20);
        btnDel.centerOffsets();
        btnDel.label.fieldWidth = btnDel.width;
        btnDel.label.size = 6;
        btnDel.color = FlxColor.fromRGB(255, 102, 102);

        lblEventInfo = new FlxText(ddlNoteEvent.x, ddlNoteEvent.y + ddlNoteEvent.height + 5, Std.int(MENU.width - 10), "Event Info"); tabNOTE.add(lblEventInfo);
        
        MENU.addGroup(tabNOTE);

        //

        MENU.addGroup(tabMENU);
        MENU.scrollFactor.set();
        MENU.showTabId("Song");
    }

    var ddlStages:FlxUIDropDownMenu;
    var ddlVoices:FlxUIDropDownMenu;
    var ddlCharacters:FlxUIDropDownMenu;
    function addDDLTABS():Void{
        var tabStage = new FlxUI(null, DDLMENU);
        tabStage.name = "Stage";

        var lblStages = new FlxText(5, 5, DDLMENU.width - 10, "Stage", 8); tabStage.add(lblStages);
        lblStages.alignment = CENTER;
        ddlStages = new FlxUIDropDownMenu(lblStages.x, lblStages.y + lblStages.height + 3, FlxUIDropDownMenu.makeStrIdLabelArray(Stage.getStages(), true)); tabStage.add(ddlStages);
        ddlStages.selectedLabel = _song.stage;
        ddlStages.name = "STAGES";

        DDLMENU.addGroup(tabStage);

        //

        var tabVoices = new FlxUI(null, DDLMENU);
        tabVoices.name = "Voices";

        var lblVoices = new FlxText(5, 5, DDLMENU.width - 10, "Voices", 8); tabVoices.add(lblVoices);
        lblVoices.alignment = CENTER;

        var txtVoice = new FlxUIInputText(lblVoices.x, lblVoices.y + lblVoices.height + 5, Std.int(lblVoices.width), "", 8); tabVoices.add(txtVoice);

        var btnAddVoice:FlxButton = new FlxButton(txtVoice.x, txtVoice.y + txtVoice.height + 5, "Add", function(){
            if(txtVoice.text != "" && !_song.voices.contains(txtVoice.text)){
                _song.voices.push(txtVoice.text);
            
                var array = _song.voices;
                if(array == null || array.length <= 0){array = ["NONE"];}
                ddlVoices.setData(FlxUIDropDownMenu.makeStrIdLabelArray(array, true));
            }
        }); tabVoices.add(btnAddVoice);
        btnAddVoice.setSize(Std.int((txtVoice.width / 2) - 3), Std.int(btnAddVoice.height));
        btnAddVoice.setGraphicSize(Std.int((txtVoice.width / 2) - 3), Std.int(btnAddVoice.height));
        btnAddVoice.centerOffsets();
        btnAddVoice.label.fieldWidth = btnAddVoice.width;
        btnAddVoice.color = FlxColor.fromRGB(94, 255, 99);

        var btnDelVoice:FlxButton = new FlxButton(btnAddVoice.x + btnAddVoice.width + 5, btnAddVoice.y, "Del", function(){
            if(_song.voices != null && _song.voices.length > 0){
                _song.voices.remove(ddlVoices.selectedLabel);

                var array = _song.voices;
                if(array == null || array.length <= 0){array = ["NONE"];}
                ddlVoices.setData(FlxUIDropDownMenu.makeStrIdLabelArray(array, true));
            }
        }); tabVoices.add(btnDelVoice);
        btnDelVoice.setSize(Std.int((txtVoice.width / 2) - 3), Std.int(btnDelVoice.height));
        btnDelVoice.setGraphicSize(Std.int((txtVoice.width / 2) - 3), Std.int(btnDelVoice.height));
        btnDelVoice.centerOffsets();
        btnDelVoice.label.fieldWidth = btnDelVoice.width;
        btnDelVoice.color = FlxColor.fromRGB(255, 94, 94);

        var btnUpdVoice:FlxButton = new FlxButton(txtVoice.x, btnAddVoice.y + btnAddVoice.height + 5, "Update Voices", function(){
            loadAudio(_song.song, _song.category);
        }); tabVoices.add(btnUpdVoice);
        btnUpdVoice.setSize(Std.int((txtVoice.width)), Std.int(btnUpdVoice.height));
        btnUpdVoice.setGraphicSize(Std.int((txtVoice.width)), Std.int(btnUpdVoice.height));
        btnUpdVoice.centerOffsets();
        btnUpdVoice.label.fieldWidth = btnUpdVoice.width;

        var arrayVoices:Array<String> = _song.voices;
        if(arrayVoices != null && arrayVoices.length <= 0){arrayVoices = ["NONE"];}
        ddlVoices = new FlxUIDropDownMenu(btnUpdVoice.x, btnUpdVoice.y + btnUpdVoice.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(arrayVoices, true)); tabVoices.add(ddlVoices);

        DDLMENU.addGroup(tabVoices);

        //

        var tabChars = new FlxUI(null, MENU);
        tabChars.name = "Characters";

        var lblCharList = new FlxText(5, 5, DDLMENU.width - 10, "Character List", 8); tabChars.add(lblCharList);
        lblCharList.alignment = CENTER;
        ddlCharacters = new FlxUIDropDownMenu(lblCharList.x, lblCharList.y + lblCharList.height + 5, FlxUIDropDownMenu.makeStrIdLabelArray(Character.getCharacters(), true)); tabChars.add(ddlCharacters);
        ddlCharacters.name = "CHARACTER_LIST";

        DDLMENU.addGroup(tabChars);

        DDLMENU.scrollFactor.set();
        DDLMENU.showTabId("Stage");
        DDLMENU.kill();
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch(label){
				case 'Change BPM':{
                    _song.generalSection[curSection].changeBPM = check.checked;
					FlxG.log.add('BPM Changed to: ' + check.checked);
                    updateSection();
                }
				case "Change ALT":{
                    _song.sectionStrums[curStrum].notes[curSection].altAnim = check.checked;
                }
                case "Change Characters to Sing":{
                    _song.sectionStrums[curStrum].notes[curSection].changeSing = check.checked;
                }
                case "Change Keys":{
                    _song.sectionStrums[curStrum].notes[curSection].changeKeys = check.checked;
                    updateSection();
                }
                case "onRight?":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][3] = check.checked;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
                case "Change Chars":{
                    _song.sectionStrums[curStrum].notes[curSection].changeSing = check.checked;
                    updateSection();
                }
			}
		}else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;
            switch(wname){
                case"SONG_NAME":{_song.song = input.text;}
                case"SONG_CATEGORY":{_song.category = input.text;}
                case"SONG_DIFFICULTY":{_song.difficulty = input.text;}
                case "CHARACTER_ASPECT":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][4] = input.text;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
            }
        }else if(id == FlxUIDropDownMenu.CLICK_EVENT && (sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;
            switch(wname){
                case "STAGES":{
                    _song.stage = drop.selectedLabel;
                    updateSection();
                }
                case "CHARACTER_LIST":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][0] = drop.selectedLabel;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
            switch(wname){
                case "SONG_Strm":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.sectionStrums.length){nums.value = _song.sectionStrums.length - 1;}
                    
                    _song.strumToPlay = Std.int(nums.value);
                }
                case "SONG_Speed":{_song.speed = nums.value;}
                case "SONG_BPM":{
                    _song.bpm = nums.value;
                    updateSection();
                }
                case "GENERALSEC_BPM":{
                    _song.generalSection[curSection].bpm = nums.value;
                    updateSection();
                }
                case "GENERALSEC_LENGTH":{
                    _song.generalSection[curSection].lengthInSteps = Std.int(nums.value);
                    updateSection();
                }
                case "GENERALSEC_STRUMTOFOCUS":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.sectionStrums.length){nums.value = _song.sectionStrums.length - 1;}

                    _song.generalSection[curSection].strumToFocus = Std.int(nums.value);
                    updateSection();
                }
                case "GENERALSEC_CHARTOFOCUS":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.characters.length){nums.value = _song.characters.length - 1;}

                    _song.generalSection[curSection].charToFocus = Std.int(nums.value);
                    updateSection();
                }
                case "STRUMSEC_KEYS":{
                    _song.sectionStrums[curStrum].notes[curSection].keys = Std.int(nums.value);
                    updateSection();
                }
                case "NOTE_STRUMTIME":{
                    var getNote = getNote(selNote[1]);
                    if(getNote != null){
                        getNote[0] = nums.value;
                        selNote = [curStrum, getNote];
                    }
                    updateSection();
                }
                case "NOTE_DATA":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= getStrumKeys(curStrum)){nums.value = getStrumKeys(curStrum) - 1;}

                    var getNote = getNote(selNote[1]);
                    if(getNote != null){
                        getNote[1] = Std.int(nums.value);                       
                        selNote = [curStrum, getNote];
                    }
                    updateSection();
                }
                case "NOTE_LENGTH":{
                    var getNote = getNote(selNote[1]);
                    if(getNote != null){
                        if(nums.value <= 0){getNote[3] = 0;}
                        getNote[2] = nums.value;
                        selNote = [curStrum, getNote];
                    }
                    updateSection();
                }
                case "NOTE_HITS":{
                    var getNote = getNote(selNote[1]);
                    if(getNote != null){
                        if(getNote[2] > 0){
                            getNote[3] = Std.int(nums.value);
                        }else{
                            getNote[3] = 0;
                        }                        
                        selNote = [curStrum, getNote];
                    }
                    updateSection();
                }
                case "STRUM_KEYS":{
                    _song.sectionStrums[curStrum].keys = Std.int(nums.value);
                    updateSection();
                }
                case "CHARACTER_ID":{
                    updateCharacterValues();
                }
                case "CHARACTER_X":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][1][0] = nums.value;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
                case "CHARACTER_Y":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][1][1] = nums.value;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
                case "CHARACTER_SIZE":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][2] = nums.value;
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
                case "CHARACTER_LAYOUT":{
                    if(_song.characters[Std.int(stpCharID.value)] != null){
                        _song.characters[Std.int(stpCharID.value)][6] = Std.int(nums.value);
                    }

                    backStage.setChars(_song.characters);

                    updateSection();
                }
                case "Strums_Length":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.sectionStrums.length){nums.value = _song.sectionStrums.length - 1;}
                }
                case "Chars_Length":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.characters.length){nums.value = _song.characters.length - 1;}
                }
            }
        }
    }
}