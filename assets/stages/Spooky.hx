import("PreSettings");
import("Paths");

import("flixel.FlxG", "FlxG");
import("flixel.FlxSprite", "FlxSprite");

presset("initChar", 0);
presset("chrome", 0);
presset("zoom", 1.05);

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

var halloweenBG:FlxSprite = null;

var beat:Int = 0;
function create(){
    halloweenBG = new FlxSprite(-200, -100);
    
    if(PreSettings.getPreSetting("BackgroundAnimated")){
        halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg', 'stages/spooky');
        halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
        halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
        halloweenBG.animation.play('idle');
    }else{
        halloweenBG.loadGraphic(Paths.image('halloween_bg_low', 'stages/spooky'));
    }

    halloweenBG.antialiasing = PreSettings.getPreSetting("Antialiasing");
    instance.add(halloweenBG);
    
    pushGlobal();
}

function beatHit(curBeat){beat = curBeat;
    if(FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset){lightningStrikeShit();}
}

function lightningStrikeShit(){
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	halloweenBG.animation.play('lightning');

	lightningStrikeBeat = beat;
	lightningOffset = FlxG.random.int(8, 24);

    for(i in 0...stage.character_Length){stage.getCharacterById(i).playAnim('scared');}
}