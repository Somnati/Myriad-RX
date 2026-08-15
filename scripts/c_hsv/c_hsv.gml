/// @description  c_hsv(hue,sat,value)
/// @param hue
/// @param sat
/// @param value
function c_hsv(argument0, argument1, argument2) {
	return make_colour_hsv(clamp(argument0,0,255),clamp(argument1,0,255),clamp(argument2,0,255));
}