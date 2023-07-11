import("flixel.group.FlxTypedGroup", "FlxTypedGroup");
import("flixel.FlxSprite", "FlxSprite");
import("flixel.FlxG", "FlxG");
import("haxe.Timer", "Timer");
import("Paths", "Paths");
import("Math", "Math");
import("PreSettings");
import("SavedFiles");
import("StrumLine");
import("Type");
import("Std");

presset("initChar", 10);
presset("camP_1", [540,-3000]);
presset("camP_2", [970,530]);
presset("zoom", 0.9);

var tanksGroup:FlxTypedGroup<FlxSprite>;
var shootStrumLine:Strumline;
var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);

var background:FlxSprite = null;
var clouds:FlxSprite = null;
var mountains:FlxSprite = null;
var buildings:FlxSprite = null;
var ruins:FlxSprite = null;
var smokeLeft:FlxSprite = null;
var smokeRight:FlxSprite = null;
var watchtower:FlxSprite = null;
var tankrolling:FlxSprite = null;
var ground:FlxSprite = null;
var tank0:FlxSprite = null;
var tank1:FlxSprite = null;
var tank2:FlxSprite = null;
var tank4:FlxSprite = null;
var tank5:FlxSprite = null;
var tank3:FlxSprite = null;

function addToLoad(temp):Void {
	temp.push({type: "IMAGE", instance: Paths.image('tankmanKilled1','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankSky','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankClouds','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankMountains','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankBuildings','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankRuins','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('smokeLeft','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('smokeRight','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankWatchtower','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankRolling','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tankGround','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank0','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank1','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank2','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank4','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank5','stages/war')});
	temp.push({type: "IMAGE", instance: Paths.image('tank3','stages/war')});
}

function create():Void {
	background = new FlxSprite(-250, -250);
	background.loadGraphic(SavedFiles.getGraphic(Paths.image('tankSky', 'stages/war')));
	background.scale.set(1, 1);
	background.updateHitbox();
	background.scrollFactor.set(0, 0);
	instance.add(background);

	clouds = new FlxSprite(-500, 150);
	clouds.scrollFactor.set(0.1, 0.1);
	clouds.loadGraphic(SavedFiles.getGraphic(Paths.image('tankClouds', 'stages/war')));
	instance.add(clouds);

	mountains = new FlxSprite(-90, 100);
	mountains.scrollFactor.set(0.2, 0.2);
	mountains.loadGraphic(SavedFiles.getGraphic(Paths.image('tankMountains', 'stages/war')));
	instance.add(mountains);

	buildings = new FlxSprite(-200, 130);
	buildings.scrollFactor.set(0.3, 0.3);
	buildings.loadGraphic(SavedFiles.getGraphic(Paths.image('tankBuildings', 'stages/war')));
	instance.add(buildings);

	ruins = new FlxSprite(-180, 150);
	ruins.scrollFactor.set(0.4, 0.4);
	ruins.loadGraphic(SavedFiles.getGraphic(Paths.image('tankRuins', 'stages/war')));
	instance.add(ruins);

	smokeLeft = new FlxSprite(0, 0);
	smokeLeft.scrollFactor.set(0.4, 0.4);
	smokeLeft.frames = SavedFiles.getAtlas(Paths.image('smokeLeft', 'stages/war'));
	smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){smokeLeft.animation.play('idle');}
	instance.add(smokeLeft);

	smokeRight = new FlxSprite(900, 0);
	smokeRight.scrollFactor.set(0.4, 0.4);
	smokeRight.frames = SavedFiles.getAtlas(Paths.image('smokeRight', 'stages/war'));
	smokeRight.animation.addByPrefix('idle', 'SmokeRight');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){smokeRight.animation.play('idle');}
	instance.add(smokeRight);

	watchtower = new FlxSprite(100, 50);
	watchtower.scrollFactor.set(0.5, 0.5);
	watchtower.frames = SavedFiles.getAtlas(Paths.image('tankWatchtower', 'stages/war'));
	watchtower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){watchtower.animation.play('idle');}
	instance.add(watchtower);

	tankrolling = new FlxSprite(300, 300);
	tankrolling.scrollFactor.set(0.5, 0.5);
	tankrolling.frames = SavedFiles.getAtlas(Paths.image('tankRolling', 'stages/war'));
	tankrolling.animation.addByPrefix('idle', 'BG tank w lighting instance 1');
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tankrolling.animation.play('idle');}
	instance.add(tankrolling);

	tanksGroup = Type.createInstance(FlxTypedGroup, []);
	instance.add(tanksGroup);

	ground = new FlxSprite(-250, -50);
	ground.loadGraphic(SavedFiles.getGraphic(Paths.image('tankGround', 'stages/war')));
	instance.add(ground);

	tank0 = new FlxSprite(-500, 700);
	tank0.frames = SavedFiles.getAtlas(Paths.image('tank0', 'stages/war'));
	tank0.animation.addByPrefix('idle', 'fg tankhead far right instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank0.animation.play('idle');}
	tank0.scrollFactor.set(1.7, 1.5);
	instance.add(tank0);

	tank1 = new FlxSprite(-300, 740);
	tank1.frames = SavedFiles.getAtlas(Paths.image('tank1', 'stages/war'));
	tank1.animation.addByPrefix('idle', 'fg tankhead 5 instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank1.animation.play('idle');}
	tank1.scrollFactor.set(2, 0.2);
	instance.add(tank1);

	tank2 = new FlxSprite(450, 940);
	tank2.scrollFactor.set(1.5, 1.5);
	tank2.frames = SavedFiles.getAtlas(Paths.image('tank2', 'stages/war'));
	tank2.animation.addByPrefix('idle', 'foreground man 3 instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank2.animation.play('idle');}
	instance.add(tank2);

	tank4 = new FlxSprite(1300, 900);
	tank4.scrollFactor.set(1.5, 1.5);
	tank4.frames = SavedFiles.getAtlas(Paths.image('tank4', 'stages/war'));
	tank4.animation.addByPrefix('idle', 'fg tankman bobbin 3 instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank4.animation.play('idle');}
	instance.add(tank4);

	tank5 = new FlxSprite(1620, 700);
	tank5.scrollFactor.set(1.5, 1.5);
	tank5.frames = SavedFiles.getAtlas(Paths.image('tank5', 'stages/war'));
	tank5.animation.addByPrefix('idle', 'fg tankhead far right instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank5.animation.play('idle');}
	instance.add(tank5);

	tank3 = new FlxSprite(1000, 740);
	tank3.scrollFactor.set(2, 0.3);
	tank3.frames = SavedFiles.getAtlas(Paths.image('tank3', 'stages/war'));
	tank3.animation.addByPrefix('idle', 'fg tankhead 4 instance 1', 24, false);
	if(PreSettings.getPreSetting('Background Animated', 'Graphic Settings')){tank3.animation.play('idle');}
	instance.add(tank3);

	pushGlobal();
}

function preload():Void {
    shootStrumLine = getState().strumsGroup.members[2];
    if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
    if(shootStrumLine == null){return;}

    for(n in shootStrumLine.notelist){  
        if(!FlxG.random.bool(16)){continue;}
        
        var new_tank:FlxSprite = new FlxSprite(500, 200 + FlxG.random.int(50, 100));
        new_tank.flipX = n.noteData == 0;
        
		new_tank.frames = SavedFiles.getAtlas(Paths.image('tankmanKilled1', 'stages/war'));
		new_tank.animation.addByPrefix('run', 'tankman running', 24, true);
		new_tank.animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);
		new_tank.animation.play('run');
		new_tank.animation.curAnim.curFrame = FlxG.random.int(0, new_tank.animation.curAnim.frames.length - 1);

		new_tank.updateHitbox();
		new_tank.setGraphicSize(Std.int(0.8 * new_tank.width));
		new_tank.updateHitbox();
        
		new_tank._.endingOffset = FlxG.random.float(50, 200);
		new_tank._.tankSpeed = FlxG.random.float(0.6, 1);
		new_tank._.strumTime = n.strumTime;

        new_tank._.update = function(elpased:Float) {
            new_tank.visible = (new_tank.x > -0.5 * FlxG.width && new_tank.x < 1.2 * FlxG.width);

            if(new_tank.animation.curAnim.name == "run"){
                var speed:Float = (getState().conductor.songPosition - new_tank._.strumTime) * new_tank._.tankSpeed;
                
                if(new_tank.flipX){new_tank.x = (0.02 * FlxG.width - new_tank._.endingOffset) + speed;}
                else{new_tank.x = (0.74 * FlxG.width + new_tank._.endingOffset) - speed;}
            }else if(new_tank.animation.curAnim.finished){
                new_tank.kill();
				Timer.delay(function(){new_tank.destroy();}, 500);
            }
    
            if(getState().conductor.songPosition > new_tank._.strumTime){
                new_tank.animation.play('shot');
                if(new_tank.flipX){new_tank.offset.x = 300; new_tank.offset.y = 200;}
            }            
        }

        tanksGroup.add(new_tank);
    }
}

function beatHit(curBeat:Int):Void {
	if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
    watchtower.animation.play('idle');
    tank0.animation.play('idle');
    tank1.animation.play('idle');
    tank2.animation.play('idle');
    tank3.animation.play('idle');
    tank4.animation.play('idle');
    tank5.animation.play('idle');
}

function update(elapsed) {
    if(!PreSettings.getPreSetting("Background Animated", "Graphic Settings")){return;}
    tankAngle += elapsed * tankSpeed;
    tankrolling.angle = tankAngle - 90 + 15;
    tankrolling.x = 400 + (1000 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180)));
    tankrolling.y = 700 + (500 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180)));
}