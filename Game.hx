import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import b.*;

@:bitmap("brush.png") class Sheet extends flash.display.BitmapData {}

class Game {
	var buffer:BitmapData = new BitmapData(960, 600, false, 0xff00ff00);
	var frames = 0;
	var fpsCountStart = 0.0;
	var blob:Blob = null;
	var dx = 1;

	function overlay(a:Float, b:Float) {
		if (a < 0.5) {
			return 2 * a * b;
		} else {
			return 1 - 2*(1 - a)*(1 - b);
		}
	}

	function brighten(pixel:UInt) {
		// BGRA?

		var r:Float = ((pixel >> 8) & 255)/255.0;
		var g:Float = ((pixel >> 16) & 255)/255.0;
		var b:Float = ((pixel >> 24) & 255)/255.0;

		var o:Float = 1.0;

		var n:Int = (pixel & 255) 
			+ (Std.int(overlay(r, o) * 255.0) << 8)
			+ (Std.int(overlay(g, o) * 255.0) << 16)
			+ (Std.int(overlay(b, o) * 255.0) << 24);

		return n;
	}

	function refresh(e:flash.events.Event) {

		buffer.fillRect(new Rectangle(0, 0, 960, 600), 0xffff0000);

		frames++;
		if (Date.now().getTime() - fpsCountStart > 1000) {
			if (fpsCountStart > 0) {
				trace(frames + " fps");
			}
			frames = 0;
			fpsCountStart = Date.now().getTime();
		}
		buffer.fillRect(new Rectangle(0, 0, 960, 600), 0xffff0000);

		blob.draw(buffer);
		blob.tick();
		blob.x += dx;
		if (blob.x > 200) {
			dx *= -1;
			blob.x = 200;
			blob.anim("walk_left");
		}
		if (blob.x < 100) {
			dx *= -1;
			blob.x = 100;
			blob.anim("walk_right");
		}

/*		var mem = buffer.getPixels(new Rectangle(0, 0, buffer.width, buffer.height));
		flash.Memory.select(mem);
		var end = mem.position;
		trace("fff");
		var i:UInt = 0;
		end = 10000;
		while (i < end) {
			i += 4;
			flash.Memory.setI32(i, 0xffffffff);			
		}
		mem.position = end;
*/
//		var bytes:ByteArray = buffer.getPixels(new Rectangle(0,0,10,10));
//		trace("argh");
/*
		try {
			bytes[10] = 0xffff0000;
			buffer.setPixels(new Rectangle(0,0,10,10), bytes);
		} catch (foo : String) {
			var y = 10;
			trace("arghb");
		}
		trace("argha");*/

		buffer.setPixel32(100, 100, 0xffffffff);

		var rect = buffer.rect;
		var size:Int = buffer.width * buffer.height * 4;
//		var pixels:ByteArray = new ByteArray();
//		pixels.length = size;
		var pixels = buffer.getPixels(buffer.rect);
		flash.Memory.select(pixels);

		// Double width
		var i:Int = size - buffer.width * 4;
		var halfW = buffer.width / 2;

		var j:Int;

		i = size;
		j = size >> 1;
		while (i > 0) {
			j -= 4 * buffer.width;
			i -= 8 * buffer.width;

			var xb = buffer.width * 4;
			var xs = buffer.width * 2;
			var pixel:UInt;
			while (xb > 0) {
				xb -= 8;
				xs -= 4;
				pixel = flash.Memory.getI32(j + xs);

				flash.Memory.setI32(i + xb, pixel);
				flash.Memory.setI32(i + xb + 4, pixel);

				var brighterPixel = brighten(pixel);

				flash.Memory.setI32(i + xb + buffer.width * 4, brighterPixel);
				flash.Memory.setI32(i + xb + buffer.width * 4 + 4, brighterPixel);
			}


//			flash.Memory.setI32(j, 0xffff00ff);
		}

/*		while (i < size) {
			flash.Memory.setI32(i, 0xffff00ff);
			i += 4;
		}
*/

/*		var smallXPos:Int;
		var bigXPos:Int;
		var pixel:UInt;
//		trace("make it so");

		var bigYPos:Int = size - buffer.width * 4;
		var smallYPos:Int = buffer.width * buffer.height * 4 - buffer.width * 4;

		while (bigYPos > 0) {

			bigXPos = bigYPos + buffer.width * 4;
			smallXPos = smallYPos + (buffer.width >> 1) * 4;

			while (bigXPos > smallXPos) {
//				flash.Memory.setI32(i + x*4, 0xffff00ff);
				pixel = flash.Memory.getI32(smallXPos);
				smallXPos -= 4;
//				pixel = 0xffff00ff;
	
				if (bigXPos >= size) {
					break;
				}

//				flash.Memory.setI32(bigXPos, pixel);
				bigXPos -= 4;
//				flash.Memory.setI32(bigXPos, pixel);
				bigXPos -= 4;

				flash.Memory.setI32(smallXPos, 0xffff00ff);

			}

			smallYPos -= buffer.width * 8;
			bigYPos -= buffer.width * 8;
		}
		trace("ruu");
*/
//		flash.Memory.setI32((100 * buffer.width + 100) * 4, 0xffffffff);

		pixels.position = 0;
		buffer.setPixels(rect, pixels);

//		buffer.setPixel32(100, 100, 0xffffffff);

		return;
	}

	var channel:SoundChannel;

	public function new() {
		Blob.setSheet(new Sheet(0, 0));
		Blob.setGrid(104, 150);
		Blob.defineAnimation("walk_right", 0, 0, 6, 15);
		Blob.defineAnimation("walk_left", 0, 1, 6, 15);

		blob = new Blob();
		blob.anim("walk_right");

		flash.Lib.current.addChild(new Bitmap(buffer));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
	}

	static function main() {
		var what = new Game();
	}
}