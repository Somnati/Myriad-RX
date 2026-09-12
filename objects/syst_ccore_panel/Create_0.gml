/// syst_ccore_panel - THE CREDIT CORE (Myriad DE's credit farm, his
/// favourite of the refinery room, ported 2026-09-12 "as is"): a slow
/// well of credits you collect by hand. The battery dial's shape - a
/// disc in the middle with a lavender liquid for the fill and the count
/// inside, the collect button under it, the two controls in a band
/// along the bottom: the SPLIT slider (how many levels go to capacity
/// and how many to rate) and the LEVEL ladder. On the overlay contract
/// every panel shares (oa / closing, ui_overlay lists it, ui_blur_tick
/// softens the room behind, the burger's X and escape close it).
/// The data lives in g.ccore (ccore_init); this is pure view - the
/// laws are ccore_values / ccore_tick / ccore_collect / ccore_buy.

ccore_init();
depth   = -510;   // over the room and its drawers, under the menu (-520) and the header (-1000)
oa      = 0;
closing = false;

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar

// ---- layout (both orientations - the money room is both) ----
land    = (room_width > 300);
disc_cx = room_width * .5;
disc_r  = land ? 38 : 32;
disc_cy = land ? 104 : 90;
read_y  = disc_cy + disc_r + 14;         // the state line under the disc
btn_w   = 90; btn_h = 16;                // [collect], under the state line
btn_x   = disc_cx - btn_w * .5;
btn_y   = read_y + 14;
// the band: the split slider left, the level ladder right (stacked in portrait)
band_y  = land ? (room_height - 62 - 17) : (room_height - 103 - 17);
sl_x    = land ? 14 : 8;
sl_y    = band_y + 17 + 12;
sl_w    = land ? 150 : (room_width - 16);
lv_x    = land ? (room_width - 14 - 190) : 8;
lv_y    = land ? (band_y + 17) : (band_y + 17 + 46);
lv_w    = land ? 190 : (room_width - 16);
buy_w   = 54;

liq_t   = random(1000);   // the liquid's own clock (the waves)
liq_lvl = -1;             // the eased fill line
flash   = 0;              // the collect's flush
glow    = 0;              // the disc's breath while it fills
drag    = false;          // the split slider in hand
qtic    = 0;

/// @func __part(i)
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

// the region law: the Step's hits and the Draw share these
__sl_r  = function() { return { x : sl_x, y : sl_y, w : sl_w, h : 5 }; };
__buy_r = function() { return { x : lv_x + lv_w - buy_w, y : lv_y + 12, w : buy_w, h : 14 }; };
__col_r = function() { return { x : btn_x, y : btn_y, w : btn_w, h : btn_h }; };
