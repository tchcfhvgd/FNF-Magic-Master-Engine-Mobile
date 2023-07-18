import("flixel.addons.ui.FlxUI", "FlxUI");
import("Alphabet");

function create():Void {
    var tabSelected:FlxUI = new FlxUI(null, getInstance());
    tabSelected.name = "Selected";

    var ttlModName:Alphabet = new Alphabet(28, 25, [{bold: true, scale: 0.6, text: mod.name}]);
    tabSelected.add(ttlModName);

    var lblModDesc:Alphabet = new Alphabet(28, ttlModName.y + ttlModName.height + 10, [{color: 0x000000, scale: 0.3, text: mod.description}]);
    tabSelected.add(lblModDesc);
    
    getInstance().addGroup(tabSelected);
    
    // ----------------------------------------------------------------- //
    
    var tabUnSelected:FlxUI = new FlxUI(null, getInstance());
    tabUnSelected.name = "UnSelected";

    var ttlModName:Alphabet = new Alphabet(28, 25, [{bold: true, scale: 0.4, text: mod.name}]);
    tabUnSelected.add(ttlModName);
    
    getInstance().addGroup(tabUnSelected);
}