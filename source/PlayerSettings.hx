package;

import Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.input.gamepad.FlxGamepad;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings {
    private static var PLAYERS:Array<PlayerSettings> = [];

    public inline static function getNumPlayers():Int {return PLAYERS.length;}
    public inline static function getPlayer(ID:Int):PlayerSettings {return PLAYERS[ID];}

    public static function init():Void {
        PLAYERS = []; //Deleting Players
		//Adding Principal Player One
        var player1:PlayerSettings = new PlayerSettings(0, Solo);
        PLAYERS.push(player1);
        
        var gamepadsDetected:Int = FlxG.gamepads.numActiveGamepads;
        for(i in 0...gamepadsDetected){
            if(i == 0 && FlxG.gamepads.getByID(0) != null){player1.controls.addGamepad(0); continue;}
            if(FlxG.gamepads.getByID(i) != null){
                var newPlayer:PlayerSettings = new PlayerSettings(i, None);
                newPlayer.controls.addGamepad(i);

                PLAYERS.push(newPlayer);
            }
        }
	}

    public var ID(default, null):Int;
    public final controls:Controls;

	function new(id, scheme){
		this.ID = id;
		this.controls = new Controls('player$id', scheme);
	}

	public function setKeyboardScheme(scheme){
		controls.setKeyboardScheme(scheme);
	}
}
