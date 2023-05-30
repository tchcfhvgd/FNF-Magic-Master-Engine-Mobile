package;

import Song.SwagGeneralSection;
import Song.SwagSection;
import Song.SwagSong;
import Song.SwagStrum;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Expr.Catch;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import states.MusicBeatState;

using StringTools;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

typedef CharacterFile = {
	var name:String;
	var skin:String;
	var aspect:String;

	var deathCharacter:String;
	var image:String;
	var healthicon:String;

	var script_path:String;

	var onRight:Bool;
	var antialiasing:Bool;
	var danceIdle:Bool;

	var scale:Float;

	var position:Array<Float>;
	var camera:Array<Float>;
	var anims:Array<AnimArray>;
}

typedef AnimArray = {
	var anim:String;
	var symbol:String;
	var fps:Int;

	var indices:Array<Int>;
	var loop:Bool;
}

class Skins {
	private static var skin_manager:Map<String, Dynamic> = [];

	public static function init():Void {
		skin_manager.clear();

		var character_list:Array<String> = Character.getCharacters();

		for(char in character_list){
			var current_skin_char = {
				current_skin: "Default",
				skins: [
					{name: "Default", locked: false}
				]
			};

			var json_founded:Array<String> = Paths.readDirectory('assets/characters/$char/Skins');

			for(json in json_founded){
				var j_array:Array<String> = json.split("-");

				if(j_array.length < 2){continue;}

				var cur_skin:String = j_array[1];

				var toContinue:Bool = false;
				for(s in current_skin_char.skins){if(s.name == cur_skin){toContinue = true;}}
				if(toContinue){continue;}

				current_skin_char.skins.push({name: cur_skin, locked: true});
			}
			
			skin_manager.set(char, current_skin_char);
		}

		var saved_skin_data:Map<String, Dynamic> = FlxG.save.data.skins;

		if(saved_skin_data == null){return;}
		for(skin_key in saved_skin_data.keys()){
			setSkin(skin_key, saved_skin_data[skin_key].skin);

			var character_unlockeds:Array<Dynamic> = saved_skin_data[skin_key].unlockeds;
			for(unlocked in character_unlockeds){
				unlockSkin(skin_key, unlocked);
			}
		}
	}

	public static function getSkin(character:String):String {
		if(!skin_manager.exists(character)){return "Default";}
		return skin_manager.get(character).current_skin;
	}

	public static function getSkinList(character:String):Array<Dynamic> {
		if(!skin_manager.exists(character)){return ["Default"];}
		return skin_manager.get(character).skins;
	}

	public static function unlockSkin(character:String, skin:String):Void {		
		if(!skin_manager.exists(character)){trace("Null Character"); return;}

		var character_skins:Array<Dynamic> =skin_manager.get(character).skins;

		for(_skin in character_skins){
			if(_skin.name == skin){
				_skin.locked = false;
				return;
			}
		}

		trace("Skin Not Found");
	}

	public static function rewardSkin(character:String, skin:String):Void {
		unlockSkin(character, skin);
		save();
	}

	public static function setSkin(character:String, skin:String):Void {
		if(!skin_manager.exists(character)){trace("Null Character"); return;}
		skin_manager.get(character).current_skin = skin;
	}

	public static function checkLocked(character:String, skin:String):Bool {
		if(!skin_manager.exists(character)){trace("Null Character"); return true;}

		var skin_list:Array<Dynamic> = skin_manager.get(character).skins;

		for(_skin in skin_list){
			if(_skin.name == skin){
				return _skin.locked;
			}
		}

		return true;
	}

	public static function save():Void {
		var skins_to_save:Map<String, Dynamic> = [];

		for(char_key in skin_manager.keys()){
			var current_skin_data = {
				skin: getSkin(char_key),
				unlockeds: []
			};

			for(skin in getSkinList(char_key)){
				if(!skin.locked){
					current_skin_data.unlockeds.push(skin.name);
				}
			}

			skins_to_save.set(char_key, current_skin_data);
		}

		FlxG.save.data.skins = skins_to_save;
		FlxG.save.flush();
	}
}

class Character extends FlxSpriteGroup {
	public static function getFocusCharID(song:SwagSong, section:Int, ?strum:Int):Int {
		var strum_list = song.sectionStrums;
		var focused_strum = strum != null ? strum : song.generalSection[section].strumToFocus;
		var focused_character = song.generalSection[section].charToFocus;

		if(strum_list == null || strum_list[focused_strum] == null){return 0;}
		if(strum_list[focused_strum].notes[section].changeSing){return strum_list[focused_strum].notes[section].charToSing[focused_character];}
		return strum_list[focused_strum].charToSing[focused_character];
	}

