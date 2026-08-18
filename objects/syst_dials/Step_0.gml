// tap a row to buy it a level (region law: this geometry is Draw's).
// DE splits these jobs - tapping a dial restarts its cycle, a separate
// button buys levels - which only matters once autonomy is an upgrade
// you have to earn. Until that layer exists, buying IS the interaction.

if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (!variable_global_exists("dial")) exit;

var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _ry = row_y0 + _i * row_h;
	if (mouse_y < _ry || mouse_y >= _ry + row_h - 1) continue;
	if (mouse_x < row_x || mouse_x >= row_x + row_w) continue;

	if (dial_buy(_i, 1)) play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
	else                 play_sound_ext(snd_matclick, .6, .75, .35, 1);
	break;
}
