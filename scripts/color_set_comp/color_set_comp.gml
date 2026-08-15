/// @description color_set_comp(c);
/// @param c

function color_set_comp(argument0) {
	var _p;
	
	_p = lerp(0,360,colour_get_hue(argument0)/255)-180;
	if _p < 0 _p+=360; if _p > 360 _p-=360;

	return make_colour_hsv(lerp(0,255,_p/360),c_sat(argument0),c_val(argument0));
}
