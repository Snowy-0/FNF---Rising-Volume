package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf') {
		if(character == this.character) return;
	
		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;

		switch(character) {
			case 'bf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_BF');
				animation.addByPrefix('idle', "M BF Idle", 24);
				animation.addByPrefix('confirm', 'M bf HEY', 24, false);

			case 'bf2':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_BF2');
				animation.addByPrefix('idle', "bf", 24);

			case 'gf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_GF');
				animation.addByPrefix('idle', "M GF Idle", 24);

			case 'dad':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Dad');
				animation.addByPrefix('idle', "M Dad Idle", 24);

			case 'spooky':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Spooky_Kids');
				animation.addByPrefix('idle', "M Spooky Kids Idle", 24);

			case 'pico':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Pico');
				animation.addByPrefix('idle', "M Pico Idle", 24);

			case 'mom':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Mom');
				animation.addByPrefix('idle', "M Mom Idle", 24);

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Parents');
				animation.addByPrefix('idle', "M Parents Idle", 24);

			case 'senpai':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Senpai');
				animation.addByPrefix('idle', "M Senpai Idle", 24);

			case 'licorice':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Licorice');
				animation.addByPrefix('idle', 'Idle', 24);
		}
		animation.play('idle');
		updateHitbox();

		switch(character) {
			case 'bf':
				offset.set(15, -40);

			case 'bf2':
				offset.set(5, 10);

			case 'gf':
				offset.set(0, -25);

			case 'licorice':
				offset.set(160, 180);
				scale.set(0.5, 0.5);
		}
	}
}
