package;

import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagGeneralSection;
import Section.SwagSection;
import StrumLineNote;
import StrumLineNote.Note;
import Song;
import Song.SwagSong;
import Song.SwagStrum;
import SpriteInput;
import SpriteInput.TextButtom;
import SpriteUIMENU.SpriteUIMENU_TAB;
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

class ChartEditorState extends MusicBeatState{
    public static var _song:SwagSong;
    var backStage:Stage;

    var curStrum:Int = 0;
    var curSection:Int = 0;
    public static var lastSection:Int = 0;
    var curSelectedNote:Array<Dynamic>;

    var strumLine:FlxSprite;

    var dArrow:Note;
    var curStrumJSON:StrumLineNoteJSON;

    var backGrid:FlxSprite;
    var stuffGroup:FlxTypedGroup<Dynamic>;
    var gridGroup:FlxTypedGroup<FlxSprite>;
    var curGrid:FlxSprite;

    var renderedNotes:FlxTypedGroup<Note>;
    private var lastNote:Note;

    //Cameras
    var camGENERAL:FlxCamera;
    var camBACK:FlxCamera;
    var camSTRUM:FlxCamera;
	var camHUD:FlxCamera;

    var genFollow:FlxObject;
    var backFollow:FlxObject;
    //-------
    
    var mPoint:FlxPoint;

    var voices:FlxSoundGroup;

