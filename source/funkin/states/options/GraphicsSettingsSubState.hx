package funkin.states.options;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

import funkin.backend.DebugDisplay;
import funkin.backend.LanguageManager;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = LanguageManager.get("options.graphics");
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence
		
		var option:Option = new Option(LanguageManager.get("graphics.gpucaching"), LanguageManager.get("graphics.gpucaching.text"), 'gpuCaching', BOOL, false);
		addOption(option);
		
		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option(LanguageManager.get("graphics.lowquality"), LanguageManager.get("graphics.lowquality.text"), 'lowQuality', 'bool', false);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("graphics.shaders"), LanguageManager.get("graphics.shaders.text"), 'shaders', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("graphics.antialiasing"), LanguageManager.get("graphics.antialiasing.text"), 'globalAntialiasing', BOOL, true);
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("graphics.debugdisplaytype"), LanguageManager.get("graphics.debugdisplaytype.text"), 'fpsDisplayType', STRING, LanguageManager.get("graphics.simple"), [LanguageManager.get("graphics.simple"), LanguageManager.get("graphics.advanced"), LanguageManager.get("graphics.disabled")]);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("graphics.framerate"), LanguageManager.get("graphics.framerate.text"), 'framerate', INT, 60);
		addOption(option);
		
		option.minValue = 60;
		option.maxValue = 400;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		
		var option:Option = new Option(LanguageManager.get("graphics.unlockedfps"), LanguageManager.get("graphics.framerate.text"), 'unlockedFramerate', 'bool', false);
		addOption(option);
		
		option.onChange = onChangeFramerate;
		
		super();
	}
	
	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				(cast sprite : FlxSprite).antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
		
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
	}
	
	function onChangeFramerate()
	{
		ClientPrefs.changeFps(ClientPrefs.framerate);
	}
}
