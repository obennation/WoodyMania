package funkin.states;

import funkin.backend.FallbackState;
import funkin.states.editors.ChartConverterState;
import funkin.data.Chart.ChartFormat;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import funkin.backend.Difficulty;
import funkin.Mods;
import funkin.data.SongMetaData;
import funkin.states.editors.ChartEditorState;
import funkin.data.WeekData;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.data.*;
import funkin.objects.*;
import funkin.backend.LanguageManager;

// todo rewrite this its kinda messy and not that safe
class FreeplayState extends MusicBeatState
{
	public static var vocals:Null<FlxSound> = null;
	
	public var debugBG:FlxSprite;
	public var debugTxt:FlxText;
	
	public var songs:Array<FreeplaySong> = [];
	
	public var freeplayTabs:Array<FreeplayTab> = [];
	
	public static var currentTab:Int = 0;
	
	public var selector:FlxText;
	
	public static var curSelected:Int = 0;
	
	public var curDifficulty:Int = -1;
	
	public static var lastDifficultyName:String = '';

	var lastPortrait:String = "";
	var lastBG:String = "";
	public var portraitName:String = 'benny';
	
	var ostName:FlxText;
	public var blackBar:FlxSprite;
	public var scoreBG:FlxSprite;
	public var blackOst:FlxSprite;
	public var portrait:FlxSprite;
	public var scoreText:FlxText;
	public var diffText:FlxText;
	public var tabText:FlxText;
	public var tabHint:FlxText;
	public var lerpScore:Int = 0;
	public var lerpRating:Float = 0;
	public var intendedScore:Int = 0;
	public var intendedRating:Float = 0;
	
	public var grpSongs:FlxTypedGroup<Alphabet>;
	public var grpIcons:FlxTypedGroup<HealthIcon>;
	public var curPlaying:Bool = false;

	public var menuBG:FlxSprite;
	public var bg:FlxSprite;
	public var intendedColor:Int;
	
	var mayGoToChartConverter:Bool = false;
	
	override function create()
	{
		FunkinAssets.cache.clearStoredMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		
		DiscordClient.changePresence("In the Menus");
		
		loadFreeplayData();
		
		if (freeplayTabs.length == 0)
		{
			CoolUtil.setTransSkip(true, false);
			persistentUpdate = false;
			FlxG.switchState(() -> new FallbackState('Cannot load Freeplay as there are no tabs loaded.', () -> FlxG.switchState(MainMenuState.new)));
			return;
		}
		
		initStateScript();
		
		scriptGroup.set('SongMetadata', FreeplaySong); // backwards compat bs ig
		scriptGroup.set('FreeplaySong', FreeplaySong);
		scriptGroup.set('WeekData', WeekData);

		menuBG = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/menuBgs/normal'));
		add(menuBG);
		menuBG.screenCenter();
		
		bg = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/menuBgs/normal'));
		add(bg);
		bg.screenCenter();

		portrait = new FlxSprite(500, -200).loadGraphic(Paths.image('menus/freeplay/renders/', portraitName));
		portrait.scale.set(0.6, 0.6);
		add(portrait);

		blackBar = new FlxSprite(-200, -100).loadGraphic(Paths.image('menus/freeplay/blackFreeplayBar'));
		blackBar.alpha = 0.75;
		add(blackBar);
		
		scoreText = new FlxText(0, 65, FlxG.width - 6, "", 32);
		scoreText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, RIGHT);

		final scoreBGSize = 66 + 33 * (Math.min(freeplayTabs.length, 2));
		
		scoreBG = new FlxSprite(scoreText.x - 6, 60).makeScaledGraphic(1, scoreBGSize, 0xFF000000);
		scoreBG.alpha = 0.5;
		add(scoreBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		var blackOst = new FlxSprite(0, 0).makeGraphic(FlxG.width, 64, FlxColor.BLACK);
        add(blackOst);

		ostName = new FlxText(935, 12, FlxG.width - 4 - 4, LanguageManager.get("freeplay.ost"), 30);
        ostName.font = 'StatusPlz Regular';
		ostName.alpha = 0.5;
		add(ostName);
		
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		
		tabText = new FlxText(diffText.x, diffText.y + 28, 0, 24);
		tabText.font = scoreText.font;
		add(tabText);
		
		tabHint = new FlxText(tabText.x, tabText.y + 28, 0, 24);
		tabHint.font = scoreText.font;
		tabHint.text = LanguageManager.get("freeplay.tab");
		tabHint.color = FlxColor.GRAY;
		add(tabHint);
		
		if (freeplayTabs.length <= 1) tabHint.kill();
		
		if (freeplayTabs.length == 0) tabText.kill();
		
		add(scoreText);
		
		debugBG = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		debugBG.alpha = 0;
		add(debugBG);
		
		debugTxt = new FlxText(25, 0, FlxG.width - 50, '', 32);
		debugTxt.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		debugTxt.borderSize = 2;
		debugTxt.screenCenter(Y);
		add(debugTxt);
		
		WeekData.setDirectoryFromWeek();
		
		changeTab();
		
		changeDiff();
		
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		
		if (lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));
		
