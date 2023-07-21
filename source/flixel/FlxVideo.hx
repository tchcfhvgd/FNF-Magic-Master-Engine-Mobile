package;

import openfl.events.NetStatusEvent;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.media.Video;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic {
	public var finishCallback:Void->Void;

	var netStream:NetStream;
	var video:Video;

	public function new(viedo_path:String):Void {
		super();

		video = new Video();
		video.x = 0;
		video.y = 0;

		FlxG.addChildBelowMouse(video);

		var netConnection = new NetConnection();
		netConnection.connect(null);

		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: client_onMetaData};
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnection_onNetStatus);
		netStream.play(Paths.file(viedo_path));
	}

	public function finishVideo():Void {
		netStream.dispose();
		FlxG.removeChild(video);
		if(finishCallback == null){return;}			
        finishCallback();
	}

	public function client_onMetaData(metaData:Dynamic):Void {
		video.attachNetStream(netStream);
		video.width = FlxG.width;
		video.height = FlxG.height;
	}

	private function netConnection_onNetStatus(event:NetStatusEvent):Void {
		if(event.info.code != 'NetStream.Play.Complete'){return;}
        finishVideo();
	}
}