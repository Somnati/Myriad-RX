/// syst_rm_numfmt - THE NUMBER FORMAT COMPARISON (his ask, 2026-09-10:
/// "a room that lists each number format and different amounts so I can
/// see how they compare"). A table: one row per amount, one column per
/// format in num_format_config, every cell crunch_arb under that format.
/// Tapping a column's header makes it the game's format (g.num_format,
/// saved) - the whole game reads the same pick, so this doubles as the
/// setting. Menu > misc > number formats.

depth = -10;
bby = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;

fmts = num_format_config();

// the amounts: one per decade band that matters, then the far ones -
// packed arbs, so they are what the game actually formats
amounts = [];
// ...and the far end: e308 is where reals stop, the arb does not - a
// thousand, fifty thousand (past three letters), a million (his "E1M"),
// a billion (the exponent itself abbreviates)
var _lg = [0, 1, 2, 3, 4, 5, 6, 7, 9, 12, 15, 18, 24, 33, 63, 100, 200, 303, 307,
           1000, 52700, 1000000, 1000000000];
for (var _i = 0; _i < array_length(_lg); _i++) {
	// a mantissa that is not 1, so rounding shows: 1.234...
	var _v = (_lg[_i] == 0) ? arb(7) : log_to_arb(_lg[_i] + log10(1.234 + (_i mod 3) * 2.1));
	array_push(amounts, _v);
}

// the table's geometry
row_h = 9;
col_w = (room_width - 62) / array_length(fmts);
tab_y = bby + 22;
label_w = 58;

hov = -1;   // the column under the pointer

/// the cell string: crunch_arb under a chosen format, without touching
/// the game's own pick for longer than one call
__cell = function(_v, _f) {
	var _keep = g.num_format;
	g.num_format = _f;
	var _s = crunch_arb(_v);
	g.num_format = _keep;
	return _s;
};
