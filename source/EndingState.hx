package;

import flixel.FlxG;
import flixel.FlxSprite;

class EndingState extends MusicBeatState
{
       override function create()
       {
              var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image('EndCreds'));
              screen.antialiasing = true;
              screen.setGraphicSize(FlxG.width, FlxG.height);
              add(screen);

              super.create();
       }

       override function update(elapsed:Float)
       {
              super.update(elapsed);

              if (FlxG.keys.justPressed.ANY)
              {
                    MusicBeatState.switchState(new StoryMenuState());
                    FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
              }
       }
}