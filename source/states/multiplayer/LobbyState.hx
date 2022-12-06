package states.multiplayer;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.atlas.FlxAtlas;
import flixel.system.FlxSoundGroup;
import substates.MusicBeatSubstate;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.util.FlxStringUtil;
import flixel.util.FlxCollision;
import openfl.display.BlendMode;
import substates.PauseSubState;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import flixel.text.FlxText;
import flixel.FlxSubState;
import lime.utils.Assets;
import sys.thread.Thread;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxGame;
import flixel.FlxG;
import haxe.Timer;
import haxe.Json;

using StringTools;

class LobbyState extends MusicBeatState {
    public var cur_player:Player;

	override public function create(){
		Multiplayer.Start_Conection();

        add(new FlxSprite().makeGraphic(100, 100, FlxColor.WHITE));

		super.create();

        cur_player = new Player();
        cur_player.isPlayer = true;
        cur_player.player_controls = principal_controls;

		FlxG.camera.follow(cur_player, LOCKON, 0.1);
        add(cur_player);
	}

    override public function update(elapsed:Float){
		super.update(elapsed);
	}

	override function stepHit(){
		super.stepHit();
	}

	override function beatHit(){
		super.beatHit();
	}
}