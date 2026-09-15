/// THE BOOT'S SPINNER (his ask): bottom right of the black gameload screen,
/// eight pixel squares round a ring, the bright one running, "charting
/// the galaxy" beside it - until the galaxy is built and the save is in
if (!in_room(rm_gameload) || boot_phase >= 2) exit;
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _cx = _gw - 22, _cy = _gh - 22;
var _ph = (current_time / 90) mod 8;
for (var _i = 0; _i < 8; _i++) {
	var _a = _i * 45;
	var _px = round(_cx + lengthdir_x(8, _a)), _py = round(_cy + lengthdir_y(8, _a));
	var _d = ((_i - _ph) mod 8 + 8) mod 8;
	var _al = .2 + .8 * max(0, 1 - _d / 3);
	draw_sprite_ext(spr_pixel_1x1, 0, _px - 1, _py - 1, 2, 2, 0, c_steelblue, _al);
}
if (variable_global_exists("font")) {
	draw_set_font(fnt);
	draw_set_halign(fa_right); draw_set_valign(fa_top);
	draw_set_color(rgb(120, 130, 150)); draw_set_alpha(.7);
	draw_text(_cx - 16, _cy - 4, (boot_phase == 0) ? "charting the galaxy" : "loading");
	draw_set_halign(fa_left); draw_set_alpha(1);
}
