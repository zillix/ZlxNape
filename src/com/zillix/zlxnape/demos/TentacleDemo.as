package com.zillix.zlxnape.demos 
{
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author zillix
	 */
	public class TentacleDemo extends ZlxNapeDemo 
	{
		private var _boss:Boss;
		public function TentacleDemo() 
		{
			super();
			
			for (var i:int = 0; i < 200; i++)
			{
				spawnBox(Math.random() * FlxG.width, Math.random() * FlxG.height);
			}
			
			_boss = new Boss(100, 10, _space, _bodyRegistry, _player);
			add(_boss);
		}
		
		override protected function setUpPlayer() : void
		{
			_player = new Player(10, 10, _space, _bodyRegistry);
			add(_player);
		}
		
		override public function update() : void
		{
			super.update();
			
			if (FlxG.keys.justPressed("SPACE"))
			{
				_boss.extendSegment();
			}
			if (FlxG.keys.justPressed("CONTROL"))
			{
				_boss.withdrawSegment();
			}
		}
		
		override protected function get instructionsText() : String
		{
			return super.instructionsText + "\nSpace: Extend\nControl: Contract\nWASD: Move player";
		}
		
	}

}