/// @description mouse_over_ext(x1,y1,x2,y2)
/// @param x1
/// @param y1
/// @param x2
/// @param y2
///Returns true if cursor is within object's bounding box

function mouse_over_ext(argument0, argument1, argument2, argument3) {
	return (mouse_x >= argument0 &&
	        mouse_x <= argument2 &&
	        mouse_y >= argument1 &&
	        mouse_y <= argument3);
}
