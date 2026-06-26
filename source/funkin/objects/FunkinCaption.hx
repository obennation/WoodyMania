package funkin.objects;
import funkin.backend.LanguageManager;

typedef FunkinCaptionTimestamp =
{
	start: Float,
	end: Float
}

typedef FunkinCaptionData =
{
	timestamp: FunkinCaptionTimestamp,
	string: String,
	?y: Float
}

class FunkinCaption extends flixel.group.FlxSpriteGroup
{
	public var string(get, set):String;
	
	public var bg:FlxSprite;
	public var text:FlxText;
	
	public var timestamp:Null<FunkinCaptionTimestamp>;
	
	public function new(?data:FunkinCaptionData, defaultY:Float = 500)
	{
		super();
		
		bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xaa000000);
		text = new FlxText(10, 0);
		
		add(bg);
		add(text);
		
		set(data?.string, data?.y ?? defaultY, data?.timestamp);
	}

	public function set(string:String = '', y:Float, ?timestamp:FunkinCaptionTimestamp):FunkinCaption
	{
		this.y = y;
		this.timestamp = timestamp;
		
		text.text = LanguageManager.get(string);
		text.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		
		return recalculate();
	}
	
	public inline function recalculate():FunkinCaption
	{
		bg.setGraphicSize(Std.int(text.width + 20), Std.int(text.height));
		bg.updateHitbox();
		
		bg.x = this.x = Math.round((FlxG.width - bg.width) * .5);
		text.x = (this.x + 10);
		
		return this;
	}
	
	function get_string():String return text.text;
	function set_string(string:String):String return text.text = string;
	
	public static function srtTimecodeToSeconds(timecode:String):Float
	{
		timecode = timecode.trim();
		
		final measure:Array<String> = timecode.split(',');
		
		if (measure.length < 2) throw 'Invalid SRT timecode "$timecode"';
		
		final times:Array<Int> = [
			for (time in measure[0].split(':'))
			{
				final time:Null<Int> = Std.parseInt(time);
				
				if (time == null) throw 'Invalid SRT timecode "$timecode"';
				
				time;
			}
		];
		final ms:Int = Std.parseInt(measure[1]);
		
		if (times.length < 3) throw 'Invalid SRT timecode "$timecode"';
		
		return (times[0] * 3600 + times[1] * 60 + times[2] + ms / 1000);
	}
	
	public static function parseSrt(srt:String):Array<FunkinCaptionData>
	{
		final data:Array<FunkinCaptionData> = [];
		
		var entries:Array<String> = srt.replace('\r', '').trim().split('\n\n');
		
		for (entry in entries)
		{
			var lines:Array<String> = entry.trim().split('\n');
			
			final index:Null<Int> = Std.parseInt(lines[0]);
			if (index == null) throw 'Invalid SRT entry\n"$entry"';
			
			final timecodes:Array<String> = lines[1].split(' --> ');
			final timestamp:FunkinCaptionTimestamp =
			{
				start: srtTimecodeToSeconds(timecodes[0]),
				end: srtTimecodeToSeconds(timecodes[1])
			};
			
			final sub:String = [for (i in 2 ... lines.length) if (lines[i].length > 0) lines[i]].join('\n');
			
			data.push({
				timestamp: timestamp,
				string: sub
			});
		}
		
		return data;
	}
}

class FunkinCaptionGroup extends flixel.group.FlxGroup.FlxTypedGroup<FunkinCaption>
{
	var _queue:Array<FunkinCaption> = [];
	
	public var playing:Bool = false;
	public var time:Float = 0;
	
	public var defaultY:Float;
	
	public var cleanup:Bool = true;
	
	public function new(defaultY:Float = 650)
	{
		super();
		
		this.defaultY = defaultY;
	}
	
	public function queue(caption:FunkinCaption):FunkinCaption
	{
		if (caption.timestamp == null) throw 'caption has no timestamp';
		
		for (i => member in _queue)
		{
			if (caption.timestamp.start < member.timestamp.start)
			{
				_queue.insert(i, caption);
				return caption;
			}
		}
		
		_queue.push(caption);
		return caption;
	}
	
	public function dequeue(caption:FunkinCaption):FunkinCaption
	{
		_queue.remove(caption);
		return caption;
	}
	
	public function empty():FunkinCaptionGroup
	{
		if (cleanup)
		{
			for (caption in _queue) caption.destroy();
			for (caption in members) caption.destroy();
		}
		
		_queue.resize(0);
		clear();
		
		return this;
	}
	
	public override function update(elapsed:Float):Void
	{
		if (playing) time += elapsed;
		
		if (_queue.length > 0 && time >= _queue[0].timestamp.start)
		{
			var caption = _queue[0];

			PlayState.instance.showSubtitle(
				caption.string,
				caption.timestamp.end - caption.timestamp.start
			);

			_queue.remove(caption);

			if (cleanup)
				caption.destroy();
		}
		
		super.update(elapsed);
	}
	
	public override function destroy():Void
	{
		empty();
		
		super.destroy();
	}
	
	public inline function preload(captions:Array<FunkinCaptionData>):Void
	{
		for (caption in captions) queue(new FunkinCaption(caption, defaultY));
	}
}