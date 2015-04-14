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

	function refresh(e:flash.events.Event) {
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