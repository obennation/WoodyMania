package funkin.states.options;

import funkin.states.options.Option;

import funkin.backend.LanguageManager;

import flixel.FlxG;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = LanguageManager.get("options.visuals");
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence
		
		var option:Option = new Option(LanguageManager.get("visuals.hidehud"), LanguageManager.get("visuals.hidehud.text"), 'hideHud', BOOL, false);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.showratings"), LanguageManager.get("visuals.showratings.text"), 'showRatings', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.healthbaralpha"), LanguageManager.get("visuals.healthbaralpha.text"), 'healthBarAlpha', PERCENT, 1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.underlaytype"), LanguageManager.get("visuals.underlaytype.text"), 'underlayType', STRING, 'Lane Underlay', UnderlayType.toArray());
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.underlayalpha"), LanguageManager.get("visuals.underlayalpha.text"), 'underlayOpacity', PERCENT, 0);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("graphics.timebar"), LanguageManager.get("graphics.timebar.text"), 'timeBarType', STRING, LanguageManager.get("graphics.timeleft"),
		[LanguageManager.get("graphics.timeleft"), LanguageManager.get("graphics.timeelapsed"), LanguageManager.get("graphics.songname"), LanguageManager.get("graphics.disabled")]);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.scoretext"), LanguageManager.get("visuals.scoretext.text"), 'scoreZoom', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.camerazooms"), LanguageManager.get("visuals.camerazooms.text"), 'camZooms', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.flashinglights"), LanguageManager.get("visuals.flashinglights.text"), 'flashing', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.jumpghosts"), LanguageManager.get("visuals.jumpghosts.text"), 'jumpGhosts', BOOL, false);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("visuals.cameranotefollow"), LanguageManager.get("visuals.cameranotefollow.text"), 'camFollowsCharacters', BOOL, true);
		addOption(option);
		
		super();
	}
}
