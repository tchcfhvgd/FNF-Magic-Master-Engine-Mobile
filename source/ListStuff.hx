package;

import flixel.graphics.frames.FlxAtlasFrames;
#if windows
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;

using StringTools;

class Songs{
	public static var listSongs:Array<Dynamic> = [];

	#if windows
	public static function loadList(){
		var music = [];
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs"))){
            if(!i.contains(".")){
                music.push(i);
            }
        }

		for (i in music){
            var nSong = StringTools.replace(i, "_", " ");
            ListStuff.Songs.addSong(nSong);

            for(t in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs/${i}/Audio'))){
                if(t.endsWith(Paths.SOUND_EXT)){
                    var archive = t.replace("." + Paths.SOUND_EXT,"");
                    ListStuff.Songs.addAudioFile(nSong, archive, Paths.getPath(i + "/Audio/" + t, SOUND, "songs"));
                    trace(archive + " founded for " + nSong + ": " + Paths.getPath(i + "/Audio/" + t, SOUND, "songs"));
                }
            }

            for(h in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs/${i}/Data'))){
                if(h.endsWith(".json")){
                    var archive = h.replace(".json", "");
                    ListStuff.Songs.addChartFile(nSong, archive, Paths.getPath(i + "/Data/" + h, TEXT, "songs"));
                    trace(archive + " founded for " + nSong + ": " + Paths.getPath(i + "/Data/" + h, TEXT, "songs"));
                }else{
                    var archive = h.split('.');
                    ListStuff.Songs.addStuffFile(nSong, archive[0], Paths.getPath(i + "/Data/" + h, TEXT, "songs"));
                    trace(archive[0] + " founded for " + nSong + ": " + Paths.getPath(i + "/Data/" + h, TEXT, "songs"));
                }
            }
        }
	}
	#end

	public static function checkName(id:Int){
		return listSongs[id][0];
	}

	public static function checkAudios(fname:String){
		var toReturn = [];
		for(i in listSongs){
			if(i[0] == fname){
				toReturn = i[1];
			}
		}
		return toReturn;
	}

	public static function checkCharts(fname:String){
		var toReturn = [];
		for(i in listSongs){
			if(i[0] == fname){
				toReturn = i[2];
			}
		}
		return toReturn;
	}

	public static function checkStuffs(fname:String){
		var toReturn = [];
		for(i in listSongs){
			if(i[0] == fname){
				toReturn = i[3];
			}
		}
		return toReturn;
	}

	public static function getAudioPath(name:String, song:String){
		var toReturn = "";
		var audios = Songs.checkAudios(song);

		for(audio in audios){
			if(audio[0] == name){
				toReturn = audio[1];
			}
		}

		return toReturn;
	}

	public static function getSongAudioPath(name:String, song:String, cat:String,  ?isSingle:Bool = false, ?id:Int = 0){
		var toReturn = "";
		var audios = Songs.checkAudios(song);

		if(isSingle){
			var hasVoice = false;
			for(audio in audios){
				if(audio[0] == id + "-" + name + "Voices-" + cat){
					hasVoice = true;
					toReturn = audio[1];
				}
			}

			if(!hasVoice){
				for(audio in audios){
					if(audio[0] == id + "-DEFAULTVoices-" + cat){
						toReturn = audio[1];
					}
				}
			}
		}else{
			for(audio in audios){
				if(audio[0] == name + "-" + cat){
					toReturn = audio[1];
				}
			}
		}

		return toReturn;
	}

	public static function getChartPath(json:String, song:String){
		var toReturn:String = "";
		var charts = Songs.checkCharts(song);

		for(chart in charts){
			if(chart[0] == json){
				toReturn = Std.string(chart[1]);
			}
		}

		return toReturn;
	}

	public static function getStuffPath(thing:String, song:String){
		var toReturn = "";
		var stuffs = Songs.checkStuffs(song);

		for(stuff in stuffs){
			if(stuff[0] == thing){
				toReturn = stuff[1];
			}
		}

		return toReturn;
	}

	public static function addSong(fname:String){
		var hSong = false;
		for(i in listSongs){
			if(i[0] == fname){
				hSong = true;
			}
		}

		if(!hSong){
			listSongs.push([fname, [], [], []]);
			trace(fname + " Created");
		}else{
			trace(fname + " is already Created");
		}
	}

	public static function addAudioFile(song:String, archive:String, path:String){
		for(i in listSongs){
			if(i[0] == song && !i[1].contains(archive)){
				i[1].push([archive, path]);
			}
		}
	}

	public static function addChartFile(song:String, archive:String, path:String){
		for(i in listSongs){
			if(i[0] == song && !i[2].contains(archive)){
				i[2].push([archive, path]);
			}
		}
	}

	public static function addStuffFile(song:String, archive:String, path:String){
		for(i in listSongs){
			if(i[0] == song && !i[3].contains(archive)){
				i[3].push([archive, path]);
			}
		}
	}
}

