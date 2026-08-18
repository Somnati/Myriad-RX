/// @description dial_color(i) - a dial's IDENTITY colour (Myriad DE's
/// get_letter_color: thirteen fixed hues, one per dial, so a dial is
/// recognisable as a coloured dot long before you can read its row).
/// DE rotates the hue again per evolution tier; that hook returns when
/// evolution does.
function dial_color(_i) {
	return make_colour_hsv((_i * (255 / 13)) mod 256, 175, 245);
}