	public static function setCameraToCharacter(char:Character, cam:FlxObject){
		if(char == null){return;}

		var camMoveX = char.character_sprite.getGraphicMidpoint().x;
		var camMoveY = char.character_sprite.getGraphicMidpoint().y;

		camMoveX += char.cameraPosition[0];
		camMoveY += char.cameraPosition[1];

		switch(PreSettings.getPreSetting("Type Camera", "Visual Settings")){
			case "Static":{}
			case "MoveToSing":{
				if(char.character_sprite.animation.curAnim != null){
					switch(char.character_sprite.animation.curAnim.name){
						case 'singUP':{camMoveY -= 100;}
						case 'singDOWN':{camMoveY += 100;}
						case 'singRIGHT':{camMoveX += (!char.character_sprite.flipX) ? 100 : -100;}
						case 'singLEFT':{camMoveX -= (!char.character_sprite.flipX) ? 100 : -100;}
					}
				}				
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
	public var curAspect:String = "Default";
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

	public var onDebug:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'Boyfriend', ?aspect:String = 'Default', ?type:String = "NORMAL"):Void {
		super(x, y);

		curCharacter = character;
		curAspect = aspect;
		curType = type;

		switch(curCharacter){
			default:{setupByCharacterFile();}
		}
	}

	public static function addToLoad(list:Array<Dynamic>, character:String = 'Boyfriend', aspect:String = 'Default'):Void {
		trace('|| CHARACTER: ${character} | ASPECT: ${aspect} ||');

		var char_path:String = Paths.getCharacterJSON(character, aspect);
		var char_file:CharacterFile = cast Json.parse(Paths.getText(char_path));

		list.push({type: "ATLAS", instance: Paths.character(character, char_file.image)});
		list.push({type: IMAGE, instance: Paths.image('icons/icon-${char_file.healthicon}', null, true)});

		var char_script_path:String = char_path.replace('.json', '.hx');
		if(!Paths.exists(char_script_path)){return;}
		Script.importScript(char_script_path).exFunction('addToLoad', [list]);
	}

	public function setupByName(?_character:String, ?_aspect:String, ?_type:String):Void {
		if(_character != null){curCharacter = _character;}
		if(_aspect != null){curAspect = _aspect;}
		if(_type != null){curType = _type;}
		setupByCharacterFile();
	}

	public function setupByCharacterFile(?jCharacter:CharacterFile):Void {
		var char_path:String = Paths.getCharacterJSON(curCharacter, curAspect);
		if(jCharacter == null){jCharacter = cast Json.parse(Paths.getText(char_path));}

		charFile = jCharacter;

		parseCharacterFiler(charFile);

		curCharacter = charFile.name;
		curSkin = charFile.skin;
		curAspect = charFile.aspect;

		healthIcon = charFile.healthicon;

		this.dancedIdle = charFile.danceIdle;

		this.antialiasing = charFile.antialiasing;

		this.dieCharacter = charFile.deathCharacter;
		imageFile = charFile.image;
		animationsArray = charFile.anims;

		positionArray = charFile.position;
		cameraPosition = charFile.camera;

		if(charScript != null){
			charScript.destroy();
			charScript = null;
		}

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

	public static function parseCharacterFiler(charFile:CharacterFile):Void {
		if(charFile.name == null){charFile.name = "Boyfriend";}
		if(charFile.skin == null){charFile.skin = "Default";}
		if(charFile.aspect == null){charFile.aspect = "Default";}

		if(charFile.healthicon == null){charFile.healthicon = "face";}

		if(charFile.deathCharacter == null){charFile.deathCharacter = "Boyfriend_Death";}
		if(charFile.image == null){charFile.image = "BOYFRIEND";}
		if(charFile.anims == null){charFile.anims = [];}

		if(charFile.position == null){charFile.position = [];}		
		if(charFile.camera == null){charFile.camera = [0, 0];}
	}

	public function setCharacterGraphic(?IMAGE:String):Void {
		if(IMAGE != null){imageFile = IMAGE;}

		this.clear();

		character_sprite = new FlxSprite(positionArray[0], positionArray[1]);

		character_sprite.antialiasing = charFile.antialiasing;
		scaleCharacter();

		character_sprite.frames = Paths.getAtlas(Paths.character(curCharacter, imageFile));
		if(animationsArray != null && animationsArray.length > 0){
			for(anim in animationsArray){
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.symbol;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; // Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0){
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
			if(holdTimer > 0){holdTimer -= elapsed;}
			else{
				if(MusicBeatState.state.curBeat != oldBeat){
					oldBeat = MusicBeatState.state.curBeat;
					dance();
				}
			}

			if(character_sprite.animation.curAnim.finished && character_sprite.animation.getByName(character_sprite.animation.curAnim.name + '-loop') != null){
				playAnim(animation.curAnim.name + '-loop');
			}
		}

		super.update(elapsed);

		if(charScript != null){charScript.exFunction('update', [elapsed]);}
	}

	public function dance():Void {
		var toContinue:Bool = true;
		if(charScript != null){toContinue = charScript.exFunction('dance');}
		if(specialAnim || !toContinue){return;}

		if(dancedIdle){
			if(character_sprite.animation.curAnim != null && character_sprite.animation.curAnim.name == 'danceRight'){playAnim('danceLeft');}
			else{playAnim('danceRight');}

			holdTimer = 0;
		}else{playAnim('idle');}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Special:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		if(character_sprite.flipX){
			if(AnimName.contains("LEFT")){AnimName = AnimName.replace("LEFT", "RIGHT");}
			else{AnimName = AnimName.replace("RIGHT", "LEFT");}
		}

		if((specialAnim && !Special)
			|| (character_sprite.animation.curAnim != null
				&& character_sprite.animation.curAnim.name == AnimName
				&& character_sprite.animation.curAnim.name.contains("sing")
				&& character_sprite.animation.curAnim.curFrame < singTimer)
		){
			return;
		}

		specialAnim = Special;
		
		if(charScript != null){charScript.exFunction('playAnim', [AnimName, Force, Reversed, Frame]);}

		if(character_sprite.animation.getByName(AnimName) == null){return;}
		character_sprite.animation.play(AnimName, Force, Reversed, Frame);
		holdTimer = ((character_sprite.animation.getByName(AnimName).frames.length - Frame) / character_sprite.animation.getByName(AnimName).frameRate);
	}

	public function turnLook(toRight:Bool = true):Void {
		onRight = toRight;
		character_sprite.flipX = onRight ? !charFile.onRight : charFile.onRight;
		if(charScript != null){charScript.exFunction('turnLook', [toRight]);}
	}

	public function scaleCharacter(_scale:Float = 1):Void {
		var new_scale = _scale * charFile.scale;
		character_sprite.scale.set(new_scale, new_scale);
	}
}
