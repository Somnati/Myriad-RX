/// rm_delta - ALLUVIUM (q314; his ask: "a stand alone mini idle game with a unique mechanic in its own room... total
/// freedom... good depth... unique from everything else"). THE MECHANIC: you do not build the farm - you steer the river,
/// and the river builds the land. The rain walks downhill as droplets (delta_drop), cutting where it runs and laying
/// silt where it slows; what it still carries when it meets the sea goes down there, and the sea floor rises into new
/// land - THE DELTA. Silt is fertility; crops grow on wet, silted ground and are reaped for GRAIN. Grain buys more rain,
/// springs, richer sediment, better seeds, and the two hand tools - a levee (raise a cell) and a channel (dig one) - so the
/// player's whole craft is where the water goes. Floods come on a season: silt everywhere, and every crop not behind a
/// levee drowned. The sea salts low new land until the silt runs deep. Idle-native: the wall clock, a catch-up on entry.
/// The controller is a VIEW: the state is g.delta (delta_init), the sim delta_tick, the ledger delta_cost / delta_buy.
d = delta_init();
bby = obj_ui_header.sprite_height;
gx = 2; gy = bby + 16;              // the grid's corner (the strip above it)
cell = DELTA_CELL;
px = gx + d.w * cell + 6;           // the panel's left edge
tool = "";                          // "" the hand / "levee" / "channel"
hover = -1;                         // the cell under the mouse (-1 none)
note = "";                          // the strip's line: what the hovered thing is, or the last thing that happened
note_t = 0;
caught = delta_catchup(d);          // THE CATCH-UP: the time away, replayed coarse
if (caught >= 60) { note = "away " + string(floor(caught / 60)) + " min: the river kept working"; note_t = 6; }
// the ground sheet: the grid baked to a surface through a buffer each frame (the house way), drawn scaled
gbuf = buffer_create(d.w * d.h * 4, buffer_fixed, 1);
gsurf = -1;
sheet_t = 99;
tut = (d.life < 1);                 // the first words, until the first grain
// ---- geometry ----
__grid_r = function() { return { x : gx, y : gy, w : d.w * cell, h : d.h * cell }; };
__back_r = function() { return { x : room_width - 62, y : bby + 1, w : 56, h : 13 }; };
__row_r  = function(_i) { return { x : px, y : gy + 30 + _i * 15, w : room_width - px - 4, h : 13 }; };
__hit    = function(_r) { return point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h); };
__cell_at = function(_mx, _my) {
	var _r = __grid_r();
	if (!point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w - 1, _r.y + _r.h - 1)) return -1;
	return floor((_mx - _r.x) / cell) + floor((_my - _r.y) / cell) * d.w;
};
// the panel's rows: what they buy, their label, their colour
rows = [
	{ k : "rain",    lbl : "rain",     col : c_sblue,    tip : "more droplets a second - the river's whole strength" },
	{ k : "springs", lbl : "spring",   col : c_sblue,    tip : "another spring up the mountains: a second river" },
	{ k : "rich",    lbl : "sediment", col : c_horange,  tip : "the water carries more: it cuts deeper and lays more silt" },
	{ k : "seed",    lbl : "seed",     col : c_sgreen,   tip : "the next crop: more grain a harvest, but it wants deeper silt" },
	{ k : "levee",   lbl : "levee",    col : c_gold,     tip : "tool: tap a cell to raise it - the water goes round, and the flood spares the fields beside it" },
	{ k : "channel", lbl : "channel",  col : c_steelblue, tip : "tool: tap a cell to dig it - the water comes this way" },
	{ k : "flood",   lbl : "call the flood", col : c_hred, tip : "the river rises now: silt on everything, and every field not behind a levee drowned" },
	{ k : "valley",  lbl : "the next valley", col : c_white, tip : "once six tenths of the sea is land: a fresh valley, the ledger from the start, and a quarter more grain a harvest for every valley settled" },
];
/// THE GROUND'S COLOUR at a cell: the sea by its depth, the land by its height - sand at the tide, grass, rock, snow -
/// darkened by the silt (richer, darker) and bluer where wet; the player's marks their own
__cell_col = function(_i) {
	var _hv = d.hgt[_i], _si = d.silt[_i], _wt = d.wet[_i], _lv = d.lev[_i];
	if (_hv < d.sea) {
		var _dp = clamp((d.sea - _hv) / .22, 0, 1);
		return merge_colour(rgb(96, 168, 190), rgb(18, 44, 96), _dp);
	}
	var _t = clamp((_hv - d.sea) / (1 - d.sea), 0, 1), _c;
	if (_t < .05)      _c = merge_colour(rgb(214, 196, 150), rgb(160, 176, 90), _t / .05);
	else if (_t < .45) _c = merge_colour(rgb(112, 160, 72), rgb(80, 124, 58), (_t - .05) / .4);
	else if (_t < .78) _c = merge_colour(rgb(120, 110, 96), rgb(160, 150, 140), (_t - .45) / .33);
	else               _c = merge_colour(rgb(200, 200, 205), rgb(245, 246, 250), (_t - .78) / .22);
	if (_si > 0) _c = merge_colour(_c, rgb(70, 48, 30), min(.45, _si * .6));
	if (_wt > .1) _c = merge_colour(_c, rgb(60, 120, 170), min(.55, _wt * .6));
	if (_lv == 1) _c = merge_colour(_c, rgb(200, 170, 110), .6);
	if (_lv == 2) _c = merge_colour(_c, rgb(30, 60, 110), .5);
	return _c;
};
