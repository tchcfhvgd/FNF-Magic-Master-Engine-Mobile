package states.editors;


import flixel.util.*;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.*;
import flixel.ui.*;

import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import io.newgrounds.swf.common.Button;
import flixel.system.FlxSoundGroup;
import openfl.events.IOErrorEvent;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import openfl.utils.ByteArray;
import flixel.tweens.FlxEase;
import flixel.input.FlxInput;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import openfl.events.Event;
import flixel.text.FlxText;
import haxe.DynamicAccess;
import openfl.media.Sound;
import lime.ui.FileDialog;
import lime.utils.Assets;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import haxe.zip.Writer;
import flixel.FlxBasic;
import flixel.FlxG;
import haxe.Timer;
import openfl.Lib;
import haxe.Json;

import FlxCustom.FlxUICustomNumericStepper;
import states.PlayState.SongListData;
import FlxCustom.FlxUICustomButton;
import Song.SwagGeneralSection;
import FlxCustom.FlxUICustomList;
import FlxCustom.FlxCustomButton;
import Conductor.BPMChangeEvent;
import StrumLine.StaticNotes;
import Song.SwagSection;
import Song.SwagStrum;
import Song.SwagSong;
import Note.NoteData;
import StrumLine;
import Note;
import Song;

#if desktop
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using SavedFiles;
using StringTools;

class ChartEditorState extends MusicBeatState {
    public static var _song:SwagSong;
    
    var stage:Stage;

    var curStrum:Int = 0;
    var curSection:Int = 0;
    public static var lastSection:Int = 0;

	var tempBpm:Float = 0;

    var strumLineEvent:FlxSprite;
    var strumLine:FlxSprite;
    var strumStatics:FlxTypedGroup<StaticNotes>;

    var eveGrid:FlxSprite;
    var curGrid:FlxSprite;
    var focusStrum:FlxSprite;
    var cursor_Arrow:Note;
    var cursor_Event:StrumEvent;

    var _saved:Alphabet;

    var backGroup:FlxTypedGroup<Dynamic>;
    var gridGroup:FlxTypedGroup<FlxSprite>;
    var stuffGroup:FlxTypedGroup<Dynamic>;
    
    var notesCanHit:Array<Array<Note>> = [];
    var renderedEvents:FlxTypedGroup<StrumEvent>;
    var renderedNotes:FlxTypedGroup<Note>;
    var renderedSustains:FlxTypedGroup<Note>;
    var sHitsArray:Array<Bool> = [];
    var sVoicesArray:Array<Bool> = [];
    
    var selNote:NoteData = Note.getNoteData();
    var selEvent:EventData = Note.getEventData();
    var selCharacter:Int = 0;

    //var tabsUI:FlxUIMenuCustom;

    var genFollow:FlxObject;
    var backFollow:FlxObject;
    //-------

    var voices:FlxSoundGroup;
    var inst:FlxSound = new FlxSound();

    var DEFAULT_KEYSIZE:Int = 60;
    var KEYSIZE:Int = 60;

    var btnAddStrum:FlxButton;
    var btnDelStrum:FlxButton;

    var MENU:FlxUITabMenu;
    var DDLMENU:FlxUITabMenu;

    var arrayFocus:Array<FlxUIInputText> = [];
    var copySection:Array<Dynamic> = null;

    var lblSongInfo:FlxText;

    var saveTimer:Timer = new Timer(60000);
    public static var autSave:Bool = false;

    override function destroy() {
        saveTimer.stop();
		super.destroy();
	}

