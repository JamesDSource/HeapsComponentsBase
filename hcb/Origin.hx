package hcb;

import hcb.math.Vector2;

enum OriginPoint {
	topLeft;
	topCenter;
	topRight;
	centerLeft;
	center;
	centerRight;
	bottomLeft;
	bottomCenter;
	bottomRight;
}

class Origin {
	public static function getOriginOffset(origin: OriginPoint, size:Vector2): Vector2 {
		var offset: Vector2 = new Vector2(0, 0);
		
		switch(origin) {
			case OriginPoint.topLeft:
			case OriginPoint.topCenter:
				offset.x = -size.x/2;
			case OriginPoint.topRight:
				offset.x = -size.x;
			case OriginPoint.centerLeft:
				offset.y = -size.y/2;
			case OriginPoint.center:
				offset.x = -size.x/2;
				offset.y = -size.y/2;
			case OriginPoint.centerRight:
				offset.x = -size.x;
				offset.y = -size.y/2;
			case OriginPoint.bottomLeft:
				offset.y = -size.y;
			case OriginPoint.bottomCenter:
				offset.x = -size.x/2;
				offset.y = -size.y;
			case OriginPoint.bottomRight:
				offset.x = -size.x;
				offset.y = -size.y;
		}

		return offset;
	}
}