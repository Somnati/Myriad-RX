/// @description  check_touch_bounds(x,y,x1,y1,x2,y2);
/// @param x
/// @param y
/// @param x1
/// @param y1
/// @param x2
/// @param y2
function check_touch_bounds(argument0, argument1, argument2, argument3, argument4, argument5) {
	var _x, _y, _x1, _x2, _y1, _y2;

	_x = argument0;
	_y = argument1;
	_x1 = argument2;
	_y1 = argument3;
	_x2 = argument4;
	_y2 = argument5;

	if _x > _x1
	    if _x < _x2
	        if _y > _y1
	            if _y < _y2
	return true
	else 
	return false;








}
