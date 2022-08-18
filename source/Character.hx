package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxBaseAnimation;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import haxe.macro.Expr.Catch;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
import Section.SwagSection;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;
import haxe.Json;


import Song.SwagSong;
import Song.SwagStrum;
import Section.SwagGeneralSection;

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

	public static function getFocusCharID(SONG:SwagSong, cSection:Int):Int{
		var sStrums = SONG.sectionStrums;
		var focusStrum = SONG.generalSection[cSection].strumToFocus;
		var gChar = SONG.generalSection[cSection].charToFocus;

		if(sStrums == null || sStrums[focusStrum] == null){return 0;}
		if(sStrums[focusStrum].notes[cSection].changeSing){return sStrums[focusStrum].notes[cSection].charToSing[gChar];}
		return sStrums[focusStrum].charToSing[gChar];
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
                case 'singRIGHT':{camMoveX += 100;}
                case 'singDOWN':{camMoveY += 100;}
                case 'singLEFT':{camMoveX -= 100;}
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

		antialiasing = true;

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
		if(this.onRight){
			if(AnimName.contains("LEFT")){AnimName = AnimName.replace("LEFT", "RIGHT");}
			else{AnimName = AnimName.replace("RIGHT", "LEFT");}
		}
		if(specialAnim || animation.getByName(AnimName) == null || (animation.curAnim != null && animation.curAnim.name == AnimName && animation.curAnim.name.contains("sing") && animation.curAnim.curFrame < singTimer)){return;}
		
		specialAnim = Special;
		animation.play(AnimName, Force, Reversed, Frame);
		holdTimer = ((animation.getByName(AnimName).frames.length - Frame) / animation.getByName(AnimName).frameRate);
	}

	public function setupByCharacterFile(?jCharacter:CharacterFile){
		if(jCharacter == null){jCharacter = Json.parse(Paths.getText(Paths.getCharacterJSON(curCharacter, curSkin, curCategory)));}
		charFile = jCharacter;

		curCharacter = charFile.name;
		curSkin = charFile.skin;
		curCategory = charFile.aspect;

		healthIcon = charFile.healthicon;
		
		this.flipX = !charFile.onRight;
		this.onRight = true;

		this.dancedIdle = charFile.danceIdle;

		this.antialiasing = !charFile.nAntialiasing;

		this.dieCharacter = charFile.deathCharacter;
		imageFile = charFile.image;
		animationsArray = charFile.anims;
		
		if(charFile.position != null){positionArray = charFile.position;}
		if(charFile.camera != null){cameraPosition = charFile.camera;}

		setCharacterGraphic();

		dance();
	}

	public function quickAnimAdd(name:String, anim:String){animation.addByPrefix(name, anim, 24, false);}

	public function turnLook(toRight:Bool = true){
		if((toRight && !this.onRight) || (!toRight && this.onRight)){
			this.flipX = !this.flipX;
			this.onRight = !this.onRight;
		}
	}

	public function setCharacterGraphic(?IMAGE:String){
		if(IMAGE != null){imageFile = IMAGE;}

		frames = Paths.getCharacterAtlas(curCharacter, imageFile);
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
