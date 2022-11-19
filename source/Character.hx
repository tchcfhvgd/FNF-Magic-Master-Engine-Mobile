package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxBaseAnimation;
import flixel.group.FlxSpriteGroup;
import haxe.format.JsonParser;
import flixel.tweens.FlxTween;
import haxe.macro.Expr.Catch;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
import openfl.utils.Assets;
import Song.SwagSection;
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

	var script_path:String;

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

class Character extends FlxSpriteGroup{
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

		var camMoveX = char.character_sprite.getMidpoint().x;
		var camMoveY = char.character_sprite.getMidpoint().y;
					
		camMoveX += char.cameraPosition[0];
		camMoveY += char.cameraPosition[1];
                
        if(char.character_sprite.animation.curAnim != null){
            switch(char.character_sprite.animation.curAnim.name){
                case 'singUP':{camMoveY -= 100;}
                case 'singRIGHT':{camMoveX += !char.onRight ? 100 : -100;}
                case 'singDOWN':{camMoveY += 100;}
                case 'singLEFT':{camMoveX -= !char.onRight ? 100 : -100;}
            }
        }

        cam.setPosition(camMoveX, camMoveY);
	}
	
	public static function getCharacters():Array<String>{
		var charArray = []; 
		for(i in Paths.readDirectory('assets/characters')){charArray.push(i);}

        return charArray;
	}

	public static var DEFAULT_CHARACTER:String = 'Boyfriend';
	
	public var character_sprite:FlxSprite;

	public var charFile:CharacterFile;
	public var charScript:Script;

	public var dieCharacter:String = null;
	public var curCharacter:String = DEFAULT_CHARACTER;
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
	
	public function setupByName(?_character:String, ?_category:String, ?_type:String):Void {
		if(_character != null){curCharacter = _character;}
		if(_category != null){curSkin = _category;}
		if(_type != null){curCategory = _type;}
		setupByCharacterFile();
	}

	public function setupByCharacterFile(?jCharacter:CharacterFile){
		var char_path:String = Paths.getCharacterJSON(curCharacter, curSkin, curCategory);
		if(jCharacter == null){jCharacter = cast Json.parse(Paths.getText(char_path));}
		charFile = jCharacter;

		curCharacter = charFile.name;
		curSkin = charFile.skin;
		curCategory = charFile.aspect;

		healthIcon = charFile.healthicon;

		this.dancedIdle = charFile.danceIdle;

		this.antialiasing = !charFile.nAntialiasing;

		this.dieCharacter = charFile.deathCharacter;
		imageFile = charFile.image;
		animationsArray = charFile.anims;
		
		if(charFile.position != null){positionArray = charFile.position;}else{positionArray = [0,0];}
		if(charFile.camera != null){cameraPosition = charFile.camera;}else{cameraPosition = [0,0];}

		if(charScript != null){charScript.destroy(); charScript = null;}
		var char_script_path:String = char_path.replace('.json', '.hx');
		if(Paths.exists(char_script_path)){
			charScript = new Script();
			charScript.setVariable("instance", this);
			charScript.exScript(Paths.getText(char_script_path));
		}
		
		setCharacterGraphic();
		turnLook(onRight);

		dance();
	}

	public function setCharacterGraphic(?IMAGE:String){
		if(IMAGE != null){imageFile = IMAGE;}
		
		this.clear();

		character_sprite = new FlxSprite(positionArray[0], positionArray[1]);

		character_sprite.frames = Paths.getAtlas(Paths.character(curCharacter, imageFile));
		if(animationsArray != null && animationsArray.length > 0) {
			for(anim in animationsArray){
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.symbol;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					character_sprite.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}else{
					character_sprite.animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
			}
		}

		if(charScript != null){charScript.exFunction('load_before_char');}

		this.add(character_sprite);
		
		if(charScript != null){charScript.exFunction('load_after_char');}
	}

	var oldBeat:Int = -1;
	override function update(elapsed:Float){
		if(character_sprite.animation.curAnim != null && !onDebug){
			if(holdTimer > 0){holdTimer -= elapsed;}else{
				specialAnim = false;

				if(MusicBeatState.state.curBeat != oldBeat){oldBeat = MusicBeatState.state.curBeat; dance();}
			}
			
			if(character_sprite.animation.curAnim.finished && character_sprite.animation.getByName(character_sprite.animation.curAnim.name + '-loop') != null){playAnim(animation.curAnim.name + '-loop');}
		}
		
		super.update(elapsed);

		if(charScript != null){charScript.exFunction('update', [elapsed]);}
	}
	
	public function dance(){
		if(dancedIdle){
			if(character_sprite.animation.curAnim != null && character_sprite.animation.curAnim.name == 'danceRight'){playAnim('danceLeft');}
			else{playAnim('danceRight');}
			holdTimer = 0;
		}else{playAnim('idle');}

		if(charScript != null){charScript.exFunction('dance');}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Special:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void{
		if(character_sprite.flipX){
			if(AnimName.contains("LEFT")){AnimName = AnimName.replace("LEFT", "RIGHT");}
			else{AnimName = AnimName.replace("RIGHT", "LEFT");}
		}
		
		if(specialAnim || character_sprite.animation.getByName(AnimName) == null || (character_sprite.animation.curAnim != null && character_sprite.animation.curAnim.name == AnimName && character_sprite.animation.curAnim.name.contains("sing") && character_sprite.animation.curAnim.curFrame < singTimer)){return;}
		
		specialAnim = Special;
		character_sprite.animation.play(AnimName, Force, Reversed, Frame);
		holdTimer = ((character_sprite.animation.getByName(AnimName).frames.length - Frame) / character_sprite.animation.getByName(AnimName).frameRate);
		
		if(charScript != null){charScript.exFunction('playAnim');}
	}

	public function turnLook(toRight:Bool = true){
		onRight = toRight;
		character_sprite.flipX = onRight ? !charFile.onRight : charFile.onRight;
		if(charScript != null){charScript.exFunction('turnLook',[toRight]);}
	}

	override public function isOnScreen(?Camera:FlxCamera):Bool{return true;}
}