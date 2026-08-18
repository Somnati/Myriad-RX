/// @description dial_color(i) - a dial's IDENTITY COLOUR, the exact
/// thirteen from Myriad DE (its c_dial0a..c_dial12m macros, read
/// through get_letter_color). These are hand-picked, not generated:
/// they do not walk the colour wheel evenly, and that irregularity is
/// what makes each dial recognisable at a glance as a single dot in
/// the docked column. Do not "improve" them into a gradient.
/// DE rotates the hue further per evolution tier; that hook returns
/// when evolution does.
function dial_color(_i) {
	switch (_i mod 13) {
		case 0:  return make_colour_rgb(128, 128, 255); // a
		case 1:  return make_colour_rgb(250,  29,  51); // b
		case 2:  return make_colour_rgb(252, 209,  42); // c
		case 3:  return make_colour_rgb( 87, 238,  70); // d
		case 4:  return make_colour_rgb(185, 253, 255); // e
		case 5:  return make_colour_rgb(228, 105, 255); // f
		case 6:  return make_colour_rgb(255, 116,  23); // g
		case 7:  return make_colour_rgb(138, 154,  91); // h
		case 8:  return make_colour_rgb(144, 133, 165); // i
		case 9:  return make_colour_rgb(255,  66, 122); // j
		case 10: return make_colour_rgb(252, 244, 163); // k
		case 11: return make_colour_rgb(  0, 128, 129); // l
		case 12: return make_colour_rgb(114, 160, 177); // m
	}
	return c_white;
}
