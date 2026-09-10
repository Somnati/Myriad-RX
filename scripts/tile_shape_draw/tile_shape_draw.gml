/// @description tile_shape_draw(tier, x, y, w, h, col, alpha);
/// @param tier   0 = an empty socket (always the plain rectangle)
/// @param x
/// @param y
/// @param w
/// @param h
/// @param col
/// @param alpha
///
/// ONE TILE, IN THE SHAPE ITS TIER WEARS (his ask, 2026-09-09: each tier
/// a different shape - rectangular, diamond, default, circular, etc).
///
/// ⚖️ SHAPE IS A SECOND CHANNEL, and on a merge board that is worth more
/// than decoration. Colour already separates the tiers, but colour is
/// the one channel that fails people - and a 30x13 tile at a glance,
/// eight of them on screen, is exactly the case where two adjacent rungs
/// of a rarity ladder look alike. Cycling the shape every tier means
/// NEIGHBOURING tiers never share one, so a pair is findable by outline
/// alone. That is the actual game being played.
///
/// The cycle is 6 and the ladder is longer than that, so shapes repeat -
/// but a tier and the tier six above it are never on the board together
/// in any state worth reading, and their colours are decades apart by
/// then anyway.
///
/// ⚖️ DRAWN AS HORIZONTAL SPANS, not sprites. Six shapes at one size
/// would be six subimages that have to be re-cut the day a tile changes
/// dimensions, and spr_tile is 30x13 - a shape sheet at that size is
/// unreadable to edit. An inset function per row is the same thing the
/// puck's disc and the upgrade slots' rounded corners are built from,
/// it costs h draws, and it scales to any w/h for free. House rule
/// either way: hard pixels only.
///
/// EMPTY SOCKETS STAY RECTANGULAR whatever tier the slot last held. A
/// socket is not a tile and must not look like one - it is the shape of
/// the SPACE, and the space does not have a rarity.
///
/// ⚖️ FLAT, AND ONLY THE OUTLINE (2026-09-09). This painted a 2D
/// "material" for one commit - a gradient, a rim, a specular pip - and
/// it looked like a smudge, because a flat draw has no surface for
/// light to fall across. The tiles are raymarched solids now (sh_tile,
/// via syst_tiles' __tile_solid) and THAT is where material lives.
/// This function is the flat twin: the empty sockets, the held tile's
/// echo, and every wash drawn OVER a solid - hover, merge flash, the
/// automerge tell, the drag assist, the ghost's shadow. It keeps the
/// same six-shape cycle so a wash has its solid's own outline.
function tile_shape_draw(_tier, _x, _y, _w, _h, _col, _a) {
	if (_a <= .003) return;
	var _s = (_tier <= 0) ? 0 : ((_tier - 1) % 6);
	var _hw = _w * .5;


	for (var _r = 0; _r < _h; _r++) {
		// how far this row is from the middle, 0 at the centre line and
		// 1 at the top and bottom edges. Every shape below is a curve on
		// this one number, which is why they all stay centred and all
		// scale with the tile.
		var _d = abs(((_r + .5) / _h) - .5) * 2;
		var _in = 0;

		switch (_s) {
			case 0: break;                              // rectangle
			case 1:                                     // rounded
				// a 3px corner. The upgrade slots use 2, but they are
				// read one at a time in a list - these are read eight at
				// once against a rectangle, and 2px of difference does
				// not survive that.
				if (_r == 0 || _r == _h - 1) _in = 3;
				else if (_r == 1 || _r == _h - 2) _in = 2;
				else if (_r == 2 || _r == _h - 3) _in = 1;
				break;
			case 2:                                     // diamond
				_in = _d * _hw;
				break;
			case 3:                                     // circle (ellipse)
				_in = _hw * (1 - sqrt(max(0, 1 - _d * _d)));
				break;
			case 4:                                     // hexagon
				// ⚖️ SHARPER THAN IT WANTS TO BE, deliberately. A gentle
				// hex taper at thirteen rows is visually the same object
				// as the ellipse above it - I drew both and could not
				// tell them apart. A long flat middle and a hard linear
				// taper is what makes it read as ANGULAR rather than as
				// a slightly worse circle.
				_in = max(0, (_d - .45) / .55) * (_w * .40);
				break;
			case 5:                                     // octagon
				_in = max(0, (_d - .5) / .5) * (_w * .22);
				break;
		}

		_in = floor(_in);
		var _sw = _w - _in * 2;
		if (_sw <= 0) continue;

		draw_sprite_ext(spr_pixel_1x1, 0, _x + _in, _y + _r, _sw, 1, 0, _col, _a);
	}
}
