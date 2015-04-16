import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import b.*;

@:bitmap("brush.png") class Sheet extends flash.display.BitmapData {}
@:bitmap("logo.png") class Logo extends flash.display.BitmapData {}
@:bitmap("particle.png") class ParticlePNG extends flash.display.BitmapData {}

class Game {
	var buffer:BitmapData = new BitmapData(320, 200, false, 0xff00ff00);
	var particleBD:BitmapData = new BitmapData(320, 200, true, 0x00000000);
	var display:BitmapData = new BitmapData(960, 600, false, 0xff00ff00);
	var overlayBD:BitmapData = new BitmapData(960, 600, false, 0xff00ff00);
	var logo = new Logo(0,0);

	var frames = 0;
	var fpsCountStart = 0.0;
	var blob:Blob = null;
	var dx = 1;
	var particles:Particles = null;

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

	function generateOverlay(buffer, bgColor = 0xff808080, fgColor = 0xffffffff) {
		for (x in 0...buffer.width) {
			for (y in 0...buffer.height) {
				if ((y%3) == 2) {
					buffer.setPixel32(x, y, fgColor);
				} else {
					buffer.setPixel32(x, y, bgColor);
				}
			}
		}
	}

	var frame = 0;

	function refresh(e:flash.events.Event) {

		frame += 1;
		var xoff = Std.int(Math.sin(frame * 0.001) * 50 + 50);
		var yoff = Std.int(Math.cos(frame * 0.0025) * 50 + 50);
		var xoff2 = Std.int(Math.sin(frame * 0.012 + 0.5) * 50 + 50);
		var yoff2 = Std.int(Math.cos(frame * 0.035 + 0.25) * 50 + 50);

		buffer.fillRect(buffer.rect, 0xff000000);
		buffer.draw(logo);
		var m = new Matrix();
		m.scale(3, 3);

		var t = flash.Lib.getTimer();

		Ray.all(xoff, yoff, xoff2, yoff2, function (x, y) {
			buffer.setPixel(x, y, 0xffffffff);
		});

		var elapsed = flash.Lib.getTimer() - t;
//		trace(elapsed);


		frames++;
		if (Date.now().getTime() - fpsCountStart > 1000) {
			if (fpsCountStart > 0) {
				trace(frames + " fps");
			}
			frames = 0;
			fpsCountStart = Date.now().getTime();
		}

		blob.draw(buffer);
		blob.tick();

		if (/*Math.random() < 0.03 &&*/ blob.ticks == 0 && (blob.currentFrameInAnimation%3) == 0) {
			particles.burst(blob.x + 50, blob.y + 150, 0, 100, 1, 1, 10);
		}

		blob.x += dx;
		if (blob.x > 100) {
			dx *= -1;
			blob.x = 100;
			blob.anim("walk_left");
		}
		if (blob.x < 0) {
			dx *= -1;
			blob.x = 0;
			blob.anim("walk_right");
		}

		var t = flash.Lib.getTimer();
		particles.tick();
		particleBD.fillRect(particleBD.rect, 0x00000000);
		particles.draw(particleBD);
		particleBD.applyFilter(particleBD, particleBD.rect, new Point(0,0), new flash.filters.GlowFilter(0xffffffff, 1.0, 10, 10, 1.5, 2, false, false));
		buffer.draw(particleBD, null, null, flash.display.BlendMode.INVERT);

		var elapsed = flash.Lib.getTimer() - t;
//		trace(elapsed);

		display.fillRect(buffer.rect, 0xffffffff);

		var m = new Matrix();
		m.scale(3, 3);
		display.draw(buffer, m, null, null);
		display.draw(overlayBD, null, null, OVERLAY);
	}

	var channel:SoundChannel;

	var c : flash.display3D.Context3D;
	var shader : Shader;
//	var pol : Polygon;
	var camera : Camera;
	var s : flash.display.Stage3D;
	var stage = flash.Lib.current.stage;

	function onReady(foo:Dynamic) {
		c = s.context3D;
		c.enableErrorChecking = true;
		c.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);
		shader = new Shader();
		camera = new Camera();
	}

	public function new() {
/*		s = stage.stage3Ds[0];
		s.addEventListener( flash.events.Event.CONTEXT3D_CREATE, onReady );
		s.requestContext3D();
		return;*/

		particles = new Particles();
		particles.setBitmap("pixel", new ParticlePNG(0,0));

		Blob.setSheet(new Sheet(0, 0));
		Blob.setGrid(104, 150);
		Blob.defineAnimation("walk_right", 0, 0, 6, 15);
		Blob.defineAnimation("walk_left", 0, 1, 6, 15);

		generateOverlay(overlayBD, 0xff808080);

		blob = new Blob();
		blob.y = 30;
		blob.anim("walk_right");

		flash.Lib.current.addChild(new Bitmap(display));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
	}

	static function main() {
		var what = new Game();
	}
}