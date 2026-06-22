package funkin.states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;

import funkin.backend.LanguageManager;

class LanguageState extends MusicBeatState
{
	var selected:Int = 0;
	var bg:FlxBackdrop;

	var langs:Array<String> = [
		"Português (Brasil)",
		"English"
	];

	var langIDs:Array<String> = [
		"pt-BR",
		"en-US"
	];

	var chat:FlxSprite;
	var benny:FlxSprite;
	var titleTxt:FlxText;
	var langTxt:FlxText;
	var confirmTxt:FlxText;

	override function create()
	{
		super.create();

		FunkinSound.playMusic(Paths.music('breakfast'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);

		bg = new FlxBackdrop(Paths.image('menus/language/checkeredBg'), XY);
		bg.antialiasing = true;
		bg.scrollFactor.set();
		bg.alpha = 0;
		add(bg);

		FlxTween.tween(bg, {alpha: 1}, 0.4, {
			ease: FlxEase.quartInOut
		});

		chat = new FlxSprite(-100, -50).loadAtlasFrames(Paths.getAtlasFrames('menus/language/chat'));
		chat.animation.addByPrefix("idle", "chat", 24, true);
		chat.animation.play("idle");
		chat.scale.set(0.65, 0.65);
		chat.updateHitbox();
		add(chat);

		benny = new FlxSprite(650, 50).loadAtlasFrames(Paths.getAtlasFrames('menus/language/benny'));
		benny.animation.addByPrefix("idle", "benny", 24, true);
		benny.animation.play("idle");
		benny.scale.set(0.65, 0.65);
		benny.updateHitbox();
		add(benny);

		titleTxt = new FlxText(60, 70, 500, "");
		titleTxt.setFormat(Paths.font("funkin.otf"), 36, FlxColor.BLACK, CENTER);
		add(titleTxt);

		langTxt = new FlxText(60, 170, 500, "");
		langTxt.setFormat(Paths.font("funkin.otf"), 36, FlxColor.BLACK, CENTER);
		add(langTxt);

		confirmTxt = new FlxText(60, 280, 500, "");
		confirmTxt.setFormat(Paths.font("funkin.otf"), 36, FlxColor.BLACK, CENTER);
		add(confirmTxt);

		updateLanguageText();
	}

	function updateLanguageText()
	{
		switch(selected)
		{
			case 0:
				titleTxt.text = "Escolha seu Idioma!";
				langTxt.text = "< " + langs[selected] + " >";
				confirmTxt.text = "Aperte ENTER para confirmar";

			case 1:
				titleTxt.text = "Choose your Language!";
				langTxt.text = "< " + langs[selected] + " >";
				confirmTxt.text = "Press ENTER to confirm";
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var scrollSpeed:Float = 50;
		bg.x -= scrollSpeed * elapsed;
		bg.y -= scrollSpeed * elapsed;

		if (FlxG.keys.justPressed.LEFT)
		{
			FunkinSound.play(Paths.sound('scrollMenu'));

			selected--;
			if (selected < 0)
				selected = langs.length - 1;

			updateLanguageText();
		}

		if (FlxG.keys.justPressed.RIGHT)
		{
			FunkinSound.play(Paths.sound('scrollMenu'));

			selected++;
			if (selected >= langs.length)
				selected = 0;

			updateLanguageText();
		}

		if (FlxG.keys.justPressed.ENTER)
		{
         FlxG.sound.play(Paths.sound('confirmMenu'));

         FlxFlicker.flicker(langTxt, 1, 0.1, false, true, function(flk:FlxFlicker) {
				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					FlxG.switchState(TitleState.new);

               ClientPrefs.language = langIDs[selected];
					LanguageManager.load(ClientPrefs.language);
				});
			});
		}
	}
}