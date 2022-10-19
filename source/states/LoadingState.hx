package states;


import haxe.Json;
import flixel.tweens.FlxTween;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import Song.SwagSong;
import Stage;

import haxe.io.Path;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LoadingState extends MusicBeatState{
	public static var toGlobalLoadStuff:Array<Dynamic> = [
		{type:IMAGE , path: Paths.image('menuBGBlue', null, true)}
	];
	public static var toLoadStuff:Array<Dynamic> = [];

	private var tempLoadingStuff:Array<Dynamic> = [];
	
	private var TARGET:FlxState;
	private var WithMusic:Bool = false;

	public function new(target:FlxState, withMusic:Bool = false){
		this.WithMusic = withMusic;
		this.TARGET = target;
		super();
	}

	override function create(){
		var bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		add(bg);

		for(stuff in toGlobalLoadStuff){tempLoadingStuff.push(stuff);}
		for(stuff in toLoadStuff){tempLoadingStuff.push(stuff);}

		loadSuff();

		super.create();
	}

	private function loadSuff():Void {
		if(tempLoadingStuff.length <= 0){onLoad(); return;}
		var _stuff:Dynamic = tempLoadingStuff.shift();

		switch(_stuff.type){
			default:{trace(_stuff);}
			case IMAGE: Paths.getGraphic(_stuff.path);
			case SOUND, MUSIC: Paths.getSound(_stuff.path);
			case TEXT: Paths.getText(_stuff.path);

			case "SONG":{
				var _song:SwagSong = cast _stuff.path;

				for(i in Paths.readDirectory('assets/songs/${_song.song}/Audio/')){Paths.getSound(i);}
				for(i in Paths.readDirectory('assets/songs/${_song.song}/Data/')){Paths.getText(i);}

				new Stage(_song.stage, _song.characters);
			}
		}

		loadSuff();
	}

	private function onLoad(){
		MusicBeatState.switchState(TARGET);
	}
}