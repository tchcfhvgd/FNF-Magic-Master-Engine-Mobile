package;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

using StringTools;

class FlxUIMenuCustom extends FlxUIGroup implements IResizable implements IFlxUIClickable implements IEventGetter {
    private var _BACK:FlxSprite;
    private var _TABS:FlxTypedGroup<FlxUIMenuTabCustom>;
	private var _TABICONS:FlxTypedGroup<FlxTypedButton<FlxSprite>>;
    private var curTAB:String = "";

	private var alignment:String = "Right";

	private var dWidth:Int;
	private var dHeight:Int;
	private var dX:Float;
	private var dY:Float;

    public function new(x:Float, y:Float, width:Int, height:Int, align:String = "Right"){
		dWidth = width;
		dHeight = height;
		dX = x;
		dY = y;
        alignment = align;
		super();

        _BACK = new FlxSprite(x, y).makeGraphic(width, height, FlxColor.BLACK);
		_BACK.alpha = 0.5;
        add(_BACK);

        _TABS = new FlxTypedGroup<FlxUIMenuTabCustom>();
		_TABICONS = new FlxTypedGroup<FlxTypedButton<FlxSprite>>();
    }

	public function addGroup(g:FlxUIMenuTabCustom):Void{
		curTAB = "";

		if(!hasThis(g)){
			trace("Adding Tab");
			g.x = _BACK.x;
			g.y = _BACK.y;

			switch(alignment){
				case "Left":{g.x = _BACK.x - g.dWidth;}
				case "Bottom":{g.y =_BACK.y + dHeight;}
				case "Up":{g.y =_BACK.y - g.dHeight;}
				case "Right":{g.x =_BACK.x + dWidth;}
			}

			add(g);
			_TABS.add(g);

			g._icon.x = _BACK.x;
			g._icon.y = _BACK.y;

			add(g._icon);
			_TABICONS.add(g._icon);
		}else{
			trace("Tab already Exist");
		}

		changeTAB();
	}

	private function getTAB(n:String):FlxUIMenuTabCustom{
		for(tab in _TABS){
			if(tab.name == n){
				return tab;
			}
		}
		return null;
	}

	public function updateButtons():Void{
		var count:Int = 0;
		for(btn in members){
			if((btn is FlxTypedButton<FlxSprite>)){
				btn.setPosition(dX + 5, dY + 5);
			}
		}
	}

	public function changeTAB(n:String = ""){
		var curTab:FlxUIMenuTabCustom = getTAB(n);

		updateButtons();
		_TABS.kill();

		var cCoords:Array<Float> = [dX, dY];
		if(curTab == null){
			trace("Null Tab: Closing");
			_BACK.setPosition(cCoords[0], cCoords[1]);
			_BACK.makeGraphic(dWidth, dHeight, FlxColor.BLACK);
		}else{
			trace("Changing Tab");
			switch(alignment){
				case "Left":{cCoords[0] -= curTab.dWidth;}
				case "Up":{cCoords[1] -= curTab.dHeight;}
			}

			trace("[" + curTab.dWidth + "," + curTab.dHeight +"]");

			_BACK.setPosition(cCoords[0], cCoords[1]);
			_BACK.makeGraphic(Std.int(dWidth + curTab.dWidth), Std.int(dHeight + curTab.dHeight), FlxColor.BLACK);

			curTab.calcBounds();
			curTab.revive();
		}
	}

	override function update(elapsed:Float){
	    super.update(elapsed);

		if(alignment != "Left" && alignment != "Bottom" && alignment != "Up" && alignment != "Right"){alignment = "Left";}
    }

	public function resize(W:Float, H:Float):Void{
    
    }

    /**To make IEventGetter happy**/
	public function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void{
        //donothing
    }

    public function getRequest(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic{
        //donothing
        return null;
    }
    
    public var skipButtonUpdate(default, set):Bool;
    private function set_skipButtonUpdate(b:Bool):Bool{
            skipButtonUpdate = b;
            return b;
    }
}

class FlxUIMenuTabCustom extends FlxSpriteGroup implements IFlxUIWidget{
	public var _icon:FlxTypedButton<FlxSprite>;
	public var name:String;

	public var broadcastToFlxUI:Bool = true;
	public var autoBounds:Bool = true;

	public var dWidth:Int;
	public var dHeight:Int;

	public function new(width:Int, height:Int, name:String, icon:String){
		this.name = name;
		this.dWidth = width;
		this.dHeight = height;
		super();

		var btnIcon = new FlxTypedButton<FlxSprite>(0, 0);
		btnIcon.makeGraphic(0, 0);
		btnIcon.label.loadGraphic(icon);

		_icon = btnIcon;
	}

	public override function destroy():Void{
		super.destroy();
	}

	public override function add(Object:FlxSprite):FlxSprite{
		var obj = super.add(Object);
		if(autoBounds){
			calcBounds();
		}
		return obj;
	}

	public override function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite{
		var obj = super.remove(Object, Splice);
		if(autoBounds){
			calcBounds();
		}
		return obj;
	}

	public function setScrollFactor(X:Float, Y:Float):Void{
		for(obj in members){
			if(obj != null){
				obj.scrollFactor.set(X, Y);
			}
		}
	}

	public function hasThis(Object:FlxSprite):Bool{
		for(obj in members){
			if(obj == Object){
				return true;
			}
		}
		return false;
	}

