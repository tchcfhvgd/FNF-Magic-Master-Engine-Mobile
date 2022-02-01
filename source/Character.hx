package;

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

import ListStuff;

using StringTools;

typedef CharacterFile = {
	var image:String;
	var healthicon:String;

	var position:Array<Float>;
	var cameraRight:Array<Float>;
	var cameraLeft:Array<Float>;

	var xFlip:Bool;
	var scale:Float;
	var singDuration:Float;
	var nAntialiasing:Bool;

	var anims:Array<AnimArray>;
}

typedef AnimArray = {
	var anim:String;
	var symbol:String;
	var fps:Int;

	var offsets_right:Array<Float>;
	var offsets_left:Array<Float>;
	var indices:Array<Int>;

	var loop:Bool;		
}

class Character extends FlxSprite{
	public static var cDefault:String = 'Boyfriend';

	public var curCharacter:String = cDefault;
	public var curType:String = "Normal";
	public var curSkin:String = "Default";
	public var curCategory:String = "Default";

	public var holdTimer:Float = 0;
	public var specialAnim:Bool = false;

	public var isRight:Bool = false;
	
	public var singDuration:Float = 4;
	public var danceIdle:Bool = false;

	public var originalFlipX:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'Boyfriend', ?category:String = 'Default', ?type:String = "NORMAL", ?isRight:Bool = false){
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end

		this.isRight = isRight;
		antialiasing = true;

		curCharacter = character;

		curSkin = ListStuff.Skins.getSkin(curCharacter);
		curCategory = category;
		curType = type;

		trace('Character: ' + curCharacter);
		trace('Type: ' + curType);
		trace('Category: ' + curCategory);
		trace('Skin: ' + curSkin);

		switch(curCharacter){
			//case 'your character name in case you want to hardcode him instead':

			default:{
				var characterPath:String = Characters.getSkinPath(curCharacter + "-"  + curSkin + "-" + curCategory, curCharacter);

				var path:String = characterPath;
				if (!Assets.exists(path)){
					curCharacter = cDefault;

					curSkin = ListStuff.Skins.getSkin(curCharacter);
					path = Characters.getSkinPath(curCharacter + "-"  + curSkin + "-" + curCategory, curCharacter); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				var rawJson = Assets.getText(path);
				var jCharacter:CharacterFile = cast Json.parse(rawJson);
				
				imageFile = jCharacter.image;
				trace('Image: ' + imageFile);
				trace('Icon: ' + jCharacter.healthicon);

				var stuffPath = Characters.getStuffPath(jCharacter.image, curCharacter);
				var spritePath = Characters.getSpritePath(jCharacter.image, curCharacter);

				trace('Stuff Path: ' + stuffPath);
				trace('Sprite Path: ' + spritePath);

				frames = Characters.getAtlas(spritePath, stuffPath);

				if(jCharacter.scale != 1) {
					jsonScale = jCharacter.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = jCharacter.position;
				cameraPosition = jCharacter.cameraLeft;

				healthIcon = jCharacter.healthicon;
				singDuration = jCharacter.singDuration;
				if(jCharacter.nAntialiasing){
					antialiasing = false;
					noAntialiasing = true;
				}

				flipX = jCharacter.xFlip;
				originalFlipX = flipX;
				if(this.isRight){
					flipX = !flipX;
					cameraPosition = jCharacter.cameraRight;
				}

				antialiasing = !noAntialiasing;

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

						if(this.isRight){
							if(anim.offsets_right != null && anim.offsets_right.length > 1) {
								addOffset(anim.anim, anim.offsets_right[0], anim.offsets_right[1]);
							}
						}else{
							if(anim.offsets_left != null && anim.offsets_left.length > 1) {
								addOffset(anim.anim, anim.offsets_left[0], anim.offsets_left[1]);
							}
						}
					}
				}else{
					quickAnimAdd('idle', 'BF idle dance');
				}

				recalculateDanceIdle();
				dance();
			}
		}
	}

	override function update(elapsed:Float){
		if(!debugMode && animation.curAnim != null){
			if(holdTimer > 0){
				holdTimer -= elapsed;
			}else{
				holdTimer = 0;
				dance();
			}

			if(specialAnim && animation.curAnim.finished){
				specialAnim = false;
				dance();
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null){
				playAnim(false, animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim(false, 'danceRight');
				else
					playAnim(false, 'danceLeft');
			}
			else if(animation.getByName('idle') != null) {
					playAnim(false, 'idle');
			}
		}
	}

	public function playAnim(special:Bool = false, AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void{
		if(!specialAnim && animation.getByName(AnimName) != null){
			specialAnim = special;
			animation.play(AnimName, Force, Reversed, Frame);
	
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName)){
				offset.set(daOffset[0], daOffset[1]);
			}
			else{
				offset.set(0, 0);
			}
	
			if (curCharacter.startsWith('gf')){
				if (AnimName == 'singLEFT'){
					danced = true;
				}else if(AnimName == 'singRIGHT'){
					danced = false;
				}
	
				if(AnimName == 'singUP' || AnimName == 'singDOWN'){
					danced = !danced;
				}
			}
		}
	}

	public function recalculateDanceIdle() {
		danceIdle = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String){
		animation.addByPrefix(name, anim, 24, false);
	}

	public function setGraphicScale(scale:Float){
		setGraphicSize(Std.int(width * (scale * jsonScale / 1)));
		updateHitbox();
	}
}
