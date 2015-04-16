package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

typedef AnimationDefinition = {
	gridX : Int,
	gridY : Int,
	frames : Int,
	ticksPerFrame : Int
}

class Blob {
	static var sheet:BitmapData;
	static var defs:Map<String, AnimationDefinition> = new Map();
	public var currentAnimation:AnimationDefinition;
	public var ticks = 0;
	public var currentFrameInAnimation = 0;
	static var grid:{w:Int, h:Int} = {w:32, h:32};
	public var x = 100;
	public var y = 100;

	public static function setSheet(sheet) {
		Blob.sheet = sheet;
	}

	public static function defineAnimation(name, gridX, gridY, frames, ticksPerFrame) {
		defs[name] = {gridX:gridX, gridY:gridY, frames:frames, ticksPerFrame:ticksPerFrame};
	}

	public function anim(name:String) {
		currentAnimation = defs[name];
		currentFrameInAnimation = 0;
		ticks = 0;
	}

	public static function setGrid(w:Int, h:Int) {
		grid.w = w;
		grid.h = h;
	}

	public function tick() {
		ticks++;
		if (ticks >= currentAnimation.ticksPerFrame) {
			currentFrameInAnimation++;
			if (currentFrameInAnimation >= currentAnimation.frames) {
				currentFrameInAnimation = 0;
			}
			ticks = 0;
		}
	}

	public function new() {
	}

	public function draw(buffer:BitmapData) {
		buffer.copyPixels(
			sheet, 
//			new Rectangle(0, 0, grid.w, grid.h),
			new Rectangle(currentAnimation.gridX + currentFrameInAnimation * grid.w, currentAnimation.gridY * grid.h, grid.w, grid.h),
			new Point(x, y)
		);
	}
}