package com.zillix.zlxnape.demos 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.renderers.BlurRenderer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import nape.constraint.Constraint;
	import nape.constraint.PivotJoint;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import nape.phys.Material;
	import org.flixel.FlxGroup;
	import nape.phys.BodyType;
	import flash.utils.getTimer;
	import org.flixel.*;
	/**
	 * A submarine with a tube attached.
	 * Restructs the players movement and demonstrates BodyChain.
	 * Can extend segments.
	 * Originally built for respire: http://ludumdare.com/compo/ludum-dare-32/?action=preview&uid=2460
	 * @author zillix
	 */
	public class BreathingTube extends ZlxNapeSprite
	{
		[Embed(source = "data/tubeSegment.png")]	public var SegmentSprite:Class;
		[Embed(source = "data/submarine.png")]	public var SubmarineSprite:Class;
		
		private static const SEGMENT_WIDTH:int = 8;
		private static const SEGMENT_HEIGHT:int = 16;
		private static const MAX_SEGMENTS:int = 100;
		private static const STARTING_SEGMENTS:int = 7;
		private static const SEGMENT_COLOR:uint = 0xffdddddd;
		
		private var _desiredChainLength:int = STARTING_SEGMENTS;
		private var _nextChainSpawnTime:int = 0;
		private static const CHAIN_SPAWN_FREQ:Number = .1;
			
		
		private var _tubeLayer:FlxGroup;
		
		private var _playerJoint:Constraint;
		private var _player:Player;
		
		private var _chain:BodyChain;
		
		private var _initialSegmentMass:Number = 0;
		private static const LOWER_SEGMENT_MASS_MATERIAL:Material = new Material(0, 0, 0, 2);
		private static const LOWER_SEGMENT_MASS_FRAC:Number = .5;
		private static const NORMAL_SEGMENT_MASS_MATERIAL:Material = new Material(0, 0, 0, 6);
		
		
		private static const SUB_COLOR:uint = 0xffffff00;
		public function BreathingTube(X:Number, Y:Number, TubeLayer:FlxGroup, player:Player, Context:BodyContext)
		{
			super(X, Y);
			loadGraphic(SubmarineSprite);
			scale.x = scale.y = 2;
			createBody(2, 2, Context, BodyType.STATIC);
			
			_tubeLayer = TubeLayer;
			_player = player;
			
			_chain = new BodyChain(this,
				getEdgeVector(DIRECTION_RIGHT), 
				_tubeLayer,
				Context,
				MAX_SEGMENTS,
				SEGMENT_WIDTH,
				SEGMENT_HEIGHT,
				SEGMENT_COLOR,
				1,
				2);
				
			_chain.segmentSpriteClass = SegmentSprite;
			_chain.fluidMask = ~InteractionGroups.NO_COLLIDE;
				
			_chain.segmentMaterial = NORMAL_SEGMENT_MASS_MATERIAL;
			_chain.segmentCollisionMask = InteractionGroups.TERRAIN;
			_chain.segmentSpriteRotations = 64;
			
			collisionGroup = InteractionGroups.TERRAIN;
			collisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.SEGMENT | InteractionGroups.PLAYER);
		}
		
		public function init() : void
		{
			_chain.init();
			for (var i:int = 0; i < (MAX_SEGMENTS - STARTING_SEGMENTS); i++)
			{
				_chain.withdrawSegment();
			}
			
			var lastSegment:ZlxNapeSprite = _chain.segments[_chain.segments.length - 1];
			 _playerJoint = new PivotJoint(lastSegment.body, _player.body, 
				getEdgeVector(DIRECTION_LEFT), Vec2.get());// , 1, 2);
			
			_playerJoint.space = _body.space;
			_playerJoint.maxForce = 1000000;
			
			
			for each (var segment:ZlxNapeSprite in _chain.segments)
			{
				_initialSegmentMass = segment.body.mass;
				break;
			}
		}
		
		public override function update() : void
		{
			super.update();
			
			if (_desiredChainLength > _chain.currentSegmentCount)
			{
				if (getTimer() > _nextChainSpawnTime)
				{
					_nextChainSpawnTime = getTimer() + CHAIN_SPAWN_FREQ * 1000;
					_chain.extendSegment();
				}
			}
			
			// Artificically make segments below the player *lighter*.
			// This keeps the player from being burdened by their weight.
			for each (var segment:ZlxNapeSprite in _chain.segments)
			{
				if (segment.y > _player.y + 15)
				{
					segment.body.mass = _initialSegmentMass * LOWER_SEGMENT_MASS_FRAC;
					segment.setMaterial(LOWER_SEGMENT_MASS_MATERIAL);
				}
				else
				{
					segment.body.mass = _initialSegmentMass;
					segment.setMaterial(NORMAL_SEGMENT_MASS_MATERIAL);
				}
			}
		}
		
		public function extend(amt:int) : void
		{
			_desiredChainLength = _desiredChainLength + amt;
		}
	}

}