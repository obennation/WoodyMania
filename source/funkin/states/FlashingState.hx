package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.backend.LanguageManager;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	
	var warnText:FlxText;
	
	override function create()
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnText = new FlxText(0, 0, FlxG.width, LanguageManager.get("flashlights.warntext"), 32);
		warnText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}
	
	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (!controls.BACK)
				{
					ClientPrefs.flashing = false;
					ClientPrefs.flush();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function(tmr:FlxTimer) {
							FlxG.switchState(TitleState.new);
						});
					});
				}
				else
				{
					ClientPrefs.flashing = true;
					ClientPrefs.flush();
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1,
						{
							onComplete: function(twn:FlxTween) {
								FlxG.switchState(TitleState.new);
							}
						});
				}
			}
		}
		super.update(elapsed);
	}
}