    override function create(){
        if(FlxG.sound.music != null){FlxG.sound.music.stop();}

        if(_song == null){_song = states.PlayState.SONG;}
        if(_song == null){_song = Song.loadFromJson("Test-Normal-Normal");}

        autSave = FlxG.save.data.autSave;
        saveTimer.run = autoSave;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence('[${_song.song}-${_song.category}-${_song.difficulty}]', '[Charting]');
		MagicStuff.setWindowTitle('Charting [${_song.song}-${_song.category}-${_song.difficulty}]', 1);
		#end

        FlxG.mouse.visible = true;

        curSection = lastSection;
		tempBpm = _song.bpm;
        
        stage = new Stage(_song.stage, _song.characters);
        stage.showCamPoints = true;
        stage.is_debug = true;
        stage.cameras = [camBHUD];
        add(stage);

        backGroup = new FlxTypedGroup<Dynamic>(); backGroup.cameras = [camHUD]; add(backGroup);
        gridGroup = new FlxTypedGroup<FlxSprite>(); gridGroup.cameras = [camHUD]; add(gridGroup);
        focusStrum = new FlxSprite().makeGraphic(KEYSIZE, KEYSIZE, FlxColor.YELLOW); focusStrum.cameras = [camHUD]; focusStrum.alpha = 0.3; add(focusStrum);
        strumStatics = new FlxTypedGroup<StaticNotes>(); strumStatics.cameras = [camHUD]; add(strumStatics);
        stuffGroup = new FlxTypedGroup<Dynamic>(); stuffGroup.cameras = [camHUD]; add(stuffGroup);

        renderedSustains = new FlxTypedGroup<Note>(); renderedSustains.cameras = [camHUD]; add(renderedSustains);
        renderedNotes = new FlxTypedGroup<Note>(); renderedNotes.cameras = [camHUD]; add(renderedNotes);
        renderedEvents = new FlxTypedGroup<StrumEvent>(); renderedEvents.cameras = [camHUD]; add(renderedEvents);

        cursor_Arrow = new Note(Note.getNoteData(), Song.getStrumKeys(_song.sectionStrums[curStrum], curSection));
        cursor_Arrow.note_size.set(KEYSIZE,KEYSIZE);
        cursor_Arrow.cameras = [camHUD];
        cursor_Arrow.onDebug = true;
        add(cursor_Arrow);

        cursor_Event  = new StrumEvent(0);
        cursor_Event.note_size.set(KEYSIZE,KEYSIZE);
        cursor_Event.cameras = [camHUD];
        cursor_Event.onDebug = true;
        add(cursor_Event);

        strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
        strumLine.cameras = [camHUD];
		//strumLine.visible = false;
		add(strumLine);
        
        strumLineEvent = new FlxSprite(0, 50).makeGraphic(KEYSIZE, 4);
        strumLineEvent.cameras = [camHUD];
		add(strumLineEvent);

        btnAddStrum = new FlxCustomButton(0, 0, KEYSIZE, KEYSIZE, "", [Paths.image('editor_assets/addStrum').getGraphic(), false, 0, 0], null, function(){
            var nStrum:SwagStrum = {
                isPlayable: true,
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

            for(i in 0...curSection){addSection(_song.sectionStrums.length - 1, _song.generalSection[i].lengthInSteps);}

            updateSection();
        });
        btnAddStrum.cameras = [camHUD];
        btnAddStrum.scrollFactor.set(1, 0);
        add(btnAddStrum);

        btnDelStrum = new FlxCustomButton(0, KEYSIZE * 1.5, KEYSIZE, KEYSIZE, "", [Paths.image('editor_assets/delStrum').getGraphic(), false, 0, 0], null, function(){
            if(_song.sectionStrums.length <= 1){return;}
    
            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            changeStrum(-1);
            
            for(section in _song.generalSection){if(section.strumToFocus >= _song.sectionStrums.length){section.strumToFocus = _song.sectionStrums.length - 1;}}
            updateSection();
        });
        btnDelStrum.cameras = [camHUD];
        btnDelStrum.scrollFactor.set(1, 0);
        add(btnDelStrum);

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

        lblSongInfo = new FlxText(0, 50, 300, "", 16);
        lblSongInfo.scrollFactor.set();
        lblSongInfo.camera = camFHUD;
        add(lblSongInfo);

        voices = new FlxSoundGroup();
        loadAudio(_song.song, _song.category);
        conductor.changeBPM(_song.bpm);
		conductor.mapBPMChanges(_song);

        var btn_infogen:FlxUIButton = new FlxUICustomButton(10, 0, Std.int(KEYSIZE / 1.5), Std.int(KEYSIZE / 1.5), '', Paths.image("info"), null, function(){
            persistentUpdate = false; canControlle = false;
            openSubState(new substates.InformationSubState(LangSupport.getText("charting_adv_1"), function(){
                persistentUpdate = true; canControlle = true;
            }));
        });
        btn_infogen.y = FlxG.height - btn_infogen.height - 10;
        btn_infogen.antialiasing = true;
        btn_infogen.scrollFactor.set();
        btn_infogen.cameras = [camHUD];
        add(btn_infogen);

        _saved = new Alphabet(0,0,[{scale:0.3,bold:true,text:"Song Saved"}]);
        _saved.alpha = 0;
        _saved.cameras = [camFHUD];
        add(_saved);

        super.create();
        
        //camBHUD.alpha = 0;
        camBHUD.zoom = 0.5;

        backFollow = new FlxObject(0, 0, 1, 1);
        backFollow.screenCenter();
		camBHUD.follow(backFollow, LOCKON, 0.04);

        genFollow = new FlxObject(0, 0, 1, 1);
        FlxG.camera.follow(genFollow, LOCKON);
        camHUD.follow(genFollow, LOCKON);
        camBHUD.zoom = stage.zoom;
        
		changeSection(curSection);
    }
    
    function updateSection(value:Int = 0, force:Bool = false):Void {
        changeStrum(value, force);

        updateStage();

        //trace(_song.characters);
        sHitsArray.resize(_song.sectionStrums.length);
        
		if(_song.generalSection[curSection].changeBPM && _song.generalSection[curSection].bpm > 0){
			conductor.changeBPM(_song.generalSection[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
        }else{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for(i in 0...curSection){if(_song.generalSection[i].changeBPM){daBPM = _song.generalSection[i].bpm;}}
			conductor.changeBPM(daBPM);
		}

        reloadChartGrid();
        
        curGrid = gridGroup.members[curStrum + 1];

        btnDelStrum.x = curGrid.x + curGrid.width + 5;
        if(strumLine.width != Std.int(curGrid.width)){strumLine.makeGraphic(Std.int(curGrid.width), 4);}
        
        renderedEvents.clear();
        var eventsInfo:Array<Dynamic> = _song.generalSection[curSection].events.copy();
        if(eventsInfo != null){
            for(e in eventsInfo){
                var eData:EventData = Note.getEventData(e);
                var isSelected:Bool = Note.compNotes(eData, selEvent, false);
        
                var note:StrumEvent = new StrumEvent(eData.strumTime, conductor, eData.isExternal, eData.isBroken);
                setupNote(note, -1);
                note.alpha = isSelected || inst.playing ? 1 : 0.5;
    
                renderedEvents.add(note);
            }
        }

        notesCanHit = [];
        renderedNotes.clear();
        renderedSustains.clear();
        for(ii in 0..._song.sectionStrums.length){
            notesCanHit.push([]);

            var sectionInfo:Array<Dynamic> = _song.sectionStrums[ii].notes[curSection].sectionNotes.copy();
            for(n in sectionInfo){if(n[1] < 0 || n[1] >= Song.getStrumKeys(_song.sectionStrums[ii], curSection)){sectionInfo.remove(n);}}
            
            var cSection = _song.sectionStrums[ii];
            var slide_gp:Array<Note> = [];
            for(n in sectionInfo){
                var nData:NoteData = Note.getNoteData(n);
                var isSelected:Bool = Note.compNotes(nData, selNote);
        
                var note:Note = new Note(nData, Song.getStrumKeys(cSection, curSection), null, cSection.noteStyle);
                setupNote(note, ii);
                note.alpha = isSelected || inst.playing ? 1 : 0.5;

                if(note.otherData.length > 0){
                    var iconEvent:StrumEvent = new StrumEvent(nData.strumTime, conductor);
                    iconEvent.setPosition(note.x, note.y);
                    iconEvent.note_size.set(Std.int(KEYSIZE / 3), Std.int(KEYSIZE / 3));
                    iconEvent.alpha = note.alpha;
                    renderedEvents.add(iconEvent);
                }

                if(nData.canMerge){slide_gp.push(note);}
                        
                renderedNotes.add(note);
                notesCanHit[ii].push(note);
        
                if(nData.sustainLength <= 0){continue;}
        
                if(nData.multiHits > 0){
                    var totalHits:Int = nData.multiHits + 1;
                    var hits:Int = nData.multiHits;
                    var curHits:Int = 1;
                    note.noteHits = 0;
                    nData.multiHits = 0;
        
                    while(hits > 0){
                        var newStrumTime = nData.strumTime + (nData.sustainLength * curHits);
                        var nSData:NoteData = Note.getNoteData(Note.convNoteData(nData));
                        nSData.strumTime = newStrumTime;
        
                        var hitNote:Note = new Note(nSData, Song.getStrumKeys(cSection, curSection), null, cSection.noteStyle);
                        setupNote(hitNote, ii);
                        hitNote.alpha = isSelected || inst.playing ? 1 : 0.5;
                        
                        renderedNotes.add(hitNote);
                        notesCanHit[ii].push(hitNote);
        
                        hits--;
                        curHits++;
                    }
                }else{
                    var cSusNote:Int = Math.floor(nData.sustainLength / (conductor.stepCrochet / 4) + 1);

                    var nSData:NoteData = Note.getNoteData(Note.convNoteData(nData));
                    nSData.strumTime += (conductor.stepCrochet / 2);
                    var nSustain:Note = new Note(nSData, Song.getStrumKeys(cSection, curSection), null, cSection.noteStyle);
                    nSustain.typeNote = "Sustain";
                    nSustain.typeHit = "Hold";
                    note.nextNote = nSustain;
                    setupNote(nSustain, ii);
                    nSustain.alpha = isSelected || inst.playing ? 0.5 : 0.3;
                    renderedSustains.add(nSustain);
                    notesCanHit[ii].push(nSustain);
                    
                    var nEData:NoteData = Note.getNoteData(Note.convNoteData(nData));
                    nEData.strumTime += ((conductor.stepCrochet / 4) * (cSusNote + 2));
                    var nSustainEnd:Note = new Note(nEData, Song.getStrumKeys(cSection, curSection), null, cSection.noteStyle);
                    nSustainEnd.typeNote = "Sustain";
                    nSustainEnd.typeHit = "Hold";
                    nSustain.nextNote = nSustainEnd;
                    setupNote(nSustainEnd, ii);
                    nSustainEnd.alpha = isSelected || inst.playing ? 0.5 : 0.3;
                    renderedSustains.add(nSustainEnd);
                    notesCanHit[ii].push(nSustainEnd);

                    if(nData.canMerge){slide_gp.push(nSustainEnd);}
                }
            }

            slide_gp.sort(function(a, b) {
                if(a.strumTime < b.strumTime) return -1;
                else if(a.strumTime > b.strumTime) return 1;
                else if(a.noteData < b.noteData) return -1;
                else if(a.noteData > b.noteData) return 1;
                else return 0;
             });

            while(slide_gp.length > 0){
                var first_slide = slide_gp.shift();
                
                for(second_slide in slide_gp){
                    if(first_slide.strumTime != second_slide.strumTime){continue;}
                    if(first_slide.noteData == second_slide.noteData){continue;}
                    first_slide.typeNote = "Merge";
                    second_slide.typeNote = "Merge";

                    var new_slide:Note = new Note(Note.getNoteData([first_slide.strumTime]), Song.getStrumKeys(cSection, curSection), null, cSection.noteStyle);
                    setupNote(new_slide, ii);
                    first_slide.nextNote = new_slide;
                    new_slide.nextNote = second_slide;
                    new_slide.typeNote = "Switch";
                    new_slide.setPosition(first_slide.x + (new_slide.width / 2), first_slide.y);
                    new_slide.shader = ShaderColorSwap.get_shader(new_slide.note_path.getColorNote(), first_slide.playColor, second_slide.playColor);
                    new_slide.alpha = 0.3;
                    renderedSustains.add(new_slide);

                    break;
                }
            }
        }
        
        updateValues();
    }
    
    var s_Characters:Array<Dynamic> = [];
    function updateStage():Void {
        if(selCharacter < 0){clCharacters.setIndex(0);}
        if(selCharacter >= _song.characters.length){clCharacters.setIndex(_song.characters.length - 1);}

        if(stage.curStage == _song.stage && s_Characters == _song.characters){return;}
        s_Characters = _song.characters.copy();

        stage.loadStage(_song.stage);
        stage.setCharacters(_song.characters);
        camBHUD.zoom = stage.zoom;
    }

    var g_STRUMS:Int = 0; var g_KEYSIZE:Int = 0; var g_STEPSLENGTH:Int = 0; var g_STRUMKEYS:Array<Int> = [];
    function reloadChartGrid(force:Bool = false):Void {
        var toChange:Bool = force;

        g_STRUMKEYS.resize(_song.sectionStrums.length);
        for(i in 0...g_STRUMKEYS.length){if(Song.getStrumKeys(_song.sectionStrums[i], curSection) != g_STRUMKEYS[i]){toChange = true; break;}}
        if(_song.generalSection[curSection].lengthInSteps != g_STEPSLENGTH){toChange = true;}
        if(g_STRUMS != _song.sectionStrums.length){toChange = true;}
        if(KEYSIZE != g_KEYSIZE){toChange = true;}
        
        if(!toChange){return;}

        while(gridGroup.members.length > _song.sectionStrums.length + 1){gridGroup.remove(gridGroup.members[gridGroup.members.length - 1], true);}
        while(gridGroup.members.length < _song.sectionStrums.length + 1){gridGroup.add(new FlxSprite());}
        
        if(chkHideStrums.checked){strumStatics.clear();}else{
            while(strumStatics.members.length > _song.sectionStrums.length){strumStatics.remove(strumStatics.members[strumStatics.members.length - 1], true);}
            while(strumStatics.members.length < _song.sectionStrums.length){strumStatics.add(new StaticNotes(0,0));}
        }

        backGroup.clear();
        stuffGroup.clear();
        
        var lastWidth:Float = 0;
        var daLehgthSteps:Int = _song.generalSection[curSection].lengthInSteps;

        // EVENT GRID STRUFF
        var evGrid = gridGroup.members[0];
        evGrid = FlxGridOverlay.create(KEYSIZE, Std.int(KEYSIZE / 2), KEYSIZE, KEYSIZE * daLehgthSteps, true, 0xff4d4d4d, 0xff333333);
        evGrid.x -= KEYSIZE * 1.5;
        if(inst.playing){evGrid.alpha = 0.5;} 
        gridGroup.members[0] = evGrid;

        eveGrid = gridGroup.members[0];
        strumLineEvent.makeGraphic(KEYSIZE, 4); strumLineEvent.x = eveGrid.x;

        var line_1 = new FlxSprite(evGrid.x - 1,0).makeGraphic(2, FlxG.height, FlxColor.BLACK); line_1.scrollFactor.set(1, 0); stuffGroup.add(line_1);
        var eBack = new FlxSprite(evGrid.x,0).makeGraphic(KEYSIZE, FlxG.height, FlxColor.BLACK); eBack.alpha = 0.5; eBack.scrollFactor.set(1, 0); backGroup.add(eBack);
        var line_2 = new FlxSprite(evGrid.x + KEYSIZE - 1,0).makeGraphic(2, FlxG.height, FlxColor.BLACK); line_2.scrollFactor.set(1, 0); stuffGroup.add(line_2);

        var line_3 = new FlxSprite(-1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK); line_3.scrollFactor.set(1, 0); stuffGroup.add(line_3);
        for(i in 0..._song.sectionStrums.length){
            var daGrid = gridGroup.members[i + 1];
            var daKeys:Int = Song.getStrumKeys(_song.sectionStrums[i], curSection);

            if(daGrid != null && daGrid.width == daKeys * KEYSIZE && !toChange){continue;}

            daGrid = FlxGridOverlay.create(KEYSIZE, KEYSIZE, KEYSIZE * daKeys, KEYSIZE * daLehgthSteps, true, 0xffe7e6e6, 0xffd9d5d5);
            if(i != curStrum || inst.playing){daGrid.alpha = 0.5;}
            daGrid.x = lastWidth; daGrid.ID = i;

            if(!chkHideStrums.checked){
                var curStatics = strumStatics.members[i];
                curStatics.style = _song.sectionStrums[i].noteStyle;
                curStatics.changeKeyNumber(daKeys, Std.int(KEYSIZE * daKeys), true, true);
                for(c in curStatics.statics){c.autoStatic = true;}
                curStatics.x = lastWidth;
            }

            if(_song.hasVoices && sVoicesArray.length > i){
                var btnToggleVoice:FlxUIButton = new FlxUICustomButton(0, 0, Std.int(KEYSIZE / 2), Std.int(KEYSIZE / 2), "", Paths.image("editor_assets/"+(!sVoicesArray[i] ? "on_mic" : "off_mic")), null, function(){
                    if(sVoicesArray.length <= i){return;} sVoicesArray[i] = !sVoicesArray[i]; reloadChartGrid(true);
                });
                btnToggleVoice.setPosition(daGrid.x + (KEYSIZE*0.75), -(btnToggleVoice.height) - 5);
                btnToggleVoice.scrollFactor.set(1, 1);
                stuffGroup.add(btnToggleVoice);
            }

            var btnPlayer:FlxUIButton = new FlxUICustomButton(0, 0, Std.int(KEYSIZE/2), Std.int(KEYSIZE/2), "", Paths.image("editor_assets/"+(_song.sectionStrums[i].isPlayable ? "on_play" : "off_play")),  null, function(){
                _song.sectionStrums[i].isPlayable = !_song.sectionStrums[i].isPlayable;
                reloadChartGrid(true);
            });
            btnPlayer.setPosition(daGrid.x + (daGrid.width/2) - (btnPlayer.width/2), -(btnPlayer.height) - 5);
            btnPlayer.scrollFactor.set(1, 1);
            stuffGroup.add(btnPlayer);
            
            var btnToggleHitSound:FlxUIButton = new FlxUICustomButton(0, -(KEYSIZE*1.75), Std.int(KEYSIZE / 2), Std.int(KEYSIZE / 2), "", Paths.image("editor_assets/"+(sHitsArray[i] ? "on_hit" : "off_hit")), null, function(){
                if(sHitsArray.length <= i){return;} sHitsArray[i] = !sHitsArray[i]; reloadChartGrid(true);
            });
            btnToggleHitSound.setPosition(daGrid.x + daGrid.width - (KEYSIZE*0.75) - btnToggleHitSound.width, -(btnToggleHitSound.height) - 5);
            btnToggleHitSound.scrollFactor.set(1, 1);
            stuffGroup.add(btnToggleHitSound);

            lastWidth += daGrid.width;

            var new_line = new FlxSprite(lastWidth - 1, 0).makeGraphic(2, FlxG.height, FlxColor.BLACK); new_line.scrollFactor.set(1, 0); stuffGroup.add(new_line);

            gridGroup.members[i + 1] = daGrid;
        }

        var genBack = new FlxSprite().makeGraphic(Std.int(lastWidth), FlxG.height, FlxColor.BLACK); genBack.alpha = 0.5; genBack.scrollFactor.set(1, 0); backGroup.add(genBack);
        
        btnAddStrum.x = lastWidth + 5;
        
        g_STRUMS = _song.sectionStrums.length; g_KEYSIZE = KEYSIZE; g_STEPSLENGTH = daLehgthSteps; for(i in 0...g_STRUMKEYS.length){g_STRUMKEYS[i] = Song.getStrumKeys(_song.sectionStrums[i], curSection);}
    }

    var pressedNotes:Array<NoteData> = [];
    override function update(elapsed:Float){
        curStep = recalculateSteps();
        
        if(inst.time < 0) {
			inst.pause();
			inst.time = 0;
		}else if(inst.time > inst.length) {
			inst.pause();
			inst.time = 0;
			changeSection();
		}

        conductor.songPosition = inst.time;

        if(_song.generalSection[curSection] != null){strumLine.y = getYfromStrum((conductor.songPosition - sectionStartTime()));}
        for(strums in strumStatics){strums.y = strumLine.y;} strumLineEvent.y = strumLine.y;

        if(_song.generalSection[curSection + 1] == null){addGenSection();}
        for(i in 0..._song.sectionStrums.length){if(_song.sectionStrums[i].notes[curSection + 1] == null){addSection(i, _song.generalSection[curSection].lengthInSteps, Song.getStrumKeys(_song.sectionStrums[i], curSection));}}

        if(Math.ceil(strumLine.y) >= curGrid.height){changeSection(curSection + 1, false);}
        if(strumLine.y <= -10){changeSection(curSection - 1, false);}
    
        FlxG.watch.addQuick('daBeat', curBeat);
        FlxG.watch.addQuick('daStep', curStep);


        lblSongInfo.text = 
        "Time: " + Std.string(FlxMath.roundDecimal(conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(inst.length / 1000, 2)) +
		"\n\nSection: " + curSection +
		"\nBeat: " + curBeat +
		"\nStep: " + curStep;

        inst.volume = chkMuteInst.checked ? 0 : 1;
        for(i in 0...voices.sounds.length){voices.sounds[i].volume = !sVoicesArray[i] && !chkMuteVoices.checked ? 1 : 0;}

        if(FlxG.mouse.pressed){cursor_Arrow.alpha = 1; cursor_Event.alpha = 1;}else{cursor_Arrow.alpha = 0.5; cursor_Event.alpha = 0.5;}
        if(inst.playing){
            eveGrid.alpha = 0.5;
            cursor_Arrow.alpha = 0;
            cursor_Event.alpha = 0;
            for(grid in gridGroup){grid.alpha = 0.5;}

            Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(_song, curSection)), backFollow, stage);

            for(i in 0...notesCanHit.length){
                for(n in notesCanHit[i]){
                    if(n.strumTime >= conductor.songPosition){continue;}
                    notesCanHit[i].remove(n);

                    if(n.hitMiss){continue;}
                    if(!chkHideStrums.checked){strumStatics.members[i].playById((n.noteData % Song.getStrumKeys(_song.sectionStrums[i], curSection)), "confirm", true);}
                    if(!chkMuteHitSounds.checked && sHitsArray[i] && n.typeHit != "Hold"){FlxG.sound.play(Paths.sound("CLAP").getSound());}

                    var song_animation:String = n.singAnimation;
                    if(_song.sectionStrums[i].notes[curSection].altAnim){song_animation += '-alt';}

                    for(i in Song.getNoteCharactersToSing(n, _song.sectionStrums[i], curSection)){
                        if(stage.getCharacterById(i) != null){
                            stage.getCharacterById(i).playAnim(song_animation, true);
                        }
                    }
                }
            }

            btnAddStrum.kill();
            btnDelStrum.kill();
        }else{
            eveGrid.alpha = 1;
            MagicStuff.doToMember(cast gridGroup, curStrum + 1, function(grid){grid.alpha = 1;}, function(grid){grid.alpha = 0.5;});           
            
            if(chkFocusChar.checked){
                Character.setCameraToCharacter(stage.getCharacterById(selCharacter), backFollow, stage);
            }else{
                Character.setCameraToCharacter(stage.getCharacterById(Character.getFocusCharID(_song, curSection, curStrum)), backFollow, stage);
            }

            btnAddStrum.revive();
            btnDelStrum.revive();
        }
        if(chkDisableStrumButtons.checked){btnAddStrum.kill(); btnDelStrum.kill();}

        var arrayControlle = true;
        for(item in arrayFocus){if(item.hasFocus){arrayControlle = false;}}

        if(canControlle && arrayControlle){
		    _song.bpm = tempBpm;

            if(!inst.playing){
                if(!chkHideChart.checked && (FlxG.mouse.x > eveGrid.x && FlxG.mouse.x < eveGrid.x + eveGrid.width && FlxG.mouse.y > eveGrid.y && FlxG.mouse.y < eveGrid.y + eveGrid.height)){
                    cursor_Arrow.alpha = 0;
                    
                    cursor_Event.x = eveGrid.x;
        
                    cursor_Event.y = Math.floor(FlxG.mouse.y / (KEYSIZE / 2)) * (KEYSIZE / 2);
                    if(FlxG.keys.pressed.SHIFT){cursor_Event.y = FlxG.mouse.y;}
                    
                    if(FlxG.mouse.justPressed){checkToAddEvent();}        
                    if(FlxG.mouse.justReleased){checkToAddEvent(true);}
                    if(FlxG.mouse.justPressedRight){reloadSelectedEvent();}
                }else if(!chkHideChart.checked && (FlxG.mouse.x > curGrid.x && FlxG.mouse.x < curGrid.x + curGrid.width && FlxG.mouse.y > curGrid.y && FlxG.mouse.y < curGrid.y + curGrid.height)){
                    cursor_Event.alpha = 0;
    
                    cursor_Arrow.x = Math.floor(FlxG.mouse.x / KEYSIZE) * KEYSIZE;
        
                    cursor_Arrow.y = Math.floor(FlxG.mouse.y / (KEYSIZE / stpHeightSize.value)) * (KEYSIZE / stpHeightSize.value);
                    if(FlxG.keys.pressed.SHIFT){cursor_Arrow.y = FlxG.mouse.y;}
        
                    var data:Int = (Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE)) % (Song.getStrumKeys(_song.sectionStrums[curStrum], curSection));
                    if(cursor_Arrow.noteData != data || cursor_Arrow.noteKeys != Song.getStrumKeys(_song.sectionStrums[curStrum], curSection)){cursor_Arrow.setupData(data, Song.getStrumKeys(_song.sectionStrums[curStrum], curSection));}
                    if(_song.sectionStrums[curStrum] != null && cursor_Arrow.style != _song.sectionStrums[curStrum].noteStyle){cursor_Arrow.loadNote("NOTE_assets", _song.sectionStrums[curStrum].noteStyle);}
            
                    if(FlxG.mouse.justPressed){checkToAddNote();}
                    if(FlxG.mouse.justReleased){checkToAddNote(true);}
                    if(FlxG.mouse.justPressedRight){reloadSelectedNote();}
                }else{cursor_Arrow.alpha = 0; cursor_Event.alpha = 0;}
            }

            if(FlxG.keys.justPressed.SPACE){
                if(inst.playing){
                    inst.pause();
                    for(voice in voices.sounds){voice.pause();}
                }else{
                    for(voice in voices.sounds){voice.play();}
                    inst.play();
                }
                for(voice in voices.sounds){voice.time = inst.time;}
                updateSection();
            }
    
            if(FlxG.keys.anyJustPressed([UP, DOWN, W, S, R, E, Q]) || FlxG.mouse.wheel != 0){
                inst.pause();
                for(voice in voices.sounds){voice.pause();}
            }

            if(FlxG.keys.justPressed.R){
                if(FlxG.keys.pressed.CONTROL){KEYSIZE = DEFAULT_KEYSIZE; cursor_Arrow.note_size.set(KEYSIZE,KEYSIZE); updateSection();}
                else if(FlxG.keys.pressed.SHIFT){resetSection(true);}
                else{resetSection();}
            }

            if(FlxG.mouse.wheel != 0){
                if(FlxG.keys.pressed.CONTROL){KEYSIZE += Std.int(FlxG.mouse.wheel * (KEYSIZE / 5)); cursor_Arrow.note_size.set(KEYSIZE,KEYSIZE); updateSection();}
                else if(FlxG.keys.pressed.SHIFT){inst.time -= (FlxG.mouse.wheel * conductor.stepCrochet * 0.5);}
                else{inst.time -= (FlxG.mouse.wheel * conductor.stepCrochet * 1);}
            }
    
            if(!FlxG.keys.pressed.SHIFT){    
                if(FlxG.keys.justPressed.E){changeNoteSustain(conductor.stepCrochet * 0.25);}
                if(FlxG.keys.justPressed.Q){changeNoteSustain(-(conductor.stepCrochet * 0.25));}
    
                if(!inst.playing){
                    if(FlxG.keys.anyPressed([UP, W])){
                        var daTime:Float = conductor.stepCrochet * 0.1;
                        inst.time -= daTime;
                    }
                    if(FlxG.keys.anyPressed([DOWN, S])){
                        var daTime:Float = conductor.stepCrochet * 0.1;
                        inst.time += daTime;
                    }
                }
        
                if(FlxG.keys.anyJustPressed([LEFT, A])){changeSection(curSection - 1);}
                if(FlxG.keys.anyJustPressed([RIGHT, D])){changeSection(curSection + 1);}
            }else{    
                if(FlxG.keys.justPressed.E){changeNoteHits(1);}
                if(FlxG.keys.justPressed.Q){changeNoteHits(-1);}
        
                if(!inst.playing){
                    if(FlxG.keys.anyPressed([UP, W])){
                        var daTime:Float = conductor.stepCrochet * 0.05;
                        inst.time -= daTime;
                    }
                    if(FlxG.keys.anyPressed([DOWN, S])){
                        var daTime:Float = conductor.stepCrochet * 0.05;
                        inst.time += daTime;
                    }
                }
        
                if(FlxG.keys.anyJustPressed([LEFT, A])){updateSection(-1);}
                if(FlxG.keys.anyJustPressed([RIGHT, D])){updateSection(1);}
            }
    
            if(FlxG.mouse.justPressedRight){
                if(FlxG.mouse.overlaps(gridGroup)){for(g in gridGroup){if(FlxG.mouse.overlaps(g) && gridGroup.members[0] != g && g.ID != curStrum){updateSection(g.ID, true);}}}
            }
            
            if(principal_controls.checkAction("Menu_Accept", JUST_PRESSED) && onConfirm == null){SongListData.loadAndPlaySong(_song);}
        }

        var fgrid:FlxSprite = gridGroup.members[_song.generalSection[curSection].strumToFocus + 1];
        focusStrum.setPosition(FlxMath.lerp(focusStrum.x, fgrid.x, 0.5), fgrid.y);
        if(focusStrum.width != fgrid.width || focusStrum.height != fgrid.height){focusStrum.makeGraphic(Std.int(FlxMath.lerp(focusStrum.width, fgrid.width, 0.5)), Std.int(FlxMath.lerp(focusStrum.height, fgrid.height, 0.5)), FlxColor.YELLOW);}

        strumLine.x = curGrid.x;
        genFollow.setPosition(FlxMath.lerp(genFollow.x, curGrid.x + (curGrid.width / 2) + (MENU.width / 2), 0.50), strumLine.y);
        super.update(elapsed);
    }

    function updateNoteValues():Void {
        if(selNote != null){
            stpStrumLine.value = selNote.strumTime;
            stpNoteLength.value = selNote.sustainLength;
            stpNoteHits.value = selNote.multiHits;
            clNotePressets.setLabel(selNote.preset, true);
            btnCanMerge.label.text = selNote.canMerge ? 'Is Slide' : 'Is Not Slide';
            var events:Array<String> = []; for(e in selNote.eventData){events.push(e[0]);} clNoteEventList.setData(events);
            clNoteEventList.setLabel(clNoteEventList.getSelectedLabel(), false, true);
        }else{
            stpStrumLine.value = 0;
            stpNoteLength.value = 0;
            stpNoteHits.value = 0;
            clNotePressets.setLabel("Default", true);
            btnCanMerge.label.text =  "Note UnSelected";            
            clNoteEventList.setData([]); clNoteEventList.setLabel(clNoteEventList.getSelectedLabel(), false, true);
        }

        if(selEvent != null){
            stpEventStrumLine.value = selEvent.strumTime;
            var events:Array<String> = []; for(e in selEvent.eventData){events.push(e[0]);} clEventListEvents.setData(events);
            clEventListEvents.setLabel(clEventListEvents.getSelectedLabel(), false, true);
            btnChangeEventFile.label.text = selEvent.isExternal ? "Global Event" : "Local Event";
            if(selEvent.isExternal){
                btnBrokeExternalEvent.active = true;
                btnBrokeExternalEvent.alpha = 1;
                btnBrokeExternalEvent.label.text = selEvent.isBroken ? "Event Broken" : "Event Active";
            }else{
                btnBrokeExternalEvent.active = false;
                btnBrokeExternalEvent.alpha = 0.5;
                btnBrokeExternalEvent.label.text = "Event is Local";
            }
        }else{
            stpEventStrumLine.value = 0;
            clEventListEvents.setData([]); clEventListEvents.setLabel(clEventListEvents.getSelectedLabel(), false, true);
        }
    }

    function updateValues():Void {
        var arrChars = []; for(c in _song.characters){arrChars.push(c[0]);}
        
        clStrumCharsToAdd.setData(arrChars);
        clSecStrumCharsToAdd.setData(arrChars);
        clCharacters.setData(arrChars);

        clEventListToNote.setData(Note.getNoteEvents(true,_song.stage));
        clEventListToEvents.setData(Note.getNoteEvents(_song.stage));
        
        clCharacters.setSuffix(' > [${selCharacter + 1}/${_song.characters.length}]');

        if(_song.characters[selCharacter] != null){
            txtCharacter.text = _song.characters[selCharacter][0];
            txtAspect.text = _song.characters[selCharacter][4];
            chkLEFT.checked = _song.characters[selCharacter][3];
            stpCharX.value = _song.characters[selCharacter][1][0];
            stpCharY.value = _song.characters[selCharacter][1][1];
            stpCharSize.value = _song.characters[selCharacter][2];
            stpCharLayout.value = _song.characters[selCharacter][6];
        }else{
            txtAspect.text = "";
            chkLEFT.checked = false;
            stpCharX.value = 0;
            stpCharY.value = 0;
            stpCharSize.value = 0;
            stpCharLayout.value = 0;
        }
        
        if(_song.sectionStrums[curStrum] != null){
            stpSrmKeys.value = _song.sectionStrums[curStrum].keys;
            lblCharsToSing.text = "Characters to Sing: |"; for(c in _song.sectionStrums[curStrum].charToSing){lblCharsToSing.text += ' [${c+1}]:${arrChars[c]} |';}
            clNoteStyle.setLabel(_song.sectionStrums[curStrum].noteStyle, true);
        }

        if(_song.sectionStrums[curStrum].notes[curSection] != null){
            chkALT.checked = _song.sectionStrums[curStrum].notes[curSection].altAnim;
            stpKeys.value = _song.sectionStrums[curStrum].notes[curSection].keys;
            chkKeys.checked = _song.sectionStrums[curStrum].notes[curSection].changeKeys;
            chkSwitchChars.checked = _song.sectionStrums[curStrum].notes[curSection].changeSing;
            lblSecCharsToSing.text = "Characters to Sing: |"; for(c in _song.sectionStrums[curStrum].notes[curSection].charToSing){lblSecCharsToSing.text += ' [${c+1}]:${arrChars[c]} |';}
        }

        if(_song.generalSection[curSection] != null){
            stpSecBPM.value = _song.generalSection[curSection].bpm;
            chkBPM.checked = _song.generalSection[curSection].changeBPM;
            stpLength.value = _song.generalSection[curSection].lengthInSteps;
            stpSecStrum.value = _song.generalSection[curSection].strumToFocus;
    
            var arrGenChars = []; for(c in _song.sectionStrums[_song.generalSection[curSection].strumToFocus].charToSing){arrGenChars.push('[$c]:${arrChars[c]}');} clGenFocusChar.setData(arrGenChars);    
        }
    }

    override function stepHit(){super.stepHit();}
    override function beatHit(){super.beatHit();}

    function setupNote(note:Dynamic, ?grid:Int):Void {
        note.note_size.set(KEYSIZE,KEYSIZE);
        if(note.typeNote == "Switch"){note.note_size.set(KEYSIZE , KEYSIZE / 4);}

        note.onDebug = true;
        note.y = Math.floor(getYfromStrum((note.strumTime - sectionStartTime())));
        note.x = gridGroup.members[grid + 1].x;
        if(!(note is StrumEvent)){note.x += Math.floor(note.noteData * KEYSIZE);}
    }

    function changeStrum(value:Int = 0, force:Bool = false):Void{
        curStrum = !force ? curStrum + value : value;

        if(chkCamFocusStrum.checked && inst.playing){curStrum = _song.generalSection[curSection].strumToFocus;}

        if(curStrum >= _song.sectionStrums.length){curStrum = _song.sectionStrums.length - 1;}
        if(curStrum < 0){curStrum = 0;}
    }

    
    function loadSong(daSong:String, cat:String, diff:String) {
        resetSection(true);

        daSong = Song.fileSong(daSong, cat, diff);
        _song = Song.loadFromJson(daSong);

		MusicBeatState.loadState("states.editors.ChartEditorState", [this.onBack, this.onConfirm], [[{type:"SONG",instance:_song}], false]);
    }

    function loadAudio(daSong:String, cat:String):Void {
		if(FlxG.sound.music != null){inst.stop();}

        inst = new FlxSound().loadEmbedded(Paths.inst(daSong, cat).getSound());
        FlxG.sound.list.add(inst);

        sVoicesArray = [];
        voices.sounds = [];
        if(_song.hasVoices){
            for(i in 0..._song.characters.length){
                var voice = new FlxSound().loadEmbedded(Paths.voice(i, _song.characters[i][0], daSong, cat).getSound());
                FlxG.sound.list.add(voice);
                sVoicesArray.push(false);
                voices.add(voice);
            }
        }

		inst.onComplete = function(){
			voices.pause();
			inst.pause();
			inst.time = 0;
            for(voice in voices.sounds){voice.time = 0;}
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
            if(inst.time > conductor.bpmChangeMap[i].songTime){
                lastChange = conductor.bpmChangeMap[i];
            }
        }
    
        curStep = lastChange.stepTime + Math.floor((inst.time - lastChange.songTime) / conductor.stepCrochet);
        updateBeat();
    
        return curStep;
    }

    function resetSection(songBeginning:Bool = false):Void{
        updateSection();
    
        inst.pause();
        for(voice in voices.sounds){voice.pause();}
    
        // Basically old shit from changeSection???
        inst.time = sectionStartTime();
    
        if(songBeginning){
            inst.time = 0;
            curSection = 0;
        }
    
        for(voice in voices.sounds){voice.time = inst.time;}
        updateCurStep(); updateSection();
    }

    function changeNoteSustain(value:Float):Void{
        updateSelectedNote(function(curNote){
            curNote.sustainLength += value;
            curNote.sustainLength = Math.max(curNote.sustainLength, 0);
    
            if(curNote.sustainLength <= 0 && curNote.multiHits > 0){curNote.multiHits = 0;}
        });
    }

    function changeNoteHits(value:Int):Void{
        updateSelectedNote(function(curNote){
            if(curNote.sustainLength <= 0){changeNoteSustain(conductor.stepCrochet);}

            curNote.multiHits += value;
            curNote.multiHits = Std.int(Math.max(curNote.multiHits, 0));
        });
    }

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void{
		if(_song.generalSection[sec] == null){return;}
        curSection = sec;

		updateSection();

		if(updateMusic){
			inst.pause();
			voices.pause();

			inst.time = sectionStartTime();
               for(voice in voices.sounds){voice.time = inst.time;}
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

    private function getSwagEvent(event:Array<Dynamic>):Array<Dynamic> {
        if(_song.generalSection[curSection] == null || _song.generalSection[curSection].events == null){return null;}

        for(e in _song.generalSection[curSection].events){if(Note.compNotes(Note.getEventData(event), Note.getEventData(e), false)){return e;}}
        return null;
    }
    private function getSwagNote(note:Array<Dynamic>, ?strum:Int):Array<Dynamic> {
        if(strum == null){strum = curStrum;}
        if(_song.sectionStrums[strum] == null || _song.sectionStrums[strum].notes[curSection] == null || _song.sectionStrums[strum].notes[curSection].sectionNotes == null){return null;}
        for(n in _song.sectionStrums[strum].notes[curSection].sectionNotes){if(Note.compNotes(Note.getNoteData(note), Note.getNoteData(n))){return n;}}
        return null;
    }
    
    private function updateSelectedEvent(func:EventData->Void, nuFunc:Void->Void = null, updateValues:Bool = true):Void {
        var e = getSwagEvent(Note.convEventData(selEvent));
        if(e == null){
            if(nuFunc != null){nuFunc();}
        }else{
            var curEvent:EventData = Note.getEventData(e);
            func(curEvent);        
            Note.set_note(e, Note.convEventData(curEvent));
            selEvent = curEvent;
        }

        if(updateValues){updateNoteValues(); updateSection();}
    }
    private function updateSelectedNote(func:NoteData->Void, nuFunc:Void->Void = null, updateValues:Bool = true):Void {
        var n = getSwagNote(Note.convNoteData(selNote));
        if(n == null){
            if(nuFunc != null){nuFunc();}
        }else{
            var curNote:NoteData = Note.getNoteData(n);    
            func(curNote);            
            Note.set_note(n, Note.convNoteData(curNote));
            selNote = curNote;
        }

        if(updateValues){updateNoteValues(); updateSection();}
    }

    private function reloadSelectedEvent():Void {
        selEvent.strumTime = getStrumTime(cursor_Event.y) + sectionStartTime();
        for(e in _song.generalSection[curSection].events.copy()){if(Note.compNotes(selEvent, Note.getEventData(e), false)){selEvent = Note.getEventData(e); break;}}
        updateNoteValues(); updateSection();
    }
    private function reloadSelectedNote():Void {
        selNote.strumTime = getStrumTime(cursor_Arrow.y) + sectionStartTime();
        selNote.keyData = Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE) % Song.getStrumKeys(_song.sectionStrums[curStrum], curSection);
        for(n in _song.sectionStrums[curStrum].notes[curSection].sectionNotes.copy()){if(Note.compNotes(selNote, Note.getNoteData(n))){selNote = Note.getNoteData(n); break;}}
        updateNoteValues(); updateSection();
    }

    var lastEvent:EventData = Note.getEventData();
    private function checkToAddEvent(isRelease:Bool = false):Void{
        var _event:EventData = Note.getEventData();
        _event.strumTime = getStrumTime(cursor_Event.y) + sectionStartTime();

        if(isRelease){
            if(getSwagEvent(Note.convEventData(_event)) == null && !Note.compNotes(lastEvent, _event, false)){
                _song.generalSection[curSection].events.push(Note.convEventData(_event));
                selEvent = _event;
            }
            lastEvent = Note.getEventData();
        }else{
            for(e in _song.generalSection[curSection].events){if(Note.compNotes(_event, Note.getEventData(e), false)){_song.generalSection[curSection].events.remove(e); lastEvent = Note.getEventData(Note.convEventData(_event)); break;}}
        }

        updateNoteValues(); updateSection();
    }
    var lastNote:NoteData = Note.getNoteData();
    private function checkToAddNote(isRelease:Bool = false):Void{
        var _note:NoteData = Note.getNoteData();
        _note.strumTime = getStrumTime(cursor_Arrow.y) + sectionStartTime();
        _note.keyData = Math.floor((FlxG.mouse.x - curGrid.x) / KEYSIZE) % Song.getStrumKeys(_song.sectionStrums[curStrum], curSection);
        _note.preset = clNotePressets.getSelectedLabel();

        if(isRelease){
            if(getSwagNote(Note.convNoteData(_note)) == null && !Note.compNotes(lastNote, _note)){
                _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push(Note.convNoteData(_note));
                selNote = _note;
            }
            lastNote = Note.getNoteData();
        }else{
            for(n in _song.sectionStrums[curStrum].notes[curSection].sectionNotes){if(Note.compNotes(_note, Note.getNoteData(n))){_song.sectionStrums[curStrum].notes[curSection].sectionNotes.remove(n); lastNote = Note.getNoteData(Note.convNoteData(_note)); break;}}
        }
        
        updateNoteValues(); updateSection();
    }

    function getYfromStrum(strumTime:Float):Float {    
        if(curGrid != null){return FlxMath.remapToRange(strumTime, 0, _song.generalSection[curSection].lengthInSteps * conductor.stepCrochet, curGrid.y, curGrid.y + curGrid.height);}
        return 0;
    }

    function getStrumTime(yPos:Float):Float{
        if(curGrid != null){return FlxMath.remapToRange(yPos, curGrid.y, curGrid.y + curGrid.height, 0, _song.generalSection[curSection].lengthInSteps * conductor.stepCrochet);}
        return 0;
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

    function copyLastSection(?sectionNum:Int = 1){
        var daSec = FlxMath.maxInt(curSection, sectionNum);
    
        for(strum in 0..._song.sectionStrums.length){
            for(note in _song.sectionStrums[strum].notes[daSec - sectionNum].sectionNotes){
                var curNote:NoteData = Note.getNoteData(note);
                curNote.strumTime = curNote.strumTime + conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
                if(getSwagNote(Note.convNoteData(curNote), strum) == null){_song.sectionStrums[strum].notes[daSec].sectionNotes.push(Note.convNoteData(curNote));}
            }
        }        
    
        updateSection();
    }

    function copyLastStrum(?sectionNum:Int = 1, ?strum:Int = 0){
        var daSec = FlxMath.maxInt(curSection, sectionNum);
    
        for(note in _song.sectionStrums[strum].notes[daSec - sectionNum].sectionNotes){
            var curNote:NoteData = Note.getNoteData(note);
            curNote.strumTime = curNote.strumTime + conductor.stepCrochet * (_song.generalSection[daSec].lengthInSteps * sectionNum);
            if(getSwagNote(Note.convNoteData(curNote), curStrum) == null){_song.sectionStrums[curStrum].notes[daSec].sectionNotes.push(Note.convNoteData(curNote));}
        }
    
        updateSection();
    }

    function mirrorNotes(?strum:Int = null){
        if(strum == null){strum = curStrum;}

        var secNotes:Array<Dynamic> = _song.sectionStrums[strum].notes[curSection].sectionNotes;
        var keyLength:Int = Song.getStrumKeys(_song.sectionStrums[strum], curSection);

        for(i in 0...secNotes.length){
            var curNote:NoteData = Note.getNoteData(secNotes[i]);
            curNote.keyData = keyLength - curNote.keyData - 1;
            secNotes[i] = Note.convNoteData(curNote);
        }

        _song.sectionStrums[strum].notes[curSection].sectionNotes = secNotes;

        updateSection();
    }

    function syncNotes(){
        var allSection:Array<Dynamic> = [];
        for(section in _song.sectionStrums){
            for(n in section.notes[curSection].sectionNotes){
                var hasNote:Bool = false;
                for(na in allSection){if(Note.compNotes(Note.getNoteData(na), Note.getNoteData(n))){hasNote = true; break;}}
                if(!hasNote){allSection.push(n);}
            }
        }
        
        for(section in _song.sectionStrums){section.notes[curSection].sectionNotes = allSection.copy();}

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
    var txtStage:FlxUIInputText;
    var txtStyle:FlxUIInputText;
    var txtAspect:FlxUIInputText;
    var txtCharacter:FlxUIInputText;
    var txtNoteStyle:FlxUIInputText;
    var stpPlayer:FlxUINumericStepper;
    var stpBPM:FlxUINumericStepper;
    var stpSpeed:FlxUINumericStepper;
    var stpStrum:FlxUINumericStepper;
    var stpCharX:FlxUINumericStepper;
    var stpCharY:FlxUINumericStepper;
    var stpCharSize:FlxUINumericStepper;
    var stpCharLayout:FlxUINumericStepper;
    var stpSecBPM:FlxUINumericStepper;
    var stpLength:FlxUINumericStepper;
    var stpSecStrum:FlxUINumericStepper;
    var stpKeys:FlxUINumericStepper;
    var stpLastSec:FlxUINumericStepper;
    var stpLastSec2:FlxUINumericStepper;
    var stpLastStrm:FlxUINumericStepper;
    var stpSwapSec:FlxUINumericStepper;
    var stpStrumLine:FlxUINumericStepper;
    var stpEventStrumLine:FlxUINumericStepper;
    var stpNoteLength:FlxUINumericStepper;
    var stpNoteHits:FlxUINumericStepper;
    var stpSrmKeys:FlxUINumericStepper;
    var stpHeightSize:FlxUINumericStepper;
    var chkALT:FlxUICheckBox;
    var chkKeys:FlxUICheckBox;
    var chkBPM:FlxUICheckBox;
    var chkLEFT:FlxUICheckBox;
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
    var ddlEvent1:FlxUIDropDownMenu;
    var lblCharsToSing:FlxText;
    var lblSecCharsToSing:FlxText;
    var lblNoteStyle:FlxText;
    var clEventListToNote:FlxUICustomList;
    var clNoteEventList:FlxUICustomList;
    var clNotePressets:FlxUICustomList;
    var clNoteCondFunc:FlxUICustomList;
    var clEventListToEvents:FlxUICustomList;
    var clEventListEvents:FlxUICustomList;
    var clCharacters:FlxUICustomList;
    var clNoteStyle:FlxUICustomList;
    var clStrumCharsToAdd:FlxUICustomList;
    var clSecStrumCharsToAdd:FlxUICustomList;
    var clGenFocusChar:FlxUICustomList;
    var btnCanMerge:FlxUIButton;
    var btnChangeEventFile:FlxUIButton;
    var btnBrokeExternalEvent:FlxUIButton;
    var note_event_sett_group:FlxUIGroup;
    var camera_note_event:FlxCamera;
    var event_sett_group:FlxUIGroup;
    var camera_event:FlxCamera;
    function addMENUTABS():Void{
        var tabMENU = new FlxUI(null, MENU);
        tabMENU.name = "4Song";

        var btnPlaySong:FlxButton = new FlxCustomButton(5, 10, Std.int(MENU.width - 10), null, "Play Song", null, null, function(){
            lastSection = curSection;
            SongListData.loadAndPlaySong(_song);
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

        var btnSaveSong:FlxButton = new FlxCustomButton(lblDiff.x, lblDiff.y + lblDiff.height + 5, Std.int((MENU.width / 2) - 10), null, "Save Song", null, null, function(){
            canAutoSave = false;
            canControlle = false;
            Song.save_song(Song.fileSong(_song.song,_song.category,_song.difficulty), _song, {path:Paths.chart(Song.fileSong(_song.song,_song.category,_song.difficulty)),
                onComplete: function(){
                    canAutoSave = true;
                    canControlle = true;

                    _saved.setPosition(FlxG.mouse.screenX - (_saved.width / 2),FlxG.mouse.screenY - (_saved.height / 2));
                    _saved.alpha = 1;
                    FlxTween.tween(_saved, {y: _saved.y - 10, alpha:0}, 1);

                    trace('Song Saved in [${Paths.chart(Song.fileSong(_song.song,_song.category,_song.difficulty))}]');
                }
            });
        }); tabMENU.add(btnSaveSong);
        var btnSaveSaveAs:FlxButton = new FlxCustomButton(btnSaveSong.x + btnSaveSong.width + 10, btnSaveSong.y, Std.int((MENU.width / 2) - 10), null, "Save Song As", null, null, function(){
            canAutoSave = false;
            canControlle = false;
            Song.save_song(Song.fileSong(_song.song,_song.category,_song.difficulty), _song, {saveAs: true, onComplete: function(){
                canAutoSave = true;
                canControlle = true;
            }});
        }); tabMENU.add(btnSaveSaveAs);

        var btnImport:FlxButton = new FlxCustomButton(5, btnSaveSong.y + btnSaveSong.height + 5, Std.int((MENU.width / 2) - 10), null, "Import Chart", null, null, function(){
                getFile(function(str){
                    var song_data:SwagSong = cast Song.convert_song(Song.fileSong(_song.song, _song.category, _song.difficulty), str.getText().trim());
                    Song.parseJSONshit(song_data);

                    _song = song_data;
                    
                    updateSection();
                });
        }); tabMENU.add(btnImport);

        var btnImportChart:FlxButton = new FlxCustomButton(btnImport.x + btnImport.width + 10, btnImport.y, Std.int((MENU.width / 2) - 10), null, "Import Events", null, null, function(){
            getFile(function(str){
                var event_data:SwagEvent = cast Song.convert_events(str.getText().trim());
                Song.parseJSONshit(_song, event_data);
                
                updateSection();
            });
        }); tabMENU.add(btnImportChart);

        var btnLoad:FlxButton = new FlxCustomButton(5, btnImport.y + btnImport.height + 5, Std.int((MENU.width) - 10), null, "Load Song", null, null, function(){loadSong(_song.song, _song.category, _song.difficulty);}); tabMENU.add(btnLoad);
               
        var line0 = new FlxSprite(5, btnLoad.y + btnLoad.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line0);

        var lblPlayer = new FlxText(5, line0.y + line0.height + 5, Std.int(MENU.width * 0.4), "Player: ", 8); tabMENU.add(lblPlayer);
        stpPlayer = new FlxUINumericStepper(lblPlayer.x + lblPlayer.width, lblPlayer.y, 1, _song.single_player, 0, 999); tabMENU.add(stpPlayer);
            @:privateAccess arrayFocus.push(cast stpPlayer.text_field);
            stpPlayer.name = "SONG_Player";

        var line2 = new FlxSprite(5, lblPlayer.y + lblPlayer.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line2);

        var lblStage = new FlxText(5, line2.y + 7, 0, "Stage: ", 8);  tabMENU.add(lblStage);
        txtStage = new FlxUIInputText(lblStage.x + lblStage.width + 5, lblStage.y, Std.int(MENU.width - lblStage.width - 15), _song.stage, 8); tabMENU.add(txtStage);
        arrayFocus.push(txtStage);
        txtStage.name = "SONG_STAGE";

        var lblStyle = new FlxText(5, lblStage.y + lblStage.height + 5, 0, "Style: ", 8);  tabMENU.add(lblStyle);
        txtStyle = new FlxUIInputText(lblStyle.x + lblStyle.width + 5, lblStyle.y, Std.int(MENU.width - lblStyle.width - 15), _song.uiStyle, 8); tabMENU.add(txtStyle);
        arrayFocus.push(txtStyle);
        txtStyle.name = "SONG_STYLE";

        var lblSpeed = new FlxText(5, lblStyle.y + lblStyle.height + 5, Std.int(MENU.width * 0.4), "Scroll Speed: ", 8); tabMENU.add(lblSpeed);
        stpSpeed = new FlxUINumericStepper(lblSpeed.x + lblSpeed.width, lblSpeed.y, 0.1, _song.speed, 0.1, 10, 1); tabMENU.add(stpSpeed);
            @:privateAccess arrayFocus.push(cast stpSpeed.text_field);
        stpSpeed.name = "SONG_Speed";
        
        var lblBPM = new FlxText(lblSpeed.x, stpSpeed.y + stpSpeed.height + 5, Std.int(MENU.width * 0.4), "BPM: ", 8); tabMENU.add(lblBPM);
        stpBPM = new FlxUINumericStepper(lblBPM.x + lblBPM.width, lblBPM.y, 1, _song.bpm, 5, 999); tabMENU.add(stpBPM);
            @:privateAccess arrayFocus.push(cast stpBPM.text_field);
        stpBPM.name = "SONG_BPM";

        chkHasVoices = new FlxUICheckBox(lblBPM.x, lblBPM.y + lblBPM.height + 5, null, null, "Song has Voices?", 100); tabMENU.add(chkHasVoices);
        chkHasVoices.checked = _song.hasVoices;

        var btnReload = new FlxUICustomButton(chkHasVoices.x + chkHasVoices.width + 5, chkHasVoices.y, Std.int((MENU.width / 2) - 8), null, "Reload Audio", null, null, function(){
            loadAudio(_song.song, _song.category);
        }); tabMENU.add(btnReload);

        var line3 = new FlxSprite(5, chkHasVoices.y + chkHasVoices.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line3);

        var lblCharacters = new FlxText(5, line3.y + line3.height + 3, Std.int(MENU.width - 10), "Characters", 8); tabMENU.add(lblCharacters);
        lblCharacters.alignment = CENTER;

        chkFocusChar = new FlxUICheckBox(lblCharacters.x, lblCharacters.y + lblCharacters.height + 3, null, null, "Focus Current Character", 300); tabMENU.add(chkFocusChar);

        clCharacters = new FlxUICustomList(chkFocusChar.x, chkFocusChar.y + chkFocusChar.height + 15, Std.int(MENU.width - 10), [], function(){selCharacter = clCharacters.getSelectedIndex(); updateValues();}, null); tabMENU.add(clCharacters);
        clCharacters.setPrefix("Character: < "); 

        var btnAddChar:FlxButton = new FlxCustomButton(clCharacters.x, clCharacters.y + clCharacters.height + 5, Std.int((MENU.width / 2) - 8), null, "Create Character", null, FlxColor.fromRGB(82, 255, 128), function(){_song.characters.push(["Boyfriend", [100, 100], 1, false, "Default", "NORMAL", 0]); updateStage(); updateValues();}); tabMENU.add(btnAddChar);
        btnAddChar.label.color = FlxColor.WHITE;

        var btnDelChar:FlxButton = new FlxCustomButton(btnAddChar.x + btnAddChar.width + 5, btnAddChar.y, Std.int((MENU.width / 2) - 8), null, "Delete Character", null, FlxColor.fromRGB(255, 94, 94), function(){_song.characters.remove(_song.characters[selCharacter]); updateStage(); updateValues();}); tabMENU.add(btnDelChar);
        btnDelChar.label.color = FlxColor.WHITE;

        var lblCharacter = new FlxText(btnAddChar.x, btnAddChar.y + btnAddChar.height + 5, 0, "Character Name:", 8); tabMENU.add(lblCharacter);
        txtCharacter = new FlxUIInputText(lblCharacter.x + lblCharacter.width + 5, lblCharacter.y, Std.int(MENU.width - lblCharacter.width - 15), "", 8); tabMENU.add(txtCharacter);
        arrayFocus.push(txtCharacter);
        txtCharacter.name = "CHARACTER_NAME";

        var lblAspect = new FlxText(lblCharacter.x, lblCharacter.y + lblCharacter.height + 5, 0, "Aspect:", 8); tabMENU.add(lblAspect);
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

        var chkAutoSave:FlxUICheckBox = new FlxUICheckBox(5, line4.y + line4.height + 5, null, null, "Enable AutoSave", Std.int((MENU.width - 15)), null, function(){}); tabMENU.add(chkAutoSave); chkAutoSave.checked = autSave;
        var btnLoadAutoSave:FlxButton = new FlxCustomButton(5, chkAutoSave.y + chkAutoSave.height + 5, Std.int((MENU.width - 15)), null, "Load Auto Save", null, null, function(){
            if(FlxG.save.data.autosave == null){return;}
            
            _song = FlxG.save.data.autosave;
            Song.parseJSONshit(_song);

            FlxG.switchState(new states.LoadingState(new ChartEditorState(this.onBack, this.onConfirm), [{type:"SONG",instance:_song}], false));
        }); tabMENU.add(btnLoadAutoSave);

        var line5 = new FlxSprite(5, btnLoadAutoSave.y + btnLoadAutoSave.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabMENU.add(line5);

        var btnClearSong:FlxButton = new FlxCustomButton(5, line5.y + line5.height + 5, Std.int((MENU.width - 15)), null, "Clear Song Notes", null, null, function(){for(i in _song.sectionStrums){for(ii in i.notes){ii.sectionNotes = [];}} updateSection();}); tabMENU.add(btnClearSong);

        var stpCSongStrm = new FlxUINumericStepper(btnClearSong.x, btnClearSong.y + btnClearSong.height + 8, 1, 0, 0, 999); tabMENU.add(stpCSongStrm);
            @:privateAccess arrayFocus.push(cast stpCSongStrm.text_field);
        stpCSongStrm.name = "Strums_Length";
        var btnClearSongStrum:FlxButton = new FlxCustomButton(stpCSongStrm.x + stpCSongStrm.width + 5, stpCSongStrm.y - 3, Std.int((MENU.width - 15) - stpCSongStrm.width), null, "Clear Song Strum Notes", null, null, function(){if(_song.sectionStrums[Std.int(stpCSongStrm.value)] != null){for(i in _song.sectionStrums[Std.int(stpCSongStrm.value)].notes){i.sectionNotes = [];}} updateSection();}); tabMENU.add(btnClearSongStrum);
        
        var btnClearSongEvents:FlxButton = new FlxCustomButton(5, stpCSongStrm.y + stpCSongStrm.height + 5, Std.int((MENU.width - 10)), null, "Clear Song Events", null, null, function(){for(i in _song.generalSection){i.events = [];} updateSection();}); tabMENU.add(btnClearSongEvents);


        MENU.addGroup(tabMENU);
        //

        var tabSTRUM = new FlxUI(null, MENU);
        tabSTRUM.name = "3Section/Strum";

        var lblStrum = new FlxText(5, 5, MENU.width - 10, "Current Strum"); tabSTRUM.add(lblStrum);
        lblStrum.alignment = CENTER;

        var btnStrmToBack:FlxButton = new FlxCustomButton(lblStrum.x, lblStrum.y + lblStrum.height + 5, Std.int((MENU.width / 2) - 8), null, "Send to Back", null, FlxColor.fromRGB(214, 212, 71), function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum - 1;
            if(index < 0){index = _song.sectionStrums.length - 1;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToBack);
        btnStrmToBack.label.color = FlxColor.WHITE;

        var btnStrmToFront:FlxButton = new FlxCustomButton(btnStrmToBack.x + btnStrmToBack.width + 5, btnStrmToBack.y, Std.int((MENU.width / 2) - 8), null, "Send to Front", null, FlxColor.fromRGB(214, 212, 71), function(){
            var strum = _song.sectionStrums[curStrum];

            var index = curStrum + 1;
            if(index >= _song.sectionStrums.length){index = 0;}

            _song.sectionStrums.remove(_song.sectionStrums[curStrum]);
            _song.sectionStrums.insert(index, strum);

            curStrum = index;
            updateSection();
        }); tabSTRUM.add(btnStrmToFront);
        btnStrmToFront.label.color = FlxColor.WHITE;

        var lblKeys = new FlxText(btnStrmToBack.x, btnStrmToBack.y + btnStrmToBack.height + 15, 0, "Strum Keys: ", 8); tabSTRUM.add(lblKeys);
        stpSrmKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpSrmKeys);
            @:privateAccess arrayFocus.push(cast stpSrmKeys.text_field);
        stpSrmKeys.name = "STRUM_KEYS";

        clNoteStyle = new FlxUICustomList(lblKeys.x , lblKeys.y + lblKeys.height + 5, Std.int(MENU.width) - 10, Note.getNoteStyles(), function(){
            if(_song.sectionStrums[curStrum] == null){return;}
            _song.sectionStrums[curStrum].noteStyle = clNoteStyle.getSelectedLabel();
            clNoteStyle.setSuffix(' [${clNoteStyle.getSelectedIndex() + 1}/${Note.getNoteStyles().length}]');
            updateSection(); reloadChartGrid(true);
        }); tabSTRUM.add(clNoteStyle);
        clNoteStyle.setPrefix('Note Style: '); clNoteStyle.setSuffix(' [${clNoteStyle.getSelectedIndex() + 1}/${Note.getNoteStyles().length}]');

        clStrumCharsToAdd = new FlxUICustomList(clNoteStyle.x , clNoteStyle.y + clNoteStyle.height + 5, Std.int(MENU.width / 2) - 10, [], function(){clStrumCharsToAdd.setSuffix(' [${clStrumCharsToAdd.getSelectedIndex() + 1}/${_song.characters.length}]');}); tabSTRUM.add(clStrumCharsToAdd);
        clStrumCharsToAdd.setSuffix(' [${clStrumCharsToAdd.getSelectedIndex() + 1}/${_song.characters.length}]');

        var btnAddCharToSing:FlxButton = new FlxCustomButton(clStrumCharsToAdd.x + clStrumCharsToAdd.width + 5, clStrumCharsToAdd.y, Std.int(MENU.width / 4) - 5, null, "Add Char", null, FlxColor.fromRGB(94, 255, 99), function(){
            if(clStrumCharsToAdd.list_length <= 0){return;}
            if(!_song.sectionStrums[curStrum].charToSing.contains(clStrumCharsToAdd.getSelectedIndex())){_song.sectionStrums[curStrum].charToSing.push(clStrumCharsToAdd.getSelectedIndex());} 
            updateValues();
        }); tabSTRUM.add(btnAddCharToSing);

        var btnDelCharToSing:FlxButton = new FlxCustomButton(btnAddCharToSing.x + btnAddCharToSing.width + 5, btnAddCharToSing.y, Std.int(MENU.width / 4) - 5, null, "Del Char", null, FlxColor.fromRGB(255, 94, 94), function(){
            if(clStrumCharsToAdd.list_length <= 0){return;}
            if(_song.sectionStrums[curStrum].charToSing.contains(clStrumCharsToAdd.getSelectedIndex())){_song.sectionStrums[curStrum].charToSing.remove(clStrumCharsToAdd.getSelectedIndex());}
            updateValues();
        }); tabSTRUM.add(btnDelCharToSing);

        lblCharsToSing = new FlxText(clStrumCharsToAdd.x, btnAddCharToSing.y + btnAddCharToSing.height + 5, Std.int(MENU.width - 10), "Characters to Sing:"); tabSTRUM.add(lblCharsToSing);

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
        stpLength = new FlxUINumericStepper(lblLength.x + lblLength.width, lblLength.y, 4, _song.generalSection[curSection].lengthInSteps, 4, 32, 0); tabSTRUM.add(stpLength);
            @:privateAccess arrayFocus.push(cast stpLength.text_field);
        stpLength.name = "GENERALSEC_LENGTH";

        var lblStrum = new FlxText(lblLength.x, lblLength.y + lblLength.height + 10, 0, "Strum to Focus: ", 8); tabSTRUM.add(lblStrum);
        stpSecStrum = new FlxUINumericStepper(lblStrum.x + lblStrum.width, lblStrum.y, 1, _song.generalSection[curSection].strumToFocus, 0, 999); tabSTRUM.add(stpSecStrum);
            @:privateAccess arrayFocus.push(cast stpSecStrum.text_field);
        stpSecStrum.name = "GENERALSEC_STRUMTOFOCUS";

        clGenFocusChar = new FlxUICustomList(stpSecStrum.x + stpSecStrum.width + 5, stpSecStrum.y, Std.int(MENU.width - lblStrum.width - stpSecStrum.width - 20), [], function(){_song.generalSection[curSection].charToFocus = clGenFocusChar.getSelectedIndex();}, null, _song.generalSection[curSection].charToFocus);  tabSTRUM.add(clGenFocusChar);

        var btnDelSecEvents:FlxButton = new FlxCustomButton(5, clGenFocusChar.y + clGenFocusChar.height + 5, Std.int((MENU.width) - 10), null, "Clear Events", null, FlxColor.fromRGB(255, 94, 94), function(){
            _song.generalSection[curSection].events = [];
            updateSection();
        }); tabSTRUM.add(btnDelSecEvents);
        btnDelSecEvents.label.color = FlxColor.WHITE;

        var btnDelAllSec:FlxButton = new FlxCustomButton(5, btnDelSecEvents.y + btnDelSecEvents.height + 5, Std.int((MENU.width) - 10), null, "Clear Section", null, FlxColor.fromRGB(255, 94, 94), function(){
            for(strum in _song.sectionStrums){strum.notes[curSection].sectionNotes = [];}
            updateSection();
        }); tabSTRUM.add(btnDelAllSec);
        btnDelAllSec.label.color = FlxColor.WHITE;
        
        var btnCopyAllSec:FlxButton = new FlxCustomButton(5, btnDelAllSec.y + btnDelAllSec.height + 5, Std.int((MENU.width / 3) - 10), null, "Copy Section", null, FlxColor.fromRGB(10, 25, 191), function(){
            copySection = [curSection, []];
            for(i in 0..._song.sectionStrums.length){
                copySection[1].push([]);
                for(n in _song.sectionStrums[i].notes[curSection].sectionNotes){
                    var curNote:NoteData = Note.getNoteData(n);
                    curNote.strumTime -= sectionStartTime();
                    copySection[1][i].push(Note.convNoteData(curNote));
                }
            }
        }); tabSTRUM.add(btnCopyAllSec);
        btnCopyAllSec.label.color = FlxColor.WHITE;

        var btnPasteAllSec:FlxButton = new FlxCustomButton(btnCopyAllSec.x + btnCopyAllSec.width + 5, btnCopyAllSec.y, Std.int((MENU.width / 3) - 6), null, "Paste Section", null, FlxColor.fromRGB(10, 25, 191), function(){
            for(i in 0..._song.sectionStrums.length){
                if(copySection[1][i] == null){continue;}

                var secNotes:Array<Dynamic> = copySection[1][i].copy();
                for(n in secNotes){
                    var curNote:NoteData = Note.getNoteData(n);
                    curNote.strumTime += sectionStartTime();

                    if(getSwagNote(Note.convNoteData(curNote), i) == null){_song.sectionStrums[i].notes[curSection].sectionNotes.push(Note.convNoteData(curNote));}
                }
            }
            updateSection();
        }); tabSTRUM.add(btnPasteAllSec);
        btnPasteAllSec.label.color = FlxColor.WHITE;

        var btnSetAllSec:FlxButton = new FlxCustomButton(btnPasteAllSec.x + btnPasteAllSec.width + 5, btnPasteAllSec.y, Std.int((MENU.width / 3) - 3), null, "Set Last Section", null, FlxColor.fromRGB(10, 25, 191), function(){
            stpLastSec.value = curSection - copySection[0];
            stpLastSec2.value = curSection - copySection[0];
        }); tabSTRUM.add(btnSetAllSec);
        btnSetAllSec.label.color = FlxColor.WHITE;

        var btnCopLastAllSec:FlxButton = new FlxCustomButton(5, btnCopyAllSec.y + btnCopyAllSec.height + 5, Std.int((MENU.width / 2) - 20), null, "Paste Last Section", null, FlxColor.fromRGB(10, 25, 191), function(){
            copyLastSection(Std.int(stpLastSec.value));
        }); tabSTRUM.add(btnCopLastAllSec);
        btnCopLastAllSec.label.color = FlxColor.WHITE;
        stpLastSec = new FlxUINumericStepper(btnCopLastAllSec.x + btnCopLastAllSec.width + 5, btnCopLastAllSec.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec);
            @:privateAccess arrayFocus.push(cast stpLastSec.text_field);

        var btnMirrorAll:FlxButton = new FlxCustomButton(5, btnCopLastAllSec.y + btnCopLastAllSec.height + 5, Std.int((MENU.width) - 10), null, "Mirror Section", null, FlxColor.fromRGB(214, 212, 71), function(){for(i in 0..._song.sectionStrums.length){mirrorNotes(i);}}); tabSTRUM.add(btnMirrorAll);
        btnMirrorAll.label.color = FlxColor.WHITE;

        var btnSync:FlxButton = new FlxCustomButton(5, btnMirrorAll.y + btnMirrorAll.height + 5, Std.int((MENU.width) - 10), null, "Synchronize Notes", null, FlxColor.fromRGB(214, 212, 71), function(){syncNotes();}); tabSTRUM.add(btnSync);
        btnSync.label.color = FlxColor.WHITE;

        var line2 = new FlxSprite(5, btnSync.y + btnSync.height + 5).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabSTRUM.add(line2);

        var lblStrumlSection = new FlxText(line2.x, line2.y + 5, MENU.width - 10, "Current Strum Section"); tabSTRUM.add(lblStrumlSection);
        lblStrumlSection.alignment = CENTER;

        chkALT = new FlxUICheckBox(5, lblStrumlSection.y + lblStrumlSection.height + 5, null, null, "Change ALT"); tabSTRUM.add(chkALT);
        chkALT.checked = _song.sectionStrums[curStrum].notes[curSection].altAnim;

        var lblKeys = new FlxText(5, chkALT.y + chkALT.height + 10, 0, "Strum Keys: ", 8); tabSTRUM.add(lblKeys);
        stpKeys = new FlxUINumericStepper(lblKeys.x + lblKeys.width, lblKeys.y, 1, _song.sectionStrums[curStrum].notes[curSection].keys, 1, 10); tabSTRUM.add(stpKeys);
            @:privateAccess arrayFocus.push(cast stpKeys.text_field);
        stpKeys.name = "STRUMSEC_KEYS";
        chkKeys = new FlxUICheckBox(stpKeys.x + stpKeys.width + 5, stpKeys.y - 1, null, null, "Change Keys"); tabSTRUM.add(chkKeys);
        chkKeys.checked = _song.sectionStrums[curStrum].notes[curSection].changeKeys;

        var btnDelStrSec:FlxButton = new FlxCustomButton(5, lblKeys.y + lblKeys.height + 5, Std.int((MENU.width) - 10), null, "Clear Strum Section", null, FlxColor.fromRGB(255, 94, 94), function(){
            _song.sectionStrums[curStrum].notes[curSection].sectionNotes = [];
            updateSection();
        }); tabSTRUM.add(btnDelStrSec);
        btnDelStrSec.label.color = FlxColor.WHITE;

        var btnCopLastStrum:FlxButton = new FlxCustomButton(5, btnDelStrSec.y + btnDelStrSec.height + 5, Std.int((MENU.width / 2) - 20), null, "Paste Last Strum", null, FlxColor.fromRGB(10, 25, 191), function(){
            copyLastStrum(Std.int(stpLastSec2.value), Std.int(stpLastStrm.value));
        }); tabSTRUM.add(btnCopLastStrum);
        btnCopLastStrum.label.color = FlxColor.WHITE;
        stpLastSec2 = new FlxUINumericStepper(btnCopLastStrum.x + btnCopLastStrum.width + 5, btnCopLastStrum.y + 3, 1, 0, -999, 999); tabSTRUM.add(stpLastSec2);
            @:privateAccess arrayFocus.push(cast stpLastSec2.text_field);
        stpLastStrm = new FlxUINumericStepper(stpLastSec2.x + stpLastSec2.width + 5, stpLastSec2.y, 1, 0, 0, 999); tabSTRUM.add(stpLastStrm);
            @:privateAccess arrayFocus.push(cast stpLastStrm.text_field);

        var btnSwapStrum:FlxButton = new FlxCustomButton(btnCopLastStrum.x, btnCopLastStrum.y + btnCopLastStrum.height + 5, Std.int((MENU.width / 2) - 3), null, "Swap Strum", null, FlxColor.fromRGB(69, 214, 173), function(){
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

        var btnMirror:FlxButton = new FlxCustomButton(btnSwapStrum.x, btnSwapStrum.y + btnSwapStrum.height + 5, Std.int((MENU.width) - 10), null, "Mirror Strum", null, FlxColor.fromRGB(214, 212, 71), function(){mirrorNotes();}); tabSTRUM.add(btnMirror);
        btnMirror.label.color = FlxColor.WHITE;

        chkSwitchChars = new FlxUICheckBox(5, btnMirror.y + btnMirror.height + 5, null, null, '\nChange Characters to Sing', 0); tabSTRUM.add(chkSwitchChars);

        clSecStrumCharsToAdd = new FlxUICustomList(chkSwitchChars.x , chkSwitchChars.y + chkSwitchChars.height + 5, Std.int(MENU.width / 2) - 10, [], function(){clSecStrumCharsToAdd.setSuffix(' [${clSecStrumCharsToAdd.getSelectedIndex() + 1}/${_song.characters.length}]');}); tabSTRUM.add(clSecStrumCharsToAdd);
        clSecStrumCharsToAdd.setSuffix(' [${clSecStrumCharsToAdd.getSelectedIndex() + 1}/${_song.characters.length}]');

        var btnSecAddCharToSing:FlxButton = new FlxCustomButton(clSecStrumCharsToAdd.x + clSecStrumCharsToAdd.width + 5, clSecStrumCharsToAdd.y, Std.int(MENU.width / 4) - 5, null, "Add Char", null, FlxColor.fromRGB(94, 255, 99), function(){
            if(clSecStrumCharsToAdd.list_length <= 0){return;}
            if(!_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(clSecStrumCharsToAdd.getSelectedIndex())){_song.sectionStrums[curStrum].notes[curSection].charToSing.push(clSecStrumCharsToAdd.getSelectedIndex());} 
            updateValues();
        }); tabSTRUM.add(btnSecAddCharToSing);

        var btnSecDelCharToSing:FlxButton = new FlxCustomButton(btnSecAddCharToSing.x + btnSecAddCharToSing.width + 5, btnSecAddCharToSing.y, Std.int(MENU.width / 4) - 5, null, "Del Char", null, FlxColor.fromRGB(255, 94, 94), function(){
            if(clSecStrumCharsToAdd.list_length <= 0){return;}
            if(_song.sectionStrums[curStrum].notes[curSection].charToSing.contains(clSecStrumCharsToAdd.getSelectedIndex())){_song.sectionStrums[curStrum].notes[curSection].charToSing.remove(clSecStrumCharsToAdd.getSelectedIndex());}
            updateValues();
        }); tabSTRUM.add(btnSecDelCharToSing);

        lblSecCharsToSing = new FlxText(clSecStrumCharsToAdd.x, btnSecAddCharToSing.y + btnSecAddCharToSing.height + 5, Std.int(MENU.width - 10), "Characters to Sing:"); tabSTRUM.add(lblSecCharsToSing);

        
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

        var lblNoteLength = new FlxText(lblStrumLine.x, lblStrumLine.y + lblStrumLine.height + 10, 0, "Note Length: ", 8); tabNOTE.add(lblNoteLength);
        stpNoteLength = new FlxUICustomNumericStepper(lblNoteLength.x + lblNoteLength.width, lblNoteLength.y, 120, (conductor.stepCrochet * 0.5), 0, 0, 999999, 2); tabNOTE.add(stpNoteLength);
            @:privateAccess arrayFocus.push(cast stpNoteLength.text_field);
        stpNoteLength.name = "NOTE_LENGTH";

        var lblNoteHits = new FlxText(lblNoteLength.x, lblNoteLength.y + lblNoteLength.height + 5, 0, "Note Hits: ", 8); tabNOTE.add(lblNoteHits);
        stpNoteHits = new FlxUINumericStepper(lblNoteHits.x + lblNoteHits.width, lblNoteHits.y, 1, 0, 0, 999); tabNOTE.add(stpNoteHits);
            @:privateAccess arrayFocus.push(cast stpNoteHits.text_field);
        stpNoteHits.name = "NOTE_HITS";
        
        btnCanMerge = new FlxUICustomButton(5, lblNoteHits.y + lblNoteHits.height + 5, Std.int(MENU.width - 10), null, "Is Slide", null, null, function(){
            updateSelectedNote(function(curNote){curNote.canMerge = !curNote.canMerge;});
        }); tabNOTE.add(btnCanMerge);

        clNotePressets = new FlxUICustomList(5, btnCanMerge.y + btnCanMerge.height + 5, Std.int(MENU.width - 10), Note.getNotePressets(), function(){
            updateSelectedNote(
                function(curNote){curNote.preset = clNotePressets.getSelectedLabel();},
                function(){selNote.preset = clNotePressets.getSelectedLabel();}
            );
            cursor_Arrow.loadPresset(selNote.preset, false);
        }); tabNOTE.add(clNotePressets);
        clNotePressets.setPrefix("Note Presset: ["); clNotePressets.setSuffix("]");
        
        clEventListToNote = new FlxUICustomList(clNotePressets.x, clNotePressets.y + clNotePressets.height + 15, Std.int(MENU.width - 35), Note.getNoteEvents(true)); tabNOTE.add(clEventListToNote);
        clEventListToNote.setPrefix("Event List: ["); clEventListToNote.setSuffix("]");

        var btnAddEventToNote = new FlxUICustomButton(clEventListToNote.x + clEventListToNote.width + 5, clEventListToNote.y, 20, null, "+", null, FlxColor.fromRGB(117, 255, 120), function(){
            updateSelectedNote(
                function(curNote){
                    this.pushTempScript(clEventListToNote.getSelectedLabel());
                    var default_list:Array<Dynamic> = [];
                    for(setting in cast(tempScripts.get(clEventListToNote.getSelectedLabel()).getVariable("defaultValues"),Array<Dynamic>)){default_list.push(setting.value);}
                    curNote.eventData.push([clEventListToNote.getSelectedLabel(), default_list, "OnHit"]);
                }
            );
            clNoteEventList.setIndex(selNote.eventData.length - 1);
        }); tabNOTE.add(btnAddEventToNote);
        
        clNoteEventList = new FlxUICustomList(clEventListToNote.x, clEventListToNote.y + clEventListToNote.height + 5, Std.int(MENU.width) - 35, [], function(){
            updateSelectedNote(
                function(curNote){                
                    clNoteEventList.setSuffix('] (${clNoteEventList.getSelectedIndex() + 1}/${curNote.eventData.length})');
                    clNoteCondFunc.setLabel(curNote.eventData[clNoteEventList.getSelectedIndex()][2]);
                    loadNoteEventSettings(clNoteEventList.getSelectedLabel());
                    //try{txtNoteEventValues.text = Json.stringify(curNote.eventData[clNoteEventList.getSelectedIndex()][1]);}catch(e){trace(e); txtNoteEventValues.text = "[]";}
                },
                function(){
                    clNoteEventList.setData([]);
                    clNoteEventList.setSuffix('] (0/0)');
                    loadNoteEventSettings();
                    //txtNoteEventValues.text = "[]";
                }, false
            );
        }); tabNOTE.add(clNoteEventList);
        clNoteEventList.setPrefix("Current Event: ["); clNoteEventList.setSuffix("]");
        
        var btnDelEventToNote = new FlxUICustomButton(clNoteEventList.x + clNoteEventList.width + 5, clNoteEventList.y, 20, null, "-", null, FlxColor.fromRGB(255, 56, 56), function(){
            updateSelectedNote(function(curNote){
                if(curNote.eventData.length <= 0){return;}
                curNote.eventData.remove(curNote.eventData[clNoteEventList.getSelectedIndex()]);
            });
            clNoteEventList.setIndex(selNote.eventData.length - 1);
        }); tabNOTE.add(btnDelEventToNote);

        clNoteCondFunc = new FlxUICustomList(5, clNoteEventList.y + clNoteEventList.height + 5, Std.int(MENU.width - 10), ["OnHit", "OnMiss", "OnCreate"], function(){
            updateSelectedNote(function(curNote){
                if(curNote.eventData.length <= 0){return;}
                curNote.eventData[clNoteEventList.getSelectedIndex()][2] = clNoteCondFunc.getSelectedLabel();
            }, false);
        }); tabNOTE.add(clNoteCondFunc);
        clNoteCondFunc.setPrefix("Condition ("); clNoteCondFunc.setSuffix(")");

        camera_note_event = new FlxCamera(5, Std.int(clNoteCondFunc.y + clNoteCondFunc.height + 5), Std.int(MENU.width - 10), 150); add(camera_note_event);

        note_event_sett_group = new FlxUIGroup(5, clNoteCondFunc.y + clNoteCondFunc.height + 5); tabNOTE.add(note_event_sett_group);
        note_event_sett_group.width = Std.int(MENU.width - 10);
        note_event_sett_group.cameras = [camera_note_event];

        var nLine1 = new FlxSprite(5, note_event_sett_group.y + 160).makeGraphic(Std.int(MENU.width - 10), 2, FlxColor.BLACK); tabNOTE.add(nLine1);
        
        var lblEvents = new FlxText(5, nLine1.y + 7, MENU.width - 10, "Event"); tabNOTE.add(lblEvents);
        lblEvents.alignment = CENTER;

        var lblEventStrumLine = new FlxText(lblEvents.x, lblEvents.y + lblEvents.height + 5, 0, "StrumTime: ", 8); tabNOTE.add(lblEventStrumLine);
        stpEventStrumLine = new FlxUICustomNumericStepper(lblEventStrumLine.x + lblEventStrumLine.width, lblEventStrumLine.y, 120, conductor.stepCrochet * 0.5, 0, 0, 999999, 2); tabNOTE.add(stpEventStrumLine);
            @:privateAccess arrayFocus.push(cast stpEventStrumLine.text_field);
        stpEventStrumLine.name = "EVENT_STRUMTIME";

        clEventListToEvents = new FlxUICustomList(lblEventStrumLine.x, lblEventStrumLine.y + lblEventStrumLine.height + 5, Std.int(MENU.width - 35), Note.getNoteEvents()); tabNOTE.add(clEventListToEvents);
        clEventListToEvents.setPrefix("Event List: ["); clEventListToEvents.setSuffix("]");

        var btnAddEventToEvents = new FlxUICustomButton(clEventListToEvents.x + clEventListToEvents.width + 5, clEventListToEvents.y, 20, null, "+", null, FlxColor.fromRGB(117, 255, 120), function(){
            updateSelectedEvent(
                function(curEvent){
                    this.pushTempScript(clEventListToEvents.getSelectedLabel());
                    var default_list:Array<Dynamic> = [];
                    for(setting in cast(tempScripts.get(clEventListToEvents.getSelectedLabel()).getVariable("defaultValues"),Array<Dynamic>)){default_list.push(setting.value);}
                    curEvent.eventData.push([clEventListToEvents.getSelectedLabel(), default_list]);
                }
            );
        }); tabNOTE.add(btnAddEventToEvents);
        
        clEventListEvents = new FlxUICustomList(clEventListToEvents.x, clEventListToEvents.y + clEventListToEvents.height + 5, Std.int(MENU.width) - 35, [], function(){
            updateSelectedEvent(
                function(curEvent){                
                    clEventListEvents.setSuffix('] (${clEventListEvents.getSelectedIndex() + 1}/${curEvent.eventData.length})');
                    //try{txtCurEventValues.text = Json.stringify(curEvent.eventData[clEventListEvents.getSelectedIndex()][1]);}catch(e){trace(e); txtCurEventValues.text = "";}
                    loadEventSettings(clEventListEvents.getSelectedLabel());
                },
                function(){
                    clEventListEvents.setData([]);
                    clEventListEvents.setSuffix('] (0/0)');
                    //txtCurEventValues.text = "[]";
                    loadEventSettings();
                }, false
            );
        }); tabNOTE.add(clEventListEvents);
        clEventListEvents.setPrefix("Current Event: ["); clEventListEvents.setSuffix("]");
        
        var btnDelEventToNote = new FlxUICustomButton(clEventListEvents.x + clEventListEvents.width + 5, clEventListEvents.y, 20, null, "-", null, FlxColor.fromRGB(255, 56, 56), function(){
            updateSelectedEvent(
                function(curEvent){
                    if(curEvent.eventData.length <= 0){return;}
                    curEvent.eventData.remove(curEvent.eventData[clEventListEvents.getSelectedIndex()]);
                }
            );
        }); tabNOTE.add(btnDelEventToNote);

        btnChangeEventFile = new FlxUICustomButton(5, clEventListEvents.y + clEventListEvents.height + 5, Std.int(MENU.width) - 120, null, 'Local Event', null, null, function(){
            updateSelectedEvent(function(curEvent){curEvent.isExternal = !curEvent.isExternal;});
        }); tabNOTE.add(btnChangeEventFile);

        btnBrokeExternalEvent = new FlxUICustomButton(btnChangeEventFile.x + btnChangeEventFile.width + 5, btnChangeEventFile.y, 100, null, 'Broke Ex Event', null, null, function(){
            updateSelectedEvent(function(curEvent){curEvent.isBroken = !curEvent.isBroken;});
        }); tabNOTE.add(btnBrokeExternalEvent);

        event_sett_group = new FlxUIGroup(5, btnChangeEventFile.y + btnChangeEventFile.height + 5); tabNOTE.add(event_sett_group);
        event_sett_group.width = Std.int(MENU.width - 10);

        MENU.addGroup(tabNOTE);
        //

        var tabSETTINGS = new FlxUI(null, MENU);
        tabSETTINGS.name = "1Settings";

        chkMuteInst = new FlxUICheckBox(5, 10, null, null, "Mute Instrumental", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteInst);

        chkMuteVoices = new FlxUICheckBox(5, chkMuteInst.y + chkMuteInst.height + 7, null, null, "Mute Voices", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteVoices);
        var btnEnVoices = new FlxUICustomButton(5, chkMuteVoices.y + chkMuteVoices.height + 5, Std.int(MENU.width / 3) - 8, null, "Enable Voices", null, FlxColor.fromRGB(117, 255, 120), function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = false;} reloadChartGrid(true);
        }); tabSETTINGS.add(btnEnVoices);
        var btnTgVoices = new FlxUICustomButton(btnEnVoices.x + btnEnVoices.width + 5, btnEnVoices.y, Std.int(MENU.width / 3) - 8, null, "Toggle Voices", null, null, function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = !sVoicesArray[i];} reloadChartGrid(true);
        }); tabSETTINGS.add(btnTgVoices);
        var btnDiVoices = new FlxUICustomButton(btnTgVoices.x + btnTgVoices.width + 5, btnTgVoices.y, Std.int(MENU.width / 3) - 8, null, "Disable Voices", null, FlxColor.fromRGB(255, 94, 94), function(){
            for(i in 0...sVoicesArray.length){sVoicesArray[i] = true;} reloadChartGrid(true);
        }); tabSETTINGS.add(btnDiVoices);

        
        chkMuteHitSounds = new FlxUICheckBox(5, btnEnVoices.y + btnEnVoices.height + 7, null, null, "Mute HitSounds", Std.int(MENU.width-10)); tabSETTINGS.add(chkMuteHitSounds);
        var btnEnHits = new FlxUICustomButton(5, chkMuteHitSounds.y + chkMuteHitSounds.height + 5, Std.int(MENU.width / 3) - 8, null, "Enable Hits", null, FlxColor.fromRGB(117, 255, 120), function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = true;} reloadChartGrid(true);
        }); tabSETTINGS.add(btnEnHits);
        var btnTgHits = new FlxUICustomButton(btnEnHits.x + btnEnHits.width + 5, btnEnHits.y, Std.int(MENU.width / 3) - 8, null, "Toggle Hits", null, null, function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = !sHitsArray[i];} reloadChartGrid(true);
        }); tabSETTINGS.add(btnTgHits);
        var btnDiHits = new FlxUICustomButton(btnTgHits.x + btnTgHits.width + 5, btnTgHits.y, Std.int(MENU.width / 3) - 8, null, "Disable Hits", null, FlxColor.fromRGB(255, 94, 94), function(){
            for(i in 0...sHitsArray.length){sHitsArray[i] = false;} reloadChartGrid(true);
        }); tabSETTINGS.add(btnDiHits);

        chkHideChart = new FlxUICheckBox(5, btnEnHits.y + btnEnHits.height + 10, null, null, "Hide Chart", 100); tabSETTINGS.add(chkHideChart);
        chkHideStrums = new FlxUICheckBox(5, chkHideChart.y + chkHideChart.height + 5, null, null, "Hide Strums", 100); tabSETTINGS.add(chkHideStrums);

        chkCamFocusStrum = new FlxUICheckBox(5, chkHideStrums.y + chkHideStrums.height + 10, null, null, "Cam Focus Strum when Playing", Std.int(MENU.width-10)); tabSETTINGS.add(chkCamFocusStrum);
                       
        chkDisableStrumButtons = new FlxUICheckBox(5, chkCamFocusStrum.y + chkCamFocusStrum.height + 5, null, null, "Disable [Add / Del] Strum Buttons"); tabSETTINGS.add(chkDisableStrumButtons);

        var lblHeightSize = new FlxText(5, chkDisableStrumButtons.y + chkDisableStrumButtons.height + 15, 0, "Height Size: "); tabSETTINGS.add(lblHeightSize);
        stpHeightSize = new FlxUINumericStepper(lblHeightSize.x + lblHeightSize.width + 5, lblHeightSize.y, 1, 1, 1, 5); tabSETTINGS.add(stpHeightSize);

        MENU.addGroup(tabSETTINGS);
        //

        MENU.scrollFactor.set();
        MENU.showTabId("4Song");
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>){
        if(id == FlxUICheckBox.CLICK_EVENT){
            var check:FlxUICheckBox = cast sender;
			var wname = check.getLabel().text;

            if(wname.startsWith("note_event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedNote(
                    function(curNote){
                        curNote.eventData[clNoteEventList.getSelectedIndex()][1][id] = check.checked;
                    }, null, false
                );

                return;
            }else if(wname.startsWith("event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedEvent(
                    function(curEvent){
                        curEvent.eventData[clEventListEvents.getSelectedIndex()][1][id] = check.checked;
                    }, null, false
                );

                return;
            }

			switch(wname){
                case "Hide Strums":{reloadChartGrid(true);}
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
                    if(_song.characters[selCharacter] != null){_song.characters[selCharacter][3] = check.checked;}
                    updateStage();
                }
                case "Change Chars":{
                    _song.sectionStrums[curStrum].notes[curSection].changeSing = check.checked;
                    updateSection();
                }
                case "Song has Voices?":{
                    inst.pause();
                    for(voice in voices.sounds){voice.pause();}
                    
                    _song.hasVoices = check.checked;
                    loadAudio(_song.song, _song.category);
                    reloadChartGrid(true);
                }
                case "Enable AutoSave":{
                    autSave = check.checked;
                    FlxG.save.data.autSave = autSave;
                    FlxG.save.flush();
                }
			}
		}else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)){
            var input:FlxUIInputText = cast sender;
            var wname = input.name;

            if(wname.startsWith("note_event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);
                var type:String = wname.split(":")[2];

                updateSelectedNote(
                    function(curNote){
                        switch(type){
                            case "string":{curNote.eventData[clNoteEventList.getSelectedIndex()][1][id] = input.text;}
                            case "array":{
                                var pString:String = '{ "Events": ${input.text} }';
                                var rString:Array<Dynamic> = [];
                                try{rString = (cast Json.parse(pString)).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}

                                curNote.eventData[clNoteEventList.getSelectedIndex()][1][id] = rString;
                            }
                        }
                    }, null, false
                );

                return;
            }else if(wname.startsWith("event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);
                var type:String = wname.split(":")[2];

                updateSelectedEvent(
                    function(curEvent){
                        switch(type){
                            case "string":{curEvent.eventData[clEventListEvents.getSelectedIndex()][1][id] = input.text;}
                            case "array":{
                                var pString:String = '{ "Events": ${input.text} }';
                                var rString:Array<Dynamic> = [];
                                try{rString = (cast Json.parse(pString)).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}

                                curEvent.eventData[clEventListEvents.getSelectedIndex()][1][id] = rString;
                            }
                        }
                    }, null, false
                );

                return;
            }

            switch(wname){
                case "SONG_NAME":{_song.song = Paths.getFileName(input.text, true);}
                case "SONG_CATEGORY":{_song.category = input.text;}
                case "SONG_DIFFICULTY":{_song.difficulty = input.text;}
                case "SONG_STYLE":{_song.uiStyle = input.text;}
                case "SONG_STAGE":{_song.stage = input.text; updateStage();}
                case "CHARACTER_NAME":{if(_song.characters[selCharacter] != null){_song.characters[selCharacter][0] = input.text;} updateStage(); updateValues();}
                case "CHARACTER_ASPECT":{if(_song.characters[selCharacter] != null){_song.characters[selCharacter][4] = input.text;} updateStage();}
                case "NOTE_EVENT":{
                    if(getSwagNote(Note.convNoteData(selNote)) == null){input.color = FlxColor.GRAY; return;}

                    var pString:String = '{ "Events": ${input.text} }';
                    var rString:Array<Dynamic> = [];
                    try{rString = (cast Json.parse(pString)).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}

                    updateSelectedNote(function(curNote){
                        if(curNote.eventData[clNoteEventList.getSelectedIndex()] == null){return;}
                        curNote.eventData[clNoteEventList.getSelectedIndex()][1] = rString;
                    }, false);
                }
                case "EVENTS_EVENT":{
                    if(getSwagEvent(Note.convEventData(selEvent)) == null){input.color = FlxColor.GRAY; return;}
                    
                    var pString:String = '{ "Events": ${input.text} }';
                    var rString:Array<Dynamic> = [];
                    try{rString = (cast Json.parse(pString)).Events; input.color = FlxColor.BLACK;}catch(e){trace(e); input.color = FlxColor.RED;}

                    updateSelectedEvent(function(curEvent){
                        if(curEvent.eventData[clEventListEvents.getSelectedIndex()] == null){return;}
                        curEvent.eventData[clEventListEvents.getSelectedIndex()][1] = rString;
                    }, false);
                }
            }
        }else if(id == FlxUIDropDownMenu.CLICK_EVENT && (sender is FlxUIDropDownMenu)){
            var drop:FlxUIDropDownMenu = cast sender;
            var wname = drop.name;
            switch(wname){
                case "CHARACTER_LIST":{
                    if(_song.characters[selCharacter] != null){
                        _song.characters[selCharacter][0] = drop.selectedLabel;
                    }

                    updateSection();
                }
            }
        }else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
            var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

            if(wname.startsWith("note_event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedNote(
                    function(curNote){
                        curNote.eventData[clNoteEventList.getSelectedIndex()][1][id] = nums.value;
                    }, null, false
                );

                return;
            }else if(wname.startsWith("event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedEvent(
                    function(curEvent){
                        curEvent.eventData[clEventListEvents.getSelectedIndex()][1][id] = nums.value;
                    }, null, false
                );

                return;
            }

            switch(wname){
                case "SONG_Player":{
                    if(nums.value < 0){nums.value = 0;}
                    if(nums.value >= _song.sectionStrums.length){nums.value = _song.sectionStrums.length - 1;}

                    _song.single_player = Std.int(nums.value);
                }
                case "CHARACTER_X":{
                    if(_song.characters[selCharacter] != null){_song.characters[selCharacter][1][0] = nums.value;}
                    updateStage();
                }
                case "CHARACTER_Y":{
                    if(_song.characters[selCharacter] != null){_song.characters[selCharacter][1][1] = nums.value;}
                    updateStage();
                }
                case "NOTE_STRUMTIME":{
                    updateSelectedNote(function(curNote){curNote.strumTime = nums.value;});
                }
                case "EVENT_STRUMTIME":{
                    updateSelectedEvent(function(curEvent){curEvent.strumTime = nums.value;});
                }
                case "NOTE_LENGTH":{
                    updateSelectedNote(function(curNote){
                        if(nums.value <= 0){curNote.multiHits = 0;}
                        curNote.sustainLength = nums.value;
                    });
                }
                case "SONG_Speed":{_song.speed = nums.value;}
                case "SONG_BPM":{
                    tempBpm = nums.value;
                    
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
                case "STRUMSEC_KEYS":{
                    _song.sectionStrums[curStrum].notes[curSection].keys = Std.int(nums.value);
                    updateSection();
                }
                case "NOTE_HITS":{
                    updateSelectedNote(function(curNote){
                        curNote.multiHits = Std.int(nums.value);
                        if(curNote.sustainLength <= 0 && curNote.multiHits >= 0){curNote.sustainLength = conductor.stepCrochet * 0.26;}
                    });
                }
                case "STRUM_KEYS":{
                    _song.sectionStrums[curStrum].keys = Std.int(nums.value);
                    updateSection();
                }
                case "CHARACTER_SIZE":{
                    if(_song.characters[selCharacter] != null){_song.characters[selCharacter][2] = nums.value;}
                    updateStage();
                }
                case "CHARACTER_LAYOUT":{
                    if(_song.characters[selCharacter] != null){_song.characters[selCharacter][6] = Std.int(nums.value);}
                    updateStage();
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
        }else if(id == FlxUICustomList.CHANGE_EVENT && (sender is FlxUICustomList)){
            var nums:FlxUICustomList = cast sender;
            var wname = nums.name;

            if(wname.startsWith("note_event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedNote(
                    function(curNote){
                        curNote.eventData[clNoteEventList.getSelectedIndex()][1][id] = nums.getSelectedLabel();
                    }, null, false
                );

                return;
            }else if(wname.startsWith("event_arg")){
                var id:Int = Std.parseInt(wname.split(":")[1]);

                updateSelectedEvent(
                    function(curEvent){
                        curEvent.eventData[clEventListEvents.getSelectedIndex()][1][id] = nums.getSelectedLabel();
                    }, null, false
                );

                return;
            }

            switch(wname){
                default:{}
            }
        }
    }

    var canAutoSave:Bool = true;
    private function autoSave():Void {
        if(!autSave || !canAutoSave){trace("Auto Save Disabled!"); return;}
        FlxG.save.data.autosave = _song;
		FlxG.save.flush();
        trace("Auto Saved!!!");
    }

    private function loadNoteEventSettings(?event:String):Void {
        note_event_sett_group.clear();   

        if(event == null){return;}
        
        this.pushTempScript(event);
        var setting_list:Array<Dynamic> = tempScripts.get(event).getVariable("defaultValues");

        var last_height:Float = 0;

        for(i in 0...setting_list.length){
            var setting:Dynamic = setting_list[i];
            var event_value:Dynamic = selNote.eventData[clNoteEventList.getSelectedIndex()][1][i];

            switch(setting.type){
                default:{
                    var chkCurrent_Variable = new FlxUICheckBox(0, last_height, null, null, setting.name);
                    chkCurrent_Variable.checked = event_value == "true";
                    chkCurrent_Variable.name = 'note_event_arg:${i}';
                    note_event_sett_group.add(chkCurrent_Variable);
                    last_height += chkCurrent_Variable.height + 5;
                }
                case 'Float':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); note_event_sett_group.add(lblArgName);
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), 0.1, Std.parseFloat(event_value), -999, 999, 3);
                    stpCurrent_Variable.name = 'note_event_arg:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    note_event_sett_group.add(stpCurrent_Variable);
                    last_height += lblArgName.height + 5;
                }
                case 'Int':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); note_event_sett_group.add(lblArgName);
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), 1, Std.parseFloat(event_value), -999, 999);
                    stpCurrent_Variable.name = 'note_event_arg:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    note_event_sett_group.add(stpCurrent_Variable);
                    last_height += lblArgName.height + 5;
                }
                case 'String':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); note_event_sett_group.add(lblArgName);
                    var data:String = ''; try{data = Json.stringify(event_value);}catch(e){trace(e); data = '""';}
                    var txtCurrent_Variable = new FlxUIInputText(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), Std.string(event_value), 8);
                    txtCurrent_Variable.name = 'note_event_arg:${i}:string';
                    arrayFocus.push(txtCurrent_Variable);
                    note_event_sett_group.add(txtCurrent_Variable); 
                    last_height += lblArgName.height + 5;
                }
                case 'Array':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); note_event_sett_group.add(lblArgName);
                    var data:String = ''; try{data = Json.stringify(Json.parse('{ "Events": ${event_value}}').Events);}catch(e){trace(e); data = '""';}
                    var txtCurrent_Variable = new FlxUIInputText(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), Std.string(event_value), 8);
                    txtCurrent_Variable.name = 'note_event_arg:${i}:array';
                    arrayFocus.push(txtCurrent_Variable);
                    note_event_sett_group.add(txtCurrent_Variable); 
                    last_height += lblArgName.height + 5;
                }
                case 'List':{
                    var clCurrent_Variable = new FlxUICustomList(0, last_height, Std.int(MENU.width) - 10, setting.list);
                    clCurrent_Variable.setPrefix('${setting.name}: ['); clCurrent_Variable.setSuffix(']');
                    clCurrent_Variable.name = 'note_event_arg:${i}';
                    clCurrent_Variable.setLabel(event_value,true);
                    note_event_sett_group.add(clCurrent_Variable); 
                    last_height += clCurrent_Variable.height + 5;
                }
            }
        }
    }

    private function loadEventSettings(?event:String):Void {
        event_sett_group.clear();   

        if(event == null){return;}
        
        this.pushTempScript(event);
        var setting_list:Array<Dynamic> = tempScripts.get(event).getVariable("defaultValues");

        var last_height:Float = 0;

        for(i in 0...setting_list.length){
            var setting:Dynamic = setting_list[i];
            var event_value:Dynamic = selEvent.eventData[clEventListEvents.getSelectedIndex()][1][i];

            switch(setting.type){
                default:{
                    var chkCurrent_Variable = new FlxUICheckBox(0, last_height, null, null, setting.name);
                    chkCurrent_Variable.checked = event_value == "true";
                    chkCurrent_Variable.name = 'event_arg:${i}';
                    event_sett_group.add(chkCurrent_Variable);
                    last_height += chkCurrent_Variable.height + 5;
                }
                case 'Float':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); event_sett_group.add(lblArgName);
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), 0.1, Std.parseFloat(event_value), -999, 999, 3);
                    stpCurrent_Variable.name = 'event_arg:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    event_sett_group.add(stpCurrent_Variable);
                    last_height += lblArgName.height + 5;
                }
                case 'Int':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); event_sett_group.add(lblArgName);
                    var stpCurrent_Variable = new FlxUICustomNumericStepper(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), 1, Std.parseFloat(event_value), -999, 999);
                    stpCurrent_Variable.name = 'event_arg:${i}';
                    @:privateAccess arrayFocus.push(cast stpCurrent_Variable.text_field);
                    event_sett_group.add(stpCurrent_Variable);
                    last_height += lblArgName.height + 5;
                }
                case 'String':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); event_sett_group.add(lblArgName);
                    var data:String = ''; try{data = Json.stringify(event_value);}catch(e){trace(e); data = '""';}
                    var txtCurrent_Variable = new FlxUIInputText(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), Std.string(event_value), 8);
                    txtCurrent_Variable.name = 'event_arg:${i}:string';
                    arrayFocus.push(txtCurrent_Variable);
                    event_sett_group.add(txtCurrent_Variable); 
                    last_height += lblArgName.height + 5;
                }
                case 'Array':{
                    var lblArgName = new FlxText(0, last_height, 0, '${setting.name}: '); event_sett_group.add(lblArgName);
                    var data:String = ''; try{data = Json.stringify(Json.parse('{ "Events": ${event_value}}').Events);}catch(e){trace(e); data = '""';}
                    var txtCurrent_Variable = new FlxUIInputText(lblArgName.width, last_height, Std.int(MENU.width - lblArgName.width - 10), Std.string(event_value), 8);
                    txtCurrent_Variable.name = 'event_arg:${i}:array';
                    arrayFocus.push(txtCurrent_Variable);
                    event_sett_group.add(txtCurrent_Variable); 
                    last_height += lblArgName.height + 5;
                }
                case 'List':{
                    var clCurrent_Variable = new FlxUICustomList(0, last_height, Std.int(MENU.width) - 10, setting.list);
                    clCurrent_Variable.setPrefix('${setting.name}: ['); clCurrent_Variable.setSuffix(']');
                    clCurrent_Variable.name = 'event_arg:${i}';
                    clCurrent_Variable.setLabel(event_value,true);
                    event_sett_group.add(clCurrent_Variable); 
                    last_height += clCurrent_Variable.height + 5;
                }
            }
        }
    }
}