	/**
	 * Calculates the bounds of the group and sets width/height
	 * @param	rect (optional) -- if supplied, populates this with the boundaries of the group
	 */
	public function calcBounds(rect:FlxRect = null){
		if(members != null && members.length > 0){
			var left:Float = Math.POSITIVE_INFINITY;
			var right:Float = Math.NEGATIVE_INFINITY;
			var top:Float = Math.POSITIVE_INFINITY;
			var bottom:Float = Math.NEGATIVE_INFINITY;
			for(fb in members){
				if(fb != null){
					if((fb is IFlxUIWidget)){
						var flui:FlxSprite = cast fb;
						if(flui.x < left){left = flui.x;}
						if(flui.x + flui.width > right){right = flui.x + flui.width;}
						if(flui.y < top){top = flui.y;}
						if(flui.y + flui.height > bottom){bottom = flui.y + flui.height;}
					}
					else if((fb is FlxSprite)){
						var flxi:FlxSprite = cast fb;
						if(flxi.x < left){left = flxi.x;}
						if(flxi.x > right){right = flxi.x;}
						if(flxi.y < top){top = flxi.y;}
						if(flxi.y > bottom){bottom = flxi.y;}
					}
				}
			}
			width = (right - left);
			height = (bottom - top);
			if(rect != null){
				rect.x = left;
				rect.y = top;
				rect.width = width;
				rect.height = height;
			}
		}else{
			width = height = 0;
		}
	}

	/**
	 * Floor the positions of all children
	 */
	public function floorAll():Void{
		var fs:FlxSprite = null;
		for (fb in members){
			fs = cast fb;
			fs.x = Math.floor(fs.x);
			fs.y = Math.floor(fs.y);
		}
	}
}

/**
 * A cheap extension of FlxUIGroup that lets you move all the children around
 * without having to call reset()
 * @author Lars Doucet
 */
 class FlxUIGroup extends FlxSpriteGroup implements IFlxUIWidget
 {
	 /***PUBLIC VARS***/
	 // a handy string handler name for this thing
	 public var name:String;
 
	 public var broadcastToFlxUI:Bool = true;
 
	 /***PUBLIC GETTER/SETTERS***/
	 // public var velocity:FlxPoint;
	 public var autoBounds:Bool = true;
 
	 /***PUBLIC FUNCTIONS***/
	 public function new(X:Float = 0, Y:Float = 0)
	 {
		 super(X, Y);
	 }
 
	 public override function destroy():Void
	 {
		 super.destroy();
	 }
 
	 public override function add(Object:FlxSprite):FlxSprite
	 {
		 var obj = super.add(Object);
		 if (autoBounds)
		 {
			 calcBounds();
		 }
		 return obj;
	 }
 
	 public override function remove(Object:FlxSprite, Splice:Bool = false):FlxSprite
	 {
		 var obj = super.remove(Object, Splice);
		 if (autoBounds)
		 {
			 calcBounds();
		 }
		 return obj;
	 }
 
	 public function setScrollFactor(X:Float, Y:Float):Void
	 {
		 for (obj in members)
		 {
			 if (obj != null)
			 {
				 obj.scrollFactor.set(X, Y);
			 }
		 }
	 }
 
	 public function hasThis(Object:FlxSprite):Bool
	 {
		 for (obj in members)
		 {
			 if (obj == Object)
			 {
				 return true;
			 }
		 }
		 return false;
	 }
 
	 /**
	  * Calculates the bounds of the group and sets width/height
	  * @param	rect (optional) -- if supplied, populates this with the boundaries of the group
	  */
	 public function calcBounds(rect:FlxRect = null)
	 {
		 if (members != null && members.length > 0)
		 {
			 var left:Float = Math.POSITIVE_INFINITY;
			 var right:Float = Math.NEGATIVE_INFINITY;
			 var top:Float = Math.POSITIVE_INFINITY;
			 var bottom:Float = Math.NEGATIVE_INFINITY;
			 for (fb in members)
			 {
				 if (fb != null)
				 {
					 if ((fb is IFlxUIWidget))
					 {
						 var flui:FlxSprite = cast fb;
						 if (flui.x < left)
						 {
							 left = flui.x;
						 }
						 if (flui.x + flui.width > right)
						 {
							 right = flui.x + flui.width;
						 }
						 if (flui.y < top)
						 {
							 top = flui.y;
						 }
						 if (flui.y + flui.height > bottom)
						 {
							 bottom = flui.y + flui.height;
						 }
					 }
					 else if ((fb is FlxSprite))
					 {
						 var flxi:FlxSprite = cast fb;
						 if (flxi.x < left)
						 {
							 left = flxi.x;
						 }
						 if (flxi.x > right)
						 {
							 right = flxi.x;
						 }
						 if (flxi.y < top)
						 {
							 top = flxi.y;
						 }
						 if (flxi.y > bottom)
						 {
							 bottom = flxi.y;
						 }
					 }
				 }
			 }
			 width = (right - left);
			 height = (bottom - top);
			 if (rect != null)
			 {
				 rect.x = left;
				 rect.y = top;
				 rect.width = width;
				 rect.height = height;
			 }
		 }
		 else
		 {
			 width = height = 0;
		 }
	 }
 
	 /**
	  * Floor the positions of all children
	  */
	 public function floorAll():Void
	 {
		 var fs:FlxSprite = null;
		 for (fb in members)
		 {
			 fs = cast fb;
			 fs.x = Math.floor(fs.x);
			 fs.y = Math.floor(fs.y);
		 }
	 }
 }
 