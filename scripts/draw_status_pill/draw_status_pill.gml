/// @description draw_status_pill(x, y, label, state, [anchor]) -> width
/// @param x
/// @param y
/// @param label
/// @param state
/// @param [anchor]
/// the ONE status readout shape (ui overhaul, tier 2): stalled, dry,
/// full, throttle %, repair quotes - anything that is a STATE rather
/// than a value renders through this pill, so severity reads at a
/// glance instead of by reading every line. 11px tall, sized to the
/// label (assumes the caller already did draw_set_font(fnt)).
/// state picks the palette:
///   uist.neutral  - gray frame, muted ink (informational)
///   uist.warning  - amber (stalled, throttled, low charge)
///   uist.critical - coral, frame pulses (dry, empty, damaged)
///   uist.positive - teal (full, complete, online)
/// anchor fa_right hangs the pill's RIGHT edge on x (row-end readouts).
/// returns the pill width so callers can flow layout around it.
enum uist { neutral, warning, critical, positive }

function draw_status_pill(_x, _y, _label, _state, _anchor = fa_left) {
	var _w = string_width(_label) + 9;
	if (_anchor == fa_right) _x -= _w;

	var _col = c_gray;
	if (_state == uist.warning)  _col = c_gold;
	if (_state == uist.critical) _col = c_hred;
	if (_state == uist.positive) _col = c_seagreen;

	// critical is the only state allowed to MOVE - a pulsing frame so
	// a dry bank / dead dial is the loudest thing on screen when true
	var _fa = .6;
	if (_state == uist.neutral)  _fa = .35;
	if (_state == uist.critical) _fa = .7 + .3 * abs(dsin(current_time * .35));

	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, 11, 0,
		merge_colour(c_black, _col, .18), .85);
	draw_px_rect(_x, _y, _w, 11, _col, _fa);

	// centering enforced both ways (see draw_ui_button: stray valign
	// + the sprite font's trailing space pushed labels off-center)
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color((_state == uist.neutral) ? sett_ink
		: merge_colour(_col, c_white, .35));
	draw_set_alpha(.95);
	draw_text(_x + (_w div 2) + 1, _y + 2, _label);
	draw_set_halign(fa_left);
	draw_set_alpha(1);

	return _w;
}
