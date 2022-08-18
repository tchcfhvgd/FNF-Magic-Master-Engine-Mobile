package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup {
    public var curImage:String = "alphabet";
    public var curScale:FlxPoint = new FlxPoint(1, 1);
	public var curText:String = "";

    public var animated:Bool = false;

    public var repMap:Map<String, String> = [
        "-" => " "
    ];

    //Dialogue Stuff
    public var delay:Float = 0.05;
	public var paused:Bool = false;

	//Menu Stuff
	public var targetY:Float = 0;
	public var menuItem:String = "";

    var spaceWidth:Float = 25;
    var xMultiplier:Float = 1;
    var yMultiplier:Float = 1;
    var xOffset:Float = 0;
    var yOffset:Float = 0;

    var lastChar:AlphaCharacter = null;
    var curChar:Int = 0;
	var curY:Float = 0;
    var curX:Float = 0;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	var pastX:Float = 0;
	var pastY:Float  = 0;

    public function new(x:Float, y:Float, ?scale:FlxPoint, text:String = "", bold:Bool = false, typed:Bool = false, animated:Bool = true, image:String = null){
		if(image != null){curImage = image;}
        if(scale != null){curScale = scale;}
        this.animated = animated;
		curText = text;
		isBold = bold;
		pastX = x;
		pastY = y;
		super(x, y);


        if(curText.length <= 0){return;}
        if(typed){typeText(); return;}
        setText();
	}

    function doSplitWords():Void {
        splitWords = curText.split("");
        for(c in splitWords){if(repMap.exists(c)){c.replace(c, repMap.get(c));}}
    }

    public function setText(){
        doSplitWords();
        curX = 0;
        curY = 0;
        clear();
    
        for(char in splitWords){
            if(char == " "){curX += spaceWidth;}else{
                if(AlphaCharacter.getChars().indexOf(char.toLowerCase()) != -1){        
                    var letter:AlphaCharacter = new AlphaCharacter(curX + xOffset, curY + yOffset, curImage);
                    letter.createChar(char, isBold);
                    if(!animated){letter.animation.stop();}
                    letter.scale.set(curScale.x, curScale.y);
                    curX += letter.width * xMultiplier;
                            
        
                    add(letter);
                }
            }
        }
    }

    public function typeText():Void{
        doSplitWords();
        curChar = 0;
        curX = 0;
        curY = 0;
        clear();

        var loopTimer = new haxe.Timer(delay * 1000);
        loopTimer.run = function(){
            if(curText.fastCodeAt(curChar) == "\n".code){
                if(lastChar != null){curY += lastChar.height * yMultiplier;}
                curX = 0;
            }

            if(splitWords[curChar] == " "){curX += spaceWidth;}else{
                if(AlphaCharacter.getChars().indexOf(splitWords[curChar]) != -1){        
                    var letter:AlphaCharacter = new AlphaCharacter(curX + xOffset, curY + yOffset, curImage);
                    if(!animated){letter.animation.stop();}
                    letter.scale.set(curScale.x, curScale.y);
                    curX += letter.width * xMultiplier;
                            
                    letter.createChar(splitWords[curChar], isBold);
        
                    add(letter);
                }
            }
            
            curChar += 1;
            if(curChar >= splitWords.length){loopTimer.stop();}
        }
    }
    
    override function update(elapsed:Float){
        switch(menuItem){
            case 'optionItem':{
                var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
    
                y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
                //x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
            }
            case 'freeItem':{
                y = FlxG.height * 0.90;
                x = FlxMath.lerp(x, -1000, 0.30);
                if(targetY == 0){x = FlxMath.lerp(x, 1000, 0.30);}
            }
            case 'mainItem':{
                var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
    
                y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
                x = FlxMath.lerp(x, (targetY * 70) + 350, 0.30);
                if(targetY == 0){x = FlxMath.lerp(x, (targetY * 70) + 400, 0.30);}
            }		
        }
    
        super.update(elapsed);
    }
}

class AlphaCharacter extends FlxSprite {
    public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var numbers:String = "1234567890";
	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? ";
    public static function getChars():String {return alphabet + numbers + symbols;}

    public function new(x:Float, y:Float, image:String){
        super(x, y);
        
        var tex = Paths.getSparrowAtlas(image);
        frames = tex;
    
        antialiasing = PreSettings.getPreSetting("Antialiasing");
    }
    
    var reMap:Map<String, String> = [
        "." => "period",
        "'" => "apostraphie",
        "?" => "question mark",
        "!" => "exclamation point",
        " " => "space"
    ];
    public function createChar(letter:String, isBold:Bool = false){
        var gSymbol:String = letter; if(reMap.exists(letter)){gSymbol = reMap.get(letter);}

        animation.addByPrefix('${letter.toUpperCase()}_bold', '${gSymbol.toUpperCase()} bold', 24, true);
        animation.addByPrefix(letter.toLowerCase(), '${gSymbol.toLowerCase()} lowercase', 24, true);
        animation.addByPrefix(letter.toUpperCase(), '${gSymbol.toUpperCase()} capital', 24, true);
        animation.addByPrefix('_${letter}', gSymbol, 24, true);

        animation.play(letter);
        if(numbers.indexOf(letter) != -1 || symbols.indexOf(letter) != -1){animation.play('_${letter}');}
        if(isBold){animation.play('${letter.toUpperCase()}_bold');}
        
        updateHitbox();
    }
}