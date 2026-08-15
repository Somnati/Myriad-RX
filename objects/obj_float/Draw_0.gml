/// two-tone gradient text with a soft shadow. x clamps to the room so
/// floats spawned near an edge slide inward instead of clipping

var _dx = clamp(x, 4 + sw * .5, room_width - 4 - sw * .5);
var _dy = y + drift_y - sh2 * scale * .5;

draw_set_halign(fa_center);
if (fnt_use != -1) draw_set_font(fnt_use);

draw_text_transformed_colour(_dx + 1, _dy + 1, text, scale, scale, tilt,
	c_black, c_black, c_black, c_black, alpha * .4);
draw_text_transformed_colour(_dx, _dy, text, scale, scale, tilt,
	c_top, c_top, c_bot, c_bot, alpha);

if (fnt_use != -1) draw_set_font(fnt); // don't leak into later floats
draw_set_halign(fa_left);