		super.create();
		scriptGroup.call('onCreate', []);
	}
	
	override function closeSubState()
	{
		changeSelection();
		persistentUpdate = true;
		super.closeSubState();
	}
	
	function createSongs()
	{
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 10, songs[i].displayName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			
			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}
			
			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			
			grpIcons.add(icon);
		}
		
		changeSelection();
	}
	
	public function addSong(songName:String, ?info:Array<Dynamic>, weekName:String = "")
    {
		var displayName:String = songName;
		var icon:String = "face";
		var color:String = "#8DA399";
		var portraitVar:String = portraitName;
		var bgVar:String = "normal";
		var portraitXVar:Float = 500;
        var portraitYVar:Float = -200;

		final meta = getSongMeta(songName);

		if (meta == null && info != null)
		{
			if (info[0] != null)
				displayName = info[0];

			if (info[1] != null)
				icon = info[1];

			if (info[2] != null)
				color = FlxColor.fromRGB(info[2][0], info[2][1], info[2][2]).toHexString();

			if (info.length > 3 && info[3] != null)
				portraitVar = info[3];
		}
		else if (meta != null)
		{
			if (meta.displayName != null)
				displayName = meta.displayName;

			if (meta.freeplayIcon != null)
				icon = meta.freeplayIcon;

			if (meta.freeplayColor != null)
				color = meta.freeplayColor;

			if (meta.portrait != null)
				portraitVar = meta.portrait;
			
			if (meta.freeplayBG != null)
				bgVar = meta.freeplayBG;

			if (meta.portraitX != null)
				portraitXVar = meta.portraitX;

			if (meta.portraitY != null)
				portraitYVar = meta.portraitY;
		}

		songs.push(new FreeplaySong(
			songName,
			displayName,
			portraitVar,
			bgVar,
			weekName,
			icon,
			FlxColor.fromString(color),
			portraitXVar,
			portraitYVar
		));
	}
	
	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		if (leWeek == null) return false;
		
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}
	
	var instPlaying:Int = -1;
	
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if (freeplayTabs.length == 0) return;
		
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));
		
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;
		
		var ratingSplit:Array<String> = Std.string(funkin.utils.MathUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}
		
		scoreText.text = LanguageManager.get("freeplay.score") + ': ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();
		
		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT) shiftMult = 3;
		
		if (freeplayTabs.length > 1)
		{
			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT) changeTab(-1);
				else changeTab(1);
				
				changeDiff();
				changeSelection();
			}
		}
		
		if (songs.length > 1)
		{
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}
			
			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
				
				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}
		}
		
		if (mayGoToChartConverter)
		{
			if (controls.ACCEPT)
			{
				FlxG.switchState(() -> new funkin.states.editors.ChartConverterState());
				ChartConverterState.goToFreeplay = true;
			}
			if (controls.BACK)
			{
				mayGoToChartConverter = false;
				changeSelection();
			}
			
			super.update(elapsed);
			return;
		}
		
		if (FlxG.keys.justPressed.SEVEN)
		{
			persistentUpdate = false;
			openSubState(new funkin.states.editors.SongMetaEditor(songs[curSelected].songName));
			return;
		}
		
		if (controls.UI_LEFT_P) changeDiff(-1);
		else if (controls.UI_RIGHT_P) changeDiff(1);
		else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDiff();
		
		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxTween.cancelTweensOf(bg, ['color']);
			
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(MainMenuState.new);
		}
		
		if (FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (FlxG.keys.justPressed.SPACE)
		{
			if (instPlaying != curSelected)
			{
				destroyFreeplayVocals();
				if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
				Mods.currentModDirectory = songs[curSelected].folder;
				PlayState.SONG = Chart.fromSong(songs[curSelected].songName, curDifficulty);
				
				// ??? why would you ever to do rewrite this
				if (PlayState.SONG.needsVoices) vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else vocals = new FlxSound();
				
				FlxG.sound.list.add(vocals);
				FunkinSound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
			}
		}
		else if (controls.ACCEPT)
		{
			persistentUpdate = false;
			
			final songName = Paths.sanitize(songs[curSelected].songName.toLowerCase());
			
			final songRet = PlayState.prepareForSong(songName, curDifficulty, false);
			
			if (songRet != null)
			{
				var error = songRet.toString();
				
				if (error.contains('incompatible format') && !error.contains(ChartFormat.UNKNOWN)) // scuffed method...
				{
					error += "\n\nIf you'd like to enter the chart converter press Accept.\nOtherwise, press Cancel to go back";
					mayGoToChartConverter = true;
				}
				
				final message = 'Failed to load song.\nException: $error';
				debugBG.alpha = 0.7;
				debugTxt.text = message;
				debugTxt.screenCenter(Y);
				
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				super.update(FlxG.elapsed);
				return;
			}
			
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			
			FlxTween.cancelTweensOf(bg, ['color']);
			
			if (FlxG.keys.pressed.SHIFT)
			{
				FlxG.switchState(ChartEditorState.new);
			}
			else
			{
				FlxG.switchState(PlayState.new);
			}
			
			if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
			
			destroyFreeplayVocals();
		}
		else if (controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		super.update(elapsed);
	}
	
	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}
	
	function loadFreeplayData()
	{
		var mods:Array<{folder:String, enabled:Bool}> = Mods.getListAsArray();
		
		for (i in mods)
		{
			if (!i.enabled) continue;
			
			var freeplayData = getFreeplayData(i.folder);
			Mods.currentModDirectory = i.folder;
			
			var tabs = freeplayData?.tabs ?? null;
			
			if (tabs == null)
			{
				var dir = FunkinAssets.readDirectory('content/${i.folder}/data/weeks');
				
				var fromWeeks = [];
				for (week in dir)
				{
					final sanitizedWeek = Paths.sanitize(week).replace('.json', '');
					fromWeeks.push(sanitizedWeek);
				}
				
				tabs = [];
				tabs.push(
					{
						title: i.folder,
						directory: i.folder,
						fromWeeks: fromWeeks,
						songs: [],
					});
			}
			
			for (tab in tabs){
				tab.directory = i.folder;
				freeplayTabs.push(tab);
			}
		}
	}
	
	function getSongMeta(song:String):Null<SongMetaData>
	{
		var path = SongMeta.getFromPath(Paths.json('$song/data/meta'));
		
		if (path == null) path = SongMeta.getFromPath(Paths.json('$song/meta'));
		
		return path;
	}
	
	function getFreeplayData(modFolder:String):Null<FreeplayData>
	{
		final freeplayDataPath = Paths.getPath('data/freeplay.json', modFolder, true);
		
		return FunkinAssets.exists(freeplayDataPath) ? FunkinAssets.parseJson5(FunkinAssets.getContent(freeplayDataPath)) : null;
	}
	
	function loadTab(tab:Int):Void
	{
		var tab = freeplayTabs[tab];
		if (tab.songs == null) tab.songs = [];
		
		if (tab.fromWeeks != null)
		{
			for (weekName in tab.fromWeeks)
			{
				if (weekIsLocked(weekName)) continue;
				
				var week:WeekData = WeekData.weeksLoaded[weekName];
				
				WeekData.setDirectoryFromWeek(week);
				
				// if week is null go to next item in loop
				if (week == null || (week.songs == null || week.songs.length <= 0)) continue;
				
				for (song in week.songs)
				{
					final name = Paths.sanitize(song[0]);
					final icon = song[1];
					final color = song[2];
					
					addSong(name, [name, icon, color]);
				}
			}
		} else 
			Mods.currentModDirectory = tab.directory; 
		for (song in tab.songs)
			addSong(song);
	}
	
	function changeDiff(change:Int = 0)
	{
		debugBG.alpha = 0;
		debugTxt.text = '';
		
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.difficulties.length - 1);
		
		lastDifficultyName = Difficulty.difficulties[curDifficulty];
		
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		
		PlayState.storyMeta.difficulty = curDifficulty;
		diffText.text = '< ' + Difficulty.getCurrentDifficultyString().toUpperCase() + ' >';
		positionHighscore();
	}
	
	function changeSelection(diff:Int = 0)
	{
		debugBG.alpha = 0;
		debugTxt.text = '';
		
		if (diff != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelected = FlxMath.wrap(curSelected + diff, 0, songs.length - 1);
		
		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			FlxTween.cancelTweensOf(bg, ['color']);
			intendedColor = newColor;
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}
		
		grpIcons.forEach((icon) -> icon.alpha = 0.6);
		grpIcons.members[curSelected].alpha = 1;
		
		for (idx => item in grpSongs.members)
		{
			item.targetY = idx - curSelected;
			
			item.alpha = 0.6;
			
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;

		var portraitPath = songs[curSelected].portrait;

	    if (portraitPath != lastPortrait)
	    {
	    	lastPortrait = portraitPath;

	    	portrait.loadGraphic(Paths.image('menus/freeplay/renders/' + portraitPath));

	        FlxTween.cancelTweensOf(portrait);
		    FlxTween.cancelTweensOf(portrait.scale);

		    portrait.scale.set(0.5, 0.5);

			portrait.x = songs[curSelected].portraitX;
            portrait.y = songs[curSelected].portraitY + 50;
		    portrait.alpha = 0.5;

		    FlxTween.tween(portrait, {
		    	y: songs[curSelected].portraitY,
		    	alpha: 1
		    }, 0.3, {
		    	ease: FlxEase.expoOut
		    });

	    	FlxTween.tween(portrait.scale, {
	    		x: 0.6,
	    		y: 0.6
	    	}, 0.3, {
	    		ease: FlxEase.expoOut
		    });
	    }

		var bgPath:String = songs[curSelected].bg;

		if (bgPath != lastBG)
		{
			lastBG = bgPath;

			bg.loadGraphic(Paths.image('menus/freeplay/menuBgs/' + bgPath));

			bg.screenCenter();

			bg.alpha = 0.5;

			FlxTween.cancelTweensOf(bg);

			FlxTween.tween(bg, {
				alpha: 1
			}, 0.35, {
				ease: FlxEase.quadOut
			});
		}
		
		Difficulty.reset();
		
		var songMeta = getSongMeta(songs[curSelected].songName);
		
		var weekDiffs:Array<String> = [];
		var songWeek = WeekData.weeksLoaded[songs[curSelected].week];
		if (songWeek != null) weekDiffs = songWeek.difficulties;
		
		if (songMeta != null && songMeta.difficulties != null)
		{
			Difficulty.difficulties = songMeta.difficulties;
		}
		else if (weekDiffs != null && weekDiffs.length > 0)
		{
			Difficulty.difficulties = weekDiffs;
		}
		
		if (Difficulty.difficulties.contains(Difficulty.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(Difficulty.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}
		
		var newPos:Int = Difficulty.difficulties.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
	}
	
	function changeTab(diff:Int = 0)
	{
		if (diff != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		var len = freeplayTabs.length - 1;
		if (len < 0) len = 0;
		
		currentTab = FlxMath.wrap(currentTab + diff, 0, len);
		tabText.text = "[ " + LanguageManager.get(freeplayTabs[currentTab].title ?? "unknown") + " ]";
		
		clearSongs();
		
		loadTab(currentTab);
		
		createSongs();
	}
	
	function clearSongs()
	{
		songs = [];
		
		if (grpSongs != null)
		{
			grpSongs.forEach(song -> song?.destroy());
			
			grpSongs.clear();
		}
		
		if (grpIcons != null)
		{
			grpIcons.forEach(icon -> icon?.destroy());
			
			grpIcons.clear();
		}
	}
	
	private function positionHighscore()
	{
		scoreBG.scale.x = scoreText.textField.textWidth + 12 + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.textField.textWidth / 2;
		tabText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		tabText.x -= tabText.textField.textWidth / 2;
		tabHint.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		tabHint.x -= tabHint.textField.textWidth / 2;
	}
}

class FreeplaySong
{
	public var displayName:String = "";
	public var songName:String = "";
	public var week:String = "";
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var portrait:String = "";
	public var bg:String = "normal";
	public var portraitX:Float = 500;
    public var portraitY:Float = -200;

	public function new(
		song:String,
		displayName:String,
		portrait:String,
		bg:String,
		week:String,
		songCharacter:String,
		color:Int,
		portraitX:Float = 500,
	    portraitY:Float = -200
	)
	{
		this.songName = song;
		this.displayName = displayName;
		this.portrait = portrait;
		this.bg = bg;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.portraitX = portraitX;
        this.portraitY = portraitY;

		this.folder = Mods.currentModDirectory;

		if (this.folder == null)
			this.folder = '';
	}
}

typedef FreeplayData =
{
	var tabs:Array<FreeplayTab>;
}

typedef FreeplayTab =
{
	var title:String;
	
	// if you load a mod freshly without any week jsons the currentModDirectory isn't set
	// you dont have to define this in the mod folder but like you can i guess
	var directory:String;
	
	var ?fromWeeks:Array<String>;
	var ?songs:Array<String>;
}