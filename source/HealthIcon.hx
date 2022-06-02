package;

import flixel.FlxSprite;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.graphics.frames.FlxAtlasFrames;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;

	public var isPlayer:Bool = false;
	public var char:String = 'bf';

	public function new(char:String = 'bf', isPlayer:Bool = false){
		this.isPlayer = isPlayer;
		super();
		
		setIcon(char);
		scrollFactor.set();
	}

	public function setIcon(char:String){
		if(this.char != char){
			switch(char){
				default:{
					var name:String = 'icons/' + char;
					var path:String = 'assets/images/';
					if(!Assets.exists(path + name + '.png', IMAGE)){name = 'icons/icon-' + char;}
					if(!Assets.exists(path + name + '.png', IMAGE)){name = 'icons/icon-face';}
							
					if(Assets.exists(path + name + '.xml', TEXT)){
						var file:FlxAtlasFrames = Paths.getSparrowAtlas(name);
						frames = file;
	
						animation.addByPrefix('default', 'Default', 24, true, isPlayer);
						animation.addByPrefix('losing', 'Losing', 24, true, isPlayer);
	
					}else{
						var file:Dynamic = Paths.image(name);
						loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
	
						animation.add('default', [0], 0, false, isPlayer);
						animation.add('losing', [1], 0, false, isPlayer);
					}

					updateHitbox();
				}
			}
			
			this.char = char;
			animation.play('default');
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
