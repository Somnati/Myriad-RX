/// @description tile_shape_draw(tier, x, y, w, h, col, alpha);
/// @param tier   0 = an empty socket (always the plain rectangle)
/// @param x
/// @param y
/// @param w
/// @param h
/// @param col
/// @param alpha
/// @param [skin]  the tile's material (tile_mat_config kind; 0 flat): the
///               body goes through sh_tile_mat (tile_mat_draw), the
///               accretion draws over it. Echoes, glows and shadows pass
///               nothing and stay flat
/// @param [seed] per-tile phase for the material
///
/// ONE TILE, DRESSED FOR ITS TIER. Two schemes, one macro:
///
/// ⚖️ TILE_SHAPES false - ACCRETION + SIZE (2026-09-10, his call to try
/// it: "do your recommendations and i'll judge"). The six-shape cycle
/// gave neighbouring tiers different outlines, which made a pair
/// findable, but a shape cycle is VARIATION, not RANK - rect, diamond,
/// ellipse say nothing about which is worth more, and he never got
/// used to it. The trashcan merge game he liked works because a bin
/// gets MORE ELABORATE as it climbs. So: one base rectangle, and every
/// tier ADDS to it rather than swapping it -
///   t2   a highlight rim along the top
///   t3+  studs in the corners, one more a tier (TL, TR, BL, BR)
///   t6+  a full inset frame
///   t7+  a base band along the bottom
///   t8+  pips on the base band, one more a tier
/// - and the tile GROWS a pixel a tier for the first three tiers, since
/// size is the one channel everyone reads as rank at a glance. Higher
/// reads as more, adjacent tiers still differ in outline, and it is all
/// spans on the same 30x13 cell - no sprites, no shader.
///
/// TILE_SHAPES true - THE SHAPE CYCLE (2026-09-09), kept whole behind
/// the macro: six silhouettes cycling (tier-1) % 6 - rect, rounded,
/// diamond, ellipse, hexagon, octagon. Flip the macro to have it back;
/// __recache's number fit reads the same macro.
///
/// EMPTY SOCKETS STAY PLAIN whatever the scheme. A socket is the shape
/// of the SPACE, and the space does not have a rarity.
///
/// (A 2D material pass and a raymarched solid were both tried the same
/// day as the shapes and both reverted - a smudge, and too much.)
function tile_shape_draw(_tier, _x, _y, _w, _h, _col, _a, _skin = 0, _seed = 0) {
	if (_a <= .003) return;

	// ================= ACCRETION + SIZE =================
	if (!TILE_SHAPES || _tier <= 0) {
		var _d = max(0, _tier - 1);
		// GROWTH: a pixel a tier, to TILE_GROW, spread round the centre so
		// the tile stays seated on its cell (the odd pixel goes right/down)
		var _g = min(_d, TILE_GROW);
		var _gx = _x - (_g div 2), _gy = _y - (_g div 2);
		var _gw = _w + _g,         _gh = _h + _g;
		// THE BODY: flat, or the tile's material (the colour law keeps its
		// mean exactly this colour - see sh_tile_mat)
		if (TILE_MATERIAL && _skin > 0 && _tier > 0)
			tile_mat_draw(_skin, _gx, _gy, _gw, _gh, _col, _a, _seed);
		else
			draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, _gw, _gh, 0, _col, _a);
		if (_d <= 0) return;   // t1 and sockets: the plain slab

		var _lt = merge_colour(_col, c_white, .28);   // the raised bits
		var _dk = merge_colour(_col, c_black, .40);   // the sunk bits

		// t2+: the rim - a highlight along the top edge, one px in
		draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + 1, _gw - 2, 1, 0, _lt, _a);

		// t6+: the frame - an inset outline a px inside the edge
		if (_d >= 5) {
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + 1, _gw - 2, 1, 0, _dk, _a * .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + _gh - 2, _gw - 2, 1, 0, _dk, _a * .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + 1, 1, _gh - 2, 0, _dk, _a * .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + _gw - 2, _gy + 1, 1, _gh - 2, 0, _dk, _a * .8);
			// the rim sits on the frame's top line, brighter than it
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 2, _gy + 1, _gw - 4, 1, 0, _lt, _a);
		}

		// t3+: the studs - 2x2 raised blocks in the corners, one more
		// a tier: top-left, top-right, bottom-left, bottom-right
		var _ns = clamp(_d - 1, 0, 4);
		var _sx = [_gx + 2, _gx + _gw - 4, _gx + 2, _gx + _gw - 4];
		var _sy = [_gy + 2, _gy + 2, _gy + _gh - 4, _gy + _gh - 4];
		for (var _k = 0; _k < _ns; _k++)
			draw_sprite_ext(spr_pixel_1x1, 0, _sx[_k], _sy[_k], 2, 2, 0, _lt, _a);

		// t7+: the base band - two darker px along the bottom
		if (_d >= 6)
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 2, _gy + _gh - 3, _gw - 4, 2, 0, _dk, _a);

		// t8+: pips on the band, one more a tier, from the centre out
		var _np = clamp(_d - 6, 0, 9);
		if (_np > 0) {
			var _pw = 2, _pg = 2;
			var _px0 = _gx + _gw * .5 - (_np * _pw + (_np - 1) * _pg) * .5;
			for (var _k = 0; _k < _np; _k++)
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_px0 + _k * (_pw + _pg)),
					_gy + _gh - 3, _pw, 1, 0, _lt, _a);
		}
		return;
	}

	// ================= THE SHAPE CYCLE (TILE_SHAPES true) =================
	var _s = (_tier - 1) % 6;
	var _hw = _w * .5;
	for (var _r = 0; _r < _h; _r++) {
		// how far this row is from the middle, 0 at the centre line and
		// 1 at the top and bottom edges. Every shape below is a curve on
		// this one number, which is why they all stay centred and all
		// scale with the tile.
		var _dd = abs(((_r + .5) / _h) - .5) * 2;
		var _in = 0;
		switch (_s) {
			case 0: break;                              // rectangle
			case 1:                                     // rounded
				if (_r == 0 || _r == _h - 1) _in = 3;
				else if (_r == 1 || _r == _h - 2) _in = 2;
				else if (_r == 2 || _r == _h - 3) _in = 1;
				break;
			case 2: _in = _dd * _hw; break;             // diamond
			case 3: _in = _hw * (1 - sqrt(max(0, 1 - _dd * _dd))); break;   // ellipse
			case 4: _in = max(0, (_dd - .45) / .55) * (_w * .40); break;   // hexagon
			case 5: _in = max(0, (_dd - .5) / .5) * (_w * .22); break;     // octagon
		}
		_in = floor(_in);
		var _sw = _w - _in * 2;
		if (_sw <= 0) continue;
		draw_sprite_ext(spr_pixel_1x1, 0, _x + _in, _y + _r, _sw, 1, 0, _col, _a);
	}
}
