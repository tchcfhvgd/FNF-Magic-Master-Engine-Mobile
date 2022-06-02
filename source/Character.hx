package;

import haxe.macro.Expr.Catch;
import Song.SwagSong;
import Section.SwagGeneralSection;
import Song.SwagStrum;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef CharacterFile = {
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
		try{
			if(SONG.sectionStrums[SONG.generalSection[cSection].strumToFocus].notes[cSection].changeSing){
				return SONG.sectionStrums[SONG.generalSection[cSection].strumToFocus].notes[cSection].charToSing[SONG.generalSection[cSection].charToFocus];
			}else{
				return SONG.sectionStrums[SONG.generalSection[cSection].strumToFocus].charToSing[SONG.generalSection[cSection].charToFocus];
			}
		}catch(e){
			return 0;
		}
	}
	public static var cDefault:String = 'Boyfriend';

	public var charFile:CharacterFile;

	public var curCharacter:String = cDefault;
	public var curSkin:String = "Default";
	public var curCategory:String = "Default";
	public var curType:String = "Normal";
	public var curLayer:Int = 0;

	public var holdTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var dancedIdle:Bool = false;

	public var onRight = true;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var imageFile:String = '';
	public var noAntialiasing:Bool = false;

	//Movement Stuff
	public var canMove:Bool = false;
	private var isMoving:Bool = false;
	private var movementStuff:Map<String, Dynamic>  = [
		
	];

	public var controls:Controls;

	public static function getCharacters():Array<String>{
		var charArray:Array<String> = [];

        #if windows
            for(i in FileSystem.readDirectory(FileSystem.absolutePath('assets/characters'))){
                var aChar:String = i.replace("_"," ");
                charArray.push(aChar);
            }
        #else
			charArray = [
                "Boyfriend",
				"Boyfriend Militar",
				"Boyfriend Pixel",
				"Cuddles",
				"Daddy Dearest",
				"Fliqpy",
				"Fliqpy Kpow",
				"Girlfriend",
				"Girlfriend Invisible",
				"Girlfriend Pixel",
				"Lumpy",
				"RussellLammy",
				"Sniffles",
				"Toothy"
            ];
        #end

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

	override function update(elapsed:Float){
		if(animation.curAnim != null){
			if(holdTimer > 0){
				holdTimer -= elapsed;
			}else{
				holdTimer = 0;
			}

			if(specialAnim && animation.curAnim.finished){
				specialAnim = false;
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null){
				playAnim(false, animation.curAnim.name + '-loop');
			}
		}


		if(canMove){keyShit();}
		super.update(elapsed);
	}

	private function keyShit() {
		if(controls != null){
			if(controls.checkAction("Game_Left", PRESSED)){this.x -= 5;}
			if(controls.checkAction("Game_Right", PRESSED)){this.x += 5;}
			if(controls.checkAction("Game_Up", PRESSED)){this.y -= 5;}
			if(controls.checkAction("Game_Down", PRESSED)){this.y += 5;}
		}
	}

	public function setupByCharacterFile(?jCharacter:CharacterFile){
		if(jCharacter == null){jCharacter = Json.parse(Paths.getText(Paths.getCharacterJSON(curCharacter, curCategory, curSkin)));}
		charFile = jCharacter;

		positionArray = charFile.position;
		cameraPosition = charFile.camera;

		healthIcon = charFile.healthicon;
		
		this.flipX = !charFile.onRight;
		this.onRight = true;

		this.dancedIdle = charFile.danceIdle;

		this.antialiasing = !charFile.nAntialiasing;

		imageFile = charFile.image;
		animationsArray = charFile.anims;

		setCharacterGraphic();

		dance();
	}

	public function dance(){
		if(!specialAnim){
			if(dancedIdle){
				if(animation.curAnim != null && animation.curAnim.name == 'danceRight'){
					playAnim(false, 'danceLeft');
				}else{
					playAnim(false, 'danceRight');
				}
			}else{
				playAnim(false, 'idle');
			}
		}
	}

	public function playAnim(special:Bool = false, AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void{
		if(!specialAnim && animation.getByName(AnimName) != null){
			
			specialAnim = special;
			animation.play(AnimName, Force, Reversed, Frame);
		}
	}

	public function quickAnimAdd(name:String, anim:String){
		animation.addByPrefix(name, anim, 24, false);
	}

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
			for (anim in animationsArray) {
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
}
