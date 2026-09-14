/// obj_tile_tower - THE TILE TOWER (DE's obj_modslot_tower, rebuilt; his
/// ask 2026-09-13: "put it in the tile room's header menu on the far
/// left... the animation it has from DE where when it spawns it's
/// moving up to its position... build it better if you can").
///
/// A column of tile slabs up the LEFT edge of the tile room while the
/// header menu is out: one slab a TIER, the lowest at the foot, the
/// tower climbing away from you - a real perspective, not DE's linear
/// taper: slab k is scaled f/(f+k) and the pitch shrinks with it, so
/// the rungs pack toward a vanishing point overhead the way a tower
/// does. Every slab is drawn AS THE BOARD DRAWS THAT TIER - the slab
/// sprite, the tier's colour, the tier's MATERIAL through sh_tile_mat -
/// so the tower is the material ladder made visible: you see what tier
/// 13's hole and tier 20's stars look like before you have merged
/// there. Your highest tier wears a glow, the beacon; every tier above
/// it is a dark silhouette with no number - the unknown. Beside each
/// slab, the tiles of that tier on the board right now, as pips.
///
/// THE RISE (DE's arrival, better): the slabs come up from under their
/// seats on the drawer's ease, the foot first and each one a beat
/// behind, so the tower BUILDS as the menu opens; closing sinks it the
/// same way. The wheel walks the view a tier while the pointer is on
/// the column (eased), clamped so the beacon is never scrolled out.
///
/// Made by syst_tiles' Step while the drawer is out in landscape (no
/// left edge to spare in portrait); it leaves when either goes. Depth
/// -521: over the panel (-510) and the menu's second blur (-515) - it
/// belongs to the menu, so it stays sharp - under the header.

depth = -521;

F      = 6;     // the perspective's focal count: slot p is F/(F+p) the size of the foot (6: DE's compression)
PITCH  = 15;    // px between slabs at the foot (13 tall + 2, DE's h + 2)
SW = sprite_get_width(spr_tile);
SH = sprite_get_height(spr_tile);
cx     = 22;    // the column's centre x - every slab centres here, so the tower tapers about its own axis
foot_y = room_height - 24;   // the foot slab's top edge (the dbg buttons sit under)
top_y  = (instance_exists(syst_tiles) ? syst_tiles.board_top : 55) + 4;

// the view: the tier on the foot slab. Opens with the beacon (the
// board's highest) about two thirds of the way up, unknowns above
view    = 1;
view_to = 1;
wheel_t = 0;
__seat_view = function() {
	var _hi = variable_global_exists("tiles") ? max(1, g.tiles.highest) : 1;
	return max(1, _hi - 8);
};
view_to = __seat_view();
view    = view_to;

/// @func __slabs()
/// @desc the visible slabs, foot up: [{ tier, x, y, s, k }] - as many as
///       fit between the foot and the board's top
__slabs = function() {
	// ⚖️ CONTINUOUS SLOTS (his report, 2026-09-13: "trickle snapping"). The
	// first version seated slab k at the k-th rung and slid the whole column
	// by frac(view) x its own pitch - but the rungs are not evenly spaced,
	// so at every whole number of view the column jumped by the difference
	// between two rungs. Now a slab sits at the REAL-VALUED slot
	// p = k - frac(view): its size is F/(F+p) and its bottom edge is the
	// integral of the pitch, PITCH x F x ln(1 + p/F) above the foot - one
	// smooth curve every slab rides, so a scroll is a glide and nothing
	// ever snaps. A slab below slot 0 (p < 0) is on its way out under the
	// foot and fades as it goes.
	var _out = [];
	var _fr = frac(view);
	var _foot_b = foot_y + SH;
	for (var _k = 0; _k < 48; _k++) {
		var _p = _k - _fr;
		var _s = F / (F + _p);
		var _h = SH * _s;
		var _yb = _foot_b - PITCH * F * ln(1 + _p / F);
		var _y  = _yb - _h;
		if (_y < top_y) break;
		array_push(_out, { tier : floor(view) + _k, k : _k, p : _p, s : _s,
			x : cx - SW * _s * .5, y : _y, h : _h, w : SW * _s,
			fade : clamp(1 + _p, 0, 1) });
	}
	return _out;
};

/// @func __rise()
/// @desc the drawer's ease, 0..1 (the tower rides it)
__rise = function() {
	if (!instance_exists(syst_menu2)) return 0;
	return syst_menu2.__ease(clamp(syst_menu2.am, 0, 1));
};

/// @func __hot()
/// @desc is the pointer on the column
__hot = function() {
	return point_in_rectangle(mouse_x, mouse_y, 0, top_y, cx + SW * .5 + 12, room_height);
};
