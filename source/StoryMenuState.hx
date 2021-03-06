package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekUnlocked:Array<Bool> = [
		true,	//Tutorial
		true	//Licorice

	];

	//It works like this:
	// ['Left character', 'Center character', 'Right character']
	var weekCharacters:Array<Dynamic> = [
		['', '', ''],
		['', '', '']

	];

	//The week's name, displayed on top-right
	var weekNames:Array<String> = [
		"",
		"Rising Volume"

	];

	//Background asset name, the background files are stored on assets/preload/menubackgrounds/
	var weekBackground:Array<String> = [
		'bf',		
		'licor'

	];
	
	var scoreText:FlxText;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Main_Checker'), 0.5, 0.5, true, true);

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(0, 3, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 26);
		scoreText.screenCenter(X);
		scoreText.x = 510;
		scoreText.alignment = CENTER;

		txtWeekTitle = new FlxText(-70, 26, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		txtWeekTitle.screenCenter(X);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgSprite = new FlxSprite(0, 184);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var portraitsSprite:FlxSprite = new FlxSprite(0, bgSprite.y + 0).loadGraphic(Paths.image('portraits'));
		portraitsSprite.screenCenter(X);
		portraitsSprite.y = 0;
		add(portraitsSprite);

		add(checker);
        checker.scrollFactor.set(0, 0.07);

		var bordersSprite:FlxSprite = new FlxSprite(0, bgSprite.y + 0).loadGraphic(Paths.image('menuborders'));
		bordersSprite.screenCenter(X);
		bordersSprite.y = 0;
		add(bordersSprite);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (i in 0...WeekData.songsNames.length)
		{
			var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekThing.scale.set(0.75, 0.75);
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (i < weekUnlocked.length && !weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[0][char]);
			weekCharacterThing.y += -600;
			weekCharacterThing.antialiasing = ClientPrefs.globalAntialiasing;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + -20);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.x = 427;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		
		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 60, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficulty.screenCenter(X);
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(0, bgSprite.y + 35).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		tracksSprite.screenCenter(X);
		tracksSprite.x = 537;
		tracksSprite.y = 130;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.07, tracksSprite.y + 60, 0, "", 29);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		checker.x -= 0.45;
        checker.y -= 0.16;

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (curWeek >= weekUnlocked.length || weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.songsNames[curWeek];
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i]);
			}

			// I'm a motherfucking genious
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 15;
				FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.songsNames.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.songsNames.length - 1;

		var leName:String = '';
		if(curWeek < weekNames.length) {
			leName = weekNames[curWeek];
		}

		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.x -= 15;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
			{
				var newVarHere:Int = bullShit - curWeek;
				  if (newVarHere == Std.int(0) && weekUnlocked[curWeek])
					  item.alpha = 1;
				  else
					  item.alpha = 0.6;
				  bullShit++;
			  }

		var assetName:String = weekBackground[0];
		if(curWeek < weekBackground.length) assetName = weekBackground[curWeek];

		bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		bgSprite.y = 0;
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = weekCharacters[0];
		if(curWeek < weekCharacters.length) weekArray = weekCharacters[curWeek];

		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var stringThing:Array<String> = WeekData.songsNames[curWeek];

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = StringTools.replace(txtTracklist.text, '-', ' ');
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}
}
