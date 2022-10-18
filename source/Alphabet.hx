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
import flixel.util.FlxColor;
import haxe.io.Bytes;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup {
    public static var DEFAULT_FONT:String = "alphabet";
	public var cur_data:Array<Dynamic> = [];

    public var repMap:Map<String, String> = [
        "-" => " "
    ];

    public var text:String = "";

    //Dialogue Stuff
    public var delay:Float = 0.05;
	public var paused:Bool = false;

    var spaceWidth:Float = 25;
    var xMultiplier:Float = 1;
    var yMultiplier:Float = 1;
    var xOffset:Float = 0;
    var yOffset:Float = 0;

    var lastChar:AlphaCharacter = null;
    var lastFirstChar:AlphaCharacter = null;

	var curY:Float = 0;
    var curX:Float = 0;

    public function new(x:Float, y:Float, data:Dynamic){
        if((data is Array)){cur_data = data;}else if((data is String)){cur_data = [({text: data})];}else{cur_data = [data];}

		super(x, y);

        if(cur_data.length <= 0){return;}
        loadText();
	}

    function doSplitWords(_text:String):Array<String> {
        var splitWords:Array<String> = _text.split("");
        for(c in splitWords){if(repMap.exists(c)){c.replace(c, repMap.get(c));}}
        return splitWords;
    }
    
    public function loadText(){
        curX = 0;
        curY = 0;
        text = "";
        clear();

        for(_dat in cur_data){
            var cur_split:Array<String> = null;
            var cur_image:String = null;

            var cur_scale:FlxPoint = _dat.scale != null ? FlxPoint.get(_dat.scale,_dat.scale) : FlxPoint.get(1,1);
            var cur_font:String = _dat.font != null ? _dat.font : DEFAULT_FONT;
            var cur_animated:Bool = _dat.animated;
            var cur_bold:Bool = _dat.bold;
            var cur_color:FlxColor = _dat.color != null ? _dat.color : 0x00ffffff;
            if(_dat.position != null){curX = _dat.position[0]; curY = _dat.position[1];}
            if(_dat.rel_position != null){curX += _dat.rel_position[0]; curY += _dat.rel_position[1];}

            if(_dat.text != null){cur_split = doSplitWords(_dat.text);}
            else if(_dat.image != null){cur_image = _dat.image;}

            if(cur_split != null){
                var _i:Int = 0;
                for(char in cur_split){
                    switch(char){
                        case '\n':{if(lastFirstChar != null){curY += lastFirstChar.height * yMultiplier; curX = 0;}}
                        case '\t':{curX += 2 * spaceWidth;}
                        case ' ':{curX += spaceWidth;}
                        default:{
                            if(AlphaCharacter.getChars().indexOf(char.toLowerCase()) != -1){
                                var letter:AlphaCharacter = new AlphaCharacter(curX + xOffset, curY + yOffset, cur_font);
                                letter.createChar(char, cur_bold, cur_color);
                                if(!cur_animated){letter.animation.stop();}
                                letter.scale.set(cur_scale.x, cur_scale.y); letter.updateHitbox();
                                curX += letter.width * xMultiplier;
                                        
                                lastChar = letter;
                                if(_i == 0){lastFirstChar = letter;}
                    
                                add(letter);
        
                                _i++;
                            }
                        }
                    }
                    text += char;
                }
            }else if(cur_image != null){
                trace('Imagen Pa:${Paths.setPath(cur_image)}');
                var _image:FlxSprite = new FlxSprite(curX, curY).loadGraphic(Paths.getGraphic(Paths.setPath(cur_image)));
                _image.scale.set(cur_scale.x, cur_scale.y); _image.updateHitbox();
                _image.color = cur_color;
                add(_image);
            }
        }
    }
    
    override function update(elapsed:Float){    
        super.update(elapsed);
    }
}

class AlphaCharacter extends FlxSprite {
    public static var alphabet:String = "abcdefghijklmnopqñrstuvwxyz";
	public static var numbers:String = "1234567890";
	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? ";
    public static function getChars():String {return alphabet + numbers + symbols;}

    public function new(x:Float, y:Float, image:String){
        super(x, y);
        
        var tex = Paths.getSparrowAtlas(image);
        frames = tex;
    }
    
    var reMap:Map<String, String> = [
        "." => "period",
        "'" => "apostraphie",
        "?" => "question mark",
        "!" => "exclamation point",
        " " => "space",
        "," => "comma"
    ];
    public function createChar(letter:String, isBold:Bool = false, getColor:FlxColor = 0x00ffffff){
        var gSymbol:String = letter; if(reMap.exists(letter)){gSymbol = reMap.get(letter);}

        animation.addByPrefix('${letter.toUpperCase()}_bold', '${gSymbol.toUpperCase()} bold', 24, true);
        animation.addByPrefix(letter.toLowerCase(), '${gSymbol.toLowerCase()} lowercase', 24, true);
        animation.addByPrefix(letter.toUpperCase(), '${gSymbol.toUpperCase()} capital', 24, true);
        animation.addByPrefix('_${letter}', gSymbol, 24, true);

        animation.play(letter);
        if(numbers.indexOf(letter) != -1 || symbols.indexOf(letter) != -1){animation.play('_${letter}');}
        if(isBold){animation.play('${letter.toUpperCase()}_bold');}
        this.color = getColor;
        
        updateHitbox();
    }
}