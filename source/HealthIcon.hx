package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite {
	public var isPlayer:Bool = false;
	public var curIcon:String = "";

	public var valueInstance:Float;

	public function new(_inst_value:Float, char:String = 'bf', _isPlayer:Bool = false){
		this.valueInstance = _inst_value;
		this.isPlayer = _isPlayer;
		super();

		this.setIcon(char);

		this.scrollFactor.set();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		playAnim(((valueInstance > 0.2 && isPlayer) || (valueInstance < 0.8 && !isPlayer)) ? 'default' : 'losing');
	}

	public function setIcon(char:String){
		if(curIcon == char){return;}
		curIcon = char;

		switch(curIcon){
			default:{
				var path = Paths.image('icons/icon-${curIcon}', null, true);
				if(!Paths.exists(path)){path = Paths.image('icons/icon-face', null, true);}

				if(Paths.getAtlas(path) != null){
					this.frames = Paths.getAtlas(path);

					this.animation.addByPrefix('default', 'Default', 24, true, isPlayer);
					this.animation.addByPrefix('losing', 'Losing', 24, true, isPlayer);
				}else{
					var _bitMap:FlxGraphic = Paths.getGraphic(path);
					if(_bitMap == null){return;}

					this.loadGraphic(_bitMap, true, Math.floor(_bitMap.width / 2), Math.floor(_bitMap.height));

					this.animation.add('default', [0], 0, false, isPlayer);
					this.animation.add('losing', [1], 0, false, isPlayer);
				}

				playAnim("default");
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0){
		if(animation.getByName(AnimName) == null){return;}
		animation.play(AnimName,Force,Reversed,Frame);
	}
}