class Characters{
	public static var listCharacters:Array<Dynamic> = [];

	#if windows
	public static function loadList(){
		var characters = [];

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/characters"))){
            if(!i.contains(".")){
                characters.push(i);
            }
        }

		for (i in characters){
            var nChar = StringTools.replace(i , "_", " ");
            ListStuff.Characters.addCharacter(nChar);

            for (t in FileSystem.readDirectory(FileSystem.absolutePath('assets/characters/${i}/Sprites'))){
                if(t.endsWith(".png")){
                    var archive = t.replace(".png", "");
                    ListStuff.Characters.addSpriteFile(nChar, archive, Paths.getPath(i + "/Sprites/" + t, IMAGE, "characters"));
                    trace(archive + " founded for " + nChar + ": " + Paths.getPath(i + "/Sprites/" + t, IMAGE, "characters"));
                }else{
                    var archive = t.split('.');
                    ListStuff.Characters.addStuffFile(nChar, archive[0], Paths.getPath(i + "/Sprites/" + t, TEXT, "characters"));
                    trace(archive[0] + " founded for " + nChar + ": " + Paths.getPath(i + "/Sprites/" + t, TEXT, "characters"));
                }
            }

            for (h in FileSystem.readDirectory(FileSystem.absolutePath('assets/characters/${i}/Skins'))){
                if(h.endsWith(".json")){
                    var archive = h.replace(".json", "");
                    ListStuff.Characters.addSkinFile(nChar, archive, Paths.getPath(i + "/Skins/" + h, TEXT, "characters"));
                    trace(archive + " founded for " + nChar + ": " + Paths.getPath(i + "/Skins/" + h, TEXT, "characters"));
                }
            }
        }
	}
	#end

	public static function checkName(id:Int){
		return listCharacters[id][0];
	}

	public static function checkStuff(fname:String){
		var toReturn = [];
		for(i in listCharacters){
			if(i[0] == fname){
				toReturn = i[3];
			}
		}
		return toReturn;
	}

	public static function checkSprites(fname:String){
		var toReturn = [];
		for(i in listCharacters){
			if(i[0] == fname){
				toReturn = i[1];
			}
		}
		return toReturn;
	}

	public static function checkSkins(fname:String){
		var toReturn = [];
		for(i in listCharacters){
			if(i[0] == fname){
				toReturn = i[2];
			}
		}
		return toReturn;
	}

	public static function getSkinPath(json:String, char:String){
		var toReturn = "";
		var sJson = json.split('-');

		var skins = Characters.checkSkins(char);

		var hasSkin = false;
		for(i in 0...2){
			for(skin in skins){
				if(i == 0 && skin[0] == json || i == 1 && !hasSkin && skin[0] == sJson[0] + "-" + sJson[1] + "-Default"){
					hasSkin = true;
					toReturn = skin[1];
					trace("Returned Path:" + skin[1]);
				}
			}
		}

		if(!hasSkin){
			toReturn = skins[0][1];
			trace("Returned Default Path:" + skins[0][1]);
		}

		return toReturn;
	}

	public static function getSpritePath(image:String, char:String){
		var toReturn = "";
		var sprites = Characters.checkSprites(char);

		for(sprite in sprites){
			if(sprite[0] == image){
				toReturn = sprite[1];
			}
		}

		return toReturn;
	}

	public static function getStuffPath(thing:String, char:String){
		var toReturn = "";
		var stuffs = Characters.checkStuff(char);

		for(stuff in stuffs){
			if(stuff[0] == thing){
				toReturn = stuff[1];
			}
		}

		return toReturn;
	}

	public static function getAtlas(image:String, stuff:String){
		var toReturn;

		if(stuff.endsWith('.xml')){
			toReturn = FlxAtlasFrames.fromSparrow(image, stuff);
		}else{
			toReturn = FlxAtlasFrames.fromSpriteSheetPacker(image, stuff);
		}
		return toReturn;
	}

	public static function addCharacter(fname:String){
		var hChar = false;
		for(i in listCharacters){
			if(i[0] == fname){
				hChar = true;
			}
		}

		if(!hChar){
			listCharacters.push([fname, [], [], []]);
			trace(fname + " Added");
		}else{
			trace(fname + " is already added");
		}
	}

	public static function addSpriteFile(char:String, archive:String, path:String){
		for(i in listCharacters){
			if(i[0] == char && !i[1].contains(archive)){
				i[1].push([archive, path]);
			}
		}
	}

	public static function addSkinFile(char:String, archive:String, path:String){
		for(i in listCharacters){
			if(i[0] == char && !i[2].contains(archive)){
				i[2].push([archive, path]);
			}
		}
	}

	public static function addStuffFile(char:String, archive:String, path:String){
		for(i in listCharacters){
			if(i[0] == char && !i[3].contains(archive)){
				i[3].push([archive, path]);
			}
		}
	}
}

