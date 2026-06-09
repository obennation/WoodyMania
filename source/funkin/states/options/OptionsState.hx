package funkin.states.options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;

import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;

import funkin.backend.LanguageManager;

class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;
	
	var options:Array<String> = [
		'notes',
		'controls',
		'adjustdelay',
		'graphics',
		'visuals',
		'gameplay',
		"misc"
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

    var justLeftSubState = false;
	
	public function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'notes':
				openSubState(new funkin.states.options.NoteSettingsSubState());
			case 'controls':
                final gamepad = FlxG.gamepads.getFirstActiveGamepad();
				openSubState(new funkin.states.options.ControlsSubState(gamepad != null ? Gamepad(gamepad.id) : Keys));
			case 'graphics':
				openSubState(new funkin.states.options.GraphicsSettingsSubState());
			case 'visuals':
				openSubState(new funkin.states.options.VisualsUISubState());
			case 'gameplay':
				openSubState(new funkin.states.options.GameplaySettingsSubState());
			case 'misc':
				openSubState(new funkin.states.options.MiscSubState());
			case 'adjustdelay':
				FlxG.switchState(funkin.states.options.NoteOffsetState.new);
		}
	}
	
	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	
	override function create()
	{
		DiscordClient.changePresence("Options Menu");
		
		initStateScript();
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		
		bg.screenCenter();
		add(bg);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		
		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			var optionText:Alphabet = new Alphabet(0, 0, LanguageManager.get('options.' + options[i]), true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
		
		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);
		
		changeSelection();
		
		super.create();
		
		scriptGroup.call('onCreate', []);
	}
	
	override function closeSubState()
	{
		ClientPrefs.flush();
		
		super.closeSubState();
        justLeftSubState = true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		
		if (controls.BACK && !justLeftSubState)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				FlxG.switchState(PlayState.new);
				FlxG.sound.music.volume = 0;
			}
			else FlxG.switchState(MainMenuState.new);
		}
		
		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
		}
		
		scriptGroup.call('onUpdatePost', [elapsed]);
        justLeftSubState = false;
	}
	
	function changeSelection(diff:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + diff, 0, options.length - 1);
		
		if (scriptGroup.call('onChangeSelection', [curSelected]) == ScriptConstants.STOP_FUNC) return;
		
		for (idx => item in grpOptions.members)
		{
			item.targetY = idx - curSelected;
			
			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
