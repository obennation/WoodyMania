package funkin.states.options;

import flixel.FlxG;

import funkin.backend.LanguageManager;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = LanguageManager.get("options.gameplaysettings");
		rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence
		
		var option:Option = new Option(LanguageManager.get("gameplay.mechanics"), LanguageManager.get("gameplay.mechanics.text"), 'mechanics', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.modcharts"), LanguageManager.get("gameplay.modcharts.text"), 'modcharts', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.downscroll"), LanguageManager.get("gameplay.downscroll.text"), 'downScroll', BOOL, false);
		addOption(option);
		
		// var option:Option = new Option('Middlescroll', '[IS NOT FUNCTIONAL AS OF NOW]\nIf checked, your notes get centered.', 'middleScroll', 'bool', false);
		// addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.ghosttapping"), LanguageManager.get("gameplay.ghosttapping.text"), 'ghostTapping', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.disablereset"), LanguageManager.get("gameplay.disablereset.text"), 'noReset', BOOL, false);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.hitsoundvolume"), LanguageManager.get("gameplay.hitsoundvolume.text"), 'hitsoundVolume', PERCENT, 0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;
		
		var option:Option = new Option(LanguageManager.get("gameplay.ratingoffset"), LanguageManager.get("gameplay.ratingoffset.text"), 'ratingOffset', INT, 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("gameplay.epicratings"), LanguageManager.get("gameplay.epicratings.text"), 'useEpicRankings', BOOL, true);
		addOption(option);
		
		// Display Name, Variable (in ClientPrefs), Minimum Valeu, Maximum Value, Scroll Speed (when holding down Left/Right)
		addHitWindowOption("Epic!", "epicWindow", 15.0, 22.5, 15);
		addHitWindowOption("Sick!", "sickWindow", 15.0, 45.0, 30);
		addHitWindowOption("Good", "goodWindow", 15.0, 90.0, 60);
		addHitWindowOption("Bad", "badWindow", 15.0, 135.0, 90);
		
		// this is usually 166.67 - AKA: Shit Window
		// i won't change this to be an actual Shit window because it'd break too much to be worth it
		var option:Option = new Option(LanguageManager.get("gameplay.safeframes"), LanguageManager.get("gameplay.safeframes.text"), 'safeFrames', FLOAT, 10);
		option.scrollSpeed = 5;
		option.minValue = 2.0;
		option.maxValue = 10.0;
		option.changeValue = 0.1;
		addOption(option);
		
		super();
	}
	
	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
	
	function addHitWindowOption(dName:String, prefID:String, min:Float = 15.0, max:Float = 200.0, scrollSpeed:Float = 15)
	{
		var option:Option = new Option('$dName ' + LanguageManager.get("gameplay.hitwindow"), LanguageManager.get("gameplay.hitwindow1.text") + ' $dName ' + LanguageManager.get("gameplay.hitwindow2.text"), prefID, FLOAT, max);
		option.displayFormat = '%vms';
		option.scrollSpeed = scrollSpeed;
		option.minValue = min;
		option.maxValue = max;
		option.changeValue = 0.1;
		addOption(option);
	}
}