    var KEYSIZE:Int = 60;

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
		camBACK.bgColor.alpha = 0;
		camSTRUM = new FlxCamera();
		camSTRUM.bgColor.alpha = 0;
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGENERAL);
		FlxG.cameras.add(camBACK);
        FlxG.cameras.add(camSTRUM);
        FlxG.cameras.add(camHUD);

        camBACK.zoom = 0.5;

        backFollow = new FlxObject(0, 0, 1, 1);
        backFollow.screenCenter();
		camBACK.follow(backFollow, LOCKON, 0.3);

        genFollow = new FlxObject(0, 0, 1, 1);
        FlxG.camera.target = genFollow;
        camSTRUM.target = FlxG.camera.target;        
        
        backStage = new Stage(_song.stage, _song.characters);
        backStage.cameras = [camBACK];
        add(backStage);

        backGrid = new FlxSprite(-1, 0).makeGraphic(0, FlxG.height, FlxColor.BLACK);
        backGrid.scrollFactor.set(1, 0);
        backGrid.alpha = 0.5;
        backGrid.cameras = [camSTRUM];
        add(backGrid);

        gridGroup = new FlxTypedGroup<FlxSprite>();
        add(gridGroup);

        stuffGroup = new FlxTypedGroup<Dynamic>();
        add(stuffGroup);

        renderedNotes = new FlxTypedGroup<Note>();
        add(renderedNotes);

        stuffGroup.cameras = [camSTRUM];
        gridGroup.cameras = [camSTRUM];
        renderedNotes.cameras = [camSTRUM];

        mPoint = new FlxPoint(0, 0);
        
        loadStrumJSON();
        dArrow = new Note(curStrumJSON.gameplayNotes[0], "Default", 0, 0);
        dArrow.setGraphicSize(KEYSIZE);
        dArrow.antialiasing = PreSettings.getPreSetting("Antialiasing");
        dArrow.cameras = [camSTRUM];
        dArrow.onEdit = true;
        add(dArrow);

        strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
        strumLine.cameras = [camSTRUM];
		//strumLine.visible = false;
		add(strumLine);

        addSections();
        updateSection();

        var gridBLine = new FlxSprite(-1, 0).makeGraphic(2, Std.int(curGrid.height), FlxColor.BLACK);
		add(gridBLine);
        gridBLine.cameras = [camSTRUM];

        voices = new FlxSoundGroup();
        loadSong(_song.song, _song.category);
        Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
    }

    override function update(elapsed:Float){
        if(FlxG.sound.music.time < 0){FlxG.sound.music.time = 0;}

        curStep = recalculateSteps();
        Conductor.songPosition = FlxG.sound.music.time;

        strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps));
        mPoint = FlxG.mouse.getPositionInCameraView(camGENERAL);

        if(curStep >= (16 * (curSection + 1))){
            if(_song.generalSection[curSection + 1] == null){addSections();}
            changeSection(curSection + 1, false);
        }
        if(curStep < (16 * curSection) && curSection > 0){
            changeSection(curSection - 1, false);       
        }
    
        FlxG.watch.addQuick('daBeat', curBeat);
        FlxG.watch.addQuick('daStep', curStep);

        if(!FlxG.sound.music.playing && (FlxG.mouse.x > curGrid.x && FlxG.mouse.x < curGrid.x + curGrid.width
		&& FlxG.mouse.y > curGrid.y && FlxG.mouse.y < curGrid.y + curGrid.height)){
            dArrow.alpha = 0.5;
			dArrow.x = Math.floor(FlxG.mouse.x / KEYSIZE) * KEYSIZE - 47;
			if(FlxG.keys.pressed.SHIFT){
                dArrow.y = FlxG.mouse.y - 47;
            }else{
                dArrow.y = Math.floor(FlxG.mouse.y / (KEYSIZE / 2)) * (KEYSIZE / 2) - 47;
            }

            var data:Int = (Math.floor(FlxG.mouse.x / KEYSIZE)) % (getStrumKeys(curStrum));
            dArrow.loadGraphicNote(data, curStrumJSON.gameplayNotes[data], "Default");

            if(FlxG.mouse.justPressed){addNote();}
		}else{
            dArrow.alpha = 0;
        }

        if(FlxG.sound.music.playing){
            backGrid.alpha = 0.3;
            curGrid.alpha = 0.5;

            if(_song.generalSection[curSection] != null){
                var char = backStage.getCharacterById(_song.generalSection[curSection].charToFocus);
    
                backFollow.setPosition(char.getMidpoint().x, char.getMidpoint().y);
            }
        }else{
            backGrid.alpha = 0.5;
            curGrid.alpha = 1;

            if(_song.sectionStrums[curStrum].notes[curSection] != null){
                var char = backStage.getCharacterById(_song.sectionStrums[curStrum].charToSing[0]);
                if(_song.sectionStrums[curStrum].notes[curSection].changeSing){
                    char = backStage.getCharacterById(_song.sectionStrums[curStrum].notes[curSection].charToSing[0]);
                }
    
                backFollow.setPosition(char.getMidpoint().x, char.getMidpoint().y);
            }
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
        }

        if(FlxG.keys.anyJustPressed([UP, DOWN, W, S]) || FlxG.mouse.wheel != 0){
            FlxG.sound.music.pause();
            for(voice in voices.sounds){voice.pause();}
        }

        if(!FlxG.keys.pressed.SHIFT){
            if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.5);}

            if(FlxG.keys.anyPressed([UP, W])){
                var daTime:Float = Conductor.stepCrochet * 0.1;
                FlxG.sound.music.time -= daTime;
            }
            if(FlxG.keys.anyPressed([DOWN, S])){
                var daTime:Float = Conductor.stepCrochet * 0.1;
                FlxG.sound.music.time += daTime;
            }

            if(FlxG.keys.justPressed.R){resetSection();}

            if(FlxG.keys.anyJustPressed([LEFT, A])){changeSection(curSection - 1);}
            if(FlxG.keys.anyJustPressed([RIGHT, D])){changeSection(curSection + 1);}
        }else{
            if(FlxG.mouse.wheel != 0){FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 1);}

            if(FlxG.keys.anyPressed([UP, W])){
                var daTime:Float = Conductor.stepCrochet * 0.05;
                FlxG.sound.music.time -= daTime;
            }
            if(FlxG.keys.anyPressed([DOWN, S])){
                var daTime:Float = Conductor.stepCrochet * 0.05;
                FlxG.sound.music.time += daTime;
            }

            if(FlxG.keys.justPressed.R){resetSection(true);}

            if(FlxG.keys.anyJustPressed([LEFT, A])){
                curStrum--;
                updateSection();
            }
            if(FlxG.keys.anyJustPressed([RIGHT, D])){
                curStrum++;
                updateSection();
            }
        }

        if(FlxG.mouse.justPressedRight){
            gridGroup.forEach(function(grid:FlxSprite){
                if(FlxG.mouse.overlaps(grid)){
                    curStrum = grid.ID;
                    updateSection();
                }
            });
        }

        strumLine.x = curGrid.x;
        genFollow.setPosition(FlxMath.lerp(genFollow.x, curGrid.x + (curGrid.width / 2), 0.50), strumLine.y);
        super.update(elapsed);
    }

    override function beatHit(){
        trace('beat');
    
        super.beatHit();
    }

    function updateSection(){
        if(curStrum >= _song.sectionStrums.length){curStrum = _song.sectionStrums.length - 1;}
        if(curStrum < 0){curStrum = 0;}

        stuffGroup.clear();
        gridGroup.clear();

        var lastWidth:Float = 0;
        for(i in 0..._song.sectionStrums.length){
            var newGrid = FlxGridOverlay.create(KEYSIZE, KEYSIZE, KEYSIZE * getStrumKeys(i), KEYSIZE * (_song.generalSection[curSection].lengthInSteps));
            newGrid.alpha = 0.5;
            newGrid.x += lastWidth;
            newGrid.ID = i;
            gridGroup.add(newGrid);

            lastWidth += newGrid.width;

            var newGridBLine = new FlxSprite(lastWidth - 1, 0).makeGraphic(2, Std.int(newGrid.height), FlxColor.BLACK);
		    stuffGroup.add(newGridBLine);
        }

        if(backGrid.width != Std.int(lastWidth)){backGrid.makeGraphic(Std.int(lastWidth + 2), FlxG.height, FlxColor.BLACK);}

        curGrid = gridGroup.members[curStrum];

        if(strumLine.width != Std.int(curGrid.width)){strumLine.makeGraphic(Std.int(curGrid.width), 4);}

        while(renderedNotes.members.length > 0){renderedNotes.remove(renderedNotes.members[0], true);}

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

        for(ii in 0..._song.sectionStrums.length){
            var sectionInfo:Array<Dynamic> = _song.sectionStrums[ii].notes[curSection].sectionNotes;
            for (i in sectionInfo){
                var daStrumTime:Float = i[0];
                var daNoteData:Int = Std.int(i[1] % getStrumKeys(ii));
                var daLength:Float = i[2];
                var daHits:Int = i[3];
                var daSpecial:Int = i[4];
                var daOther:Array<NoteData> = i[5];

                var daJSON:StrumLineNoteJSON = cast Json.parse(Assets.getText(Paths.strumline(getStrumKeys(ii))));
        
                var note:Note = new Note(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[ii].noteStyle, daStrumTime, daNoteData, daLength, daHits, daSpecial, daOther);
                note.onEdit = true;
                note.setGraphicSize(KEYSIZE, KEYSIZE);
                note.updateHitbox();
                note.x = gridGroup.members[ii].x + Math.floor(daNoteData * KEYSIZE);
                note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps)));
        
                if(curSelectedNote != null){
                    if(curSelectedNote[0] == note.strumTime){
                        lastNote = note;
                    }
                }                        
        
                renderedNotes.add(note);

                if(daLength > 0){
                    if(daHits > 0){
                        var totalHits:Int = daHits;
                        var hits:Int = daHits;
                        var curHits:Int = 1;
                        note.noteHits = 0;
                        daHits = 0;
    
                        while(hits > 0){
                            var newStrumTime = daStrumTime + (daLength * curHits);
    
                            var hitNote:Note = new Note(daJSON.gameplayNotes[daNoteData], _song.sectionStrums[ii].noteStyle, newStrumTime, daNoteData, 0, curHits, daSpecial, daOther);
                            hitNote.onEdit = true;
                            hitNote.setGraphicSize(KEYSIZE, KEYSIZE);
                            hitNote.updateHitbox();
                            hitNote.x = gridGroup.members[ii].x + Math.floor(daNoteData * KEYSIZE);
                            hitNote.y = Math.floor(getYfromStrum((newStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.generalSection[curSection].lengthInSteps)));
    
                            hitNote.alpha = hits * 0.8 / totalHits;

                            renderedNotes.add(hitNote);
    
                            hits--;
                            curHits++;
                        }
                    }else{

                    }
                }
            }
        }
    }

    function loadSong(daSong:String, cat:String):Void{
		if(FlxG.sound.music != null){FlxG.sound.music.stop();}

		FlxG.sound.playMusic(Paths.inst(daSong, cat), 0.6);

        voices.sounds = [];
        for(i in 0..._song.voices.length){
            var voice = new FlxSound().loadEmbedded(Paths.voice(i, _song.voices[i], daSong, cat));
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

    function loadStrumJSON():Void{
        curStrumJSON = cast Json.parse(Assets.getText(Paths.strumline(getStrumKeys(curStrum))));
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

    private function addSections(lengthInSteps:Int = 16):Void{
        var genSec:SwagGeneralSection = {
            bpm: _song.bpm,
            changeBPM: false,
    
            lengthInSteps: lengthInSteps,
    
            strumToFocus: 0,
            charToFocus: 0
        };

        _song.generalSection.push(genSec);
        
        for(i in 0..._song.sectionStrums.length){
            addSection(i, lengthInSteps, getStrumKeys(i));
        }
    }

    private function addSection(strumm:Int = 0, lengthInSteps:Int = 16, keys:Int = 4):Void{
        var sec:SwagSection = {
            charToSing: [0],
            changeSing: false,
    
            keys: keys,
            changeKeys: false,
    
            altAnim: false,
    
            sectionNotes: []
        };

        _song.sectionStrums[strumm].notes.push(sec);
    }

    private function addNote(?n:Note):Void{
        var noteStrum = getStrumTime(dArrow.y) + sectionStartTime();
        var noteData = Math.floor(FlxG.mouse.x / KEYSIZE);
        var noteLength = 0;
        var noteHits = 0;
        var specialData = 0;
        var otherData = [];

        if(n != null){
            _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.noteLength, n.noteHits, n.specialData, n.otherData]);
        }else{
            _song.sectionStrums[curStrum].notes[curSection].sectionNotes.push([noteStrum, noteData, noteLength, noteHits, specialData, otherData]);
        }

        var thingy = _song.sectionStrums[curStrum].notes[curSection].sectionNotes[_song.sectionStrums[curStrum].notes[curSection].sectionNotes.length - 1];
        curSelectedNote = thingy;
    
        updateSection();
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
        var toReturn = _song.sectionStrums[strum].keys;

        if(_song.sectionStrums[strum].notes[curSection].changeKeys){toReturn = _song.sectionStrums[strum].notes[curSection].keys;}

        return toReturn;
    }
}