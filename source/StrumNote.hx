package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite{
    public static var daPixelZoom:Float = 6;
    var styleUiCheck = 'Normal';

	private var noteData:Int = 0;
    private var specialData:Int = 0;
    private var typeCheck:String = 'NORMAL';
    private var confirmOffset:Array<Float> = [-13, -13];

	public function new(x:Float, y:Float, leData:Int, noteTypeCheck:String, ?leSData:Int = 0){
		noteData = leData;
        specialData = leSData;
        typeCheck = noteTypeCheck;
        super(x, y);

        if(PlayState.SONG.ui_Style != null){
			styleUiCheck = PlayState.SONG.ui_Style;
		}

        loadGraphicStrum(noteData, typeCheck, specialData);
	}

	override function update(elapsed:Float) {

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false){
		animation.play(anim, force);
		centerOffsets();

		if(animation.curAnim.name == 'confirm'){
            offset.add(confirmOffset[0], confirmOffset[1]);
        }
	}

    public function loadGraphicStrum(leData:Int, noteTypeCheck:String, ?leSData:Int = 0){
        switch (noteTypeCheck){
			case 'PIXEL':{
                loadGraphic(Paths.image('style_UI/PIXEL/' + styleUiCheck + '/arrows-pixels', 'shared'), true, 17, 17);

                animation.add('green', [6]);
				animation.add('red', [7]);
				animation.add('blue', [5]);
				animation.add('purplel', [4]);

				setGraphicSize(Std.int(width * daPixelZoom));
				updateHitbox();
				antialiasing = false;
                
                switch (Math.abs(noteData)){
					case 2:{
						animation.add('static', [2]);
						animation.add('pressed', [6, 10], 12, false);
						animation.add('confirm', [14, 18], 12, false);
                    }						
					case 3:{
						animation.add('static', [3]);
						animation.add('pressed', [7, 11], 12, false);
						animation.add('confirm', [15, 19], 24, false);
                    }						
					case 1:{
						animation.add('static', [1]);
						animation.add('pressed', [5, 9], 12, false);
						animation.add('confirm', [13, 17], 24, false);
                    }
					case 0:{
						animation.add('static', [0]);
						animation.add('pressed', [4, 8], 12, false);
						animation.add('confirm', [12, 16], 24, false);
                    }
				}

                confirmOffset = [0, 0];
            }	
			default:{
                switch(leSData){
                    case 2:{
                        frames = Paths.getSparrowAtlas('style_UI/NORMAL/Blood_NOTE_ASSETS', 'shared');
                        animation.addByPrefix('green', 'arrowUP');
                        animation.addByPrefix('blue', 'arrowDOWN');
                        animation.addByPrefix('purple', 'arrowLEFT');
                        animation.addByPrefix('red', 'arrowRIGHT');
                
                        antialiasing = true;
                        setGraphicSize(Std.int(width * 0.7));
                
                        switch (Math.abs(noteData)){
                            case 0:{
                                animation.addByPrefix('static', 'arrowLEFT');
                                animation.addByPrefix('pressed', 'left press', 24, false);
                                animation.addByPrefix('confirm', 'left confirm', 24, false);
                            }
                            case 1:{
                                animation.addByPrefix('static', 'arrowDOWN');
                                animation.addByPrefix('pressed', 'down press', 24, false);
                                animation.addByPrefix('confirm', 'down confirm', 24, false);
                            }
                            case 2:{
                                animation.addByPrefix('static', 'arrowUP');
                                animation.addByPrefix('pressed', 'up press', 24, false);
                                animation.addByPrefix('confirm', 'up confirm', 24, false);
                            }
                            case 3:{
                                animation.addByPrefix('static', 'arrowRIGHT');
                                animation.addByPrefix('pressed', 'right press', 24, false);
                                animation.addByPrefix('confirm', 'right confirm', 24, false);
                            }
                        }
                    }
                    default:{
                        frames = Paths.getSparrowAtlas('style_UI/NORMAL/' + styleUiCheck + '/NOTE_assets', 'shared');
                        animation.addByPrefix('green', 'arrowUP');
                        animation.addByPrefix('blue', 'arrowDOWN');
                        animation.addByPrefix('purple', 'arrowLEFT');
                        animation.addByPrefix('red', 'arrowRIGHT');
                
                        antialiasing = true;
                        setGraphicSize(Std.int(width * 0.7));
                
                        switch (Math.abs(noteData)){
                            case 0:{
                                animation.addByPrefix('static', 'arrowLEFT');
                                animation.addByPrefix('pressed', 'left press', 24, false);
                                animation.addByPrefix('confirm', 'left confirm', 24, false);
                            }
                            case 1:{
                                animation.addByPrefix('static', 'arrowDOWN');
                                animation.addByPrefix('pressed', 'down press', 24, false);
                                animation.addByPrefix('confirm', 'down confirm', 24, false);
                            }
                            case 2:{
                                animation.addByPrefix('static', 'arrowUP');
                                animation.addByPrefix('pressed', 'up press', 24, false);
                                animation.addByPrefix('confirm', 'up confirm', 24, false);
                            }
                            case 3:{
                                animation.addByPrefix('static', 'arrowRIGHT');
                                animation.addByPrefix('pressed', 'right press', 24, false);
                                animation.addByPrefix('confirm', 'right confirm', 24, false);
                            }
                        }
                    }
                }
            }
		}

        updateHitbox();
		scrollFactor.set();
    }
}
