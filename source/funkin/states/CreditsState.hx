package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import funkin.objects.*;
import funkin.backend.LanguageManager;

// safety and readability
abstract CreditsData(Array<String>) from Array<String>
{
	public var isTitle(get, never):Bool;
	
	function get_isTitle() return this.length <= 1;
	
	public var name(get, never):String;
	
	function get_name() return this[0] ?? '';
	
	public var iconPath(get, never):String;
	
	function get_iconPath() return this[1] ?? '';
	
	public var description(get, never):String;
	
	function get_description() return this[2] ?? '';
	
	public var link(get, never):String;
	
	function get_link() return this[3] ?? '';
	
	public var bgColour(get, never):FlxColor;
	
	function get_bgColour() return FlxColor.fromString(this[4] ?? 'WHITE') ?? FlxColor.WHITE;
	
	public var modDirectory(get, never):Null<String>;
	
	function get_modDirectory() return this[5];
}

// todo rewrite this menu

@:nullSafety
class CreditsState extends MusicBeatState
{
	@:unreflective
	var hardcodedCredits:Array<Array<String>> = [
		[LanguageManager.get("credits.woodymaniateam")],
		['bennation', 'bennation', LanguageManager.get("credits.bennation"), 'https://twitter.com/eobennation', '0xFF233DA9'],
		['gi', 'gi', LanguageManager.get("credits.gi"), 'https://twitter.com/gebyongaku', '0xFF53B7D8'],
		['J. Dumwell', 'jooj', LanguageManager.get("credits.joojdumwell"), 'https://twitter.com/JooJ_Dumwell99', '0xFFFFFFFF'],
		['AquelaAylaLa', 'ayla', LanguageManager.get("credits.aquelaaylala"), 'https://twitter.com/AquelaAylaLa', '0xFFFFFFFF'],
		['Spike', 'spk', LanguageManager.get("credits.spk"), 'https://x.com/SHdgehog', '0xFFFF9900'],
		['bren', 'brendon', LanguageManager.get("credits.bren"), '', '0xFF5A4736'],
		[''],
		[LanguageManager.get("credits.nightmarevisionteam")],
		['DuskieWhy', 'duskie', LanguageManager.get("credits.duskiewhy"), 'https://twitter.com/DuskieWhy', '0xA8324A'],
		['data5', 'data', LanguageManager.get("credits.data5"), 'https://x.com/_data5', '0xF9A250'],
		['NebulaZorua', 'neb', LanguageManager.get("credits.nebulazorua"), 'https://twitter.com/Nebula_Zorua', '0x9B00B3'],
		['JoggingScout', 'joggingscout', LanguageManager.get("credits.joggingscout"), 'https://twitter.com/JoggingScout', '0x3366CC'],
		['Iseta', 'iseta', LanguageManager.get("credits.iseta"), 'https://twitter.com/Isetaaaaa', '0x6ede0b']
	];
	
	var curSelected:Int = -1;
	var credits:Array<CreditsData> = [];
	
	var grpOptions:Null<FlxTypedGroup<Alphabet>> = null;
	
	var bg:Null<FlxSprite> = null;
	
	var descText:Null<FlxText> = null;
	var descBox:Null<AttachedSprite> = null;
	var descYOffset:Float = -75;
	
	override function create()
	{
		DiscordClient.changePresence("In the Menus");
		
		persistentUpdate = true;
		
		addModCredits(); // add the mod credits.. if there is any
		credits = credits.concat(hardcodedCredits); // then our credits
		
		initStateScript();
		
		bg = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		
		for (i in 0...credits.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, credits[i].name, credits[i].isTitle, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			optionText.changeAxis = Y;
			optionText.targetY = i;
			grpOptions.add(optionText);
			
			if (credits[i].isTitle) continue; // if its a title we dont need to worry about adding a icon
			
			if (credits[i].modDirectory != null)
			{
				@:nullSafety(Off) // but i checked if it was null... :(
				Mods.currentModDirectory = credits[i].modDirectory;
			}
			
			var icon:AttachedSprite = new AttachedSprite('branding/credits/${credits[i].iconPath}');
			icon.setGraphicSize(130);
			icon.updateHitbox();
			icon.xAdd = optionText.width + 10;
			icon.sprTracker = optionText;
			icon.copyVisible = false;
			icon.visible = Paths.fileExists('images/branding/credits/${credits[i].iconPath}.png');
			add(icon);
			
			Mods.currentModDirectory = '';
			
			if (curSelected == -1)
			{
				curSelected = i;
				bg.color = credits[i].bgColour;
			}
		}
		
		descBox = new AttachedSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);
		
		descText = new FlxText(50, FlxG.height + descYOffset - 25, 1180, "", 32);
		descText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);
		
		changeSelection();
		super.create();
		
		scriptGroup.call('onCreate');
	}
	
	var canInteract:Bool = true;
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if (canInteract)
		{
			if (credits.length > 1)
			{
				final moveMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;
				
				if (FlxG.mouse.wheel != 0)
				{
					changeSelection(-FlxG.mouse.wheel * moveMult);
					holdTime = 0;
				}
				
				if (controls.UI_UP_P)
				{
					changeSelection(-1 * moveMult);
					holdTime = 0;
				}
				
				if (controls.UI_DOWN_P)
				{
					changeSelection(1 * moveMult);
					holdTime = 0;
				}
				
				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
					
					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -moveMult : moveMult));
					}
				}
			}
			
			if (controls.ACCEPT && credits[curSelected].link.length > 4)
			{
				CoolUtil.browserLoad(credits[curSelected].link);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(MainMenuState.new);
				canInteract = false;
			}
		}
		
		if (grpOptions != null)
		{
			final lerpRate = FlxMath.getElapsedLerp(0.2, elapsed);
			for (item in grpOptions.members)
			{
				if (item.isBold) continue;
				
				final expectedX = (item.targetY == 0 ? ((FlxG.width - item.width) / 2) - 65 : 200 + -80 * Math.abs(item.targetY));
				item.x = FlxMath.lerp(item.x, expectedX, lerpRate);
				
				item.alpha = item.targetY == 0 ? 1 : 0.6;
			}
		}
		
		if (bg != null) bg.color = FlxColor.interpolate(bg.color, credits[curSelected].bgColour, FlxMath.getElapsedLerp(0.03, elapsed));
		super.update(elapsed);
	}
	
	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		do
			(curSelected = FlxMath.wrap(curSelected + change, 0, credits.length - 1))
		while (credits[curSelected].isTitle);
		
		if (grpOptions != null) for (idx => item in grpOptions.members)
			item.targetY = idx - curSelected;
			
		if (descText != null)
		{
			descText.text = credits[curSelected].description;
			descText.y = FlxG.height - descText.height + descYOffset - 60;
			
			FlxTween.cancelTweensOf(descText, ['y']);
			FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
			
			if (descBox != null)
			{
				descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
				descBox.updateHitbox();
			}
		}
	}
	
	function addModCredits():Void
	{
		#if MODS_ALLOWED
		final addedMods:Array<String> = [];
		for (folder in Mods.parseList().enabled)
		{
			if (addedMods.contains(folder)) continue;
			
			var creditsFile:String = (folder != null && folder.trim().length > 0) ? Paths.mods(folder + '/data/credits.txt') : Paths.mods('data/credits.txt');
			
			if (FileSystem.exists(creditsFile))
			{
				var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
				for (i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					if (arr.length >= 5) arr.push(folder);
					credits.push(arr);
				}
				credits.push(['']);
			}
			
			addedMods.push(folder);
		}
		#end
	}
}