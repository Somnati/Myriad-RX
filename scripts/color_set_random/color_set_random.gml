/// @description color_set_random();

function color_set_random(){

	return make_colour_hsv(round(random(239)),round(random_range(11,255)),round(random_range(175,255)));

}