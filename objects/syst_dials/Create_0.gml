/// syst_dials - the dial column: draw-only plus its own hit regions
/// (the house region pattern; Myriad DE spreads this across obj_dial,
/// obj_dial_position and obj_dragautos, each dial a live instance with
/// surfaces and spring animation - RX starts with one controller
/// drawing all rows, and grows into per-dial instances when the feel
/// work needs them).
/// THE REVEAL RULE (DE's): you see the dials you own plus the NEXT one,
/// so the ladder unfolds as you climb it instead of showing thirteen
/// locked rows on a fresh save.

depth = 800;

row_y0 = 180;  // the column's top - obj_clicker's tap surface ends at 176
row_h  = 16;
row_x  = 3;
row_w  = room_width - 6;

/// how many rows to draw: every owned dial, plus one unbought
__rows = function() {
	if (!variable_global_exists("dial")) return 0;
	var _n = 0;
	for (var _i = 0; _i < g.dial_total; _i++)
		if (g.dial[_i].level > 0) _n = _i + 1;
	return min(g.dial_total, _n + 1);
};