class Skins {
	public static var curSkinsArray:Array<Dynamic> = [];
    public static var allSkinsArray:Array<Dynamic> = [];

    public static function getLibrarySkins(){
        allSkinsArray = FlxG.save.data.unlockedSkins;
        trace('Skins Library:\n ${allSkinsArray}');
        return allSkinsArray;
    }

    public static function getCharSkins(char:String){
        curSkinsArray = FlxG.save.data.unlockedSkins;
        var toReturn = ['Default'];

        for(i in 0...curSkinsArray.length){
            if(curSkinsArray[i][0] == char){
                toReturn = curSkinsArray[i][1];
                trace('List of Skins for ${char}: ${toReturn}');
            }
        }

		return toReturn;
    }

	public static function getSkin(char:String){
		curSkinsArray = FlxG.save.data.characterSkins;
		var toReturn = 'Default';

		for(i in 0...curSkinsArray.length){
			if(curSkinsArray[i][0] == char){
				toReturn = curSkinsArray[i][1];
			}
		}

		trace('Current Skin for ${char}: ${toReturn}');
        return toReturn;
	}

    public static function setSkin(char:String, skin:String){
        curSkinsArray = FlxG.save.data.characterSkins;

        var isCharFile = false;
        for(i in 0...curSkinsArray.length){
            if(curSkinsArray[i][0] == char){
                isCharFile = true;
                if(curSkinsArray[i][1] == skin){
                    trace('Selected Skin');
                }else{
                    curSkinsArray[i][1] = skin;
                    trace('Pushed ' + skin + ' to ' + char);
                }               
            }
        }

        if(!isCharFile){
            curSkinsArray.push([char, skin]);
            trace('File created for ${char} with the following skin: ${skin}');
        }
        
        FlxG.save.data.characterSkins = curSkinsArray;
        trace(char + ' file Saved');
    }

    public static function addCharSkin(char:String, skin:String){
        allSkinsArray = FlxG.save.data.unlockedSkins;

        var isCharFile = false;
        for(i in 0...allSkinsArray.length){
            if(allSkinsArray[i][0] == char){
                isCharFile = true;
                curSkinsArray = allSkinsArray[i][1];
                if(!curSkinsArray.contains(skin)){
                    curSkinsArray.push(skin);
                    allSkinsArray[i][1] = curSkinsArray;

                    trace('Pushed ' + skin + ' to ' + char + '\n
                    Character Skins: ' + allSkinsArray[i]);
                }
            }
        }

        if(!isCharFile){
            allSkinsArray.push([char, ['', skin]]);
            trace('Created file to ${char} and added skin ${skin}');
        }
        
        FlxG.save.data.unlockedSkins = allSkinsArray;
        trace('${char} file Saved');
    }

    public static function resetSkins(){
        FlxG.save.data.unlockedSkins =
			[
				['Boyfriend', ['Default', 'Tiger']],
				['Boyfriend Militar', ['Default', 'Og', 'Mii', 'SUS']]
			];   

        allSkinsArray = FlxG.save.data.unlockedSkins;
        
        trace('Rebooted skin file: \n ${allSkinsArray}');
    }

}