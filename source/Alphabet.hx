package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import haxe.io.Bytes;
import flixel.FlxG;
import haxe.Timer;

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

    //------| Dialogue Stuff |------//
    var onDialogue:Bool = false;
    var charSound:FlxSound;
    //-----------------------------//

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
        text = "";
        curX = 0;
        curY = 0;
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
                        case ' ':{curX += spaceWidth;  text += " ";}
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
                var _image:FlxSprite = new FlxSprite(curX, curY).loadGraphic(Paths.image(cur_image));
                _image.scale.set(cur_scale.x, cur_scale.y); _image.updateHitbox();
                _image.color = cur_color;
                add(_image);
            }
        }
    }

    var timer:FlxTimer;
    public function startText():Void {
        var cloned_data:Array<Dynamic> = cur_data.copy();
        text = "";
        curX = 0;
        curY = 0;
        clear();

        onDialogue = true;

        if(timer != null){timer.cancel();}
        timer = new FlxTimer();

        var current_item:Dynamic = null;
        var current_text:Array<String> = [];
        
        var cur_scale:FlxPoint = FlxPoint.get(1,1);
        var cur_font:String = DEFAULT_FONT;
        var cur_animated:Bool = true;
        var cur_bold:Bool = true;
        var cur_color:FlxColor = 0x00ffffff;

        var _i:Int = 0;

        timer.start(1,
            function(tmr:FlxTimer){
                if(current_text.length <= 0){
                    if(cloned_data.length <= 0){
                        onDialogue = false;
                        return;
                    }

                    current_item = cloned_data.copy();
                    current_text = doSplitWords(current_item.text);

                    timer.loops = current_text.length + 1;
                    timer.time = current_item.time;
                    
                    cur_scale = current_item.scale != null ? FlxPoint.get(current_item.scale,current_item.scale) : FlxPoint.get(1,1);
                    cur_font = current_item.font != null ? current_item.font : DEFAULT_FONT;
                    cur_animated = current_item.animated;
                    cur_bold = current_item.bold;
                    cur_color = current_item.color != null ? current_item.color : 0x00ffffff;
                    if(current_item.position != null){curX = current_item.position[0]; curY = current_item.position[1];}
                    if(current_item.rel_position != null){curX += current_item.rel_position[0]; curY += current_item.rel_position[1];}

                    if(current_item.sound != null && Paths.exists(Paths.sound(current_item.sound, null, true))){charSound = new FlxSound().loadEmbedded(Paths.sound(current_item.sound));}
                    
                    return;
                }

                var cur_character:String = current_text.shift();
                
                switch(cur_character){
                    case '\n':{if(lastFirstChar != null){curY += lastFirstChar.height * yMultiplier; curX = 0;}}
                    case '\t':{curX += 2 * spaceWidth;}
                    case ' ':{curX += spaceWidth; text += " ";}
                    default:{
                        if(AlphaCharacter.getChars().indexOf(cur_character.toLowerCase()) != -1){
                            var letter:AlphaCharacter = new AlphaCharacter(curX + xOffset, curY + yOffset, cur_font);
                            letter.createChar(cur_character, cur_bold, cur_color);
                            if(!cur_animated){letter.animation.stop();}
                            letter.scale.set(cur_scale.x, cur_scale.y); letter.updateHitbox();
                            curX += letter.width * xMultiplier;
                                    
                            lastChar = letter;
                            if(_i == 0){lastFirstChar = letter;}
                
                            add(letter);
                            if(charSound != null){charSound.play();}
    
                            _i++;
                        }
                    }
                }
                text += cur_character;
            }
        , 1);
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
        
        var tex = Paths.getSparrowAtlas(Paths.image(image, null, true));
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

class PopUpScore extends FlxSpriteGroup {
    var recyclePop:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    public function new(?score:Int):Void {
        super();

        if(recyclePop.length <= 0){recyclePop.add(new FlxSprite());}
    
        if(score != null){popup(score);}
    }

    public function popup(score:Int, ?style:String){
        clear();

        var lastWidth:Float = 0;
        for(i in 0...'$score'.length){
            var _n:FlxSprite = recyclePop.recycle(FlxSprite);
            _n.loadGraphic(Paths.styleImage('num${'$score'.split("")[i]}', style));
            _n.setPosition(lastWidth,0);
            _n.scale.set(0.5,0.5);
            _n.updateHitbox();
            add(_n);

            lastWidth += _n.width - 5;

            FlxTween.tween(_n, {y: _n.y - 35, alpha: 0}, 0.5 + (i * 0.2), {ease:FlxEase.quadOut});
        }
    }
}