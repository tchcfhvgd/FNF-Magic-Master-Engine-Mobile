package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxBaseAnimation;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import haxe.macro.Expr.Catch;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
import Song.SwagSection;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;
import haxe.Json;


import Song.SwagSong;
import Song.SwagStrum;
import Song.SwagGeneralSection;

import states.MusicBeatState;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef CharacterFile = {
	var name:String;
	var skin:String;
	var aspect:String;

	var deathCharacter:String;
	var image:String;
	var healthicon:String;

	var position:Array<Float>;
	var camera:Array<Float>;

	var onRight:Bool;
	var nAntialiasing:Bool;

	var danceIdle:Bool;

	var anims:Array<AnimArray>;
}

typedef AnimArray = {
	var anim:String;
	var symbol:String;
	var fps:Int;

	var indices:Array<Int>;

	var loop:Bool;
}

class Character extends FlxSprite{
	public static function getSkin(character:String):String {
		return "Default";
	}

	public static function getFocusCharID(song:SwagSong, section:Int, ?strum:Int):Int{
		var strum_list = song.sectionStrums;
		var focused_strum = strum != null ? strum : song.generalSection[section].strumToFocus;
		var focused_character = song.generalSection[section].charToFocus;

		if(strum_list == null || strum_list[focused_strum] == null){return 0;}
		if(strum_list[focused_strum].notes[section].changeSing){return strum_list[focused_strum].notes[section].charToSing[focused_character];}
		return strum_list[focused_strum].charToSing[focused_character];
	}

	public static function setCameraToCharacter(char:Character, cam:FlxObject){
		if(char == null){return;}

		var camMoveX = char.getMidpoint().x;
		var camMoveY = char.getMidpoint().y;
					
		camMoveX += char.cameraPosition[0];
		camMoveY += char.cameraPosition[1];
                
        if(char.animation.curAnim != null){
            switch(char.animation.curAnim.name){
                case 'singUP':{camMoveY -= 100;}
                case 'singRIGHT':{camMoveX += !char.onRight ? 100 : -100;}
                case 'singDOWN':{camMoveY += 100;}
                case 'singLEFT':{camMoveX -= !char.onRight ? 100 : -100;}
            }
        }

        cam.setPosition(camMoveX, camMoveY);
	}

	public static var cDefault:String = 'Boyfriend';

	public var charFile:CharacterFile;

	public var dieCharacter:String = null;
	public var curCharacter:String = cDefault;
	public var curSkin:String = "Default";
	public var curCategory:String = "Default";
	public var curType:String = "Normal";
	public var curLayer:Int = 0;

	public var singTimer:Int = 1;
	public var holdTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var dancedIdle:Bool = false;
	public var forceBeat:Bool = false;

	public var onRight = true;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var imageFile:String = '';
	public var noAntialiasing:Bool = false;

	public var onDebug:Bool = false;

	public static function getCharacters():Array<String>{
		var charArray = []; 
		for(i in Paths.readDirectory('assets/characters')){charArray.push(i);}

        return charArray;
	}

	public function new(x:Float, y:Float, ?character:String = 'Boyfriend', ?category:String = 'Default', ?type:String = "NORMAL"){
		super(x, y);

		curCharacter = character;

		curSkin = Character.getSkin(curCharacter);
		curCategory = category;
		curType = type;

		switch(curCharacter){
			default:{setupByCharacterFile();}
		}
		
	}

	var oldBeat:Int = -1;
	override function update(elapsed:Float){
		if(animation.curAnim != null && !onDebug){
			if(holdTimer > 0){holdTimer -= elapsed;}else{
				specialAnim = false;

				if(MusicBeatState.state.curBeat != oldBeat){oldBeat = MusicBeatState.state.curBeat; dance();}
			}
			
			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null){playAnim(animation.curAnim.name + '-loop');}
		}
		
		super.update(elapsed);
	}
	
	public function dance(){
		if(specialAnim){return;}
		if(dancedIdle){
			if(animation.curAnim != null && animation.curAnim.name == 'danceRight'){playAnim('danceLeft');}
			else{playAnim('danceRight');}
			holdTimer = 0;
		}else{playAnim('idle');}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Special:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void{
		if(this.flipX){
			if(AnimName.contains("LEFT")){AnimName = AnimName.replace("LEFT", "RIGHT");}
			else{AnimName = AnimName.replace("RIGHT", "LEFT");}
		}
		
		if(specialAnim || animation.getByName(AnimName) == null || (animation.curAnim != null && animation.curAnim.name == AnimName && animation.curAnim.name.contains("sing") && animation.curAnim.curFrame < singTimer)){return;}
		
		specialAnim = Special;
		animation.play(AnimName, Force, Reversed, Frame);
		holdTimer = ((animation.getByName(AnimName).frames.length - Frame) / animation.getByName(AnimName).frameRate);
	}

	public function setupByName(?_character:String, ?_category:String, ?_type:String):Void {
		if(_character != null){curCharacter = _character;}
		if(_category != null){curSkin = _category;}
		if(_type != null){curCategory = _type;}
		setupByCharacterFile();
	}

	public function setupByCharacterFile(?jCharacter:CharacterFile){
		if(jCharacter == null){jCharacter = cast Paths.getCharacterJSON(curCharacter, curSkin, curCategory);}
		charFile = jCharacter;

		curCharacter = charFile.name;
		curSkin = charFile.skin;
		curCategory = charFile.aspect;

		healthIcon = charFile.healthicon;
		
		turnLook(onRight);

		this.dancedIdle = charFile.danceIdle;

		this.antialiasing = !charFile.nAntialiasing;

		this.dieCharacter = charFile.deathCharacter;
		imageFile = charFile.image;
		animationsArray = charFile.anims;
		
		if(charFile.position != null){positionArray = charFile.position;}else{positionArray = [0,0];}
		if(charFile.camera != null){cameraPosition = charFile.camera;}else{cameraPosition = [0,0];}

		setCharacterGraphic();

		dance();
	}

	public function quickAnimAdd(name:String, anim:String){animation.addByPrefix(name, anim, 24, false);}

	public function turnLook(toRight:Bool = true){
		this.onRight = toRight;

		if(onRight){
			this.flipX = !charFile.onRight;
		}else{
			this.flipX = charFile.onRight;
		}
	}

	public function setCharacterGraphic(?IMAGE:String){
		if(IMAGE != null){imageFile = IMAGE;}

		frames = Paths.getAtlas(Paths.character(curCharacter, imageFile));
		if(animationsArray != null && animationsArray.length > 0) {
			for(anim in animationsArray){
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.symbol;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}else{
					animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
			}
		}else{
			quickAnimAdd('idle', 'BF idle dance');
		}
	}

	override public function isOnScreen(?Camera:FlxCamera):Bool{return true;}
}
