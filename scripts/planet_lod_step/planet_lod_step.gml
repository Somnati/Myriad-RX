/// @description planet_lod_step(pn, l, until) -> true once the tier stands (l.ready): builds rows of a zoom tier (planet_lod_begin) until the get_timer deadline
/// A tier texel is the terrain SAMPLED THERE (planet_texel at the tier
/// texel's own centre, exactly as the base map's texels were at theirs)
/// WHERE THE MAP'S TEXELS DISAGREE - the four base texels around it are not
/// one biome - and the base's own biome elsewhere (its height between the
/// four). So a coast, a wood's edge, a river's bank is truly resolved,
/// the inside of a plain costs nothing, and the tier agrees with the map
/// everywhere the map is sure. (The first cut interpolated the fields
/// everywhere: a smoothed field misses its thresholds and every biome
/// shifted between tiers; the second sampled everywhere: whole minutes
/// of noise at 4x - his reports, 2026-09-17)
/// Rivers and lakes ride over from the base biome map: a lake's texel
/// whole, a river as a line through its texel toward each river or water
/// neighbour. The colour texture (rgb the biome's colour, alpha 1 - glow)
/// and the height texture (red the height, green water, blue the woods on
/// land / the depth under water) match planet_bake's exactly. Into
/// buffers (surface_byte_order's channel order), up as textures at the end
function planet_lod_step(_pn, _l, _until) {
	if (_l.ready) return true;
	if (!buffer_exists(_l.tbuf) || !buffer_exists(_l.hbuf)) return false;
	var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
	var _tb = _l.tbuf, _hb = _l.hbuf;
	var _ps = _pn.smp, _tw = _pn.tw, _th = _pn.th, _k = _l.k, _w = _l.w;
	var _el = _pn.elev, _bm = _pn.biome, _pal = _pn.pal, _glow = _pn.glow, _gas = (_pn.kind == "gas"), _sea = _pn.sea;
	var _base = _gas ? 1 : max(_sea, .34);
	while (_l.row < _l.h && get_timer() < _until) {
		var _j = _l.row, _v = (_j + .5) / _l.h, _by = _j div _k, _fy = ((_j mod _k) + .5) / _k;
		var _yy = _v * _th - .5, _y0 = floor(_yy), _ty = _yy - _y0, _y1 = clamp(_y0 + 1, 0, _th - 1);
		_y0 = clamp(_y0, 0, _th - 1);
		var _o = (_j * _w + _l.col) * 4;
		for (var _i = _l.col; _i < _w; _i++) {
			var _u = (_i + .5) / _w;
			var _xx = _u * _tw - .5, _x0 = floor(_xx), _tx = _xx - _x0;
			var _x1 = (_x0 + 1 + _tw) mod _tw; _x0 = (_x0 + _tw) mod _tw;   // (the seam wraps)
			var _i00 = _x0 + _y0 * _tw, _i10 = _x1 + _y0 * _tw, _i01 = _x0 + _y1 * _tw, _i11 = _x1 + _y1 * _tw;
			var _b, _oe, _b00 = _bm[_i00];
			if (_b00 == _bm[_i10] && _b00 == _bm[_i01] && _b00 == _bm[_i11]) {
				// the map is sure here: its biome, its height between the four
				_b = _b00;
				_oe = _el[_i00] * (1 - _tx) * (1 - _ty) + _el[_i10] * _tx * (1 - _ty) + _el[_i01] * (1 - _tx) * _ty + _el[_i11] * _tx * _ty;
			} else {
				planet_texel(_ps, _u, _v);
				_b = _ps.ob; _oe = _ps.oe;
			}
			if (!_gas) {
				var _bx = _i div _k, _bi = _bx + _by * _tw, _fx = ((_i mod _k) + .5) / _k;
				var _bb = _bm[_bi], _natl = !(_b == 0 || _b == 1 || _b == 11);
				if (_natl && _el[_bi] >= _sea) {   // (the base texel is land: its water is a lake or a river, not the coast's own call)
					if (_bb == 1) _b = 1;
					else if (_bb == 11) {
						var _hit = false, _any = false, _rw = .6 / _k;
						for (var _dy = -1; _dy <= 1 && !_hit; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
							if (_dx == 0 && _dy == 0) continue;
							var _ny = _by + _dy; if (_ny < 0 || _ny >= _th) continue;
							var _nb = _bm[((_bx + _dx + _tw) mod _tw) + _ny * _tw];
							if (!(_nb == 0 || _nb == 1 || _nb == 11)) continue;
							_any = true;
							var _px2 = _fx - .5, _py2 = _fy - .5, _sx = _dx * .5, _sy = _dy * .5;
							var _tt = clamp((_px2 * _sx + _py2 * _sy) / (_sx * _sx + _sy * _sy), 0, 1);
							var _ddx = _px2 - _sx * _tt, _ddy = _py2 - _sy * _tt;
							if (sqrt(_ddx * _ddx + _ddy * _ddy) < _rw) { _hit = true; break; }
						}
						if (!_any && point_distance(_fx, _fy, .5, .5) < _rw) _hit = true;
						if (_hit) _b = 11;
					}
				}
			}
			var _c = _pal[_b];
			buffer_poke(_tb, _o + _or, buffer_u8, colour_get_red(_c)); buffer_poke(_tb, _o + _og, buffer_u8, colour_get_green(_c)); buffer_poke(_tb, _o + _ob, buffer_u8, colour_get_blue(_c)); buffer_poke(_tb, _o + _oa, buffer_u8, 255 - floor(_glow[_b] * 255));
			var _h = _gas ? 0 : power(clamp((_oe - _base) / max(.001, 1 - _base), 0, 1), 1.6);
			var _wat = (!_gas && (_b == 0 || _b == 1 || _b == 11)) ? 255 : 0;
			var _for = (!_gas) ? ((_b == 5 || _b == 6) ? 255 : ((_b == 12) ? 140 : 0)) : 0;
			if (_wat > 0) _for = floor(clamp((_sea - _oe) / .08, 0, 1) * 255);
			buffer_poke(_hb, _o + _or, buffer_u8, floor(_h * 255)); buffer_poke(_hb, _o + _og, buffer_u8, _wat); buffer_poke(_hb, _o + _ob, buffer_u8, _for); buffer_poke(_hb, _o + _oa, buffer_u8, 255);
			_o += 4;
			// (the deadline inside the row too: a row of a tier is a thousand texels and more, and a frame's share is a few ms)
			if ((_i & 31) == 31 && get_timer() >= _until) { _l.col = _i + 1; return false; }
		}
		_l.col = 0;
		_l.row++;
	}
	if (_l.row >= _l.h) {
		_l.tsurf = surface_create(_l.w, _l.h); _l.hsurf = surface_create(_l.w, _l.h);
		buffer_set_surface(_l.tbuf, _l.tsurf, 0); buffer_set_surface(_l.hbuf, _l.hsurf, 0);
		buffer_delete(_l.tbuf); buffer_delete(_l.hbuf); _l.tbuf = -1; _l.hbuf = -1;
		_l.ready = true;
	}
	return _l.ready;
}
