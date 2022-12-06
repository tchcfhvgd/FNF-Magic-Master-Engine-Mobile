package;

import haxe.ds.StringMap;
import haxe.MainLoop;
import haxe.Timer;
import haxe.Json;
import haxe.Http;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.net.Host;
import sys.ssl.Socket;
#end

class Multiplayer {
	private inline static var MAIN_LOOP_DELAY:Float = 0.1;

	private static var SOCKET:Socket;
    
	private static var MAIN_LOOP_TIMER:Timer;

	public static function Start_Conection():Void {
		SOCKET = new Socket();

		try{
			SOCKET.verifyCert = false;
			SOCKET.connect(new Host("irc.twitch.tv"), 6697);
			SOCKET.setBlocking(false);
	
			SOCKET.write('--cwd /my/project\n');
			SOCKET.write('myproject.hxml\n');
			SOCKET.write("\000");
	
			var hasError = false;
			for(line in SOCKET.read().split('\n')){
				switch(line.charCodeAt(0)) {
					case 0x01:{Sys.print(line.substr(1).split("\x01").join('\n'));}
					case 0x02:{hasError = true;}				
					default:{Sys.stderr().writeString('${line}\n');}
				}
			}
			if(hasError){Sys.print("Error :C");}
		}catch(e:Dynamic){
            Sys.println("Error: " + e);
		}
		
	}
}