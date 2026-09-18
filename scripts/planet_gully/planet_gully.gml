/// @description planet_gully(pn, u, v, lift) -> the GULLIES' height term at a map coordinate (elevation units, about zero): fine ridges and channels down every range's flank
/// THE GULLIES (his ask, 2026-09-17: "every range to have continuous tiny
/// branches"): a RIDGED value noise on three lattices - two texels, one,
/// and a half - whose crests are countless small connected ridges with
/// channels between, masked by the range skeleton's lift so plains stay
/// smooth and every spur carries them. INTO THE HEIGHTS (planet_ranges
/// adds it to pn.elev under every lift and re-runs the biome law): the
/// crests reach the peaks' line, so a range's crown is a spiky, branching
/// thing of rock and snow, and the drainage runs down the channels. (The
/// first cut was height-texture only, a whisper in the shading - "not
/// noticeable... the same noodle look", his report.) Hashed off the seed
function planet_gully(_pn, _u, _v, _lift) {
	if (_lift <= 0) return 0;
	var _m = clamp(_lift / .06, 0, 1);
	var _s = _pn.seed;
	// two octaves of 2d value noise on the map's own lattice (x wraps), each folded into ridges
	var _g = 0, _amp = .5, _fx = _pn.tw * .5, _fy = _pn.th * .5;
	repeat (3) {
		var _x = _u * _fx, _y = _v * _fy;
		var _ix = floor(_x), _iy = floor(_y), _tx = _x - _ix, _ty = _y - _iy;
		_tx = _tx * _tx * (3 - 2 * _tx); _ty = _ty * _ty * (3 - 2 * _ty);
		var _wx = _fx;   // (the lattice wraps at the map's seam)
		var _x0 = ((_ix mod _wx) + _wx) mod _wx, _x1 = (_x0 + 1) mod _wx;
		var _h00 = planet_gully_h(_x0, _iy, _s), _h10 = planet_gully_h(_x1, _iy, _s), _h01 = planet_gully_h(_x0, _iy + 1, _s), _h11 = planet_gully_h(_x1, _iy + 1, _s);
		var _n = lerp(lerp(_h00, _h10, _tx), lerp(_h01, _h11, _tx), _ty);
		_g += (1 - abs(2 * _n - 1)) * _amp;   // (ridged: the crests are the lattice's middle crossings - lines)
		_amp = (_amp > .4) ? .3 : .2; _fx *= 2; _fy *= 2; _s += 7919;
	}
	return (_g - .45) * .17 * _m;
}
