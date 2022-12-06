package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxBaseAnimation;
import flixel.group.FlxSpriteGroup;
import openfl.utils.AssetType;
import flixel.tweens.FlxTween;
import haxe.format.JsonParser;
import haxe.macro.Expr.Catch;
import states.MusicBeatState;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
import openfl.utils.Assets;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;

import Song.SwagSong;
import Song.SwagStrum;
import Song.SwagSection;
import Song.SwagGeneralSection;

using StringTools;

#if windows
import sys.FileSystem;
import sys.io.File;
#end

class Player extends FlxSprite {
    public static var PLAYER_SIZE:Int = 60;
	public static var DEFAULT_CHARACTER:String = 'bf';

    public var isPlayer:Bool = false;
    public var player_controls:Controls;

	public function new(X:Float = 0, Y:Float = 0, ?character:String){
        if(character == null){character = DEFAULT_CHARACTER;}
		super(X, Y);

        this.maxVelocity.set(200, 200);
        this.drag.set(1000, 1000);

        loadPlayerAssets(character);
	}

    public function loadPlayerAssets(player:String){
        this.frames = Paths.getAtlas(Paths.image('players/${player}_player', null, true));

        this.setGraphicSize(PLAYER_SIZE, PLAYER_SIZE);
        this.updateHitbox();
    }

	override function update(elapsed:Float){
        keyShit();
        
		super.update(elapsed);
	}

    private function keyShit():Void {
        if(player_controls == null){return;}

		if(player_controls.checkAction("Player_Left", PRESSED)){this.acceleration.x = -1000;}
		else if(player_controls.checkAction("Player_Right", PRESSED)){this.acceleration.x = 1000;}
        else {this.acceleration.x = 0;}
        
		if(player_controls.checkAction("Player_Up", PRESSED)){this.acceleration.y = -1000;}
		else if(player_controls.checkAction("Player_Down", PRESSED)){this.acceleration.y = 1000;}
        else {this.acceleration.y = 0;}
        
		if(player_controls.checkAction("Player_Run", PRESSED)){this.maxVelocity.set(400, 400);}
		else {this.maxVelocity.set(200, 200);}
    }
}
