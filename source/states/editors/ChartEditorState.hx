package states.editors;


import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;
import flixel.ui.*;

import flixel.FlxState;
import FlxCustom.FlxCustomButton;
import flixel.tweens.FlxEase;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.input.FlxInput;
import io.newgrounds.swf.common.Button;
import flixel.FlxCamera;
import haxe.zip.Writer;
import haxe.DynamicAccess;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import lime.ui.FileDialog;


import FlxCustom.FlxUICustomList;
import FlxCustom.FlxUICustomButton;
import FlxCustom.FlxUICustomNumericStepper;
import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import StrumLineNote;
import StrumLineNote.Note;
import StrumLineNote.StrumStaticNotes;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import states.PlayState.SongListData;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class ChartEditorState extends MusicBeatState{
    public static var _song:SwagSong;
    var _file:FileReference;
    var backStage:Stage;

    var curStrum:Int = 0;
    var curSection:Int = 0;
    public static var lastSection:Int = 0;

    var strumLineEvent:FlxSprite;
    var strumLine:FlxSprite;
    var strumStatics:FlxTypedGroup<StrumStaticNotes>;

    var dArrow:Note;
    var backGrid:FlxSprite;
    var eventGrid:FlxSprite;
    var stuffGroup:FlxTypedGroup<Dynamic>;
    var gridGroup:FlxTypedGroup<FlxSprite>;
    var curGrid:FlxSprite;

    var renderedEvents:FlxTypedGroup<Note>;
    var renderedNotes:FlxTypedGroup<FlxTypedGroup<Dynamic>>;
    var renderedSustains:FlxTypedGroup<FlxTypedGroup<Dynamic>>;
    var renderedAll:Array<Array<Note>> = [];
    var pressedNotes:Array<Array<Note>> = [];
    var sHitsArray:Array<Bool> = [];
    var sVoicesArray:Array<Bool> = [];
    
    var selNote:Array<Dynamic> = [0, [0, 0, 0, 0, null, {}]];
    var selEvent:Array<Dynamic> = [[], {}];

    var gridBLine:FlxSprite;

    //var tabsUI:FlxUIMenuCustom;

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
    var arrayFocus:Array<FlxUIInputText> = [];

    var lblSongInfo:FlxText;

    public static function editChart(?onConfirm:Class<FlxState>, ?onBack:Class<FlxState>, ?chart:SwagSong){
        if(chart == null){chart = Song.loadFromJson("Test-Normal-Normal", "Test");}
        _song = chart;

        FlxG.sound.music.stop();
        MusicBeatState.switchState(new ChartEditorState(onConfirm, onBack));
    }

    override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('[${_song.song}-${_song.category}-${_song.difficulty}]', '[Charting]');
		MagicStuff.setWindowTitle('Charting [${_song.song}-${_song.category}-${_song.difficulty}]', 1);
		#end

        FlxG.mouse.visible = true;

        curSection = lastSection;
        
        backStage = new Stage(_song.stage, _song.characters);
        backStage.cameras = [camBHUD];
        add(backStage);

        var backEventGrid = new FlxSprite(-(KEYSIZE * 1.5), 0).makeGraphic(KEYSIZE, FlxG.height, FlxColor.BLACK);
        backEventGrid.scrollFactor.set(1, 0);
        backEventGrid.alpha = 0.5;
        backEventGrid.cameras = [camHUD];
        add(backEventGrid);

        eventGrid = FlxGridOverlay.create(KEYSIZE, Std.int(KEYSIZE / 2), KEYSIZE, KEYSIZE * (_song.generalSection[curSection].lengthInSteps), true, 0xff4d4d4d, 0xff333333);
        eventGrid.setPosition(backEventGrid.x, 0);
        eventGrid.cameras = [camHUD];
        add(eventGrid);

        var eLine1 = new FlxSprite(eventGrid.x - 1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK);
        eLine1.scrollFactor.set(1, 0);
        eLine1.cameras = [camHUD];
        add(eLine1);
        
        var eLine2 = new FlxSprite(eventGrid.x + eventGrid.width - 1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK);
        eLine2.scrollFactor.set(1, 0);
        eLine2.cameras = [camHUD];
        add(eLine2);

        backGrid = new FlxSprite(-1, 0).makeGraphic(0, FlxG.height, FlxColor.BLACK);
        backGrid.scrollFactor.set(1, 0);
        backGrid.alpha = 0.5;
        backGrid.cameras = [camHUD];
        add(backGrid);

        gridGroup = new FlxTypedGroup<FlxSprite>();
        gridGroup.cameras = [camHUD];
        add(gridGroup);

        stuffGroup = new FlxTypedGroup<Dynamic>();
        stuffGroup.cameras = [camHUD];
        add(stuffGroup);

        strumStatics = new FlxTypedGroup<StrumStaticNotes>();
        strumStatics.cameras = [camHUD];
        add(strumStatics);

        renderedSustains = new FlxTypedGroup<FlxTypedGroup<Dynamic>>();
        renderedSustains.cameras = [camHUD];
        add(renderedSustains);

        renderedNotes = new FlxTypedGroup<FlxTypedGroup<Dynamic>>();
        renderedNotes.cameras = [camHUD];
        add(renderedNotes);

        renderedEvents = new FlxTypedGroup<Note>();
        renderedEvents.cameras = [camHUD];
        add(renderedEvents);

        dArrow = new Note(0, 0);
        dArrow.loadGraphicNote(getNoteJSON(curStrum, 0));
        dArrow.setGraphicSize(KEYSIZE, KEYSIZE);
        dArrow.cameras = [camHUD];
        dArrow.onDebug = true;
        add(dArrow);

        strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
        strumLine.cameras = [camHUD];
		//strumLine.visible = false;
		add(strumLine);
        
        strumLineEvent = new FlxSprite(eventGrid.x, 50).makeGraphic(KEYSIZE, 4);
        strumLineEvent.cameras = [camHUD];
		add(strumLineEvent);

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
        
        btnAddStrum.cameras = [camHUD];
        btnAddStrum.loadGraphic(Paths.image('UI_Assets/addStrum', 'shared'));
        btnAddStrum.setSize(50, 50);
		btnAddStrum.setGraphicSize(50);
		btnAddStrum.centerOffsets();
        btnAddStrum.scrollFactor.set(1, 0);
        add(btnAddStrum);

        btnDelStrum = new FlxTypedButton<FlxSprite>(0, 0, function(){
            if(_song.sectionStrums.length > 1){
                _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
                for(section in _song.generalSection){if(section.strumToFocus >= _song.sectionStrums.length){section.strumToFocus = _song.sectionStrums.length - 1;}}
                if(_song.strumToPlay >= _song.sectionStrums.length){_song.strumToPlay = _song.sectionStrums.length - 1;}
            }
            updateSection();
        });
        btnDelStrum.cameras = [camHUD];
        btnDelStrum.loadGraphic(Paths.image('UI_Assets/delStrum', 'shared'));
        btnDelStrum.setSize(50, 50);
		btnDelStrum.setGraphicSize(50);
		btnDelStrum.centerOffsets();
        btnDelStrum.scrollFactor.set(1, 0);
        add(btnDelStrum);

        gridBLine = new FlxSprite(-1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK);
        gridBLine.scrollFactor.set(1, 0);
        gridBLine.cameras = [camHUD];
		add(gridBLine);

        var menuTabs = [
            {name: "1Settings", label: 'Settings'},
            {name: "2Note", label: 'Note/Event'},
            {name: "3Section/Strum", label: 'Section/Strum'},
            {name: "4Song", label: 'Song'}
        ];
        MENU = new FlxUITabMenu(null, menuTabs, true);
        MENU.resize(300, Std.int(FlxG.height));
		MENU.x = FlxG.width - MENU.width;
        MENU.camera = camFHUD;
        addMENUTABS();
        
        add(MENU);

        lblSongInfo = new FlxText(0, 0, 300, "", 16);
        lblSongInfo.scrollFactor.set();
        lblSongInfo.camera = camFHUD;
        add(lblSongInfo);

        updateSection();
        updateCharacterValues();

        voices = new FlxSoundGroup();
        loadAudio(_song.song, _song.category);
        conductor.changeBPM(_song.bpm);
		conductor.mapBPMChanges(_song);

        super.create();
        
        //camBHUD.alpha = 0;
        camBHUD.zoom = 0.5;

        backFollow = new FlxObject(0, 0, 1, 1);
        backFollow.screenCenter();
		camBHUD.follow(backFollow, LOCKON, 0.04);

        genFollow = new FlxObject(0, 0, 1, 1);
        FlxG.camera.follow(genFollow, LOCKON);
        camHUD.follow(genFollow, LOCKON);
        camBHUD.zoom = backStage.zoom;
    }

    override function update(elapsed:Float){
        curStep = recalculateSteps();
        
        if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}

        conductor.songPosition = FlxG.sound.music.time;

        if(_song.generalSection[curSection] != null){strumLine.y = getYfromStrum((conductor.songPosition - sectionStartTime()) % (conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps));}
        for(strums in strumStatics){for(strum in strums){strum.setPosition(strum.x, strumLine.y);}}
        strumLineEvent.y = strumLine.y;

        if(_song.generalSection[curSection + 1] == null){addGenSection();}
        for(i in 0..._song.sectionStrums.length){if(_song.sectionStrums[i].notes[curSection + 1] == null){addSection(i, _song.generalSection[curSection].lengthInSteps, getStrumKeys(i));}}

        if(curStep >= (16 * (curSection + 1))){changeSection(curSection + 1, false);}
        if(curStep + 1 < (16 * curSection) && curSection > 0){changeSection(curSection - 1, false);}
    
        FlxG.watch.addQuick('daBeat', curBeat);
        FlxG.watch.addQuick('daStep', curStep);

        lblSongInfo.text = 
        "Time: " + Std.string(FlxMath.roundDecimal(conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) +
		"\n\nSection: " + curSection +
		"\nBeat: " + curBeat +
		"\nStep: " + curStep;

        if(!chkMuteInst.checked){FlxG.sound.music.volume = 1;}else{FlxG.sound.music.volume = 0;}
        if(FlxG.sound.music.playing){
            eventGrid.alpha = 0.5;
            backGrid.alpha = 0.3;
            curGrid.alpha = 0.5;
            dArrow.alpha = 0;

            Character.setCameraToCharacter(backStage.getCharacterById(Character.getFocusCharID(_song, curSection)), backFollow);

            for(i in 0..._song.sectionStrums.length){
                var renderStrum:Array<Note> = renderedAll[i];
                for(daNote in renderStrum){
                    if(daNote.strumTime < conductor.songPosition && !checkPressedNote([daNote.strumTime, daNote.noteData], i) && !daNote.hitMiss){
                        if(!chkHideStrums.checked){strumStatics.members[i].members[Std.int(daNote.noteData % getStrumKeys(i))].playAnim("confirm", true);}

                        if(!chkMuteHitSounds.checked && sHitsArray[i] && daNote.typeHit == "Press"){FlxG.sound.play(Paths.sound("CLAP"));}

                        var cList:Array<Int> = _song.sectionStrums[i].charToSing;
				        if(_song.sectionStrums[i].notes[Std.int(curStep / 16)].changeSing){cList = _song.sectionStrums[i].notes[Std.int(curStep / 16)].charToSing;}
				        for(i in cList){backStage.getCharacterById(i).playAnim(daNote.chAnim, true);}

                        pressedNotes[i].push(daNote);
                    }
                }
            }

            for(i in 0...voices.sounds.length){if(!sVoicesArray[i] && !chkMuteVoices.checked){voices.sounds[i].volume = 1;}else{voices.sounds[i].volume = 0;}}

            btnAddStrum.kill();
            btnDelStrum.kill();
        }else{
            eventGrid.alpha = 1;
            backGrid.alpha = 0.5;
            curGrid.alpha = 1;

            if((FlxG.mouse.x > eventGrid.x && FlxG.mouse.x < eventGrid.x + eventGrid.width && FlxG.mouse.y > eventGrid.y && FlxG.mouse.y < eventGrid.y + eventGrid.height)){
                dArrow.x = eventGrid.x;
    
                if(FlxG.keys.pressed.SHIFT){
                    dArrow.y = FlxG.mouse.y - ((dArrow.width - KEYSIZE) / 2);
                }else{
                    dArrow.y = Math.floor(FlxG.mouse.y / (KEYSIZE / 2)) * (KEYSIZE / 2) - ((dArrow.width - KEYSIZE) / 2);
                }
    
                if(FlxG.mouse.pressed){dArrow.alpha = 1;}else{dArrow.alpha = 0.5;}
                
                if(FlxG.mouse.justPressed){checkToHold(true);}
                if(FlxG.mouse.justReleased){checkToAdd(true);}
                if(FlxG.mouse.justPressedRight){checkSelNote(true);}
            }else if((FlxG.mouse.x > curGrid.x && FlxG.mouse.x < curGrid.x + curGrid.width && FlxG.mouse.y > curGrid.y && FlxG.mouse.y < curGrid.y + curGrid.height)){
                dArrow.x = (Math.floor(FlxG.mouse.x / KEYSIZE) * KEYSIZE) - ((dArrow.width - KEYSIZE) / 2);
    
                if(FlxG.keys.pressed.SHIFT){
                    dArrow.y = FlxG.mouse.y - ((dArrow.width - KEYSIZE) / 2);
                }else{
                    dArrow.y = Math.floor(FlxG.mouse.y / (KEYSIZE / 2)) * (KEYSIZE / 2) - ((dArrow.width - KEYSIZE) / 2);
                }
    
                var data:Int = (Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE)) % (getStrumKeys(curStrum));
                if(!holdingNote){dArrow.loadGraphicNote(getNoteJSON(curStrum, data));}
    
                if(FlxG.mouse.pressed){dArrow.alpha = 1;}else{dArrow.alpha = 0.5;}
    
                if(FlxG.mouse.justPressed){checkToHold();}
                if(FlxG.mouse.justReleased){checkToAdd();}
                if(FlxG.mouse.justPressedRight){checkSelNote();}
            }else{
                dArrow.alpha = 0;
            }
            
            pressedNotes = [];
            for(i in 0..._song.sectionStrums.length){
                pressedNotes.push([]);

                var renderStrum:Array<Note> = renderedAll[i];
                for(n in renderStrum){if(n.strumTime < conductor.songPosition && !pressedNotes[i].contains(n)){pressedNotes[i].push(n);}}
            }
            
            var fChar:Character = backStage.getCharacterById(_song.sectionStrums[curStrum].charToSing[0]);
            if(_song.generalSection[curSection].strumToFocus == curStrum){fChar = backStage.getCharacterById(_song.sectionStrums[curStrum].charToSing[_song.generalSection[curSection].charToFocus]);}
            if(chkFocusChar.checked){fChar = backStage.getCharacterById(focusChar);}
            Character.setCameraToCharacter(fChar, backFollow);

            btnAddStrum.revive();
            btnDelStrum.revive();
        }

        if(chkDisableStrumButtons.checked){
            btnAddStrum.kill();
            btnDelStrum.kill();
        }

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){
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
                if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * conductor.stepCrochet * 0.5);}
    
                if(FlxG.keys.justPressed.E){changeNoteSustain(conductor.stepCrochet * 0.26);}
                if(FlxG.keys.justPressed.Q){changeNoteSustain(-(conductor.stepCrochet * 0.24));}
    
                if(!FlxG.sound.music.playing){
                    if(FlxG.keys.anyPressed([UP, W])){
                        var daTime:Float = conductor.stepCrochet * 0.1;
                        FlxG.sound.music.time -= daTime;
                    }
                    if(FlxG.keys.anyPressed([DOWN, S])){
                        var daTime:Float = conductor.stepCrochet * 0.1;
                        FlxG.sound.music.time += daTime;
                    }
                }
    
                if(FlxG.keys.justPressed.R){resetSection();}
    
                if(FlxG.keys.anyJustPressed([LEFT, A])){changeSection(curSection - 1);}
                if(FlxG.keys.anyJustPressed([RIGHT, D])){changeSection(curSection + 1);}
            }else{
                if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * conductor.stepCrochet * 1);}
    
                if(FlxG.keys.justPressed.E){changeNoteHits(1);}
                if(FlxG.keys.justPressed.Q){changeNoteHits(-1);}
    
                if(FlxG.keys.justPressed.C){trace(copySection);}
                if(FlxG.keys.justPressed.T){trace(pressedNotes);}
    
                if(!FlxG.sound.music.playing){
                    if(FlxG.keys.anyPressed([UP, W])){
                        var daTime:Float = conductor.stepCrochet * 0.05;
                        FlxG.sound.music.time -= daTime;
                    }
                    if(FlxG.keys.anyPressed([DOWN, S])){
                        var daTime:Float = conductor.stepCrochet * 0.05;
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
        }

        strumLine.x = curGrid.x;

        genFollow.setPosition(FlxMath.lerp(genFollow.x, curGrid.x + (curGrid.width / 2) + (MENU.width / 2), 0.50), strumLine.y);
        super.update(elapsed);
    }

    function checkPressedNote(n:Dynamic, strum:Int):Bool{
        var strumAll:Array<Note> = pressedNotes[strum];
        for(daNote in strumAll){if(compNotes([daNote.strumTime, daNote.noteData], n)){return true;}}

        return false;
    }

    override function stepHit(){
        super.stepHit();
	}

    override function beatHit(){
        super.beatHit();
        
		for(i in 0...backStage.character_Length){
            var char = backStage.getCharacterById(i);
            if(char.holdTimer <= 0){char.dance();}
        }
    }

    function updateSection():Void {
        stuffGroup.clear();
        gridGroup.clear();
        strumStatics.clear();

        changeStrum();

        if(backStage.curStage != _song.stage){
            backStage.loadStage(_song.stage);
            camBHUD.zoom = backStage.zoom;
        }else{
            backStage.reload();
        }

        //trace(_song.characters);
        sHitsArray.resize(_song.sectionStrums.length);
        
        eventGrid = FlxGridOverlay.create(KEYSIZE, Std.int(KEYSIZE / 2), KEYSIZE, KEYSIZE * (_song.generalSection[curSection].lengthInSteps), true, 0xff4d4d4d, 0xff333333);
        eventGrid.setPosition(-(KEYSIZE * 1.5), 0);
        if(FlxG.sound.music.playing){eventGrid.alpha = 0.5;}

        var lastWidth:Float = 0;
        for(i in 0..._song.sectionStrums.length){
            var newGrid = FlxGridOverlay.create(KEYSIZE, KEYSIZE, KEYSIZE * getStrumKeys(i), KEYSIZE * (_song.generalSection[curSection].lengthInSteps), true, i == _song.generalSection[curSection].strumToFocus ? 0xfffffed6 : 0xffe7e6e6, i == _song.generalSection[curSection].strumToFocus ? 0xffe8e7b7 : 0xffd9d5d5);
            if(i != curStrum || FlxG.sound.music.playing){newGrid.alpha = 0.5;}
            newGrid.x += lastWidth;
            newGrid.ID = i;
            gridGroup.add(newGrid);

            lastWidth += newGrid.width;

            var newGridBLine = new FlxSprite(lastWidth - 1, 0).makeGraphic(2, Std.int(newGrid.height), FlxColor.BLACK);
            newGridBLine.scrollFactor.set(1, 0);
		    stuffGroup.add(newGridBLine);

            if(!chkHideStrums.checked){
                var newStrumStatic = new StrumStaticNotes(newGrid.x, strumLine.y, getStrumKeys(i), Std.int(newGrid.width));
                strumStatics.add(newStrumStatic);
            }

            var btnSoundHit:FlxUIButton = new FlxUICustomButton(newGrid.x + (newGrid.width / 8), newGrid.y + newGrid.height + 5, Std.int(newGrid.width / 4), null, "Sound Hits", sHitsArray[i] ? FlxColor.fromRGB(122, 255, 131) : FlxColor.fromRGB(255, 122, 122), function(){sHitsArray[i] = !sHitsArray[i]; updateSection();});
            btnSoundHit.scrollFactor.set(1, 1);
            stuffGroup.add(btnSoundHit);

            if(_song.hasVoices){
                var btnVoiceMute:FlxUIButton = new FlxUICustomButton(newGrid.x + newGrid.width - (newGrid.width / 8) - (newGrid.width / 4), newGrid.y + newGrid.height + 5, Std.int(newGrid.width / 4), null, "Voice", !sVoicesArray[i] ? FlxColor.fromRGB(122, 255, 131) : FlxColor.fromRGB(255, 122, 122), function(){sVoicesArray[i] = !sVoicesArray[i]; updateSection();});
                btnVoiceMute.scrollFactor.set(1, 1);
                stuffGroup.add(btnVoiceMute);
            }
        }

        if(backGrid.width != Std.int(lastWidth)){backGrid.makeGraphic(Std.int(lastWidth + 2), FlxG.height, FlxColor.BLACK);}

        curGrid = gridGroup.members[curStrum];
        if(FlxG.sound.music.playing && chkCamFocusStrum.checked){curGrid = gridGroup.members[_song.generalSection[curSection].strumToFocus];}
        btnAddStrum.setPosition(lastWidth + 5, curGrid.y);
        btnDelStrum.setPosition(curGrid.x + curGrid.width + 5, curGrid.y + btnAddStrum.height + 10);

        if(strumLine.width != Std.int(curGrid.width)){strumLine.makeGraphic(Std.int(curGrid.width), 4);}
        gridBLine.makeGraphic(2, Std.int(curGrid.height), FlxColor.BLACK);

		if(_song.generalSection[curSection].changeBPM && _song.generalSection[curSection].bpm > 0){
			conductor.changeBPM(_song.generalSection[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
        }else{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for(i in 0...curSection){
                if(_song.generalSection[i].changeBPM){
                    daBPM = _song.generalSection[i].bpm;
                }
            }
			conductor.changeBPM(daBPM);
		}

        renderedEvents.clear();
        var eventsInfo:Array<Dynamic> = _song.generalSection[curSection].events;
        if(eventsInfo != null){for(e in eventsInfo){pushEventToGrid(e);}}

        renderedAll = [];
        renderedNotes.clear();
        renderedSustains.clear();
        for(ii in 0..._song.sectionStrums.length){
            renderedNotes.add(new FlxTypedGroup<Note>());
            renderedSustains.add(new FlxTypedGroup<Note>());
            renderedAll.push([]);

            var sectionInfo:Array<Dynamic> = _song.sectionStrums[ii].notes[curSection].sectionNotes;
            for(i in sectionInfo){
                i[2] = (conductor.stepCrochet * 0.25) * (Math.floor(i[2] / (conductor.stepCrochet * 0.25)));

                if(i[1] >= 0 && i[1] < getStrumKeys(ii)){pushNoteToGrid(i, ii);}
            }
        }

        updateSectionValues();
        updateStrumValues();
    }

    function pushEventToGrid(e:Dynamic):Void {
        var daStrumTime:Float = e[0];
        var daEvents:Array<Dynamic> = e[1];
        
        var daJSON:StrumLineNoteJSON = cast Json.parse(Paths.getText(Paths.getStrumJSON(4)));

        var note:Note = newGridNote(0, daStrumTime, 3, 0, 0, "", daEvents);
        note.loadGraphicNote(daJSON.gameplayNotes[3], _song.sectionStrums[0].noteStyle, "EventIcon");
        note.x = eventGrid.x;
        
        note.alpha = 0.5;
        if(selEvent[0] == note.strumTime){note.alpha = note._alpha;}

        renderedEvents.add(note);
    }

    var prevNote:Note = null;
    function pushNoteToGrid(i:Dynamic, strum:Int, ?merge:Bool = false):Note {
        var daStrumTime:Float = i[0];
        var daNoteData:Int = i[1];
        var daLength:Float = i[2];
        var daHits:Int = i[3];
        var daPresset:String = i[4];
        var daHasMerge:Dynamic = i[5];
        var daOther:Array<Dynamic> = i[6];

        var daJSON:StrumLineNoteJSON = cast Json.parse(Paths.getText(Paths.getStrumJSON(getStrumKeys(strum))));

        var note:Note = newGridNote(strum, daStrumTime, daNoteData, daLength, daHits, daPresset, daOther);
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
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daPresset, daOther, daJSON.gameplayNotes[fData.noteData]); cData++;
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daPresset, daOther, daJSON.gameplayNotes[fData.noteData]); cData++;
                for(i in 1...lDatas){for(ii in 0...4){setSwitcher(cData, strum, daStrumTime, fData.noteData, daPresset, daOther, daJSON.gameplayNotes[fData.noteData + i]); cData++;}}
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daPresset, daOther, daJSON.gameplayNotes[sData.noteData]); cData++;
                setSwitcher(cData, strum, daStrumTime, fData.noteData, daPresset, daOther, daJSON.gameplayNotes[sData.noteData]); cData++;
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
    
                    var hitNote:Note = newGridNote(strum, newStrumTime, daNoteData, 0, curHits, daPresset, daOther);
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
                var cSusNote = Math.floor(daLength / (conductor.stepCrochet * 0.25) + 2);

                var prevSustain:Note = note;
                for(sNote in 0...Math.floor(daLength / (conductor.stepCrochet * 0.25)) + 2){
                    var sStrumTime = daStrumTime + (conductor.stepCrochet / 2) + ((conductor.stepCrochet * 0.25) * sNote);
                            
                    var nSustain:Note = newGridNote(strum, sStrumTime, daNoteData, 0, 0, daPresset, daOther);
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
                    nSustain.typeHit = "Hold";
                    prevSustain.nextNote = nSustain;

                    if(cSusNote <= 1 && daHasMerge != null){
                        nSustain.scale.y = 0.75;
                        
                        var nMerge:Note = newGridNote(strum, sStrumTime, daNoteData, 0, 0, daPresset, daOther);
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

                        if(daHasMerge[1] >= 0 && daHasMerge[1] < getStrumKeys(strum)){
                            nMerge.nextNote = pushNoteToGrid(daHasMerge, strum, true);
                        }
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

    function setSwitcher(i:Int, strum:Int, daStrumTime:Float, noteData:Int, notePresset:String, daOther:Array<Dynamic>, JSON:NoteJSON){
        var nSustain:Note = newGridNote(strum, daStrumTime, noteData, 0, 0, notePresset, daOther);
        nSustain.loadGraphicNote(JSON, _song.sectionStrums[strum].noteStyle);
        nSustain.typeNote = "Switch";
        nSustain.typeHit = "Ghost";
    
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

    function newGridNote(grid:Int, strumTime:Float, noteData:Int, ?noteLength:Float = 0, ?noteHits:Int = 0, ?notePresset:String = "", ?otherData:Array<Dynamic>):Note{
        var note:Note = new Note(strumTime, noteData, noteLength, noteHits, notePresset, otherData);
        note.loadGraphicNote(getNoteJSON(grid, note.noteData), _song.sectionStrums[grid].noteStyle);
        note.setGraphicSize(KEYSIZE, KEYSIZE);
        note.updateHitbox();
        note.onDebug = true;
        note.x = gridGroup.members[grid].x + Math.floor(noteData * KEYSIZE);
        note.y = Math.floor(getYfromStrum((strumTime - sectionStartTime()) % (conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps)));

        return note;
    }

    function changeStrum(value:Int = 0):Void{
        curStrum += value;

        if(curStrum >= _song.sectionStrums.length){curStrum = _song.sectionStrums.length - 1;}
        if(curStrum < 0){curStrum = 0;}

        updateStrumValues();
    }

    function updateCharacters():Void{
        if(focusChar >= _song.characters.length){focusChar = 0;}
        if(focusChar < 0){focusChar = _song.characters.length - 1;}

        backStage.setCharacters(_song.characters);
    }
    function updateCharacterValues():Void{
        lblCurChar.text = '[${focusChar}/${_song.characters.length - 1}]';

        if(_song.characters[focusChar] != null){
            clCharacters.setLabel(_song.characters[focusChar][0]);

            txtAspect.text = _song.characters[focusChar][4];
            chkLEFT.checked = _song.characters[focusChar][3];
            stpCharX.value = _song.characters[focusChar][1][0];
            stpCharY.value = _song.characters[focusChar][1][1];
            stpCharSize.value = _song.characters[focusChar][2];
            stpCharLayout.value = _song.characters[focusChar][6];
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
        var note = getSongNote(selNote[1]);

        if(note != null){
            stpStrumLine.value = note[0];
            stpNoteData.value = note[1];
            stpNoteLength.value = note[2];
            stpNoteHits.value = note[3];
            clNotePressets.setLabel(note[4]);

            var events:Array<Dynamic> = note[6];

            clEventListNote.setData([]);
            if(events.length > 0){for(e in events){clEventListNote.addToData(e[0]);}}
            clEventListNote.setIndex(0);
        }else{
            stpStrumLine.value = 0;
            stpNoteData.value = 0;
            stpNoteLength.value = 0;
            stpNoteHits.value = 0;
            clNotePressets.setLabel("Default");

            clEventListNote.setData([]);
            clEventListNote.setIndex(0);
        }

        var event = getSongEvent(selEvent);

        if(event != null){
            stpEventStrumLine.value = event[0];
            
            var events:Array<Dynamic> = event[1];

            clEventListEvents.setData([]);
            for(e in events){clEventListEvents.addToData(e[0]);}
            clEventListEvents.setIndex(0);
        }else{
            stpEventStrumLine.value = 0;
            
            clEventListEvents.setData([]);
            clEventListEvents.setIndex(0);
        }
    }

    function loadSong(daSong:String, cat:String, diff:String) {
		FlxG.sound.music.pause();
		FlxG.sound.music.time = 0;
        changeSection();

        daSong = daSong.replace(" ", "_");

        _song = Song.loadFromJson(daSong + "-" + cat + "-" + diff, daSong);

        LoadingState.loadAndSwitchState(new ChartEditorState(this.onBack, this.onConfirm), _song, false);
    }

    function loadAudio(daSong:String, cat:String):Void{
        daSong = daSong.replace(" ", "_");

		if(FlxG.sound.music != null){FlxG.sound.music.stop();}

		FlxG.sound.playMusic(Paths.inst(daSong, cat), 0.6);

        voices.sounds = [];
        if(_song.hasVoices){
            for(i in 0..._song.characters.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, _song.characters[i][0], daSong, cat));
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

        for(i in 0...conductor.bpmChangeMap.length){
            if(FlxG.sound.music.time > conductor.bpmChangeMap[i].songTime){
                lastChange = conductor.bpmChangeMap[i];
            }
        }
    
        curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / conductor.stepCrochet);
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
        var n = getSongNote(selNote[1]);
        if(n == null){return;}

        n[2] += value;
        n[2] = Math.max(n[2], 0);
        n[2] = Math.floor((n[2] / (conductor.stepCrochet * 0.25)) * (conductor.stepCrochet * 0.25));

        if(n[2] <= 0 && n[3] > 0){n[3] = 0;}

        updateSection();
    }

    function changeNoteHits(value:Int):Void{
        var n = getSongNote(selNote[1]);
        if(n == null){return;}

        if(n[2] <= 0){changeNoteSustain(conductor.stepCrochet);}

        n[3] += value;
        n[3] = Math.max(n[3], 0);
        
        updateSection();
    }

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void{
		if(_song.generalSection[sec] == null){return;}
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
	}

    private function addGenSection(lengthInSteps:Int = 16):Void{
        var genSec:SwagGeneralSection = {
            bpm: _song.bpm,
            changeBPM: false,
    
            lengthInSteps: lengthInSteps,
    
            strumToFocus: _song.generalSection[curSection].strumToFocus,
            charToFocus: _song.generalSection[curSection].charToFocus,

            events: []
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

    private function newEventData(isSelected:Bool = false):Array<Dynamic>{
        var e:Array<Dynamic> = Note.getEventDynamicData();
        if(isSelected){e = Note.getEventDynamicData(selEvent);}

        e[0] = getStrumTime(dArrow.y) + sectionStartTime();

        return e;
    }

    private function newNoteData(isSelected:Bool = false):Array<Dynamic>{
        var n:Array<Dynamic> = Note.getNoteDynamicData();
        if(isSelected){n = Note.getNoteDynamicData(selNote[1]);}

        n[0] = getStrumTime(dArrow.y) + sectionStartTime();
        n[1] = Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE) % getStrumKeys(curStrum);

        return n;
    }

    private function compNotes(n1:Array<Dynamic>, n2:Array<Dynamic>, specific:Bool = false):Bool{
        if((n1 != null && n2 != null) && (((n1[0] >= n2[0] - 5 && n1[0] <= n2[0] + 5) && n1[1] == n2[1]) || (specific && (n1 == n2)))){
            return true;
        }else{
            return false;
        }
    }

    private function getSongEvent(e:Array<Dynamic>):Array<Dynamic>{
        if(_song.generalSection[curSection] != null && _song.generalSection[curSection].events != null){
            for(i in _song.generalSection[curSection].events){
                if(i[0] == e[0]){
                    return i;
                }
            }
        }
        return null;
    }

    private function getSongNote(n:Array<Dynamic>, ?strum:Int):Array<Dynamic>{
        if(strum == null){strum = curStrum;}

        if(_song.sectionStrums[strum].notes[curSection] != null){
            for(i in _song.sectionStrums[strum].notes[curSection].sectionNotes){
                if(compNotes(i, n)){
                    return i;
                }else{
                    var last:Array<Dynamic> = i;
                    var nM:Array<Dynamic> = i[5];
                    while(nM != null){
                        nM[0] = last[0] + last[2];
    
                        last = nM;
                        if(compNotes(nM, n)){return nM;}
                        nM = nM[5];
                    }
                }
            }
        }

        return null;
    }

    var curLastNote:Array<Dynamic> = null;
    var curLastEvent:Array<Dynamic> = null;
    var holdingNote:Bool = false;
    var holdingEvent:Bool = false;
    private function checkToHold(isEvent:Bool = false):Void{
        if(isEvent){
            var eAdd = getSongEvent(newEventData());
            
            if(eAdd != null){
                holdingEvent = true;
                trace("Event Exist - (Deleting)");

                selEvent = eAdd;
                curLastEvent = eAdd;

                //dArrow.otherData = nAdd[5];
                //dArrow.loadGraphicNote(getNoteJSON(curStrum, dArrow.noteData));

                _song.generalSection[curSection].events.remove(eAdd);
            }
        }else{
            var nAdd = getSongNote(newNoteData());

            if(nAdd != null){
                holdingNote = true;
                trace("Note Exist - (Deleting)");

                selNote = [curStrum, nAdd];
                curLastNote = nAdd;

                //dArrow.otherData = nAdd[5];
                //dArrow.loadGraphicNote(getNoteJSON(curStrum, dArrow.noteData));

                _song.sectionStrums[curStrum].notes[curSection].sectionNotes.remove(nAdd);
            }
        }
        

        updateSection();
    }

    private function checkToAdd(isEvent:Bool = false):Void{
        if(isEvent){
            if(!holdingNote){
                var eAdd = newEventData();
                if(holdingEvent){eAdd = newEventData(true);}
        
                if(holdingEvent){
                    if(getSongEvent(eAdd) == null){
                        if(!compNotes([eAdd[0], 0], [curLastEvent[0], 0])){        
                            _song.generalSection[curSection].events.push(eAdd);
                            selEvent = eAdd;
                        }
                    }else{
                        _song.generalSection[curSection].events.push(curLastEvent);
                    }
                }else{
                    if(getSongEvent(eAdd) == null){
                        _song.generalSection[curSection].events.push(eAdd);
                        selEvent = eAdd;
                    }
                }
        
                holdingEvent = false;
                //dArrow.otherData = null;
            }            
        }else{
            if(!holdingEvent){
                var nAdd = newNoteData();
                if(holdingNote){nAdd = newNoteData(true);}
        
                if(holdingNote){
                    if(getSongNote(nAdd) == null){
                        if(!compNotes(nAdd, curLastNote)){        
                            _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(nAdd);
                            selNote = [curStrum, nAdd];
                        }
                    }else{
                        _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(curLastNote);
                    }
                }else{
                    if(getSongNote(nAdd) == null){
                        _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(nAdd);
                        selNote = [curStrum, nAdd];
                    }
                }
        
                holdingNote = false;
                //dArrow.otherData = null;
            }
        }
        
        updateSection();
        updateNoteValues();
    }
    private function checkSelNote(isEvent:Bool = false){
        if(isEvent){
            var eAdd = newEventData();

            for(i in _song.generalSection[curSection].events){
                if(compNotes([i[0], 0], [eAdd[0], 0])){
                    selEvent = i;
                    break;
                }
            }
        }else{
            var nAdd = newNoteData();

            for(i in _song.sectionStrums[curStrum].notes[curSection].sectionNotes){
                if(compNotes(i, nAdd)){
                    selNote = [curStrum, i];
                    break;
                }else{
                    var pBreak:Bool = false;

                    var last:Array<Dynamic> = i;
                    var n:Array<Dynamic> = last[5];
                    while(n != null){
                        last = n;
                        if(compNotes(n, nAdd)){
                            selNote = [curStrum, n];
                            pBreak = true;
                            break;
                        }
                        n = n[5];
                    }
                    if(pBreak){break;}
                }
            }     
        } 

        updateSection();
        updateNoteValues();
    }

    private function saveSong(){
		var songJson = {"song": _song};

		var data:String = Json.stringify(songJson, "\t");

		if((data != null) && (data.length > 0)){
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song + "-" + _song.category + "-" + _song.difficulty + ".json");
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
        var toReturn:Float = 0;
        
        if(curGrid != null){toReturn = FlxMath.remapToRange(strumTime, 0, _song.generalSection[curSection].lengthInSteps * conductor.stepCrochet, curGrid.y, curGrid.y + curGrid.height);}
        
        return toReturn;
    }

    function getStrumTime(yPos:Float):Float{
        return FlxMath.remapToRange(yPos, curGrid.y, curGrid.y + curGrid.height, 0, _song.generalSection[curSection].lengthInSteps * conductor.stepCrochet);
    }

    function sectionStartTime():Float{
        var daBPM:Float = _song.bpm;
        var daPos:Float = 0;
        for(i in 0...curSection){
            if(_song.generalSection[i] != null && _song.generalSection[i].changeBPM){
                daBPM = _song.generalSection[i].bpm;
            }
            daPos += 4 * (1000 * 60 / daBPM);
        }

        return daPos;
    }

    function getNoteJSON(strum:Int, noteData:Int):NoteJSON{
        var cJson:StrumLineNoteJSON = cast Json.parse(Paths.getText(Paths.getStrumJSON(getStrumKeys(strum))));

        return cJson.gameplayNotes[noteData];
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
            var strumtime = note[0] + conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
    
            var copN:Array<Dynamic> = Note.getNoteDynamicData(note);
            copN[0] = strumtime;

            if(getSongNote(copN, strum) == null){_song.sectionStrums[strum].notes[daSec].sectionNotes.push(copN);}
        }
    
        updateSection();
    }

    function copyLastStrum(?sectionNum:Int = 1, ?strum:Int = 0){
        var daSec = FlxMath.maxInt(curSection, sectionNum);
    
        for(note in _song.sectionStrums[strum].notes[daSec - sectionNum].sectionNotes){
            var strumtime = note[0] + conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
    
            var copN:Array<Dynamic> = Note.getNoteDynamicData(note);
            copN[0] = strumtime;

            if(getSongNote(copN) == null){_song.sectionStrums[curStrum].notes[daSec].sectionNotes.push(copN);}
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
                    var newNote:Array<Dynamic> = Note.getNoteDynamicData(n);
                    if(getSongNote(newNote, i) == null){
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

    var focusChar:Int;
    var txtSong:FlxUIInputText;
    var txtCat:FlxUIInputText;
    var txtDiff:FlxUIInputText;
    var txtAspect:FlxUIInputText;
    var stpBPM:FlxUINumericStepper;
    var stpSpeed:FlxUINumericStepper;
    var stpStrum:FlxUINumericStepper;
    var chkLEFT:FlxUICheckBox;
    var stpCharX:FlxUINumericStepper;
    var stpCharY:FlxUINumericStepper;
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
    var stpStrumLine:FlxUINumericStepper;
    var stpEventStrumLine:FlxUINumericStepper;
    var stpNoteData:FlxUINumericStepper;
    var stpNoteLength:FlxUINumericStepper;
    var stpNoteHits:FlxUINumericStepper;
    var clNotePressets:FlxUICustomList = new FlxUICustomList();
    var ddlEvent1:FlxUIDropDownMenu;
    var txtEvent2:FlxUIInputText;
    var stpSrmKeys:FlxUINumericStepper;
    var txtNoteStyle:FlxUIInputText;
    var lblCharsToSing:FlxText;
    var lblSecCharsToSing:FlxText;
    var lblNoteStyle:FlxText;
    var chkSwitchChars:FlxUICheckBox;
    var chkHasVoices:FlxUICheckBox;
    var chkHideChart:FlxUICheckBox;
    var chkHideStrums:FlxUICheckBox;
    var chkFocusChar:FlxUICheckBox;
    var chkMuteInst:FlxUICheckBox;
    var chkMuteVoices:FlxUICheckBox;
    var chkMuteHitSounds:FlxUICheckBox;
    var chkCamFocusStrum:FlxUICheckBox;
    var chkDisableStrumButtons:FlxUICheckBox;
    var clCharacters:FlxUICustomList;
    var clStages:FlxUICustomList;
    var lblCurChar:FlxText;
    var lblNoteListCount:FlxText;
    var lblEventListCount:FlxText;
    var clEventListToNote:FlxUICustomList = new FlxUICustomList();
    var clEventListNote:FlxUICustomList;
    var txtNoteEventValues:FlxUIInputText = new FlxUIInputText();
    var clNoteCondFunc:FlxUICustomList = new FlxUICustomList();
    var clEventListToEvents:FlxUICustomList = new FlxUICustomList();
    var clEventListEvents:FlxUICustomList;
    var txtCurEventValues:FlxUIInputText = new FlxUIInputText();
    function addMENUTABS():Void{
        var tabSETTINGS = new FlxUI(null, MENU);
        tabSETTINGS.name = "1Settings";

        chkMuteInst = new FlxUICheckBox(5, 10, null, null, "Mute Instrumental", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteInst);

        chkMuteVoices = new FlxUICheckBox(5, chkMuteInst.y + chkMuteInst.height + 7, null, null, "Mute Voices", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteVoices);
        var btnEnVoices = new FlxUICustomButton(5, chkMuteVoices.y + chkMuteVoices.height + 5, Std.int(MENU.width / 3) - 8, null, "Enable Voices", FlxColor.fromRGB(117, 255, 120), function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = false;} updateSection();
        }); tabSETTINGS.add(btnEnVoices);
        var btnTgVoices = new FlxUICustomButton(btnEnVoices.x + btnEnVoices.width + 5, btnEnVoices.y, Std.int(MENU.width / 3) - 8, null, "Toggle Voices", null, function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = !sVoicesArray[i];} updateSection();
        }); tabSETTINGS.add(btnTgVoices);
        var btnDiVoices = new FlxUICustomButton(btnTgVoices.x + btnTgVoices.width + 5, btnTgVoices.y, Std.int(MENU.width / 3) - 8, null, "Disable Voices", FlxColor.fromRGB(255, 94, 94), function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = true;} updateSection();
        }); tabSETTINGS.add(btnDiVoices);

        
        chkMuteHitSounds = new FlxUICheckBox(5, btnEnVoices.y + btnEnVoices.height + 7, null, null, "Mute HitSounds", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteHitSounds);
        var btnEnHits = new FlxUICustomButton(5, chkMuteHitSounds.y + chkMuteHitSounds.height + 5, Std.int(MENU.width / 3) - 8, null, "Enable Hits", FlxColor.fromRGB(117, 255, 120), function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = true;} updateSection();
        }); tabSETTINGS.add(btnEnHits);
        var btnTgHits = new FlxUICustomButton(btnEnHits.x + btnEnHits.width + 5, btnEnHits.y, Std.int(MENU.width / 3) - 8, null, "Toggle Hits", null, function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = !sHitsArray[i];} updateSection();
        }); tabSETTINGS.add(btnTgHits);
        var btnDiHits = new FlxUICustomButton(btnTgHits.x + btnTgHits.width + 5, btnTgHits.y, Std.int(MENU.width / 3) - 8, null, "Disable Hits", FlxColor.fromRGB(255, 94, 94), function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = false;} updateSection();
        }); tabSETTINGS.add(btnDiHits);

        chkHideChart = new FlxUICheckBox(5, btnEnHits.y + btnEnHits.height + 10, null, null, "Hide Chart", 100); tabSETTINGS.add(chkHideChart);
        chkHideStrums = new FlxUICheckBox(5, chkHideChart.y + chkHideChart.height + 5, null, null, "Hide Strums", 100); tabSETTINGS.add(chkHideStrums);

        chkCamFocusStrum = new FlxUICheckBox(5, chkHideStrums.y + chkHideStrums.height + 10, null, null, "Cam Focus Strum when Playing", Std.int(MENU.width-10)); tabSETTINGS.add(chkCamFocusStrum);
                       
        chkDisableStrumButtons = new FlxUICheckBox(5, chkCamFocusStrum.y + chkCamFocusStrum.height + 5, null, null, "Disable [Add / Del] Strum Buttons"); tabSETTINGS.add(chkDisableStrumButtons);

        MENU.addGroup(tabSETTINGS);


        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "4Song";

        var btnPlaySong:FlxButton = new FlxCustomButton(5, 10, Std.int(MENU.width - 10), null, "Play Song", null, function(){
            SongListData.playSong(Song.convertJSON('${_song.song}-${_song.category}-${_song.difficulty}', _song));
        }); tabMENU.add(btnPlaySong);

        var line1 = new FlxSprite(5, btnPlaySong.y + btnPlaySong.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line1);

        var lblSong = new FlxText(5, line1.y + line1.height + 5, 0, "SONG:", 8); tabMENU.add(lblSong);
        txtSong = new FlxUIInputText(lblSong.x + lblSong.width + 5, lblSong.y, Std.int(MENU.width - lblSong.width - 15), Paths.getFileName(_song.song), 8); tabMENU.add(txtSong);
        arrayFocus.push(txtSong);
        txtSong.name = "SONG_NAME";

        var lblCat = new FlxText(lblSong.x, txtSong.y + txtSong.height + 5, 0, "CATEGORY:", 8); tabMENU.add(lblCat);
        txtCat = new FlxUIInputText(lblCat.x + lblCat.width + 5, lblCat.y, Std.int(MENU.width - lblCat.width - 15), _song.category, 8); tabMENU.add(txtCat);
        arrayFocus.push(txtCat);
        txtCat.name = "SONG_CATEGORY";

        var lblDiff = new FlxText(lblCat.x, txtCat.y + txtCat.height + 5, 0, "DIFFICULTY:", 8); tabMENU.add(lblDiff);
        txtDiff = new FlxUIInputText(lblDiff.x + lblDiff.width + 5, lblDiff.y, Std.int(MENU.width - lblDiff.width - 15), _song.difficulty, 8); tabMENU.add(txtDiff);
        arrayFocus.push(txtDiff);
        txtDiff.name = "SONG_DIFFICULTY";

        var btnSave:FlxButton = new FlxCustomButton(lblDiff.x, lblDiff.y + lblDiff.height + 5, Std.int((MENU.width / 3) - 8), null, "Save Song", null, function(){saveSong();}); tabMENU.add(btnSave);

        var btnLoad:FlxButton = new FlxCustomButton(btnSave.x + btnSave.width + 5, btnSave.y, Std.int((MENU.width / 3) - 5), null, "Load Song", null, function(){
            loadSong(_song.song, _song.category, _song.difficulty);
        }); tabMENU.add(btnLoad);

        var btnImport:FlxButton = new FlxCustomButton(btnLoad.x + btnLoad.width + 5, btnLoad.y, Std.int((MENU.width / 3) - 8), null, "Import Chart", null, function(){
                getFile(function(str){
                    var fChart:SwagSong = Song.parseJSONshit(Paths.getText(str).trim(), '${_song.song}-${_song.category}-${_song.difficulty}');
                    fChart.song = _song.song;
                    fChart.difficulty = _song.difficulty;
                    fChart.category = _song.category;

                    _song = fChart;

                    updateSection();
                });
        }); tabMENU.add(btnImport);
        
        var line2 = new FlxSprite(btnSave.x, btnSave.y + btnSave.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line2);

        var sStage = _song.stage;
        clStages = new FlxUICustomList(line2.x, line2.y + 7, Std.int(MENU.width - 10), Stage.getStages(), function(lst:FlxUICustomList){
            _song.stage = lst.getSelectedLabel();

            backStage.loadStage(_song.stage);
            camBHUD.zoom = backStage.zoom;
            
            clEventListToNote.setData(Note.getEvents(_song.stage));
            clEventListToEvents.setData(Note.getEvents(_song.stage));
        }); tabMENU.add(clStages);
        clStages.setPrefix("Stage: ");
        clStages.setLabel(sStage);
        clStages.name = "STAGES";

        var lblStrum = new FlxText(clStages.x, clStages.y + clStages.height, Std.int(MENU.width * 0.4), "Strum to Play: ", 8); tabMENU.add(lblStrum);
        stpStrum = new FlxUINumericStepper(lblStrum.x + lblStrum.width, lblStrum.y, 1, _song.strumToPlay, 0, _song.sectionStrums.length - 1); tabMENU.add(stpStrum);
            @:privateAccess arrayFocus.push(cast stpStrum.text_field);
        stpStrum.name = "SONG_Strm";

        var lblSpeed = new FlxText(lblStrum.x, lblStrum.y + lblStrum.height + 5, Std.int(MENU.width * 0.4), "Scroll Speed: ", 8); tabMENU.add(lblSpeed);
        stpSpeed = new FlxUINumericStepper(lblSpeed.x + lblSpeed.width, lblSpeed.y, 0.1, _song.speed, 0.1, 10, 1); tabMENU.add(stpSpeed);
            @:privateAccess arrayFocus.push(cast stpSpeed.text_field);
        stpSpeed.name = "SONG_Speed";
        
        var lblBPM = new FlxText(lblSpeed.x, stpSpeed.y + stpSpeed.height + 5, Std.int(MENU.width * 0.4), "BPM: ", 8); tabMENU.add(lblBPM);
        stpBPM = new FlxUINumericStepper(lblBPM.x + lblBPM.width, lblBPM.y, 1, _song.bpm, 5, 999); tabMENU.add(stpBPM);
            @:privateAccess arrayFocus.push(cast stpBPM.text_field);
        stpBPM.name = "SONG_BPM";

        chkHasVoices = new FlxUICheckBox(lblBPM.x, lblBPM.y + lblBPM.height + 5, null, null, "Song has Voices?", 100); tabMENU.add(chkHasVoices);
        chkHasVoices.checked = _song.hasVoices;

        var line3 = new FlxSprite(5, chkHasVoices.y + chkHasVoices.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line3);

        var lblCharacters = new FlxText(5, line3.y + line3.height + 3, Std.int(MENU.width - 10), "Characters", 8); tabMENU.add(lblCharacters);
        lblCharacters.alignment = CENTER;

        chkFocusChar = new FlxUICheckBox(lblCharacters.x, lblCharacters.y + lblCharacters.height + 3, null, null, "Focus Current Character", 300); tabMENU.add(chkFocusChar);

        var btnPrevChar:FlxButton = new FlxCustomButton(chkFocusChar.x, chkFocusChar.y + chkFocusChar.height + 5, 20, 20, "<", null, function(){
            focusChar--;
            updateCharacters();
            updateCharacterValues();
        }); tabMENU.add(btnPrevChar);
        
        var gChar = _song.characters[focusChar][0];
        clCharacters = new FlxUICustomList(btnPrevChar.x + btnPrevChar.width + 5, btnPrevChar.y, Std.int(MENU.width - 110), Character.getCharacters(), function(lst:FlxUICustomList){
            _song.characters[focusChar][0] = lst.getSelectedLabel();
            updateCharacters();
        }); tabMENU.add(clCharacters);
        clCharacters.setPrefix("Character: ");
        clCharacters.setLabel(gChar);
        clCharacters.name = "CHARACTERS";

        var btnNextChar:FlxButton = new FlxCustomButton(clCharacters.x + clCharacters.width + 5, clCharacters.y, 20, 20, ">", null, function(){
            focusChar++;
            updateCharacters();
            updateCharacterValues();
        }); tabMENU.add(btnNextChar);

        lblCurChar = new FlxText(btnNextChar.x + btnNextChar.width + 5, btnNextChar.y, 0, '[${focusChar}/${_song.characters.length - 1}]', 12); tabMENU.add(lblCurChar);

        var btnAddChar:FlxButton = new FlxCustomButton(chkFocusChar.x, btnPrevChar.y + btnPrevChar.height + 5, Std.int((MENU.width / 2) - 8), null, "Add Character", FlxColor.fromRGB(82, 255, 128), function(){
            _song.characters.push(["Boyfriend", [100, 100], 1, false, "Default", "NORMAL", 0]);
            updateCharacters();
            updateCharacterValues();
        }); tabMENU.add(btnAddChar);
        btnAddChar.label.color = FlxColor.WHITE;

        var btnDelChar:FlxButton = new FlxCustomButton(btnAddChar.x + btnAddChar.width + 5, btnAddChar.y, Std.int((MENU.width / 2) - 8), null, "Del Cur Character", FlxColor.fromRGB(255, 94, 94), function(){
            _song.characters.remove(_song.characters[focusChar]);
            updateCharacters();
            updateCharacterValues();
        }); tabMENU.add(btnDelChar);
        btnDelChar.label.color = FlxColor.WHITE;

        var lblAspect = new FlxText(btnAddChar.x, btnAddChar.y + btnAddChar.height + 5, 0, "Aspect:", 8); tabMENU.add(lblAspect);
        txtAspect = new FlxUIInputText(lblAspect.x + lblAspect.width + 5, lblAspect.y, Std.int(MENU.width * 0.4), "", 8); tabMENU.add(txtAspect);
        arrayFocus.push(txtAspect);
        txtAspect.name = "CHARACTER_ASPECT";

        chkLEFT = new FlxUICheckBox(txtAspect.x + txtAspect.width + 5, txtAspect.y - 1, null, null, "onRight?", 100); tabMENU.add(chkLEFT);

        var lblCharX = new FlxText(lblAspect.x, lblAspect.y + lblAspect.height + 5, 0, "X:", 8); tabMENU.add(lblCharX);
        stpCharX = new FlxUICustomNumericStepper(lblCharX.x + lblCharX.width + 5, lblCharX.y, 120, 1, 0, -99999, 99999, 1); tabMENU.add(stpCharX);
            @:privateAccess arrayFocus.push(cast stpCharX.text_field);
        stpCharX.name = "CHARACTER_X";

        var lblCharSize = new FlxText(stpCharX.x + stpCharX.width + 5, stpCharX.y, 0, "Size:", 8); tabMENU.add(lblCharSize);
        stpCharSize = new FlxUINumericStepper(lblCharSize.x + lblCharSize.width + 10, lblCharSize.y, 0.1, 1, 0, 999, 1); tabMENU.add(stpCharSize);
            @:privateAccess arrayFocus.push(cast stpCharSize.text_field);
        stpCharSize.name = "CHARACTER_SIZE";

        var lblCharY = new FlxText(lblCharX.x, lblCharX.y + lblCharX.height + 5, 0, "Y:", 8); tabMENU.add(lblCharY);
        stpCharY = new FlxUICustomNumericStepper(lblCharY.x + lblCharY.width + 5, lblCharY.y, 120, 1, 0, -99999, 99999, 1); tabMENU.add(stpCharY);
            @:privateAccess arrayFocus.push(cast stpCharY.text_field);
        stpCharY.name = "CHARACTER_Y";

        var lblCharLayout = new FlxText(stpCharY.x + stpCharY.width + 5, stpCharY.y, 0, "Layout:", 8); tabMENU.add(lblCharLayout);
        stpCharLayout = new FlxUINumericStepper(lblCharLayout.x + lblCharLayout.width + 5, lblCharLayout.y, 1, 0, -999, 999); tabMENU.add(stpCharLayout);
            @:privateAccess arrayFocus.push(cast stpCharLayout.text_field);
        stpCharLayout.name = "CHARACTER_LAYOUT";

        var line4 = new FlxSprite(5, lblCharY.y + lblCharY.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line4);

        var btnClearSong:FlxButton = new FlxCustomButton(5, line4.y + line4.height + 5, Std.int((MENU.width - 15)), null, "Clear Song Notes", null, function(){
            for(i in _song.sectionStrums){
                for(ii in i.notes){
                    ii.sectionNotes = [];
                }
            }
            updateSection();
        }); tabMENU.add(btnClearSong);

        var stpCSongStrm = new FlxUINumericStepper(btnClearSong.x, btnClearSong.y + btnClearSong.height + 8, 1, 0, 0, 999); tabMENU.add(stpCSongStrm);
            @:privateAccess arrayFocus.push(cast stpCSongStrm.text_field);
        stpCSongStrm.name = "Strums_Length";
        var btnClearSongStrum:FlxButton = new FlxCustomButton(stpCSongStrm.x + stpCSongStrm.width + 5, stpCSongStrm.y - 3, Std.int((MENU.width - 15) - stpCSongStrm.width), null, "Clear Song Strum Notes", null, function(){
            if(_song.sectionStrums[Std.int(stpCSongStrm.value)] != null){
                for(i in _song.sectionStrums[Std.int(stpCSongStrm.value)].notes){
                    i.sectionNotes = [];
                }
            }

            updateSection();
        }); tabMENU.add(btnClearSongStrum);
        
        var btnClearSongEvents:FlxButton = new FlxCustomButton(5, stpCSongStrm.y + stpCSongStrm.height + 5, Std.int((MENU.width - 10)), null, "Clear Song Events", null, function(){
            for(i in _song.generalSection){i.events = [];}
            updateSection();
        }); tabMENU.add(btnClearSongEvents);

        //

        var tabSTRUM = new FlxUI(null, MENU);
        tabSTRUM.name = "3Section/Strum";

        var lblStrum = new FlxText(5, 5, MENU.width - 10, "Current Strum"); tabSTRUM.add(lblStrum);
        lblStrum.alignment = CENTER;

        var btnStrmToBack:FlxButton = new FlxCustomButton(lblStrum.x, lblStrum.y + lblStrum.height + 5, Std.int((MENU.width / 2) - 8), null, "Send to Back", FlxColor.fromRGB(214, 212, 71), function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum - 1;
            if(index < 0){index = _song.sectionStrums.length - 1;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToBack);
        btnStrmToBack.label.color = FlxColor.WHITE;

        var btnStrmToFront:FlxButton = new FlxCustomButton(btnStrmToBack.x + btnStrmToBack.width + 5, btnStrmToBack.y, Std.int((MENU.width / 2) - 8), null, "Send to Front", FlxColor.fromRGB(214, 212, 71), function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum + 1;
            if(index >= _song.sectionStrums.length){index = 0;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToFront);
        btnStrmToFront.label.color = FlxColor.WHITE;

        var lblKeys = new FlxText(btnStrmToBack.x, btnStrmToBack.y + btnStrmToBack.height + 5, 0, "KEYS: ", 8); tabSTRUM.add(lblKeys);
        stpSrmKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpSrmKeys);
            @:privateAccess arrayFocus.push(cast stpSrmKeys.text_field);
        stpSrmKeys.name = "STRUM_KEYS";

        var lblStyle = new FlxText(stpSrmKeys.x + stpSrmKeys.width + 5, stpSrmKeys.y + 2, 0, "Style:", 8); tabSTRUM.add(lblStyle);
        var btnBackStyle:FlxButton = new FlxCustomButton(lblStyle.x + lblStyle.width, lblStyle.y - 2, 20, null, "<", null, function(){
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

        var backText = new FlxSprite(btnBackStyle.x + btnBackStyle.width, btnBackStyle.y); tabSTRUM.add(backText);
        lblNoteStyle = new FlxText(backText.x , backText.y, 60, _song.sectionStrums[curStrum].noteStyle, 8); tabSTRUM.add(lblNoteStyle);
        lblNoteStyle.color = FlxColor.BLACK;
        lblNoteStyle.alignment = CENTER;
        lblNoteStyle.autoSize = false;
        lblNoteStyle.wordWrap = false;
        backText.setSize(Std.int(lblNoteStyle.fieldWidth), Std.int(btnBackStyle.height));
        backText.makeGraphic(Std.int(lblNoteStyle.fieldWidth), Std.int(btnBackStyle.height));

        var btnFrontStyle:FlxButton = new FlxCustomButton(lblNoteStyle.x + lblNoteStyle.width, backText.y, 20, null, ">", null, function(){
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

        var lblAddChar = new FlxText(lblKeys.x, btnBackStyle.y + btnBackStyle.height + 7, 0, "Character ID: "); tabSTRUM.add(lblAddChar);
        var stpCharsID = new FlxUINumericStepper(lblAddChar.x + lblAddChar.width, lblAddChar.y, 1, 0, -999, 999); tabSTRUM.add(stpCharsID);
            @:privateAccess arrayFocus.push(cast stpCharsID.text_field);
        stpCharsID.name = "Chars_Length";
        var btnAddCharToSing:FlxButton = new FlxCustomButton(stpCharsID.x + stpCharsID.width + 5, stpCharsID.y - 3, 20, 20, "+", FlxColor.fromRGB(94, 255, 99), function(){
            if(!_song.sectionStrums[curStrum].charToSing.contains(Std.int(stpCharsID.value))){
                _song.sectionStrums[curStrum].charToSing.push(Std.int(stpCharsID.value));
            }
            
            updateStrumValues();
        }); tabSTRUM.add(btnAddCharToSing);

        var btnDelCharToSing:FlxButton = new FlxCustomButton(btnAddCharToSing.x + btnAddCharToSing.width + 5, btnAddCharToSing.y, 20, null, "-", FlxColor.fromRGB(255, 94, 94), function(){
            if(_song.sectionStrums[curStrum].charToSing.contains(Std.int(stpCharsID.value))){
                _song.sectionStrums[curStrum].charToSing.remove(Std.int(stpCharsID.value));
            }

            updateStrumValues();
        }); tabSTRUM.add(btnDelCharToSing);

        lblCharsToSing = new FlxText(lblAddChar.x, btnAddCharToSing.y + btnAddCharToSing.height + 5, 0, "Characters to Sing:"); tabSTRUM.add(lblCharsToSing);

        var line1 = new FlxSprite(lblCharsToSing.x, lblCharsToSing.y + (lblCharsToSing.height * 4) + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabSTRUM.add(line1);

        var lblGeneralSection = new FlxText(line1.x, line1.y + 5, MENU.width - 10, "General Section"); tabSTRUM.add(lblGeneralSection);
        lblGeneralSection.alignment = CENTER;

        var lblBPM = new FlxText(lblGeneralSection.x, lblGeneralSection.y + lblGeneralSection.height + 5, 0, "BPM: ", 8); tabSTRUM.add(lblBPM);
        stpSecBPM = new FlxUINumericStepper(lblBPM.x + lblBPM.width, lblBPM.y, 1, _song.bpm, 5, 999); tabSTRUM.add(stpSecBPM);
            @:privateAccess arrayFocus.push(cast stpSecBPM.text_field);
        stpSecBPM.name = "GENERALSEC_BPM";
        chkBPM = new FlxUICheckBox(stpSecBPM.x + stpSecBPM.width + 5, stpSecBPM.y - 1, null, null, "Change BPM", 100); tabSTRUM.add(chkBPM);
		chkBPM.checked = _song.generalSection[curSection].changeBPM;

        var lblLength = new FlxText(lblBPM.x, lblBPM.y + lblBPM.height + 10, 0, "Section Length (In steps): ", 8); tabSTRUM.add(lblLength);
        stpLength = new FlxUINumericStepper(lblLength.x + lblLength.width, lblLength.y, 4, _song.generalSection[curSection].lengthInSteps, 0, 999, 0); tabSTRUM.add(stpLength);
            @:privateAccess arrayFocus.push(cast stpLength.text_field);
        stpLength.name = "GENERALSEC_LENGTH";

        var lblStrum = new FlxText(lblLength.x, lblLength.y + lblLength.height + 10, 0, "Strum to Focus: ", 8); tabSTRUM.add(lblStrum);
        stpSecStrum = new FlxUINumericStepper(lblStrum.x + lblStrum.width, lblStrum.y, 1, _song.generalSection[curSection].strumToFocus, 0, 999); tabSTRUM.add(stpSecStrum);
            @:privateAccess arrayFocus.push(cast stpSecStrum.text_field);
        stpSecStrum.name = "GENERALSEC_STRUMTOFOCUS";

        var lblChar = new FlxText(stpSecStrum.x + stpSecStrum.width + 5, stpSecStrum.y, 0, "Char to Focus: ", 8); tabSTRUM.add(lblChar);
        stpSecChar = new FlxUINumericStepper(lblChar.x + lblChar.width, lblChar.y, 1, _song.generalSection[curSection].charToFocus, 0, 999); tabSTRUM.add(stpSecChar);
            @:privateAccess arrayFocus.push(cast stpSecChar.text_field);
        stpSecChar.name = "GENERALSEC_CHARTOFOCUS";

        var line2 = new FlxSprite(lblStrum.x, lblStrum.y + lblStrum.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabSTRUM.add(line2);

        var lblStrumlSection = new FlxText(line2.x, line2.y + 5, MENU.width - 10, "Current Strum Section"); tabSTRUM.add(lblStrumlSection);
        lblStrumlSection.alignment = CENTER;

        chkALT = new FlxUICheckBox(lblStrumlSection.x, lblStrumlSection.y + lblStrumlSection.height + 5, null, null, "Change ALT"); tabSTRUM.add(chkALT);
        chkALT.checked = _song.sectionStrums[curStrum].notes[curSection].altAnim;

        var lblKeys = new FlxText(chkALT.x, chkALT.y + chkALT.height + 10, 0, "KEYS: ", 8); tabSTRUM.add(lblKeys);
        stpKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpKeys);
            @:privateAccess arrayFocus.push(cast stpKeys.text_field);
        stpKeys.name = "STRUMSEC_KEYS";
        chkKeys = new FlxUICheckBox(stpKeys.x + stpKeys.width + 5, stpKeys.y - 1, null, null, "Change Keys"); tabSTRUM.add(chkKeys);
        chkKeys.checked = _song.sectionStrums[curStrum].notes[curSection].changeKeys;

        var btnDelAllSec:FlxButton = new FlxCustomButton(lblKeys.x, lblKeys.y + lblKeys.height + 5, Std.int((MENU.width / 2) - 8), null, "Clear All Section", FlxColor.fromRGB(255, 94, 94), function(){
            for(strum in _song.sectionStrums){strum.notes[curSection].sectionNotes = [];}
            updateSection();
        }); tabSTRUM.add(btnDelAllSec);
        btnDelAllSec.label.color = FlxColor.WHITE;

        var btnDelStrSec:FlxButton = new FlxCustomButton(btnDelAllSec.x + btnDelAllSec.width + 5, btnDelAllSec.y, Std.int((MENU.width / 2) - 8), null, "Clear Strum Section", FlxColor.fromRGB(255, 94, 94), function(){
            _song.sectionStrums[curStrum].notes[curSection].sectionNotes = [];
            updateSection();
        }); tabSTRUM.add(btnDelStrSec);
        btnDelStrSec.label.color = FlxColor.WHITE;

        var btnCopyAllSec:FlxButton = new FlxCustomButton(btnDelAllSec.x, btnDelAllSec.y + btnDelAllSec.height + 5, Std.int((MENU.width / 3) - 10), null, "Copy Section", FlxColor.fromRGB(10, 25, 191), function(){
            copySection = [curSection, []];
            for(i in 0..._song.sectionStrums.length){
                copySection[1].push([]);
                for(n in _song.sectionStrums[i].notes[curSection].sectionNotes){                    
                    var s:Array<Dynamic> = Note.getNoteDynamicData(n);
                    s[0] -= sectionStartTime();
                    
                    copySection[1][i].push(s);
                }
            }
        }); tabSTRUM.add(btnCopyAllSec);
        btnCopyAllSec.label.color = FlxColor.WHITE;

        var btnPasteAllSec:FlxButton = new FlxCustomButton(btnCopyAllSec.x + btnCopyAllSec.width + 5, btnCopyAllSec.y, Std.int((MENU.width / 3) - 6), null, "Paste Section", FlxColor.fromRGB(10, 25, 191), function(){
            for(i in 0..._song.sectionStrums.length){
                if(copySection[1][i] != null){
                    var secNotes:Array<Dynamic> = copySection[1][i];
                    for(n in secNotes){
                        var s:Array<Dynamic> = Note.getNoteDynamicData(n);
                        s[0] += sectionStartTime();

                        if(getSongNote(s, i) == null){_song.sectionStrums[i].notes[curSection].sectionNotes.push(s);}
                    }
                }
            }
            updateSection();
        }); tabSTRUM.add(btnPasteAllSec);
        btnPasteAllSec.label.color = FlxColor.WHITE;

        var btnSetAllSec:FlxButton = new FlxCustomButton(btnPasteAllSec.x + btnPasteAllSec.width + 5, btnPasteAllSec.y, Std.int((MENU.width / 3) - 3), null, "Set Last Section", FlxColor.fromRGB(10, 25, 191), function(){
            stpLastSec.value = curSection - copySection[0];
            stpLastSec2.value = curSection - copySection[0];
        }); tabSTRUM.add(btnSetAllSec);
        btnSetAllSec.label.color = FlxColor.WHITE;

        var btnCopLastAllSec:FlxButton = new FlxCustomButton(btnCopyAllSec.x, btnCopyAllSec.y + btnCopyAllSec.height + 5, Std.int((MENU.width / 2) - 20), null, "Paste Last Section", FlxColor.fromRGB(10, 25, 191), function(){
            for(i in 0..._song.sectionStrums.length){copyLastSection(Std.int(stpLastSec.value), i);}
        }); tabSTRUM.add(btnCopLastAllSec);
        btnCopLastAllSec.label.color = FlxColor.WHITE;
        stpLastSec = new FlxUINumericStepper(btnCopLastAllSec.x + btnCopLastAllSec.width + 5, btnCopLastAllSec.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec);
            @:privateAccess arrayFocus.push(cast stpLastSec.text_field);

        var btnCopLastStrum:FlxButton = new FlxCustomButton(btnCopLastAllSec.x, btnCopLastAllSec.y + btnCopLastAllSec.height + 5, Std.int((MENU.width / 2) - 20), null, "Paste Last Strum", FlxColor.fromRGB(10, 25, 191), function(){
            copyLastStrum(Std.int(stpLastSec2.value), Std.int(stpLastStrm.value));
        }); tabSTRUM.add(btnCopLastStrum);
        btnCopLastStrum.label.color = FlxColor.WHITE;
        stpLastSec2 = new FlxUINumericStepper(btnCopLastStrum.x + btnCopLastStrum.width + 5, btnCopLastStrum.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec2);
            @:privateAccess arrayFocus.push(cast stpLastSec2.text_field);
        stpLastStrm = new FlxUINumericStepper(stpLastSec2.x + stpLastSec2.width + 5, stpLastSec2.y, 1, 0, 0, 999); tabSTRUM.add(stpLastStrm);
            @:privateAccess arrayFocus.push(cast stpLastStrm.text_field);

        var btnSwapStrum:FlxButton = new FlxCustomButton(btnCopLastStrum.x, btnCopLastStrum.y + btnCopLastStrum.height + 5, Std.int((MENU.width / 2) - 3), null, "Swap Strum", FlxColor.fromRGB(69, 214, 173), function(){
            var sec1 = _song.sectionStrums[curStrum].notes[curSection].sectionNotes;
            var sec2 = _song.sectionStrums[Std.int(stpSwapSec.value)].notes[curSection].sectionNotes;

            _song.sectionStrums[curStrum].notes[curSection].sectionNotes = sec2;
            _song.sectionStrums[Std.int(stpSwapSec.value)].notes[curSection].sectionNotes = sec1;

            updateSection();
        }); tabSTRUM.add(btnSwapStrum);
        btnSwapStrum.label.color = FlxColor.WHITE;
        stpSwapSec = new FlxUINumericStepper(btnSwapStrum.x + btnSwapStrum.width + 5, btnSwapStrum.y + 3, 1, 0, 0, 999); tabSTRUM.add(stpSwapSec);
            @:privateAccess arrayFocus.push(cast stpSwapSec.text_field);
        stpSwapSec.name = "Strums_Length";

        var btnMirror:FlxButton = new FlxCustomButton(btnSwapStrum.x, btnSwapStrum.y + btnSwapStrum.height + 5, Std.int((MENU.width / 2) - 8), null, "Mirror Strum", FlxColor.fromRGB(214, 212, 71), function(){
            trace("|-Strum Mirror-|");
            mirrorNotes();
            trace("|-Strum Mirror End-|");
        }); tabSTRUM.add(btnMirror);
        btnMirror.label.color = FlxColor.WHITE;

        var btnMirrorAll:FlxButton = new FlxCustomButton(btnMirror.x + btnMirror.width + 5, btnMirror.y, Std.int((MENU.width / 2) - 8), null, "Mirror Section", FlxColor.fromRGB(214, 212, 71), function(){
            trace("|-Section Mirror-|");
            for(i in 0..._song.sectionStrums.length){mirrorNotes(i);}
            trace("|-Section Mirror End-|");
        }); tabSTRUM.add(btnMirrorAll);
        btnMirrorAll.label.color = FlxColor.WHITE;

        var btnSync:FlxButton = new FlxCustomButton(btnMirror.x, btnMirror.y + btnMirror.height + 5, Std.int((MENU.width) - 10), null, "Synchronize Notes", FlxColor.fromRGB(214, 212, 71), function(){
            syncNotes();
        }); tabSTRUM.add(btnSync);
        btnSync.label.color = FlxColor.WHITE;

        var btnMiguel:FlxButton = new FlxCustomButton(btnSync.x, btnSync.y + btnSync.height + 5, Std.int((MENU.width) - 10), null, "Miguel2", FlxColor.fromRGB(0, 0, 255), function(){}); tabSTRUM.add(btnMiguel);
        btnMiguel.label.color = FlxColor.WHITE;

        chkSwitchChars = new FlxUICheckBox(btnMiguel.x, btnMiguel.y + btnMiguel.height + 5, null, null, "Change Characters to Sing", 0); tabSTRUM.add(chkSwitchChars);

        var lblAddSecChar = new FlxText(chkSwitchChars.x, chkSwitchChars.y + chkSwitchChars.height + 5, 0, "Character ID: "); tabSTRUM.add(lblAddSecChar);
        var stpCharsSecID = new FlxUINumericStepper(lblAddSecChar.x + lblAddSecChar.width, lblAddSecChar.y, 1, 0, -999, 999); tabSTRUM.add(stpCharsSecID);
            @:privateAccess arrayFocus.push(cast stpCharsSecID.text_field);
        stpCharsSecID.name = "Chars_Length";
        var btnAddSecCharToSing:FlxButton = new FlxCustomButton(stpCharsSecID.x + stpCharsSecID.width + 5, stpCharsSecID.y - 3, 20, null, "+", FlxColor.fromRGB(94, 255, 99), function(){
            if(!_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(Std.int(stpCharsSecID.value))){
                _song.sectionStrums[curStrum].notes[curSection].charToSing.push(Std.int(stpCharsSecID.value));
            }
            
            updateSectionValues();
        }); tabSTRUM.add(btnAddSecCharToSing);

        var btnDelSecCharToSing:FlxButton = new FlxCustomButton(btnAddSecCharToSing.x + btnAddSecCharToSing.width + 5, btnAddSecCharToSing.y, 20, null, "-", FlxColor.fromRGB(255, 94, 94), function(){
            if(_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(Std.int(stpCharsSecID.value))){
                _song.sectionStrums[curStrum].notes[curSection].charToSing.remove(Std.int(stpCharsSecID.value));
            }

            updateSectionValues();
        }); tabSTRUM.add(btnDelSecCharToSing);

        lblSecCharsToSing = new FlxText(lblAddSecChar.x, btnAddSecCharToSing.y + btnAddSecCharToSing.height + 5, 0, "Characters to Sing:"); tabSTRUM.add(lblSecCharsToSing);

        MENU.addGroup(tabSTRUM);

        //

        var tabNOTE = new FlxUI(null, MENU);
        tabNOTE.name = "2Note";

        var lblNote = new FlxText(5, 5, MENU.width - 10, "Note"); tabNOTE.add(lblNote);
        lblNote.alignment = CENTER;

        var lblStrumLine = new FlxText(lblNote.x, lblNote.y + lblNote.height + 5, 0, "StrumTime: ", 8); tabNOTE.add(lblStrumLine);
        stpStrumLine = new FlxUICustomNumericStepper(lblStrumLine.x + lblStrumLine.width, lblStrumLine.y, 120, conductor.stepCrochet * 0.5, 0, 0, 999999, 2); tabNOTE.add(stpStrumLine);
            @:privateAccess arrayFocus.push(cast stpStrumLine.text_field);
        stpStrumLine.name = "NOTE_STRUMTIME";

        var lblNoteData = new FlxText(lblStrumLine.x, lblStrumLine.y + lblStrumLine.height + 5, 0, "Note Data: ", 8); tabNOTE.add(lblNoteData);
        stpNoteData = new FlxUINumericStepper(lblNoteData.x + lblNoteData.width, lblNoteData.y, 1, 0, 0, 999); tabNOTE.add(stpNoteData);
            @:privateAccess arrayFocus.push(cast stpNoteData.text_field);
        stpNoteData.name = "NOTE_DATA";

        var lblNoteLength = new FlxText(lblNoteData.x, lblNoteData.y + lblNoteData.height + 10, 0, "Note Length: ", 8); tabNOTE.add(lblNoteLength);
        stpNoteLength = new FlxUICustomNumericStepper(lblNoteLength.x + lblNoteLength.width, lblNoteLength.y, 120, (conductor.stepCrochet * 0.5), 0, 0, 999999, 2); tabNOTE.add(stpNoteLength);
            @:privateAccess arrayFocus.push(cast stpNoteLength.text_field);
        stpNoteLength.name = "NOTE_LENGTH";

        var lblNoteHits = new FlxText(lblNoteLength.x, lblNoteLength.y + lblNoteLength.height + 5, 0, "Note Hits: ", 8); tabNOTE.add(lblNoteHits);
        stpNoteHits = new FlxUINumericStepper(lblNoteHits.x + lblNoteHits.width, lblNoteHits.y, 1, 0, 0, 999); tabNOTE.add(stpNoteHits);
            @:privateAccess arrayFocus.push(cast stpNoteHits.text_field);
        stpNoteHits.name = "NOTE_HITS";

        clNotePressets = new FlxUICustomList(5, lblNoteHits.y + lblNoteHits.height + 5, Std.int(MENU.width - 10), Note.getPressets(), function(lst:FlxUICustomList){
            var note = getSongNote(selNote[1], curStrum); if(note == null){return;}
            note[4] = lst.getSelectedLabel();
            
            updateSection();
        }); tabNOTE.add(clNotePressets);
        clNotePressets.setPrefix("Note Presset: ["); clNotePressets.setSuffix("]");
        clNotePressets.setIndex(0);

        var btnMerge:FlxButton = new FlxCustomButton(5, clNotePressets.y + clNotePressets.height + 10, Std.int(MENU.width - 10), null, "Add Merge Note", FlxColor.fromRGB(133, 233, 255), function(){
            var note = getSongNote(selNote[1], curStrum); if(note == null){return;}
            if(note[2] <= 0){note[2] = (conductor.stepCrochet * 0.5);}
            var merge = Note.getNoteDynamicData();
            merge[0] = note[0] + note[2] + Math.floor(conductor.stepCrochet * 0.75);

            note[5] = merge;
            updateSection();
        }); tabNOTE.add(btnMerge);
        
        clEventListToNote = new FlxUICustomList(btnMerge.x, btnMerge.y + btnMerge.height + 5, Std.int(MENU.width - 35), Note.getEvents(_song.stage)); tabNOTE.add(clEventListToNote);
        clEventListToNote.setPrefix("Event List: ["); clEventListToNote.setSuffix("]");
        clEventListToNote.setIndex(0);

        var btnAddEventToNote = new FlxUICustomButton(clEventListToNote.x + clEventListToNote.width + 5, clEventListToNote.y, 20, null, "+", FlxColor.fromRGB(117, 255, 120), function(){
            var note = getSongNote(selNote[1]); if(note == null){return;}
            var event:Array<Dynamic> = note[6]; if(event == null){event = [];}
            event.push([clEventListToNote.getSelectedLabel(), []]);
            note[6] = event;

            updateNoteValues();
        }); tabNOTE.add(btnAddEventToNote);
        
        lblNoteListCount = new FlxText(5, clEventListToNote.y + clEventListToNote.height + 5, 0, "[0/0]"); tabNOTE.add(lblNoteListCount);

        clEventListNote = new FlxUICustomList(lblNoteListCount.x + lblNoteListCount.width + 5, lblNoteListCount.y, Std.int(MENU.width - lblNoteListCount.width) - 40, [], function(lst:FlxUICustomList){
            var note = getSongNote(selNote[1]); if(note == null){lblNoteListCount.text = "[0/0]"; txtNoteEventValues.text = "[]"; return;}
            var event:Array<Dynamic> = note[6]; if(event == null || event.length <= 0){lblNoteListCount.text = "[0/0]"; txtNoteEventValues.text = "[]"; return;}
            
            lblNoteListCount.text = '[${lst.getSelectedIndex()}/${event.length - 1}]';
            txtNoteEventValues.text = cast event[lst.getSelectedIndex()][1];
            clNoteCondFunc.setLabel(event[lst.getSelectedIndex()][2]);
        }); tabNOTE.add(clEventListNote);
        clEventListNote.setPrefix("Note Event: ["); clEventListNote.setSuffix("]");
        clEventListNote.setIndex(0);
        
        var btnDelEventToNote = new FlxUICustomButton(clEventListNote.x + clEventListNote.width + 5, clEventListNote.y, 20, null, "-", FlxColor.fromRGB(255, 56, 56), function(){
            var note = getSongNote(selNote[1]); if(note == null){return;}
            var event:Array<Dynamic> = note[6]; if(event == null || event[clEventListNote.getSelectedIndex()] == null){return;}
            event.remove(event[clEventListNote.getSelectedIndex()]);
            note[6] = event;

            updateNoteValues();
        }); tabNOTE.add(btnDelEventToNote);

        txtNoteEventValues = new FlxUIInputText(5, clEventListNote.y + clEventListNote.height + 5, Std.int(MENU.width) - 115, "[]"); tabNOTE.add(txtNoteEventValues);
        txtNoteEventValues.name = "NOTE_EVENT";
        arrayFocus.push(txtNoteEventValues);

        clNoteCondFunc = new FlxUICustomList(txtNoteEventValues.x + txtNoteEventValues.width + 5, txtNoteEventValues.y, 100, ["OnHit", "OnMiss"], function(lst:FlxUICustomList){
            var note = getSongNote(selNote[1]); if(note == null){return;}
            var event:Array<Dynamic> = note[6]; if(event == null || event.length <= 0){return;}
            
            event[clEventListNote.getSelectedIndex()][2] = lst.getSelectedLabel();
        }); tabNOTE.add(clNoteCondFunc);

        var nLine1 = new FlxSprite(5, txtNoteEventValues.y + txtNoteEventValues.height + 10).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabNOTE.add(nLine1);
        
        var lblEvents = new FlxText(5, nLine1.y + 7, MENU.width - 10, "Section Events"); tabNOTE.add(lblEvents);
        lblEvents.alignment = CENTER;

        var lblEventStrumLine = new FlxText(lblEvents.x, lblEvents.y + lblEvents.height + 5, 0, "StrumTime: ", 8); tabNOTE.add(lblEventStrumLine);
        stpEventStrumLine = new FlxUICustomNumericStepper(lblEventStrumLine.x + lblEventStrumLine.width, lblEventStrumLine.y, 120, conductor.stepCrochet * 0.5, 0, 0, 999999, 2); tabNOTE.add(stpEventStrumLine);
            @:privateAccess arrayFocus.push(cast stpEventStrumLine.text_field);
        stpEventStrumLine.name = "EVENT_STRUMTIME";

        clEventListToEvents = new FlxUICustomList(lblEventStrumLine.x, lblEventStrumLine.y + lblEventStrumLine.height + 5, Std.int(MENU.width - 35), Note.getEvents(_song.stage)); tabNOTE.add(clEventListToEvents);
        clEventListToEvents.setPrefix("Event List: ["); clEventListToEvents.setSuffix("]");
        clEventListToEvents.setIndex(0);

        var btnAddEventToEvents = new FlxUICustomButton(clEventListToEvents.x + clEventListToEvents.width + 5, clEventListToEvents.y, 20, null, "+", FlxColor.fromRGB(117, 255, 120), function(){
            var note = getSongEvent(selEvent); if(note == null){return;}
            var event:Array<Dynamic> = note[1]; if(event == null){event = [];}
            event.push([clEventListToEvents.getSelectedLabel(), []]);
            note[1] = event;

            updateNoteValues();
        }); tabNOTE.add(btnAddEventToEvents);
        
        lblEventListCount = new FlxText(5, clEventListToEvents.y + clEventListToEvents.height + 5, 0, "[0/0]"); tabNOTE.add(lblEventListCount);

        clEventListEvents = new FlxUICustomList(lblEventListCount.x + lblEventListCount.width + 5, lblEventListCount.y, Std.int(MENU.width - lblEventListCount.width) - 40, [], function(lst:FlxUICustomList){
            var note = getSongEvent(selEvent); if(note == null){lblEventListCount.text = "[0/0]"; txtCurEventValues.text = "[]"; return;}
            var event:Array<Dynamic> = note[1]; if(event == null || event.length <= 0){lblEventListCount.text = "[0/0]"; txtCurEventValues.text = "[]"; return;}
            
            lblEventListCount.text = '[${lst.getSelectedIndex()}/${event.length - 1}]';
            txtCurEventValues.text = event[lst.getSelectedIndex()][1];
        }); tabNOTE.add(clEventListEvents);
        clEventListEvents.setPrefix("Current Event: ["); clEventListEvents.setSuffix("]");
        clEventListEvents.setIndex(0);
        
        var btnDelEventToNote = new FlxUICustomButton(clEventListEvents.x + clEventListEvents.width + 5, clEventListEvents.y, 20, null, "-", FlxColor.fromRGB(255, 56, 56), function(){
            var note = getSongEvent(selEvent); if(note == null){return;}
            var event:Array<Dynamic> = note[1]; if(event == null || event[clEventListEvents.getSelectedIndex()] == null){return;}
            event.remove(event[clEventListEvents.getSelectedIndex()]);
            note[1] = event;

            updateNoteValues();
        }); tabNOTE.add(btnDelEventToNote);

        txtCurEventValues = new FlxUIInputText(5, clEventListEvents.y + clEventListEvents.height + 5, Std.int(MENU.width - 10), "[]"); tabNOTE.add(txtCurEventValues);
        txtCurEventValues.name = "EVENTS_EVENT";
        arrayFocus.push(txtCurEventValues);

        MENU.addGroup(tabNOTE);

        //

        MENU.addGroup(tabMENU);
        MENU.scrollFactor.set();
        MENU.showTabId("4Song");
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch(label){
                case "Hide Strums":{updateSection();}
                case "Hide Chart":{
                    camHUD.visible = !check.checked;
                    camFHUD.alpha = !check.checked ? 1 : 0.5;
                }
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
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][3] = check.checked;}
                    updateCharacters();
                }
                case "Change Chars":{
                    _song.sectionStrums[curStrum].notes[curSection].changeSing = check.checked;
                    updateSection();
                }
                case "Song has Voices?":{
                    FlxG.sound.music.pause();
                    for(voice in voices.sounds){voice.pause();}
                    
                    _song.hasVoices = check.checked;
                    loadAudio(_song.song, _song.category);
                }
			}
		}else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;
            switch(wname){
                case"SONG_NAME":{_song.song = Paths.getFileName(input.text, true);}
                case"SONG_CATEGORY":{_song.category = input.text;}
                case"SONG_DIFFICULTY":{_song.difficulty = input.text;}
                case "CHARACTER_ASPECT":{
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][4] = input.text;}
                    updateCharacters();
                }
                case "NOTE_EVENT":{
                    var note = getSongNote(selNote[1]); if(note == null){return;}

                    var textArray:Array<Dynamic> = [];
                    if(input.text.replace("[", "").replace("]", "").length > 0){for(i in input.text.replace("[", "").replace("]", "").split(",")){textArray.push(i);}}

                    var events:Array<Dynamic> = note[6];
                    if(events[clEventListNote.getSelectedIndex()] == null){return;}
                    events[clEventListNote.getSelectedIndex()][1] = textArray;

                }
                case "EVENTS_EVENT":{
                    var event = getSongEvent(selEvent); if(event == null){return;}
                    
                    var textArray:Array<Dynamic> = [];
                    if(input.text.replace("[", "").replace("]", "").length > 0){for(i in input.text.replace("[", "").replace("]", "").split(",")){textArray.push(i);}}

                    var events:Array<Dynamic> = event[1];
                    if(events[clEventListEvents.getSelectedIndex()] == null){return;}
                    events[clEventListEvents.getSelectedIndex()][1] = textArray;
                }
            }
        }else if(id == FlxUIDropDownMenu.CLICK_EVENT && (sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;
            switch(wname){
                case "CHARACTER_LIST":{
                    if(_song.characters[focusChar] != null){
                        _song.characters[focusChar][0] = drop.selectedLabel;
                    }

                    updateSection();
                }
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
            switch(wname){
                case "CHARACTER_X":{
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][1][0] = nums.value;}
                    updateCharacters();
                }
                case "CHARACTER_Y":{
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][1][1] = nums.value;}
                    updateCharacters();
                }
                case "NOTE_STRUMTIME":{
                    var getSongNote = getSongNote(selNote[1]);
                    if(getSongNote != null){
                        getSongNote[0] = nums.value;
                        selNote = [curStrum, getSongNote];
                    }
                    updateSection();
                }
                case "EVENT_STRUMTIME":{
                    var getSongEvent = getSongEvent(selEvent);
                    if(getSongEvent != null){
                        getSongEvent[0] = nums.value;
                        selEvent = getSongEvent;
                    }
                    updateSection();
                }
                case "NOTE_LENGTH":{
                    var getSongNote = getSongNote(selNote[1]);
                    if(getSongNote != null){
                        if(nums.value <= 0){getSongNote[3] = 0;}
                        getSongNote[2] = nums.value;
                        selNote = [curStrum, getSongNote];
                    }
                    updateSection();
                }
                case "SONG_Strm":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.sectionStrums.length){nums.value = _song.sectionStrums.length - 1;}
                    
                    _song.strumToPlay = Std.int(nums.value);
                }
                case "SONG_Speed":{_song.speed = nums.value;}
                case "SONG_BPM":{
                    _song.bpm = nums.value;
                    
				    conductor.mapBPMChanges(_song);
				    conductor.changeBPM(nums.value);
                    
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
                case "NOTE_DATA":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= getStrumKeys(curStrum)){nums.value = getStrumKeys(curStrum) - 1;}

                    var getSongNote = getSongNote(selNote[1]);
                    if(getSongNote != null){
                        getSongNote[1] = Std.int(nums.value);                       
                        selNote = [curStrum, getSongNote];
                    }
                    updateSection();
                }
                case "NOTE_HITS":{
                    var getSongNote = getSongNote(selNote[1]);
                    if(getSongNote != null){
                        if(getSongNote[2] > 0){
                            getSongNote[3] = Std.int(nums.value);
                        }else{
                            getSongNote[3] = 0;
                        }                        
                        selNote = [curStrum, getSongNote];
                    }
                    updateSection();
                }
                case "STRUM_KEYS":{
                    _song.sectionStrums[curStrum].keys = Std.int(nums.value);
                    updateSection();
                }
                case "CHARACTER_SIZE":{
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][2] = nums.value;}
                    updateCharacters();
                }
                case "CHARACTER_LAYOUT":{
                    if(_song.characters[focusChar] != null){_song.characters[focusChar][6] = Std.int(nums.value);}
                    updateCharacters();
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