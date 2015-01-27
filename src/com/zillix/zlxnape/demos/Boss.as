package com.zillix.zlxnape.demos
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.BodyRegistry;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.zlxnape.InteractionGroups;
	import flash.display.PixelSnapping;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.phys.BodyType;
	
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Boss extends ZlxNapeSprite 
	{
		private var SEGMENT_WIDTH:int = 8;
		private var SEGMENT_HEIGHT:int = 16;
		public var segments:Vector.<ZlxNapeSprite>;
		private var maxSegments:int = 20;
		private var segmentIndex:int = 0;
		private var _target:FlxObject;
		
		public var joints:Vector.<PivotJoint>;
		
		public function Boss(X:Number, Y:Number, target:FlxObject)
		{
			super(X, Y);
			_target = target;
		}
		
		override public function createBody(Width:Number, Height:Number, bodyContext:BodyContext, bodyType:BodyType =  null, copyValues:Boolean = true) : void
		{
			super.createBody(Width, Height, bodyContext, bodyType, copyValues);
			
			collisionGroup = InteractionGroups.BOSS;
			collisionMask = ~InteractionGroups.SEGMENT;
			
			addCbType(CallbackTypes.GROUND);
			
			initSegments(_target);
		}
		
		private function initSegments(target:FlxObject) : void
		{
			joints = new Vector.<PivotJoint>();
			segments = new Vector.<ZlxNapeSprite>();
			
			var base:ZlxNapeSprite = this;
			for (var i:int = 0; i < maxSegments; i++)
			{
				base = addSegment(base);
				
				base.followTarget(target, .5, 20);
			}
			
			for (var j:int = 0; j < 10; j++)
			{
				withdrawSegment();
			}
			
			
		}
		
		private function addSegment(obj:ZlxNapeSprite) : ZlxNapeSprite
		{
			var segment:ZlxNapeSprite = new ZlxNapeSprite(obj.x + obj.width / 2 - SEGMENT_WIDTH / 2, obj.y + obj.height);
			segment.createBody(SEGMENT_WIDTH, SEGMENT_HEIGHT, new BodyContext(_body.space, _bodyRegistry));
			segment.makeGraphic(SEGMENT_WIDTH, SEGMENT_HEIGHT, 0xffdddddd);
			segment.collisionGroup = InteractionGroups.SEGMENT;
			segment.collisionMask = ~InteractionGroups.SEGMENT;
			segments.push(segment);
			segment.addCbType(CallbackTypes.GROUND);
			
			PlayState.instance.add(segment);
			var pivotPoint:Vec2 = Vec2.get(obj.x + obj.width/2, obj.y + obj.height);
			var pivotJoint:PivotJoint = new PivotJoint(obj.body, segment.body, 
				obj.body.worldPointToLocal(pivotPoint, true),
				segment.body.worldPointToLocal(pivotPoint, true));
			
			pivotJoint.space = _body.space;
			joints.push(pivotJoint);
			
			return segment;
		}
		
		public function withdrawSegment() : void
		{
			if (segmentIndex < maxSegments - 1)
			{
				var joint1:PivotJoint = joints[segmentIndex];
				joint1.active = false;
				var segment:ZlxNapeSprite = segments[segmentIndex];
				segment.disable();
				var joint2:PivotJoint = joints[segmentIndex + 1];
				joint2.body1 = this.body;
				segmentIndex++;
			}
		}
		
		public function extendSegment() : void
		{
			var segment:ZlxNapeSprite = segments[segmentIndex - 1];
			segment.enable(_body.space);
			var joint1:PivotJoint = joints[segmentIndex - 1];
			joint1.active = true;
			var joint2:PivotJoint = joints[segmentIndex];
			joint2.body1 = segment.body;
			segmentIndex--;
		}
		
		public override function update() : void
		{
			super.update();
			_body.setVelocityFromTarget(new Vec2(FlxG.mouse.x, FlxG.mouse.y), _body.rotation, 5);
		}
	}
	
}