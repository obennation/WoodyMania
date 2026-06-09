package funkin.states.options;

import funkin.backend.LanguageManager;

using StringTools;

class MiscSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = LanguageManager.get("options.misc");
		rpcTitle = 'Miscellaneous Menu'; // for Discord Rich Presence

		var option:Option = new Option(LanguageManager.get("misc.language"), LanguageManager.get("misc.language.text"), 'language', STRING, 'en-US', ['en-US', 'pt-BR']);
		option.onChange = function()
	    {
    		funkin.backend.LanguageManager.load(ClientPrefs.language);
    		FlxG.resetState();
		}
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("misc.nmvsplash"), LanguageManager.get("misc.nmvsplash.text"), 'toggleSplashScreen', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("misc.devmode"), LanguageManager.get("misc.devmode.text"), 'inDevMode', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("misc.streamedsongfiles"), LanguageManager.get("misc.streamedsongfiles.text"),'streamedMusic', BOOL, false);
		addOption(option);
		
		var pause:Option = new Option(LanguageManager.get("misc.autopause"), LanguageManager.get("misc.autopause.text"), 'autoPause', BOOL,
			false);
		pause.onChange = () -> {
			FlxG.autoPause = ClientPrefs.autoPause;
		};
		addOption(pause);
		
		super();
	}
}
