package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

class Ray {
	public static function all(x1:Float, y1:Float, x2:Float, y2:Float, callback:Function) {

		callback(Math.round(x1), Math.round(y1));
		callback(Math.round(x2), Math.round(y2));

		var midpointX:Float = (x1 + x2)*0.5;
		var midpointY:Float = (y1 + y2)*0.5;

		if (Math.round(x1) == Math.round(midpointX) && Math.round(y1) == Math.round(midpointY)) {
			return;
		}
		if (Math.round(x2) == Math.round(midpointX) && Math.round(y2) == Math.round(midpointY)) {
			return;
		}

		callback(Math.round(midpointX), Math.round(midpointY));

		all(x1, y1, midpointX, midpointY, callback);
		all(midpointX, midpointY, x2, y2, callback);
	}

/*	public static function all(x1:Int, y1:Int, x2:Int, y2:Int, callback:Function) {
		callback(x1, y1);
		callback(x2, y2);
		var midpointX = Math.round((x1 + x2)*0.5);
		var midpointY = Math.round((y1 + y2)*0.5);

		if ((midpointX != x1 || midpointY != y1)
			&& (midpointX != x2 || midpointY != y2)) {

			callback(midpointX, midpointY);
			all(x1, y1, midpointX, midpointY, callback);
			all(midpointX, midpointY, x2, y2, callback);
		}
	}*/

}