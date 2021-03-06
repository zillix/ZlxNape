package com.zillix.zlxnape.demos 
{
	import com.zillix.zlxnape.BodyContext;
	import org.flixel.FlxG;
	/**
	 * Demonstrates tentacles.
	 * Shows how they can follow an object, expand, and contract.
	 * @author zillix
	 */
	public class TentacleDemo extends ZlxNapeDemo 
	{
		private var _boss:Boss;
		public function TentacleDemo() 
		{
			super();
			
			_boss = new Boss(100, 10, _player, _background);
			_boss.createBody(25, 25, new BodyContext(_space, _bodyRegistry));
			add(_boss);
			
			
		}
		
		override protected function setUpPlayer() : void
		{
			_player = new Player(FlxG.width / 2, FlxG.height / 2);
			_player.createBody(20, 20, new BodyContext(_space, _bodyRegistry));
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
		
		override public function get instructionsText() : String
		{
			return super.instructionsText + "\nSpace: Extend" +
			"\nControl: Contract" +
			"\nARROWS: Move player" +
			"\nMouse: Move boss";
		}
		
	}

}