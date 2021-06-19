package hcb;

import VectorMath;

enum OriginPoint {
	TopLeft;
	TopCenter;
	TopRight;
	CenterLeft;
	Center;
	CenterRight;
	BottomLeft;
	BottomCenter;
	BottomRight;
}

class Origin {
	public static inline function getOriginOffset(origin: OriginPoint, size:Vec2, keepInt: Bool = false): Vec2 {
		var offset: Vec2 = vec2(0, 0);
		switch(origin) {
			case OriginPoint.TopLeft:
			case OriginPoint.TopCenter:
				offset.x = -size.x/2;
			case OriginPoint.TopRight:
				offset.x = -size.x;
			case OriginPoint.CenterLeft:
				offset.y = -size.y/2;
			case OriginPoint.Center:
				offset.x = -size.x/2;
				offset.y = -size.y/2;
			case OriginPoint.CenterRight:
				offset.x = -size.x;
				offset.y = -size.y/2;
			case OriginPoint.BottomLeft:
				offset.y = -size.y;
			case OriginPoint.BottomCenter:
				offset.x = -size.x/2;
				offset.y = -size.y;
			case OriginPoint.BottomRight:
				offset.x = -size.x;
				offset.y = -size.y;
		}

		if(keepInt)
			offset = vec2(Std.int(offset.x), Std.int(offset.y));

		return offset;
	}
}