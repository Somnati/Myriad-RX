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
/// ---- THE MATERIAL PASS (2026-09-09) ----
///
/// ⚖️ A THIRD CHANNEL, AND DELIBERATELY NOT 3D. He asked whether the
/// tiles should become raymarched solids like the dice and the puck,
/// with real specularity and iridescence. They should not, and the
/// reason is the same fact in both directions: THOSE OBJECTS ROTATE.
/// A die tumbles, so the face you read changes and the pips have to be
/// carved from the object-space hit point - raymarching is the only
/// thing that gets you that. A puck yaws, so its knurl travels. A board
/// tile sits in a fixed grid and never turns at all, so a raymarched
/// tile would burn a ray per pixel to produce a picture identical every
/// frame. Fake 3D on a static object is an expensive sprite.
///
/// Iridescence is the sharpest case. sh_dice sweeps hue by the FACING
/// term - how edge-on each pixel is - which is why a pearl die changes
/// colour as it turns. On a flat static tile that term is constant, so
/// the whole film model collapses to a flat tint. What DOES read on a
/// static object is a hue sweep across its WIDTH, which is a gradient
/// and costs nothing.
///
/// So the material is drawn, not lit:
///   grad   vertical shading - tight for metal, broad for matte
///   rim    a lit top edge and a dark bottom one
///   pip    one specular mark, present on metals and absent on plain
///   iri    a hue sweep across the tile's width (the oil-slick read)
///
/// ⚖️ ROLLED PER TIER, NOT CLIMBED (his call, 2026-09-09 - "for now").
/// It rode the rarity ladder first: plain low, precious high, the
/// language every loot game has already taught. He wants to see them
/// random instead, so every tier draws its own surface out of the hat.
///
/// STABLE, THOUGH, and that is the part that matters. A material
/// re-rolled per frame is a strobe, and one re-rolled per instance
/// means two tier-7s on the same board look like different things -
/// which would destroy exactly the pair-finding the shape channel
/// exists to serve. The four values are HASHED FROM THE TIER, so a
/// tier is one material forever, on every board, across saves.
///
/// The hash is sin/frac rather than random_set_seed: it touches no RNG
/// stream, needs no seed save-and-restore (vis_tier_color's own trap -
/// DE's version scrambled the caller's stream mid-formula), needs no
/// cache, and is pure. Sixteen tiles a frame times four values is
/// nothing next to a seeded roll and a restore.
///
/// SHAPE STILL CYCLES, deliberately, and I have not changed it: it is
/// the channel that makes NEIGHBOURING tiers differ, which is how a
/// pair is spotted. If material also cycled they would fight; random
/// material against cycling shape keeps the two answering different
/// questions.
///
/// @param [mat]  false = a flat fill, no material. The overlays (hover,
///               merge flash, automerge tell, drag assist, the ghost's
///               shadow) are washes ON a tile rather than tiles, and a
///               specular pip on a .25-alpha overlay is a bright dot
///               floating over the board.
function tile_shape_draw(_tier, _x, _y, _w, _h, _col, _a, _mat = false) {
	if (_a <= .003) return;
	var _s = (_tier <= 0) ? 0 : ((_tier - 1) % 6);
	var _hw = _w * .5;

	// ---- the material, hashed from the tier ----
	// Four independent streams off the same tier, so the values do not
	// correlate - a shiny tile is not automatically also an iridescent
	// one. See the header for why this is a hash and not a seeded roll.
	var _grad = 0, _rim = 0, _pip = 0, _iri = 0;
	if (_mat && _tier > 0) {
		var _h1 = frac(sin(_tier * 12.9898) * 43758.5453);
		var _h2 = frac(sin(_tier * 78.2330) * 27182.8182);
		var _h3 = frac(sin(_tier * 45.1640) * 31415.9265);
		var _h4 = frac(sin(_tier * 94.6730) * 16180.3399);

		_grad = lerp(.08, .55, _h1);
		_rim  = lerp(0,   .50, _h2);
		// a third of tiers get NO specular at all. A board where every
		// tile glints is a board where the glint says nothing - the
		// plain ones are what make the shiny ones read as shiny.
		_pip = (_h3 < .34) ? 0 : lerp(.20, .90, (_h3 - .34) / .66);
		// and a fifth are films. Rarer still, because it is the loudest
		// of the four and the one that fights the digit hardest.
		_iri = (_h4 < .80) ? 0 : lerp(.25, .55, (_h4 - .80) / .20);
	}

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

		if (!_mat) {
			draw_sprite_ext(spr_pixel_1x1, 0, _x + _in, _y + _r, _sw, 1, 0,
				_col, _a);
			continue;
		}

		// vertical shading: bright at the top, dark at the bottom, from
		// the same light every raised thing in this game uses
		var _v = 1 - (_r / max(1, _h - 1));          // 1 top .. 0 bottom
		var _cl = merge_colour(_col, c_black, _grad * (1 - _v));
		_cl = merge_colour(_cl, c_white, _grad * _v * .55);
		// the rim: only the outermost rows, and only if the material has
		// one - it is what separates a polished tile from a painted one
		if (_rim > 0) {
			if (_r == 0)      _cl = merge_colour(_cl, c_white, _rim);
			if (_r == _h - 1) _cl = merge_colour(_cl, c_black, _rim);
		}

		var _cr = _cl;
		// the film: a hue sweep across the WIDTH. On a static tile this
		// is what iridescence can honestly be - the angle-driven version
		// needs an angle, and this object has exactly one.
		if (_iri > 0) {
			_cl = merge_colour(_cl, vis_tier_color(_tier + 2), _iri * _v);
			_cr = merge_colour(_cr, vis_tier_color(_tier + 5), _iri * _v);
		}

		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _r, _sw, 1, 0, _cl, _cr, _cr, _cl, _a);
	}

	// ---- the specular mark ----
	// ONE pixel pair, up and left, where the house light comes from. It
	// is the whole difference between "a coloured shape" and "a coloured
	// shape made of something", and it is deliberately tiny: this object
	// is 13px tall and carries a number, so a highlight big enough to
	// admire is a highlight that eats the digit.
	if (_mat && _pip > 0)
		draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y + 2, 2, 1, 0,
			merge_colour(_col, c_white, .85), _pip * _a);
}
