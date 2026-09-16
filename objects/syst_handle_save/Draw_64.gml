/// THE BOOT'S SPINNER (his ask, 2026-09-16: "a smooth minimal loading icon
/// instead of the current sprite-like one"): bottom right of the black
/// gameload screen, a thin ring arc that turns and breathes - the head runs
/// ahead, the tail catches up (the indeterminate ring) - drawn at the
/// WINDOW'S own resolution as a soft-edged triangle strip, "charting the
/// galaxy" beside it in the house font at a whole scale - until the galaxy
/// is built and the save is in
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
var _cx = _gw - 22 * _sc, _cy = _gh - 22 * _sc;
var _r = 8.5 * _sc, _th = 1.6 * _sc;                 // the ring's radius and thickness
// THE ARC: it turns at a steady rate while its length breathes - growing,
// the tail holds and the head runs; shrinking, the tail chases (wall time,
// so it moves the same on every machine)
var _t = current_time / 1000;
var _br = (1 - cos(_t * 1.9)) * .5;                 // 0..1..0, the breath
var _sw = 28 + 244 * _br;                           // the sweep, degrees
var _a0 = _t * 210 + 150 * _br;                     // the tail's angle (the extra turn keeps the head running while it shrinks)
var _seg = max(12, ceil(_sw / 5));                  // ~5 degrees a segment
var _col = c_steelblue;
draw_set_alpha(1);
// two strips: the inner half (clear -> full) and the outer half (full -> clear) - a soft edge each side
for (var _half = 0; _half < 2; _half++) {
	draw_primitive_begin(pr_trianglestrip);
	for (var _i = 0; _i <= _seg; _i++) {
		var _f = _i / _seg, _a = _a0 + _sw * _f;
		// the ends fade over their last 12 degrees
		var _ea = min(1, min(_f * _sw, (1 - _f) * _sw) / 12);
		var _ri = (_half == 0) ? (_r - _th) : _r, _ro = (_half == 0) ? _r : (_r + _th);
		var _ai = (_half == 0) ? 0 : 1, _ao = (_half == 0) ? 1 : 0;
		draw_vertex_colour(_cx + lengthdir_x(_ri, _a), _cy + lengthdir_y(_ri, _a), _col, _ai * _ea);
		draw_vertex_colour(_cx + lengthdir_x(_ro, _a), _cy + lengthdir_y(_ro, _a), _col, _ao * _ea);
	}
	draw_primitive_end();
}
if (variable_global_exists("font")) {
	draw_set_font(fnt);
	draw_set_halign(fa_right); draw_set_valign(fa_top);
	draw_set_color(rgb(120, 130, 150)); draw_set_alpha(.7);
	draw_text_transformed(_cx - 16 * _sc, _cy - 4 * _sc, (boot_phase == 0) ? "charting the galaxy" : ((action == sv_load || action == sv_save) ? "loading" : "the first world"), _sc, _sc, 0);
	draw_set_halign(fa_left); draw_set_alpha(1);
}
