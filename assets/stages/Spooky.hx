import("PreSettings");
import("Paths");

import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 1);
presset("chrome", 0);
presset("zoom", 0.7);

function create(){
    var halloweenBG = new FlxSprite(-200, -100);
    
    if(PreSettings.getPresseting("BackgroundAnimated")){
        halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg', 'stages/spooky');
        halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
        halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
        halloweenBG.animation.play('idle');
    }else{
        halloweenBG.loadGraphic(Paths.image('halloween_bg_low', 'stages/spooky'));
    }

    halloweenBG.antialiasing = PreSettings.getPreSetting("Antialiasing");
    instance.add(halloweenBG);
}

function update(){
    
}