/// THE BOOT'S SPINNER (his ask, 2026-09-16: "a smooth minimal loading icon";
/// redrawn the same day - "the loading spinner looks bad"): bottom right of
/// the black gameload screen, a ring of eight PIXEL DOTS on the house grid
/// - the head bright, a tail fading behind it - stepping round on the wall
/// clock, so it moves the same on every machine and a slow frame skips
/// rather than freezes; the caption beside it in the house font at a whole
/// scale; and under both a one-pixel PROGRESS BAR with the boot's real
/// progress (the galaxy's passes, the worlds' rows, the bakes' rows -
/// syst_handle_save's Step). Crisp: everything lands on whole house pixels
/// (the soft window-resolution arc it replaces did not)
if (!in_room(rm_gameload) || boot_phase >= 2) exit;
// the gui at the window's size (the room behind is a stub of another shape;
// the rooms set it back to their own on arrival - obj_set_landscape /
// syst_display / scr_display1)
var _ww = max(120, window_get_width()), _wh = max(68, window_get_height());
display_set_gui_size(_ww, _wh);
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
// the whole gui black first
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, _gw, _gh, 0, c_black, 1);
var _sc = max(1, floor(_gh / 270));                 // the house scale: one room pixel in window pixels
var _cx = _gw - 20 * _sc, _cy = _gh - 22 * _sc;     // the ring's centre
var _col = c_steelblue;
// THE DOTS: eight round the ring, 2x2 house pixels each, on a 6px radius; the
// head steps a dot every 90 ms and the tail fades by .6 a dot behind it
var _head = floor(current_time / 90) mod 8;
for (var _k = 0; _k < 8; _k++) {
	var _back = (_head - _k + 8) mod 8;              // dots behind the head
	var _a = max(.08, power(.6, _back));
	var _dx = _cx + lengthdir_x(6 * _sc, _k * 45 - 90), _dy = _cy + lengthdir_y(6 * _sc, _k * 45 - 90);
	_dx = floor(_dx / _sc) * _sc; _dy = floor(_dy / _sc) * _sc;
	draw_sprite_ext(spr_pixel_1x1, 0, _dx - _sc, _dy - _sc, 2 * _sc, 2 * _sc, 0, (_back == 0) ? merge_colour(_col, c_white, .45) : _col, _a);
}
draw_set_alpha(1);
// THE CAPTION, left of the ring, and THE BAR under both
var _txt = (boot_phase == 0) ? "charting the galaxy" : ((action == sv_load || action == sv_save) ? "loading" : "the first world");
var _bx1 = _cx + 8 * _sc, _bx0 = _bx1 - 92 * _sc;   // the bar: the longest caption's reach to the ring's right edge
if (variable_global_exists("font")) {
	draw_set_font(fnt);
	_bx0 = _cx - 12 * _sc - string_width("charting the galaxy") * _sc;
	draw_set_halign(fa_right); draw_set_valign(fa_top);
	draw_set_color(rgb(120, 130, 150)); draw_set_alpha(.7);
	draw_text_transformed(_cx - 12 * _sc, _cy - 4 * _sc, _txt, _sc, _sc, 0);
	draw_set_halign(fa_left); draw_set_alpha(1);
}
var _by = _cy + 12 * _sc, _bw = _bx1 - _bx0;
draw_sprite_ext(spr_pixel_1x1, 0, _bx0, _by, _bw, _sc, 0, merge_colour(_col, c_black, .8), 1);
draw_sprite_ext(spr_pixel_1x1, 0, _bx0, _by, floor(_bw * clamp(boot_prog_v, 0, 1) / _sc) * _sc, _sc, 0, _col, .85);
