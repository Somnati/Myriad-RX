/// syst_cheat_panel - THE CHEAT SHOP (Disgaea D2/5/6/7's, his ask
/// 2026-09-13, built to his row list): obtain rates you REDISTRIBUTE.
/// Every row starts at 100%; the total is capped (cheat_cap: 100 a row,
/// +25 per rebirth milestone, +5 per rebirth); lower one thing to raise
/// another. Nothing here is bought - the whole design is that nothing
/// is free and everything is a choice, and the cap itself is the meta
/// progression (the milestone ruler under the tap room finally points
/// at something).
///
/// A panel on the overlay contract (settings / statistics / the time
/// bank): cheat_open() the one door, cheat_close() the exit, oa /
/// closing the ease ui_blur_tick reads, ui_overlay() lists it. Rows
/// deal in behind the strip (ui_anim_in). Draw-only + region hits off
/// the same geometry declared here (the house pattern).
///
/// THE CONTROLS: [-] / [+] step CHEAT_STEP with hold-to-repeat; press
/// or drag on a row's bar sets it outright (a raise stops where the
/// pool runs out); [default] is Disgaea's - every row back to 100.
/// The footer explains the hovered row, or the rule.
cheat_init();
depth = -510;
oa      = 0;
closing = false;
hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
cfg  = cheat_config();
N    = array_length(cfg.rows);
land = (room_width > 300);

// ---- layout (region law: Step's hits and Draw share these) ----
x0 = land ? 24 : 6;
x1 = room_width - x0;
band_y = hh + 22;                 // the cap band
row_y0 = hh + 42;                 // the first row
row_h  = land ? 16 : 24;          // portrait rows are two lines
bw_btn = 18;                      // [-] / [+]
bx_minus = x1 - bw_btn * 2 - 4;
bx_plus  = x1 - bw_btn;
// the bar: landscape beside the name, portrait on the second line
bar_x0 = land ? x0 + 132 : x0;
bar_x1 = land ? bx_minus - 8 : x1 - 30;   // (portrait: the percent sits right of the bar on its own line)
val_x  = land ? x0 + 122 : x1;            // the percent, right-aligned here
val_dy = land ? 2 : 12;                   // ...on line one, or line two in portrait (the long names ran into it - 2026-09-14)
foot_y = row_y0 + N * row_h + 8;

hot_row = -1;    // the row under the pointer
hot_btn = 0;     // -1 / +1 while over its button
drag    = -1;    // the row whose bar is being dragged
rep_t   = 0;     // the hold-to-repeat clock
hot_def = false; // the pointer on [default]
def_w   = 52;

/// @func __bar(i) -> the bar's rect
__bar = function(_i) {
	var _y = row_y0 + _i * row_h + (land ? 5 : 14);
	return { x : bar_x0, y : _y, w : bar_x1 - bar_x0, h : 6 };
};

/// @func __step(i, dir)
/// @desc one press of a row's button: the change, or why not
__step = function(_i, _dir) {
	var _v = g.cheat.v[_i];
	if (cheat_set(_i, _v + _dir * CHEAT_STEP)) {
		play_sound_ext(snd_softclick, .95 + (_dir > 0 ? .1 : 0), 1.05 + (_dir > 0 ? .1 : 0), .4, 1);
		return;
	}
	play_sound_ext(snd_matclick, .6, .75, .3, 1);
	var _b = __bar(_i);
	if (_dir > 0) float_text(_b.x + _b.w * .5, _b.y - 8, (_v >= CHEAT_ROW_MAX) ? "at the max" : "nothing free - lower another", c_hred);
	else          float_text(_b.x + _b.w * .5, _b.y - 8, "never under " + string(CHEAT_ROW_MIN) + "%", c_hred);
};

/// @func __part(i)
/// @desc seat part i for the open animation (the settings recipe)
__part = function(_i) {
	var _e = ui_anim_in(oa, _i);
	if (_e < .001) return 0;
	var _o = (1 - _e) * UI_IN_DEAL;
	if (_o != 0) matrix_set(matrix_world, matrix_build(0, _o, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_e);
	return _e;
};
__part_end = function() {
	ui_fade_set(1);
	matrix_set(matrix_world, matrix_build_identity());
};
