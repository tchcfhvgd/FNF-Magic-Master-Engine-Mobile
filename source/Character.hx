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
	var zoom:Float;

	var onRight:Bool;
	var singDuration:Float;
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

	public var curCharacter:String = cDefault;
	public var curType:String = "Normal";
	public var curSkin:String = "Default";
	public var curCategory:String = "Default";

	public var holdTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var dancedIdle:Bool = false;

	public var onRight = true;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var cameraZoom:Float = 0.8;

	public var imageFile:String = '';
	public var noAntialiasing:Bool = false;

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

	public function new(x:Float, y:Float, ?character:String = 'Boyfriend', ?category:String = 'Default', ?type:String = "NORMAL", ?toRight:Bool = true, ?nScale:Int = 1){
		super(x, y);

		antialiasing = true;

		curCharacter = character;

		curSkin = Character.getSkin(curCharacter);
		curCategory = category;
		curType = type;

		trace('Character: ' + curCharacter);
		trace('Type: ' + curType);
		trace('Category: ' + curCategory);
		trace('Skin: ' + curSkin);

		switch(curCharacter){
			//case 'your character name in case you want to hardcode him instead':

			default:{
				var path:String = Paths.getCharacterJSON(curCharacter, curCategory, curSkin);

				var rawJson = Assets.getText(path);
				var jCharacter:CharacterFile = cast Json.parse(rawJson);
				
				imageFile = jCharacter.image;
				trace('Image: ' + imageFile);
				trace('Icon: ' + jCharacter.healthicon);

				frames = Paths.getCharacterAtlas(curCharacter, imageFile);

				positionArray = jCharacter.position;
				cameraPosition = jCharacter.camera;
				cameraZoom = jCharacter.zoom;

				healthIcon = jCharacter.healthicon;
				//singDuration = jCharacter.singDuration;
				if(jCharacter.nAntialiasing){
					antialiasing = false;
					noAntialiasing = true;
				}

				this.scale.set(nScale, nScale);

				this.onRight = jCharacter.onRight;
				this.dancedIdle = jCharacter.danceIdle;

				this.antialiasing = !noAntialiasing;

				animationsArray = jCharacter.anims;
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
				dance();
			}
		}

		turnLook(toRight);
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
		super.update(elapsed);
	}

	/**
	 * FOR GF DANCING SHIT
	 */
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
}
