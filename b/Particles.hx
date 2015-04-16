package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

class Particle {
	public var x = 100.0;
	public var y = 100.0;
	public var xs = 0.0;
	public var ys = 0.0;
	public var gravity = 0.00;
	public var lifetime = 100;
	public var friction = 0.98;

	public function new() {
	}
}

class Particles {
	var all = new Array<Particle>();

	public function new() {
	}

	public function makeParticle() {
		for (p in all) {
			if (p.lifetime == 0) {
				return p;
			}
		}

		var p = new Particle();
		all.push(p);
		return p;
	}

	public function burst(x:Float = 100, y:Float = 100, direction:Float = 0, directionVariance:Float = 3.1415*1.5, speed:Float = 1, speedVariance:Float = 0.5, count:Int = 5) {
		for (i in 0...count) {
			var p = makeParticle();
			var a = direction + (Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random())/8.0 * directionVariance - directionVariance/2.0;

			var s = speed + (Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random())/8.0 * speedVariance;
			p.xs = Math.cos(a) * s;
			p.ys = Math.sin(a) * s;
			p.x = x;
			p.y = y;
			p.lifetime = 100 + Std.int(Math.random() * 100);
		}
	}

	public function draw(bd:BitmapData) {
		for (p in all) {
			if (p.lifetime == 0) {
				continue;
			}
			bd.setPixel32(Std.int(p.x), Std.int(p.y), 0xffffffff);
		}
	}

	public function tick() {
		for (p in all) {
			p.x += p.xs;
			p.y += p.ys;
			if (p.lifetime > 0) {
				p.lifetime--;
			}

			p.xs *= p.friction;
			p.ys *= p.friction;
			p.ys += p.gravity;
		}
	}
}